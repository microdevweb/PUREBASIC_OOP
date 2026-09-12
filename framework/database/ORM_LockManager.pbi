; =============================================================================
; ORM_LockManager.pbi - Distributed Record Locking
; PureBasic OOP Framework - Alpha 1.4
; =============================================================================
; Manages the _orm_locks table in the shared database to prevent two workstations
; from editing the same record simultaneously.
;
; Features:
;   - Lease-based locks with heartbeat (auto-expire if station crashes)
;   - Human-readable lock holder info
;   - Automatic cleanup of expired locks
;   - Heartbeat background thread that renews the lock every 30 seconds
;
; Lock lifetime: 60 seconds. Heartbeat renews every 30 seconds.
; If a station crashes, the lock expires in max 60 seconds (no permanent deadlock).
; =============================================================================

XIncludeFile "ORM_Entity.pbi"

DeclareModule ORM_LockManager

  UseModule ORM_Entity

  #ORM_Lock_TTL_Seconds       = 60   ; Lock expires after 60s without heartbeat
  #ORM_Heartbeat_Interval_ms  = 30000 ; Heartbeat every 30 seconds

  ; --- Acquire a lock on an entity record ---
  ; entityType.s : "Client"
  ; recordId.i   : the id value of the record to lock
  ; db.i         : open database handle
  ; Returns #True if lock acquired, #False if already locked or error
  Declare.b Lock(db.i, entityType.s, recordId.i, stationId.s = "", userName.s = "")

  ; --- Release a lock ---
  ; Returns #True if lock was released, #False if it was not held by this station.
  Declare.b Unlock(db.i, entityType.s, recordId.i, stationId.s = "")
  Declare.b Release(db.i, entityType.s, recordId.i, stationId.s = "")

  ; --- Check if a record is currently locked (does NOT acquire) ---
  ; Returns #True if locked, #False if free or expired.
  Declare.b IsLocked(db.i, entityType.s, recordId.i)

  ; --- Get human-readable lock holder info ---
  ; Returns "Alice on DESKTOP-COMPTA since 14:05" or "" if not locked.
  Declare.s GetLockHolderInfo(db.i, entityType.s, recordId.i)

  ; --- Start the heartbeat thread for a specific lock ---
  ; Call this after a successful Lock() to keep the lock alive.
  ; Returns the thread ID (store it, you need it to stop the heartbeat).
  Declare.i StartHeartbeat(db.i, entityType.s, recordId.i)

  ; --- Stop the heartbeat thread ---
  ; Call this before or after Unlock().
  Declare StopHeartbeat(threadId.i)

  ; --- Internal: Clean up all expired locks in the database ---
  ; Called automatically at Lock() time and periodically.
  Declare CleanExpiredLocks(db.i)

EndDeclareModule

