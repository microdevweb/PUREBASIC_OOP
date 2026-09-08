; ============================================================================
; PureBasic OOP GUI Framework - CanvasText.pbi
; Modern WPF/WinUI-style 2D Vector-rendered TextBlock / Label Control
; Features: Horizontal and Vertical alignment, Text Truncation with Ellipsis (...),
;           Transparent or Solid Background, Custom Typography & High-DPI Scaling,
;           MVVM Two-Way/One-Way DataBinding support.
; Author:      MicrodevWeb
; ============================================================================

XIncludeFile "../CanvasControl.pbi"

#UI_TextAlign_Left    = 0
#UI_TextAlign_Center  = 1
#UI_TextAlign_Right   = 2

#UI_TextAlign_Top     = 0
#UI_TextAlign_Middle  = 1
#UI_TextAlign_Bottom  = 2

Namespace UI {

  Class CanvasText Extends CanvasControl {
    Protected hAlign.i
    Protected vAlign.i
    Protected showEllipsis.b
    Protected isTransparent.b

    ; Constructeur 1: Par défaut (100x24, "")
    Public Method Init() {
      Super\Init(100, 24)
      This\text = ""
      This\hAlign = #UI_TextAlign_Left
      This\vAlign = #UI_TextAlign_Middle
      This\showEllipsis = #True
      This\isTransparent = #True
      This\borderThickness = 0
      This\cornerRadius = 0
      This\paddingLeft = 0
      This\paddingTop = 0
      This\paddingRight = 0
      This\paddingBottom = 0
      This\background = RGB(255, 255, 255)
      This\foreground = RGB(33, 37, 41)
      This\Redraw()
    }

    ; Constructeur 2: Texte seul (100x24)
    Public Method Init(text_p.s) {
      Super\Init(100, 24)
      This\text = text_p
      This\hAlign = #UI_TextAlign_Left
      This\vAlign = #UI_TextAlign_Middle
      This\showEllipsis = #True
      This\isTransparent = #True
      This\borderThickness = 0
      This\cornerRadius = 0
      This\paddingLeft = 0
      This\paddingTop = 0
      This\paddingRight = 0
      This\paddingBottom = 0
      This\background = RGB(255, 255, 255)
      This\foreground = RGB(33, 37, 41)
      This\Redraw()
    }

    ; Constructeur 3: Texte et dimensions
    Public Method Init(text_p.s, w_p.i, h_p.i) {
      Super\Init(w_p, h_p)
      This\text = text_p
      This\hAlign = #UI_TextAlign_Left
      This\vAlign = #UI_TextAlign_Middle
      This\showEllipsis = #True
      This\isTransparent = #True
      This\borderThickness = 0
      This\cornerRadius = 0
      This\paddingLeft = 0
      This\paddingTop = 0
      This\paddingRight = 0
      This\paddingBottom = 0
      This\background = RGB(255, 255, 255)
      This\foreground = RGB(33, 37, 41)
      This\Redraw()
    }

    ; Constructeur 4: Position, dimensions et texte
    Public Method Init(x_p.i, y_p.i, w_p.i, h_p.i, text_p.s) {
      Super\Init(x_p, y_p, w_p, h_p)
      This\text = text_p
      This\hAlign = #UI_TextAlign_Left
      This\vAlign = #UI_TextAlign_Middle
      This\showEllipsis = #True
      This\isTransparent = #True
      This\borderThickness = 0
      This\cornerRadius = 0
      This\paddingLeft = 0
      This\paddingTop = 0
      This\paddingRight = 0
      This\paddingBottom = 0
      This\background = RGB(255, 255, 255)
      This\foreground = RGB(33, 37, 41)
      This\Redraw()
    }

    ; --- Alignement & Propriétés de Texte ---

    Public Method SetAlignment(horizontal_p.i, vertical_p.i = #UI_TextAlign_Middle) {
      This\hAlign = horizontal_p
      This\vAlign = vertical_p
      This\Redraw()
    }

    Public Method.i GetHorizontalAlignment() {
      ProcedureReturn This\hAlign
    }

    Public Method.i GetVerticalAlignment() {
      ProcedureReturn This\vAlign
    }

    Public Method SetEllipsis(enabled_p.b) {
      This\showEllipsis = enabled_p
      This\Redraw()
    }

    Public Method.b GetEllipsis() {
      ProcedureReturn This\showEllipsis
    }

    Public Method SetTransparent(transparent_p.b) {
      This\isTransparent = transparent_p
      This\Redraw()
    }

    Public Method.b IsTransparent() {
      ProcedureReturn This\isTransparent
    }

    ; --- Troncature intelligente avec Ellipsis (...) ---
    Protected Method.s FormatDisplayText(availWidth_p.i) {
      If availWidth_p <= 0 : ProcedureReturn "" : EndIf
      If TextWidth(This\text) <= availWidth_p
        ProcedureReturn This\text
      EndIf

      If (Not This\showEllipsis)
        ProcedureReturn This\text
      EndIf

      Protected dots.s = "..."
      Protected dotsW.i = TextWidth(dots)
      If dotsW >= availWidth_p
        ProcedureReturn "."
      EndIf

      Protected maxW.i = availWidth_p - dotsW
      Protected len.i = Len(This\text)
      Protected sub.s = This\text

      While (len > 0 And TextWidth(sub) > maxW)
        len - 1
        sub = Left(This\text, len)
      Wend

      ProcedureReturn sub + dots
    }

    ; --- Rendu Vectoriel Moderne (OnPaint) ---

    Public Method OnPaint(w_p.i, h_p.i) {
      ; 1. Fond
      If (Not This\isTransparent) Or This\borderThickness > 0
        This\DrawControlBackground(w_p, h_p)
      Else
        ; Effacement avec la couleur de fond de base
        Box(0, 0, w_p, h_p, This\background)
      EndIf

      ; 2. Police
      If (This\fontID)
        DrawingFont(This\fontID)
      EndIf

      If This\text = "" : ProcedureReturn : EndIf

      Protected padL.i = DesktopScaledX(This\paddingLeft)
      Protected padT.i = DesktopScaledY(This\paddingTop)
      Protected padR.i = DesktopScaledX(This\paddingRight)
      Protected padB.i = DesktopScaledY(This\paddingBottom)

      Protected availW.i = w_p - padL - padR
      Protected availH.i = h_p - padT - padB
      If availW < 0 : availW = 0 : EndIf
      If availH < 0 : availH = 0 : EndIf

      Protected dispText.s = This\FormatDisplayText(availW)
      Protected txtW.i = TextWidth(dispText)
      Protected txtH.i = TextHeight(dispText)

      ; Calcul X selon hAlign
      Protected posX.i = padL
      Select (This\hAlign)
        Case #UI_TextAlign_Center:
          posX = padL + (availW - txtW) / 2
        Case #UI_TextAlign_Right:
          posX = w_p - padR - txtW
      EndSelect

      ; Calcul Y selon vAlign
      Protected posY.i = padT
      Select (This\vAlign)
        Case #UI_TextAlign_Middle:
          posY = padT + (availH - txtH) / 2
        Case #UI_TextAlign_Bottom:
          posY = h_p - padB - txtH
      EndSelect

      Protected fg.i = This\GetCurrentForegroundColor()
      DrawText(posX, posY, dispText, fg, This\background)
    }

  }

}
