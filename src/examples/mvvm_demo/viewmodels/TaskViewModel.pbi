; ============================================================================
; PureBasic OOP MVVM Demo - TaskViewModel.pbi
; Presentation State, Observable Properties and Commands
; ============================================================================

XIncludeFile "../../../ui/UI.pbi"
XIncludeFile "../models/TaskModel.pbi"

; Forward command procedure declarations
Declare TaskViewModel_OnAddTask(*param)
Declare TaskViewModel_OnClearTasks(*param)
Declare TaskViewModel_OnRefresh(*param)
Declare TaskViewModel_OnExport(*param)

Global *CurrentTaskViewModel = 0

Namespace Demo::ViewModels {

  Class TaskViewModel Extends UI::MVVM::ViewModelBase {
    Protected *tasksCollection.UI::MVVM::ObservableCollection
    Protected taskCounter.i

    Public Method Init() {
      Super::Init()
      *CurrentTaskViewModel = This
      This\taskCounter = 0
      This\*tasksCollection = New UI::MVVM::ObservableCollection()

      ; 1. Initial State
      This\SetString("TaskInput", "")
      This\SetString("FilterQuery", "")
      This\SetString("Category", "Composants UI")
      This\SetString("StatusMessage", "Architecture MVVM active - Pret")
      This\SetString("TasksCountText", "0 taches")
      This\SetInt("ProgressValue", 60)
      This\SetBool("AutoRefresh", #True)
      This\SetBool("DarkMode", #True)

      ; 2. Register RelayCommands
      Protected *cmdAdd.UI::MVVM::RelayCommand = New UI::MVVM::RelayCommand(@TaskViewModel_OnAddTask())
      This\RegisterCommand("AddTaskCommand", *cmdAdd)

      Protected *cmdClear.UI::MVVM::RelayCommand = New UI::MVVM::RelayCommand(@TaskViewModel_OnClearTasks())
      This\RegisterCommand("ClearTasksCommand", *cmdClear)

      Protected *cmdRefresh.UI::MVVM::RelayCommand = New UI::MVVM::RelayCommand(@TaskViewModel_OnRefresh())
      This\RegisterCommand("RefreshCommand", *cmdRefresh)

      Protected *cmdExport.UI::MVVM::RelayCommand = New UI::MVVM::RelayCommand(@TaskViewModel_OnExport())
      This\RegisterCommand("ExportCommand", *cmdExport)

      ; 3. Initial Sample Data
      This\AddTask("ObservableObject.pbi", "Services MVVM")
      This\AddTask("RelayCommand.pbi", "Services MVVM")
      This\AddTask("TaskView.xml", "Vues Declaratives")
      This\AddTask("BindingEngine.pbi", "Moteur de Liaison")
    }

    Public Method.i GetTasksCollection() {
      ProcedureReturn This\*tasksCollection
    }

    Public Method AddTask(title.s, category.s) {
      If Trim(title) = "" : ProcedureReturn : EndIf
      This\taskCounter + 1
      Protected *item.Demo::Models::TaskItem = New Demo::Models::TaskItem(This\taskCounter, title, category)
      This\*tasksCollection\Add(*item\ToTableRow())
      This\UpdateCountText()
      This\SetString("StatusMessage", "Tache '" + title + "' ajoutee avec succes.")
    }

    Public Method UpdateCountText() {
      Protected cnt.i = This\*tasksCollection\Count()
      This\SetString("TasksCountText", Str(cnt) + " tache(s) enregistree(s)")
      This\SetInt("ProgressValue", cnt * 20)
    }

    Public Method ClearAllTasks() {
      This\*tasksCollection\Clear()
      This\taskCounter = 0
      This\UpdateCountText()
      This\SetString("StatusMessage", "Toutes les taches ont ete supprimees.")
    }

    Public Method HandleAddFromUI() {
      Protected inputTitle.s = Trim(This\GetString("TaskInput"))
      If inputTitle = ""
        This\SetString("StatusMessage", "Veuillez entrer un titre de tache.")
        ProcedureReturn
      EndIf
      Protected cat.s = This\GetString("Category")
      If cat = "" : cat = "General" : EndIf
      This\AddTask(inputTitle, cat)
      This\SetString("TaskInput", "")
    }

    Public Method Free() {
      If This\*tasksCollection
        This\*tasksCollection\Free()
      EndIf
      Super::Free()
    }
  }

}

Procedure TaskViewModel_OnAddTask(*param)
  If *CurrentTaskViewModel
    Protected *vm.Demo::ViewModels::TaskViewModel = *CurrentTaskViewModel
    *vm\HandleAddFromUI()
  EndIf
EndProcedure

Procedure TaskViewModel_OnClearTasks(*param)
  If *CurrentTaskViewModel
    Protected *vmClear.Demo::ViewModels::TaskViewModel = *CurrentTaskViewModel
    *vmClear\ClearAllTasks()
  EndIf
EndProcedure

Procedure TaskViewModel_OnRefresh(*param)
  If *CurrentTaskViewModel
    Protected *vmRef.Demo::ViewModels::TaskViewModel = *CurrentTaskViewModel
    *vmRef\SetString("StatusMessage", "Donnees synchronisees avec le ViewModel.")
  EndIf
EndProcedure

Procedure TaskViewModel_OnExport(*param)
  If *CurrentTaskViewModel
    Protected *vmExp.Demo::ViewModels::TaskViewModel = *CurrentTaskViewModel
    *vmExp\SetString("StatusMessage", "Exportation des donnees terminee.")
  EndIf
EndProcedure
