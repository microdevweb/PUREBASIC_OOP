; =============================================================================
; 06_database_crm / main.pb
; PureBasic OOP Framework - Alpha 1.4 - Exemple ORM Complet
; =============================================================================
; Démontre l'utilisation du moteur ORM Phase 2:
;   - Définition d'entités (Client, Contact)
;   - Sérialisation / Désérialisation
;   - AutoMigrate (création automatique des tables)
;   - SaveAsync (INSERT/UPDATE + cascade children)
;   - QueryAsync (liste non-bloquante)
;   - FindByIdAsync (chargement non-bloquant)
;   - DeleteAsync (avec contrôle FK configurable)
;   - LockManager (verrous distribués)
;   - Retour thread -> UI via PostEvent
; =============================================================================

; --- Charger tout le framework ---
XIncludeFile "../../framework/database/ORM.pbi"

; =============================================================================
; DÉCLARATION DES CONSTANTES DB
; =============================================================================
; Sur SQLite : chemin du fichier
; Sur MySQL   : nom de la base / hôte / port / user / password (futur)
#DB_PATH      = "crm.db"    ; fichier SQLite créé dans le dossier courant
#DB_FILE_PATH = #DB_PATH    ; alias pour ORM_AsyncWorker

; =============================================================================
; ENTITÉS
; =============================================================================

; --- Client ---
Structure Client Extends ORM::ORM_EntityBase
  companyName.s
  email.s
  phone.s
  city.s
  isActive.i
EndStructure

; --- Contact (lié à un Client via clientId) ---
Structure Contact Extends ORM::ORM_EntityBase
  clientId.i
  firstName.s
  lastName.s
  email.s
  isPrimary.i
EndStructure

; =============================================================================
; SÉRIALISATION (entity -> map de strings pour SQL)
; =============================================================================

Procedure Client_Serialize(*entity.Client, Map values.s())
  values("companyName") = *entity\companyName
  values("email")       = *entity\email
  values("phone")       = *entity\phone
  values("city")        = *entity\city
  values("isActive")    = Str(*entity\isActive)
EndProcedure

Procedure Client_Deserialize(*entity.Client, Map values.s())
  *entity\companyName = values("companyName")
  *entity\email       = values("email")
  *entity\phone       = values("phone")
  *entity\city        = values("city")
  *entity\isActive    = Val(values("isActive"))
EndProcedure

Procedure.i Client_New()
  Protected *c.Client = AllocateStructure(Client)
  *c\orm_isNew   = #True
  *c\orm_isDirty = #False
  ProcedureReturn *c
EndProcedure

Procedure Contact_Serialize(*entity.Contact, Map values.s())
  values("clientId")  = Str(*entity\clientId)
  values("firstName") = *entity\firstName
  values("lastName")  = *entity\lastName
  values("email")     = *entity\email
  values("isPrimary") = Str(*entity\isPrimary)
EndProcedure

Procedure Contact_Deserialize(*entity.Contact, Map values.s())
  *entity\clientId  = Val(values("clientId"))
  *entity\firstName = values("firstName")
  *entity\lastName  = values("lastName")
  *entity\email     = values("email")
  *entity\isPrimary = Val(values("isPrimary"))
EndProcedure

Procedure.i Contact_New()
  Protected *c.Contact = AllocateStructure(Contact)
  *c\orm_isNew   = #True
  *c\orm_isDirty = #False
  ProcedureReturn *c
EndProcedure

; =============================================================================
; PROCÉDURE CASCADE : sauvegarde des contacts d'un client
; =============================================================================
; Cette procédure est enregistrée comme saveChildrenProc dans la relation.
; Elle est appelée automatiquement par ORM_Relations::SaveWithChildren
; après que le client parent a été sauvegardé.
;
; La liste de contacts à sauvegarder est stockée dans une variable globale
; orm_pendingContacts() qui est remplie avant l'appel async.
; Pour une application réelle, une Map<clientId, List<Contact>> est préférable.

Global NewList orm_pendingContacts.i()   ; liste de pointeurs *Contact

