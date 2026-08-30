; ============================================================================
; Title:       ide_main_window.pb
; Description: Main IDE window with responsive layout, top action bar, and modern UI
; Author:      MicrodevWeb
; ============================================================================

EnableExplicit

XIncludeFile "../config/ide_settings.pbi"
XIncludeFile "../editor/ide_scintilla.pbi"
XIncludeFile "../editor/ide_lexer.pbi"
XIncludeFile "../editor/ide_autocomplete.pbi"
XIncludeFile "../editor/ide_autoclose.pbi"
XIncludeFile "../compiler_bridge/ide_builder.pbi"
XIncludeFile "../compiler_bridge/ide_parser_symbols.pbi"
XIncludeFile "ide_dlg_settings.pbi"

Enumeration Windows
  #Win_Main
EndEnumeration

Enumeration Menus
  #Menu_Main
  
  ; File menu items
  #Menu_File_New
  #Menu_File_Open
  #Menu_File_Save
  #Menu_File_SaveAs
  #Menu_File_Settings
  #Menu_File_Exit
  
  ; Edit menu items
  #Menu_Edit_Undo
  #Menu_Edit_Redo
  #Menu_Edit_Cut
  #Menu_Edit_Copy
  #Menu_Edit_Paste
  #Menu_Edit_SelectAll
  #Menu_Edit_Autocomplete
  
  ; Project menu items
  #Menu_Build_Run
  #Menu_Build_TranspileOnly
  
  ; Help menu items
  #Menu_Help_About
EndEnumeration

Enumeration Shortcuts
  #Shortcut_F5
  #Shortcut_CtrlSpace
  #Shortcut_CtrlS
  #Shortcut_CtrlO
  #Shortcut_CtrlN
EndEnumeration

Enumeration Gadgets
  ; Modern Top Action Bar
  #Gadget_Container_TopBar
  #Btn_Top_New
  #Btn_Top_Open
  #Btn_Top_Save
  #Btn_Top_Run
  #Btn_Top_Settings
  
  ; UI Containers and Gadgets
  #Gadget_Container_Sidebar
  #Gadget_Txt_SidebarTitle
  #Gadget_Tree_Symbols
  
  #Gadget_Container_EditorArea
  #Gadget_Txt_TabBar
  #Gadget_Scintilla_Editor
  
  #Gadget_Container_Bottom
  #Gadget_Txt_ConsoleTitle
  #Gadget_List_Console
  
  #Gadget_Status_Bar
EndEnumeration

Global CurrentDocumentPath.s = ""
Global IsModified.b = #False
Global SidebarWidth.i = 240
Global ConsoleHeight.i = 160

