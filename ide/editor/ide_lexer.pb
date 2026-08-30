; ============================================================================
; Title:       ide_lexer.pb
; Description: Configuration du lexer Scintilla et coloration PureBasic + OOP
; Author:      Expert PureBasic OOP
; ============================================================================

EnableExplicit

XIncludeFile "ide_scintilla.pb"
XIncludeFile "../config/ide_settings.pb"
XIncludeFile "../data/ide_keywords.pb"

Procedure IDE_ApplyThemeAndLexer(gadgetId.i)
  Protected *utf8
  
  ; 1. Définition du Lexer PureBasic natif Scintilla
  IDE_SendSci(gadgetId, #SCI_SETLEXER, #SCLEX_PUREBASIC, 0)
  
  ; 2. Style par défaut
  *utf8 = UTF8(Settings\FontName)
  If *utf8
    IDE_SendSci(gadgetId, #SCI_STYLESETFONT, #STYLE_DEFAULT, *utf8)
    FreeMemory(*utf8)
  EndIf
  IDE_SendSci(gadgetId, #SCI_STYLESETSIZE, #STYLE_DEFAULT, Settings\FontSize)
  IDE_SendSci(gadgetId, #SCI_STYLESETFORE, #STYLE_DEFAULT, Settings\Colors\FgColor)
  IDE_SendSci(gadgetId, #SCI_STYLESETBACK, #STYLE_DEFAULT, Settings\Colors\BgColor)
  IDE_SendSci(gadgetId, #SCI_STYLECLEARALL, 0, 0) ; Propage aux autres styles
  
  ; 3. Marge des numéros de ligne
  If Settings\ShowLineNumbers
    IDE_SendSci(gadgetId, #SCI_SETMARGINTYPEN, 0, #SC_MARGIN_NUMBER)
    IDE_SendSci(gadgetId, #SCI_SETMARGINWIDTHN, 0, 48)
    IDE_SendSci(gadgetId, #SCI_SETMARGINSENSITIVEN, 0, 0)
    IDE_SendSci(gadgetId, #SCI_STYLESETFORE, #STYLE_LINENUMBER, Settings\Colors\LineNumberFg)
    IDE_SendSci(gadgetId, #SCI_STYLESETBACK, #STYLE_LINENUMBER, Settings\Colors\LineNumberBg)
  Else
    IDE_SendSci(gadgetId, #SCI_SETMARGINWIDTHN, 0, 0)
  EndIf
  
  ; 4. Curseur et sélection
  IDE_SendSci(gadgetId, #SCI_SETCARETFORE, Settings\Colors\CaretColor, 0)
  IDE_SendSci(gadgetId, #SCI_SETSELFORE, 1, Settings\Colors\SelectionFg)
  IDE_SendSci(gadgetId, #SCI_SETSELBACK, 1, Settings\Colors\SelectionBg)
  
  ; Ligne courante
  If Settings\HighlightCurrentLine
    IDE_SendSci(gadgetId, #SCI_SETCARETLINEVISIBLE, 1, 0)
    IDE_SendSci(gadgetId, #SCI_SETCARETLINEBACK, Settings\Colors\CurrentLineBg, 0)
  Else
    IDE_SendSci(gadgetId, #SCI_SETCARETLINEVISIBLE, 0, 0)
  EndIf
  
  ; Tabulation et indentation
  IDE_SendSci(gadgetId, #SCI_SETTABWIDTH, Settings\TabWidth, 0)
  IDE_SendSci(gadgetId, #SCI_SETINDENT, Settings\TabWidth, 0)
  IDE_SendSci(gadgetId, #SCI_SETUSETABS, 0, 0) ; Convertit tab en espaces
  
  ; 5. Coloration syntaxique par catégorie
  ; Identifiants standards
  IDE_SendSci(gadgetId, #SCI_STYLESETFORE, #SCE_B_IDENTIFIER, Settings\Colors\FgColor)
  IDE_SendSci(gadgetId, #SCI_STYLESETBACK, #SCE_B_IDENTIFIER, Settings\Colors\BgColor)
  
  ; Commentaires
  IDE_SendSci(gadgetId, #SCI_STYLESETFORE, #SCE_B_COMMENT, Settings\Colors\CommentColor)
  
  ; Chaînes
  IDE_SendSci(gadgetId, #SCI_STYLESETFORE, #SCE_B_STRING, Settings\Colors\StringColor)
  IDE_SendSci(gadgetId, #SCI_STYLESETFORE, #SCE_B_STRINGEOL, Settings\Colors\StringColor)
  
  ; Nombres
  IDE_SendSci(gadgetId, #SCI_STYLESETFORE, #SCE_B_NUMBER, Settings\Colors\NumberColor)
  IDE_SendSci(gadgetId, #SCI_STYLESETFORE, #SCE_B_HEXNUMBER, Settings\Colors\NumberColor)
  IDE_SendSci(gadgetId, #SCI_STYLESETFORE, #SCE_B_BINNUMBER, Settings\Colors\NumberColor)
  
  ; Mots-clés PureBasic Standard (KeyWord set 0 -> #SCE_B_KEYWORD)
  IDE_SendSci(gadgetId, #SCI_STYLESETFORE, #SCE_B_KEYWORD, Settings\Colors\KeywordPBColor)
  IDE_SendSci(gadgetId, #SCI_STYLESETBOLD, #SCE_B_KEYWORD, 1)
  
  ; Mots-clés PureBasic OOP (KeyWord set 1 -> #SCE_B_KEYWORD2)
  IDE_SendSci(gadgetId, #SCI_STYLESETFORE, #SCE_B_KEYWORD2, Settings\Colors\KeywordOOPColor)
  IDE_SendSci(gadgetId, #SCI_STYLESETBOLD, #SCE_B_KEYWORD2, 1)
  
  ; Fonctions intégrées (KeyWord set 2 -> #SCE_B_KEYWORD3 ou #SCE_B_KEYWORD4)
  IDE_SendSci(gadgetId, #SCI_STYLESETFORE, #SCE_B_KEYWORD3, Settings\Colors\FunctionColor)
  IDE_SendSci(gadgetId, #SCI_STYLESETFORE, #SCE_B_KEYWORD4, Settings\Colors\FunctionColor)
  
  ; Opérateurs
  IDE_SendSci(gadgetId, #SCI_STYLESETFORE, #SCE_B_OPERATOR, Settings\Colors\OperatorColor)
  
  ; Constantes
  IDE_SendSci(gadgetId, #SCI_STYLESETFORE, #SCE_B_CONSTANT, Settings\Colors\ConstantColor)
  
  ; 6. Envoi des listes de mots-clés au Lexer Scintilla
  ; Set 0 : Mots clés PB
  *utf8 = UTF8(IDE_GetPBKeywords())
  If *utf8
    IDE_SendSci(gadgetId, #SCI_SETKEYWORDS, 0, *utf8)
    FreeMemory(*utf8)
  EndIf
  
  ; Set 1 : Mots clés OOP
  *utf8 = UTF8(IDE_GetOOPKeywords())
  If *utf8
    IDE_SendSci(gadgetId, #SCI_SETKEYWORDS, 1, *utf8)
    FreeMemory(*utf8)
  EndIf
  
  ; Set 2 : Fonctions
  *utf8 = UTF8(IDE_GetPBFallbackFunctions())
  If *utf8
    IDE_SendSci(gadgetId, #SCI_SETKEYWORDS, 2, *utf8)
    FreeMemory(*utf8)
  EndIf
  
  ; Configuration de la complétion Scintilla
  IDE_SendSci(gadgetId, #SCI_AUTOCSETSEPARATOR, Asc(" "), 0)
  IDE_SendSci(gadgetId, #SCI_AUTOCSETIGNORECASE, 1, 0)
  IDE_SendSci(gadgetId, #SCI_AUTOCSETORDER, 1, 0) ; Trié
EndProcedure
