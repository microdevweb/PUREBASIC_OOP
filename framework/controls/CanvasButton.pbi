; ============================================================================
; PureBasic OOP GUI Framework - CanvasButton.pbi
; Modern WPF/WinUI-style 2D Vector-rendered Canvas Button Control
; Features: Visual States (Normal, Hover, Pressed, Focused, Disabled),
;           WPF Styling Tokens (CornerRadius, Padding, Borders, Palette presets),
;           Vector rounded background, Optional Icon support, High-DPI text alignment,
;           Full MVVM Command and Two-Way Hover/Pressed Property DataBinding.
; Author:      MicrodevWeb
; ============================================================================

XIncludeFile "../CanvasControl.pbi"

Namespace UI {

  Class CanvasButton Extends CanvasControl {
    Protected iconImage.i
    Protected iconSpacing.i
    Protected textAlignment.i ; 0: Center, 1: Left, 2: Right

    ; Constructeur 1: Par défaut (100x32, "")
    Public Method Init() {
      Super\Init(100, 32)
      This\text = "Button"
      This\cornerRadius = 6
      This\borderThickness = 1
      This\iconImage = 0
      This\iconSpacing = 6
      This\textAlignment = 0
      This\animateHoverScale = #True
      This\SetDefaultStyle()
      This\Redraw()
    }

    ; Constructeur 2: Texte seul (100x32)
    Public Method Init(text_p.s) {
      Super\Init(100, 32)
      This\text = text_p
      This\cornerRadius = 6
      This\borderThickness = 1
      This\iconImage = 0
      This\iconSpacing = 6
      This\textAlignment = 0
      This\animateHoverScale = #True
      This\SetDefaultStyle()
      This\Redraw()
    }

    ; Constructeur 3: Texte et dimensions
    Public Method Init(text_p.s, w_p.i, h_p.i) {
      Super\Init(w_p, h_p)
      This\text = text_p
      This\cornerRadius = 6
      This\borderThickness = 1
      This\iconImage = 0
      This\iconSpacing = 6
      This\textAlignment = 0
      This\animateHoverScale = #True
      This\SetDefaultStyle()
      This\Redraw()
    }

    ; Constructeur 4: Position, dimensions et texte
    Public Method Init(x_p.i, y_p.i, w_p.i, h_p.i, text_p.s) {
      Super\Init(x_p, y_p, w_p, h_p)
      This\text = text_p
      This\cornerRadius = 6
      This\borderThickness = 1
      This\iconImage = 0
      This\iconSpacing = 6
      This\textAlignment = 0
      This\animateHoverScale = #True
      This\SetDefaultStyle()
      This\Redraw()
    }

    ; --- Palettes Prédéfinies Modernes (WPF / WinUI 3 / Tailwind) ---

    Public Method SetDefaultStyle() {
      This\background = RGB(243, 244, 246)
      This\foreground = RGB(17, 24, 39)
      This\hoverBackground = RGB(229, 231, 235)
      This\hoverForeground = RGB(17, 24, 39)
      This\pressedBackground = RGB(209, 213, 219)
      This\pressedForeground = RGB(17, 24, 39)
      This\disabledBackground = RGB(243, 244, 246)
      This\disabledForeground = RGB(156, 163, 175)

      This\borderColor = RGB(209, 213, 219)
      This\hoverBorderColor = RGB(156, 163, 175)
      This\pressedBorderColor = RGB(107, 114, 128)
      This\Redraw()
    }

    Public Method SetPrimaryStyle() {
      This\background = RGB(37, 99, 235)       ; Blue 600
      This\foreground = RGB(255, 255, 255)
      This\hoverBackground = RGB(29, 78, 216)   ; Blue 700
      This\hoverForeground = RGB(255, 255, 255)
      This\pressedBackground = RGB(30, 64, 175) ; Blue 800
      This\pressedForeground = RGB(255, 255, 255)
      This\disabledBackground = RGB(191, 219, 254)
      This\disabledForeground = RGB(255, 255, 255)

      This\borderColor = RGB(29, 78, 216)
      This\hoverBorderColor = RGB(30, 64, 175)
      This\pressedBorderColor = RGB(23, 37, 84)
      This\Redraw()
    }

    Public Method SetSuccessStyle() {
      This\background = RGB(22, 163, 74)       ; Green 600
      This\foreground = RGB(255, 255, 255)
      This\hoverBackground = RGB(21, 128, 61)   ; Green 700
      This\hoverForeground = RGB(255, 255, 255)
      This\pressedBackground = RGB(22, 101, 52) ; Green 800
      This\pressedForeground = RGB(255, 255, 255)
      This\disabledBackground = RGB(187, 247, 208)
      This\disabledForeground = RGB(255, 255, 255)

      This\borderColor = RGB(21, 128, 61)
      This\hoverBorderColor = RGB(22, 101, 52)
      This\pressedBorderColor = RGB(20, 83, 45)
      This\Redraw()
    }

    Public Method SetDangerStyle() {
      This\background = RGB(220, 38, 38)       ; Red 600
      This\foreground = RGB(255, 255, 255)
      This\hoverBackground = RGB(185, 28, 28)   ; Red 700
      This\hoverForeground = RGB(255, 255, 255)
      This\pressedBackground = RGB(153, 27, 27) ; Red 800
      This\pressedForeground = RGB(255, 255, 255)
      This\disabledBackground = RGB(254, 202, 202)
      This\disabledForeground = RGB(255, 255, 255)

      This\borderColor = RGB(185, 28, 28)
      This\hoverBorderColor = RGB(153, 27, 27)
      This\pressedBorderColor = RGB(127, 29, 29)
      This\Redraw()
    }

    Public Method SetDarkStyle() {
      This\background = RGB(30, 41, 59)        ; Slate 800
      This\foreground = RGB(248, 250, 252)     ; Slate 50
      This\hoverBackground = RGB(51, 65, 85)   ; Slate 700
      This\hoverForeground = RGB(255, 255, 255)
      This\pressedBackground = RGB(15, 23, 42) ; Slate 900
      This\pressedForeground = RGB(255, 255, 255)
      This\disabledBackground = RGB(100, 116, 139)
      This\disabledForeground = RGB(148, 163, 184)

      This\borderColor = RGB(51, 65, 85)
      This\hoverBorderColor = RGB(71, 85, 105)
      This\pressedBorderColor = RGB(15, 23, 42)
      This\Redraw()
    }

    Public Method SetOutlineStyle(baseColor_p.i) {
      This\background = RGB(255, 255, 255)
      This\foreground = baseColor_p
      This\borderColor = baseColor_p
      This\borderThickness = 1

      ; Hover légèrement teinté
      This\hoverBackground = RGB(241, 245, 249)
      This\hoverForeground = baseColor_p
      This\hoverBorderColor = baseColor_p

      ; Pressed un peu plus soutenu
      This\pressedBackground = RGB(226, 232, 240)
      This\pressedForeground = baseColor_p
      This\pressedBorderColor = baseColor_p

      This\disabledBackground = RGB(255, 255, 255)
      This\disabledForeground = RGB(203, 213, 225)
      This\Redraw()
    }

    Public Method SetGhostStyle(baseColor_p.i) {
      This\background = RGB(255, 255, 255)
      This\foreground = baseColor_p
      This\borderColor = RGB(255, 255, 255)
      This\borderThickness = 0

      This\hoverBackground = RGB(241, 245, 249)
      This\hoverForeground = baseColor_p
      This\hoverBorderColor = RGB(241, 245, 249)

      This\pressedBackground = RGB(226, 232, 240)
      This\pressedForeground = baseColor_p
      This\pressedBorderColor = RGB(226, 232, 240)

      This\disabledBackground = RGB(255, 255, 255)
      This\disabledForeground = RGB(203, 213, 225)
      This\Redraw()
    }

    ; --- Icône et Alignement ---

    Public Method SetIcon(img_p.i) {
      This\iconImage = img_p
      This\iconSpacing = 6
      This\Redraw()
    }

    Public Method SetIcon(img_p.i, spacing_p.i) {
      This\iconImage = img_p
      This\iconSpacing = spacing_p
      This\Redraw()
    }

    Public Method.i GetIcon() {
      ProcedureReturn This\iconImage
    }

    Public Method SetTextAlignment(align_p.i) {
      This\textAlignment = align_p
      This\Redraw()
    }

    ; --- Rendu Vectoriel Moderne (OnPaint) ---

    Public Method OnPaint(w_p.i, h_p.i) {
      ; 1. Fond et bordure arrondis selon l'état visuel actif
      This\DrawControlBackground(w_p, h_p)

      ; 2. Anneau de focus si le gadget a le focus clavier
      This\DrawFocusRing(w_p, h_p)

      ; 3. Préparation de la police et du texte
      If (This\fontID)
        DrawingFont(This\fontID)
      EndIf

      Protected fg.i = This\GetCurrentForegroundColor()
      Protected padL.i = DesktopScaledX(This\paddingLeft)
      Protected padR.i = DesktopScaledX(This\paddingRight)
      Protected contentW.i = w_p - padL - padR
      If contentW < 0 : contentW = 0 : EndIf

      Protected txtW.i = 0
      Protected txtH.i = 0
      If This\text <> ""
        txtW = TextWidth(This\text)
        txtH = TextHeight(This\text)
      EndIf

      Protected iconW.i = 0
      Protected iconH.i = 0
      Protected sp.i = 0
      If This\iconImage And IsImage(This\iconImage)
        iconW = DesktopScaledX(ImageWidth(This\iconImage))
        iconH = DesktopScaledY(ImageHeight(This\iconImage))
        If This\text <> ""
          sp = DesktopScaledX(This\iconSpacing)
        EndIf
      EndIf

      Protected totalW.i = iconW + sp + txtW
      Protected startX.i = padL

      Select This\textAlignment
        Case 0: ; Centré
          startX = (w_p - totalW) / 2
        Case 1: ; Gauche
          startX = padL
        Case 2: ; Droite
          startX = w_p - padR - totalW
      EndSelect

      If startX < padL : startX = padL : EndIf

      ; 4. Dessin de l'icône si présente
      If This\iconImage And IsImage(This\iconImage)
        Protected iconY.i = (h_p - iconH) / 2
        DrawAlphaImage(ImageID(This\iconImage), startX, iconY)
        startX + iconW + sp
      EndIf

      ; 5. Dessin du texte
      If This\text <> ""
        Protected txtY.i = (h_p - txtH) / 2
        DrawingMode(#PB_2DDrawing_Transparent)
        DrawText(startX, txtY, This\text, fg)
      EndIf
    }

    Public Method ApplyStyle(*s.UI::Style) {
      Super\ApplyStyle(*s)
      If Not *s : ProcedureReturn : EndIf
      Protected count.i = *s\GetSetterCount()
      Protected i.i
      For i = 0 To count - 1
        Protected prop.s = UCase(Trim(*s\GetSetterProperty(i)))
        Protected val.s = Trim(*s\GetSetterValue(i))
        If prop = "TEXTALIGNMENT" Or prop = "HALIGN"
          If UCase(val) = "LEFT" : This\textAlignment = 1
          ElseIf UCase(val) = "RIGHT" : This\textAlignment = 2
          ElseIf UCase(val) = "CENTER" : This\textAlignment = 0
          EndIf
        EndIf
      Next
      This\Redraw()
    }

  }

}
