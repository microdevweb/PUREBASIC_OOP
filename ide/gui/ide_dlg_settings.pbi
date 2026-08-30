; ============================================================================
; Title:       ide_dlg_settings.pb
; Description: Settings dialog window (Syntax colors, Autocomplete threshold, Auto-closing)
; Author:      MicrodevWeb
; ============================================================================

EnableExplicit

XIncludeFile "../config/ide_settings.pbi"

Enumeration SettingsWidgets 1000
  #Dlg_Settings_Window
  #Dlg_Settings_Panel
  
  ; Tab 1: Editor & Typing
  #Dlg_Chk_AC_Enable
  #Dlg_Spin_AC_MinChars
  #Dlg_Txt_AC_MinChars
  #Dlg_Chk_AutoCloseBlocks
  #Dlg_Chk_AutoCloseBrackets
  #Dlg_Chk_ShowLineNumbers
  #Dlg_Chk_HighlightLine
  #Dlg_Spin_TabWidth
  #Dlg_Txt_TabWidth
  
  ; Tab 2: Theme & Syntax Colors
  #Dlg_Cmb_ThemePreset
  #Dlg_Btn_Color_Bg
  #Dlg_Btn_Color_Fg
  #Dlg_Btn_Color_PBKw
  #Dlg_Btn_Color_OOPKw
  #Dlg_Btn_Color_String
  #Dlg_Btn_Color_Comment
  #Dlg_Btn_Color_Number
  #Dlg_Btn_Color_Function
  
  ; Tab 3: Compiler Path
  #Dlg_Txt_CompilerPath
  #Dlg_Str_CompilerPath
  #Dlg_Btn_BrowseCompiler
  
  ; Action buttons
  #Dlg_Btn_Save
  #Dlg_Btn_Cancel
EndEnumeration

; Temporary theme state during dialog editing
Global TempTheme.IDE_ThemeColors

