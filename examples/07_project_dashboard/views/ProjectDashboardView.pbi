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
        If FileSize("examples/07_project_dashboard/" + xmlPath) > 0
          xmlPath = "examples/07_project_dashboard/" + xmlPath
        ElseIf FileSize(GetPathPart(ProgramFilename()) + xmlPath) > 0
          xmlPath = GetPathPart(ProgramFilename()) + xmlPath
        ElseIf FileSize("ProjectDashboardView.xml") > 0
          xmlPath = "ProjectDashboardView.xml"
        EndIf
      EndIf

      This\LoadView(xmlPath, *vm)
    }

  }

}
