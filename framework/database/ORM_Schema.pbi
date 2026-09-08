; =============================================================================
; ORM_Schema.pbi - Schema Engine: class metadata -> SQL DDL
; PureBasic OOP Framework - Alpha 1.4
; =============================================================================
; Stores ORM registration metadata (entity name, table name, field list,
; child relations) and generates CREATE TABLE / ALTER TABLE SQL on demand.
;
; Usage:
;   ORM_Schema::RegisterEntity("Client", "clients", fields(), relations())
;   ORM_Schema::Migrate(dbHandle)   ; Runs CREATE TABLE or ALTER TABLE
; =============================================================================

XIncludeFile "ORM_Dialect_SQLite.pbi"
XIncludeFile "ORM_Transaction.pbi"

DeclareModule ORM_Schema

  ; --- Relation descriptor (1-N link between parent and child table) ---
  Structure ORM_RelationDef
    childTable.s      ; e.g. "contacts"
    fkColumn.s        ; e.g. "clientId"
    cascadeSave.b     ; #True = save parent saves children
    deletePolicy.i    ; #ORM_Cascade_Delete / #ORM_Restrict_Delete / etc.
  EndStructure

  ; --- Full entity descriptor stored in the internal registry ---
  Structure ORM_EntityMeta
    entityName.s      ; Class name as registered (e.g. "Client")
    tableName.s       ; DB table name (e.g. "clients")
    List fields.ORM_FieldDef()     ; Field descriptors (name, typeCode, ...)
    List relations.ORM_RelationDef()  ; 1-N child relations
  EndStructure

  ; --- Internal registry (list of all registered entities) ---
  Global NewList orm_registry.ORM_EntityMeta()

  ; --- Register an entity so AutoMigrate knows its structure ---
  ; entityName.s  : "Client"
  ; tableName.s   : "clients"
  ; fields()      : list of ORM_FieldDef (filled by generated code or manually)
  ; relations()   : list of ORM_RelationDef (optional, for 1-N links)
  Declare RegisterEntity(entityName.s, tableName.s,
                         List fields.ORM_FieldDef(),
                         List relations.ORM_RelationDef())

  ; --- Run AutoMigrate: create or update tables in the given database ---
  ; db.i : open database handle
  ; Returns #True if all migrations succeed, #False otherwise.
  Declare.b Migrate(db.i)

  ; --- Helper: derive table name from entity name (lowercase + "s") ---
  ; "Client" -> "clients", "Contact" -> "contacts"
  Declare.s TableNameFromEntity(entityName.s)

  ; --- Find an entity meta record by name (returns pointer or 0) ---
  Declare.i FindEntity(entityName.s)

EndDeclareModule

Module ORM_Schema

  ; ---------------------------------------------------------------------------
  ; Derive table name from entity class name: "Client" -> "clients"
  ; ---------------------------------------------------------------------------
  Procedure.s TableNameFromEntity(entityName.s)
    ProcedureReturn LCase(entityName) + "s"
  EndProcedure

  ; ---------------------------------------------------------------------------
  ; Register an entity in the internal registry
  ; ---------------------------------------------------------------------------
  Procedure RegisterEntity(entityName.s, tableName.s,
                           List fields.ORM_FieldDef(),
                           List relations.ORM_RelationDef())
    ; Check for duplicate registration
    ForEach orm_registry()
      If orm_registry()\entityName = entityName
        Debug "ORM_Schema::RegisterEntity() WARNING: '" + entityName + "' already registered, skipping."
        ProcedureReturn
      EndIf
    Next

    ; Add to registry
    AddElement(orm_registry())
    orm_registry()\entityName = entityName
    orm_registry()\tableName  = tableName

    ; Copy field list
    ForEach fields()
      AddElement(orm_registry()\fields())
      orm_registry()\fields()\name     = fields()\name
      orm_registry()\fields()\typeCode = fields()\typeCode
      orm_registry()\fields()\isFK     = fields()\isFK
      orm_registry()\fields()\fkTable  = fields()\fkTable
      orm_registry()\fields()\nullable = fields()\nullable
    Next

    ; Copy relation list
    ForEach relations()
      AddElement(orm_registry()\relations())
      orm_registry()\relations()\childTable    = relations()\childTable
      orm_registry()\relations()\fkColumn      = relations()\fkColumn
      orm_registry()\relations()\cascadeSave   = relations()\cascadeSave
      orm_registry()\relations()\deletePolicy  = relations()\deletePolicy
    Next

    Debug "ORM_Schema: Registered entity '" + entityName + "' -> table '" + tableName + "'"
  EndProcedure

  ; ---------------------------------------------------------------------------
  ; Find entity metadata by name
  ; ---------------------------------------------------------------------------
  Procedure.i FindEntity(entityName.s)
    ForEach orm_registry()
      If orm_registry()\entityName = entityName
        ProcedureReturn @orm_registry()
      EndIf
    Next
    ProcedureReturn 0
  EndProcedure

  ; ---------------------------------------------------------------------------
  ; Check if a table already exists in the SQLite database
  ; ---------------------------------------------------------------------------
  Procedure.b TableExists(db.i, tableName.s)
    Protected sql.s = "SELECT name FROM sqlite_master WHERE type='table' AND name=?;"
    If DatabaseQuery(db, "SELECT name FROM sqlite_master WHERE type='table' AND name='" + tableName + "';")
      Protected exists.b = NextDatabaseRow(db)
      FinishDatabaseQuery(db)
      ProcedureReturn exists
    EndIf
    ProcedureReturn #False
  EndProcedure

  ; ---------------------------------------------------------------------------
  ; Check if a column exists in a given table
  ; ---------------------------------------------------------------------------
  Procedure.b ColumnExists(db.i, tableName.s, columnName.s)
    Protected found.b = #False
    If DatabaseQuery(db, "PRAGMA table_info(" + tableName + ");")
      While NextDatabaseRow(db)
        ; PRAGMA table_info columns: cid, name, type, notnull, dflt_value, pk
        If GetDatabaseString(db, 1) = columnName  ; column index 1 = name
          found = #True
        EndIf
      Wend
      FinishDatabaseQuery(db)
    EndIf
    ProcedureReturn found
  EndProcedure

  ; ---------------------------------------------------------------------------
  ; Run AutoMigrate: iterate all registered entities, create or update tables
  ; ---------------------------------------------------------------------------
  Procedure.b Migrate(db.i)
    Protected ok.b = #True

    ; Ensure the lock manager table exists first
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
      Debug "ORM_Schema::Migrate() ERROR: Could not create _orm_locks table"
      ProcedureReturn #False
    EndIf
    Debug "ORM_Schema: _orm_locks table ready."

    ; Enable WAL mode for better concurrent read/write performance
    ORM_Transaction::Execute(db, "PRAGMA journal_mode=WAL;")

    ; Process each registered entity
    ForEach orm_registry()
      Protected tbl.s = orm_registry()\tableName

      If TableExists(db, tbl)
        ; Table exists: check for new columns (schema migration)
        Debug "ORM_Schema: Table '" + tbl + "' exists, checking for new columns..."
        ForEach orm_registry()\fields()
          If orm_registry()\fields()\name <> "id"
            If Not ColumnExists(db, tbl, orm_registry()\fields()\name)
              ; Column does not exist yet: add it non-destructively
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
