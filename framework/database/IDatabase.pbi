; =============================================================================
; IDatabase.pbi - Database Connection & Context Interface
; PureBasic OOP Framework - ORM Engine v2.0
; =============================================================================

DeclareModule DatabaseEngine

  ; Drivers supportés
  #DB_Driver_SQLite     = 1
  #DB_Driver_MySQL      = 2
  #DB_Driver_PostgreSQL = 3

  ; -----------------------------------------------------------------------------
  ; Interface IDatabase
  ; Définit le contrat universel pour toute base de données dans le framework.
  ; -----------------------------------------------------------------------------
  Interface IDatabase
    ; Connexion & Cycle de vie
    Connect.b()
    Disconnect()
    IsOpen.b()
    GetHandle.i()
    GetDriver.i()

    ; Transactions
    BeginTransaction.b()
    Commit.b()
    Rollback.b()
    IsInTransaction.b()

    ; Exécution SQL brute & Requêtes
    Execute.b(sql.s)
    Query.i(sql.s)

    ; Opérations d'entités via l'interface
    Save.b(*entity)
    Delete.b(*entity)
    
    ; Migration automatique de schéma
    AutoMigrate.b()
  EndInterface

EndDeclareModule

Module DatabaseEngine
EndModule
