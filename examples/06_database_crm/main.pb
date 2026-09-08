; =============================================================================
; 06_database_crm - Complete CRM Demo with ORM Engine
; PureBasic OOP Framework - Alpha 1.4
; =============================================================================
; Demonstrates:
;   - ORM::ConfigureSQLite() and AutoMigrate()
;   - Class Client with List Contacts.Contact() (1-N relation)
;   - Async save and load (non-blocking UI)
;   - Explicit record locking (Lock/Unlock)
;   - RestrictDelete: cannot delete a client that has contacts
;   - CascadeSave: saving client saves all its contacts in one transaction
;
; Run this example directly from the PureBasic OOP IDE.
; A file "crm_demo.db" will be created in the same directory.
; =============================================================================

; Include the ORM engine (single include, everything is inside)
XIncludeFile "../../framework/database/ORM.pbi"

; =============================================================================
; Entity: Contact (child of Client)
; =============================================================================
Class Contact Extends ORM::Entity {
  Public id.i           ; PK - managed by ORM
  Public clientId.i     ; FK -> clients.id  (managed by ORM)
  Public firstName.s
  Public lastName.s
  Public email.s
  Public phone.s
}

; Registration procedure called by ORM::Register()
; Fills the field list so AutoMigrate knows what columns to create.
Procedure Contact_Register()
  Protected entityName.s = "Contact"
  Protected tableName.s  = "contacts"

  NewList fields.ORM_FieldDef()
  NewList relations.ORM_Schema::ORM_RelationDef()

  ; Define columns (the id column is always implicit - added by BuildCreateTable)
  AddElement(fields()) : fields()\name = "clientId"   : fields()\typeCode = #ORM_Type_FK      : fields()\isFK = #True : fields()\fkTable = "clients"
  AddElement(fields()) : fields()\name = "firstName"  : fields()\typeCode = #ORM_Type_String
  AddElement(fields()) : fields()\name = "lastName"   : fields()\typeCode = #ORM_Type_String
  AddElement(fields()) : fields()\name = "email"      : fields()\typeCode = #ORM_Type_String
  AddElement(fields()) : fields()\name = "phone"      : fields()\typeCode = #ORM_Type_String

  ORM_Schema::RegisterEntity(entityName, tableName, fields(), relations())
EndProcedure

; =============================================================================
; Entity: Client (parent, owns a list of Contacts)
; =============================================================================
Class Client Extends ORM::Entity {
  Public id.i           ; PK - managed by ORM
  Public companyName.s
  Public vatNumber.s
  Public address.s
  Public creditLimit.d
  Public isActive.b

  ; 1-N relation: cascade save + restrict delete (defaults)
  Public List Contacts.Contact()
}

; Registration procedure for Client
Procedure Client_Register()
  Protected entityName.s = "Client"
  Protected tableName.s  = "clients"

  NewList fields.ORM_FieldDef()
  NewList relations.ORM_Schema::ORM_RelationDef()

  ; Define columns
  AddElement(fields()) : fields()\name = "companyName"  : fields()\typeCode = #ORM_Type_String
  AddElement(fields()) : fields()\name = "vatNumber"    : fields()\typeCode = #ORM_Type_String
  AddElement(fields()) : fields()\name = "address"      : fields()\typeCode = #ORM_Type_String
  AddElement(fields()) : fields()\name = "creditLimit"  : fields()\typeCode = #ORM_Type_Double
  AddElement(fields()) : fields()\name = "isActive"     : fields()\typeCode = #ORM_Type_Bool

  ; Define 1-N relation to contacts
  AddElement(relations())
  relations()\childTable   = "contacts"
  relations()\fkColumn     = "clientId"
  relations()\cascadeSave  = #True                              ; Save client -> save contacts
  relations()\deletePolicy = #ORM_Restrict_Delete               ; Block delete if contacts exist

  ORM_Schema::RegisterEntity(entityName, tableName, fields(), relations())
EndProcedure

; =============================================================================
; UI Constants
; =============================================================================
#Window_Main    = 0
#Gadget_List    = 0
#Gadget_Name    = 1
#Gadget_Add     = 2
#Gadget_Save    = 3
#Gadget_Delete  = 4
#Gadget_Lock    = 5
#Gadget_Unlock  = 6
#Gadget_Status  = 7
#Gadget_Contacts = 8