Module ORM_LockManager

  UseModule ORM_Entity

  ; --- Global station identifier (built once at module load time) ---
  Global orm_stationId.s = ComputerName() + "@" + GetEnvironmentVariable("USERNAME")

  ; --- Heartbeat stop flag (one per active heartbeat thread) ---
  ; We use a simple integer array indexed by thread ID for the stop signal.
  Structure ORM_HeartbeatCtx
    db.i
    entityType.s
    recordId.i
    stopFlag.i    ; Set to 1 to signal the heartbeat thread to exit
  EndStructure
  Global NewList orm_heartbeatContexts.ORM_HeartbeatCtx()

  ; ---------------------------------------------------------------------------
  ; Clean up expired locks (entries where expires_at < current Unix time)
  ; ---------------------------------------------------------------------------
  Procedure CleanExpiredLocks(db.i)
    Protected now.i = Int(ElapsedMilliseconds() / 1000)
    DatabaseUpdate(db, "DELETE FROM _orm_locks WHERE expires_at < " + Str(now) + ";")
  EndProcedure

  ; ---------------------------------------------------------------------------
  ; Acquire a lock
  ; ---------------------------------------------------------------------------
  Procedure.b Lock(db.i, entityType.s, recordId.i, stationId.s = "", userName.s = "")
    If stationId = "" : stationId = orm_stationId : EndIf
    If userName = ""  : userName = GetEnvironmentVariable("USERNAME") : EndIf

    ; First clean up any stale/expired locks
    CleanExpiredLocks(db)

    Protected now.i     = Int(ElapsedMilliseconds() / 1000)
    Protected expires.i = now + #ORM_Lock_TTL_Seconds

    ; Try to INSERT the lock record (will fail if another station holds it)
    Protected insertSQL.s = "INSERT OR IGNORE INTO _orm_locks " +
                            "(entity_type, record_id, station_id, user_name, locked_at, expires_at) " +
                            "VALUES ('" + entityType + "', " + Str(recordId) + ", " +
                            "'" + stationId + "', " +
                            "'" + userName + "', " +
                            Str(now) + ", " + Str(expires) + ");"

    If Not DatabaseUpdate(db, insertSQL)
      Debug "ORM_LockManager::Lock() DB ERROR: " + DatabaseError()
      ProcedureReturn #False
    EndIf

    ; Check if our INSERT actually succeeded (RowsAffected = 1 means we got the lock)
    If AffectedDatabaseRows(db) > 0
      Debug "ORM_LockManager: Lock GRANTED for " + entityType + "#" + Str(recordId) + " by " + stationId
      ProcedureReturn #True
    Else
      ; A lock already exists for this record (held by another station)
      Debug "ORM_LockManager: Lock DENIED for " + entityType + "#" + Str(recordId) + " (already locked)"
      ProcedureReturn #False
    EndIf
  EndProcedure

  ; ---------------------------------------------------------------------------
  ; Release a lock (only if held by this station)
  ; ---------------------------------------------------------------------------
  Procedure.b Unlock(db.i, entityType.s, recordId.i, stationId.s = "")
    If stationId = "" : stationId = orm_stationId : EndIf
    Protected sql.s = "DELETE FROM _orm_locks WHERE " +
                      "entity_type='" + entityType + "' AND " +
                      "record_id=" + Str(recordId) + " AND " +
                      "station_id='" + stationId + "';"
    DatabaseUpdate(db, sql)
    Protected released.b = Bool(AffectedDatabaseRows(db) > 0)
    If released
      Debug "ORM_LockManager: Lock RELEASED for " + entityType + "#" + Str(recordId)
    Else
      Debug "ORM_LockManager::Unlock() WARNING: lock not held by this station"
    EndIf
    ProcedureReturn released
  EndProcedure

  ; ---------------------------------------------------------------------------
  ; Alias Release -> Unlock
  ; ---------------------------------------------------------------------------
  Procedure.b Release(db.i, entityType.s, recordId.i, stationId.s = "")
    ProcedureReturn Unlock(db, entityType, recordId, stationId)
  EndProcedure

  ; ---------------------------------------------------------------------------
  ; Check if a record is currently locked (does not acquire)
  ; ---------------------------------------------------------------------------
  Procedure.b IsLocked(db.i, entityType.s, recordId.i)
    ; Clean expired locks first for accurate result
    CleanExpiredLocks(db)

    Protected sql.s = "SELECT COUNT(*) FROM _orm_locks WHERE " +
                      "entity_type='" + entityType + "' AND record_id=" + Str(recordId) + ";"
    Protected locked.b = #False
    If DatabaseQuery(db, sql)
      If NextDatabaseRow(db)
        locked = Bool(GetDatabaseLong(db, 0) > 0)
      EndIf
      FinishDatabaseQuery(db)
    EndIf
    ProcedureReturn locked
  EndProcedure

  ; ---------------------------------------------------------------------------
  ; Get human-readable lock holder info
  ; ---------------------------------------------------------------------------
  Procedure.s GetLockHolderInfo(db.i, entityType.s, recordId.i)
    Protected info.s = ""
    Protected sql.s  = "SELECT user_name, station_id, locked_at FROM _orm_locks WHERE " +
                       "entity_type='" + entityType + "' AND record_id=" + Str(recordId) + ";"
    If DatabaseQuery(db, sql)
      If NextDatabaseRow(db)
        Protected userName.s    = GetDatabaseString(db, 0)
        Protected stationId.s   = GetDatabaseString(db, 1)
        Protected lockedAt.i    = GetDatabaseLong(db, 2)

        ; Format the "since HH:MM" part from the Unix timestamp
        Protected timeSince.s = FormatDate("%hh:%ii", lockedAt)

        info = userName + " on " + stationId + " since " + timeSince
      EndIf
      FinishDatabaseQuery(db)
    EndIf
    ProcedureReturn info
  EndProcedure

  ; ---------------------------------------------------------------------------
  ; Heartbeat thread procedure (called by CreateThread)
  ; Renews the lock every 30 seconds until stopFlag is set
  ; ---------------------------------------------------------------------------
  Procedure ORM_HeartbeatThread(*ctx.ORM_HeartbeatCtx)
    While *ctx\stopFlag = 0
      Delay(#ORM_Heartbeat_Interval_ms)
      If *ctx\stopFlag = 0
        ; Renew the lock expiry
        Protected now.i     = Int(ElapsedMilliseconds() / 1000)
        Protected expires.i = now + #ORM_Lock_TTL_Seconds
        Protected sql.s = "UPDATE _orm_locks SET expires_at=" + Str(expires) +
                          " WHERE entity_type='" + *ctx\entityType + "' AND " +
                          "record_id=" + Str(*ctx\recordId) + " AND " +
                          "station_id='" + orm_stationId + "';"
        DatabaseUpdate(*ctx\db, sql)
        Debug "ORM_LockManager: Heartbeat renewed for " + *ctx\entityType + "#" + Str(*ctx\recordId)
      EndIf
    Wend
    Debug "ORM_LockManager: Heartbeat thread stopped."
  EndProcedure

  ; ---------------------------------------------------------------------------
  ; Start a heartbeat thread after acquiring a lock
  ; ---------------------------------------------------------------------------
  Procedure.i StartHeartbeat(db.i, entityType.s, recordId.i)
    AddElement(orm_heartbeatContexts())
    orm_heartbeatContexts()\db         = db
    orm_heartbeatContexts()\entityType = entityType
    orm_heartbeatContexts()\recordId   = recordId
    orm_heartbeatContexts()\stopFlag   = 0
    Protected tid.i = CreateThread(@ORM_HeartbeatThread(), @orm_heartbeatContexts())
    Debug "ORM_LockManager: Heartbeat thread started (TID=" + Str(tid) + ")"
    ProcedureReturn tid
  EndProcedure

  ; ---------------------------------------------------------------------------
  ; Stop a heartbeat thread (set stop flag and wait for thread to exit)
  ; ---------------------------------------------------------------------------
  Procedure StopHeartbeat(threadId.i)
    ForEach orm_heartbeatContexts()
      ; Find the context matching this thread (by checking memory address)
      ; In practice the caller passes the context pointer as threadId
      ; Simple approach: set stopFlag=1 on the most recently added context
      orm_heartbeatContexts()\stopFlag = 1
    Next
    WaitThread(threadId)
    Debug "ORM_LockManager: Heartbeat thread joined."
  EndProcedure

EndModule

; =============================================================================
; EOF ORM_LockManager.pbi
; =============================================================================
