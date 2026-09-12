; =============================================================================
; test_orm.pb - Tests unitaires du moteur ORM Alpha 1.4
; PureBasic OOP Framework - Tests Phase 1 + Phase 2
; =============================================================================
; Ouvrir ce fichier dans l'IDE PureBasic et appuyer sur F5.
; Les rÃ©sultats apparaissent dans la fenÃªtre Debug Output.
; =============================================================================

XIncludeFile "../framework/database/ORM.pbi"

; =============================================================================
; COMPTEURS DE TEST
; =============================================================================
Global g_pass.i  = 0
Global g_fail.i  = 0
Global g_total.i = 0

Macro Assert(condition, testName)
  g_total + 1
  If condition
    g_pass + 1
    Debug "[PASS] " + testName
  Else
    g_fail + 1
    Debug "[FAIL] *** " + testName + " ***"
  EndIf
EndMacro

; =============================================================================
; ENTITÃ‰S DE TEST
; =============================================================================

Structure Societe Extends ORM::ORM_EntityBase
  nom.s
  ville.s
  actif.i
EndStructure

Structure Employe Extends ORM::ORM_EntityBase
  societeId.i
  prenom.s
  actif.i
EndStructure

; ---------------------------------------------------------------------------
; SÃ©rialisation Societe
; ---------------------------------------------------------------------------
Procedure Societe_Serialize(*e.Societe, Map v.s())
  v("nom")   = *e\nom
  v("ville") = *e\ville
  v("actif") = Str(*e\actif)
EndProcedure

Procedure Societe_Deserialize(*e.Societe, Map v.s())
  *e\nom   = v("nom")
  *e\ville = v("ville")
  *e\actif = Val(v("actif"))
EndProcedure

Procedure.i Societe_New()
  Protected *s.Societe = AllocateStructure(Societe)
  *s\orm_isNew   = #True
  *s\orm_isDirty = #False
  ProcedureReturn *s
EndProcedure

; ---------------------------------------------------------------------------
; SÃ©rialisation Employe
; ---------------------------------------------------------------------------
Procedure Employe_Serialize(*e.Employe, Map v.s())
  v("societeId") = Str(*e\societeId)
  v("prenom")    = *e\prenom
  v("actif")     = Str(*e\actif)
EndProcedure

Procedure Employe_Deserialize(*e.Employe, Map v.s())
  *e\societeId = Val(v("societeId"))
  *e\prenom    = v("prenom")
  *e\actif     = Val(v("actif"))
EndProcedure

Procedure.i Employe_New()
  Protected *e.Employe = AllocateStructure(Employe)
  *e\orm_isNew   = #True
  *e\orm_isDirty = #False
  ProcedureReturn *e
EndProcedure

; =============================================================================
; CASCADE SAVE
; Attention : Protected doit Ãªtre AVANT ForEach, jamais Ã  l'intÃ©rieur du bloc
; =============================================================================
Global NewList g_pendingEmployes.i()

Procedure SaveSocieteEmployes(*parent, db.i)
  Protected *base.ORM_CRUD::ORM_EntityBase = *parent
  Protected parentId.i = *base\id
  Protected *emp.Employe    ; <- dÃ©claration AVANT la boucle
  ForEach g_pendingEmployes()
    *emp = g_pendingEmployes()
    If *emp
      ORM_CRUD::SaveOne(db, "Employe", *emp, parentId, "societeId", @Employe_Serialize())
    EndIf
  Next
EndProcedure

