; =============================================================================
; ORM_Entity.pbi - Base class for all ORM-managed entities
; PureBasic OOP Framework - Alpha 1.4
; =============================================================================
; Every class that wants database persistence must:
;   Class MyEntity Extends ORM::Entity { ... }
; The ORM engine then manages id, dirty tracking, locking and async I/O.
; =============================================================================

XIncludeFile "IDatabaseEntity.pbi"
XIncludeFile "EntitySet.pbi"

DeclareModule ORM_Entity

  ; ---------------------------------------------------------------------------
  ; Lock result constants (returned by Entity\Lock())
  ; ---------------------------------------------------------------------------
  #ORM_Lock_Granted       = 0   ; Lock acquired successfully
  #ORM_Lock_AlreadyLocked = 1   ; Another station holds the lock
  #ORM_Lock_NotSaved      = 2   ; Cannot lock a record that was never saved (id=0)
  #ORM_Lock_Error         = 3   ; DB connection error

  ; ---------------------------------------------------------------------------
  ; Operation result constants (returned/passed to async callbacks)
  ; ---------------------------------------------------------------------------
  #ORM_Success               = 0
  #ORM_Error_NotFound        = 1
  #ORM_Error_HasChildren     = 2   ; RestrictDelete: parent has linked child records
  #ORM_Error_IdImmutable     = 3   ; Attempt to change the primary key after save
  #ORM_Error_DbConnection    = 4
  #ORM_Error_Constraint      = 5   ; FK or unique violation

  ; ---------------------------------------------------------------------------
  ; Cascade / Referential integrity policy constants
  ; ---------------------------------------------------------------------------
  #ORM_Cascade_Save    = 1   ; Save parent -> save all modified children (default)
  #ORM_Cascade_Delete  = 2   ; Delete parent -> delete all children first
  #ORM_Restrict_Delete = 3   ; Block parent delete if children exist (default)
  #ORM_SetNull_Delete  = 4   ; On parent delete: set children FK column to NULL
  #ORM_AllowOrphan     = 5   ; No FK enforcement at ORM level

  #Cascade_None        = 0
  #Cascade_Save        = 1
  #Cascade_Delete      = 2
  #Cascade_All         = 3

  ; ---------------------------------------------------------------------------
  ; Relation type constants
  ; ---------------------------------------------------------------------------
  #ORM_Rel_OneToMany   = 1
  #ORM_Rel_ManyToOne   = 2
  #ORM_Rel_ManyToMany  = 3
  #ORM_Rel_OneToOne    = 4
  ; ---------------------------------------------------------------------------
  ; Field type codes (used in metadata)
  ; ---------------------------------------------------------------------------
  #ORM_Type_Integer = 1   ; .i or .l
  #ORM_Type_String  = 2   ; .s
  #ORM_Type_Double  = 3   ; .d
  #ORM_Type_Float   = 4   ; .f
  #ORM_Type_Bool    = 5   ; .b  (stored as INTEGER 0/1)
  #ORM_Type_FK      = 6   ; foreign key column (auto-generated for child tables)

EndDeclareModule

Module ORM_Entity
EndModule

; =============================================================================
; ORM::Entity - Base class definition
; Every entity field below is managed by the ORM engine automatically.
; The developer's class simply extends this via: Class MyClass Extends ORM::Entity
; =============================================================================

; NOTE: In PureBasic OOP, the actual Class block is in the main ORM.pbi
; because the transpiler resolves inheritance at include-time.
; This file declares the shared constants and documents the contract.

; --- Entity Contract (what ORM::Entity provides to subclasses) ---
;
;  id.i            : Primary key. Auto-assigned on first save. READ-ONLY after save.
;  orm_isNew.b     : True if never saved to DB yet (id = 0)
;  orm_isDirty.b   : True if any field changed since last load/save
;  orm_tableName.s : The database table name (auto-derived from class name, lowercase)
;  orm_lockOwner.s : Station that holds the lock on this record ("" if unlocked)
;  orm_lockUser.s  : User name of lock holder
;  orm_lockSince.s : Human-readable lock time
;
;  Lock()          : Attempt to acquire an exclusive edit lock. Returns #ORM_Lock_*
;  Unlock()        : Release the lock. Safe to call even if lock was not held.
;  IsLocked()      : Check lock status without acquiring. Returns #True/#False.
;  GetLockHolderInfo() : Returns "User on Machine since HH:MM" string
;
;  Save()          : Synchronous save (INSERT or UPDATE). Returns #ORM_Success or error.
;  SaveAsync(cb)   : Asynchronous save. Calls cb(*entity, result.i) on UI thread.
;  Delete()        : Synchronous delete. Respects cascade/restrict rules.
;  DeleteAsync(cb) : Asynchronous delete. Calls cb(result.i) on UI thread.
;  Reload()        : Reload all fields from DB (discards unsaved changes).

; =============================================================================
; EOF ORM_Entity.pbi
; =============================================================================
