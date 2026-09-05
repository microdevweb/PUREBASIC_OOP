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
      Super\Init()
      This\itemCount = 0

      ; 1. Charge la vue declarative XML avec resolution de chemin multi-niveaux
      Protected xmlFile.s = #PB_Compiler_FilePath + "MainWindow.xml"
      If Not FileSize(xmlFile) > 0
        xmlFile = #PB_Compiler_FilePath + "views/MainWindow.xml"
      EndIf
      If Not FileSize(xmlFile) > 0
        xmlFile = GetPathPart(ProgramFilename()) + "views/MainWindow.xml"
      EndIf
      If Not FileSize(xmlFile) > 0
        xmlFile = GetPathPart(ProgramFilename()) + "MainWindow.xml"
      EndIf
      If Not FileSize(xmlFile) > 0
        xmlFile = "src/examples/xml_demo/views/MainWindow.xml"
      EndIf
      If Not FileSize(xmlFile) > 0
        xmlFile = "views/MainWindow.xml"
      EndIf
      
      Protected loaded.b = #False
      If FileSize(xmlFile) > 0
        loaded = This\LoadView(xmlFile)
      EndIf

      ; Si le fichier n'a pas ete trouve sur disque, charge le XML embarque par defaut
      If Not loaded
        Protected defaultXml.s = "<Window Title='PureBasic OOP - Demonstrateur XAML / XML UI' Width='720' Height='540'>" +
          "<DockPanel LastChildFill='true'>" +
          "  <StackPanel Dock='Top' Orientation='Horizontal' Spacing='10' Margin='10' Height='40'>" +
          "    <Button Name='btnNew' Text='Nouveau' Width='100' Height='32'/>" +
          "    <Button Name='btnSave' Text='Enregistrer' Width='100' Height='32'/>" +
          "    <TextBox Name='txtSearch' Placeholder='Rechercher...' Width='220' Height='30'/>" +
          "    <Button Name='btnSearch' Text='Filtrer' Width='80' Height='32'/>" +
          "  </StackPanel>" +
          "  <StackPanel Dock='Bottom' Orientation='Horizontal' Spacing='15' Margin='8,4' Height='32'>" +
          "    <Label Name='lblStatus' Text='Pret - Vue XAML/XML chargee' Width='320' Height='22'/>" +
          "    <ProgressBar Name='pbProgress' Value='75' Width='160' Height='20'/>" +
          "    <ToggleSwitch Name='toggleDark' Text='Mode Actif' Width='120' Height='24' Checked='true'/>" +
          "  </StackPanel>" +
          "  <StackPanel Dock='Left' Orientation='Vertical' Spacing='8' Margin='10,0' Width='140'>" +
          "    <Label Text='Actions Rapides' Height='20'/>" +
          "    <Button Name='btnAction1' Text='Synchroniser' Height='30'/>" +
          "    <Button Name='btnAction2' Text='Exporter CSV' Height='30'/>" +
          "    <CheckBox Name='chkAutoRefresh' Text='Auto-refresh' Checked='true' Height='24'/>" +
          "  </StackPanel>" +
          "  <Grid Rows='Auto,*' Columns='*,*' Margin='5' Dock='Fill'>" +
          "    <StackPanel Row='0' Column='0' ColumnSpan='2' Orientation='Horizontal' Spacing='10' Margin='0,0,0,10'>" +
          "      <Label Text='Nom:' Width='40' Height='24'/>" +
          "      <TextBox Name='txtName' Placeholder='Entrez un element...' Width='180' Height='26'/>" +
          "      <ComboBox Name='cboCategory' Items='Composants UI,Services Backend,Plugins,Themes' SelectedIndex='0' Width='160' Height='26'/>" +
          "      <Button Name='btnAdd' Text='Ajouter' Width='80' Height='28'/>" +
          "    </StackPanel>" +
          "    <ListIcon Name='lstItems' Row='1' Column='0' ColumnSpan='2' Columns='ID:50,Nom:200,Categorie:160,Statut:100' GridLines='true' FullRowSelect='true' Margin='0'/>" +
          "  </Grid>" +
          "</DockPanel>" +
          "</Window>"
        loaded = This\LoadViewFromString(defaultXml)
      EndIf

      If Not loaded
        MessageRequester("Erreur", "Impossible de charger la vue XML.")
        ProcedureReturn
      EndIf

      ; 2. Recupere les references des controles nommes
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

      ; 3. Initialise les donnees de test
      This\AddDemoItem("Button.pbi", "Composants UI", "Actif")
      This\AddDemoItem("XMLLoader.pbi", "Services Backend", "Actif")
      This\AddDemoItem("DockPanel.pbi", "Composants UI", "Actif")
      This\AddDemoItem("DarkTheme.pbi", "Themes", "Inactif")
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
          MessageRequester("Information", "Veuillez saisir un nom d'element.")
          ProcedureReturn
        EndIf
        
        Protected catVal.s = "General"
        If (This\*cboCategory) : catVal = This\*cboCategory\GetSelectedItem() : EndIf
        
        This\AddDemoItem(nameVal, catVal, "Nouveau")
        If (This\*txtName) : This\*txtName\SetText("") : EndIf
        If (This\*lblStatus) : This\*lblStatus\SetText("Element '" + nameVal + "' ajoute avec succes!") : EndIf

      ; Clic sur Nouveau
      ElseIf (This\*btnNew And *child\GetId() = This\*btnNew\GetId())
        If (This\*lstItems) : This\*lstItems\Clear() : EndIf
        This\itemCount = 0
        If (This\*lblStatus) : This\*lblStatus\SetText("Liste reinitialisee.") : EndIf

      ; Clic sur Sauvegarder
      ElseIf (This\*btnSave And *child\GetId() = This\*btnSave\GetId())
        If (This\*lblStatus) : This\*lblStatus\SetText("Donnees sauvegardees avec succes.") : EndIf

      ; Clic sur Filtrer / Recherche
      ElseIf (This\*btnSearch And *child\GetId() = This\*btnSearch\GetId())
        Protected q.s = ""
        If (This\*txtSearch) : q = Trim(This\*txtSearch\GetText()) : EndIf
        If (This\*lblStatus) : This\*lblStatus\SetText("Filtre applique: '" + q + "'") : EndIf
      EndIf
    }
  }

}