; ----------------------------------------------------------------------------
; Procedure:   UpdateColorButton
; Purpose:     Refreshes label text of color button with current hex value
; Parameters:  btnGadget.i - Gadget ID of target button
;              color.i     - Color value in integer format
;              label.s     - Descriptive text label
; Return:      None
; ----------------------------------------------------------------------------
Procedure UpdateColorButton(btnGadget.i, color.i, label.s)
  SetGadgetText(btnGadget, label + " ( #" + Hex(color, #PB_Long) + " )")
EndProcedure

; ----------------------------------------------------------------------------
; Procedure:   IDE_OpenSettingsDialog
; Purpose:     Creates and displays the settings dialog window
; Parameters:  parentWindow.i - ID of parent window for centering
; Return:      None
; ----------------------------------------------------------------------------
Procedure IDE_OpenSettingsDialog(parentWindow.i)
  If IsWindow(#Dlg_Settings_Window)
    SetActiveWindow(#Dlg_Settings_Window)
    ProcedureReturn
  EndIf
  
  TempTheme = Settings\Colors
  
  Protected winW = 540, winH = 460
  OpenWindow(#Dlg_Settings_Window, 0, 0, winW, winH, "PureBasic OOP IDE Settings", #PB_Window_SystemMenu | #PB_Window_WindowCentered, WindowID(parentWindow))
  
  PanelGadget(#Dlg_Settings_Panel, 10, 10, winW - 20, winH - 60)
  
  ; --------------------------------------------------------------------------
  ; Tab 1: Editor & Typing options
  ; --------------------------------------------------------------------------
  AddGadgetItem(#Dlg_Settings_Panel, -1, "Editor & Typing")
  
  FrameGadget(#PB_Any, 15, 15, 480, 110, "Autocomplete")
  CheckBoxGadget(#Dlg_Chk_AC_Enable, 30, 40, 440, 24, "Enable automatic completion popup")
  SetGadgetState(#Dlg_Chk_AC_Enable, Settings\AutocompleteEnabled)
  
  TextGadget(#Dlg_Txt_AC_MinChars, 30, 75, 280, 24, "Typed characters before popup:")
  SpinGadget(#Dlg_Spin_AC_MinChars, 320, 70, 70, 26, 1, 10, #PB_Spin_Numeric)
  SetGadgetState(#Dlg_Spin_AC_MinChars, Settings\AutocompleteMinChars)
  SetGadgetText(#Dlg_Spin_AC_MinChars, Str(Settings\AutocompleteMinChars))
  
  FrameGadget(#PB_Any, 15, 140, 480, 130, "Auto-Closing")
  CheckBoxGadget(#Dlg_Chk_AutoCloseBlocks, 30, 165, 440, 24, "Auto-close block keywords (If/EndIf, Class/EndClass, etc.)")
  SetGadgetState(#Dlg_Chk_AutoCloseBlocks, Settings\AutoCloseBlocks)
  
  CheckBoxGadget(#Dlg_Chk_AutoCloseBrackets, 30, 195, 440, 24, "Auto-close delimiter pairs: ( ), [ ], { }, " + Chr(34) + " " + Chr(34))
  SetGadgetState(#Dlg_Chk_AutoCloseBrackets, Settings\AutoCloseBrackets)
  
  CheckBoxGadget(#Dlg_Chk_ShowLineNumbers, 30, 225, 200, 24, "Show line numbers margin")
  SetGadgetState(#Dlg_Chk_ShowLineNumbers, Settings\ShowLineNumbers)
  
  CheckBoxGadget(#Dlg_Chk_HighlightLine, 250, 225, 200, 24, "Highlight active line")
  SetGadgetState(#Dlg_Chk_HighlightLine, Settings\HighlightCurrentLine)
  
  FrameGadget(#PB_Any, 15, 280, 480, 70, "Indentation")
  TextGadget(#Dlg_Txt_TabWidth, 30, 305, 280, 24, "Tab size in spaces:")
  SpinGadget(#Dlg_Spin_TabWidth, 320, 300, 70, 26, 2, 8, #PB_Spin_Numeric)
  SetGadgetState(#Dlg_Spin_TabWidth, Settings\TabWidth)
  SetGadgetText(#Dlg_Spin_TabWidth, Str(Settings\TabWidth))
  
  ; --------------------------------------------------------------------------
  ; Tab 2: Syntax Colors & Themes
  ; --------------------------------------------------------------------------
  AddGadgetItem(#Dlg_Settings_Panel, -1, "Syntax Colors")
  
  TextGadget(#PB_Any, 20, 20, 120, 24, "Theme preset:")
  ComboBoxGadget(#Dlg_Cmb_ThemePreset, 150, 16, 200, 26)
  AddGadgetItem(#Dlg_Cmb_ThemePreset, 0, "Dark Modern (VS Code Style)")
  AddGadgetItem(#Dlg_Cmb_ThemePreset, 1, "Classic PureBasic (Light)")
  If Settings\ThemeName = "Classic PureBasic"
    SetGadgetState(#Dlg_Cmb_ThemePreset, 1)
  Else
    SetGadgetState(#Dlg_Cmb_ThemePreset, 0)
  EndIf
  
  FrameGadget(#PB_Any, 15, 60, 480, 280, "Customizable Colors")
  
  ButtonGadget(#Dlg_Btn_Color_Bg, 30, 85, 210, 30, "")
  UpdateColorButton(#Dlg_Btn_Color_Bg, TempTheme\BgColor, "Editor Background")
  
  ButtonGadget(#Dlg_Btn_Color_Fg, 260, 85, 210, 30, "")
  UpdateColorButton(#Dlg_Btn_Color_Fg, TempTheme\FgColor, "Plain Text")
  
  ButtonGadget(#Dlg_Btn_Color_PBKw, 30, 125, 210, 30, "")
  UpdateColorButton(#Dlg_Btn_Color_PBKw, TempTheme\KeywordPBColor, "PB Keywords (If, For...)")
  
  ButtonGadget(#Dlg_Btn_Color_OOPKw, 260, 125, 210, 30, "")
  UpdateColorButton(#Dlg_Btn_Color_OOPKw, TempTheme\KeywordOOPColor, "OOP Keywords (Class...)")
  
  ButtonGadget(#Dlg_Btn_Color_String, 30, 165, 210, 30, "")
  UpdateColorButton(#Dlg_Btn_Color_String, TempTheme\StringColor, "String Literals")
  
  ButtonGadget(#Dlg_Btn_Color_Comment, 260, 165, 210, 30, "")
  UpdateColorButton(#Dlg_Btn_Color_Comment, TempTheme\CommentColor, "Comments (;)")
  
  ButtonGadget(#Dlg_Btn_Color_Number, 30, 205, 210, 30, "")
  UpdateColorButton(#Dlg_Btn_Color_Number, TempTheme\NumberColor, "Numbers")
  
  ButtonGadget(#Dlg_Btn_Color_Function, 260, 205, 210, 30, "")
  UpdateColorButton(#Dlg_Btn_Color_Function, TempTheme\FunctionColor, "Functions")
  
  ; --------------------------------------------------------------------------
  ; Tab 3: PureBasic Compiler
  ; --------------------------------------------------------------------------
  AddGadgetItem(#Dlg_Settings_Panel, -1, "PureBasic Compiler")
  
  FrameGadget(#PB_Any, 15, 20, 480, 120, "Path to pbcompiler.exe binary")
  StringGadget(#Dlg_Str_CompilerPath, 30, 55, 380, 26, Settings\CompilerPath)
  ButtonGadget(#Dlg_Btn_BrowseCompiler, 420, 55, 60, 26, "...")
  TextGadget(#PB_Any, 30, 90, 440, 35, "Required to compile and execute projects with F5.")
  
  CloseGadgetList()
  
  ; Dialog action buttons
  ButtonGadget(#Dlg_Btn_Save, winW - 220, winH - 40, 100, 30, "Save")
  ButtonGadget(#Dlg_Btn_Cancel, winW - 110, winH - 40, 100, 30, "Cancel")
EndProcedure

; ----------------------------------------------------------------------------
; Procedure:   IDE_HandleSettingsEvents
; Purpose:     Dispatches events for settings dialog controls
; Parameters:  event.i       - PureBasic event ID
;              eventGadget.i - Event source gadget ID
; Return:      #True if settings were saved, #False otherwise
; ----------------------------------------------------------------------------
Procedure IDE_HandleSettingsEvents(event.i, eventGadget.i)
  Select event
    Case #PB_Event_Gadget
      Select eventGadget
        ; 1. Theme preset combo change
        Case #Dlg_Cmb_ThemePreset
          If GetGadgetState(#Dlg_Cmb_ThemePreset) = 1
            IDE_Theme_SetClassicPB(@TempTheme)
          Else
            IDE_Theme_SetDarkModern(@TempTheme)
          EndIf
          UpdateColorButton(#Dlg_Btn_Color_Bg, TempTheme\BgColor, "Editor Background")
          UpdateColorButton(#Dlg_Btn_Color_Fg, TempTheme\FgColor, "Plain Text")
          UpdateColorButton(#Dlg_Btn_Color_PBKw, TempTheme\KeywordPBColor, "PB Keywords (If, For...)")
          UpdateColorButton(#Dlg_Btn_Color_OOPKw, TempTheme\KeywordOOPColor, "OOP Keywords (Class...)")
          UpdateColorButton(#Dlg_Btn_Color_String, TempTheme\StringColor, "String Literals")
          UpdateColorButton(#Dlg_Btn_Color_Comment, TempTheme\CommentColor, "Comments (;)")
          UpdateColorButton(#Dlg_Btn_Color_Number, TempTheme\NumberColor, "Numbers")
          UpdateColorButton(#Dlg_Btn_Color_Function, TempTheme\FunctionColor, "Functions")
          
        ; 2. Individual color requesters
        Case #Dlg_Btn_Color_Bg
          Protected col = ColorRequester(TempTheme\BgColor)
          If col <> -1 : TempTheme\BgColor = col : UpdateColorButton(#Dlg_Btn_Color_Bg, col, "Editor Background") : EndIf
        Case #Dlg_Btn_Color_Fg
          col = ColorRequester(TempTheme\FgColor)
          If col <> -1 : TempTheme\FgColor = col : UpdateColorButton(#Dlg_Btn_Color_Fg, col, "Plain Text") : EndIf
        Case #Dlg_Btn_Color_PBKw
          col = ColorRequester(TempTheme\KeywordPBColor)
          If col <> -1 : TempTheme\KeywordPBColor = col : UpdateColorButton(#Dlg_Btn_Color_PBKw, col, "PB Keywords (If, For...)") : EndIf
        Case #Dlg_Btn_Color_OOPKw
          col = ColorRequester(TempTheme\KeywordOOPColor)
          If col <> -1 : TempTheme\KeywordOOPColor = col : UpdateColorButton(#Dlg_Btn_Color_OOPKw, col, "OOP Keywords (Class...)") : EndIf
        Case #Dlg_Btn_Color_String
          col = ColorRequester(TempTheme\StringColor)
          If col <> -1 : TempTheme\StringColor = col : UpdateColorButton(#Dlg_Btn_Color_String, col, "String Literals") : EndIf
        Case #Dlg_Btn_Color_Comment
          col = ColorRequester(TempTheme\CommentColor)
          If col <> -1 : TempTheme\CommentColor = col : UpdateColorButton(#Dlg_Btn_Color_Comment, col, "Comments (;)") : EndIf
        Case #Dlg_Btn_Color_Number
          col = ColorRequester(TempTheme\NumberColor)
          If col <> -1 : TempTheme\NumberColor = col : UpdateColorButton(#Dlg_Btn_Color_Number, col, "Numbers") : EndIf
        Case #Dlg_Btn_Color_Function
          col = ColorRequester(TempTheme\FunctionColor)
          If col <> -1 : TempTheme\FunctionColor = col : UpdateColorButton(#Dlg_Btn_Color_Function, col, "Functions") : EndIf
          
        ; 3. Browse compiler button
        Case #Dlg_Btn_BrowseCompiler
          Protected file.s = OpenFileRequester("Select pbcompiler.exe", Settings\CompilerPath, "Executables (*.exe)|*.exe|All files (*.*)|*.*", 0)
          If file <> ""
            SetGadgetText(#Dlg_Str_CompilerPath, file)
          EndIf
          
        ; 4. Save button action
        Case #Dlg_Btn_Save
          Settings\AutocompleteEnabled  = GetGadgetState(#Dlg_Chk_AC_Enable)
          Settings\AutocompleteMinChars = GetGadgetState(#Dlg_Spin_AC_MinChars)
          If Settings\AutocompleteMinChars < 1 : Settings\AutocompleteMinChars = 1 : EndIf
          
          Settings\AutoCloseBlocks      = GetGadgetState(#Dlg_Chk_AutoCloseBlocks)
          Settings\AutoCloseBrackets    = GetGadgetState(#Dlg_Chk_AutoCloseBrackets)
          Settings\ShowLineNumbers      = GetGadgetState(#Dlg_Chk_ShowLineNumbers)
          Settings\HighlightCurrentLine = GetGadgetState(#Dlg_Chk_HighlightLine)
          Settings\TabWidth             = GetGadgetState(#Dlg_Spin_TabWidth)
          Settings\CompilerPath         = GetGadgetText(#Dlg_Str_CompilerPath)
          
          If GetGadgetState(#Dlg_Cmb_ThemePreset) = 1
            Settings\ThemeName = "Classic PureBasic"
          Else
            Settings\ThemeName = "Dark Modern"
          EndIf
          Settings\Colors = TempTheme
          CurrentTheme = TempTheme
          
          IDE_Settings_Save()
          CloseWindow(#Dlg_Settings_Window)
          ProcedureReturn #True ; Signals settings were updated
          
        ; 5. Cancel button action
        Case #Dlg_Btn_Cancel
          CloseWindow(#Dlg_Settings_Window)
      EndSelect
      
    Case #PB_Event_CloseWindow
      If EventWindow() = #Dlg_Settings_Window
        CloseWindow(#Dlg_Settings_Window)
      EndIf
  EndSelect
  
  ProcedureReturn #False
EndProcedure
