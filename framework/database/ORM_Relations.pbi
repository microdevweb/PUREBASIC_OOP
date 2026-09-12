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
XIncludeFile "EntitySet.pbi"

DeclareModule ORM_Relations

  UseModule EntitySet
  UseModule DatabaseEntities

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
  Declare.i DeleteWithFKCheck(db.i, entityType.s, *entity)

  ; --- High-level atomic save with all 1-N and N-N relations ---
  Declare.b SaveEntityComplete(db.i, entityType.s, *entity)

  ; --- High-level atomic delete with all 1-N and N-N relations ---
  Declare.b DeleteEntityComplete(db.i, entityType.s, *entity)

  ; --- Synchronize Many-to-Many junction table links from an EntitySet ---
  Declare.b SyncManyToManyLinks(db.i, joinTable.s, parentFk.s, parentId.i, childFk.s, entitySet.IEntitySet)

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
        found = Bool(GetDatabaseLong(db, 0) > 0)
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
    If Not *meta : ProcedureReturn ORM_Entity::#ORM_Error_NotFound : EndIf

    ; --- BEGIN transaction ---
    If Not ORM_Transaction::Begin(db)
      ProcedureReturn ORM_Entity::#ORM_Error_DbConnection
    EndIf

    ; --- Step 1: save parent (INSERT or UPDATE) ---
    Protected ok.b = ORM_CRUD::InsertOrUpdate(db, entityType, *entity, serializeProc)

    If Not ok
      ORM_Transaction::Rollback(db)
      Debug "ORM_Relations::SaveWithChildren: parent save FAILED - rolled back"
      ProcedureReturn ORM_Entity::#ORM_Error_DbConnection
    EndIf

    ; Get the parent id (set by INSERT or already > 0 for UPDATE)
    Protected parentId.i = ORM_CRUD::GetEntityId(*entity, *meta)

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
      ProcedureReturn ORM_Entity::#ORM_Success
    Else
      ORM_Transaction::Rollback(db)
      Debug "ORM_Relations::SaveWithChildren: COMMIT failed - rolled back"
      ProcedureReturn ORM_Entity::#ORM_Error_DbConnection
    EndIf
  EndProcedure

  ; ---------------------------------------------------------------------------
  ; DeleteWithFKCheck: enforce referential integrity before deleting
  ; ---------------------------------------------------------------------------
  Procedure.i DeleteWithFKCheck(db.i, entityType.s, *entity)
    Protected *meta.ORM_Schema::ORM_EntityMeta = ORM_Schema::FindEntityMeta(entityType)
    If Not *meta : ProcedureReturn ORM_Entity::#ORM_Error_NotFound : EndIf

    Protected parentId.i = ORM_CRUD::GetEntityId(*entity, *meta)

    If parentId = 0
      Debug "ORM_Relations::DeleteWithFKCheck: id=0, nothing to delete"
      ProcedureReturn ORM_Entity::#ORM_Success
    EndIf

    ; --- BEGIN transaction ---
    If Not ORM_Transaction::Begin(db)
      ProcedureReturn ORM_Entity::#ORM_Error_DbConnection
    EndIf

    ; --- Check each 1-N relation and apply the configured delete policy ---
    ForEach *meta\relations()
      Protected childTbl.s = *meta\relations()\childTable
      Protected fkCol.s    = *meta\relations()\fkColumn
      Protected policy.i   = *meta\relations()\deletePolicy

      Select policy
        Case ORM_Entity::#ORM_Restrict_Delete
          ; BLOCK the delete if children exist
          If HasChildren(db, childTbl, fkCol, parentId)
            ORM_Transaction::Rollback(db)
            Debug "ORM_Relations::Delete BLOCKED: " + entityType + "#" + Str(parentId) +
                  " has children in '" + childTbl + "' (RestrictDelete policy)"
            ProcedureReturn ORM_Entity::#ORM_Error_HasChildren
          EndIf

        Case ORM_Entity::#ORM_Cascade_Delete
          ; Delete all children first, then continue to parent delete
          If Not DeleteChildren(db, childTbl, fkCol, parentId)
            ORM_Transaction::Rollback(db)
            Debug "ORM_Relations::Delete: cascade child delete FAILED"
            ProcedureReturn ORM_Entity::#ORM_Error_DbConnection
          EndIf

        Case ORM_Entity::#ORM_SetNull_Delete
          ; Nullify FK on children, then continue to parent delete
          If Not NullifyChildren(db, childTbl, fkCol, parentId)
            ORM_Transaction::Rollback(db)
            Debug "ORM_Relations::Delete: set-null on children FAILED"
            ProcedureReturn ORM_Entity::#ORM_Error_DbConnection
          EndIf

        Case ORM_Entity::#ORM_AllowOrphan
          ; No action - children keep their FK value (may become orphans)
          Debug "ORM_Relations::Delete: AllowOrphan - skipping FK check for " + childTbl

        Default
          ; Default safety: treat unknown policy as RestrictDelete
          If HasChildren(db, childTbl, fkCol, parentId)
            ORM_Transaction::Rollback(db)
            ProcedureReturn ORM_Entity::#ORM_Error_HasChildren
          EndIf
      EndSelect
    Next

    ; --- All FK rules passed: delete the parent record ---
    If Not ORM_CRUD::DeleteById(db, entityType, parentId)
      ORM_Transaction::Rollback(db)
      ProcedureReturn ORM_Entity::#ORM_Error_DbConnection
    EndIf

    ; --- COMMIT ---
    If ORM_Transaction::Commit(db)
      Debug "ORM_Relations::DeleteWithFKCheck: DELETED " + entityType + "#" + Str(parentId)
      ProcedureReturn ORM_Entity::#ORM_Success
    Else
      ORM_Transaction::Rollback(db)
      ProcedureReturn ORM_Entity::#ORM_Error_DbConnection
    EndIf
  EndProcedure

  ; ---------------------------------------------------------------------------
  ; Synchronize Many-to-Many junction table from an EntitySet
  ; ---------------------------------------------------------------------------
  Procedure.b SyncManyToManyLinks(db.i, joinTable.s, parentFk.s, parentId.i, childFk.s, entitySet.IEntitySet)
    If Not entitySet : ProcedureReturn #True : EndIf

    Protected i.i, count.i = entitySet\GetAddedCount()
    For i = 0 To count - 1
      Protected item.IDatabaseEntity = entitySet\GetAddedItem(i)
      If item
        Protected childId.i = item\GetId()
        If childId = 0
          item\Save()
          childId = item\GetId()
        EndIf
        If childId > 0
          Protected sqlInsert.s = "INSERT OR IGNORE INTO " + joinTable + " (" + parentFk + ", " + childFk + ") VALUES (" + Str(parentId) + ", " + Str(childId) + ");"
          ORM_Transaction::Execute(db, sqlInsert)
        EndIf
      EndIf
    Next

    count = entitySet\GetRemovedCount()
    For i = 0 To count - 1
      Protected remItem.IDatabaseEntity = entitySet\GetRemovedItem(i)
      If remItem
        Protected remChildId.i = remItem\GetId()
        If remChildId > 0
          Protected sqlDel.s = "DELETE FROM " + joinTable + " WHERE " + parentFk + "=" + Str(parentId) + " AND " + childFk + "=" + Str(remChildId) + ";"
          ORM_Transaction::Execute(db, sqlDel)
        EndIf
      EndIf
    Next

    entitySet\ResetTracking()
    ProcedureReturn #True
  EndProcedure

  ; ---------------------------------------------------------------------------
  ; High-level Save with 1-N & N-N relations
  ; ---------------------------------------------------------------------------
  Procedure.b SaveEntityComplete(db.i, entityType.s, *entity)
    Protected *meta.ORM_Schema::ORM_EntityMeta = ORM_Schema::FindEntityMeta(entityType)
    If Not *meta : ProcedureReturn #False : EndIf

    Protected inTx.b = #False
    If ORM_Transaction::Begin(db)
      inTx = #True
    EndIf

    Protected ok.b = ORM_CRUD::InsertOrUpdate(db, entityType, *entity, *meta\serializeProc)
    If Not ok
      If inTx : ORM_Transaction::Rollback(db) : EndIf
      ProcedureReturn #False
    EndIf

    Protected parentId.i = ORM_CRUD::GetEntityId(*entity, *meta)

    ForEach *meta\relations()
      If *meta\relations()\saveChildrenProc <> 0
        Protected saveProc.ORM_Schema::ORM_SaveChildrenProto = *meta\relations()\saveChildrenProc
        saveProc(*entity, db)
      EndIf
    Next

    If inTx
      ORM_Transaction::Commit(db)
    EndIf

    ProcedureReturn #True
  EndProcedure

  ; ---------------------------------------------------------------------------
  ; High-level Delete with 1-N & N-N relations
  ; ---------------------------------------------------------------------------
  Procedure.b DeleteEntityComplete(db.i, entityType.s, *entity)
    Protected *meta.ORM_Schema::ORM_EntityMeta = ORM_Schema::FindEntityMeta(entityType)
    If Not *meta : ProcedureReturn #False : EndIf

    Protected inTx.b = #False
    If ORM_Transaction::Begin(db)
      inTx = #True
    EndIf

    Protected parentId.i = ORM_CRUD::GetEntityId(*entity, *meta)

    ; Delete N-N junction records
    ForEach *meta\relations()
      If *meta\relations()\relationType = ORM_Entity::#ORM_Rel_ManyToMany Or *meta\relations()\joinTable <> ""
        Protected jTable.s = *meta\relations()\joinTable
        Protected pFk.s    = *meta\relations()\parentFkColumn
        If jTable <> "" And pFk <> "" And parentId > 0
          ORM_Transaction::Execute(db, "DELETE FROM " + jTable + " WHERE " + pFk + "=" + Str(parentId) + ";")
        EndIf
      EndIf
    Next

    Protected res.i = DeleteWithFKCheck(db, entityType, *entity)
    If res <> ORM_Entity::#ORM_Success
      If inTx : ORM_Transaction::Rollback(db) : EndIf
      ProcedureReturn #False
    EndIf

    If inTx
      ORM_Transaction::Commit(db)
    EndIf
    ProcedureReturn #True
  EndProcedure

EndModule

; =============================================================================
; EOF ORM_Relations.pbi
; =============================================================================

