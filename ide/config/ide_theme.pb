; ============================================================================
; Title:       ide_theme.pb
; Description: Color theme definitions and presets for PureBasic OOP IDE
; Author:      MicrodevWeb
; ============================================================================

EnableExplicit

; ----------------------------------------------------------------------------
; Structure:   IDE_ThemeColors
; Purpose:     Stores RGB/BGR color values for editor background and syntax items
; ----------------------------------------------------------------------------
Structure IDE_ThemeColors
  BgColor.i            ; Editor background color
  FgColor.i            ; Default plain text color
  LineNumberBg.i       ; Line numbers margin background
  LineNumberFg.i       ; Line numbers text color
  SelectionBg.i        ; Selection background color
  SelectionFg.i        ; Selection text color
  CaretColor.i         ; Blinking cursor color
  CurrentLineBg.i      ; Active line highlight color
  
  ; Syntax token colors
  CommentColor.i       ; Comments (;)
  StringColor.i        ; String literals ("...")
  NumberColor.i        ; Integers and float literals
  KeywordPBColor.i     ; Standard PureBasic keywords (If, For, Select, etc.)
  KeywordOOPColor.i    ; OOP extension keywords (Class, Method, Super, This, New, etc.)
  FunctionColor.i      ; Built-in functions and procedure calls
  OperatorColor.i      ; Operators (+, -, *, =, \, ::)
  ConstantColor.i      ; Constants (#PB_Any, etc.)
EndStructure

Global CurrentTheme.IDE_ThemeColors

; ----------------------------------------------------------------------------
; Procedure:   IDE_Theme_SetDarkModern
; Purpose:     Applies VS Code Dark Modern style color values
; Parameters:  *theme - Pointer to IDE_ThemeColors structure
; Return:      None
; ----------------------------------------------------------------------------
Procedure IDE_Theme_SetDarkModern(*theme.IDE_ThemeColors)
  With *theme
    \BgColor         = $1E1E1E  ; Dark grey background (#1E1E1E)
    \FgColor         = $D4D4D4  ; Off-white plain text
    \LineNumberBg    = $252526  ; Margin background
    \LineNumberFg    = $858585  ; Neutral grey line numbers
    \SelectionBg     = $264F78  ; Blue selection highlight
    \SelectionFg     = $FFFFFF  ; White text inside selection
    \CaretColor      = $AEAFAD  ; Light grey caret
    \CurrentLineBg   = $2A2D2E  ; Active line highlight
    
    \CommentColor    = $6A9955  ; Soft green comments
    \StringColor     = $CE9178  ; Coral / orange string literals
    \NumberColor     = $B5CEA8  ; Light mint green numbers
    \KeywordPBColor  = $569CD6  ; VS Code blue for native PB keywords
    \KeywordOOPColor = $C586C0  ; Magenta / Purple for OOP keywords
    \FunctionColor   = $DCDCAA  ; Soft yellow for functions
    \OperatorColor   = $D4D4D4  ; Off-white operators
    \ConstantColor   = $4FC1FF  ; Light cyan constants
  EndWith
EndProcedure

; ----------------------------------------------------------------------------
; Procedure:   IDE_Theme_SetClassicPB
; Purpose:     Applies classic PureBasic IDE color values (light theme)
; Parameters:  *theme - Pointer to IDE_ThemeColors structure
; Return:      None
; ----------------------------------------------------------------------------
Procedure IDE_Theme_SetClassicPB(*theme.IDE_ThemeColors)
  With *theme
    \BgColor         = $FFFFFF  ; White background
    \FgColor         = $000000  ; Black text
    \LineNumberBg    = $F0F0F0  ; Light grey margin
    \LineNumberFg    = $808080  ; Grey line numbers
    \SelectionBg     = $C0C0C0  ; Silver selection
    \SelectionFg     = $000000  ; Black text
    \CaretColor      = $000000  ; Black caret
    \CurrentLineBg   = $EFEFEF  ; Active line highlight
    
    \CommentColor    = $008000  ; Green comments
    \StringColor     = $808080  ; Grey string literals
    \NumberColor     = $0000FF  ; Blue numbers
    \KeywordPBColor  = $006699  ; Dark blue native PB keywords
    \KeywordOOPColor = $990066  ; Dark purple for OOP keywords
    \FunctionColor   = $006666  ; Dark cyan functions
    \OperatorColor   = $000000  ; Black operators
    \ConstantColor   = $996600  ; Brown constants
  EndWith
EndProcedure

; Initialize default theme
IDE_Theme_SetDarkModern(@CurrentTheme)
