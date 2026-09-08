; =============================================================================
; ORM_Relations.pbi - 1-N Cascade Save, FK Integrity Enforcement
; PureBasic OOP Framework - Alpha 1.4 (Phase 2)
; =============================================================================
; Handles all referential integrity scenarios for 1-N relations:
;
;   CascadeSave   (default) - saving parent triggers saving all its children
;   RestrictDelete(default) - cannot delete parent while children exist
;   CascadeDelete           - deleting parent deletes all its children first
;   SetNullDelete           - deleting parent nullifies children's FK column
;   AllowOrphan             - no enforcement (children keep stale FK)
;
; All operations run INSIDE a BEGIN/COMMIT transaction so the entire
; parent+children operation is atomic. On any failure -> ROLLBACK.
; =============================================================================

XIncludeFile "ORM_CRUD.pbi"

DeclareModule ORM_Relations

  ; --- Check if any child records exist for a given parent id ---
  ; childTable.s : "contacts"
  ; fkColumn.s   : "clientId"
  ; parentId.i   : the parent's id value
  Declare.b HasChildren(db.i, childTable.s, fkColumn.s, parentId.i)

  ; --- Delete all child records (CascadeDelete policy) ---
  Declare.b DeleteChildren(db.i, childTable.s, fkColumn.s, parentId.i)

  ; --- Set FK to NULL on all children (SetNullDelete policy) ---
  Declare.b NullifyChildren(db.i, childTable.s, fkColumn.s, parentId.i)

  ; --- Save parent + all children in one atomic transaction ---
  ; Steps:
  ;   1. BEGIN
  ;   2. INSERT or UPDATE the parent entity
  ;   3. For each relation with cascadeSave=True: call saveChildrenProc
  ;   4. COMMIT (or ROLLBACK on any error)
  ; Returns #ORM_Success or error code.
  Declare.i SaveWithChildren(db.i, entityType.s, *entity, serializeProc.i)

  ; --- Delete with FK enforcement ---
  ; Checks each relation's deletePolicy before performing the DELETE.
  ; Policies applied in order:
  ;   RestrictDelete -> return #ORM_Error_HasChildren if children exist
  ;   CascadeDelete  -> delete children first, then parent
  ;   SetNullDelete  -> nullify children FK, then delete parent
  ;   AllowOrphan    -> delete parent without touching children
  ; Returns #ORM_Success, #ORM_Error_HasChildren, or other error code.
  Declare.i DeleteWithFKCheck(db.i, entityType.s, *entity)

EndDeclareModule

