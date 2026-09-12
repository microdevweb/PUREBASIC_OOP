; =============================================================================
; ORM_CRUD.pbi - Core INSERT / UPDATE / DELETE / SELECT operations
; PureBasic OOP Framework - Alpha 1.4 (Phase 2)
; =============================================================================
; All procedures in this module are SYNCHRONOUS and intended to be called
; from background worker threads (never directly from the UI thread).
;
; Field values are serialized to/from a string Map via developer-supplied
; procedures. The ORM engine reads field type metadata to produce correct SQL
; literals (quoted strings, bare integers, boolean 0/1).
;
; ID field convention:
;   The `id` field MUST be the first field declared in every entity class.
;   The ORM accesses it via the ORM_EntityBase helper structure cast.
;   After an INSERT, the new auto-increment id is written back to the entity.
; =============================================================================

XIncludeFile "ORM_Schema.pbi"
XIncludeFile "IDatabaseEntity.pbi"

DeclareModule ORM_CRUD

  UseModule DatabaseEntities

  ; Base accessor: id is always the first integer field in non-OOP entities.
  ; For OOP entities with VTable, access via IDatabaseEntity.
  Structure ORM_EntityBase
    id.i          ; offset 0 - primary key
    orm_isNew.b   ; offset 4 (or 8 on 64-bit) - True before first save
    orm_isDirty.b ; True if any field changed since last save/load
  EndStructure

  Declare.i GetEntityId(*entity, *meta.ORM_Schema::ORM_EntityMeta)
  Declare SetEntityId(*entity, *meta.ORM_Schema::ORM_EntityMeta, id.i)
  Declare SetEntityStatus(*entity, *meta.ORM_Schema::ORM_EntityMeta, isNew.b, isDirty.b)

  ; --- SQL escaping: double single-quotes to prevent SQL injection ---
  Declare.s EscapeStr(s.s)

  ; --- Convert a string value + ORM type code to a safe SQL literal ---
  ; Strings -> 'escaped', integers/booleans -> bare number, doubles -> decimal
  Declare.s ValueToSQL(value.s, typeCode.i)

  ; --- INSERT new entity, writes back the new auto-increment id ---
  ; Returns #True on success.
  Declare.b Insert(db.i, entityType.s, *entity, serializeProc.i)

  ; --- UPDATE existing entity (id must be > 0) ---
  ; Returns #True on success.
  Declare.b Update(db.i, entityType.s, *entity, serializeProc.i)

  ; --- INSERT or UPDATE depending on whether id=0 (new) or id>0 (existing) ---
  Declare.b InsertOrUpdate(db.i, entityType.s, *entity, serializeProc.i)

  ; --- Save a single child entity with FK column forced to parentId ---
  ; Used inside saveChildrenProc callbacks for cascade save.
  ; fkColumn.s : "clientId" - the FK column name in the child table
  Declare.b SaveOne(db.i, childEntityType.s, *child, parentId.i, fkColumn.s, serializeProc.i)

  ; --- DELETE record by id, without FK enforcement (handled by ORM_Relations) ---
  Declare.b DeleteById(db.i, entityType.s, recordId.i)

  ; --- SELECT one row into a map (used by Reload and FindById) ---
  Declare.b SelectById(db.i, entityType.s, recordId.i, Map outValues.s())

  ; --- Load one entity from DB by id, fills *entity via deserializeProc ---
  ; Returns #ORM_Success or #ORM_Error_NotFound / #ORM_Error_DbConnection.
  Declare.i FindById(db.i, entityType.s, recordId.i, *entity, deserializeProc.i)

  ; --- Query: load a list of entity pointers matching a WHERE clause ---
  ; Worker creates new entities via newEntityProc and fills via deserializeProc.
  ; The caller owns the returned entity pointers and must free them.
  ; Returns #ORM_Success or error code.
  Declare.i Query(db.i, entityType.s, whereClause.s,
                  List results.i(),
                  newEntityProc.i, deserializeProc.i)

EndDeclareModule

