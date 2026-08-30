; ============================================================================
; Title:       ide_dlg_about.pb
; Description: About dialog window for PureBasic OOP IDE
; Author:      MicrodevWeb
; ============================================================================

EnableExplicit

#Dlg_About_Window = 500

; ----------------------------------------------------------------------------
; Procedure:   IDE_OpenAboutDialog
; Purpose:     Displays the About dialog window with version and credit info
; Parameters:  parentWindow.i - ID of the parent window for centering
; Return:      None
; ----------------------------------------------------------------------------
Procedure IDE_OpenAboutDialog(parentWindow.i)
  ; Check if window is already open
  If IsWindow(#Dlg_About_Window)
    SetActiveWindow(#Dlg_About_Window)
    ProcedureReturn
  EndIf
  
  Protected winW = 420, winH = 220
  OpenWindow(#Dlg_About_Window, 0, 0, winW, winH, "About PureBasic OOP IDE", #PB_Window_SystemMenu | #PB_Window_WindowCentered, WindowID(parentWindow))
  
  ; Application title and description labels
  TextGadget(#PB_Any, 20, 25, winW - 40, 30, "PureBasic OOP IDE & Toolchain v1.0", #PB_Text_Center)
  TextGadget(#PB_Any, 20, 60, winW - 40, 60, "Dedicated development environment for PureBasic OOP extension." + #CRLF$ + "Includes Scintilla coloring, autocomplete, block auto-closing, and F5 build.", #PB_Text_Center)
  TextGadget(#PB_Any, 20, 130, winW - 40, 20, "Developed by MicrodevWeb", #PB_Text_Center)
  
  ; Close button
  Protected btnOk = ButtonGadget(#PB_Any, (winW - 100) / 2, 165, 100, 30, "Close")
  
  ; Modal event loop
  Repeat
    Protected event = WaitWindowEvent()
    If event = #PB_Event_CloseWindow Or (event = #PB_Event_Gadget And EventGadget() = btnOk)
      Break
    EndIf
  ForEver
  
  CloseWindow(#Dlg_About_Window)
EndProcedure
