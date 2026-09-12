; =============================================================================
; ORM_Dialect_SQLite.pbi - SQLite-specific SQL generation
; PureBasic OOP Framework - Alpha 1.4
; =============================================================================
; Translates ORM field metadata (type, constraints) into valid SQLite DDL and
; DML SQL strings. Called by ORM_Schema.pbi and ORM_CRUD.pbi.
; =============================================================================

DeclareModule ORM_Dialect_SQLite

  ; --- PureBasic field type codes (used in metadata) ---
  #ORM_Type_Integer = 1   ; .i or .l
  #ORM_Type_String  = 2   ; .s
  #ORM_Type_Double  = 3   ; .d
  #ORM_Type_Float   = 4   ; .f
  #ORM_Type_Bool    = 5   ; .b  (stored as INTEGER 0/1)
  #ORM_Type_FK      = 6   ; foreign key column (auto-generated for child tables)

  ; --- Returns the SQLite column type string for a given ORM type code ---
  ; Example: ORM_Dialect_SQLite::ColumnType(#ORM_Type_String) => "TEXT"
  Declare.s ColumnType(ormTypeCode.i)

  ; --- Build the full CREATE TABLE statement for a given entity metadata ---
  ; tableName.s        : "clients"
  ; fields()           : list of ORM field descriptors
  ; Returns a complete "CREATE TABLE IF NOT EXISTS ..." SQL string.
  Declare.s BuildCreateTable(tableName.s, List fields.ORM_Schema::ORM_FieldDef())

  ; --- Build CREATE TABLE for Many-to-Many junction table ---
  Declare.s BuildCreateJunctionTable(joinTableName.s, parentTable.s, parentFk.s, childTable.s, childFk.s)

  ; --- Build ALTER TABLE ADD COLUMN statement (for schema migration) ---
  Declare.s BuildAddColumn(tableName.s, fieldName.s, ormTypeCode.i)

  ; --- Build INSERT statement with named placeholders ---
  ; Returns: "INSERT INTO clients (companyName, isActive) VALUES (?, ?)"
  Declare.s BuildInsert(tableName.s, List fieldNames.s())

  ; --- Build UPDATE statement ---
  ; Returns: "UPDATE clients SET companyName=?, isActive=? WHERE id=?"
  Declare.s BuildUpdate(tableName.s, List fieldNames.s())

  ; --- Build SELECT by id ---
  ; Returns: "SELECT * FROM clients WHERE id=?"
  Declare.s BuildSelectById(tableName.s)

  ; --- Build SELECT with WHERE clause ---
  ; Returns: "SELECT * FROM clients WHERE isActive=1 ORDER BY companyName"
  Declare.s BuildSelect(tableName.s, whereClause.s)

  ; --- Build DELETE by id ---
  ; Returns: "DELETE FROM clients WHERE id=?"
  Declare.s BuildDeleteById(tableName.s)

  ; --- Build SELECT to check for children (RestrictDelete check) ---
  ; childTableName.s : "contacts", fkColumn.s : "clientId"
  ; Returns: "SELECT COUNT(*) FROM contacts WHERE clientId=?"
  Declare.s BuildCountChildren(childTableName.s, fkColumn.s)

EndDeclareModule

Module ORM_Dialect_SQLite

  ; ---------------------------------------------------------------------------
  ; Map ORM type code to SQLite column type string
  ; ---------------------------------------------------------------------------
  Procedure.s ColumnType(ormTypeCode.i)
    Select ormTypeCode
      Case #ORM_Type_Integer : ProcedureReturn "INTEGER"
      Case #ORM_Type_String  : ProcedureReturn "TEXT"
      Case #ORM_Type_Double  : ProcedureReturn "REAL"
      Case #ORM_Type_Float   : ProcedureReturn "REAL"
      Case #ORM_Type_Bool    : ProcedureReturn "INTEGER"   ; 0 or 1
      Case #ORM_Type_FK      : ProcedureReturn "INTEGER"   ; FK column
      Default                : ProcedureReturn "TEXT"
    EndSelect
  EndProcedure

  ; ---------------------------------------------------------------------------
  ; Build full CREATE TABLE IF NOT EXISTS statement
  ; ---------------------------------------------------------------------------
  Procedure.s BuildCreateTable(tableName.s, List fields.ORM_Schema::ORM_FieldDef())
    Protected sql.s = "CREATE TABLE IF NOT EXISTS " + tableName + " (" + #CRLF$
    sql + "  id INTEGER PRIMARY KEY AUTOINCREMENT"

    ForEach fields()
      ; Skip the id field (already handled as PK above)
      If fields()\name <> "id"
        sql + "," + #CRLF$
        sql + "  " + fields()\name + " " + ColumnType(fields()\typeCode)
        ; Add NOT NULL for FK columns
        If fields()\typeCode = #ORM_Type_FK
          sql + " NOT NULL"
        EndIf
      EndIf
    Next

    sql + #CRLF$ + ");"
    ProcedureReturn sql
  EndProcedure

  ; ---------------------------------------------------------------------------
  ; Build ALTER TABLE ADD COLUMN (schema migration: new field in existing table)
  ; ---------------------------------------------------------------------------
  Procedure.s BuildAddColumn(tableName.s, fieldName.s, ormTypeCode.i)
    ProcedureReturn "ALTER TABLE " + tableName + " ADD COLUMN " + fieldName + " " + ColumnType(ormTypeCode) + ";"
  EndProcedure

  ; ---------------------------------------------------------------------------
  ; Build INSERT statement
  ; ---------------------------------------------------------------------------
  Procedure.s BuildInsert(tableName.s, List fieldNames.s())
    Protected cols.s = ""
    Protected vals.s = ""
    Protected first.b = #True

    ForEach fieldNames()
      If Not first : cols + ", " : vals + ", " : EndIf
      cols + fieldNames()
      vals + "?"
      first = #False
    Next

    ProcedureReturn "INSERT INTO " + tableName + " (" + cols + ") VALUES (" + vals + ");"
  EndProcedure

  ; ---------------------------------------------------------------------------
  ; Build UPDATE statement (all fields except id, WHERE id=?)
  ; ---------------------------------------------------------------------------
  Procedure.s BuildUpdate(tableName.s, List fieldNames.s())
    Protected sets.s = ""
    Protected first.b = #True

    ForEach fieldNames()
      If fieldNames() <> "id"
        If Not first : sets + ", " : EndIf
        sets + fieldNames() + "=?"
        first = #False
      EndIf
    Next

    ProcedureReturn "UPDATE " + tableName + " SET " + sets + " WHERE id=?;"
  EndProcedure

  ; ---------------------------------------------------------------------------
  ; Build SELECT by primary key
  ; ---------------------------------------------------------------------------
  Procedure.s BuildSelectById(tableName.s)
    ProcedureReturn "SELECT * FROM " + tableName + " WHERE id=?;"
  EndProcedure

  ; ---------------------------------------------------------------------------
  ; Build SELECT with optional WHERE clause
  ; ---------------------------------------------------------------------------
  Procedure.s BuildSelect(tableName.s, whereClause.s)
    Protected sql.s = "SELECT * FROM " + tableName
    If whereClause <> ""
      sql + " " + whereClause
    EndIf
    sql + ";"
    ProcedureReturn sql
  EndProcedure

  ; ---------------------------------------------------------------------------
  ; Build DELETE by primary key
  ; ---------------------------------------------------------------------------
  Procedure.s BuildDeleteById(tableName.s)
    ProcedureReturn "DELETE FROM " + tableName + " WHERE id=?;"
  EndProcedure

  ; ---------------------------------------------------------------------------
  ; Build COUNT children query (for RestrictDelete check)
  ; ---------------------------------------------------------------------------
  Procedure.s BuildCountChildren(childTableName.s, fkColumn.s)
    ProcedureReturn "SELECT COUNT(*) FROM " + childTableName + " WHERE " + fkColumn + "=?;"
  EndProcedure

  ; ---------------------------------------------------------------------------
  ; Build CREATE TABLE for Many-to-Many junction table
  ; ---------------------------------------------------------------------------
  Procedure.s BuildCreateJunctionTable(joinTableName.s, parentTable.s, parentFk.s, childTable.s, childFk.s)
    Protected sql.s = "CREATE TABLE IF NOT EXISTS " + joinTableName + " (" +
                      parentFk + " INTEGER NOT NULL, " +
                      childFk + " INTEGER NOT NULL, " +
                      "PRIMARY KEY (" + parentFk + ", " + childFk + "), " +
                      "FOREIGN KEY (" + parentFk + ") REFERENCES " + parentTable + "(id) ON DELETE CASCADE, " +
                      "FOREIGN KEY (" + childFk + ") REFERENCES " + childTable + "(id) ON DELETE CASCADE);"
    ProcedureReturn sql
  EndProcedure

EndModule

; =============================================================================
; EOF ORM_Dialect_SQLite.pbi
; =============================================================================
