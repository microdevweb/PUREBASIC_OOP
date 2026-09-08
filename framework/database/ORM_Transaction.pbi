; =============================================================================
; ORM_Transaction.pbi - Database transaction helpers
; PureBasic OOP Framework - Alpha 1.4
; =============================================================================
; Wraps SQLite transaction commands with error handling and nesting support.
; All multi-step ORM operations (e.g. cascade save) use these helpers so that
; either everything succeeds or everything is rolled back atomically.
; =============================================================================

DeclareModule ORM_Transaction

  ; Transaction nesting depth counter (0 = no active transaction)
  Global orm_txDepth.i = 0

  ; --- Begin a transaction (or save a nested savepoint) ---
  ; db.i : open database handle (from OpenDatabase())
  ; Returns #True on success, #False on error.
  Declare.b Begin(db.i)

  ; --- Commit the current transaction ---
  Declare.b Commit(db.i)

  ; --- Roll back the current transaction ---
  Declare.b Rollback(db.i)

  ; --- Execute a single SQL statement with no result set ---
  ; Thin wrapper around DatabaseUpdate() with error logging.
  Declare.b Execute(db.i, sql.s)

EndDeclareModule

Module ORM_Transaction

  ; ---------------------------------------------------------------------------
  ; Begin transaction
  ; Uses SQLite WAL mode savepoints for nested call safety
  ; ---------------------------------------------------------------------------
  Procedure.b Begin(db.i)
    Protected ok.b
    If orm_txDepth = 0
      ok = DatabaseUpdate(db, "BEGIN;")
    Else
      ; Nested call: use a savepoint named by depth level
      ok = DatabaseUpdate(db, "SAVEPOINT orm_sp_" + Str(orm_txDepth) + ";")
    EndIf
    If ok
      orm_txDepth + 1
    Else
      Debug "ORM_Transaction::Begin() ERROR: " + DatabaseError()
    EndIf
    ProcedureReturn ok
  EndProcedure

  ; ---------------------------------------------------------------------------
  ; Commit transaction (or release savepoint)
  ; ---------------------------------------------------------------------------
  Procedure.b Commit(db.i)
    Protected ok.b
    If orm_txDepth <= 0
      Debug "ORM_Transaction::Commit() WARNING: no active transaction"
      ProcedureReturn #False
    EndIf
    orm_txDepth - 1
    If orm_txDepth = 0
      ok = DatabaseUpdate(db, "COMMIT;")
    Else
      ok = DatabaseUpdate(db, "RELEASE SAVEPOINT orm_sp_" + Str(orm_txDepth) + ";")
    EndIf
    If Not ok
      Debug "ORM_Transaction::Commit() ERROR: " + DatabaseError()
    EndIf
    ProcedureReturn ok
  EndProcedure

  ; ---------------------------------------------------------------------------
  ; Rollback transaction (or rollback to savepoint)
  ; ---------------------------------------------------------------------------
  Procedure.b Rollback(db.i)
    Protected ok.b
    If orm_txDepth <= 0
      Debug "ORM_Transaction::Rollback() WARNING: no active transaction"
      ProcedureReturn #False
    EndIf
    orm_txDepth - 1
    If orm_txDepth = 0
      ok = DatabaseUpdate(db, "ROLLBACK;")
    Else
      ok = DatabaseUpdate(db, "ROLLBACK TO SAVEPOINT orm_sp_" + Str(orm_txDepth) + ";")
    EndIf
    If Not ok
      Debug "ORM_Transaction::Rollback() ERROR: " + DatabaseError()
    EndIf
    ProcedureReturn ok
  EndProcedure

  ; ---------------------------------------------------------------------------
  ; Execute a single SQL statement (no result set)
  ; ---------------------------------------------------------------------------
  Procedure.b Execute(db.i, sql.s)
    Protected ok.b = DatabaseUpdate(db, sql)
    If Not ok
      Debug "ORM_Transaction::Execute() ERROR: " + DatabaseError()
      Debug "  SQL was: " + sql
    EndIf
    ProcedureReturn ok
  EndProcedure

EndModule

; =============================================================================
; EOF ORM_Transaction.pbi
; =============================================================================