; =============================================================================
; ENREGISTREMENT DES ENTITÃ‰S
; =============================================================================
Procedure RegisterTestEntities(deletePolicy.i)
  Protected *r.ORM_Schema::ORM_RelationDef

  NewList fSoc.ORM_Schema::ORM_FieldDef()
  AddElement(fSoc()) : fSoc()\name = "id"    : fSoc()\typeCode = ORM_Entity::#ORM_Type_Integer
  AddElement(fSoc()) : fSoc()\name = "nom"   : fSoc()\typeCode = ORM_Entity::#ORM_Type_String
  AddElement(fSoc()) : fSoc()\name = "ville" : fSoc()\typeCode = ORM_Entity::#ORM_Type_String
  AddElement(fSoc()) : fSoc()\name = "actif" : fSoc()\typeCode = ORM_Entity::#ORM_Type_Bool

  NewList rSoc.ORM_Schema::ORM_RelationDef()
  AddElement(rSoc())
  rSoc()\childTable       = "employes"
  rSoc()\fkColumn         = "societeId"
  rSoc()\cascadeSave      = #True
  rSoc()\deletePolicy     = deletePolicy
  rSoc()\saveChildrenProc = @SaveSocieteEmployes()

  ORM_Schema::RegisterEntity("Societe", "societes",
                              fSoc(), rSoc(),
                              @Societe_Serialize(), @Societe_Deserialize(), @Societe_New())

  NewList fEmp.ORM_Schema::ORM_FieldDef()
  AddElement(fEmp()) : fEmp()\name = "id"        : fEmp()\typeCode = ORM_Entity::#ORM_Type_Integer
  AddElement(fEmp()) : fEmp()\name = "societeId" : fEmp()\typeCode = ORM_Entity::#ORM_Type_Integer : fEmp()\isFK = #True : fEmp()\fkTable = "societes"
  AddElement(fEmp()) : fEmp()\name = "prenom"    : fEmp()\typeCode = ORM_Entity::#ORM_Type_String
  AddElement(fEmp()) : fEmp()\name = "actif"     : fEmp()\typeCode = ORM_Entity::#ORM_Type_Bool

  NewList rEmp.ORM_Schema::ORM_RelationDef()

  ORM_Schema::RegisterEntity("Employe", "employes",
                              fEmp(), rEmp(),
                              @Employe_Serialize(), @Employe_Deserialize(), @Employe_New())
EndProcedure

; =============================================================================
; HELPERS TESTS : chaque test dans sa procÃ©dure pour Ã©viter les conflits
; de portÃ©e des variables Protected
; =============================================================================

; --- T01: ConfigureSQLite ---
Procedure Test_T01_Config()
  Assert(IsDatabase(ORM::orm_mainDb), "[T01] ConfigureSQLite - connexion ouverte")
EndProcedure

; --- T02: AutoMigrate ---
Procedure Test_T02_Migrate()
  Protected migOk.b = ORM_Schema::Migrate(ORM::orm_mainDb)
  Assert(migOk, "[T02] AutoMigrate - retourne #True")

  Protected found.b = #False
  If DatabaseQuery(ORM::orm_mainDb, "SELECT name FROM sqlite_master WHERE type='table' AND name='societes';")
    found = NextDatabaseRow(ORM::orm_mainDb)
    FinishDatabaseQuery(ORM::orm_mainDb)
  EndIf
  Assert(found, "[T02b] Table 'societes' crÃ©Ã©e en base")
EndProcedure

; --- T03: Idempotence ---
Procedure Test_T03_Idempotence()
  Protected migOk2.b = ORM_Schema::Migrate(ORM::orm_mainDb)
  Assert(migOk2, "[T03] AutoMigrate 2Ã¨me appel idempotent (sans erreur)")
EndProcedure

; --- T04: Insert ---
Global *g_soc1.Societe   ; partagÃ© entre tests

