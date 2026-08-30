; ============================================================================
; Title:       ide_settings.pb
; Description: User preferences manager (Autocomplete, Auto-close, Theme, Compiler)
; Author:      MicrodevWeb
; ============================================================================

EnableExplicit

XIncludeFile "ide_theme.pb"

; ----------------------------------------------------------------------------
; Structure:   IDE_Settings
; Purpose:     Holds all configuration options for editor, syntax, and build tool
; ----------------------------------------------------------------------------
Structure IDE_Settings
  ; Autocomplete options
  AutocompleteMinChars.i    ; Minimum typed characters before triggering popup (default: 2)
  AutocompleteEnabled.b     ; Enable/Disable autocomplete flag
  
  ; Auto-closing options
  AutoCloseBlocks.b         ; Auto-close block keywords (If/EndIf, Class/EndClass, etc.)
  AutoCloseBrackets.b       ; Auto-close delimiter pairs (), [], {}, ""
  
  ; Font and visual options
  FontName.s                ; Font family name (e.g. "Consolas")
  FontSize.i                ; Font size in points (e.g. 11)
  TabWidth.i                ; Indentation size in spaces (e.g. 2)
  ShowLineNumbers.b         ; Show/Hide line numbers margin
  HighlightCurrentLine.b    ; Highlight active line flag
  
  ; Compiler path and files
  CompilerPath.s            ; Full file path to pbcompiler.exe
  LastOpenedFile.s          ; Path to the last opened project or file
  
  ; Active theme
  ThemeName.s               ; Theme preset name ("Dark Modern", "Classic PureBasic")
  Colors.IDE_ThemeColors    ; Theme color definition
EndStructure

Global Settings.IDE_Settings

; ----------------------------------------------------------------------------
; Procedure:   IDE_Settings_GetConfigFile
; Purpose:     Returns the full path to the preferences file
; Parameters:  None
; Return:      Path to ide_settings.prefs file
; ----------------------------------------------------------------------------
Procedure.s IDE_Settings_GetConfigFile()
  Protected appDir.s = GetPathPart(ProgramFilename())
  If appDir = "" Or Not FileSize(appDir) = -2
    appDir = GetCurrentDirectory()
  EndIf
  ProcedureReturn appDir + "ide_settings.prefs"
EndProcedure

; ----------------------------------------------------------------------------
; Procedure:   IDE_Settings_SetDefaults
; Purpose:     Sets default values for all preferences and loads Dark Modern theme
; Parameters:  None
; Return:      None
; ----------------------------------------------------------------------------
Procedure IDE_Settings_SetDefaults()
  With Settings
    \AutocompleteMinChars  = 2
    \AutocompleteEnabled   = #True
    \AutoCloseBlocks       = #True
    \AutoCloseBrackets     = #True
    \FontName              = "Consolas"
    \FontSize              = 11
    \TabWidth              = 2
    \ShowLineNumbers       = #True
    \HighlightCurrentLine  = #True
    \CompilerPath          = "C:\Program Files\PureBasic\Compilers\pbcompiler.exe"
    \LastOpenedFile        = ""
    \ThemeName             = "Dark Modern"
    IDE_Theme_SetDarkModern(@\Colors)
  EndWith
EndProcedure

