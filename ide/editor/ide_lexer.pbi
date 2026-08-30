; ============================================================================
; Title:       ide_lexer.pb
; Description: Scintilla syntax lexer configuration for PureBasic and OOP keywords
; Author:      MicrodevWeb
; ============================================================================

EnableExplicit

XIncludeFile "ide_scintilla.pbi"
XIncludeFile "../config/ide_settings.pbi"
XIncludeFile "../data/ide_keywords.pbi"

; ----------------------------------------------------------------------------
; Procedure:   IDE_ApplyThemeAndLexer
; Purpose:     Applies lexer styles, fonts, margins, and keywords to Scintilla gadget
; Parameters:  gadgetId.i - Target Scintilla gadget ID
; Return:      None
; ----------------------------------------------------------------------------
Procedure IDE_ApplyThemeAndLexer(gadgetId.i)
  Protected *utf8
  
  ; 1. Set native PureBasic Scintilla lexer
  IDE_SendSci(gadgetId, #SCI_SETLEXER, #SCLEX_PUREBASIC, 0)
  
  ; 2. Default font and base colors
  *utf8 = UTF8(Settings\FontName)
  If *utf8
    IDE_SendSci(gadgetId, #SCI_STYLESETFONT, #STYLE_DEFAULT, *utf8)
    FreeMemory(*utf8)
  EndIf
  IDE_SendSci(gadgetId, #SCI_STYLESETSIZE, #STYLE_DEFAULT, Settings\FontSize)
  IDE_SendSci(gadgetId, #SCI_STYLESETFORE, #STYLE_DEFAULT, Settings\Colors\FgColor)
  IDE_SendSci(gadgetId, #SCI_STYLESETBACK, #STYLE_DEFAULT, Settings\Colors\BgColor)
  IDE_SendSci(gadgetId, #SCI_STYLECLEARALL, 0, 0) ; Clear and propagate base styles
  
  ; 3. Line numbers margin configuration
  If Settings\ShowLineNumbers
    IDE_SendSci(gadgetId, #SCI_SETMARGINTYPEN, 0, #SC_MARGIN_NUMBER)
    IDE_SendSci(gadgetId, #SCI_SETMARGINWIDTHN, 0, 48)
    IDE_SendSci(gadgetId, #SCI_SETMARGINSENSITIVEN, 0, 0)
    IDE_SendSci(gadgetId, #SCI_STYLESETFORE, #STYLE_LINENUMBER, Settings\Colors\LineNumberFg)
    IDE_SendSci(gadgetId, #SCI_STYLESETBACK, #STYLE_LINENUMBER, Settings\Colors\LineNumberBg)
  Else
    IDE_SendSci(gadgetId, #SCI_SETMARGINWIDTHN, 0, 0)
  EndIf
  
  ; 4. Caret and selection styling
  IDE_SendSci(gadgetId, #SCI_SETCARETFORE, Settings\Colors\CaretColor, 0)
  IDE_SendSci(gadgetId, #SCI_SETSELFORE, 1, Settings\Colors\SelectionFg)
  IDE_SendSci(gadgetId, #SCI_SETSELBACK, 1, Settings\Colors\SelectionBg)
  
  ; Active line highlight
  If Settings\HighlightCurrentLine
    IDE_SendSci(gadgetId, #SCI_SETCARETLINEVISIBLE, 1, 0)
    IDE_SendSci(gadgetId, #SCI_SETCARETLINEBACK, Settings\Colors\CurrentLineBg, 0)
  Else
    IDE_SendSci(gadgetId, #SCI_SETCARETLINEVISIBLE, 0, 0)
  EndIf
  
  ; Ensure editor is writable and not read-only
  IDE_SendSci(gadgetId, #SCI_SETREADONLY, 0, 0)
  
  ; Tabulation and indentation settings
  IDE_SendSci(gadgetId, #SCI_SETTABWIDTH, Settings\TabWidth, 0)
  IDE_SendSci(gadgetId, #SCI_SETINDENT, Settings\TabWidth, 0)
  IDE_SendSci(gadgetId, #SCI_SETUSETABS, 0, 0) ; Converts tab key to spaces
  
  ; 5. Syntax token colors
  ; Default identifiers
  IDE_SendSci(gadgetId, #SCI_STYLESETFORE, #SCE_B_IDENTIFIER, Settings\Colors\FgColor)
  IDE_SendSci(gadgetId, #SCI_STYLESETBACK, #SCE_B_IDENTIFIER, Settings\Colors\BgColor)
  
  ; Comments
  IDE_SendSci(gadgetId, #SCI_STYLESETFORE, #SCE_B_COMMENT, Settings\Colors\CommentColor)
  
  ; String literals
  IDE_SendSci(gadgetId, #SCI_STYLESETFORE, #SCE_B_STRING, Settings\Colors\StringColor)
  IDE_SendSci(gadgetId, #SCI_STYLESETFORE, #SCE_B_STRINGEOL, Settings\Colors\StringColor)
  
  ; Number literals
  IDE_SendSci(gadgetId, #SCI_STYLESETFORE, #SCE_B_NUMBER, Settings\Colors\NumberColor)
  IDE_SendSci(gadgetId, #SCI_STYLESETFORE, #SCE_B_HEXNUMBER, Settings\Colors\NumberColor)
  IDE_SendSci(gadgetId, #SCI_STYLESETFORE, #SCE_B_BINNUMBER, Settings\Colors\NumberColor)
  
  ; Standard PureBasic keywords (KeyWord set 0 -> #SCE_B_KEYWORD)
  IDE_SendSci(gadgetId, #SCI_STYLESETFORE, #SCE_B_KEYWORD, Settings\Colors\KeywordPBColor)
  IDE_SendSci(gadgetId, #SCI_STYLESETBOLD, #SCE_B_KEYWORD, 1)
  
  ; OOP extension keywords (KeyWord set 1 -> #SCE_B_KEYWORD2)
  IDE_SendSci(gadgetId, #SCI_STYLESETFORE, #SCE_B_KEYWORD2, Settings\Colors\KeywordOOPColor)
  IDE_SendSci(gadgetId, #SCI_STYLESETBOLD, #SCE_B_KEYWORD2, 1)
  
  ; Built-in functions (KeyWord set 2 -> #SCE_B_KEYWORD3 / #SCE_B_KEYWORD4)
  IDE_SendSci(gadgetId, #SCI_STYLESETFORE, #SCE_B_KEYWORD3, Settings\Colors\FunctionColor)
  IDE_SendSci(gadgetId, #SCI_STYLESETFORE, #SCE_B_KEYWORD4, Settings\Colors\FunctionColor)
  
  ; Operators
  IDE_SendSci(gadgetId, #SCI_STYLESETFORE, #SCE_B_OPERATOR, Settings\Colors\OperatorColor)
  
  ; Constants
  IDE_SendSci(gadgetId, #SCI_STYLESETFORE, #SCE_B_CONSTANT, Settings\Colors\ConstantColor)
  
  ; 6. Send keyword wordlists to Scintilla lexer
  ; Set 0: Native PB keywords
  *utf8 = UTF8(IDE_GetPBKeywords())
  If *utf8
    IDE_SendSci(gadgetId, #SCI_SETKEYWORDS, 0, *utf8)
    FreeMemory(*utf8)
  EndIf
  
  ; Set 1: OOP extension keywords
  *utf8 = UTF8(IDE_GetOOPKeywords())
  If *utf8
    IDE_SendSci(gadgetId, #SCI_SETKEYWORDS, 1, *utf8)
    FreeMemory(*utf8)
  EndIf
  
  ; Set 2: Built-in functions
  *utf8 = UTF8(IDE_GetPBFallbackFunctions())
  If *utf8
    IDE_SendSci(gadgetId, #SCI_SETKEYWORDS, 2, *utf8)
    FreeMemory(*utf8)
  EndIf
  
  ; Autocomplete options in Scintilla
  IDE_SendSci(gadgetId, #SCI_AUTOCSETSEPARATOR, Asc(" "), 0)
  IDE_SendSci(gadgetId, #SCI_AUTOCSETIGNORECASE, 1, 0)
  IDE_SendSci(gadgetId, #SCI_AUTOCSETORDER, 1, 0) ; Strictly sorted order
EndProcedure
