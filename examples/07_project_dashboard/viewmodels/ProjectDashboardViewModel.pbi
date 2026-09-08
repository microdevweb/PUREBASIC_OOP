; ============================================================================
; Project Dashboard (WPF Modern UI) - Reactive MVVM ViewModel
; File: viewmodels/ProjectDashboardViewModel.pbi
; ============================================================================

XIncludeFile "../models/ProjectModel.pbi"

Namespace Dashboard {

  Class ProjectDashboardViewModel Extends MVVM::ViewModelBase {
    Public *model.Dashboard::ProjectModel
    
    ; Observable Properties DataBound to UI
    Public *ProjectName.MVVM::StringProperty
    Public *StartDate.MVVM::StringProperty
    Public *EndDate.MVVM::StringProperty
    Public *Priority.MVVM::StringProperty
    Public *Status.MVVM::StringProperty
    Public *Description.MVVM::StringProperty
    Public *SearchQuery.MVVM::StringProperty
    Public *StatusNotification.MVVM::StringProperty
    Public *ActiveNavTab.MVVM::StringProperty

    Public Method Init() {
      Super\Init()

      This\*model = New Dashboard::ProjectModel()

      ; Register observable properties
      This\*ProjectName        = This\BindString("ProjectName", This\*model\GetName())
      This\*StartDate          = This\BindString("StartDate", This\*model\GetStartDate())
      This\*EndDate            = This\BindString("EndDate", This\*model\GetEndDate())
      This\*Priority           = This\BindString("Priority", This\*model\GetPriority())
      This\*Status             = This\BindString("Status", This\*model\GetStatus())
      This\*Description        = This\BindString("Description", This\*model\GetDescription())
      This\*SearchQuery        = This\BindString("SearchQuery", "")
      This\*StatusNotification = This\BindString("StatusNotification", "Ready.")
      This\*ActiveNavTab       = This\BindString("ActiveNavTab", "Projects")
    }

    Public Method Free() {
      If This\*model
        This\*model\Free()
        This\*model = 0
      EndIf
      Super\Free()
    }

    ; --- UI Commands Processing (RelayCommands) ---
    Public Method.b OnCommand(cmdName.s, *param = 0) {
      Select cmdName
        ; Action: Save changes
        Case "CmdSaveChanges"
          Protected pName.s = Trim(This\*ProjectName\GetValue())
          If pName = ""
            This\*StatusNotification\SetValue("[!] Project name cannot be empty.")
            ProcedureReturn #True
          EndIf
          
          This\*model\SetName(pName)
          This\*model\SetStartDate(This\*StartDate\GetValue())
          This\*model\SetEndDate(This\*EndDate\GetValue())
          This\*model\SetDescription(This\*Description\GetValue())
          This\*StatusNotification\SetValue("[OK] Project '" + pName + "' saved successfully.")
          ProcedureReturn #True

        ; Action: Cancel changes
        Case "CmdCancel"
          This\*ProjectName\SetValue(This\*model\GetName())
          This\*StartDate\SetValue(This\*model\GetStartDate())
          This\*EndDate\SetValue(This\*model\GetEndDate())
          This\*Description\SetValue(This\*model\GetDescription())
          This\*StatusNotification\SetValue("Modifications cancelled.")
          ProcedureReturn #True

        ; Action: Delete project
        Case "CmdDelete"
          This\*ProjectName\SetValue("")
          This\*StartDate\SetValue("")
          This\*EndDate\SetValue("")
          This\*Description\SetValue("")
          This\*StatusNotification\SetValue("Project data reset.")
          ProcedureReturn #True

        ; Action: Add new project
        Case "CmdAddProject"
          This\*ProjectName\SetValue("New Project")
          This\*StartDate\SetValue("01/01/2027")
          This\*EndDate\SetValue("30/06/2027")
          This\*Description\SetValue("New project initialized...")
          This\*StatusNotification\SetValue("New project template created.")
          ProcedureReturn #True

        ; Action: Generate report
        Case "CmdGenerateReport"
          Protected curName.s = This\*ProjectName\GetValue()
          This\*StatusNotification\SetValue("Summary report generated for '" + curName + "'.")
          ProcedureReturn #True

        ; Actions: Sidebar Navigation
        Case "CmdNavDashboard"
          This\*ActiveNavTab\SetValue("Dashboard")
          This\*StatusNotification\SetValue("Navigation: Dashboard view.")
          ProcedureReturn #True

        Case "CmdNavProjects"
          This\*ActiveNavTab\SetValue("Projects")
          This\*StatusNotification\SetValue("Navigation: Projects view.")
          ProcedureReturn #True

        Case "CmdNavTasks"
          This\*ActiveNavTab\SetValue("Tasks")
          This\*StatusNotification\SetValue("Navigation: Tasks view.")
          ProcedureReturn #True

        Case "CmdNavAnalytics"
          This\*ActiveNavTab\SetValue("Analytics")
          This\*StatusNotification\SetValue("Navigation: Analytics view.")
          ProcedureReturn #True

        Case "CmdNavSettings"
          This\*ActiveNavTab\SetValue("Settings")
          This\*StatusNotification\SetValue("Navigation: Settings view.")
          ProcedureReturn #True

      EndSelect

      ProcedureReturn #False
    }
  }

}

; IDE Options = PureBasic 6.40 (Windows - x64)
; CursorPosition = 81
; FirstLine = 63
; EnableXP
; DPIAware