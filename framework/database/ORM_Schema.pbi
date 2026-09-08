; =============================================================================
; ORM_Schema.pbi - Schema Engine: class metadata -> SQL DDL
; PureBasic OOP Framework - Alpha 1.4 (Phase 2 update)
; =============================================================================
; Phase 2 adds:
;   - serializeProc / deserializeProc / newEntityProc in ORM_EntityMeta
;   - saveChildrenProc in ORM_RelationDef (for cascade save)
;   - Public FindEntityMeta() for use by ORM_CRUD and ORM_Relations
; =============================================================================

XIncludeFile "ORM_Dialect_SQLite.pbi"
XIncludeFile "ORM_Transaction.pbi"

DeclareModule ORM_Schema

  ; --- Serialize / Deserialize procedure prototypes ---
  ; SerializeProc   : fills a Map with field values (strings) from an entity pointer
  ; DeserializeProc : reads from a Map and writes values back into entity fields
  ; NewEntityProc   : creates and returns a new empty entity (used by Query)
  Prototype ORM_SerializeProto  (*entity, Map values.s())
  Prototype ORM_DeserializeProto(*entity, Map values.s())
  Prototype.i ORM_NewEntityProto()

  ; SaveChildrenProto: iterates over all children of *parent and saves each one
  ; Called by ORM_Relations::SaveWithChildren during cascade save.
  ; The developer implements this once per relation.
  Prototype ORM_SaveChildrenProto(*parent, db.i)

  ; --- Relation descriptor (1-N link between parent and child table) ---
  Structure ORM_RelationDef
    childTable.s          ; e.g. "contacts"
    fkColumn.s            ; e.g. "clientId" (FK column in child table)
    cascadeSave.b         ; #True  = save parent -> also save all children
    deletePolicy.i        ; #ORM_Restrict_Delete / #ORM_Cascade_Delete / etc.
    saveChildrenProc.i    ; @MyProc(*parent, db.i) - saves all children of parent
  EndStructure

  ; --- Full entity descriptor stored in the internal registry ---
  Structure ORM_EntityMeta
    entityName.s          ; Class name as registered (e.g. "Client")
    tableName.s           ; DB table name (e.g. "clients")
    serializeProc.i       ; @MySerialize(*entity, Map values.s())
    deserializeProc.i     ; @MyDeserialize(*entity, Map values.s())
    newEntityProc.i       ; @MyNewEntity() -> *entity
    List fields.ORM_FieldDef()
    List relations.ORM_RelationDef()
  EndStructure

  ; --- Internal registry ---
  Global NewList orm_registry.ORM_EntityMeta()

  ; --- Register an entity with its field list, relation list, and I/O procs ---
  ; serializeProc   : Procedure(*entity, Map values.s()) -- converts entity to map
  ; deserializeProc : Procedure(*entity, Map values.s()) -- fills entity from map
  ; newEntityProc   : Procedure() returns *entity         -- creates empty entity
  Declare RegisterEntity(entityName.s, tableName.s,
                         List fields.ORM_FieldDef(),
                         List relations.ORM_RelationDef(),
                         serializeProc.i   = 0,
                         deserializeProc.i = 0,
                         newEntityProc.i   = 0)

  ; --- Find entity metadata by name (public, used by CRUD and Relations) ---
  ; Returns pointer to ORM_EntityMeta or 0 if not found.
  Declare.i FindEntityMeta(entityName.s)

  ; --- Run AutoMigrate: create or update tables ---
  ; db.i : open database handle
  ; Returns #True if all migrations succeed, #False otherwise.
  Declare.b Migrate(db.i)

  ; --- Helper: derive table name from entity name (lowercase + "s") ---
  ; "Client" -> "clients", "Contact" -> "contacts"
  Declare.s TableNameFromEntity(entityName.s)

EndDeclareModule

