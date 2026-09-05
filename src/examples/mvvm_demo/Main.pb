; ============================================================================
; PureBasic OOP GUI Framework - MVVM Demo Application
; Main.pb - Application Entry Point
; ============================================================================

XIncludeFile "views/TaskView.pbi"

; 1. Initialisation de l'Application OOP
Define *app.UI::Application = New UI::Application("PureBasic OOP MVVM Demo")

; 2. Instanciation du ViewModel (Donnees et Logique)
Define *vm.Demo::ViewModels::TaskViewModel = New Demo::ViewModels::TaskViewModel()

; 3. Instanciation de la Vue (Injection du ViewModel)
Define *view.Demo::Views::TaskView = New Demo::Views::TaskView(*vm)

; 4. Execution de la boucle d'evenements
*app\SetMainWindow(*view)
*app\Run()
