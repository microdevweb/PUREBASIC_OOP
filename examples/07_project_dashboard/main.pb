; ============================================================================
; Project Dashboard (WPF Modern UI) - Point d'Entrée Principal
; Fichier : main.pb
; ============================================================================

EnableExplicit

; 1. Inclusion de la Vue Principale (Le Framework UI & MVVM est auto-inclus par le transpileur !)
XIncludeFile "views/ProjectDashboardView.pbi"

; 2. Instanciation de l'Application PureBasic OOP
Define *app.UI::Application = New UI::Application("Project Dashboard - [WPF_ModernUI_App]")

; 3. Instanciation du ViewModel (état réactif et logique métier)
Define *vm.Dashboard::ProjectDashboardViewModel = New Dashboard::ProjectDashboardViewModel()

; 4. Instanciation de la Vue (Injection du ViewModel en DataContext)
Define *view.Dashboard::ProjectDashboardView = New Dashboard::ProjectDashboardView(*vm)

; 5. Définition de la fenêtre principale et lancement de la boucle d'événements
*app\SetMainWindow(*view)
*app\Run()

; 6. Libération propre
*view\Free()
*vm\Free()
*app\Free()

; IDE Options = PureBasic 6.40 (Windows - x64)
; CursorPosition = 23
; EnableXP
; DPIAware