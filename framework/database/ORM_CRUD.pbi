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

DeclareModule ORM_CRUD

  ; Base accessor: id is always the first integer field in every entity.
  ; Cast any *entity pointer to *ORM_EntityBase to read or write id/flags.
  Structure ORM_EntityBase
    id.i          ; offset 0 - primary key
    orm_isNew.b   ; offset 4 (or 8 on 64-bit) - True before first save
    orm_isDirty.b ; True if any field changed since last save/load
  EndStructure

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

  ; --- Load one entity from DB by id, fills *entity via deserializeProc ---
  ; Returns #ORM_Success or #ORM_Error_NotFound / #ORM_Error_DbConnection.
  Declare.i FindById(db.i, entityType.s, recordId.i, *entity, deserializeProc.i)

  ; --- Query: load a list of entity pointers matching a WHERE clause ---
  ; Worker creates new entities via newEntityProc and fills via deserializeProc.
  ; The caller owns the returned entity pointers and must free them.
  ; Returns #ORM_Success or error code.
  Declare.i Query(db.i, entityType.s, whereClause.s,
                  List *results.i(),
                  newEntityProc.i, deserializeProc.i)

EndDeclareModule

Module ORM_CRUD

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
      Protected *base.ORM_CRUD::ORM_EntityBase = *entity
      *base\id          = LastInsertedID(db)
      *base\orm_isNew   = #False
      *base\orm_isDirty = #False
      Debug "ORM_CRUD::Insert OK - new id=" + Str(*base\id)
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

    Protected *base.ORM_CRUD::ORM_EntityBase = *entity
    If *base\id = 0
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
                      " WHERE id=" + Str(*base\id) + ";"
    Debug "ORM_CRUD::Update -> " + sql

    If ORM_Transaction::Execute(db, sql)
      *base\orm_isDirty = #False
      Debug "ORM_CRUD::Update OK id=" + Str(*base\id)
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
    Protected *base.ORM_CRUD::ORM_EntityBase = *entity
    If *base\id = 0 Or *base\orm_isNew
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

    Protected *base.ORM_CRUD::ORM_EntityBase = *child
    Protected sql.s
    Protected ok.b

    If *base\id = 0 Or *base\orm_isNew
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
        *base\id          = LastInsertedID(db)
        *base\orm_isNew   = #False
        *base\orm_isDirty = #False
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
            " WHERE id=" + Str(*base\id) + ";"
      Debug "ORM_CRUD::SaveOne UPDATE -> " + sql
      ok = ORM_Transaction::Execute(db, sql)
      If ok
        *base\orm_isDirty = #False
      EndIf
    EndIf

    If Not ok
      Debug "ORM_CRUD::SaveOne FAILED: " + DatabaseError()
    EndIf
    ProcedureReturn ok
  EndProcedure

  ; ---------------------------------------------------------------------------
  ; DeleteById: remove record (FK rules checked by ORM_Relations before this)
  ; ---------------------------------------------------------------------------
  Procedure.b DeleteById(db.i, entityType.s, recordId.i)
    Protected *meta.ORM_Schema::ORM_EntityMeta = ORM_Schema::FindEntityMeta(entityType)
    If Not *meta : ProcedureReturn #False : EndIf

    Protected sql.s = "DELETE FROM " + *meta\tableName + " WHERE id=" + Str(recordId) + ";"
    Debug "ORM_CRUD::DeleteById -> " + sql
    If ORM_Transaction::Execute(db, sql)
      Debug "ORM_CRUD::DeleteById OK id=" + Str(recordId)
      ProcedureReturn #True
    Else
      Debug "ORM_CRUD::DeleteById FAILED: " + DatabaseError()
      ProcedureReturn #False
    EndIf
  EndProcedure

  ; ---------------------------------------------------------------------------
  ; FindById: SELECT * WHERE id=N, fill entity via deserializeProc
  ; Uses DatabaseColumnName() to safely map column positions to field names.
  ; ---------------------------------------------------------------------------
  Procedure.i FindById(db.i, entityType.s, recordId.i, *entity, deserializeProc.i)
    Protected *meta.ORM_Schema::ORM_EntityMeta = ORM_Schema::FindEntityMeta(entityType)
    If Not *meta : ProcedureReturn #ORM_Entity::#ORM_Error_NotFound : EndIf

    Protected sql.s = "SELECT * FROM " + *meta\tableName +
                      " WHERE id=" + Str(recordId) + " LIMIT 1;"
    Debug "ORM_CRUD::FindById -> " + sql

    If Not DatabaseQuery(db, sql)
      Debug "ORM_CRUD::FindById QUERY ERROR: " + DatabaseError()
      ProcedureReturn #ORM_Entity::#ORM_Error_DbConnection
    EndIf

    If Not NextDatabaseRow(db)
      FinishDatabaseQuery(db)
      Debug "ORM_CRUD::FindById: id=" + Str(recordId) + " NOT FOUND in " + *meta\tableName
      ProcedureReturn #ORM_Entity::#ORM_Error_NotFound
    EndIf

    ; Build value map using actual column names from result set (safe against schema drift)
    NewMap values.s()
    Protected numCols.i = DatabaseColumns(db)
    Protected i.i
    For i = 0 To numCols - 1
      values(DatabaseColumnName(db, i)) = GetDatabaseString(db, i)
    Next
    FinishDatabaseQuery(db)

    ; Write id and state flags back
    Protected *base.ORM_CRUD::ORM_EntityBase = *entity
    *base\id          = Val(values("id"))
    *base\orm_isNew   = #False
    *base\orm_isDirty = #False

    ; Call developer-supplied deserialize proc to fill the remaining fields
    Protected deserialize.ORM_Schema::ORM_DeserializeProto = deserializeProc
    deserialize(*entity, values())

    Debug "ORM_CRUD::FindById OK - id=" + Str(*base\id)
    ProcedureReturn #ORM_Entity::#ORM_Success
  EndProcedure

  ; ---------------------------------------------------------------------------
  ; Query: SELECT with optional WHERE clause, returns list of entity pointers
  ; Creates new entities via newEntityProc.
  ; Caller is responsible for freeing the returned entity pointers.
  ; ---------------------------------------------------------------------------
  Procedure.i Query(db.i, entityType.s, whereClause.s,
                    List *results.i(),
                    newEntityProc.i, deserializeProc.i)
    Protected *meta.ORM_Schema::ORM_EntityMeta = ORM_Schema::FindEntityMeta(entityType)
    If Not *meta : ProcedureReturn #ORM_Entity::#ORM_Error_NotFound : EndIf

    Protected sql.s = "SELECT * FROM " + *meta\tableName
    If Trim(whereClause) <> "" : sql + " " + whereClause : EndIf
    sql + ";"
    Debug "ORM_CRUD::Query -> " + sql

    If Not DatabaseQuery(db, sql)
      Debug "ORM_CRUD::Query ERROR: " + DatabaseError()
      ProcedureReturn #ORM_Entity::#ORM_Error_DbConnection
    EndIf

    Protected numCols.i = DatabaseColumns(db)
    Protected count.i   = 0

    Protected newEntity.ORM_Schema::ORM_NewEntityProto  = newEntityProc
    Protected deserialize.ORM_Schema::ORM_DeserializeProto = deserializeProc

    ClearList(*results())

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
      Protected *base.ORM_CRUD::ORM_EntityBase = *entity
      *base\id          = Val(values("id"))
      *base\orm_isNew   = #False
      *base\orm_isDirty = #False

      ; Fill entity fields
      deserialize(*entity, values())

      ; Append to result list
      AddElement(*results())
      *results() = *entity
      count + 1
    Wend

    FinishDatabaseQuery(db)
    Debug "ORM_CRUD::Query: returned " + Str(count) + " row(s)"
    ProcedureReturn #ORM_Entity::#ORM_Success
  EndProcedure

EndModule

; =============================================================================
; EOF ORM_CRUD.pbi
; =============================================================================
