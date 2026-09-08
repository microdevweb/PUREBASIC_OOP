; ============================================================================
; Application Gestionnaire de Taches (TodoApp) - ViewModel Reactif
; File: viewmodels/TaskViewModel.pbi
; ============================================================================

XIncludeFile "../constants/AppConstants.pbi"
XIncludeFile "../models/TaskModel.pbi"

Namespace TodoApp {

  Class TaskViewModel Extends MVVM::ViewModelBase {
    Public *TaskTitle.MVVM::StringProperty
    Public *TaskCount.MVVM::IntProperty
    Public *StatusMessage.MVVM::StringProperty
    Public *TaskListContent.MVVM::StringProperty

    ; --- Constructeur : Initialisation et enregistrement des proprietes ---
    Public Method Init() {
      Super\Init()
      
      ; Register observable properties dans le registre MVVM
      This\*TaskTitle       = This\BindString(#PROP_TASK_TITLE, "")
      This\*TaskCount       = This\BindInt(#PROP_TASK_COUNT, 0)
      This\*StatusMessage   = This\BindString(#PROP_STATUS_MSG, "Ready - No tasks recorded.")
      This\*TaskListContent = This\BindString(#PROP_LIST_CONTENT, "")
    }

    ; --- Gestionnaire des Commandes UI ---
    Public Method.b OnCommand(cmdName.s, *param = 0) {
      Select cmdName
        Case #CMD_ADD_TASK
          Protected title.s = Trim(This\*TaskTitle\GetValue())
          
          If title <> ""
            Protected currentCount.i = This\*TaskCount\GetValue() + 1
            
            ; Mise a jour des proprietes -> Notification automatique de la Vue !
            This\*TaskCount\SetValue(currentCount)
            This\*StatusMessage\SetValue("Task added successfully: '" + title + "'")
            
            Protected curList.s = This\*TaskListContent\GetValue()
            If curList <> "" : curList + #CRLF$ : EndIf
            curList + "- [" + Str(currentCount) + "] " + title
            This\*TaskListContent\SetValue(curList)
            
            ; Reinitialise le champ de saisie
            This\*TaskTitle\SetValue("")
            ProcedureReturn #True
          Else
            This\*StatusMessage\SetValue("Error: Please enter a task title.")
            ProcedureReturn #True
          EndIf

        Case #CMD_CLEAR_ALL
          This\*TaskCount\SetValue(0)
          This\*TaskTitle\SetValue("")
          This\*TaskListContent\SetValue("")
          This\*StatusMessage\SetValue("All tasks have been reset.")
          ProcedureReturn #True
      EndSelect
      
      ProcedureReturn #False
    }
  }

}
