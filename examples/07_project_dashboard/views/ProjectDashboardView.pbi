; ============================================================================
; Project Dashboard (WPF Modern UI) - Vue Fenêtre PureBasic OOP
; Fichier : views/ProjectDashboardView.pbi
; ============================================================================

XIncludeFile "../viewmodels/ProjectDashboardViewModel.pbi"

Namespace Dashboard {

  Class ProjectDashboardView Extends UI::Window {

    Public Method Init(*vm.Dashboard::ProjectDashboardViewModel) {
      Super\Init()

      Protected xmlPath.s = "views/ProjectDashboardView.xml"
      If FileSize(xmlPath) <= 0
        CompilerIf Defined(OOP_PROJECT_DIR, #PB_Constant)
          If FileSize(#OOP_PROJECT_DIR + xmlPath) > 0
            xmlPath = #OOP_PROJECT_DIR + xmlPath
          ElseIf FileSize(#OOP_PROJECT_DIR + "views/" + GetFilePart(xmlPath)) > 0
            xmlPath = #OOP_PROJECT_DIR + "views/" + GetFilePart(xmlPath)
          ElseIf FileSize(#OOP_PROJECT_DIR + GetFilePart(xmlPath)) > 0
            xmlPath = #OOP_PROJECT_DIR + GetFilePart(xmlPath)
          EndIf
        CompilerEndIf
        CompilerIf Defined(OOP_WORKSPACE_DIR, #PB_Constant)
          If FileSize(xmlPath) <= 0
            If FileSize(#OOP_WORKSPACE_DIR + "examples/07_project_dashboard/" + xmlPath) > 0
              xmlPath = #OOP_WORKSPACE_DIR + "examples/07_project_dashboard/" + xmlPath
            ElseIf FileSize(#OOP_WORKSPACE_DIR + xmlPath) > 0
              xmlPath = #OOP_WORKSPACE_DIR + xmlPath
            EndIf
          EndIf
        CompilerEndIf
        If FileSize(xmlPath) <= 0
          If FileSize("examples/07_project_dashboard/" + xmlPath) > 0
            xmlPath = "examples/07_project_dashboard/" + xmlPath
          ElseIf FileSize(GetPathPart(ProgramFilename()) + xmlPath) > 0
            xmlPath = GetPathPart(ProgramFilename()) + xmlPath
          ElseIf FileSize("ProjectDashboardView.xml") > 0
            xmlPath = "ProjectDashboardView.xml"
          EndIf
        EndIf
      EndIf

      This\LoadView(xmlPath, *vm)
    }

  }

}