Module ORM_CRUD

  UseModule ORM_Dialect_SQLite

  ; ---------------------------------------------------------------------------
  ; SQL string escaping: double single-quotes
  ; ---------------------------------------------------------------------------
  Procedure.s EscapeStr(s.s)
    ProcedureReturn "'" + ReplaceString(s, "'", "''") + "'"
  EndProcedure

  ; ---------------------------------------------------------------------------
  ; Convert a string value to the correct SQL literal for its type
  ; ---------------------------------------------------------------------------
  Procedure.s ValueToSQL(value.s, typeCode.i)
    Select typeCode
      Case #ORM_Type_String                      ; TEXT -> 'escaped string'
        ProcedureReturn EscapeStr(value)
      Case #ORM_Type_Bool                        ; BOOLEAN -> 0 or 1
        If value = "1" Or LCase(value) = "true"
          ProcedureReturn "1"
        Else
          ProcedureReturn "0"
        EndIf
      Case #ORM_Type_Double, #ORM_Type_Float     ; REAL -> decimal point value
        ProcedureReturn StrD(ValD(value))
      Default                                    ; INTEGER / FK -> bare number
        ProcedureReturn Str(Val(value))
    EndSelect
  EndProcedure

  Procedure.i GetEntityId(*entity, *meta.ORM_Schema::ORM_EntityMeta)
    If Not *entity : ProcedureReturn 0 : EndIf
    If *meta And *meta\isOOP
      Protected ent.DatabaseEntities::IDatabaseEntity = *entity
      ProcedureReturn ent\GetId()
    Else
      Protected *base.ORM_CRUD::ORM_EntityBase = *entity
      ProcedureReturn *base\id
    EndIf
  EndProcedure

  Procedure SetEntityId(*entity, *meta.ORM_Schema::ORM_EntityMeta, id.i)
    If Not *entity : ProcedureReturn : EndIf
    If *meta And *meta\isOOP
      Protected ent.DatabaseEntities::IDatabaseEntity = *entity
      ent\SetId(id)
    Else
      Protected *base.ORM_CRUD::ORM_EntityBase = *entity
      *base\id = id
    EndIf
  EndProcedure

  Procedure SetEntityStatus(*entity, *meta.ORM_Schema::ORM_EntityMeta, isNew.b, isDirty.b)
    If Not *entity : ProcedureReturn : EndIf
    If *meta And *meta\isOOP
      Protected ent.DatabaseEntities::IDatabaseEntity = *entity
      ent\SetNew(isNew)
      ent\SetDirty(isDirty)
    Else
      Protected *base.ORM_CRUD::ORM_EntityBase = *entity
      *base\orm_isNew = isNew
      *base\orm_isDirty = isDirty
    EndIf
  EndProcedure

  ; ---------------------------------------------------------------------------
  ; Internal helper: get SQLite last insert row id
  ; ---------------------------------------------------------------------------
  Procedure.i LastInsertedID(db.i)
    Protected id.i = 0
    If DatabaseQuery(db, "SELECT last_insert_rowid();")
      If NextDatabaseRow(db)
        id = GetDatabaseLong(db, 0)
      EndIf
      FinishDatabaseQuery(db)
    EndIf
    ProcedureReturn id
  EndProcedure

  ; ---------------------------------------------------------------------------
  ; Internal: build column+value lists from entity metadata and serialized map
  ; Returns #False if entity is not registered.
  ; ---------------------------------------------------------------------------
  Procedure.b BuildInsertParts(entityType.s, Map values.s(),
                               skippedFK.s,    ; FK column whose value is already in map (or "")
                               *outCols.String, *outVals.String)
    Protected *meta.ORM_Schema::ORM_EntityMeta = ORM_Schema::FindEntityMeta(entityType)
    If Not *meta : ProcedureReturn #False : EndIf

    Protected cols.s = ""
    Protected vals.s = ""
    Protected first.b = #True

    ForEach *meta\fields()
      If *meta\fields()\name = "id" : Continue : EndIf  ; id is auto-increment

      If Not first : cols + ", " : vals + ", " : EndIf
      cols + *meta\fields()\name
      Protected fv.s = values(*meta\fields()\name)
      vals + ValueToSQL(fv, *meta\fields()\typeCode)
      first = #False
    Next

    *outCols\s = cols
    *outVals\s = vals
    ProcedureReturn #True
  EndProcedure

  ; ---------------------------------------------------------------------------
  ; INSERT: serialize entity, build SQL, execute, write back new id
  ; ---------------------------------------------------------------------------
  Procedure.b Insert(db.i, entityType.s, *entity, serializeProc.i)
    Protected *meta.ORM_Schema::ORM_EntityMeta = ORM_Schema::FindEntityMeta(entityType)
    If Not *meta : ProcedureReturn #False : EndIf

    Protected serialize.ORM_Schema::ORM_SerializeProto = serializeProc
    NewMap values.s()
    serialize(*entity, values())

    Protected cols.s = ""
    Protected vals.s = ""
    Protected first.b = #True

    ForEach *meta\fields()
      If *meta\fields()\name = "id" : Continue : EndIf
      If Not first : cols + ", " : vals + ", " : EndIf
      Protected fv.s = values(*meta\fields()\name)
      vals + ValueToSQL(fv, *meta\fields()\typeCode)
      cols + *meta\fields()\name
      first = #False
    Next

    Protected sql.s = "INSERT INTO " + *meta\tableName +
                      " (" + cols + ") VALUES (" + vals + ");"
    Debug "ORM_CRUD::Insert -> " + sql

    If ORM_Transaction::Execute(db, sql)
      Protected newId.i = LastInsertedID(db)
      SetEntityId(*entity, *meta, newId)
      SetEntityStatus(*entity, *meta, #False, #False)
      Debug "ORM_CRUD::Insert OK - new id=" + Str(newId)
      ProcedureReturn #True
    Else
      Debug "ORM_CRUD::Insert FAILED: " + DatabaseError()
      ProcedureReturn #False
    EndIf
  EndProcedure

  ; ---------------------------------------------------------------------------
  ; UPDATE: serialize entity, build SET clause, execute
  ; ---------------------------------------------------------------------------
  Procedure.b Update(db.i, entityType.s, *entity, serializeProc.i)
    Protected *meta.ORM_Schema::ORM_EntityMeta = ORM_Schema::FindEntityMeta(entityType)
    If Not *meta : ProcedureReturn #False : EndIf

    Protected entId.i = GetEntityId(*entity, *meta)
    If entId = 0
      Debug "ORM_CRUD::Update ERROR: id=0 - use Insert() for new entities"
      ProcedureReturn #False
    EndIf

    Protected serialize.ORM_Schema::ORM_SerializeProto = serializeProc
    NewMap values.s()
    serialize(*entity, values())

    Protected sets.s  = ""
    Protected first.b = #True

    ForEach *meta\fields()
      If *meta\fields()\name = "id" : Continue : EndIf
      If Not first : sets + ", " : EndIf
      Protected fv.s = values(*meta\fields()\name)
      sets + *meta\fields()\name + "=" + ValueToSQL(fv, *meta\fields()\typeCode)
      first = #False
    Next

    Protected sql.s = "UPDATE " + *meta\tableName +
                      " SET " + sets +
                      " WHERE id=" + Str(entId) + ";"
    Debug "ORM_CRUD::Update -> " + sql

    If ORM_Transaction::Execute(db, sql)
      SetEntityStatus(*entity, *meta, #False, #False)
      Debug "ORM_CRUD::Update OK id=" + Str(entId)
      ProcedureReturn #True
    Else
      Debug "ORM_CRUD::Update FAILED: " + DatabaseError()
      ProcedureReturn #False
    EndIf
  EndProcedure

  ; ---------------------------------------------------------------------------
  ; InsertOrUpdate: branch on id value
  ; ---------------------------------------------------------------------------
  Procedure.b InsertOrUpdate(db.i, entityType.s, *entity, serializeProc.i)
    Protected *meta.ORM_Schema::ORM_EntityMeta = ORM_Schema::FindEntityMeta(entityType)
    If Not *meta : ProcedureReturn #False : EndIf

    Protected isNew.b = #False
    If *meta\isOOP
      Protected ent.DatabaseEntities::IDatabaseEntity = *entity
      isNew = Bool(ent\GetId() = 0 Or ent\IsNew())
    Else
      Protected *base.ORM_CRUD::ORM_EntityBase = *entity
      isNew = Bool(*base\id = 0 Or *base\orm_isNew)
    EndIf

    If isNew
      ProcedureReturn Insert(db, entityType, *entity, serializeProc)
    Else
      ProcedureReturn Update(db, entityType, *entity, serializeProc)
    EndIf
  EndProcedure

  ; ---------------------------------------------------------------------------
  ; SaveOne: save a child entity and force its FK column to parentId
  ; Used inside cascade save callbacks (saveChildrenProc)
  ; ---------------------------------------------------------------------------
  Procedure.b SaveOne(db.i, childEntityType.s, *child, parentId.i, fkColumn.s, serializeProc.i)
    Protected *meta.ORM_Schema::ORM_EntityMeta = ORM_Schema::FindEntityMeta(childEntityType)
    If Not *meta : ProcedureReturn #False : EndIf

    Protected serialize.ORM_Schema::ORM_SerializeProto = serializeProc
    NewMap values.s()
    serialize(*child, values())

    ; Force the FK column to the parent id (overrides whatever the developer set)
    values(fkColumn) = Str(parentId)

    Protected isNewChild.b = #False
    If *meta\isOOP
      Protected entChild.DatabaseEntities::IDatabaseEntity = *child
      isNewChild = Bool(entChild\GetId() = 0 Or entChild\IsNew())
    Else
      Protected *base.ORM_CRUD::ORM_EntityBase = *child
      isNewChild = Bool(*base\id = 0 Or *base\orm_isNew)
    EndIf

    Protected sql.s
    Protected ok.b

    If isNewChild
      ; INSERT new child
      Protected cols.s  = ""
      Protected vals.s  = ""
      Protected first.b = #True
      ForEach *meta\fields()
        If *meta\fields()\name = "id" : Continue : EndIf
        If Not first : cols + ", " : vals + ", " : EndIf
        Protected fv.s = values(*meta\fields()\name)
        vals + ValueToSQL(fv, *meta\fields()\typeCode)
        cols + *meta\fields()\name
        first = #False
      Next
      sql = "INSERT INTO " + *meta\tableName +
            " (" + cols + ") VALUES (" + vals + ");"
      Debug "ORM_CRUD::SaveOne INSERT -> " + sql
      ok = ORM_Transaction::Execute(db, sql)
      If ok
        SetEntityId(*child, *meta, LastInsertedID(db))
        SetEntityStatus(*child, *meta, #False, #False)
      EndIf
    Else
      ; UPDATE existing child
      Protected sets.s = ""
      first = #True
      ForEach *meta\fields()
        If *meta\fields()\name = "id" : Continue : EndIf
        If Not first : sets + ", " : EndIf
        fv = values(*meta\fields()\name)
        sets + *meta\fields()\name + "=" + ValueToSQL(fv, *meta\fields()\typeCode)
        first = #False
      Next
      sql = "UPDATE " + *meta\tableName +
            " SET " + sets +
            " WHERE id=" + Str(GetEntityId(*child, *meta)) + ";"
      Debug "ORM_CRUD::SaveOne UPDATE -> " + sql
      ok = ORM_Transaction::Execute(db, sql)
      If ok
        SetEntityStatus(*child, *meta, #False, #False)
      EndIf
    EndIf

    If ok
      ForEach *meta\relations()
        If *meta\relations()\saveChildrenProc <> 0
          Protected saveChildProc.ORM_Schema::ORM_SaveChildrenProto = *meta\relations()\saveChildrenProc
          saveChildProc(*child, db)
        EndIf
      Next
    EndIf

    ProcedureReturn ok
  EndProcedure

  ; ---------------------------------------------------------------------------
  ; DeleteById: straight DELETE without relation checks
  ; ---------------------------------------------------------------------------
  Procedure.b DeleteById(db.i, entityType.s, recordId.i)
    Protected *meta.ORM_Schema::ORM_EntityMeta = ORM_Schema::FindEntityMeta(entityType)
    If Not *meta : ProcedureReturn #False : EndIf

    Protected sql.s = "DELETE FROM " + *meta\tableName + " WHERE id=" + Str(recordId) + ";"
    Debug "ORM_CRUD::DeleteById -> " + sql
    ProcedureReturn ORM_Transaction::Execute(db, sql)
  EndProcedure

  ; ---------------------------------------------------------------------------
  ; SelectById: load one record into a map (used by Reload and FindById)
  ; ---------------------------------------------------------------------------
  Procedure.b SelectById(db.i, entityType.s, recordId.i, Map outValues.s())
    Protected *meta.ORM_Schema::ORM_EntityMeta = ORM_Schema::FindEntityMeta(entityType)
    If Not *meta : ProcedureReturn #False : EndIf

    Protected sql.s = "SELECT * FROM " + *meta\tableName + " WHERE id=" + Str(recordId) + " LIMIT 1;"
    If Not DatabaseQuery(db, sql)
      ProcedureReturn #False
    EndIf

    If Not NextDatabaseRow(db)
      FinishDatabaseQuery(db)
      ProcedureReturn #False
    EndIf

    ClearMap(outValues())
    Protected numCols.i = DatabaseColumns(db)
    Protected i.i
    For i = 0 To numCols - 1
      outValues(DatabaseColumnName(db, i)) = GetDatabaseString(db, i)
    Next
    FinishDatabaseQuery(db)
    ProcedureReturn #True
  EndProcedure

  ; ---------------------------------------------------------------------------
  ; FindById: SELECT one row and fill *entity via deserializeProc
  ; ---------------------------------------------------------------------------
  Procedure.i FindById(db.i, entityType.s, recordId.i, *entity, deserializeProc.i)
    Protected *meta.ORM_Schema::ORM_EntityMeta = ORM_Schema::FindEntityMeta(entityType)
    If Not *meta : ProcedureReturn ORM_Entity::#ORM_Error_NotFound : EndIf

    Protected sql.s = "SELECT * FROM " + *meta\tableName + " WHERE id=" + Str(recordId) + " LIMIT 1;"
    Debug "ORM_CRUD::FindById -> " + sql

    If Not DatabaseQuery(db, sql)
      Debug "ORM_CRUD::FindById ERROR: " + DatabaseError()
      ProcedureReturn ORM_Entity::#ORM_Error_DbConnection
    EndIf

    If Not NextDatabaseRow(db)
      FinishDatabaseQuery(db)
      Debug "ORM_CRUD::FindById: record " + Str(recordId) + " not found"
      ProcedureReturn ORM_Entity::#ORM_Error_NotFound
    EndIf

    NewMap values.s()
    Protected numCols.i = DatabaseColumns(db)
    Protected i.i
    For i = 0 To numCols - 1
      values(DatabaseColumnName(db, i)) = GetDatabaseString(db, i)
    Next
    FinishDatabaseQuery(db)

    ; Write id and state flags back
    SetEntityId(*entity, *meta, Val(values("id")))
    SetEntityStatus(*entity, *meta, #False, #False)

    ; Call developer-supplied deserialize proc to fill the remaining fields
    Protected deserialize.ORM_Schema::ORM_DeserializeProto = deserializeProc
    deserialize(*entity, values())

    Debug "ORM_CRUD::FindById OK - id=" + Str(GetEntityId(*entity, *meta))
    ProcedureReturn ORM_Entity::#ORM_Success
  EndProcedure

  ; ---------------------------------------------------------------------------
  ; Query: SELECT with optional WHERE clause, returns list of entity pointers
  ; Creates new entities via newEntityProc.
  ; Caller is responsible for freeing the returned entity pointers.
  ; ---------------------------------------------------------------------------
  Procedure.i Query(db.i, entityType.s, whereClause.s,
                    List results.i(),
                    newEntityProc.i, deserializeProc.i)
    Protected *meta.ORM_Schema::ORM_EntityMeta = ORM_Schema::FindEntityMeta(entityType)
    If Not *meta : ProcedureReturn ORM_Entity::#ORM_Error_NotFound : EndIf

    Protected sql.s = "SELECT * FROM " + *meta\tableName
    If Trim(whereClause) <> "" : sql + " " + whereClause : EndIf
    sql + ";"
    Debug "ORM_CRUD::Query -> " + sql

    If Not DatabaseQuery(db, sql)
      Debug "ORM_CRUD::Query ERROR: " + DatabaseError()
      ProcedureReturn ORM_Entity::#ORM_Error_DbConnection
    EndIf

    Protected numCols.i = DatabaseColumns(db)
    Protected count.i   = 0

    Protected newEntity.ORM_Schema::ORM_NewEntityProto  = newEntityProc
    Protected deserialize.ORM_Schema::ORM_DeserializeProto = deserializeProc

    ClearList(results())

    While NextDatabaseRow(db)
      ; Create a fresh entity instance
      Protected *entity = newEntity()
      If Not *entity
        Debug "ORM_CRUD::Query ERROR: newEntityProc returned null"
        Break
      EndIf

      ; Map column name -> value string
      NewMap values.s()
      Protected i.i
      For i = 0 To numCols - 1
        values(DatabaseColumnName(db, i)) = GetDatabaseString(db, i)
      Next

      ; Set id and flags
      SetEntityId(*entity, *meta, Val(values("id")))
      SetEntityStatus(*entity, *meta, #False, #False)

      ; Fill entity fields
      deserialize(*entity, values())

      ; Append to result list
      AddElement(results())
      results() = *entity
      count + 1
    Wend

    FinishDatabaseQuery(db)
    Debug "ORM_CRUD::Query OK - loaded " + Str(count) + " record(s)"
    ProcedureReturn ORM_Entity::#ORM_Success
  EndProcedure

EndModule

; =============================================================================
; EOF ORM_CRUD.pbi
; =============================================================================