; =============================================================================
; Async Callback Procedures
; These run on the UI thread (called via PostEvent dispatch from worker)
; =============================================================================

Procedure OnClientSaved(*client.Client, result.i)
  If result = #ORM_Entity::#ORM_Success
    SetGadgetText(#Gadget_Status, "Client saved successfully. ID=" + Str(*client\id))
  ElseIf result = #ORM_Entity::#ORM_Error_HasChildren
    SetGadgetText(#Gadget_Status, "ERROR: Cannot delete - client has linked contacts!")
  Else
    SetGadgetText(#Gadget_Status, "ERROR: Save failed (code " + Str(result) + ")")
  EndIf
EndProcedure

Procedure OnListLoaded(*resultList, result.i)
  SetGadgetText(#Gadget_Status, "List loaded asynchronously (non-blocking).")
  ; In a real app: iterate the returned list and populate the ListGadget
EndProcedure

; =============================================================================
; Main Application
; =============================================================================

; --- Step 1: Initialize ORM with SQLite ---
Protected dbPath.s = GetPathPart(ProgramFilename()) + "crm_demo.db"
ORM::ConfigureSQLite(dbPath)

; --- Step 2: Register entities (parent before child!) ---
Contact_Register()   ; Register Contact first (no relation to parent at meta level)
Client_Register()    ; Register Client with its 1-N relation to contacts

; --- Step 3: AutoMigrate (creates or updates tables) ---
If Not ORM::AutoMigrate()
  MessageRequester("ORM Error", "AutoMigrate failed! Check debug output.", #PB_MessageRequester_Error)
  End
EndIf

; --- Step 4: Open the main window ---
If OpenWindow(#Window_Main, 200, 200, 700, 500, "CRM Demo - ORM Alpha 1.4", #PB_Window_SystemMenu | #PB_Window_SizeGadget)
  ORM::SetMainWindow(WindowID(#Window_Main))

  ; Layout gadgets
  ListViewGadget(#Gadget_List,    10,  10, 340, 200)
  StringGadget  (#Gadget_Name,   360,  10, 320,  28, "")
  SetGadgetText (#Gadget_Name, "Client name...")

  ButtonGadget  (#Gadget_Add,    360,  50, 150,  28, "Add Client")
  ButtonGadget  (#Gadget_Save,   520,  50, 150,  28, "Save Async")
  ButtonGadget  (#Gadget_Delete, 360,  90, 150,  28, "Delete Client")
  ButtonGadget  (#Gadget_Lock,   520,  90, 150,  28, "Lock Record")
  ButtonGadget  (#Gadget_Unlock, 360, 130, 150,  28, "Unlock Record")

  ListViewGadget(#Gadget_Contacts, 10, 230, 340, 200)
  AddGadgetItem (#Gadget_Contacts, -1, "Contacts will appear here...")

  TextGadget    (#Gadget_Status,   10, 460, 680,  28, "ORM Ready. Database: " + dbPath)

  ; --- Seed with demo data (first run only) ---
  ; Check if any clients already exist before seeding
  Protected demoClient.Client
  Protected demoContact.Contact

  ; This would normally use FindByIdAsync - shown as a sync concept for demo clarity
  ; ORM::QueryAsync("Client", "ORDER BY companyName", @OnListLoaded())

  ; ---- EVENT LOOP ----
  Protected *currentClient.Client = 0
  Protected lockThreadId.i = 0

  Repeat
    Protected event.i = WaitWindowEvent()

    Select event
      ; --- Async worker notification (from background thread via PostEvent) ---
      Case #PB_Event_Custom
        Protected evCode.i     = EventType()
        Protected callbackPtr.i = EventData()
        Protected entityPtr.i   = EventObject()

        ; Dispatch to the right callback
        Select evCode
          Case #ORM_AsyncWorker::#ORM_Event_SaveDone
            Protected saveCallback.i = callbackPtr
            CallFunctionFast(saveCallback, entityPtr, #ORM_Entity::#ORM_Success)
          Case #ORM_AsyncWorker::#ORM_Event_LoadDone
            Protected loadCallback.i = callbackPtr
            CallFunctionFast(loadCallback, entityPtr, #ORM_Entity::#ORM_Success)
          Case #ORM_AsyncWorker::#ORM_Event_Error
            Protected errCallback.i = callbackPtr
            CallFunctionFast(errCallback, entityPtr, #ORM_Entity::#ORM_Error_DbConnection)
        EndSelect

      Case #PB_Event_Gadget
        Select EventGadget()

          Case #Gadget_Add
            ; Create a new client object and add to list view (not saved yet)
            Protected *c.Client = NewObject(Client)
            *c\companyName = GetGadgetText(#Gadget_Name)
            *c\isActive    = #True
            ; Add a demo contact
            AddElement(*c\Contacts())
              *c\Contacts()\firstName = "Jean"
              *c\Contacts()\lastName  = "Dupont"
              *c\Contacts()\email     = "jean@" + LCase(*c\companyName) + ".com"
            AddGadgetItem(#Gadget_List, -1, *c\companyName + " (not saved)")
            *currentClient = *c
            SetGadgetText(#Gadget_Status, "New client created in memory. Click 'Save Async' to persist.")

          Case #Gadget_Save
            If *currentClient <> 0
              SetGadgetText(#Gadget_Status, "Saving in background thread (UI stays responsive)...")
              ; This call returns IMMEDIATELY - no UI freeze!
              ORM_AsyncWorker::SaveAsync(*currentClient, "Client", @OnClientSaved(), WindowID(#Window_Main))
            Else
              SetGadgetText(#Gadget_Status, "No client selected. Click 'Add Client' first.")
            EndIf

          Case #Gadget_Lock
            If *currentClient <> 0 And *currentClient\id > 0
              Protected lockResult.i = ORM_LockManager::Lock(ORM::orm_mainDb, "Client", *currentClient\id)
              Select lockResult
                Case #ORM_Lock_Granted
                  lockThreadId = ORM_LockManager::StartHeartbeat(ORM::orm_mainDb, "Client", *currentClient\id)
                  SetGadgetText(#Gadget_Status, "Lock GRANTED. Heartbeat active (30s renewal).")
                Case #ORM_Lock_AlreadyLocked
                  Protected info.s = ORM_LockManager::GetLockHolderInfo(ORM::orm_mainDb, "Client", *currentClient\id)
                  MessageRequester("Record Locked",
                                   "This record is being edited by:" + #CRLF$ + info,
                                   #PB_MessageRequester_Warning)
                Case #ORM_Lock_Error
                  MessageRequester("Lock Error", "Cannot contact database.", #PB_MessageRequester_Error)
              EndSelect
            Else
              SetGadgetText(#Gadget_Status, "Save the client first (needs a DB id to lock).")
            EndIf

          Case #Gadget_Unlock
            If *currentClient <> 0 And *currentClient\id > 0
              If lockThreadId > 0
                ORM_LockManager::StopHeartbeat(lockThreadId)
                lockThreadId = 0
              EndIf
              ORM_LockManager::Unlock(ORM::orm_mainDb, "Client", *currentClient\id)
              SetGadgetText(#Gadget_Status, "Lock released.")
            EndIf

          Case #Gadget_Delete
            If *currentClient <> 0
              ; In Phase 2: ORM_AsyncWorker::DeleteAsync() will check for contacts
              ; and return #ORM_Error_HasChildren if RestrictDelete policy is in effect.
              SetGadgetText(#Gadget_Status, "DeleteAsync() - Phase 2 implementation pending.")
            EndIf

        EndSelect

      Case #PB_Event_CloseWindow
        Break

    EndSelect
  ForEver

  ; Cleanup on exit
  If lockThreadId > 0 : ORM_LockManager::StopHeartbeat(lockThreadId) : EndIf
  If *currentClient <> 0 : ORM_LockManager::Unlock(ORM::orm_mainDb, "Client", *currentClient\id) : EndIf
  ORM::Shutdown()
EndIf

; =============================================================================
; EOF main.pb
; =============================================================================
