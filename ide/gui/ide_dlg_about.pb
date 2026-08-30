; ============================================================================
; Title:       ide_dlg_about.pb
; Description: Boîte de dialogue À propos
; Author:      Expert PureBasic OOP
; ============================================================================

EnableExplicit

#Dlg_About_Window = 500

Procedure IDE_OpenAboutDialog(parentWindow.i)
  If IsWindow(#Dlg_About_Window)
    SetActiveWindow(#Dlg_About_Window)
    ProcedureReturn
  EndIf
  
  Protected winW = 420, winH = 220
  OpenWindow(#Dlg_About_Window, 0, 0, winW, winH, "À propos de PureBasic OOP IDE", #PB_Window_SystemMenu | #PB_Window_WindowCentered, WindowID(parentWindow))
  
  TextGadget(#PB_Any, 20, 25, winW - 40, 30, "PureBasic OOP IDE & Toolchain v1.0", #PB_Text_Center)
  TextGadget(#PB_Any, 20, 60, winW - 40, 60, "Environnement de développement dédié à l'extension Objet PureBasic." + #CRLF$ + "Intègre la coloration Scintilla, l'autocomplétion avancée, l'auto-fermeture de blocs et la compilation native F5.", #PB_Text_Center)
  TextGadget(#PB_Any, 20, 130, winW - 40, 20, "Développé pour la communauté PureBasic OOP", #PB_Text_Center)
  
  Protected btnOk = ButtonGadget(#PB_Any, (winW - 100) / 2, 165, 100, 30, "Fermer")
  
  Repeat
    Protected event = WaitWindowEvent()
    If event = #PB_Event_CloseWindow Or (event = #PB_Event_Gadget And EventGadget() = btnOk)
      Break
    EndIf
  ForEver
  
  CloseWindow(#Dlg_About_Window)
EndProcedure