; ----------------------------------------------------------------------------
; Procedure:   IDE_Settings_Save
; Purpose:     Writes all settings into the preferences INI file
; Parameters:  None
; Return:      None
; ----------------------------------------------------------------------------
Procedure IDE_Settings_Save()
  Protected file.s = IDE_Settings_GetConfigFile()
  If CreatePreferences(file, #PB_Preference_GroupSeparator)
    PreferenceGroup("General")
    WritePreferenceString("FontName", Settings\FontName)
    WritePreferenceInteger("FontSize", Settings\FontSize)
    WritePreferenceInteger("TabWidth", Settings\TabWidth)
    WritePreferenceInteger("ShowLineNumbers", Settings\ShowLineNumbers)
    WritePreferenceInteger("HighlightCurrentLine", Settings\HighlightCurrentLine)
    WritePreferenceString("CompilerPath", Settings\CompilerPath)
    WritePreferenceString("LastOpenedFile", Settings\LastOpenedFile)
    WritePreferenceString("ThemeName", Settings\ThemeName)
    
    PreferenceGroup("Autocomplete")
    WritePreferenceInteger("AutocompleteMinChars", Settings\AutocompleteMinChars)
    WritePreferenceInteger("AutocompleteEnabled", Settings\AutocompleteEnabled)
    
    PreferenceGroup("AutoClose")
    WritePreferenceInteger("AutoCloseBlocks", Settings\AutoCloseBlocks)
    WritePreferenceInteger("AutoCloseBrackets", Settings\AutoCloseBrackets)
    
    PreferenceGroup("Colors")
    WritePreferenceInteger("BgColor", Settings\Colors\BgColor)
    WritePreferenceInteger("FgColor", Settings\Colors\FgColor)
    WritePreferenceInteger("LineNumberBg", Settings\Colors\LineNumberBg)
    WritePreferenceInteger("LineNumberFg", Settings\Colors\LineNumberFg)
    WritePreferenceInteger("SelectionBg", Settings\Colors\SelectionBg)
    WritePreferenceInteger("SelectionFg", Settings\Colors\SelectionFg)
    WritePreferenceInteger("CaretColor", Settings\Colors\CaretColor)
    WritePreferenceInteger("CurrentLineBg", Settings\Colors\CurrentLineBg)
    WritePreferenceInteger("CommentColor", Settings\Colors\CommentColor)
    WritePreferenceInteger("StringColor", Settings\Colors\StringColor)
    WritePreferenceInteger("NumberColor", Settings\Colors\NumberColor)
    WritePreferenceInteger("KeywordPBColor", Settings\Colors\KeywordPBColor)
    WritePreferenceInteger("KeywordOOPColor", Settings\Colors\KeywordOOPColor)
    WritePreferenceInteger("FunctionColor", Settings\Colors\FunctionColor)
    WritePreferenceInteger("OperatorColor", Settings\Colors\OperatorColor)
    WritePreferenceInteger("ConstantColor", Settings\Colors\ConstantColor)
    
    ClosePreferences()
  EndIf
EndProcedure

; ----------------------------------------------------------------------------
; Procedure:   IDE_Settings_Load
; Purpose:     Reads settings from preferences file or initializes default values
; Parameters:  None
; Return:      None
; ----------------------------------------------------------------------------
Procedure IDE_Settings_Load()
  Protected file.s = IDE_Settings_GetConfigFile()
  IDE_Settings_SetDefaults()
  
  If OpenPreferences(file)
    PreferenceGroup("General")
    Settings\FontName             = ReadPreferenceString("FontName", Settings\FontName)
    Settings\FontSize             = ReadPreferenceInteger("FontSize", Settings\FontSize)
    Settings\TabWidth             = ReadPreferenceInteger("TabWidth", Settings\TabWidth)
    Settings\ShowLineNumbers      = ReadPreferenceInteger("ShowLineNumbers", Settings\ShowLineNumbers)
    Settings\HighlightCurrentLine = ReadPreferenceInteger("HighlightCurrentLine", Settings\HighlightCurrentLine)
    Settings\CompilerPath         = ReadPreferenceString("CompilerPath", Settings\CompilerPath)
    Settings\LastOpenedFile       = ReadPreferenceString("LastOpenedFile", Settings\LastOpenedFile)
    Settings\ThemeName            = ReadPreferenceString("ThemeName", Settings\ThemeName)
    
    PreferenceGroup("Autocomplete")
    Settings\AutocompleteMinChars = ReadPreferenceInteger("AutocompleteMinChars", Settings\AutocompleteMinChars)
    Settings\AutocompleteEnabled  = ReadPreferenceInteger("AutocompleteEnabled", Settings\AutocompleteEnabled)
    
    PreferenceGroup("AutoClose")
    Settings\AutoCloseBlocks      = ReadPreferenceInteger("AutoCloseBlocks", Settings\AutoCloseBlocks)
    Settings\AutoCloseBrackets    = ReadPreferenceInteger("AutoCloseBrackets", Settings\AutoCloseBrackets)
    
    PreferenceGroup("Colors")
    Settings\Colors\BgColor         = ReadPreferenceInteger("BgColor", Settings\Colors\BgColor)
    Settings\Colors\FgColor         = ReadPreferenceInteger("FgColor", Settings\Colors\FgColor)
    Settings\Colors\LineNumberBg    = ReadPreferenceInteger("LineNumberBg", Settings\Colors\LineNumberBg)
    Settings\Colors\LineNumberFg    = ReadPreferenceInteger("LineNumberFg", Settings\Colors\LineNumberFg)
    Settings\Colors\SelectionBg     = ReadPreferenceInteger("SelectionBg", Settings\Colors\SelectionBg)
    Settings\Colors\SelectionFg     = ReadPreferenceInteger("SelectionFg", Settings\Colors\SelectionFg)
    Settings\Colors\CaretColor      = ReadPreferenceInteger("CaretColor", Settings\Colors\CaretColor)
    Settings\Colors\CurrentLineBg   = ReadPreferenceInteger("CurrentLineBg", Settings\Colors\CurrentLineBg)
    Settings\Colors\CommentColor    = ReadPreferenceInteger("CommentColor", Settings\Colors\CommentColor)
    Settings\Colors\StringColor     = ReadPreferenceInteger("StringColor", Settings\Colors\StringColor)
    Settings\Colors\NumberColor     = ReadPreferenceInteger("NumberColor", Settings\Colors\NumberColor)
    Settings\Colors\KeywordPBColor  = ReadPreferenceInteger("KeywordPBColor", Settings\Colors\KeywordPBColor)
    Settings\Colors\KeywordOOPColor = ReadPreferenceInteger("KeywordOOPColor", Settings\Colors\KeywordOOPColor)
    Settings\Colors\FunctionColor   = ReadPreferenceInteger("FunctionColor", Settings\Colors\FunctionColor)
    Settings\Colors\OperatorColor   = ReadPreferenceInteger("OperatorColor", Settings\Colors\OperatorColor)
    Settings\Colors\ConstantColor   = ReadPreferenceInteger("ConstantColor", Settings\Colors\ConstantColor)
    
    ClosePreferences()
  EndIf
  
  ; Sync global active theme
  CurrentTheme = Settings\Colors
EndProcedure
