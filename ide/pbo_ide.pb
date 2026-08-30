; ============================================================================
; Title:       pbo_ide.pb
; Description: Main entry point for PureBasic OOP IDE application
; Author:      MicrodevWeb
; ============================================================================

EnableExplicit

; Include modular components (.pbi)
XIncludeFile "config/ide_settings.pbi"
XIncludeFile "editor/ide_scintilla.pbi"
XIncludeFile "editor/ide_lexer.pbi"
XIncludeFile "editor/ide_autocomplete.pbi"
XIncludeFile "editor/ide_autoclose.pbi"
XIncludeFile "compiler_bridge/ide_builder.pbi"
XIncludeFile "compiler_bridge/ide_parser_symbols.pbi"
XIncludeFile "gui/ide_dlg_settings.pbi"
XIncludeFile "gui/ide_dlg_about.pbi"
XIncludeFile "gui/ide_main_window.pbi"

; ----------------------------------------------------------------------------
; Global Initialization
; ----------------------------------------------------------------------------
If Not IDE_InitScintilla()
  MessageRequester("Fatal Error", "Cannot initialize Scintilla editor component.", #PB_MessageRequester_Error)
  End 1
EndIf

; Load saved settings or defaults
IDE_Settings_Load()

; Create and display main application window
IDE_MainWindow_Open()

; ----------------------------------------------------------------------------
; Main Application Event Loop
; ----------------------------------------------------------------------------
Define Event.i, EventWin.i, EventGad.i, EventMen.i, Quit.b = #False

Repeat
  Event = WaitWindowEvent()
  EventWin = EventWindow()
  
  ; 1. Process Settings Dialog events if open
  If IsWindow(#Dlg_Settings_Window) And EventWin = #Dlg_Settings_Window
    If Event = #PB_Event_Gadget
      EventGad = EventGadget()
    Else
      EventGad = -1
    EndIf
    If IDE_HandleSettingsEvents(Event, EventGad)
      ; Settings were updated and saved, reapply theme & lexer to editor
      IDE_ApplyThemeAndLexer(#Gadget_Scintilla_Editor)
      IDE_MainWindow_Log("Settings and syntax colors updated.", #False)
    EndIf
    Continue
  EndIf
  
  ; 2. Process Main Window events
  Select Event
    Case #PB_Event_Menu
      EventMen = EventMenu()
      Select EventMen
        ; Menu and shortcut actions
        Case #Menu_File_New, #Shortcut_CtrlN
          IDE_MainWindow_NewFile()
        Case #Menu_File_Open, #Shortcut_CtrlO
          IDE_MainWindow_OpenFile()
        Case #Menu_File_Save, #Shortcut_CtrlS
          IDE_MainWindow_SaveFile(#False)
        Case #Menu_File_SaveAs
          IDE_MainWindow_SaveFile(#True)
        Case #Menu_File_Settings
          IDE_OpenSettingsDialog(#Win_Main)
        Case #Menu_File_Exit
          Quit = #True
          
        ; Edit menu
        Case #Menu_Edit_Autocomplete, #Shortcut_CtrlSpace
          IDE_TriggerAutocomplete(#Gadget_Scintilla_Editor, #True)
          
        ; Project menu / F5 Build
        Case #Menu_Build_Run, #Shortcut_F5
          IDE_MainWindow_Log("--- Starting F5 Build Pipeline ---", #False)
          Define srcCode.s = IDE_GetEditorText(#Gadget_Scintilla_Editor)
          IDE_BuildAndRun(srcCode, CurrentDocumentPath, @IDE_MainWindow_Log())
          
        Case #Menu_Build_TranspileOnly
          IDE_MainWindow_Log("--- Updating symbols outline ---", #False)
          IDE_MainWindow_UpdateSymbols()
          IDE_MainWindow_Log("Symbol outline tree refreshed.", #False)
          
        ; Help menu
        Case #Menu_Help_About
          IDE_OpenAboutDialog(#Win_Main)
      EndSelect
      
    Case #PB_Event_Gadget
      EventGad = EventGadget()
      Select EventGad
        ; Top Action Bar buttons
        Case #Btn_Top_New
          IDE_MainWindow_NewFile()
        Case #Btn_Top_Open
          IDE_MainWindow_OpenFile()
        Case #Btn_Top_Save
          IDE_MainWindow_SaveFile(#False)
        Case #Btn_Top_Run
          IDE_MainWindow_Log("--- Starting F5 Build Pipeline ---", #False)
          srcCode = IDE_GetEditorText(#Gadget_Scintilla_Editor)
          IDE_BuildAndRun(srcCode, CurrentDocumentPath, @IDE_MainWindow_Log())
        Case #Btn_Top_Settings
          IDE_OpenSettingsDialog(#Win_Main)
          
        Case #Gadget_Tree_Symbols
          ; Click on tree node to jump to line in editor
          If EventType() = #PB_EventType_LeftClick
            Define selItem = GetGadgetState(#Gadget_Tree_Symbols)
            If selItem > 0
              Define itemText.s = GetGadgetItemText(#Gadget_Tree_Symbols, selItem)
              ForEach IDE_FoundSymbols()
                If FindString(itemText, IDE_FoundSymbols()\name)
                  Define targetLine = IDE_FoundSymbols()\line - 1
                  Define targetPos = IDE_SendSci(#Gadget_Scintilla_Editor, #SCI_POSITIONFROMLINE, targetLine)
                  IDE_SendSci(#Gadget_Scintilla_Editor, #SCI_SETCURRENTPOS, targetPos)
                  IDE_SendSci(#Gadget_Scintilla_Editor, #SCI_SETSEL, targetPos, targetPos)
                  SetActiveGadget(#Gadget_Scintilla_Editor)
                  Break
                EndIf
              Next
            EndIf
          EndIf
      EndSelect
      
    Case #PB_Event_SizeWindow
      If EventWin = #Win_Main
        IDE_MainWindow_ResizeLayout()
      EndIf
      
    Case #PB_Event_CloseWindow
      If EventWin = #Win_Main
        Quit = #True
      EndIf
  EndSelect
  
Until Quit = #True

End 0
