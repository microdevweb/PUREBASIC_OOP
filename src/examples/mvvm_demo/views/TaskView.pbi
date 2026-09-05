; ============================================================================
; PureBasic OOP MVVM Demo - TaskView.pbi
; Minimal Code-Behind View for TaskView.xml
; ============================================================================

XIncludeFile "../../../ui/UI.pbi"
XIncludeFile "../viewmodels/TaskViewModel.pbi"

Namespace Demo::Views {

  Class TaskView Extends UI::Window {
    Protected *viewModel.Demo::ViewModels::TaskViewModel

    Public Method Init(*vm.Demo::ViewModels::TaskViewModel) {
      Super::Init()
      This\*viewModel = *vm

      ; 1. Resout le chemin du fichier XML
      Protected xmlFile.s = #PB_Compiler_FilePath + "TaskView.xml"
      If Not FileSize(xmlFile) > 0
        xmlFile = #PB_Compiler_FilePath + "views/TaskView.xml"
      EndIf
      If Not FileSize(xmlFile) > 0
        xmlFile = GetPathPart(ProgramFilename()) + "views/TaskView.xml"
      EndIf
      If Not FileSize(xmlFile) > 0
        xmlFile = GetPathPart(ProgramFilename()) + "TaskView.xml"
      EndIf
      If Not FileSize(xmlFile) > 0
        xmlFile = "src/examples/mvvm_demo/views/TaskView.xml"
      EndIf
      If Not FileSize(xmlFile) > 0
        xmlFile = "views/TaskView.xml"
      EndIf

      ; 2. Charge la vue declarative en injectant le DataContext (ViewModel)
      Protected loaded.b = #False
      If FileSize(xmlFile) > 0
        loaded = This\LoadView(xmlFile, *vm)
      EndIf

      If Not loaded
        ; Fallback XML embarque
        Protected defaultXml.s = "<Window Title='PureBasic OOP - Architecture MVVM &amp; DataBinding' Width='740' Height='560'>" +
          "<DockPanel LastChildFill='true'>" +
          "  <StackPanel Dock='Top' Orientation='Horizontal' Spacing='10' Margin='10' Height='40'>" +
          "    <Button Text='Rafraichir' Command='{Binding RefreshCommand}' Width='110' Height='32'/>" +
          "    <Button Text='Exporter' Command='{Binding ExportCommand}' Width='100' Height='32'/>" +
          "    <Button Text='Vider Liste' Command='{Binding ClearTasksCommand}' Width='110' Height='32'/>" +
          "    <TextBox Placeholder='Rechercher...' Text='{Binding Path=FilterQuery, Mode=TwoWay}' Width='220' Height='30'/>" +
          "  </StackPanel>" +
          "  <StackPanel Dock='Bottom' Orientation='Horizontal' Spacing='15' Margin='8,4' Height='32'>" +
          "    <Label Text='{Binding StatusMessage}' Width='320' Height='22'/>" +
          "    <ProgressBar Value='{Binding ProgressValue}' Width='160' Height='20'/>" +
          "    <ToggleSwitch Text='Mode Actif' Checked='{Binding DarkMode, Mode=TwoWay}' Width='120' Height='24'/>" +
          "  </StackPanel>" +
          "  <StackPanel Dock='Left' Orientation='Vertical' Spacing='8' Margin='10,0' Width='150'>" +
          "    <Label Text='Statistiques MVVM' Height='20'/>" +
          "    <Label Text='{Binding TasksCountText}' Height='20'/>" +
          "    <CheckBox Text='Auto-refresh' Checked='{Binding AutoRefresh, Mode=TwoWay}' Height='24'/>" +
          "  </StackPanel>" +
          "  <Grid Rows='Auto,*' Columns='*,*' Margin='5' Dock='Fill'>" +
          "    <StackPanel Row='0' Column='0' ColumnSpan='2' Orientation='Horizontal' Spacing='10' Margin='0,0,0,10'>" +
          "      <Label Text='Titre:' Width='45' Height='24'/>" +
          "      <TextBox Name='txtInput' Text='{Binding Path=TaskInput, Mode=TwoWay}' Placeholder='Entrez le titre d\\'une tache...' Width='220' Height='26'/>" +
          "      <ComboBox Name='cboCategory' Items='Composants UI,Services MVVM,Vues Declaratives,Moteur de Liaison' SelectedIndex='0' Width='170' Height='26'/>" +
          "      <Button Text='Ajouter' Command='{Binding AddTaskCommand}' Width='85' Height='28'/>" +
          "    </StackPanel>" +
          "    <ListIcon Name='lstTasks' Row='1' Column='0' ColumnSpan='2' Columns='ID:50,Titre:240,Categorie:160,Statut:100' GridLines='true' FullRowSelect='true' Margin='0'/>" +
          "  </Grid>" +
          "</DockPanel>" +
          "</Window>"
        loaded = This\LoadViewFromString(defaultXml, *vm)
      EndIf

      If Not loaded
        MessageRequester("Erreur", "Impossible de charger la vue TaskView.")
        ProcedureReturn
      EndIf

      ; 3. Lier la collection observable du ViewModel a la ListIcon
      Protected *lst.UI::Component = This\FindControl("lstTasks")
      If *lst And *vm
        Protected engine.UI::MVVM::BindingEngine
        engine\RegisterCollectionBinding(*lst, *vm\GetTasksCollection())
      EndIf
    }
  }

}