Procedure Test_T04_Insert()
  *g_soc1 = Societe_New()
  *g_soc1\nom   = "Dupont & Fils"
  *g_soc1\ville = "Lyon"
  *g_soc1\actif = 1
  Protected insertOk.b = ORM_CRUD::Insert(ORM::orm_mainDb, "Societe", *g_soc1, @Societe_Serialize())
  Assert(insertOk,            "[T04] Insert() retourne #True")
  Assert(*g_soc1\id > 0,     "[T04b] id auto-incrÃ©mentÃ© (id=" + Str(*g_soc1\id) + ")")
  Assert(*g_soc1\orm_isNew = #False, "[T04c] orm_isNew = #False aprÃ¨s Insert")
EndProcedure

; --- T05: FindById ---
Procedure Test_T05_FindById()
  Protected *load1.Societe = AllocateStructure(Societe)
  Protected res.i = ORM_CRUD::FindById(ORM::orm_mainDb, "Societe", *g_soc1\id, *load1, @Societe_Deserialize())
  Assert(res = ORM_Entity::#ORM_Success, "[T05] FindById retourne ORM_Success")
  Assert(*load1\nom   = "Dupont & Fils", "[T05b] nom = '" + *load1\nom + "'")
  Assert(*load1\ville = "Lyon",          "[T05c] ville = '" + *load1\ville + "'")
  Assert(*load1\id    = *g_soc1\id,      "[T05d] id = " + Str(*load1\id))
  FreeStructure(*load1)

  Protected *nf.Societe = AllocateStructure(Societe)
  Protected nfRes.i = ORM_CRUD::FindById(ORM::orm_mainDb, "Societe", 99999, *nf, @Societe_Deserialize())
  Assert(nfRes = ORM_Entity::#ORM_Error_NotFound, "[T05e] FindById id inexistant -> ORM_Error_NotFound")
  FreeStructure(*nf)
EndProcedure

; --- T06: Update ---
Procedure Test_T06_Update()
  *g_soc1\ville     = "Marseille"
  *g_soc1\orm_isDirty = #True
  Protected ok.b = ORM_CRUD::Update(ORM::orm_mainDb, "Societe", *g_soc1, @Societe_Serialize())
  Assert(ok, "[T06] Update() retourne #True")
  Assert(*g_soc1\orm_isDirty = #False, "[T06b] orm_isDirty = #False aprÃ¨s Update")

  Protected *rel.Societe = AllocateStructure(Societe)
  ORM_CRUD::FindById(ORM::orm_mainDb, "Societe", *g_soc1\id, *rel, @Societe_Deserialize())
  Assert(*rel\ville = "Marseille", "[T06c] Ville mise Ã  jour en base: '" + *rel\ville + "'")
  FreeStructure(*rel)
EndProcedure

; --- T07: Query ---
Global *g_soc2.Societe   ; sociÃ©tÃ© inactive, partagÃ©e pour T13

Procedure Test_T07_Query()
  *g_soc2 = Societe_New()
  *g_soc2\nom   = "Martin SA"
  *g_soc2\ville = "Paris"
  *g_soc2\actif = 0
  ORM_CRUD::Insert(ORM::orm_mainDb, "Societe", *g_soc2, @Societe_Serialize())

  NewList results.i()
  Protected res.i = ORM_CRUD::Query(ORM::orm_mainDb, "Societe", "WHERE actif=1",
                                    results(), @Societe_New(), @Societe_Deserialize())
  Assert(res = ORM_Entity::#ORM_Success, "[T07] Query retourne ORM_Success")
  Assert(ListSize(results()) = 1, "[T07b] Query WHERE actif=1 -> 1 rÃ©sultat (count=" + Str(ListSize(results())) + ")")

  ; LibÃ©rer les entitÃ©s allouÃ©es par Query
  Protected *qr.Societe
  ForEach results()
    *qr = results()
    If *qr : FreeStructure(*qr) : EndIf
  Next
  ClearList(results())
EndProcedure

; --- T08: SaveWithChildren (cascade) ---
Global *g_soc3.Societe
Global *g_emp1.Employe
Global *g_emp2.Employe

Procedure Test_T08_SaveWithChildren()
  *g_soc3        = Societe_New()
  *g_soc3\nom    = "Cascade SARL"
  *g_soc3\ville  = "Bordeaux"
  *g_soc3\actif  = 1

  *g_emp1         = Employe_New()
  *g_emp1\prenom  = "Alice"
  *g_emp1\actif   = 1

  *g_emp2         = Employe_New()
  *g_emp2\prenom  = "Bob"
  *g_emp2\actif   = 1

  ClearList(g_pendingEmployes())
  AddElement(g_pendingEmployes()) : g_pendingEmployes() = *g_emp1
  AddElement(g_pendingEmployes()) : g_pendingEmployes() = *g_emp2

  Protected res.i = ORM_Relations::SaveWithChildren(ORM::orm_mainDb, "Societe", *g_soc3, @Societe_Serialize())
  Assert(res = ORM_Entity::#ORM_Success, "[T08] SaveWithChildren retourne ORM_Success")
  Assert(*g_soc3\id > 0, "[T08b] Parent id assignÃ©: " + Str(*g_soc3\id))
  Assert(*g_emp1\id > 0, "[T08c] Enfant 1 id assignÃ©: " + Str(*g_emp1\id))
  Assert(*g_emp2\id > 0, "[T08d] Enfant 2 id assignÃ©: " + Str(*g_emp2\id))

  Protected *eLoaded.Employe = AllocateStructure(Employe)
  ORM_CRUD::FindById(ORM::orm_mainDb, "Employe", *g_emp1\id, *eLoaded, @Employe_Deserialize())
  Assert(*eLoaded\societeId = *g_soc3\id,
         "[T08e] Employe.societeId=" + Str(*eLoaded\societeId) + " == soc3.id=" + Str(*g_soc3\id))
  FreeStructure(*eLoaded)
EndProcedure

; --- T09: RestrictDelete ---
Procedure Test_T09_RestrictDelete()
  ; *g_soc3 a des enfants -> doit Ãªtre bloquÃ©
  Protected res.i = ORM_Relations::DeleteWithFKCheck(ORM::orm_mainDb, "Societe", *g_soc3)
  Assert(res = ORM_Entity::#ORM_Error_HasChildren, "[T09] RestrictDelete bloque (code=" + Str(res) + ")")

  Protected *chk.Societe = AllocateStructure(Societe)
  Protected chkRes.i = ORM_CRUD::FindById(ORM::orm_mainDb, "Societe", *g_soc3\id, *chk, @Societe_Deserialize())
  Assert(chkRes = ORM_Entity::#ORM_Success, "[T09b] Parent toujours prÃ©sent aprÃ¨s RestrictDelete bloquÃ©")
  FreeStructure(*chk)
EndProcedure

; --- T10: CascadeDelete ---
Procedure Test_T10_CascadeDelete()
  ; Changer la politique de la relation en CascadeDelete
  Protected *meta.ORM_Schema::ORM_EntityMeta = ORM_Schema::FindEntityMeta("Societe")
  If *meta
    FirstElement(*meta\relations())
    *meta\relations()\deletePolicy = ORM_Entity::#ORM_Cascade_Delete
  EndIf

  Protected res.i = ORM_Relations::DeleteWithFKCheck(ORM::orm_mainDb, "Societe", *g_soc3)
  Assert(res = ORM_Entity::#ORM_Success, "[T10] CascadeDelete retourne ORM_Success")

  Protected *sGone.Societe = AllocateStructure(Societe)
  Protected sgRes.i = ORM_CRUD::FindById(ORM::orm_mainDb, "Societe", *g_soc3\id, *sGone, @Societe_Deserialize())
  Assert(sgRes = ORM_Entity::#ORM_Error_NotFound, "[T10b] Parent supprimÃ© en base")
  FreeStructure(*sGone)

  Protected *eGone.Employe = AllocateStructure(Employe)
  Protected egRes.i = ORM_CRUD::FindById(ORM::orm_mainDb, "Employe", *g_emp1\id, *eGone, @Employe_Deserialize())
  Assert(egRes = ORM_Entity::#ORM_Error_NotFound, "[T10c] Enfant supprimÃ© en cascade")
  FreeStructure(*eGone)
EndProcedure

; --- T11: Lock + double lock ---
Procedure Test_T11_Lock()
  Protected ok1.b = ORM_LockManager::Lock(ORM::orm_mainDb, "Societe", *g_soc1\id, "PC01", "Alice")
  Assert(ok1, "[T11] Premier Lock acquis")

  Protected ok2.b = ORM_LockManager::Lock(ORM::orm_mainDb, "Societe", *g_soc1\id, "PC02", "Bob")
  Assert(ok2 = #False, "[T11b] Double Lock refusÃ© (autre poste)")
EndProcedure

; --- T12: Release + re-lock ---
Procedure Test_T12_Release()
  Protected relOk.b = ORM_LockManager::Release(ORM::orm_mainDb, "Societe", *g_soc1\id, "PC01")
  Assert(relOk, "[T12] Release OK")

  Protected ok3.b = ORM_LockManager::Lock(ORM::orm_mainDb, "Societe", *g_soc1\id, "PC02", "Bob")
  Assert(ok3, "[T12b] Re-Lock aprÃ¨s Release rÃ©ussi")
  ORM_LockManager::Release(ORM::orm_mainDb, "Societe", *g_soc1\id, "PC02")
EndProcedure

; --- T13: DeleteById direct ---
Procedure Test_T13_DeleteDirect()
  Protected ok.b = ORM_CRUD::DeleteById(ORM::orm_mainDb, "Societe", *g_soc2\id)
  Assert(ok, "[T13] DeleteById retourne #True")

  Protected *gone.Societe = AllocateStructure(Societe)
  Protected goneRes.i = ORM_CRUD::FindById(ORM::orm_mainDb, "Societe", *g_soc2\id, *gone, @Societe_Deserialize())
  Assert(goneRes = ORM_Entity::#ORM_Error_NotFound, "[T13b] Record supprimÃ© introuvable")
  FreeStructure(*gone)
EndProcedure

; --- T14: EscapeStr ---
Procedure Test_T14_EscapeStr()
  Protected esc.s = ORM_CRUD::EscapeStr("L'injecteur ; DROP TABLE societes; --")
  Assert(FindString(esc, "''") > 0, "[T14] EscapeStr double les apostrophes")
  Assert(Left(esc, 1) = "'",        "[T14b] EscapeStr encadre avec des quotes")
EndProcedure

; --- T15: ALTER TABLE (nouvelle colonne) ---
Procedure Test_T15_AlterTable()
  Protected *meta.ORM_Schema::ORM_EntityMeta = ORM_Schema::FindEntityMeta("Societe")
  If *meta
    AddElement(*meta\fields())
    *meta\fields()\name     = "pays"
    *meta\fields()\typeCode = ORM_Entity::#ORM_Type_String
  EndIf

  Protected migOk.b = ORM_Schema::Migrate(ORM::orm_mainDb)
  Assert(migOk, "[T15] AutoMigrate avec nouvelle colonne 'pays' OK")

  Protected found.b = #False
  If DatabaseQuery(ORM::orm_mainDb, "PRAGMA table_info(societes);")
    While NextDatabaseRow(ORM::orm_mainDb)
      If GetDatabaseString(ORM::orm_mainDb, 1) = "pays"
        found = #True
      EndIf
    Wend
    FinishDatabaseQuery(ORM::orm_mainDb)
  EndIf
  Assert(found, "[T15b] Colonne 'pays' prÃ©sente dans PRAGMA table_info(societes)")
EndProcedure

; =============================================================================
; MAIN - EXÃ‰CUTION
; =============================================================================
#TEST_DB = "test_orm.db"
DeleteFile(#TEST_DB)   ; repartir d'une base propre

Debug ""
Debug "=============================================="
Debug "  ORM Alpha 1.4 - Suite de Tests Unitaires  "
Debug "=============================================="
Debug ""

; Init DB
ORM::ConfigureSQLite(#TEST_DB)
RegisterTestEntities(ORM_Entity::#ORM_Restrict_Delete)

; Lancer les tests
Test_T01_Config()
Test_T02_Migrate()
Test_T03_Idempotence()
Test_T04_Insert()
Test_T05_FindById()
Test_T06_Update()
Test_T07_Query()
Test_T08_SaveWithChildren()
Test_T09_RestrictDelete()
Test_T10_CascadeDelete()
Test_T11_Lock()
Test_T12_Release()
Test_T13_DeleteDirect()
Test_T14_EscapeStr()
Test_T15_AlterTable()

; RÃ©sumÃ© final
Debug ""
Debug "=============================================="
Debug "  RÃ‰SULTATS: " + Str(g_pass) + " / " + Str(g_total) + " passÃ©s"
If g_fail > 0
  Debug "  Ã‰CHECS: " + Str(g_fail)
Else
  Debug "  Tous les tests passÃ©s âœ“"
EndIf
Debug "=============================================="

; LibÃ©ration mÃ©moire
If *g_soc1 : FreeStructure(*g_soc1) : EndIf
If *g_soc2 : FreeStructure(*g_soc2) : EndIf
If *g_soc3 : FreeStructure(*g_soc3) : EndIf
If *g_emp1 : FreeStructure(*g_emp1) : EndIf
If *g_emp2 : FreeStructure(*g_emp2) : EndIf
ORM::Shutdown()
Debug "Fichier DB de test: " + #TEST_DB
End

; =============================================================================
; EOF tests/test_orm.pb
; =============================================================================

