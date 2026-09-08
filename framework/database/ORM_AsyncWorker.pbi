; =============================================================================
; ORM_AsyncWorker.pbi - Background Thread Pool for non-blocking DB operations
; PureBasic OOP Framework - Alpha 1.4
; =============================================================================
; All slow database operations (load, save, query) are dispatched to this pool
; so the UI thread is NEVER blocked.
;
; How it works:
;   1. UI thread calls SaveAsync(*entity, @callback) or QueryAsync(...)
;   2. A work item is pushed to the thread-safe queue
;   3. A worker thread picks it up, executes the SQL on its own DB connection
;   4. Worker calls PostEvent(#PB_Event_Custom, window, ...) to notify the UI
;   5. UI event handler receives the result and calls the user's callback safely
;
; Important:
;   - Workers have their OWN database connection (no cross-thread DB sharing)
;   - SQLite WAL mode allows multiple readers + 1 writer concurrently
;   - All PostEvent calls are handled by the main event loop (WindowEvent())
; =============================================================================

XIncludeFile "ORM_Transaction.pbi"

DeclareModule ORM_AsyncWorker

  ; --- Work item type codes ---
  #ORM_Op_Save    = 1
  #ORM_Op_FindById = 2
  #ORM_Op_Query   = 3
  #ORM_Op_Delete  = 4

  ; --- Custom event codes dispatched from worker to UI thread ---
  ; Usage: PostEvent(#PB_Event_Custom, windowId, #ORM_Event_SaveDone, ...)
  #ORM_Event_SaveDone    = $1001
  #ORM_Event_LoadDone    = $1002
  #ORM_Event_QueryDone   = $1003
  #ORM_Event_DeleteDone  = $1004
  #ORM_Event_Error       = $1005

  ; --- Work item pushed to the worker queue ---
  Structure ORM_WorkItem
    operation.i     ; #ORM_Op_*
    entityPtr.i     ; Pointer to the entity object (*client)
    entityType.s    ; "Client"
    recordId.i      ; For FindById / Delete
    whereClause.s   ; For QueryAsync
    callbackPtr.i   ; Pointer to callback procedure
    windowId.i      ; Target window for PostEvent notification
    resultPtr.i     ; Output: pointer to result data (filled by worker)
    errorCode.i     ; Output: #ORM_Success or error code
  EndStructure

  ; --- Initialize the worker pool ---
  ; dbPath.s    : path to the SQLite file (each worker opens its own connection)
  ; numWorkers  : number of parallel worker threads (1 to 4)
  ; windowId.i  : the main window handle to receive completion events
  Declare Init(dbPath.s, numWorkers.i = 2, windowId.i = 0)

  ; --- Shut down all workers gracefully ---
  Declare Shutdown()

  ; --- Push a work item to the queue ---
  ; Returns #True if queued successfully.
  Declare.b Enqueue(workItem.ORM_WorkItem)

  ; --- Convenience wrappers (called from entity methods) ---
  Declare SaveAsync(*entity, entityType.s, callbackPtr.i, windowId.i)
  Declare FindByIdAsync(entityType.s, recordId.i, callbackPtr.i, windowId.i)
  Declare QueryAsync(entityType.s, whereClause.s, callbackPtr.i, windowId.i)
  Declare DeleteAsync(*entity, entityType.s, callbackPtr.i, windowId.i)

EndDeclareModule

Module ORM_AsyncWorker

  ; ---------------------------------------------------------------------------
  ; Internal state
  ; ---------------------------------------------------------------------------
  Global orm_dbPath.s
  Global orm_windowId.i
  Global orm_numWorkers.i

  ; Thread-safe work queue
  Global orm_queueMutex.i     = CreateMutex()
  Global orm_queueSemaphore.i = CreateSemaphore()   ; signals workers that work is available
  Global NewList orm_workQueue.ORM_AsyncWorker::ORM_WorkItem()
  Global orm_shutdown.i = 0

  ; Worker thread IDs
  Global Dim orm_workerThreads.i(4)

  ; ---------------------------------------------------------------------------
  ; Worker thread procedure
  ; Each worker opens its OWN SQLite connection to avoid cross-thread sharing
  ; ---------------------------------------------------------------------------
  Procedure ORM_WorkerThread(*dummy)
    ; Open a dedicated DB connection for this worker
    Protected workerDb.i = OpenDatabase(#PB_Any, orm_dbPath, "", "", #PB_Database_SQLite)
    If Not IsDatabase(workerDb)
      Debug "ORM_AsyncWorker: WORKER FAILED to open DB: " + orm_dbPath
      ProcedureReturn
    EndIf
    ORM_Transaction::Execute(workerDb, "PRAGMA journal_mode=WAL;")
    Debug "ORM_AsyncWorker: Worker thread started (DB=" + Str(workerDb) + ")"

    Repeat
      ; Wait for a work item signal
      WaitSemaphore(orm_queueSemaphore)

      ; Check for shutdown signal
      If orm_shutdown = 1 : Break : EndIf

      ; Pop next work item from queue (under mutex protection)
      Protected workItem.ORM_AsyncWorker::ORM_WorkItem
      LockMutex(orm_queueMutex)
        If ListSize(orm_workQueue()) > 0
          FirstElement(orm_workQueue())
          CopyStructure(@orm_workQueue(), @workItem, ORM_AsyncWorker::ORM_WorkItem)
          DeleteElement(orm_workQueue())
        EndIf
      UnlockMutex(orm_queueMutex)

      ; Execute the work item
      Protected eventCode.i = #ORM_AsyncWorker::#ORM_Event_Error
      Protected result.i    = #ORM_Entity::#ORM_Error_DbConnection

      Select workItem\operation
        Case #ORM_AsyncWorker::#ORM_Op_Save
          ; TODO Phase 2: call ORM_CRUD::InsertOrUpdate(workerDb, workItem\entityPtr, workItem\entityType)
          ; For now: placeholder that always succeeds
          Debug "ORM_AsyncWorker: [STUB] SaveAsync for " + workItem\entityType
          result    = #ORM_Entity::#ORM_Success
          eventCode = #ORM_AsyncWorker::#ORM_Event_SaveDone

        Case #ORM_AsyncWorker::#ORM_Op_FindById
          ; TODO Phase 2: call ORM_CRUD::FindById(workerDb, workItem\entityType, workItem\recordId)
          Debug "ORM_AsyncWorker: [STUB] FindByIdAsync for " + workItem\entityType + "#" + Str(workItem\recordId)
          result    = #ORM_Entity::#ORM_Success
          eventCode = #ORM_AsyncWorker::#ORM_Event_LoadDone

        Case #ORM_AsyncWorker::#ORM_Op_Query
          ; TODO Phase 2: call ORM_CRUD::Query(workerDb, workItem\entityType, workItem\whereClause)
          Debug "ORM_AsyncWorker: [STUB] QueryAsync for " + workItem\entityType + " WHERE " + workItem\whereClause
          result    = #ORM_Entity::#ORM_Success
          eventCode = #ORM_AsyncWorker::#ORM_Event_QueryDone

        Case #ORM_AsyncWorker::#ORM_Op_Delete
          ; TODO Phase 2: call ORM_CRUD::Delete(workerDb, workItem\entityType, workItem\entityPtr)
          Debug "ORM_AsyncWorker: [STUB] DeleteAsync for " + workItem\entityType
          result    = #ORM_Entity::#ORM_Success
          eventCode = #ORM_AsyncWorker::#ORM_Event_DeleteDone
      EndSelect

      ; Dispatch result to UI thread via PostEvent (SAFE: UI thread handles gadget updates)
      ; lParam encodes the callback pointer, wParam encodes the result code
      PostEvent(#PB_Event_Custom, workItem\windowId, eventCode,
                workItem\callbackPtr, workItem\entityPtr)
      ; NOTE: The UI event handler must cast the callback pointer and call it:
      ;   callbackProc = EventData()    ; = callbackPtr
      ;   entityPtr    = EventObject()  ; = *entity
      ;   callbackProc(entityPtr, result)

    ForEver

    CloseDatabase(workerDb)
    Debug "ORM_AsyncWorker: Worker thread exiting."
  EndProcedure

  ; ---------------------------------------------------------------------------
  ; Initialize the worker pool
  ; ---------------------------------------------------------------------------
  Procedure Init(dbPath.s, numWorkers.i = 2, windowId.i = 0)
    orm_dbPath     = dbPath
    orm_windowId   = windowId
    orm_numWorkers = Clamp(numWorkers, 1, 4)
    orm_shutdown   = 0

    Protected i.i
    For i = 0 To orm_numWorkers - 1
      orm_workerThreads(i) = CreateThread(@ORM_WorkerThread(), 0)
    Next
    Debug "ORM_AsyncWorker: Pool started with " + Str(orm_numWorkers) + " worker(s)."
  EndProcedure

  ; ---------------------------------------------------------------------------
  ; Shut down the worker pool gracefully
  ; ---------------------------------------------------------------------------
  Procedure Shutdown()
    orm_shutdown = 1
    ; Signal all workers to wake up and exit
    Protected i.i
    For i = 0 To orm_numWorkers - 1
      SignalSemaphore(orm_queueSemaphore)
    Next
    ; Wait for all workers to finish
    For i = 0 To orm_numWorkers - 1
      If orm_workerThreads(i)
        WaitThread(orm_workerThreads(i))
      EndIf
    Next
    Debug "ORM_AsyncWorker: All workers stopped."
  EndProcedure

  ; ---------------------------------------------------------------------------
  ; Push a work item onto the queue
  ; ---------------------------------------------------------------------------
  Procedure.b Enqueue(workItem.ORM_AsyncWorker::ORM_WorkItem)
    LockMutex(orm_queueMutex)
      AddElement(orm_workQueue())
      CopyStructure(@workItem, @orm_workQueue(), ORM_AsyncWorker::ORM_WorkItem)
    UnlockMutex(orm_queueMutex)
    SignalSemaphore(orm_queueSemaphore)   ; Wake up one worker
    ProcedureReturn #True
  EndProcedure

  ; ---------------------------------------------------------------------------
  ; Convenience wrapper: SaveAsync
  ; ---------------------------------------------------------------------------
  Procedure SaveAsync(*entity, entityType.s, callbackPtr.i, windowId.i)
    Protected item.ORM_AsyncWorker::ORM_WorkItem
    item\operation   = #ORM_AsyncWorker::#ORM_Op_Save
    item\entityPtr   = *entity
    item\entityType  = entityType
    item\callbackPtr = callbackPtr
    item\windowId    = windowId
    Enqueue(item)
  EndProcedure

  ; ---------------------------------------------------------------------------
  ; Convenience wrapper: FindByIdAsync
  ; ---------------------------------------------------------------------------
  Procedure FindByIdAsync(entityType.s, recordId.i, callbackPtr.i, windowId.i)
    Protected item.ORM_AsyncWorker::ORM_WorkItem
    item\operation   = #ORM_AsyncWorker::#ORM_Op_FindById
    item\entityType  = entityType
    item\recordId    = recordId
    item\callbackPtr = callbackPtr
    item\windowId    = windowId
    Enqueue(item)
  EndProcedure

  ; ---------------------------------------------------------------------------
  ; Convenience wrapper: QueryAsync
  ; ---------------------------------------------------------------------------
  Procedure QueryAsync(entityType.s, whereClause.s, callbackPtr.i, windowId.i)
    Protected item.ORM_AsyncWorker::ORM_WorkItem
    item\operation   = #ORM_AsyncWorker::#ORM_Op_Query
    item\entityType  = entityType
    item\whereClause = whereClause
    item\callbackPtr = callbackPtr
    item\windowId    = windowId
    Enqueue(item)
  EndProcedure

  ; ---------------------------------------------------------------------------
  ; Convenience wrapper: DeleteAsync
  ; ---------------------------------------------------------------------------
  Procedure DeleteAsync(*entity, entityType.s, callbackPtr.i, windowId.i)
    Protected item.ORM_AsyncWorker::ORM_WorkItem
    item\operation   = #ORM_AsyncWorker::#ORM_Op_Delete
    item\entityPtr   = *entity
    item\entityType  = entityType
    item\callbackPtr = callbackPtr
    item\windowId    = windowId
    Enqueue(item)
  EndProcedure

EndModule

; =============================================================================
; EOF ORM_AsyncWorker.pbi
; =============================================================================