Procedure SaveClientContacts(*parent, db.i)
  Protected *c.Contact
  Protected parentId.i = 0
  ; Cast le parent pour récupérer l'id (écrit par INSERT avant cet appel)
  Protected *base.ORM_CRUD::ORM_EntityBase = *parent
  parentId = *base\id
  Debug "SaveClientContacts: saving contacts for clientId=" + Str(parentId)
  ForEach orm_pendingContacts()
    *c = orm_pendingContacts()
    If *c
      ; SaveOne force le clientId = parentId et choisit INSERT ou UPDATE
      ORM_CRUD::SaveOne(db, "Contact", *c, parentId, "clientId", @Contact_Serialize())
    EndIf
  Next
EndProcedure

; =============================================================================
; ENREGISTREMENT DES ENTITÉS (fait une seule fois au démarrage)
; =============================================================================

Procedure RegisterEntities()
  ; --- Champs Client ---
  NewList clientFields.ORM_Schema::ORM_FieldDef()
  With clientFields()
    AddElement(clientFields()) : \name = "id"          : \typeCode = #ORM_Entity::#ORM_Type_Integer
    AddElement(clientFields()) : \name = "companyName" : \typeCode = #ORM_Entity::#ORM_Type_String
    AddElement(clientFields()) : \name = "email"       : \typeCode = #ORM_Entity::#ORM_Type_String
    AddElement(clientFields()) : \name = "phone"       : \typeCode = #ORM_Entity::#ORM_Type_String
    AddElement(clientFields()) : \name = "city"        : \typeCode = #ORM_Entity::#ORM_Type_String
    AddElement(clientFields()) : \name = "isActive"    : \typeCode = #ORM_Entity::#ORM_Type_Bool
  EndWith

  ; --- Relation Client -> Contacts ---
  NewList clientRelations.ORM_Schema::ORM_RelationDef()
  AddElement(clientRelations())
  clientRelations()\childTable       = "contacts"
  clientRelations()\fkColumn         = "clientId"
  clientRelations()\cascadeSave      = #True
  clientRelations()\deletePolicy     = #ORM_Entity::#ORM_Restrict_Delete  ; défaut : bloquer si contacts existent
  clientRelations()\saveChildrenProc = @SaveClientContacts()

  ORM_Schema::RegisterEntity("Client", "clients",
                              clientFields(), clientRelations(),
                              @Client_Serialize(), @Client_Deserialize(), @Client_New())

  ; --- Champs Contact ---
  NewList contactFields.ORM_Schema::ORM_FieldDef()
  With contactFields()
    AddElement(contactFields()) : \name = "id"        : \typeCode = #ORM_Entity::#ORM_Type_Integer
    AddElement(contactFields()) : \name = "clientId"  : \typeCode = #ORM_Entity::#ORM_Type_Integer : \isFK = #True : \fkTable = "clients"
    AddElement(contactFields()) : \name = "firstName" : \typeCode = #ORM_Entity::#ORM_Type_String
    AddElement(contactFields()) : \name = "lastName"  : \typeCode = #ORM_Entity::#ORM_Type_String
    AddElement(contactFields()) : \name = "email"     : \typeCode = #ORM_Entity::#ORM_Type_String
    AddElement(contactFields()) : \name = "isPrimary" : \typeCode = #ORM_Entity::#ORM_Type_Bool
  EndWith

  ; Contact n'a pas de sous-enfants
  NewList contactRelations.ORM_Schema::ORM_RelationDef()

  ORM_Schema::RegisterEntity("Contact", "contacts",
                              contactFields(), contactRelations(),
                              @Contact_Serialize(), @Contact_Deserialize(), @Contact_New())

EndProcedure

; =============================================================================
; CALLBACKS UI (appelés depuis le thread principal via PostEvent)
; =============================================================================

Global *g_currentClient.Client   ; client actuellement affiché
Global orm_mainDb.i              ; connexion principale (migration)
Global MainWindow.i
Global QueryList.i, StatusText.i, SaveBtn.i, LoadBtn.i, QueryBtn.i, DeleteBtn.i, LockBtn.i

#WinWidth  = 820
#WinHeight = 540

