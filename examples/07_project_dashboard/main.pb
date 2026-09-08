; ============================================================================
; Project Dashboard (WPF Modern UI) - Main Entry Point
; File: main.pb
; ============================================================================

EnableExplicit

; 1. Include Main View (UI & MVVM framework is auto-included by transpiler)
XIncludeFile "views/ProjectDashboardView.pbi"

; 2. Instantiate PureBasic OOP Application
Define *app.UI::Application = New UI::Application("Project Dashboard - [WPF_ModernUI_App]")

; 3. Instantiate ViewModel (Reactive state and business logic)
Define *vm.Dashboard::ProjectDashboardViewModel = New Dashboard::ProjectDashboardViewModel()

; 4. Instantiate View (Inject ViewModel into DataContext)
Define *view.Dashboard::ProjectDashboardView = New Dashboard::ProjectDashboardView(*vm)

; 5. Set main window and run event loop
*app\SetMainWindow(*view)
*app\Run()

; 6. Clean teardown
*view\Free()
*vm\Free()
*app\Free()

; IDE Options = PureBasic 6.40 (Windows - x64)
; CursorPosition = 23
; EnableXP
; DPIAware