; ============================================================================
; PureBasic OOP MVVM Demo - TaskViewModel.pbi
; Presentation State, Observable Properties and Commands
; Author:      MicrodevWeb
; ============================================================================

XIncludeFile "../../../ui/UI.pbi"
XIncludeFile "../models/TaskModel.pbi"

Namespace Demo::ViewModels {

  Class TaskViewModel Extends UI::MVVM::ViewModelBase {
    Protected *tasksCollection.UI::MVVM::ObservableCollection
    Protected taskCounter.i

    Public Method Init() {
      Super::Init()
      This\taskCounter = 0
      This\*tasksCollection = New UI::MVVM::ObservableCollection()

      ; 1. Initial State
      This\Set("TaskInput", "")
      This\Set("FilterQuery", "")
      This\Set("Category", "UI Components")
      This\Set("StatusMessage", "MVVM Architecture active - Ready")
      This\Set("TasksCountText", "0 tasks")
      This\Set("ProgressValue", 60)
      This\Set("AutoRefresh", #True)
      This\Set("DarkMode", #True)

      ; 2. Initial Sample Data
      This\AddTask("ObservableObject.pbi", "MVVM Services")
      This\AddTask("RelayCommand.pbi", "MVVM Services")
      This\AddTask("TaskView.xml", "Declarative Views")
      This\AddTask("BindingEngine.pbi", "Binding Engine")
    }

    ; Direct virtual command dispatcher
    Public Method.b OnCommand(cmd.s, *param = 0) {
      Select cmd
        Case "AddTaskCommand", "AddTask", "OnAddTask"
          This\HandleAddFromUI()
          ProcedureReturn #True

        Case "ClearTasksCommand", "ClearTasks", "OnClearTasks"
          This\ClearAllTasks()
          ProcedureReturn #True

        Case "RefreshCommand", "Refresh", "OnRefresh"
          This\Set("StatusMessage", "Data synchronized with ViewModel.")
          ProcedureReturn #True

        Case "ExportCommand", "Export", "OnExport"
          This\Set("StatusMessage", "Data export completed.")
          ProcedureReturn #True
      EndSelect

      ProcedureReturn #False
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
      This\Set("StatusMessage", "Task '" + title + "' added successfully.")
    }

    Public Method UpdateCountText() {
      Protected cnt.i = This\*tasksCollection\Count()
      This\Set("TasksCountText", Str(cnt) + " task(s) recorded")
      This\Set("ProgressValue", cnt * 20)
    }

    Public Method ClearAllTasks() {
      This\*tasksCollection\Clear()
      This\taskCounter = 0
      This\UpdateCountText()
      This\Set("StatusMessage", "All tasks cleared.")
    }

    Public Method HandleAddFromUI() {
      Protected inputTitle.s = Trim(This\Get("TaskInput"))
      If inputTitle = ""
        This\Set("StatusMessage", "Please enter a task title.")
        ProcedureReturn
      EndIf
      Protected cat.s = This\Get("Category")
      If cat = "" : cat = "General" : EndIf
      This\AddTask(inputTitle, cat)
      This\Set("TaskInput", "")
    }

    Public Method Free() {
      If This\*tasksCollection
        This\*tasksCollection\Free()
      EndIf
      Super::Free()
    }
  }

}

