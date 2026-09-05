; ============================================================================
; PureBasic OOP GUI - XML / XAML UI Demo
; Main.pb - Application Entry Point
; ============================================================================

XIncludeFile "views/MainWindow.pbi"

; Initialisation de l'application OOP
Define *app.UI::Application = New UI::Application("XML UI Demo")

; Création de la fenêtre principale à partir de la vue XML
Define *mainWin.Demo::MainWindow = New Demo::MainWindow()

; Définition comme fenêtre principale et boucle d'événements
*app\SetMainWindow(*mainWin)
*app\Run()
