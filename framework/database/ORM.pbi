; =============================================================================
; ORM.pbi - Public API entry point for the PureBasic OOP Data Engine
; PureBasic OOP Framework - Alpha 1.4 (Phase 2)
; =============================================================================
; This is the ONLY file you need to include in your project:
;
;   XIncludeFile "framework/database/ORM.pbi"
;
; Workflow:
;   1. ORM::ConfigureSQLite("my.db")            -> open DB
;   2. ORM_Schema::RegisterEntity(...)          -> declare entities + relations
;   3. ORM::AutoMigrate()                       -> create / update tables + start workers
;   4. ORM::SetMainWindow(wnd)                  -> link async events to your window
;   5. ORM_AsyncWorker::SaveAsync(...)          -> save in background
;   6. ORM_AsyncWorker::QueryAsync(...)         -> query in background
;   7. Handle #PB_Event_Custom in your loop     -> dispatch callbacks
;   8. ORM::Shutdown()                          -> clean exit
;
; See examples/06_database_crm/main.pb for a complete working demo.
; =============================================================================

XIncludeFile "ORM_Entity.pbi"
XIncludeFile "ORM_Dialect_SQLite.pbi"
XIncludeFile "ORM_Transaction.pbi"
XIncludeFile "ORM_Schema.pbi"
XIncludeFile "ORM_LockManager.pbi"
XIncludeFile "ORM_CRUD.pbi"
XIncludeFile "ORM_Relations.pbi"
XIncludeFile "ORM_AsyncWorker.pbi"

DeclareModule ORM

  ; ---------------------------------------------------------------------------
  ; Global state (one database connection per application for the UI thread)
  ; Workers get their own connections in ORM_AsyncWorker.
  ; ---------------------------------------------------------------------------
  Global orm_mainDb.i   = 0       ; Main DB handle (sync ops & schema)
  Global orm_dbPath.s   = ""      ; Path to SQLite file
  Global orm_mainWindow.i = 0     ; Main window handle for async PostEvent

  ; ---------------------------------------------------------------------------
  ; DATABASE CONFIGURATION
  ; ---------------------------------------------------------------------------

  ; Configure the engine for an SQLite database file.
  ; Call ONCE before RegisterEntity() or AutoMigrate().
  ;   filePath.s : relative or absolute path to the .db file
  ;                e.g. "app.db" or GetPathPart(ProgramFilename()) + "data\crm.db"
  Declare ConfigureSQLite(filePath.s)

  ; Configure for MySQL / MariaDB (planned - not implemented in Alpha 1.4)
  ;   host.s     : server IP or hostname
  ;   port.i     : TCP port (usually 3306)
  ;   dbName.s   : database / schema name
  ;   user.s     : login username
  ;   password.s : login password
  Declare ConfigureMySQL(host.s, port.i, dbName.s, user.s, password.s)

  ; Set the main window so async worker results are dispatched to it.
  ; Call after OpenWindow().
  Declare SetMainWindow(windowId.i)

  ; ---------------------------------------------------------------------------
  ; SCHEMA AUTO-MIGRATION
  ; ---------------------------------------------------------------------------

  ; Create or update all registered entity tables in the database.
  ; Safe to call on every startup: existing tables are NEVER dropped.
  ; New fields discovered are added with non-destructive ALTER TABLE ADD COLUMN.
  ; Also starts the async worker pool.
  Declare.b AutoMigrate()

  ; ---------------------------------------------------------------------------
  ; ASYNCHRONOUS HELPERS (convenience wrappers around ORM_AsyncWorker)
  ; ---------------------------------------------------------------------------

  ; Save entity (+ cascade children) asynchronously.
  ; callbackPtr : Procedure OnSaved(*entity, result.i)
  Declare SaveAsync(*entity, entityType.s, serializeProc.i, callbackPtr.i)

  ; Load entity by id asynchronously.
  ; callbackPtr : Procedure OnLoaded(*entity, result.i)
  Declare FindByIdAsync(*entity, entityType.s, recordId.i, deserializeProc.i, callbackPtr.i)

  ; Query entity list asynchronously (results in orm_queryResultList).
  ; callbackPtr : Procedure OnQueryDone(result.i)
  Declare QueryAsync(entityType.s, whereClause.s, newEntityProc.i, deserializeProc.i, callbackPtr.i)

  ; Delete entity with FK enforcement asynchronously.
  ; callbackPtr : Procedure OnDeleted(*entity, result.i)
  Declare DeleteAsync(*entity, entityType.s, callbackPtr.i)

  ; ---------------------------------------------------------------------------
  ; SHUTDOWN
  ; ---------------------------------------------------------------------------

  ; Stop all worker threads and close the database.
  ; Call at application exit.
  Declare Shutdown()

