; ============================================================================
; Title:       ide_theme.pb
; Description: Gestion des thèmes et des couleurs de l'IDE PureBasic OOP
; Author:      Expert PureBasic OOP
; ============================================================================

EnableExplicit

Structure IDE_ThemeColors
  BgColor.i            ; Fond de l'éditeur
  FgColor.i            ; Texte standard
  LineNumberBg.i       ; Fond de la marge des numéros de ligne
  LineNumberFg.i       ; Texte des numéros de ligne
  SelectionBg.i        ; Fond de la sélection
  SelectionFg.i        ; Texte de la sélection
  CaretColor.i         ; Couleur du curseur clignotant
  CurrentLineBg.i      ; Surlignage de la ligne courante
  
  ; Coloration syntaxique
  CommentColor.i       ; Commentaires (;)
  StringColor.i        ; Chaînes ("...")
  NumberColor.i        ; Nombres entiers et flottants
  KeywordPBColor.i     ; Mots-clés PureBasic standard (If, For, Select, etc.)
  KeywordOOPColor.i    ; Mots-clés OOP (Class, Method, Super, This, New, etc.)
  FunctionColor.i      ; Fonctions et appels
  OperatorColor.i      ; Opérateurs (+, -, *, =, \, ::)
  ConstantColor.i      ; Constantes (#PB_Any, etc.)
EndStructure

Global CurrentTheme.IDE_ThemeColors

Procedure IDE_Theme_SetDarkModern(*theme.IDE_ThemeColors)
  With *theme
    \BgColor         = $1E1E1E  ; Gris très foncé (#1E1E1E en BGR)
    \FgColor         = $D4D4D4  ; Blanc cassé
    \LineNumberBg    = $252526  ; Fond marge
    \LineNumberFg    = $858585  ; Gris moyen
    \SelectionBg     = $264F78  ; Bleu foncé sélection
    \SelectionFg     = $FFFFFF  ; Blanc sélection
    \CaretColor      = $AEAFAD  ; Curseur
    \CurrentLineBg   = $2A2D2E  ; Ligne active
    
    \CommentColor    = $6A9955  ; Vert doux VS Code
    \StringColor     = $CE9178  ; Orange/corail doux
    \NumberColor     = $B5CEA8  ; Vert menthe clair
    \KeywordPBColor  = $569CD6  ; Bleu VS Code
    \KeywordOOPColor = $C586C0  ; Magenta / Violet moderne pour la POO
    \FunctionColor   = $DCDCAA  ; Jaune pâle
    \OperatorColor   = $D4D4D4  ; Blanc cassé
    \ConstantColor   = $4FC1FF  ; Cyan clair
  EndWith
EndProcedure

Procedure IDE_Theme_SetClassicPB(*theme.IDE_ThemeColors)
  With *theme
    \BgColor         = $FFFFFF  ; Fond blanc
    \FgColor         = $000000  ; Texte noir
    \LineNumberBg    = $F0F0F0  ; Fond gris très clair
    \LineNumberFg    = $808080  ; Gris
    \SelectionBg     = $C0C0C0  ; Gris sélection
    \SelectionFg     = $000000  ; Texte noir
    \CaretColor      = $000000  ; Curseur noir
    \CurrentLineBg   = $EFEFEF  ; Ligne active
    
    \CommentColor    = $008000  ; Vert standard
    \StringColor     = $808080  ; Gris chaîne standard PB
    \NumberColor     = $0000FF  ; Bleu
    \KeywordPBColor  = $006699  ; Bleu foncé PB
    \KeywordOOPColor = $990066  ; Pourpre/Magenta foncé pour la POO
    \FunctionColor   = $006666  ; Cyan foncé
    \OperatorColor   = $000000  ; Noir
    \ConstantColor   = $996600  ; Brun/Orange
  EndWith
EndProcedure

; Initialisation par défaut
IDE_Theme_SetDarkModern(@CurrentTheme)
