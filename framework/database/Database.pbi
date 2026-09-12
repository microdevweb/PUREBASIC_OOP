; =============================================================================
; Database.pbi - Database Management Class implementing IDatabase
; PureBasic OOP Framework - ORM Engine v2.0
; =============================================================================

XIncludeFile "IDatabase.pbi"
XIncludeFile "IDatabaseEntity.pbi"
XIncludeFile "ORM_Transaction.pbi"
XIncludeFile "ORM_Schema.pbi"
XIncludeFile "ORM_Relations.pbi"

DeclareModule Database

  UseModule DatabaseEngine
  UseModule DatabaseEntities

  Structure _Database_Internal
    *vTable
    driver.i
    databasePath.s
    host.s
    port.i
    databaseName.s
    username.s
    password.s
    dbHandle.i
    inTransaction.b
    enableWAL.b
    enableFK.b
    isOpen.b
  EndStructure

  ; Création d'instances
  Declare.i NewSQLite(path.s, enableWAL.b = #True, enableFK.b = #True)
  Declare.i NewMySQL(host.s, port.i, dbName.s, user.s, password.s)
  
  ; Gestion de la base par défaut (active record style)
  Declare SetDefault(db.IDatabase)
  Declare.i GetDefault()
  Declare.i WrapHandle(dbHandle.i)
  
  ; Méthodes de configuration
  Declare ConfigureSQLite(*this._Database_Internal, path.s, enableWAL.b = #True, enableFK.b = #True)
  Declare ConfigureMySQL(*this._Database_Internal, host.s, port.i, dbName.s, user.s, password.s)
  
  ; Implémentation IDatabase
  Declare.b Connect(*this._Database_Internal)
  Declare Disconnect(*this._Database_Internal)
  Declare.b IsOpen(*this._Database_Internal)
  Declare.i GetHandle(*this._Database_Internal)
  Declare.i GetDriver(*this._Database_Internal)
  
  Declare.b BeginTransaction(*this._Database_Internal)
  Declare.b Commit(*this._Database_Internal)
  Declare.b Rollback(*this._Database_Internal)
  Declare.b IsInTransaction(*this._Database_Internal)
  
  Declare.b Execute(*this._Database_Internal, sql.s)
  Declare.i Query(*this._Database_Internal, sql.s)
  
  Declare.b Save(*this._Database_Internal, *entity)
  Declare.b Delete(*this._Database_Internal, *entity)
  
  Declare.b AutoMigrate(*this._Database_Internal)
  Declare Free(*this._Database_Internal)
EndDeclareModule

Module Database

  UseModule DatabaseEngine
  UseModule DatabaseEntities

  Global g_defaultDatabase.IDatabase = 0

  Procedure SetDefault(db.IDatabase)
    g_defaultDatabase = db
  EndProcedure

  Procedure.i GetDefault()
    ProcedureReturn g_defaultDatabase
  EndProcedure

  Procedure.i WrapHandle(dbHandle.i)
    If dbHandle = 0 : ProcedureReturn 0 : EndIf
    If g_defaultDatabase And g_defaultDatabase\GetHandle() = dbHandle
      ProcedureReturn g_defaultDatabase
    EndIf
    Protected *this._Database_Internal = AllocateStructure(_Database_Internal)
    If *this
      *this\vTable = ?Database_VTable
      *this\dbHandle = dbHandle
      *this\isOpen = #True
      ProcedureReturn *this
    EndIf
    ProcedureReturn 0
  EndProcedure

  Procedure ConfigureSQLite(*this._Database_Internal, path.s, enableWAL.b = #True, enableFK.b = #True)
    *this\driver = DatabaseEngine::#DB_Driver_SQLite
    *this\databasePath = path
    *this\enableWAL = enableWAL
    *this\enableFK = enableFK
  EndProcedure

  Procedure ConfigureMySQL(*this._Database_Internal, host.s, port.i, dbName.s, user.s, password.s)
    *this\driver = DatabaseEngine::#DB_Driver_MySQL
    *this\host = host
    *this\port = port
    *this\databaseName = dbName
    *this\username = user
    *this\password = password
  EndProcedure

  Procedure.b Connect(*this._Database_Internal)
    If *this\isOpen And IsDatabase(*this\dbHandle)
      ProcedureReturn #True
    EndIf

    Select *this\driver
      Case DatabaseEngine::#DB_Driver_SQLite
        UseSQLiteDatabase()
        If FileSize(*this\databasePath) = -1
          Protected f.i = CreateFile(#PB_Any, *this\databasePath)
          If f : CloseFile(f) : EndIf
        EndIf
        *this\dbHandle = OpenDatabase(#PB_Any, *this\databasePath, "", "", #PB_Database_SQLite)
        If IsDatabase(*this\dbHandle)
          *this\isOpen = #True
          If *this\enableWAL
            DatabaseUpdate(*this\dbHandle, "PRAGMA journal_mode=WAL;")
          EndIf
          If *this\enableFK
            DatabaseUpdate(*this\dbHandle, "PRAGMA foreign_keys=ON;")
          EndIf
          ProcedureReturn #True
        Else
          Debug "Database::Connect ERROR: " + DatabaseError()
          ProcedureReturn #False
        EndIf

      Case DatabaseEngine::#DB_Driver_MySQL
        Debug "Database::Connect MySQL not yet implemented"
        ProcedureReturn #False
        
      Default
        ProcedureReturn #False
    EndSelect
  EndProcedure

  Procedure Disconnect(*this._Database_Internal)
    If *this\isOpen And IsDatabase(*this\dbHandle)
      If *this\inTransaction
        ORM_Transaction::Rollback(*this\dbHandle)
        *this\inTransaction = #False
      EndIf
      CloseDatabase(*this\dbHandle)
      *this\dbHandle = 0
      *this\isOpen = #False
    EndIf
  EndProcedure

  Procedure.b IsOpen(*this._Database_Internal)
    ProcedureReturn *this\isOpen
  EndProcedure

  Procedure.i GetHandle(*this._Database_Internal)
    ProcedureReturn *this\dbHandle
  EndProcedure

  Procedure.i GetDriver(*this._Database_Internal)
    ProcedureReturn *this\driver
  EndProcedure

  Procedure.b BeginTransaction(*this._Database_Internal)
    If Not *this\isOpen : Connect(*this) : EndIf
    If Not *this\isOpen : ProcedureReturn #False : EndIf
    If *this\inTransaction : ProcedureReturn #True : EndIf
    
    If ORM_Transaction::Begin(*this\dbHandle)
      *this\inTransaction = #True
      ProcedureReturn #True
    EndIf
    ProcedureReturn #False
  EndProcedure

  Procedure.b Commit(*this._Database_Internal)
    If Not *this\isOpen Or Not *this\inTransaction : ProcedureReturn #False : EndIf
    If ORM_Transaction::Commit(*this\dbHandle)
      *this\inTransaction = #False
      ProcedureReturn #True
    EndIf
    ProcedureReturn #False
  EndProcedure

  Procedure.b Rollback(*this._Database_Internal)
    If Not *this\isOpen Or Not *this\inTransaction : ProcedureReturn #False : EndIf
    If ORM_Transaction::Rollback(*this\dbHandle)
      *this\inTransaction = #False
      ProcedureReturn #True
    EndIf
    ProcedureReturn #False
  EndProcedure

  Procedure.b IsInTransaction(*this._Database_Internal)
    ProcedureReturn *this\inTransaction
  EndProcedure

  Procedure.b Execute(*this._Database_Internal, sql.s)
    If Not *this\isOpen : Connect(*this) : EndIf
    If Not *this\isOpen : ProcedureReturn #False : EndIf
    ProcedureReturn DatabaseUpdate(*this\dbHandle, sql)
  EndProcedure

  Procedure.i Query(*this._Database_Internal, sql.s)
    If Not *this\isOpen : Connect(*this) : EndIf
    If Not *this\isOpen : ProcedureReturn 0 : EndIf
    ProcedureReturn DatabaseQuery(*this\dbHandle, sql)
  EndProcedure

  Procedure.b Save(*this._Database_Internal, *entity)
    If Not *entity : ProcedureReturn #False : EndIf
    If Not *this\isOpen : Connect(*this) : EndIf
    If Not *this\isOpen : ProcedureReturn #False : EndIf
    
    Protected *entityObj.IDatabaseEntity = *entity
    Protected entityName.s = *entityObj\GetEntityName()
    If entityName = "" : ProcedureReturn #False : EndIf
    
    ProcedureReturn ORM_Relations::SaveEntityComplete(*this\dbHandle, entityName, *entity)
  EndProcedure

  Procedure.b Delete(*this._Database_Internal, *entity)
    If Not *entity : ProcedureReturn #False : EndIf
    If Not *this\isOpen : Connect(*this) : EndIf
    If Not *this\isOpen : ProcedureReturn #False : EndIf
    
    Protected *entityObj.IDatabaseEntity = *entity
    Protected entityName.s = *entityObj\GetEntityName()
    If entityName = "" : ProcedureReturn #False : EndIf
    
    ProcedureReturn ORM_Relations::DeleteEntityComplete(*this\dbHandle, entityName, *entity)
  EndProcedure

  Procedure.b AutoMigrate(*this._Database_Internal)
    If Not *this\isOpen : Connect(*this) : EndIf
    If Not *this\isOpen : ProcedureReturn #False : EndIf
    ProcedureReturn ORM_Schema::Migrate(*this\dbHandle)
  EndProcedure

  Procedure Free(*this._Database_Internal)
    Disconnect(*this)
    FreeStructure(*this)
  EndProcedure

  ; VTable
  DataSection
    Database_VTable:
      Data.i @Connect()
      Data.i @Disconnect()
      Data.i @IsOpen()
      Data.i @GetHandle()
      Data.i @GetDriver()
      Data.i @BeginTransaction()
      Data.i @Commit()
      Data.i @Rollback()
      Data.i @IsInTransaction()
      Data.i @Execute()
      Data.i @Query()
      Data.i @Save()
      Data.i @Delete()
      Data.i @AutoMigrate()
  EndDataSection

  Procedure.i NewSQLite(path.s, enableWAL.b = #True, enableFK.b = #True)
    Protected *obj._Database_Internal = AllocateStructure(_Database_Internal)
    *obj\vTable = ?Database_VTable
    ConfigureSQLite(*obj, path, enableWAL, enableFK)
    If g_defaultDatabase = 0
      g_defaultDatabase = *obj
    EndIf
    ProcedureReturn *obj
  EndProcedure

  Procedure.i NewMySQL(host.s, port.i, dbName.s, user.s, password.s)
    Protected *obj._Database_Internal = AllocateStructure(_Database_Internal)
    *obj\vTable = ?Database_VTable
    ConfigureMySQL(*obj, host, port, dbName, user, password)
    If g_defaultDatabase = 0
      g_defaultDatabase = *obj
    EndIf
    ProcedureReturn *obj
  EndProcedure

EndModule
