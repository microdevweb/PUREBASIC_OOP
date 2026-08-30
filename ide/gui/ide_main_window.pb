; ============================================================================
; Title:       ide_main_window.pb
; Description: Fenêtre principale de l'IDE PureBasic OOP avec Scintilla, barre d'outils et console
; Author:      Expert PureBasic OOP
; ============================================================================

EnableExplicit

XIncludeFile "../config/ide_settings.pb"
XIncludeFile "../editor/ide_scintilla.pb"
XIncludeFile "../editor/ide_lexer.pb"
XIncludeFile "../editor/ide_autocomplete.pb"
XIncludeFile "../editor/ide_autoclose.pb"
XIncludeFile "../compiler_bridge/ide_builder.pb"
XIncludeFile "../compiler_bridge/ide_parser_symbols.pb"
XIncludeFile "ide_dlg_settings.pb"

Enumeration MainWidgets
  #Win_Main
  #Menu_Main
  
  ; Menus
  #Menu_File_New
  #Menu_File_Open
  #Menu_File_Save
  #Menu_File_SaveAs
  #Menu_File_Settings
  #Menu_File_Exit
  
  #Menu_Edit_Undo
  #Menu_Edit_Redo
  #Menu_Edit_Cut
  #Menu_Edit_Copy
  #Menu_Edit_Paste
  #Menu_Edit_SelectAll
  #Menu_Edit_Autocomplete
  
  #Menu_Build_Run
  #Menu_Build_TranspileOnly
  
  #Menu_Help_About
  
  ; Raccourcis
  #Shortcut_F5
  #Shortcut_CtrlSpace
  #Shortcut_CtrlS
  #Shortcut_CtrlO
  #Shortcut_CtrlN
  
  ; Gadgets UI
  #Toolbar_Main
  #Gadget_Splitter_Main
  #Gadget_Splitter_Side
  #Gadget_Tree_Symbols
  #Gadget_Scintilla_Editor
  #Gadget_List_Console
  #Gadget_Status_Bar
EndEnumeration

Global CurrentDocumentPath.s = ""
Global IsModified.b = #False