; ----------------------------------------------------------------------------
; Procedure:   IDE_MainWindow_ResizeLayout
; Purpose:     Recalculates and dynamically resizes all widgets to fit the window
; Parameters:  None
; Return:      None
; ----------------------------------------------------------------------------
Procedure IDE_MainWindow_ResizeLayout()
  If Not IsWindow(#Win_Main) : ProcedureReturn : EndIf
  
  Protected winW = WindowWidth(#Win_Main)
  Protected winH = WindowHeight(#Win_Main)
  Protected tbHeight = 40  ; Top action bar height
  Protected sbHeight = 24  ; Status bar height
  
  ; Top Action Bar full width
  ResizeGadget(#Gadget_Container_TopBar, 0, 0, winW, tbHeight)
  
  ; Usable workspace area
  Protected workY = tbHeight
  Protected workH = winH - tbHeight - sbHeight
  If workH < 150 : workH = 150 : EndIf
  
  ; 1. Left Sidebar
  Protected sbW = SidebarWidth
  If sbW > winW - 300 : sbW = winW - 300 : EndIf
  If sbW < 120 : sbW = 120 : EndIf
  
  ResizeGadget(#Gadget_Container_Sidebar, 0, workY, sbW, workH)
  ResizeGadget(#Gadget_Txt_SidebarTitle, 0, 0, sbW, 26)
  ResizeGadget(#Gadget_Tree_Symbols, 0, 26, sbW, workH - 26)
  
  ; 2. Right Workspace (Editor + Bottom Console)
  Protected rightX = sbW
  Protected rightW = winW - sbW
  If rightW < 200 : rightW = 200 : EndIf
  
  Protected conH = ConsoleHeight
  If conH > workH - 120 : conH = workH - 120 : EndIf
  If conH < 80 : conH = 80 : EndIf
  
  Protected editH = workH - conH
  
  ; Editor Container
  ResizeGadget(#Gadget_Container_EditorArea, rightX, workY, rightW, editH)
  ResizeGadget(#Gadget_Txt_TabBar, 0, 0, rightW, 26)
  ResizeGadget(#Gadget_Scintilla_Editor, 0, 26, rightW, editH - 26)
  
  ; Console Container
  ResizeGadget(#Gadget_Container_Bottom, rightX, workY + editH, rightW, conH)
  ResizeGadget(#Gadget_Txt_ConsoleTitle, 0, 0, rightW, 24)
  ResizeGadget(#Gadget_List_Console, 0, 24, rightW, conH - 24)
EndProcedure

; ----------------------------------------------------------------------------
; Procedure:   IDE_MainWindow_Log
; Purpose:     Appends timestamped message to bottom console list view
; Parameters:  message.s - Log text string
;              isError.b - Flag indicating error severity
; Return:      None
; ----------------------------------------------------------------------------
Procedure IDE_MainWindow_Log(message.s, isError.b)
  If IsGadget(#Gadget_List_Console)
    Protected prefix.s = FormatDate("[%hh:%ii:%ss] ", Date())
    AddGadgetItem(#Gadget_List_Console, -1, prefix + message)
    SendMessage_(GadgetID(#Gadget_List_Console), #WM_VSCROLL, #SB_BOTTOM, 0)
  EndIf
EndProcedure

; ----------------------------------------------------------------------------
; Procedure:   IDE_MainWindow_UpdateTitle
; Purpose:     Refreshes main window title bar and editor tab label
; Parameters:  None
; Return:      None
; ----------------------------------------------------------------------------
Procedure IDE_MainWindow_UpdateTitle()
  Protected docName.s = "Untitled.pbo"
  If CurrentDocumentPath <> ""
    docName = GetFilePart(CurrentDocumentPath)
  EndIf
  If IsModified
    docName + " *"
  EndIf
  
  SetWindowTitle(#Win_Main, "PureBasic OOP IDE - [" + docName + "]")
  If IsGadget(#Gadget_Txt_TabBar)
    SetGadgetText(#Gadget_Txt_TabBar, "  " + docName)
  EndIf
EndProcedure

; ----------------------------------------------------------------------------
; Procedure:   IDE_MainWindow_UpdateSymbols
; Purpose:     Parses editor text and updates left symbol tree gadget
; Parameters:  None
; Return:      None
; ----------------------------------------------------------------------------
Procedure IDE_MainWindow_UpdateSymbols()
  If IsGadget(#Gadget_Scintilla_Editor) And IsGadget(#Gadget_Tree_Symbols)
    Protected code.s = IDE_GetEditorText(#Gadget_Scintilla_Editor)
    IDE_ExtractSymbolsFromText(code)
    
    ClearGadgetItems(#Gadget_Tree_Symbols)
    AddGadgetItem(#Gadget_Tree_Symbols, 0, "Classes & Methods", 0, 0)
    
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

; ----------------------------------------------------------------------------
; Procedure:   IDE_MainWindow_NewFile
; Purpose:     Creates a new document with boilerplate OOP template
; Parameters:  None
; Return:      None
; ----------------------------------------------------------------------------
Procedure IDE_MainWindow_NewFile()
  IDE_SetEditorText(#Gadget_Scintilla_Editor, "; New PureBasic OOP file (.pbo)" + #CRLF$ + "Class MyObject" + #CRLF$ + "  Public Method SayHello()" + #CRLF$ + "    PrintN(" + Chr(34) + "Hello PureBasic OOP!" + Chr(34) + ")" + #CRLF$ + "  EndMethod" + #CRLF$ + "EndClass" + #CRLF$)
  CurrentDocumentPath = ""
  IsModified = #False
  IDE_MainWindow_UpdateTitle()
  IDE_MainWindow_UpdateSymbols()
  IDE_MainWindow_Log("New file created.", #False)
  SetActiveGadget(#Gadget_Scintilla_Editor)
EndProcedure

; ----------------------------------------------------------------------------
; Procedure:   IDE_MainWindow_OpenFile
; Purpose:     Opens an existing source file into the editor
; Parameters:  filePath.s - Optional file path to open (prompts if empty)
; Return:      None
; ----------------------------------------------------------------------------
Procedure IDE_MainWindow_OpenFile(filePath.s = "")
  If filePath = ""
    filePath = OpenFileRequester("Open PureBasic OOP File", GetCurrentDirectory(), "PureBasic OOP (*.pbo)|*.pbo|PureBasic (*.pb;*.pbi)|*.pb;*.pbi|All Files (*.*)|*.*", 0)
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
      IDE_MainWindow_Log("Opened file: " + filePath, #False)
      SetActiveGadget(#Gadget_Scintilla_Editor)
    Else
      MessageRequester("Error", "Cannot open selected file.", #PB_MessageRequester_Error)
    EndIf
  EndIf
EndProcedure

; ----------------------------------------------------------------------------
; Procedure:   IDE_MainWindow_SaveFile
; Purpose:     Saves active editor text to file
; Parameters:  saveAs.b - Flag to force Save As dialog
; Return:      #True on success, #False on cancel or failure
; ----------------------------------------------------------------------------
Procedure IDE_MainWindow_SaveFile(saveAs.b = #False)
  If CurrentDocumentPath = "" Or saveAs
    CurrentDocumentPath = SaveFileRequester("Save PureBasic OOP File", "MyScript.pbo", "PureBasic OOP (*.pbo)|*.pbo|All Files (*.*)|*.*", 0)
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
    IDE_MainWindow_Log("File saved successfully: " + CurrentDocumentPath, #False)
    ProcedureReturn #True
  Else
    MessageRequester("Error", "Cannot save file.", #PB_MessageRequester_Error)
    ProcedureReturn #False
  EndIf
EndProcedure

; ----------------------------------------------------------------------------
; Procedure:   ScintillaCallback
; Purpose:     Processes Scintilla notification events (characters added, edits)
; Parameters:  gadgetId.i         - Scintilla gadget ID
;              *scNotification    - Pointer to SCNotification structure
; Return:      None
; ----------------------------------------------------------------------------
Procedure ScintillaCallback(gadgetId.i, *scNotification.SCNotification)
  If *scNotification = 0 : ProcedureReturn : EndIf
  Select *scNotification\nmhdr\code
    Case #SCN_CHARADDED
      Protected charAdded = *scNotification\ch
      ; 1. Auto-close delimiter pairs and block keywords
      IDE_HandleAutoClose(gadgetId, charAdded)
      
      ; 2. Trigger autocomplete on identifier character typed
      If (charAdded >= Asc("a") And charAdded <= Asc("z")) Or (charAdded >= Asc("A") And charAdded <= Asc("Z")) Or charAdded = Asc("_")
        IDE_TriggerAutocomplete(gadgetId, #False)
      EndIf
      
      IsModified = #True
      IDE_MainWindow_UpdateTitle()
      
    Case #SCN_MODIFIED
      IsModified = #True
  EndSelect
EndProcedure

; ----------------------------------------------------------------------------
; Procedure:   IDE_MainWindow_Open
; Purpose:     Builds the main window layout with top bar, responsive containers and editor
; Parameters:  None
; Return:      None
; ----------------------------------------------------------------------------
Procedure IDE_MainWindow_Open()
  Protected winW = 1280, winH = 800
  OpenWindow(#Win_Main, 0, 0, winW, winH, "PureBasic OOP IDE", #PB_Window_SystemMenu | #PB_Window_SizeGadget | #PB_Window_MinimizeGadget | #PB_Window_MaximizeGadget | #PB_Window_ScreenCentered)
  
  ; Set dark background color for the main window
  SetWindowColor(#Win_Main, $181818)
  
  ; Maximize window on launch for full-screen responsive workspace
  SetWindowState(#Win_Main, #PB_Window_Maximize)
  
  ; --------------------------------------------------------------------------
  ; Main Menu Bar
  ; --------------------------------------------------------------------------
  CreateMenu(#Menu_Main, WindowID(#Win_Main))
  MenuTitle("File")
  MenuItem(#Menu_File_New, "New" + Chr(9) + "Ctrl+N")
  MenuItem(#Menu_File_Open, "Open..." + Chr(9) + "Ctrl+O")
  MenuItem(#Menu_File_Save, "Save" + Chr(9) + "Ctrl+S")
  MenuItem(#Menu_File_SaveAs, "Save As...")
  MenuBar()
  MenuItem(#Menu_File_Settings, "Settings...")
  MenuBar()
  MenuItem(#Menu_File_Exit, "Exit")
  
  MenuTitle("Edit")
  MenuItem(#Menu_Edit_Autocomplete, "Autocomplete" + Chr(9) + "Ctrl+Space")
  
  MenuTitle("Project")
  MenuItem(#Menu_Build_Run, "Compile & Run" + Chr(9) + "F5")
  MenuItem(#Menu_Build_TranspileOnly, "Transpile Only")
  
  MenuTitle("Help")
  MenuItem(#Menu_Help_About, "About PureBasic OOP IDE")
  
  ; Keyboard shortcuts
  AddKeyboardShortcut(#Win_Main, #PB_Shortcut_F5, #Shortcut_F5)
  AddKeyboardShortcut(#Win_Main, #PB_Shortcut_Control | #PB_Shortcut_Space, #Shortcut_CtrlSpace)
  AddKeyboardShortcut(#Win_Main, #PB_Shortcut_Control | #PB_Shortcut_S, #Shortcut_CtrlS)
  AddKeyboardShortcut(#Win_Main, #PB_Shortcut_Control | #PB_Shortcut_O, #Shortcut_CtrlO)
  AddKeyboardShortcut(#Win_Main, #PB_Shortcut_Control | #PB_Shortcut_N, #Shortcut_CtrlN)
  
  ; --------------------------------------------------------------------------
  ; Top Action Bar (Flat modern header with action buttons)
  ; --------------------------------------------------------------------------
  ContainerGadget(#Gadget_Container_TopBar, 0, 0, winW, 40, #PB_Container_Flat)
  SetGadgetColor(#Gadget_Container_TopBar, #PB_Gadget_BackColor, $2D2D2D)
  
  ButtonGadget(#Btn_Top_New, 8, 6, 75, 28, "New")
  ButtonGadget(#Btn_Top_Open, 88, 6, 75, 28, "Open")
  ButtonGadget(#Btn_Top_Save, 168, 6, 75, 28, "Save")
  ButtonGadget(#Btn_Top_Run, 255, 6, 120, 28, "▶ Run (F5)")
  ButtonGadget(#Btn_Top_Settings, 385, 6, 85, 28, "Settings")
  CloseGadgetList()
  
  ; --------------------------------------------------------------------------
  ; 1. Left Sidebar Container (Class outline explorer)
  ; --------------------------------------------------------------------------
  ContainerGadget(#Gadget_Container_Sidebar, 0, 40, SidebarWidth, winH - 64, #PB_Container_Flat)
  SetGadgetColor(#Gadget_Container_Sidebar, #PB_Gadget_BackColor, $252526)
  
  TextGadget(#Gadget_Txt_SidebarTitle, 0, 0, SidebarWidth, 26, "  OUTLINE SYMBOLS", #PB_Text_Center)
  SetGadgetColor(#Gadget_Txt_SidebarTitle, #PB_Gadget_BackColor, $333333)
  SetGadgetColor(#Gadget_Txt_SidebarTitle, #PB_Gadget_FrontColor, $CCCCCC)
  
  TreeGadget(#Gadget_Tree_Symbols, 0, 26, SidebarWidth, winH - 90)
  SetGadgetColor(#Gadget_Tree_Symbols, #PB_Gadget_BackColor, $252526)
  SetGadgetColor(#Gadget_Tree_Symbols, #PB_Gadget_FrontColor, $D4D4D4)
  CloseGadgetList()
  
  ; --------------------------------------------------------------------------
  ; 2. Center Editor Container (Scintilla Editor & Tab Header)
  ; --------------------------------------------------------------------------
  ContainerGadget(#Gadget_Container_EditorArea, SidebarWidth, 40, winW - SidebarWidth, winH - 64 - ConsoleHeight, #PB_Container_Flat)
  SetGadgetColor(#Gadget_Container_EditorArea, #PB_Gadget_BackColor, $1E1E1E)
  
  TextGadget(#Gadget_Txt_TabBar, 0, 0, winW - SidebarWidth, 26, "  Untitled.pbo")
  SetGadgetColor(#Gadget_Txt_TabBar, #PB_Gadget_BackColor, $1E1E1E)
  SetGadgetColor(#Gadget_Txt_TabBar, #PB_Gadget_FrontColor, $FFFFFF)
  
  ScintillaGadget(#Gadget_Scintilla_Editor, 0, 26, winW - SidebarWidth, winH - 90 - ConsoleHeight, @ScintillaCallback())
  IDE_ApplyThemeAndLexer(#Gadget_Scintilla_Editor)
  CloseGadgetList()
  
  ; --------------------------------------------------------------------------
  ; 3. Bottom Output Console Container
  ; --------------------------------------------------------------------------
  ContainerGadget(#Gadget_Container_Bottom, SidebarWidth, winH - 64 - ConsoleHeight, winW - SidebarWidth, ConsoleHeight, #PB_Container_Flat)
  SetGadgetColor(#Gadget_Container_Bottom, #PB_Gadget_BackColor, $1E1E1E)
  
  TextGadget(#Gadget_Txt_ConsoleTitle, 0, 0, winW - SidebarWidth, 24, "  OUTPUT & BUILD LOGS")
  SetGadgetColor(#Gadget_Txt_ConsoleTitle, #PB_Gadget_BackColor, $2D2D2D)
  SetGadgetColor(#Gadget_Txt_ConsoleTitle, #PB_Gadget_FrontColor, $AAAAAA)
  
  ListViewGadget(#Gadget_List_Console, 0, 24, winW - SidebarWidth, ConsoleHeight - 24)
  SetGadgetColor(#Gadget_List_Console, #PB_Gadget_BackColor, $181818)
  SetGadgetColor(#Gadget_List_Console, #PB_Gadget_FrontColor, $CCCCCC)
  CloseGadgetList()
  
  ; --------------------------------------------------------------------------
  ; 4. Bottom Status Bar
  ; --------------------------------------------------------------------------
  CreateStatusBar(#Gadget_Status_Bar, WindowID(#Win_Main))
  AddStatusBarField(350)
  AddStatusBarField(220)
  AddStatusBarField(#PB_Ignore)
  StatusBarText(#Gadget_Status_Bar, 0, "Ready")
  StatusBarText(#Gadget_Status_Bar, 1, "PureBasic OOP Engine v1.0")
  StatusBarText(#Gadget_Status_Bar, 2, "UTF-8")
  
  ; Initial layout dynamic calculation
  IDE_MainWindow_ResizeLayout()
  
  ; Load last opened document or create default template
  If Settings\LastOpenedFile <> "" And FileSize(Settings\LastOpenedFile) > 0
    IDE_MainWindow_OpenFile(Settings\LastOpenedFile)
  Else
    IDE_MainWindow_NewFile()
  EndIf
  
  ; Focus editor on launch
  SetActiveGadget(#Gadget_Scintilla_Editor)
EndProcedure