Procedure OnClientSaved(*entity, result.i)
  Protected msg.s
  If result = #ORM_Entity::#ORM_Success
    Protected *c.Client = *entity
    msg = "✓ Client sauvegardé: id=" + Str(*c\id) + " (" + *c\companyName + ")"
    SetGadgetText(StatusText, msg)
  Else
    SetGadgetText(StatusText, "✗ ERREUR sauvegarde (code=" + Str(result) + ")")
  EndIf
EndProcedure

Procedure OnClientLoaded(*entity, result.i)
  If result = #ORM_Entity::#ORM_Success
    Protected *c.Client = *entity
    SetGadgetText(StatusText, "✓ Client chargé: " + *c\companyName + " <" + *c\email + ">")
  Else
    SetGadgetText(StatusText, "✗ Client introuvable ou erreur DB.")
  EndIf
EndProcedure

Procedure OnQueryDone(result.i)
  If result <> #ORM_Entity::#ORM_Success
    SetGadgetText(StatusText, "✗ Erreur requête (code=" + Str(result) + ")")
    ProcedureReturn
  EndIf

  ; Lire la liste résultat sous mutex (thread-safe)
  LockMutex(ORM_AsyncWorker::orm_queryResultMutex)
    ClearGadgetItems(QueryList)
    Protected cnt.i = 0
    ForEach ORM_AsyncWorker::orm_queryResultList()
      Protected *c.Client = ORM_AsyncWorker::orm_queryResultList()
      If *c
        AddGadgetItem(QueryList, -1, Str(*c\id) + Chr(10) + *c\companyName + Chr(10) + *c\email + Chr(10) + *c\city)
        ; Libérer la mémoire (le worker a alloué via Client_New)
        FreeStructure(*c)
      EndIf
      cnt + 1
    Next
    ClearList(ORM_AsyncWorker::orm_queryResultList())
  UnlockMutex(ORM_AsyncWorker::orm_queryResultMutex)
  SetGadgetText(StatusText, "✓ Requête: " + Str(cnt) + " client(s) actifs chargés")
EndProcedure

Procedure OnClientDeleted(*entity, result.i)
  Select result
    Case #ORM_Entity::#ORM_Success
      SetGadgetText(StatusText, "✓ Client supprimé avec succès")
    Case #ORM_Entity::#ORM_Error_HasChildren
      SetGadgetText(StatusText, "✗ Suppression bloquée: ce client a encore des contacts")
    Default
      SetGadgetText(StatusText, "✗ Erreur suppression (code=" + Str(result) + ")")
  EndSelect
EndProcedure

; =============================================================================
; CONSTRUCTION DE L'INTERFACE
; =============================================================================