EndDeclareModule

Module ORM

  ; ---------------------------------------------------------------------------
  ; Configure SQLite
  ; ---------------------------------------------------------------------------
  Procedure ConfigureSQLite(filePath.s)
    orm_dbPath = filePath
    UseSQLiteDatabase()

    orm_mainDb = OpenDatabase(#PB_Any, filePath, "", "", #PB_Database_SQLite)
    If Not IsDatabase(orm_mainDb)
      MessageRequester("ORM Error",
                       "Cannot open SQLite database:" + #CRLF$ + filePath + #CRLF$ + #CRLF$ +
                       "Check that the path exists and you have write permission.",
                       #PB_MessageRequester_Error)
      End
    EndIf

    ORM_Transaction::Execute(orm_mainDb, "PRAGMA journal_mode=WAL;")
    ORM_Transaction::Execute(orm_mainDb, "PRAGMA foreign_keys=ON;")
    Debug "ORM: SQLite opened: " + filePath
  EndProcedure

  ; ---------------------------------------------------------------------------
  ; Configure MySQL (stub)
  ; ---------------------------------------------------------------------------
  Procedure ConfigureMySQL(host.s, port.i, dbName.s, user.s, password.s)
    Debug "ORM: ConfigureMySQL() - NOT YET IMPLEMENTED in Alpha 1.4"
    MessageRequester("ORM Info",
                     "MySQL/MariaDB support is planned for the next release." + #CRLF$ +
                     "Please use ConfigureSQLite() for Alpha 1.4.",
                     #PB_MessageRequester_Info)
  EndProcedure

  ; ---------------------------------------------------------------------------
  ; Set main window
  ; ---------------------------------------------------------------------------
  Procedure SetMainWindow(windowId.i)
    orm_mainWindow = windowId
    Debug "ORM: Main window -> " + Str(windowId)
  EndProcedure

  ; ---------------------------------------------------------------------------
  ; AutoMigrate: create/update tables, start worker pool
  ; ---------------------------------------------------------------------------
  Procedure.b AutoMigrate()
    If Not IsDatabase(orm_mainDb)
      Debug "ORM::AutoMigrate() ERROR: No DB configured. Call ConfigureSQLite() first."
      ProcedureReturn #False
    EndIf
    Protected ok.b = ORM_Schema::Migrate(orm_mainDb)
    If ok
      Debug "ORM: AutoMigrate OK - starting async worker pool"
      ORM_AsyncWorker::Init(orm_dbPath, 2, orm_mainWindow)
    Else
      Debug "ORM: AutoMigrate completed WITH ERRORS"
    EndIf
    ProcedureReturn ok
  EndProcedure

  ; ---------------------------------------------------------------------------
  ; Async wrappers (delegate to ORM_AsyncWorker with main window)
  ; ---------------------------------------------------------------------------
  Procedure SaveAsync(*entity, entityType.s, serializeProc.i, callbackPtr.i)
    ORM_AsyncWorker::SaveAsync(*entity, entityType, serializeProc, callbackPtr, orm_mainWindow)
  EndProcedure

  Procedure FindByIdAsync(*entity, entityType.s, recordId.i, deserializeProc.i, callbackPtr.i)
    ORM_AsyncWorker::FindByIdAsync(*entity, entityType, recordId, deserializeProc, callbackPtr, orm_mainWindow)
  EndProcedure

  Procedure QueryAsync(entityType.s, whereClause.s, newEntityProc.i, deserializeProc.i, callbackPtr.i)
    ORM_AsyncWorker::QueryAsync(entityType, whereClause, newEntityProc, deserializeProc, callbackPtr, orm_mainWindow)
  EndProcedure

  Procedure DeleteAsync(*entity, entityType.s, callbackPtr.i)
    ORM_AsyncWorker::DeleteAsync(*entity, entityType, callbackPtr, orm_mainWindow)
  EndProcedure

  ; ---------------------------------------------------------------------------
  ; Shutdown
  ; ---------------------------------------------------------------------------
  Procedure Shutdown()
    ORM_AsyncWorker::Shutdown()
    If IsDatabase(orm_mainDb)
      CloseDatabase(orm_mainDb)
      Debug "ORM: Database closed."
    EndIf
  EndProcedure

EndModule

; =============================================================================
; EOF ORM.pbi
; =============================================================================
