; ============================================================================
; Title:       ide_settings.pb
; Description: Gestion des paramètres utilisateurs (Autocomplétion, Auto-close, Thème)
; Author:      Expert PureBasic OOP
; ============================================================================

EnableExplicit

XIncludeFile "ide_theme.pb"

Structure IDE_Settings
  ; Autocomplétion
  AutocompleteMinChars.i    ; Nombre de caractères avant déclenchement (défaut : 2)
  AutocompleteEnabled.b     ; #True / #False
  
  ; Auto-fermeture
  AutoCloseBlocks.b         ; Fermeture automatique de If/EndIf, Class/EndClass, etc.
  AutoCloseBrackets.b       ; Fermeture des paires (), [], {}, ""
  
  ; Police & Affichage
  FontName.s                ; Ex: "Consolas" ou "Courier New"
  FontSize.i                ; Ex: 11
  TabWidth.i                ; Ex: 2 ou 4 espaces
  ShowLineNumbers.b         ; #True / #False
  HighlightCurrentLine.b    ; #True / #False
  
  ; Compilateur & Chemins
  CompilerPath.s            ; Chemin vers pbcompiler.exe
  LastOpenedFile.s          ; Dernier fichier ouvert
  
  ; Thème actif
  ThemeName.s               ; "Dark Modern", "Classic PureBasic", "Custom"
  Colors.IDE_ThemeColors    ; Couleurs personnalisées
EndStructure

Global Settings.IDE_Settings

Procedure.s IDE_Settings_GetConfigFile()
  Protected appDir.s = GetPathPart(ProgramFilename())
  If appDir = "" Or Not FileSize(appDir) = -2
    appDir = GetCurrentDirectory()
  EndIf
  ProcedureReturn appDir + "ide_settings.prefs"
EndProcedure

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
  
  ; Synchroniser le CurrentTheme global
  CurrentTheme = Settings\Colors
EndProcedure