Module ORM_Schema

  ; ---------------------------------------------------------------------------
  ; Derive table name from entity class name
  ; ---------------------------------------------------------------------------
  Procedure.s TableNameFromEntity(entityName.s)
    ProcedureReturn LCase(entityName) + "s"
  EndProcedure

  ; ---------------------------------------------------------------------------
  ; Register entity in the internal registry
  ; ---------------------------------------------------------------------------
  Procedure RegisterEntity(entityName.s, tableName.s,
                           List fields.ORM_FieldDef(),
                           List relations.ORM_RelationDef(),
                           serializeProc.i   = 0,
                           deserializeProc.i = 0,
                           newEntityProc.i   = 0)
    ; Check for duplicate
    ForEach orm_registry()
      If orm_registry()\entityName = entityName
        Debug "ORM_Schema::RegisterEntity() WARNING: '" + entityName + "' already registered, skipping."
        ProcedureReturn
      EndIf
    Next

    AddElement(orm_registry())
    orm_registry()\entityName      = entityName
    orm_registry()\tableName       = tableName
    orm_registry()\serializeProc   = serializeProc
    orm_registry()\deserializeProc = deserializeProc
    orm_registry()\newEntityProc   = newEntityProc

    ForEach fields()
      AddElement(orm_registry()\fields())
      orm_registry()\fields()\name     = fields()\name
      orm_registry()\fields()\typeCode = fields()\typeCode
      orm_registry()\fields()\isFK     = fields()\isFK
      orm_registry()\fields()\fkTable  = fields()\fkTable
      orm_registry()\fields()\nullable = fields()\nullable
    Next

    ForEach relations()
      AddElement(orm_registry()\relations())
      orm_registry()\relations()\childTable        = relations()\childTable
      orm_registry()\relations()\fkColumn          = relations()\fkColumn
      orm_registry()\relations()\cascadeSave       = relations()\cascadeSave
      orm_registry()\relations()\deletePolicy      = relations()\deletePolicy
      orm_registry()\relations()\saveChildrenProc  = relations()\saveChildrenProc
    Next

    Debug "ORM_Schema: Registered entity '" + entityName + "' -> table '" + tableName + "'"
  EndProcedure

  ; ---------------------------------------------------------------------------
  ; Public entity lookup
  ; ---------------------------------------------------------------------------
  Procedure.i FindEntityMeta(entityName.s)
    ForEach orm_registry()
      If orm_registry()\entityName = entityName
        ProcedureReturn @orm_registry()
      EndIf
    Next
    Debug "ORM_Schema: ERROR - entity '" + entityName + "' not registered!"
    ProcedureReturn 0
  EndProcedure

  ; ---------------------------------------------------------------------------
  ; Internal helpers for AutoMigrate
  ; ---------------------------------------------------------------------------
  Procedure.b TableExists(db.i, tableName.s)
    If DatabaseQuery(db, "SELECT name FROM sqlite_master WHERE type='table' AND name='" + tableName + "';")
      Protected exists.b = NextDatabaseRow(db)
      FinishDatabaseQuery(db)
      ProcedureReturn exists
    EndIf
    ProcedureReturn #False
  EndProcedure

  Procedure.b ColumnExists(db.i, tableName.s, columnName.s)
    Protected found.b = #False
    If DatabaseQuery(db, "PRAGMA table_info(" + tableName + ");")
      While NextDatabaseRow(db)
        ; PRAGMA table_info: cid=0, name=1, type=2, notnull=3, dflt=4, pk=5
        If GetDatabaseString(db, 1) = columnName
          found = #True
        EndIf
      Wend
      FinishDatabaseQuery(db)
    EndIf
    ProcedureReturn found
  EndProcedure

  ; ---------------------------------------------------------------------------
  ; AutoMigrate: create _orm_locks + all registered entity tables
  ; ---------------------------------------------------------------------------
  Procedure.b Migrate(db.i)
    Protected ok.b = #True

    ; Always ensure the lock manager table exists
    Protected lockSQL.s = "CREATE TABLE IF NOT EXISTS _orm_locks (" + #CRLF$
    lockSQL + "  entity_type TEXT    NOT NULL," + #CRLF$
    lockSQL + "  record_id   INTEGER NOT NULL," + #CRLF$
    lockSQL + "  station_id  TEXT    NOT NULL," + #CRLF$
    lockSQL + "  user_name   TEXT    NOT NULL," + #CRLF$
    lockSQL + "  locked_at   INTEGER NOT NULL," + #CRLF$
    lockSQL + "  expires_at  INTEGER NOT NULL," + #CRLF$
    lockSQL + "  PRIMARY KEY (entity_type, record_id)" + #CRLF$
    lockSQL + ");"
    If Not ORM_Transaction::Execute(db, lockSQL)
      Debug "ORM_Schema::Migrate() ERROR: Cannot create _orm_locks table"
      ProcedureReturn #False
    EndIf
    Debug "ORM_Schema: _orm_locks table ready."

    ; Enable WAL journal mode for concurrent reader/writer access
    ORM_Transaction::Execute(db, "PRAGMA journal_mode=WAL;")
    ORM_Transaction::Execute(db, "PRAGMA foreign_keys=ON;")

    ; Process each registered entity
    ForEach orm_registry()
      Protected tbl.s = orm_registry()\tableName

      If TableExists(db, tbl)
        ; Table exists: non-destructive column check (ALTER TABLE ADD COLUMN)
        Debug "ORM_Schema: Table '" + tbl + "' exists - checking for new columns..."
        ForEach orm_registry()\fields()
          If orm_registry()\fields()\name <> "id"
            If Not ColumnExists(db, tbl, orm_registry()\fields()\name)
              Protected alterSQL.s = ORM_Dialect_SQLite::BuildAddColumn(
                tbl,
                orm_registry()\fields()\name,
                orm_registry()\fields()\typeCode)
              If ORM_Transaction::Execute(db, alterSQL)
                Debug "ORM_Schema:   Added column '" + orm_registry()\fields()\name + "' to '" + tbl + "'"
              Else
                Debug "ORM_Schema:   ERROR adding column '" + orm_registry()\fields()\name + "'"
                ok = #False
              EndIf
            EndIf
          EndIf
        Next
      Else
        ; Table does not exist: create it
        Protected createSQL.s = ORM_Dialect_SQLite::BuildCreateTable(tbl, orm_registry()\fields())
        If ORM_Transaction::Execute(db, createSQL)
          Debug "ORM_Schema: Created table '" + tbl + "'"
        Else
          Debug "ORM_Schema: ERROR creating table '" + tbl + "'"
          ok = #False
        EndIf
      EndIf
    Next

    ProcedureReturn ok
  EndProcedure

EndModule

; =============================================================================
; EOF ORM_Schema.pbi
; =============================================================================
