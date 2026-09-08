; ============================================================================
; TodoApp Application - Main Entry Point
; File: main.pb
; ============================================================================

EnableExplicit

; 1. Include Main View (UI & MVVM framework is auto-included by transpiler)
XIncludeFile "views/MainWindow.pbi"

; 2. Instantiate PureBasic OOP Application
Define *app.UI::Application = New UI::Application("TodoApp MVVM")

; 3. Instantiate ViewModel (Reactive state and business logic)
Define *vm.TodoApp::TaskViewModel = New TodoApp::TaskViewModel()

; 4. Instantiate View (Inject ViewModel into DataContext)
Define *mainWindow.TodoApp::MainWindow = New TodoApp::MainWindow(*vm)

; 5. Set main window and run event loop
*app\SetMainWindow(*mainWindow)
*app\Run()

; 6. Clean up application resources
*mainWindow\Free()
*vm\Free()
*app\Free()