Procedure BuildUI()
  MainWindow = OpenWindow(#PB_Any, 0, 0, #WinWidth, #WinHeight,
                          "CRM Demo - ORM Alpha 1.4",
                          #PB_Window_SystemMenu | #PB_Window_ScreenCentered)

  ; -- Colonne gauche : formulaire client --
  TextGadget(#PB_Any, 10, 10, 100, 20, "Raison sociale:")
  Global InputCompany.i  = StringGadget(#PB_Any, 10, 30, 380, 25, "Acme SARL")
  TextGadget(#PB_Any, 10, 62, 100, 20, "Email:")
  Global InputEmail.i    = StringGadget(#PB_Any, 10, 82, 380, 25, "info@acme.fr")
  TextGadget(#PB_Any, 10, 114, 100, 20, "Téléphone:")
  Global InputPhone.i    = StringGadget(#PB_Any, 10, 134, 380, 25, "+33 1 00 00 00 00")
  TextGadget(#PB_Any, 10, 166, 100, 20, "Ville:")
  Global InputCity.i     = StringGadget(#PB_Any, 10, 186, 380, 25, "Paris")
  Global CheckActive.i   = CheckBoxGadget(#PB_Any, 10, 218, 200, 22, "Client actif")
  SetGadgetState(CheckActive, 1)

  ; -- Champ ID de recherche --
  TextGadget(#PB_Any, 10, 250, 120, 20, "Charger ID:")
  Global InputLoadId.i = StringGadget(#PB_Any, 135, 248, 80, 25, "1")

  ; -- Boutons --
  SaveBtn   = ButtonGadget(#PB_Any, 10,  280, 140, 32, "💾 Sauvegarder")
  LoadBtn   = ButtonGadget(#PB_Any, 160, 280, 140, 32, "📂 Charger")
  QueryBtn  = ButtonGadget(#PB_Any, 10,  320, 140, 32, "🔍 Clients actifs")
  DeleteBtn = ButtonGadget(#PB_Any, 160, 320, 140, 32, "🗑 Supprimer")
  LockBtn   = ButtonGadget(#PB_Any, 310, 280, 100, 72, "🔒 Verrouiller")

  ; -- Liste résultat droite --
  Protected ListX.i = 420
  TextGadget(#PB_Any, ListX, 10, 380, 20, "Résultats requête:")
  QueryList = ListViewGadget(#PB_Any, ListX, 30, 380, 460)

  ; -- Barre de statut --
  StatusText = TextGadget(#PB_Any, 10, 500, 790, 28, "Prêt.")
  SetGadgetFont(StatusText, LoadFont(#PB_Any, "Consolas", 9))
EndProcedure

; =============================================================================
; PROGRAMME PRINCIPAL
; =============================================================================

; 1. Ouvrir la connexion principale (pour AutoMigrate)
orm_mainDb = OpenDatabase(#PB_Any, #DB_PATH, "", "", #PB_Database_SQLite)
If Not IsDatabase(orm_mainDb)
  MessageRequester("ORM CRM", "Impossible d'ouvrir la base SQLite: " + #DB_PATH, #PB_MessageRequester_Error)
  End
EndIf

; 2. Enregistrer les entités
RegisterEntities()

; 3. AutoMigrate (synchrone, une seule fois au démarrage)
If Not ORM_Schema::Migrate(orm_mainDb)
  MessageRequester("ORM CRM", "Erreur AutoMigrate", #PB_MessageRequester_Error)
  End
EndIf

; 4. Démarrer le pool de workers asynchrones
ORM_AsyncWorker::Init(#DB_FILE_PATH, 2, 0)

; 5. Créer le client courant (nouveau par défaut)
*g_currentClient = Client_New()

; 6. Construire l'UI
BuildUI()
ORM_AsyncWorker::orm_windowId = MainWindow

; =============================================================================
; BOUCLE ÉVÉNEMENTS
; =============================================================================

Repeat
  Protected ev.i = WaitWindowEvent()

  Select ev
    ; --- Événements boutons ---
    Case #PB_Event_Gadget
      Select EventGadget()

        ; ==== SAUVEGARDER ====
        Case SaveBtn
          *g_currentClient\companyName = GetGadgetText(InputCompany)
          *g_currentClient\email       = GetGadgetText(InputEmail)
          *g_currentClient\phone       = GetGadgetText(InputPhone)
          *g_currentClient\city        = GetGadgetText(InputCity)
          *g_currentClient\isActive    = GetGadgetState(CheckActive)
          *g_currentClient\orm_isDirty = #True

          ; Ajouter 2 contacts de démo (seulement si nouveau client)
          If *g_currentClient\orm_isNew
            ClearList(orm_pendingContacts())
            Protected *contact1.Contact = Contact_New()
            *contact1\firstName = "Jean"  : *contact1\lastName = "Dupont" : *contact1\email = "j.dupont@acme.fr" : *contact1\isPrimary = 1
            AddElement(orm_pendingContacts()) : orm_pendingContacts() = *contact1

            Protected *contact2.Contact = Contact_New()
            *contact2\firstName = "Marie" : *contact2\lastName = "Martin" : *contact2\email = "m.martin@acme.fr" : *contact2\isPrimary = 0
            AddElement(orm_pendingContacts()) : orm_pendingContacts() = *contact2
          EndIf

          SetGadgetText(StatusText, "⏳ Sauvegarde en cours...")
          ORM_AsyncWorker::SaveAsync(*g_currentClient, "Client",
                                     @Client_Serialize(), @OnClientSaved(), MainWindow)

        ; ==== CHARGER ====
        Case LoadBtn
          Protected loadId.i = Val(GetGadgetText(InputLoadId))
          If loadId > 0
            SetGadgetText(StatusText, "⏳ Chargement id=" + Str(loadId) + "...")
            ORM_AsyncWorker::FindByIdAsync(*g_currentClient, "Client", loadId,
                                           @Client_Deserialize(), @OnClientLoaded(), MainWindow)
          Else
            SetGadgetText(StatusText, "⚠ Entrez un ID valide")
          EndIf

        ; ==== REQUÊTE CLIENTS ACTIFS ====
        Case QueryBtn
          SetGadgetText(StatusText, "⏳ Requête en cours...")
          ORM_AsyncWorker::QueryAsync("Client", "WHERE isActive=1 ORDER BY companyName",
                                      @Client_New(), @Client_Deserialize(),
                                      @OnQueryDone(), MainWindow)

        ; ==== SUPPRIMER ====
        Case DeleteBtn
          If *g_currentClient\id > 0
            SetGadgetText(StatusText, "⏳ Suppression id=" + Str(*g_currentClient\id) + "...")
            ORM_AsyncWorker::DeleteAsync(*g_currentClient, "Client",
                                         @OnClientDeleted(), MainWindow)
          Else
            SetGadgetText(StatusText, "⚠ Aucun client chargé à supprimer")
          EndIf

        ; ==== VERROUILLER ====
        Case LockBtn
          If *g_currentClient\id > 0
            If ORM_LockManager::Lock(orm_mainDb, "Client", *g_currentClient\id, "PC01", "admin")
              SetGadgetText(StatusText, "🔒 Verrou acquis pour Client#" + Str(*g_currentClient\id))
            Else
              SetGadgetText(StatusText, "✗ Verrou refusé (record déjà verrouillé sur un autre poste)")
            EndIf
          Else
            SetGadgetText(StatusText, "⚠ Chargez un client avant de verrouiller")
          EndIf

      EndSelect

    ; --- Réponse asynchrone des workers ---
    Case #PB_Event_Custom
      Protected cb.i  = EventData()     ; adresse du callback
      Protected ent.i = EventObject()   ; *entity (0 pour QueryDone)

      Select EventType()
        Case #ORM_AsyncWorker::#ORM_Event_SaveDone
          ; Met à jour le formulaire si c'est notre client courant
          If ent = *g_currentClient
            Protected *sc.Client = *g_currentClient
            SetGadgetText(InputCompany, *sc\companyName)
          EndIf
          ; Appeler le callback UI (@OnClientSaved)
          CallFunctionFast(cb, ent, #ORM_Entity::#ORM_Success)

        Case #ORM_AsyncWorker::#ORM_Event_LoadDone
          If ent = *g_currentClient
            Protected *lc.Client = *g_currentClient
            SetGadgetText(InputCompany, *lc\companyName)
            SetGadgetText(InputEmail,   *lc\email)
            SetGadgetText(InputPhone,   *lc\phone)
            SetGadgetText(InputCity,    *lc\city)
            SetGadgetState(CheckActive,  *lc\isActive)
          EndIf
          CallFunctionFast(cb, ent, #ORM_Entity::#ORM_Success)

        Case #ORM_AsyncWorker::#ORM_Event_QueryDone
          ; Le code résultat est dans ORM_AsyncWorker::orm_queryResultCode
          CallFunctionFast(cb, ORM_AsyncWorker::orm_queryResultCode)

        Case #ORM_AsyncWorker::#ORM_Event_DeleteDone
          CallFunctionFast(cb, ent, #ORM_Entity::#ORM_Success)

        Case #ORM_AsyncWorker::#ORM_Event_Error
          SetGadgetText(StatusText, "✗ Erreur async inattendue")

      EndSelect

    ; --- Fermeture fenêtre ---
    Case #PB_Event_CloseWindow
      ; Libérer le verrou éventuel sur le client courant
      If *g_currentClient\id > 0
        ORM_LockManager::Release(orm_mainDb, "Client", *g_currentClient\id, "PC01")
      EndIf
      Break

  EndSelect

Until ev = #PB_Event_CloseWindow

; Arrêt propre
ORM_AsyncWorker::Shutdown()
CloseDatabase(orm_mainDb)
FreeStructure(*g_currentClient)
ClearList(orm_pendingContacts())

Debug "CRM Demo terminé proprement."
End

; =============================================================================
; EOF examples/06_database_crm/main.pb
; =============================================================================
