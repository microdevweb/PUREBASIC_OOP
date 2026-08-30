; ============================================================================
; Title:       pbo_ide.pb
; Description: Point d'entrée principal de l'IDE PureBasic OOP
; Author:      Expert PureBasic OOP
; ============================================================================

EnableExplicit

; Inclusion des modules structurés
XIncludeFile "config/ide_settings.pb"
XIncludeFile "editor/ide_scintilla.pb"
XIncludeFile "editor/ide_lexer.pb"
XIncludeFile "editor/ide_autocomplete.pb"
XIncludeFile "editor/ide_autoclose.pb"
XIncludeFile "compiler_bridge/ide_builder.pb"
XIncludeFile "compiler_bridge/ide_parser_symbols.pb"
XIncludeFile "gui/ide_dlg_settings.pb"
XIncludeFile "gui/ide_dlg_about.pb"
XIncludeFile "gui/ide_main_window.pb"

; ----------------------------------------------------------------------------
; Initialisation Globale
; ----------------------------------------------------------------------------
If Not IDE_InitScintilla()
  MessageRequester("Erreur Fatale", "Impossible d'initialiser le composant Scintilla.", #PB_MessageRequester_Error)
  End 1
EndIf

; Chargement des paramètres persistants
IDE_Settings_Load()

; Ouverture de la fenêtre principale
IDE_MainWindow_Open()

; ----------------------------------------------------------------------------
; Boucle Principale des Événements
; ----------------------------------------------------------------------------
Define Event.i, EventWin.i, EventGad.i, EventMen.i, Quit.b = #False

Repeat
  Event = WaitWindowEvent()
  EventWin = EventWindow()
  
  ; 1. Gestion des événements de la boîte de dialogue Paramètres
  If IsWindow(#Dlg_Settings_Window) And EventWin = #Dlg_Settings_Window
    If IDE_HandleSettingsEvents(Event, EventGadget())
      ; Les paramètres ont été mis à jour, réappliquer le thème et lexer sur l'éditeur
      IDE_ApplyThemeAndLexer(#Gadget_Scintilla_Editor)
      IDE_MainWindow_Log("Paramètres et coloration syntaxique mis à jour.", #False)
    EndIf
    Continue
  EndIf
  
  ; 2. Gestion des événements de la fenêtre principale
  Select Event
    Case #PB_Event_Menu
      EventMen = EventMenu()
      Select EventMen
        ; Fichier
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
          
        ; Édition
        Case #Menu_Edit_Autocomplete, #Shortcut_CtrlSpace
          IDE_TriggerAutocomplete(#Gadget_Scintilla_Editor, #True)
          
        ; Projet / Compilation F5
        Case #Menu_Build_Run, #Shortcut_F5
          IDE_MainWindow_Log("--- Démarrage de la compilation F5 ---", #False)
          Define srcCode.s = IDE_GetEditorText(#Gadget_Scintilla_Editor)
          IDE_BuildAndRun(srcCode, CurrentDocumentPath, @IDE_MainWindow_Log())
          
        Case #Menu_Build_TranspileOnly
          IDE_MainWindow_Log("--- Transpilation en cours ---", #False)
          IDE_MainWindow_UpdateSymbols()
          IDE_MainWindow_Log("Arbre des symboles actualisé.", #False)
          
        ; Aide
        Case #Menu_Help_About
          IDE_OpenAboutDialog(#Win_Main)
      EndSelect
      
    Case #PB_Event_Gadget
      EventGad = EventGadget()
      Select EventGad
        Case #Gadget_Tree_Symbols
          ; Clic sur un symbole dans l'arbre pour naviguer vers la ligne
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
        Define curW = WindowWidth(#Win_Main)
        Define curH = WindowHeight(#Win_Main)
        ResizeGadget(#Gadget_Splitter_Main, 0, 0, curW, curH - 30)
      EndIf
      
    Case #PB_Event_CloseWindow
      If EventWin = #Win_Main
        Quit = #True
      EndIf
  EndSelect
  
Until Quit = #True

End 0