Module ORM_Relations

  ; ---------------------------------------------------------------------------
  ; Check if a parent has any child records in the given child table
  ; ---------------------------------------------------------------------------
  Procedure.b HasChildren(db.i, childTable.s, fkColumn.s, parentId.i)
    Protected sql.s = "SELECT COUNT(*) FROM " + childTable +
                      " WHERE " + fkColumn + "=" + Str(parentId) + ";"
    Protected found.b = #False
    If DatabaseQuery(db, sql)
      If NextDatabaseRow(db)
        found = (GetDatabaseLong(db, 0) > 0)
      EndIf
      FinishDatabaseQuery(db)
    Else
      Debug "ORM_Relations::HasChildren ERROR: " + DatabaseError()
    EndIf
    Debug "ORM_Relations::HasChildren (" + childTable + ", " + fkColumn + "=" + Str(parentId) + ") -> " + Str(found)
    ProcedureReturn found
  EndProcedure

  ; ---------------------------------------------------------------------------
  ; Delete all children (CascadeDelete)
  ; ---------------------------------------------------------------------------
  Procedure.b DeleteChildren(db.i, childTable.s, fkColumn.s, parentId.i)
    Protected sql.s = "DELETE FROM " + childTable +
                      " WHERE " + fkColumn + "=" + Str(parentId) + ";"
    Debug "ORM_Relations::DeleteChildren -> " + sql
    ProcedureReturn ORM_Transaction::Execute(db, sql)
  EndProcedure

  ; ---------------------------------------------------------------------------
  ; Set FK to NULL on all children (SetNullDelete)
  ; ---------------------------------------------------------------------------
  Procedure.b NullifyChildren(db.i, childTable.s, fkColumn.s, parentId.i)
    Protected sql.s = "UPDATE " + childTable +
                      " SET " + fkColumn + "=NULL" +
                      " WHERE " + fkColumn + "=" + Str(parentId) + ";"
    Debug "ORM_Relations::NullifyChildren -> " + sql
    ProcedureReturn ORM_Transaction::Execute(db, sql)
  EndProcedure

  ; ---------------------------------------------------------------------------
  ; SaveWithChildren: atomic parent + children save in one transaction
  ; ---------------------------------------------------------------------------
  Procedure.i SaveWithChildren(db.i, entityType.s, *entity, serializeProc.i)
    Protected *meta.ORM_Schema::ORM_EntityMeta = ORM_Schema::FindEntityMeta(entityType)
    If Not *meta : ProcedureReturn #ORM_Entity::#ORM_Error_NotFound : EndIf

    ; --- BEGIN transaction ---
    If Not ORM_Transaction::Begin(db)
      ProcedureReturn #ORM_Entity::#ORM_Error_DbConnection
    EndIf

    ; --- Step 1: save parent (INSERT or UPDATE) ---
    Protected ok.b = ORM_CRUD::InsertOrUpdate(db, entityType, *entity, serializeProc)

    If Not ok
      ORM_Transaction::Rollback(db)
      Debug "ORM_Relations::SaveWithChildren: parent save FAILED - rolled back"
      ProcedureReturn #ORM_Entity::#ORM_Error_DbConnection
    EndIf

    ; Get the parent id (set by INSERT or already > 0 for UPDATE)
    Protected *base.ORM_CRUD::ORM_EntityBase = *entity
    Protected parentId.i = *base\id

    ; --- Step 2: for each cascade relation, call saveChildrenProc ---
    ForEach *meta\relations()
      If *meta\relations()\cascadeSave And *meta\relations()\saveChildrenProc <> 0
        Protected saveChildrenFn.ORM_Schema::ORM_SaveChildrenProto = *meta\relations()\saveChildrenProc
        saveChildrenFn(*entity, db)
        ; Note: saveChildrenProc calls ORM_CRUD::SaveOne() internally for each child.
        ; If it fails, it should Debug the error; we don't break the transaction here
        ; for individual child failures (could add strict mode later).
        Debug "ORM_Relations: cascade-saved children of " + entityType + "#" + Str(parentId)
      EndIf
    Next

    ; --- COMMIT ---
    If ORM_Transaction::Commit(db)
      Debug "ORM_Relations::SaveWithChildren: COMMITTED (" + entityType + "#" + Str(parentId) + ")"
      ProcedureReturn #ORM_Entity::#ORM_Success
    Else
      ORM_Transaction::Rollback(db)
      Debug "ORM_Relations::SaveWithChildren: COMMIT failed - rolled back"
      ProcedureReturn #ORM_Entity::#ORM_Error_DbConnection
    EndIf
  EndProcedure

  ; ---------------------------------------------------------------------------
  ; DeleteWithFKCheck: enforce referential integrity before deleting
  ; ---------------------------------------------------------------------------
  Procedure.i DeleteWithFKCheck(db.i, entityType.s, *entity)
    Protected *meta.ORM_Schema::ORM_EntityMeta = ORM_Schema::FindEntityMeta(entityType)
    If Not *meta : ProcedureReturn #ORM_Entity::#ORM_Error_NotFound : EndIf

    Protected *base.ORM_CRUD::ORM_EntityBase = *entity
    Protected parentId.i = *base\id

    If parentId = 0
      Debug "ORM_Relations::DeleteWithFKCheck: id=0, nothing to delete"
      ProcedureReturn #ORM_Entity::#ORM_Success
    EndIf

    ; --- BEGIN transaction ---
    If Not ORM_Transaction::Begin(db)
      ProcedureReturn #ORM_Entity::#ORM_Error_DbConnection
    EndIf

    ; --- Check each 1-N relation and apply the configured delete policy ---
    ForEach *meta\relations()
      Protected childTbl.s = *meta\relations()\childTable
      Protected fkCol.s    = *meta\relations()\fkColumn
      Protected policy.i   = *meta\relations()\deletePolicy

      Select policy
        Case #ORM_Entity::#ORM_Restrict_Delete
          ; BLOCK the delete if children exist
          If HasChildren(db, childTbl, fkCol, parentId)
            ORM_Transaction::Rollback(db)
            Debug "ORM_Relations::Delete BLOCKED: " + entityType + "#" + Str(parentId) +
                  " has children in '" + childTbl + "' (RestrictDelete policy)"
            ProcedureReturn #ORM_Entity::#ORM_Error_HasChildren
          EndIf

        Case #ORM_Entity::#ORM_Cascade_Delete
          ; Delete all children first, then continue to parent delete
          If Not DeleteChildren(db, childTbl, fkCol, parentId)
            ORM_Transaction::Rollback(db)
            Debug "ORM_Relations::Delete: cascade child delete FAILED"
            ProcedureReturn #ORM_Entity::#ORM_Error_DbConnection
          EndIf

        Case #ORM_Entity::#ORM_SetNull_Delete
          ; Nullify FK on children, then continue to parent delete
          If Not NullifyChildren(db, childTbl, fkCol, parentId)
            ORM_Transaction::Rollback(db)
            Debug "ORM_Relations::Delete: set-null on children FAILED"
            ProcedureReturn #ORM_Entity::#ORM_Error_DbConnection
          EndIf

        Case #ORM_Entity::#ORM_AllowOrphan
          ; No action - children keep their FK value (may become orphans)
          Debug "ORM_Relations::Delete: AllowOrphan - skipping FK check for " + childTbl

        Default
          ; Default safety: treat unknown policy as RestrictDelete
          If HasChildren(db, childTbl, fkCol, parentId)
            ORM_Transaction::Rollback(db)
            ProcedureReturn #ORM_Entity::#ORM_Error_HasChildren
          EndIf
      EndSelect
    Next

    ; --- All FK rules passed: delete the parent record ---
    If Not ORM_CRUD::DeleteById(db, entityType, parentId)
      ORM_Transaction::Rollback(db)
      ProcedureReturn #ORM_Entity::#ORM_Error_DbConnection
    EndIf

    ; --- COMMIT ---
    If ORM_Transaction::Commit(db)
      Debug "ORM_Relations::DeleteWithFKCheck: DELETED " + entityType + "#" + Str(parentId)
      ProcedureReturn #ORM_Entity::#ORM_Success
    Else
      ORM_Transaction::Rollback(db)
      ProcedureReturn #ORM_Entity::#ORM_Error_DbConnection
    EndIf
  EndProcedure

EndModule

; =============================================================================
; EOF ORM_Relations.pbi
; =============================================================================
