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
; Procedure:   IDE_ToAscii
; Purpose:     Returns ASCII pointer for Scintilla commands
; Parameters:  strVal.s - Unicode string
; Return:      Pointer to ASCII memory buffer
; ----------------------------------------------------------------------------
Procedure.i IDE_ToAscii(strVal.s)
  Static *asciiBuffer = 0
  Static bufferLength.i = 0
  
  Protected needLen.i = Len(strVal) + 1
  If bufferLength < needLen
    If *asciiBuffer : FreeMemory(*asciiBuffer) : EndIf
    *asciiBuffer = AllocateMemory(needLen + 16, #PB_Memory_NoClear)
    bufferLength = needLen + 16
  EndIf
  
  PokeS(*asciiBuffer, strVal, -1, #PB_Ascii)
  ProcedureReturn *asciiBuffer
EndProcedure

; ----------------------------------------------------------------------------
; Procedure:   IDE_ApplyThemeAndLexer
; Purpose:     Applies lexer styles, fonts, margins, and keywords to Scintilla gadget
; Parameters:  gadgetId.i - Target Scintilla gadget ID
; Return:      None
; ----------------------------------------------------------------------------
Procedure IDE_ApplyThemeAndLexer(gadgetId.i)
  Protected *asciiPtr
  
  ; 1. Set native PureBasic Scintilla lexer
  IDE_SendSci(gadgetId, #SCI_SETLEXER, #SCLEX_PUREBASIC, 0)
  
  ; 2. Default font and base colors
  *asciiPtr = IDE_ToAscii(Settings\FontName)
  If *asciiPtr
    IDE_SendSci(gadgetId, #SCI_STYLESETFONT, #STYLE_DEFAULT, *asciiPtr)
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
  
  ; 5. Syntax token colors for SCLEX_PUREBASIC
  ; Default identifiers (0 and 7)
  IDE_SendSci(gadgetId, #SCI_STYLESETFORE, #SCE_B_DEFAULT, Settings\Colors\FgColor)
  IDE_SendSci(gadgetId, #SCI_STYLESETBACK, #SCE_B_DEFAULT, Settings\Colors\BgColor)
  IDE_SendSci(gadgetId, #SCI_STYLESETFORE, #SCE_B_IDENTIFIER, Settings\Colors\FgColor)
  IDE_SendSci(gadgetId, #SCI_STYLESETBACK, #SCE_B_IDENTIFIER, Settings\Colors\BgColor)
  
  ; Comments (1)
  IDE_SendSci(gadgetId, #SCI_STYLESETFORE, #SCE_B_COMMENT, Settings\Colors\CommentColor)
  
  ; Number literals (2, 17, 18)
  IDE_SendSci(gadgetId, #SCI_STYLESETFORE, #SCE_B_NUMBER, Settings\Colors\NumberColor)
  IDE_SendSci(gadgetId, #SCI_STYLESETFORE, #SCE_B_HEXNUMBER, Settings\Colors\NumberColor)
  IDE_SendSci(gadgetId, #SCI_STYLESETFORE, #SCE_B_BINNUMBER, Settings\Colors\NumberColor)
  
  ; Standard PureBasic keywords (3 -> #SCE_B_KEYWORD)
  IDE_SendSci(gadgetId, #SCI_STYLESETFORE, #SCE_B_KEYWORD, Settings\Colors\KeywordPBColor)
  IDE_SendSci(gadgetId, #SCI_STYLESETBOLD, #SCE_B_KEYWORD, 1)
  
  ; String literals (4, 9)
  IDE_SendSci(gadgetId, #SCI_STYLESETFORE, #SCE_B_STRING, Settings\Colors\StringColor)
  IDE_SendSci(gadgetId, #SCI_STYLESETFORE, #SCE_B_STRINGEOL, Settings\Colors\StringColor)
  
  ; Preprocessor & Operators (5, 6)
  IDE_SendSci(gadgetId, #SCI_STYLESETFORE, #SCE_B_PREPROCESSOR, Settings\Colors\OperatorColor)
  IDE_SendSci(gadgetId, #SCI_STYLESETFORE, #SCE_B_OPERATOR, Settings\Colors\OperatorColor)
  
  ; OOP extension keywords (10 -> #SCE_B_KEYWORD2)
  IDE_SendSci(gadgetId, #SCI_STYLESETFORE, #SCE_B_KEYWORD2, Settings\Colors\KeywordOOPColor)
  IDE_SendSci(gadgetId, #SCI_STYLESETBOLD, #SCE_B_KEYWORD2, 1)
  
  ; Built-in functions (11, 12 -> #SCE_B_KEYWORD3 / #SCE_B_KEYWORD4)
  IDE_SendSci(gadgetId, #SCI_STYLESETFORE, #SCE_B_KEYWORD3, Settings\Colors\FunctionColor)
  IDE_SendSci(gadgetId, #SCI_STYLESETFORE, #SCE_B_KEYWORD4, Settings\Colors\FunctionColor)
  
  ; Constants (13 -> #SCE_B_CONSTANT)
  IDE_SendSci(gadgetId, #SCI_STYLESETFORE, #SCE_B_CONSTANT, Settings\Colors\ConstantColor)
  
  ; ASM (14 -> #SCE_B_ASM)
  IDE_SendSci(gadgetId, #SCI_STYLESETFORE, #SCE_B_ASM, Settings\Colors\OperatorColor)
  
  ; 6. Send keyword wordlists to Scintilla lexer (ASCII encoded as expected by Scintilla)
  ; Set 0: Native PB keywords
  *asciiPtr = IDE_ToAscii(IDE_GetPBKeywords())
  If *asciiPtr
    IDE_SendSci(gadgetId, #SCI_SETKEYWORDS, 0, *asciiPtr)
  EndIf
  
  ; Set 1: OOP extension keywords
  *asciiPtr = IDE_ToAscii(IDE_GetOOPKeywords())
  If *asciiPtr
    IDE_SendSci(gadgetId, #SCI_SETKEYWORDS, 1, *asciiPtr)
  EndIf
  
  ; Set 2: Built-in functions
  *asciiPtr = IDE_ToAscii(IDE_GetPBFallbackFunctions())
  If *asciiPtr
    IDE_SendSci(gadgetId, #SCI_SETKEYWORDS, 2, *asciiPtr)
  EndIf
  
  ; Autocomplete options in Scintilla
  IDE_SendSci(gadgetId, #SCI_AUTOCSETSEPARATOR, Asc(" "), 0)
  IDE_SendSci(gadgetId, #SCI_AUTOCSETIGNORECASE, 1, 0)
  IDE_SendSci(gadgetId, #SCI_AUTOCSETORDER, 1, 0) ; Strictly sorted order
EndProcedure
