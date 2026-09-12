; =============================================================================
; ORM_AsyncWorker.pbi - Background Thread Pool for non-blocking DB operations
; PureBasic OOP Framework - Alpha 1.4 (Phase 2 - stubs replaced with real CRUD)
; =============================================================================
; How it works:
;   1. UI calls SaveAsync(*entity, entityType, serializeProc, @callback)
;   2. Work item pushed to thread-safe queue (mutex + semaphore)
;   3. Worker thread picks up item, opens its OWN DB connection (WAL mode)
;   4. Worker executes real SQL via ORM_Relations / ORM_CRUD
;   5. Worker posts PostEvent(#PB_Event_Custom, ...) to UI thread
;   6. UI event loop dispatches result to developer callback safely
;
; Query results:
;   For QueryAsync, the worker fills a global shared list (orm_queryResultList)
;   under a mutex. The callback reads and clears it. This is safe for typical
;   single-window CRM apps where one query completes before the next fires.
;   For high-concurrency needs, extend to a slot-indexed result pool.
; =============================================================================

XIncludeFile "ORM_Relations.pbi"

DeclareModule ORM_AsyncWorker

  CompilerIf Not Defined(PB_Event_Custom, #PB_Constant)
    #PB_Event_Custom = 65536
  CompilerEndIf

  ; --- Work item operation codes ---
  #ORM_Op_Save     = 1
  #ORM_Op_FindById = 2
  #ORM_Op_Query    = 3
  #ORM_Op_Delete   = 4

  ; --- Custom event type codes (used in PostEvent / EventType()) ---
  #ORM_Event_SaveDone   = $1001
  #ORM_Event_LoadDone   = $1002
  #ORM_Event_QueryDone  = $1003
  #ORM_Event_DeleteDone = $1004
  #ORM_Event_Error      = $1005

  ; --- Work item: one unit of async work pushed to the queue ---
  Structure ORM_WorkItem
    operation.i       ; #ORM_Op_*
    entityPtr.i       ; *entity for Save / FindById / Delete
    entityType.s      ; "Client"
    recordId.i        ; For FindById
    whereClause.s     ; For Query (e.g. "WHERE isActive=1 ORDER BY companyName")
    serializeProc.i   ; For Save (serialize entity -> map)
    deserializeProc.i ; For FindById / Query (map -> entity fields)
    newEntityProc.i   ; For Query (create fresh entity per row)
    callbackPtr.i     ; Procedure(*entity, result.i) or (List, result.i)
    windowId.i        ; Window to receive PostEvent notification
  EndStructure

  ; --- Global query result list (shared between worker and UI callback) ---
  ; Protected by orm_queryResultMutex.
  Global NewList orm_queryResultList.i()     ; Holds *entity pointers
  Global orm_queryResultCode.i = 0           ; #ORM_Success or error
  Global orm_queryResultMutex.i              ; Locked while list is being read/written

  ; --- Initialize the worker pool ---
  ; dbPath.s   : path to the SQLite file (each worker opens its own connection)
  ; numWorkers : 1 to 4 parallel worker threads
  ; windowId   : main window handle to receive completion events
  Declare Init(dbPath.s, numWorkers.i = 2, windowId.i = 0)

  ; --- Shut down all workers gracefully (call before CloseDatabase) ---
  Declare Shutdown()

  ; --- Push a work item onto the queue ---
  Declare.b Enqueue(*workItem.ORM_WorkItem)

  ; --- Convenience wrappers: call these from the UI thread ---

  ; SaveAsync: save entity (with cascade children) in background
  ; Callback: Procedure OnSaved(*entity, result.i) : EndProcedure
  Declare SaveAsync(*entity, entityType.s, serializeProc.i, callbackPtr.i, windowId.i)

  ; FindByIdAsync: load one entity by id in background, fills *entity
  ; Callback: Procedure OnLoaded(*entity, result.i) : EndProcedure
  Declare FindByIdAsync(*entity, entityType.s, recordId.i, deserializeProc.i, callbackPtr.i, windowId.i)

  ; QueryAsync: load a list of entities in background
  ; Results are available in orm_queryResultList() inside the callback.
  ; Callback: Procedure OnQueryDone(result.i) : EndProcedure
  Declare QueryAsync(entityType.s, whereClause.s, newEntityProc.i, deserializeProc.i, callbackPtr.i, windowId.i)

  ; DeleteAsync: delete entity with FK enforcement in background
  ; Callback: Procedure OnDeleted(*entity, result.i) : EndProcedure
  Declare DeleteAsync(*entity, entityType.s, callbackPtr.i, windowId.i)

EndDeclareModule

Module ORM_AsyncWorker

  ; ---------------------------------------------------------------------------
  ; Internal state
  ; ---------------------------------------------------------------------------
  Global orm_dbPath.s
  Global orm_windowId.i
  Global orm_numWorkers.i

  Global orm_queueMutex.i
  Global orm_queueSemaphore.i
  Global NewList orm_workQueue.ORM_AsyncWorker::ORM_WorkItem()
  Global orm_shutdown.i = 0
  Global Dim orm_workerThreads.i(4)

  ; Initialize the shared query result mutex
  orm_queryResultMutex = CreateMutex()

  ; ---------------------------------------------------------------------------
  ; Worker thread: opens own DB connection, processes items from queue
  ; ---------------------------------------------------------------------------
  Procedure ORM_WorkerThread(*dummy)
    ; Each worker has its OWN database connection (thread-safe with WAL mode)
    Protected workerDb.i = OpenDatabase(#PB_Any, orm_dbPath, "", "", #PB_Database_SQLite)
    If Not IsDatabase(workerDb)
      Debug "ORM_AsyncWorker: WORKER FAILED to open DB: " + orm_dbPath
      ProcedureReturn
    EndIf
    ; Enable WAL mode on this worker's connection too
    ORM_Transaction::Execute(workerDb, "PRAGMA journal_mode=WAL;")
    ORM_Transaction::Execute(workerDb, "PRAGMA foreign_keys=ON;")
    Debug "ORM_AsyncWorker: Worker started (workerDb=" + Str(workerDb) + ")"

    Repeat
      ; Wait for a signal that work is available
      WaitSemaphore(orm_queueSemaphore)

      ; Shutdown signal
      If orm_shutdown = 1 : Break : EndIf

      ; Pop next item from queue (under mutex protection)
      Protected workItem.ORM_AsyncWorker::ORM_WorkItem
      LockMutex(orm_queueMutex)
        If ListSize(orm_workQueue()) > 0
          FirstElement(orm_workQueue())
          CopyStructure(@orm_workQueue(), @workItem, ORM_AsyncWorker::ORM_WorkItem)
          DeleteElement(orm_workQueue())
        EndIf
      UnlockMutex(orm_queueMutex)

      ; --- Execute the operation ---
      Protected eventCode.i = #ORM_Event_Error
      Protected result.i    = ORM_Entity::#ORM_Error_DbConnection

      Select workItem\operation

        ; ----- SAVE (with cascade children) -----
        Case #ORM_Op_Save
          result = ORM_Relations::SaveWithChildren(workerDb,
                                                   workItem\entityType,
                                                   workItem\entityPtr,
                                                   workItem\serializeProc)
          eventCode = #ORM_Event_SaveDone
          Debug "ORM_AsyncWorker: SaveAsync DONE for " + workItem\entityType +
                " -> result=" + Str(result)

        ; ----- FIND BY ID -----
        Case #ORM_Op_FindById
          result = ORM_CRUD::FindById(workerDb,
                                      workItem\entityType,
                                      workItem\recordId,
                                      workItem\entityPtr,
                                      workItem\deserializeProc)
          eventCode = #ORM_Event_LoadDone
          Debug "ORM_AsyncWorker: FindByIdAsync DONE id=" + Str(workItem\recordId) +
                " -> result=" + Str(result)

        ; ----- QUERY (list) -----
        Case #ORM_Op_Query
          ; Lock the shared result list while filling it
          LockMutex(orm_queryResultMutex)
            ClearList(orm_queryResultList())
            result = ORM_CRUD::Query(workerDb,
                                     workItem\entityType,
                                     workItem\whereClause,
                                     orm_queryResultList(),
                                     workItem\newEntityProc,
                                     workItem\deserializeProc)
            orm_queryResultCode = result
          UnlockMutex(orm_queryResultMutex)
          eventCode = #ORM_Event_QueryDone
          Debug "ORM_AsyncWorker: QueryAsync DONE for " + workItem\entityType +
                " -> " + Str(ListSize(orm_queryResultList())) + " row(s)"

        ; ----- DELETE (with FK enforcement) -----
        Case #ORM_Op_Delete
          result = ORM_Relations::DeleteWithFKCheck(workerDb,
                                                    workItem\entityType,
                                                    workItem\entityPtr)
          eventCode = #ORM_Event_DeleteDone
          Debug "ORM_AsyncWorker: DeleteAsync DONE for " + workItem\entityType +
                " -> result=" + Str(result)

      EndSelect

      ; --- Dispatch result to UI thread via PostEvent (thread-safe) ---
      ; EventType()   = eventCode (e.g. #ORM_Event_SaveDone)
      ; EventData()   = callbackPtr (the callback proc address)
      ; EventObject() = entityPtr (the *entity)
      ; The UI event loop must read these and call the callback:
      ;
      ;   Case #PB_Event_Custom
      ;     cb.i   = EventData()
      ;     ent.i  = EventObject()
      ;     Select EventType()
      ;       Case #ORM_Event_SaveDone   : CallFunctionFast(cb, ent, result)
      ;       Case #ORM_Event_LoadDone   : CallFunctionFast(cb, ent, result)
      ;       Case #ORM_Event_QueryDone  : CallFunctionFast(cb, result)
      ;       Case #ORM_Event_DeleteDone : CallFunctionFast(cb, ent, result)
      ;     EndSelect

      PostEvent(#PB_Event_Custom,
                workItem\windowId,
                eventCode,
                workItem\callbackPtr,  ; EventData()
                workItem\entityPtr)    ; EventObject()

    ForEver

    CloseDatabase(workerDb)
    Debug "ORM_AsyncWorker: Worker thread exiting."
  EndProcedure

  ; ---------------------------------------------------------------------------
  ; Init: start the worker thread pool
  ; ---------------------------------------------------------------------------
  Procedure Init(dbPath.s, numWorkers.i = 2, windowId.i = 0)
    orm_dbPath      = dbPath
    orm_windowId    = windowId
    If numWorkers < 1 : numWorkers = 1 : ElseIf numWorkers > 4 : numWorkers = 4 : EndIf
    orm_numWorkers  = numWorkers
    orm_shutdown    = 0
    orm_queueMutex     = CreateMutex()
    orm_queueSemaphore = CreateSemaphore()

    Protected i.i
    For i = 0 To orm_numWorkers - 1
      orm_workerThreads(i) = CreateThread(@ORM_WorkerThread(), 0)
    Next
    Debug "ORM_AsyncWorker: Pool started with " + Str(orm_numWorkers) + " worker(s)."
  EndProcedure

  ; ---------------------------------------------------------------------------
  ; Shutdown: signal workers to stop and wait for them
  ; ---------------------------------------------------------------------------
  Procedure Shutdown()
    orm_shutdown = 1
    Protected i.i
    For i = 0 To orm_numWorkers - 1
      SignalSemaphore(orm_queueSemaphore)   ; Wake each worker so it can exit
    Next
    For i = 0 To orm_numWorkers - 1
      If orm_workerThreads(i)
        WaitThread(orm_workerThreads(i))
      EndIf
    Next
    Debug "ORM_AsyncWorker: All workers stopped."
  EndProcedure

  ; ---------------------------------------------------------------------------
  ; Enqueue: push a work item onto the queue
  ; ---------------------------------------------------------------------------
  Procedure.b Enqueue(*workItem.ORM_AsyncWorker::ORM_WorkItem)
    LockMutex(orm_queueMutex)
      AddElement(orm_workQueue())
      CopyStructure(*workItem, @orm_workQueue(), ORM_AsyncWorker::ORM_WorkItem)
    UnlockMutex(orm_queueMutex)
    SignalSemaphore(orm_queueSemaphore)
    ProcedureReturn #True
  EndProcedure

  ; ---------------------------------------------------------------------------
  ; SaveAsync wrapper
  ; ---------------------------------------------------------------------------
  Procedure SaveAsync(*entity, entityType.s, serializeProc.i, callbackPtr.i, windowId.i)
    Protected item.ORM_AsyncWorker::ORM_WorkItem
    item\operation     = #ORM_Op_Save
    item\entityPtr     = *entity
    item\entityType    = entityType
    item\serializeProc = serializeProc
    item\callbackPtr   = callbackPtr
    item\windowId      = windowId
    Enqueue(@item)
  EndProcedure

  ; ---------------------------------------------------------------------------
  ; FindByIdAsync wrapper
  ; ---------------------------------------------------------------------------
  Procedure FindByIdAsync(*entity, entityType.s, recordId.i, deserializeProc.i, callbackPtr.i, windowId.i)
    Protected item.ORM_AsyncWorker::ORM_WorkItem
    item\operation       = #ORM_Op_FindById
    item\entityPtr       = *entity
    item\entityType      = entityType
    item\recordId        = recordId
    item\deserializeProc = deserializeProc
    item\callbackPtr     = callbackPtr
    item\windowId        = windowId
    Enqueue(@item)
  EndProcedure

  ; ---------------------------------------------------------------------------
  ; QueryAsync wrapper
  ; ---------------------------------------------------------------------------
  Procedure QueryAsync(entityType.s, whereClause.s, newEntityProc.i, deserializeProc.i, callbackPtr.i, windowId.i)
    Protected item.ORM_AsyncWorker::ORM_WorkItem
    item\operation       = #ORM_Op_Query
    item\entityType      = entityType
    item\whereClause     = whereClause
    item\newEntityProc   = newEntityProc
    item\deserializeProc = deserializeProc
    item\callbackPtr     = callbackPtr
    item\windowId        = windowId
    Enqueue(@item)
  EndProcedure

  ; ---------------------------------------------------------------------------
  ; DeleteAsync wrapper
  ; ---------------------------------------------------------------------------
  Procedure DeleteAsync(*entity, entityType.s, callbackPtr.i, windowId.i)
    Protected item.ORM_AsyncWorker::ORM_WorkItem
    item\operation   = #ORM_Op_Delete
    item\entityPtr   = *entity
    item\entityType  = entityType
    item\callbackPtr = callbackPtr
    item\windowId    = windowId
    Enqueue(@item)
  EndProcedure

EndModule

; =============================================================================
; EOF ORM_AsyncWorker.pbi
; =============================================================================


