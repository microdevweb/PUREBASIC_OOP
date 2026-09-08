; ============================================================================
; PureBasic OOP GUI Framework - CanvasControl.pbi
; Universal Base Class for WPF/WinUI-style 2D Vector-rendered Canvas Controls
; Features: Visual State Machine (Normal, Hover, Pressed, Focused, Disabled),
;           WPF Styling Tokens (Background, Foreground, Border, CornerRadius, Padding),
;           High-DPI dynamic scaling, Input event routing, and MVVM Two-Way Bindings.
; Author:      MicrodevWeb
; ============================================================================

XIncludeFile "Gadget.pbi"
XIncludeFile "Application.pbi"
XIncludeFile "style/Style.pbi"

; ----------------------------------------------------------------------------
; Visual States (WPF VisualStateManager style)
; ----------------------------------------------------------------------------
#UI_VisualState_Normal   = 0
#UI_VisualState_Hover    = 1
#UI_VisualState_Pressed  = 2
#UI_VisualState_Focused  = 3
#UI_VisualState_Disabled = 4

Namespace UI {

  ; ==========================================================================
  ; Abstract Class: CanvasControl
  ; Base class for all custom vector canvas-rendered UI controls
  ; ==========================================================================
  Abstract Class CanvasControl Extends Gadget {
    ; Visual States
    Protected visualState.i
    Protected isHovered.b
    Protected isPressed.b
    Protected isFocused.b
    Protected mouseX.i
    Protected mouseY.i

    ; Content / Text
    Protected text.s

    ; WPF-Style Appearance Tokens
    Protected background.i
    Protected foreground.i
    Protected hoverBackground.i
    Protected hoverForeground.i
    Protected pressedBackground.i
    Protected pressedForeground.i
    Protected disabledBackground.i
    Protected disabledForeground.i

    ; Border & Geometry
    Protected borderColor.i
    Protected hoverBorderColor.i
    Protected pressedBorderColor.i
    Protected borderThickness.i
    Protected cornerRadius.i

    ; Padding
    Protected paddingLeft.i
    Protected paddingTop.i
    Protected paddingRight.i
    Protected paddingBottom.i

    ; Typographie autonome
    Protected ownedFont.i

    ; Arrière-plan du conteneur parent (pour transparence et coins arrondis propres)
    Protected parentBackground.i

    ; Propriétés d'animation et de micro-interactions fluides
    Protected currentScale.f
    Protected targetScale.f
    Protected animateHoverScale.b

    ; Moteur de Styles et Triggers Déclaratifs (WPF/XAML)
    Protected *style.UI::Style
    Protected baseBackground.i
    Protected baseForeground.i
    Protected baseBorderColor.i
    Protected baseHoverBackground.i
    Protected baseHoverForeground.i
    Protected baseHoverBorderColor.i
    Protected basePressedBackground.i
    Protected basePressedForeground.i
    Protected basePressedBorderColor.i
    Protected baseBorderThickness.i
    Protected baseCornerRadius.i
    Protected baseScale.f

    ; --- Initialisation des valeurs par défaut ---
    Protected Method InitDefaults() {
      This\visualState = #UI_VisualState_Normal
      This\isHovered = #False
      This\isPressed = #False
      This\isFocused = #False
      This\mouseX = 0
      This\mouseY = 0
      This\text = ""
      This\ownedFont = 0
      This\parentBackground = RGB(241, 245, 249) ; Fond par défaut du thème clair / fenêtre
      This\currentScale = 1.0
      This\targetScale = 1.0
      This\animateHoverScale = #False

      ; Palette par défaut moderne (Light)
      This\background = RGB(255, 255, 255)
      This\foreground = RGB(33, 37, 41)
      This\hoverBackground = RGB(242, 246, 250)
      This\hoverForeground = RGB(0, 102, 204)
      This\pressedBackground = RGB(204, 232, 255)
      This\pressedForeground = RGB(0, 90, 180)
      This\disabledBackground = RGB(240, 240, 240)
      This\disabledForeground = RGB(160, 160, 160)

      This\borderColor = RGB(218, 224, 233)
      This\hoverBorderColor = RGB(0, 120, 215)
      This\pressedBorderColor = RGB(0, 90, 180)
      This\borderThickness = 1
      This\cornerRadius = 4

      This\paddingLeft = 8
      This\paddingTop = 4
      This\paddingRight = 8
      This\paddingBottom = 4

      ; Enregistrement des valeurs de base pour les triggers
      This\style = 0
      This\baseBackground = This\background
      This\baseForeground = This\foreground
      This\baseBorderColor = This\borderColor
      This\baseHoverBackground = This\hoverBackground
      This\baseHoverForeground = This\hoverForeground
      This\baseHoverBorderColor = This\hoverBorderColor
      This\basePressedBackground = This\pressedBackground
      This\basePressedForeground = This\pressedForeground
      This\basePressedBorderColor = This\pressedBorderColor
      This\baseBorderThickness = This\borderThickness
      This\baseCornerRadius = This\cornerRadius
      This\baseScale = 1.0
    }

    ; Constructeur 1: Par défaut (100x30)
    Public Method Init() {
      Super\Init()
      This\x = 0 : This\y = 0 : This\width = 100 : This\height = 30
      This\desiredWidth = 100 : This\desiredHeight = 30
      This\isVisible = #True : This\isEnabled = #True
      This\InitDefaults()
      This\id = CanvasGadget(#PB_Any, 0, 0, 100, 30, #PB_Canvas_Keyboard)
      If (This\id) {
        UI::RegisterGadget(This\id, This)
        This\Redraw()
      }
    }

    ; Constructeur 2: Dimensions spécifiées
    Public Method Init(w_p.i, h_p.i) {
      Super\Init()
      This\x = 0 : This\y = 0 : This\width = w_p : This\height = h_p
      This\desiredWidth = w_p : This\desiredHeight = h_p
      This\isVisible = #True : This\isEnabled = #True
      This\InitDefaults()
      This\id = CanvasGadget(#PB_Any, 0, 0, w_p, h_p, #PB_Canvas_Keyboard)
      If (This\id) {
        UI::RegisterGadget(This\id, This)
        This\Redraw()
      }
    }

    ; Constructeur 3: Position et dimensions
    Public Method Init(x_p.i, y_p.i, w_p.i, h_p.i) {
      Super\Init()
      This\x = x_p : This\y = y_p : This\width = w_p : This\height = h_p
      This\desiredWidth = w_p : This\desiredHeight = h_p
      This\isVisible = #True : This\isEnabled = #True
      This\InitDefaults()
      This\id = CanvasGadget(#PB_Any, x_p, y_p, w_p, h_p, #PB_Canvas_Keyboard)
      If (This\id) {
        UI::RegisterGadget(This\id, This)
        This\Redraw()
      }
    }

    ; Constructeur 4: Position, dimensions et flags personnalisés
    Public Method Init(x_p.i, y_p.i, w_p.i, h_p.i, flags_p.i) {
      Super\Init()
      This\x = x_p : This\y = y_p : This\width = w_p : This\height = h_p
      This\desiredWidth = w_p : This\desiredHeight = h_p
      This\isVisible = #True : This\isEnabled = #True
      This\InitDefaults()
      This\id = CanvasGadget(#PB_Any, x_p, y_p, w_p, h_p, flags_p | #PB_Canvas_Keyboard)
      If (This\id) {
        UI::RegisterGadget(This\id, This)
        This\Redraw()
      }
    }

    ; --- High-DPI Helpers ---

    Public Method.i ScaleX(val_p.i) {
      ProcedureReturn DesktopScaledX(val_p)
    }

    Public Method.i ScaleY(val_p.i) {
      ProcedureReturn DesktopScaledY(val_p)
    }

    Public Method.f GetDpiScale() {
      Protected sc.f = DesktopResolutionX()
      If sc <= 0.0 : sc = 1.0 : EndIf
      ProcedureReturn sc
    }

    ; --- Machine d'États Visuels (WPF VisualStateManager) ---

    Public Method.i GetVisualState() {
      ProcedureReturn This\visualState
    }

    Public Method UpdateVisualState() {
      Protected oldState.i = This\visualState
      Protected newState.i = #UI_VisualState_Normal

      If (Not This\isEnabled) {
        newState = #UI_VisualState_Disabled
      } ElseIf (This\isPressed) {
        newState = #UI_VisualState_Pressed
      } ElseIf (This\isHovered) {
        newState = #UI_VisualState_Hover
      } ElseIf (This\isFocused) {
        newState = #UI_VisualState_Focused
      }

      ; Application des triggers WPF actifs selon le nouvel état
      This\ApplyStyleTriggers()

      If (oldState <> newState) {
        This\visualState = newState
        This\OnVisualStateChanged(oldState, newState)
        This\Redraw()
      }
    }

    Public Method OnVisualStateChanged(oldState_p.i, newState_p.i) {
    }

    ; --- Getters / Setters pour les États ---

    Public Method.b IsHovered() {
      ProcedureReturn This\isHovered
    }

    Public Method.b IsMouseOver() {
      ProcedureReturn This\isHovered
    }

    Public Method SetIsHovered(state_p.b) {
      If (This\isHovered <> state_p) {
        This\isHovered = state_p
        This\UpdateVisualState()
      }
    }

    Public Method.b IsPressed() {
      ProcedureReturn This\isPressed
    }

    Public Method SetIsPressed(state_p.b) {
      If (This\isPressed <> state_p) {
        This\isPressed = state_p
        This\UpdateVisualState()
      }
    }

    Public Method.b IsFocused() {
      ProcedureReturn This\isFocused
    }

    Public Method SetIsFocused(state_p.b) {
      If (This\isFocused <> state_p) {
        This\isFocused = state_p
        This\UpdateVisualState()
      }
    }

    Public Method SetEnabled(e.b) {
      Super\SetEnabled(e.b)
      This\UpdateVisualState()
    }

    ; --- Getters / Setters pour le Texte ---

    Public Method.s GetText() {
      ProcedureReturn This\text
    }

    Public Method SetText(text_p.s) {
      This\text = text_p
      This\Redraw()
    }

    ; --- Getters / Setters pour les Couleurs et Styles ---

    Public Method.i GetBackground() {
      ProcedureReturn This\background
    }

    Public Method SetBackground(color_p.i) {
      This\background = color_p
      This\Redraw()
    }

    Public Method.i GetForeground() {
      ProcedureReturn This\foreground
    }

    Public Method SetForeground(color_p.i) {
      This\foreground = color_p
      This\Redraw()
    }

    Public Method.i GetHoverBackground() {
      ProcedureReturn This\hoverBackground
    }

    Public Method SetHoverBackground(color_p.i) {
      This\hoverBackground = color_p
      This\Redraw()
    }

    Public Method.i GetHoverForeground() {
      ProcedureReturn This\hoverForeground
    }

    Public Method SetHoverForeground(color_p.i) {
      This\hoverForeground = color_p
      This\Redraw()
    }

    Public Method.i GetPressedBackground() {
      ProcedureReturn This\pressedBackground
    }

    Public Method SetPressedBackground(color_p.i) {
      This\pressedBackground = color_p
      This\Redraw()
    }

    Public Method.i GetPressedForeground() {
      ProcedureReturn This\pressedForeground
    }

    Public Method SetPressedForeground(color_p.i) {
      This\pressedForeground = color_p
      This\Redraw()
    }

    Public Method.i GetDisabledBackground() {
      ProcedureReturn This\disabledBackground
    }

    Public Method SetDisabledBackground(color_p.i) {
      This\disabledBackground = color_p
      This\Redraw()
    }

    Public Method.i GetDisabledForeground() {
      ProcedureReturn This\disabledForeground
    }

    Public Method SetDisabledForeground(color_p.i) {
      This\disabledForeground = color_p
      This\Redraw()
    }

    Public Method.i GetBorderColor() {
      ProcedureReturn This\borderColor
    }

    Public Method SetBorderColor(color_p.i) {
      This\borderColor = color_p
      This\Redraw()
    }

    Public Method.i GetHoverBorderColor() {
      ProcedureReturn This\hoverBorderColor
    }

    Public Method SetHoverBorderColor(color_p.i) {
      This\hoverBorderColor = color_p
      This\Redraw()
    }

    Public Method.i GetPressedBorderColor() {
      ProcedureReturn This\pressedBorderColor
    }

    Public Method SetPressedBorderColor(color_p.i) {
      This\pressedBorderColor = color_p
      This\Redraw()
    }

    Public Method.i GetBorderThickness() {
      ProcedureReturn This\borderThickness
    }

    Public Method SetBorderThickness(thickness_p.i) {
      This\borderThickness = thickness_p
      This\Redraw()
    }

    Public Method.i GetCornerRadius() {
      ProcedureReturn This\cornerRadius
    }

    Public Method SetCornerRadius(radius_p.i) {
      This\cornerRadius = radius_p
      This\Redraw()
    }

    Public Method SetBorder(color_p.i, thickness_p.i, radius_p.i) {
      This\borderColor = color_p
      This\borderThickness = thickness_p
      This\cornerRadius = radius_p
      This\Redraw()
    }

    ; --- Padding Interne ---

    Public Method SetPadding(l_p.i, t_p.i, r_p.i, b_p.i) {
      This\paddingLeft = l_p
      This\paddingTop = t_p
      This\paddingRight = r_p
      This\paddingBottom = b_p
      This\Redraw()
    }

    Public Method.i GetPaddingLeft() {
      ProcedureReturn This\paddingLeft
    }

    Public Method.i GetPaddingTop() {
      ProcedureReturn This\paddingTop
    }

    Public Method.i GetPaddingRight() {
      ProcedureReturn This\paddingRight
    }

    Public Method.i GetPaddingBottom() {
      ProcedureReturn This\paddingBottom
    }

    ; --- Helpers de Couleurs Actives selon l'État ---

    Public Method.i GetCurrentBackgroundColor() {
      Select (This\visualState)
        Case #UI_VisualState_Disabled:
          ProcedureReturn This\disabledBackground
        Case #UI_VisualState_Pressed:
          ProcedureReturn This\pressedBackground
        Case #UI_VisualState_Hover:
          ProcedureReturn This\hoverBackground
        Default:
          ProcedureReturn This\background
      EndSelect
    }

    Public Method.i GetCurrentForegroundColor() {
      Select (This\visualState)
        Case #UI_VisualState_Disabled:
          ProcedureReturn This\disabledForeground
        Case #UI_VisualState_Pressed:
          ProcedureReturn This\pressedForeground
        Case #UI_VisualState_Hover:
          ProcedureReturn This\hoverForeground
        Default:
          ProcedureReturn This\foreground
      EndSelect
    }

    Public Method.i GetCurrentBorderColor() {
      Select (This\visualState)
        Case #UI_VisualState_Disabled:
          ProcedureReturn This\disabledForeground
        Case #UI_VisualState_Pressed:
          ProcedureReturn This\pressedBorderColor
        Case #UI_VisualState_Hover:
          ProcedureReturn This\hoverBorderColor
        Default:
          ProcedureReturn This\borderColor
      EndSelect
    }

    ; --- Helpers Graphiques Intégrés ---

    Public Method DrawControlBackground(w_p.i, h_p.i) {
      ; Effacer l'arriere-plan du canvas avec la couleur du conteneur parent
      ; pour eviter les artefacts carres autour des coins arrondis
      Box(0, 0, w_p, h_p, This\parentBackground)

      Protected curBg.i = This\GetCurrentBackgroundColor()
      Protected curBorder.i = This\GetCurrentBorderColor()
      Protected scaledRadius.i = DesktopScaledX(This\cornerRadius)
      Protected scaledThick.i = DesktopScaledX(This\borderThickness)

      Protected curMarginX.i = 0
      Protected curMarginY.i = 0

      If (This\animateHoverScale)
        Protected baseM.f = 2.0
        Protected delta.f = (This\currentScale - 1.0) / 0.05
        Protected mF.f = baseM - (delta * baseM)
        If mF < 0.0 : mF = 0.0 : ElseIf mF > 4.0 : mF = 4.0 : EndIf
        curMarginX = DesktopScaledX(Round(mF, #PB_Round_Nearest))
        curMarginY = DesktopScaledY(Round(mF, #PB_Round_Nearest))
      EndIf

      Protected drawX.i = curMarginX
      Protected drawY.i = curMarginY
      Protected drawW.i = w_p - (curMarginX * 2)
      Protected drawH.i = h_p - (curMarginY * 2)
      If drawW < 4 : drawW = 4 : EndIf
      If drawH < 4 : drawH = 4 : EndIf

      If (scaledRadius > 0) {
        ; Fond arrondi avec bordure
        If (scaledThick > 0) {
          RoundBox(drawX, drawY, drawW, drawH, scaledRadius, scaledRadius, curBorder)
          If (drawW > scaledThick * 2 And drawH > scaledThick * 2) {
            Protected innerR.i = scaledRadius - scaledThick
            If innerR < 0 : innerR = 0 : EndIf
            RoundBox(drawX + scaledThick, drawY + scaledThick, drawW - (scaledThick * 2), drawH - (scaledThick * 2), innerR, innerR, curBg)
          }
        } Else {
          RoundBox(drawX, drawY, drawW, drawH, scaledRadius, scaledRadius, curBg)
        }
      } Else {
        ; Rectangle standard avec bordure
        If (scaledThick > 0) {
          Box(drawX, drawY, drawW, drawH, curBorder)
          If (drawW > scaledThick * 2 And drawH > scaledThick * 2) {
            Box(drawX + scaledThick, drawY + scaledThick, drawW - (scaledThick * 2), drawH - (scaledThick * 2), curBg)
          }
        } Else {
          Box(drawX, drawY, drawW, drawH, curBg)
        }
      }
    }

    Public Method DrawFocusRing(w_p.i, h_p.i) {
      If (This\isFocused) {
        Protected fCol.i = RGB(0, 120, 215)
        Protected scaledRadius.i = DesktopScaledX(This\cornerRadius)
        If scaledRadius > 2 : scaledRadius - 2 : EndIf
        RoundBox(2, 2, w_p - 4, h_p - 4, scaledRadius, scaledRadius, fCol)
        RoundBox(3, 3, w_p - 6, h_p - 6, scaledRadius, scaledRadius, This\GetCurrentBackgroundColor())
      }
    }

    ; --- Rendu Graphique Virtuel ---

    Public Abstract Method OnPaint(w_p.i, h_p.i)

    Public Method Redraw() {
      If (This\id And IsGadget(This\id)) {
        If (StartDrawing(CanvasOutput(This\id))) {
          This\OnPaint(OutputWidth(), OutputHeight())
          StopDrawing()
        }
      }
    }

    ; --- Événements Souris, Clavier & Focus ---

    Public Method OnMouseEnter() {
      This\isHovered = #True
      This\UpdateVisualState()
      If (This\animateHoverScale) {
        UI_InitAnimationEngine()
        UI_GlobalAnimEngine\StartFloatAnimation(This, "Scale", This\currentScale, 1.05, 120, #UI_ANIM_EASING_EASEOUT_QUAD)
      }
    }

    Public Method OnMouseLeave() {
      This\isHovered = #False
      This\isPressed = #False
      This\UpdateVisualState()
      If (This\animateHoverScale) {
        UI_InitAnimationEngine()
        UI_GlobalAnimEngine\StartFloatAnimation(This, "Scale", This\currentScale, 1.00, 160, #UI_ANIM_EASING_EASEOUT_CUBIC)
      }
    }

    Public Method OnMouseDown(mx_p.i, my_p.i, button_p.i) {
      This\isPressed = #True
      This\UpdateVisualState()
      If (This\animateHoverScale) {
        UI_InitAnimationEngine()
        UI_GlobalAnimEngine\StartFloatAnimation(This, "Scale", This\currentScale, 0.96, 70, #UI_ANIM_EASING_EASEOUT_QUAD)
      }
    }

    Public Method OnMouseUp(mx_p.i, my_p.i, button_p.i) {
      This\isPressed = #False
      This\UpdateVisualState()
      If (This\animateHoverScale) {
        UI_InitAnimationEngine()
        Protected targetSc.f = 1.00
        If (This\isHovered) : targetSc = 1.05 : EndIf
        UI_GlobalAnimEngine\StartFloatAnimation(This, "Scale", This\currentScale, targetSc, 120, #UI_ANIM_EASING_EASEOUT_BACK)
      }
    }

    Public Method OnMouseMove(mx_p.i, my_p.i) {
    }

    Public Method OnMouseWheel(delta_p.i) {
    }

    Public Method OnKeyDown(key_p.i) {
    }

    Public Method OnKeyUp(key_p.i) {
    }

    Public Method OnFocus() {
      This\isFocused = #True
      This\UpdateVisualState()
    }

    Public Method OnLostFocus() {
      This\isFocused = #False
      This\UpdateVisualState()
    }

    Public Method OnInput(char_p.i) {
    }

    Public Method OnLeftDoubleClick(mx_p.i, my_p.i) {
    }

    Public Method OnCustomEvent(eventType_p.i) {
      Select (eventType_p)
        Case #PB_EventType_MouseEnter:
          This\OnMouseEnter()

        Case #PB_EventType_MouseLeave:
          This\OnMouseLeave()

        Case #PB_EventType_LeftButtonDown:
          This\mouseX = GetGadgetAttribute(This\id, #PB_Canvas_MouseX)
          This\mouseY = GetGadgetAttribute(This\id, #PB_Canvas_MouseY)
          This\OnMouseDown(This\mouseX, This\mouseY, 1)

        Case #PB_EventType_LeftButtonUp:
          Protected wasPressed.b = This\isPressed
          This\mouseX = GetGadgetAttribute(This\id, #PB_Canvas_MouseX)
          This\mouseY = GetGadgetAttribute(This\id, #PB_Canvas_MouseY)
          This\OnMouseUp(This\mouseX, This\mouseY, 1)
          If (wasPressed) {
            This\OnClick()
          }

        Case #PB_EventType_LeftDoubleClick:
          This\mouseX = GetGadgetAttribute(This\id, #PB_Canvas_MouseX)
          This\mouseY = GetGadgetAttribute(This\id, #PB_Canvas_MouseY)
          This\OnLeftDoubleClick(This\mouseX, This\mouseY)

        Case #PB_EventType_MouseMove:
          This\mouseX = GetGadgetAttribute(This\id, #PB_Canvas_MouseX)
          This\mouseY = GetGadgetAttribute(This\id, #PB_Canvas_MouseY)
          This\OnMouseMove(This\mouseX, This\mouseY)

        Case #PB_EventType_MouseWheel:
          Protected wheelDelta.i = GetGadgetAttribute(This\id, #PB_Canvas_WheelDelta)
          This\OnMouseWheel(wheelDelta)

        Case #PB_EventType_Focus:
          This\OnFocus()

        Case #PB_EventType_LostFocus:
          This\OnLostFocus()

        Case #PB_EventType_KeyDown:
          This\OnKeyDown(GetGadgetAttribute(This\id, #PB_Canvas_Key))

        Case #PB_EventType_KeyUp:
          This\OnKeyUp(GetGadgetAttribute(This\id, #PB_Canvas_Key))

        Case #PB_EventType_Input:
          Protected inputChar.i = GetGadgetAttribute(This\id, #PB_Canvas_Input)
          This\OnInput(inputChar)
      EndSelect
    }

    ; --- Typographie Haute-Fidélité ---

    Public Method SetTypography(fontName_p.s, fontSize_p.i, bold_p.b) {
      Protected scaledSize.i = DesktopScaledY(fontSize_p)
      If scaledSize < 6 : scaledSize = 6 : EndIf
      Protected flags.i = #PB_Font_HighQuality
      If bold_p : flags | #PB_Font_Bold : EndIf
      Protected newFont.i = LoadFont(#PB_Any, fontName_p, scaledSize, flags)
      If newFont
        If This\ownedFont And IsFont(This\ownedFont)
          FreeFont(This\ownedFont)
        EndIf
        This\ownedFont = newFont
        This\fontID = FontID(newFont)
        This\Redraw()
      EndIf
    }

    Public Method SetParentBackground(col_p.i) {
      This\parentBackground = col_p
      This\Redraw()
    }

    Public Method.i GetParentBackground() {
      ProcedureReturn This\parentBackground
    }

    ; Virtual Layout Arrange method: redessine imperativement le canvas des que sa taille reelle est fixee
    Public Method Arrange(nx.i, ny.i, nw.i, nh.i) {
      This\SetPosition(nx, ny, nw, nh)
      If (This\id And IsGadget(This\id)) {
        ResizeGadget(This\id, nx, ny, nw, nh)
      }
      This\Redraw()
    }

    ; Micro-Animations Callbacks & Settings
    Public Method OnAnimationTick(propName.s, value.f) {
      If propName = "Scale"
        This\currentScale = value
        This\Redraw()
      EndIf
    }

    Public Method SetAnimateHoverScale(enable_p.b) {
      This\animateHoverScale = enable_p
    }

    Public Method.b IsAnimateHoverScale() {
      ProcedureReturn This\animateHoverScale
    }

    ; --- Intégration du Système de Styles & Triggers Déclaratifs (WPF/XAML) ---

    Public Method ApplyStyle(*s.UI::Style) {
      If Not *s : ProcedureReturn : EndIf
      This\style = *s

      Protected fontNameStr.s = ""
      Protected fontSizeVal.i = 0
      Protected fontBoldVal.b = #False
      Protected hasTypography.b = #False

      ; Appliquer les Setters de base définis dans le Style
      Protected count.i = *s\GetSetterCount()
      Protected i.i
      For i = 0 To count - 1
        Protected prop.s = UCase(Trim(*s\GetSetterProperty(i)))
        Protected val.s = Trim(*s\GetSetterValue(i))

        Select prop
          Case "BACKGROUND", "BG"
            This\background = UI_ParseColor(val, This\background)
          Case "FOREGROUND", "FG"
            This\foreground = UI_ParseColor(val, This\foreground)
          Case "BORDERCOLOR"
            This\borderColor = UI_ParseColor(val, This\borderColor)
          Case "HOVERBACKGROUND", "HOVERBG"
            This\hoverBackground = UI_ParseColor(val, This\hoverBackground)
          Case "HOVERFOREGROUND", "HOVERFG"
            This\hoverForeground = UI_ParseColor(val, This\hoverForeground)
          Case "HOVERBORDERCOLOR"
            This\hoverBorderColor = UI_ParseColor(val, This\hoverBorderColor)
          Case "PRESSEDBACKGROUND", "PRESSEDBG"
            This\pressedBackground = UI_ParseColor(val, This\pressedBackground)
          Case "PRESSEDFOREGROUND", "PRESSEDFG"
            This\pressedForeground = UI_ParseColor(val, This\pressedForeground)
          Case "PRESSEDBORDERCOLOR"
            This\pressedBorderColor = UI_ParseColor(val, This\pressedBorderColor)
          Case "BORDERTHICKNESS"
            This\borderThickness = Val(val)
          Case "CORNERRADIUS"
            This\cornerRadius = Val(val)
          Case "SCALE"
            This\currentScale = ValF(val)
            This\targetScale = This\currentScale
          Case "ANIMATEHOVERSCALE"
            If UCase(val) = "TRUE" Or val = "1"
              This\animateHoverScale = #True
            Else
              This\animateHoverScale = #False
            EndIf
          Case "FONTNAME", "FONTFAMILY"
            fontNameStr = val
            hasTypography = #True
          Case "FONTSIZE"
            fontSizeVal = Val(val)
            hasTypography = #True
          Case "FONTBOLD", "FONTWEIGHT"
            If UCase(val) = "TRUE" Or UCase(val) = "BOLD" Or val = "1"
              fontBoldVal = #True
            Else
              fontBoldVal = #False
            EndIf
            hasTypography = #True
        EndSelect
      Next

      ; Mémorisation des valeurs appliquées comme référence de base pour les triggers
      This\baseBackground = This\background
      This\baseForeground = This\foreground
      This\baseBorderColor = This\borderColor
      This\baseHoverBackground = This\hoverBackground
      This\baseHoverForeground = This\hoverForeground
      This\baseHoverBorderColor = This\hoverBorderColor
      This\basePressedBackground = This\pressedBackground
      This\basePressedForeground = This\pressedForeground
      This\basePressedBorderColor = This\pressedBorderColor
      This\baseBorderThickness = This\borderThickness
      This\baseCornerRadius = This\cornerRadius
      This\baseScale = This\currentScale

      If hasTypography
        If fontNameStr = "" : fontNameStr = "Segoe UI" : EndIf
        If fontSizeVal <= 0 : fontSizeVal = 10 : EndIf
        This\SetTypography(fontNameStr, fontSizeVal, fontBoldVal)
      EndIf

      This\ApplyStyleTriggers()
      This\Redraw()
    }

    Public Method ApplyStyleTriggers() {
      If Not This\style : ProcedureReturn : EndIf

      ; 1. Rétablir les valeurs de base
      This\background = This\baseBackground
      This\foreground = This\baseForeground
      This\borderColor = This\baseBorderColor
      This\hoverBackground = This\baseHoverBackground
      This\hoverForeground = This\baseHoverForeground
      This\hoverBorderColor = This\baseHoverBorderColor
      This\pressedBackground = This\basePressedBackground
      This\pressedForeground = This\basePressedForeground
      This\pressedBorderColor = This\basePressedBorderColor
      This\cornerRadius = This\baseCornerRadius
      This\borderThickness = This\baseBorderThickness

      ; 2. Parcourir les triggers et activer ceux dont la condition est remplie
      Protected tCount.i = This\style\GetTriggerCount()
      Protected t.i, s.i
      Protected hasScaleTrigger.b = #False

      For t = 0 To tCount - 1
        Protected tProp.s = UCase(Trim(This\style\GetTriggerProperty(t)))
        Protected tVal.s = UCase(Trim(This\style\GetTriggerValue(t)))
        Protected isTriggerActive.b = #False

        Select tProp
          Case "ISMOUSEOVER"
            If (tVal = "TRUE" And This\isHovered) Or (tVal = "FALSE" And Not This\isHovered)
              isTriggerActive = #True
            EndIf
          Case "ISPRESSED"
            If (tVal = "TRUE" And This\isPressed) Or (tVal = "FALSE" And Not This\isPressed)
              isTriggerActive = #True
            EndIf
          Case "ISFOCUSED"
            If (tVal = "TRUE" And This\isFocused) Or (tVal = "FALSE" And Not This\isFocused)
              isTriggerActive = #True
            EndIf
        EndSelect

        If (isTriggerActive)
          Protected sCount.i = This\style\GetTriggerSetterCount(t)
          For s = 0 To sCount - 1
            Protected prop.s = UCase(Trim(This\style\GetTriggerSetterProperty(t, s)))
            Protected val.s = Trim(This\style\GetTriggerSetterValue(t, s))

            Select prop
              Case "BACKGROUND", "BG"
                Protected parsedBg.i = UI_ParseColor(val, This\background)
                This\background = parsedBg
                If tProp = "ISMOUSEOVER" : This\hoverBackground = parsedBg : EndIf
                If tProp = "ISPRESSED"   : This\pressedBackground = parsedBg : EndIf
              Case "FOREGROUND", "FG"
                Protected parsedFg.i = UI_ParseColor(val, This\foreground)
                This\foreground = parsedFg
                If tProp = "ISMOUSEOVER" : This\hoverForeground = parsedFg : EndIf
                If tProp = "ISPRESSED"   : This\pressedForeground = parsedFg : EndIf
              Case "BORDERCOLOR"
                Protected parsedBrd.i = UI_ParseColor(val, This\borderColor)
                This\borderColor = parsedBrd
                If tProp = "ISMOUSEOVER" : This\hoverBorderColor = parsedBrd : EndIf
                If tProp = "ISPRESSED"   : This\pressedBorderColor = parsedBrd : EndIf
              Case "CORNERRADIUS"
                This\cornerRadius = Val(val)
              Case "BORDERTHICKNESS"
                This\borderThickness = Val(val)
              Case "SCALE"
                hasScaleTrigger = #True
                Protected targetSc.f = ValF(val)
                UI_InitAnimationEngine()
                UI_GlobalAnimEngine\StartFloatAnimation(This, "Scale", This\currentScale, targetSc, 120, #UI_ANIM_EASING_EASEOUT_QUAD)
            EndSelect
          Next
        EndIf
      Next

      ; Si aucun trigger Scale n'est actif, et qu'on a bougé de l'échelle de base, retour fluide
      If (Not hasScaleTrigger) And (Not This\isHovered) And (Not This\isPressed) And This\currentScale <> This\baseScale
        UI_InitAnimationEngine()
        UI_GlobalAnimEngine\StartFloatAnimation(This, "Scale", This\currentScale, This\baseScale, 150, #UI_ANIM_EASING_EASEOUT_CUBIC)
      EndIf
    }

    Public Method.i GetStyle() {
      ProcedureReturn This\style
    }

    ; --- Nettoyage ---

    Public Method Free() {
      If (This\ownedFont And IsFont(This\ownedFont)) {
        FreeFont(This\ownedFont)
        This\ownedFont = 0
      }
      If (This\id) {
        UI::UnregisterGadget(This\id)
        Super\Free()
      }
    }
  }

}
