; ============================================================================
; PureBasic OOP GUI - MainWindow.pbi (Code-Behind for MainWindow.xml)
; ============================================================================

XIncludeFile "../../../ui/UI.pbi"

Namespace Demo {

  Class MainWindow Extends UI::Window {
    Protected *btnAdd.UI::Button
    Protected *btnNew.UI::Button
    Protected *btnSave.UI::Button
    Protected *btnSearch.UI::Button
    Protected *txtName.UI::TextBox
    Protected *txtSearch.UI::TextBox
    Protected *cboCategory.UI::ComboBox
    Protected *lstItems.UI::ListIcon
    Protected *lblStatus.UI::Label
    Protected *pbProgress.UI::ProgressBar
    Protected *toggleDark.UI::ToggleSwitch
    Protected *chkAutoRefresh.UI::CheckBox
    Protected itemCount.i

    Public Method Init() {
      Super::Init()
      This\itemCount = 0

      ; 1. Charge la vue déclarative XML
      Protected xmlFile.s = GetPathPart(ProgramFilename()) + "views/MainWindow.xml"
      If Not FileSize(xmlFile) > 0
        xmlFile = "views/MainWindow.xml"
      EndIf
      If Not FileSize(xmlFile) > 0
        xmlFile = "src/examples/xml_demo/views/MainWindow.xml"
      EndIf
      
      If Not This\LoadView(xmlFile)
        MessageRequester("Erreur", "Impossible de charger la vue XML: " + xmlFile)
        ProcedureReturn
      EndIf

      ; 2. Récupère les références des contrôles nommés
      This\*btnAdd = This\FindControl("btnAdd")
      This\*btnNew = This\FindControl("btnNew")
      This\*btnSave = This\FindControl("btnSave")
      This\*btnSearch = This\FindControl("btnSearch")
      This\*txtName = This\FindControl("txtName")
      This\*txtSearch = This\FindControl("txtSearch")
      This\*cboCategory = This\FindControl("cboCategory")
      This\*lstItems = This\FindControl("lstItems")
      This\*lblStatus = This\FindControl("lblStatus")
      This\*pbProgress = This\FindControl("pbProgress")
      This\*toggleDark = This\FindControl("toggleDark")
      This\*chkAutoRefresh = This\FindControl("chkAutoRefresh")

      ; 3. Initialise les données de test
      This\AddDemoItem("Button.pbi", "Composants UI", "Actif")
      This\AddDemoItem("XMLLoader.pbi", "Services Backend", "Actif")
      This\AddDemoItem("DockPanel.pbi", "Composants UI", "Actif")
      This\AddDemoItem("DarkTheme.pbi", "Thèmes", "Inactif")
    }

    Public Method AddDemoItem(nom.s, cat.s, statut.s) {
      This\itemCount + 1
      If (This\*lstItems) {
        Protected rowData.s = Str(This\itemCount) + Chr(10) + nom + Chr(10) + cat + Chr(10) + statut
        This\*lstItems\AddItem(-1, rowData, 0)
      }
    }

    Public Method OnChildEvent(*child.UI::Gadget, eventType.i) {
      If Not *child : ProcedureReturn : EndIf

      ; Clic sur Ajouter
      If (This\*btnAdd And *child\GetId() = This\*btnAdd\GetId())
        Protected nameVal.s = ""
        If (This\*txtName) : nameVal = Trim(This\*txtName\GetText()) : EndIf
        If nameVal = ""
          MessageRequester("Information", "Veuillez saisir un nom d'élément.")
          ProcedureReturn
        EndIf
        
        Protected catVal.s = "Général"
        If (This\*cboCategory) : catVal = This\*cboCategory\GetSelectedItem() : EndIf
        
        This\AddDemoItem(nameVal, catVal, "Nouveau")
        If (This\*txtName) : This\*txtName\SetText("") : EndIf
        If (This\*lblStatus) : This\*lblStatus\SetText("Élément '" + nameVal + "' ajouté avec succès!") : EndIf

      ; Clic sur Nouveau
      ElseIf (This\*btnNew And *child\GetId() = This\*btnNew\GetId())
        If (This\*lstItems) : This\*lstItems\Clear() : EndIf
        This\itemCount = 0
        If (This\*lblStatus) : This\*lblStatus\SetText("Liste réinitialisée.") : EndIf

      ; Clic sur Sauvegarder
      ElseIf (This\*btnSave And *child\GetId() = This\*btnSave\GetId())
        If (This\*lblStatus) : This\*lblStatus\SetText("Données sauvegardées avec succès.") : EndIf

      ; Clic sur Filtrer / Recherche
      ElseIf (This\*btnSearch And *child\GetId() = This\*btnSearch\GetId())
        Protected q.s = ""
        If (This\*txtSearch) : q = Trim(This\*txtSearch\GetText()) : EndIf
        If (This\*lblStatus) : This\*lblStatus\SetText("Filtre appliqué: '" + q + "'") : EndIf
      EndIf
    }
  }

}