; Callback de logging pour la console inférieure
Procedure IDE_MainWindow_Log(message.s, isError.b)
  If IsGadget(#Gadget_List_Console)
    Protected prefix.s = FormatDate("[%hh:%ii:%ss] ", Date())
    AddGadgetItem(#Gadget_List_Console, -1, prefix + message)
    SendMessage_(GadgetID(#Gadget_List_Console), #WM_VSCROLL, #SB_BOTTOM, 0)
  EndIf
EndProcedure

Procedure IDE_MainWindow_UpdateTitle()
  Protected title.s = "PureBasic OOP IDE"
  If CurrentDocumentPath <> ""
    title + " - [" + GetFilePart(CurrentDocumentPath) + "]"
  Else
    title + " - [Sans titre.pbo]"
  EndIf
  If IsModified
    title + " *"
  EndIf
  SetWindowTitle(#Win_Main, title)
EndProcedure

Procedure IDE_MainWindow_UpdateSymbols()
  If IsGadget(#Gadget_Scintilla_Editor) And IsGadget(#Gadget_Tree_Symbols)
    Protected code.s = IDE_GetEditorText(#Gadget_Scintilla_Editor)
    IDE_ExtractSymbolsFromText(code)
    
    ClearGadgetItems(#Gadget_Tree_Symbols)
    Protected itemClasses = 0
    AddGadgetItem(#Gadget_Tree_Symbols, 0, "Classes & Méthodes", 0, 0)
    
    ForEach IDE_FoundSymbols()
      If IDE_FoundSymbols()\type = "Class"
        AddGadgetItem(#Gadget_Tree_Symbols, -1, "Class " + IDE_FoundSymbols()\name, 0, 1)
      ElseIf IDE_FoundSymbols()\type = "Method"
        AddGadgetItem(#Gadget_Tree_Symbols, -1, "  -> " + IDE_FoundSymbols()\name + "()", 0, 2)
      ElseIf IDE_FoundSymbols()\type = "Procedure"
        AddGadgetItem(#Gadget_Tree_Symbols, -1, "Procedure " + IDE_FoundSymbols()\name + "()", 0, 1)
      EndIf
    Next
    
    SetGadgetItemState(#Gadget_Tree_Symbols, 0, #PB_Tree_Expanded)
  EndIf
EndProcedure

Procedure IDE_MainWindow_NewFile()
  IDE_SetEditorText(#Gadget_Scintilla_Editor, "; Nouveau fichier PureBasic OOP (.pbo)" + #CRLF$ + "Class MonObjet" + #CRLF$ + "  Public Method Saluer()" + #CRLF$ + "    PrintN(" + Chr(34) + "Bonjour PureBasic OOP !" + Chr(34) + ")" + #CRLF$ + "  EndMethod" + #CRLF$ + "EndClass" + #CRLF$)
  CurrentDocumentPath = ""
  IsModified = #False
  IDE_MainWindow_UpdateTitle()
  IDE_MainWindow_UpdateSymbols()
  IDE_MainWindow_Log("Nouveau fichier créé.", #False)
EndProcedure

Procedure IDE_MainWindow_OpenFile(filePath.s = "")
  If filePath = ""
    filePath = OpenFileRequester("Ouvrir un fichier PureBasic OOP", GetCurrentDirectory(), "PureBasic OOP (*.pbo)|*.pbo|PureBasic (*.pb;*.pbi)|*.pb;*.pbi|Tous (*.*)|*.*", 0)
  EndIf
  
  If filePath <> ""
    Protected file = ReadFile(#PB_Any, filePath)
    If file
      Protected content.s = ""
      While Not Eof(file)
        content + ReadString(file, #PB_UTF8) + #CRLF$
      Wend
      CloseFile(file)
      
      IDE_SetEditorText(#Gadget_Scintilla_Editor, content)
      CurrentDocumentPath = filePath
      IsModified = #False
      Settings\LastOpenedFile = filePath
      IDE_Settings_Save()
      
      IDE_MainWindow_UpdateTitle()
      IDE_MainWindow_UpdateSymbols()
      IDE_MainWindow_Log("Fichier ouvert : " + filePath, #False)
    Else
      MessageRequester("Erreur", "Impossible de lire le fichier sélectionné.", #PB_MessageRequester_Error)
    EndIf
  EndIf
EndProcedure

Procedure IDE_MainWindow_SaveFile(saveAs.b = #False)
  If CurrentDocumentPath = "" Or saveAs
    CurrentDocumentPath = SaveFileRequester("Enregistrer le fichier PureBasic OOP", "MonScript.pbo", "PureBasic OOP (*.pbo)|*.pbo|Tous (*.*)|*.*", 0)
    If CurrentDocumentPath = "" : ProcedureReturn #False : EndIf
    If GetExtensionPart(CurrentDocumentPath) = ""
      CurrentDocumentPath + ".pbo"
    EndIf
  EndIf
  
  Protected file = CreateFile(#PB_Any, CurrentDocumentPath)
  If file
    Protected content.s = IDE_GetEditorText(#Gadget_Scintilla_Editor)
    WriteString(file, content, #PB_UTF8)
    CloseFile(file)
    IsModified = #False
    IDE_MainWindow_UpdateTitle()
    IDE_MainWindow_Log("Fichier enregistré avec succès : " + CurrentDocumentPath, #False)
    ProcedureReturn #True
  Else
    MessageRequester("Erreur", "Impossible d'enregistrer le fichier.", #PB_MessageRequester_Error)
    ProcedureReturn #False
  EndIf
EndProcedure

Procedure ScintillaCallback(gadgetId.i, *scNotification.SCNotification)
  Select *scNotification\nmhdr\code
    Case #SCN_CHARADDED
      Protected charAdded = *scNotification\ch
      ; 1. Auto-close paires et blocs
      IDE_HandleAutoClose(gadgetId, charAdded)
      
      ; 2. Déclenchement automatique de l'autocomplétion
      If (charAdded >= Asc("a") And charAdded <= Asc("z")) Or (charAdded >= Asc("A") And charAdded <= Asc("Z")) Or charAdded = Asc("_")
        IDE_TriggerAutocomplete(gadgetId, #False)
      EndIf
      
      IsModified = #True
      IDE_MainWindow_UpdateTitle()
      
    Case #SCN_MODIFIED
      IsModified = #True
  EndSelect
EndProcedure

Procedure IDE_MainWindow_Open()
  Protected winW = 1024, winH = 700
  OpenWindow(#Win_Main, 100, 100, winW, winH, "PureBasic OOP IDE", #PB_Window_SystemMenu | #PB_Window_SizeGadget | #PB_Window_MinimizeGadget | #PB_Window_MaximizeGadget | #PB_Window_ScreenCentered)
  
  ; --------------------------------------------------------------------------
  ; Barre de Menu
  ; --------------------------------------------------------------------------
  CreateMenu(#Menu_Main, WindowID(#Win_Main))
  MenuTitle("Fichier")
  MenuItem(#Menu_File_New, "Nouveau" + Chr(9) + "Ctrl+N")
  MenuItem(#Menu_File_Open, "Ouvrir..." + Chr(9) + "Ctrl+O")
  MenuItem(#Menu_File_Save, "Enregistrer" + Chr(9) + "Ctrl+S")
  MenuItem(#Menu_File_SaveAs, "Enregistrer sous...")
  MenuBar()
  MenuItem(#Menu_File_Settings, "Paramètres...")
  MenuBar()
  MenuItem(#Menu_File_Exit, "Quitter")
  
  MenuTitle("Édition")
  MenuItem(#Menu_Edit_Autocomplete, "Autocomplétion" + Chr(9) + "Ctrl+Espace")
  
  MenuTitle("Projet")
  MenuItem(#Menu_Build_Run, "Compiler & Exécuter" + Chr(9) + "F5")
  MenuItem(#Menu_Build_TranspileOnly, "Transpiler uniquement")
  
  MenuTitle("Aide")
  MenuItem(#Menu_Help_About, "À propos de PureBasic OOP IDE")
  
  ; Raccourcis Clavier
  AddKeyboardShortcut(#Win_Main, #PB_Shortcut_F5, #Shortcut_F5)
  AddKeyboardShortcut(#Win_Main, #PB_Shortcut_Control | #PB_Shortcut_Space, #Shortcut_CtrlSpace)
  AddKeyboardShortcut(#Win_Main, #PB_Shortcut_Control | #PB_Shortcut_S, #Shortcut_CtrlS)
  AddKeyboardShortcut(#Win_Main, #PB_Shortcut_Control | #PB_Shortcut_O, #Shortcut_CtrlO)
  AddKeyboardShortcut(#Win_Main, #PB_Shortcut_Control | #PB_Shortcut_N, #Shortcut_CtrlN)
  
  ; --------------------------------------------------------------------------
  ; Création des Gadgets UI
  ; --------------------------------------------------------------------------
  ; Arbre des symboles à gauche
  TreeGadget(#Gadget_Tree_Symbols, 0, 0, 200, winH - 60)
  
  ; Éditeur Scintilla au centre
  ScintillaGadget(#Gadget_Scintilla_Editor, 0, 0, winW - 200, 450, @ScintillaCallback())
  IDE_ApplyThemeAndLexer(#Gadget_Scintilla_Editor)
  
  ; Console de sortie en bas
  ListViewGadget(#Gadget_List_Console, 0, 0, winW - 200, 150)
  
  ; Splitters pour organiser la disposition responsive
  SplitterGadget(#Gadget_Splitter_Side, 200, 0, winW - 200, winH - 60, #Gadget_Scintilla_Editor, #Gadget_List_Console, #PB_Splitter_Separator)
  SetGadgetState(#Gadget_Splitter_Side, 420)
  
  SplitterGadget(#Gadget_Splitter_Main, 0, 0, winW, winH - 30, #Gadget_Tree_Symbols, #Gadget_Splitter_Side, #PB_Splitter_Vertical | #PB_Splitter_Separator)
  SetGadgetState(#Gadget_Splitter_Main, 200)
  
  ; Barre d'état
  CreateStatusBar(#Gadget_Status_Bar, WindowID(#Win_Main))
  AddStatusBarField(300)
  AddStatusBarField(200)
  AddStatusBarField(#PB_Ignore)
  StatusBarText(#Gadget_Status_Bar, 0, "Prêt")
  StatusBarText(#Gadget_Status_Bar, 1, "PureBasic OOP Engine v1.0")
  
  ; Charger le dernier fichier ou créer un modèle par défaut
  If Settings\LastOpenedFile <> "" And FileSize(Settings\LastOpenedFile) > 0
    IDE_MainWindow_OpenFile(Settings\LastOpenedFile)
  Else
    IDE_MainWindow_NewFile()
  EndIf
EndProcedure
