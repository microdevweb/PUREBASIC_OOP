; ============================================================================
; PureBasic OOP GUI Framework - Container.pbi
; Base abstract class for all responsive layout panels
; Author:      MicrodevWeb
; ============================================================================

XIncludeFile "../Component.pbi"

Namespace UI::Layouts {

  Class Container Extends UI::Component {
    Protected List *children.UI::Component()
    Protected paddingLeft.i
    Protected paddingTop.i
    Protected paddingRight.i
    Protected paddingBottom.i
    Protected bgGadgetId.i
    Protected backgroundColor.i
    Protected borderColor.i
    Protected borderThickness.i
    Protected cornerRadius.i
    Protected hasBackground.b

    ; Constructeur 1: Par défaut
    Public Method Init() {
      Super\Init()
      This\paddingLeft = 0
      This\paddingTop = 0
      This\paddingRight = 0
      This\paddingBottom = 0
      This\horizontalAlignment = #UI_Align_Stretch
      This\verticalAlignment = #UI_Align_VStretch
      This\bgGadgetId = 0
      This\backgroundColor = 0
      This\borderColor = 0
      This\borderThickness = 0
      This\cornerRadius = 0
      This\hasBackground = #False
    }

    ; Constructeur 2: Dimensions
    Public Method Init(w_p.i, h_p.i) {
      Super\Init()
      This\width = w_p : This\height = h_p
      This\desiredWidth = w_p : This\desiredHeight = h_p
      This\paddingLeft = 0
      This\paddingTop = 0
      This\paddingRight = 0
      This\paddingBottom = 0
      This\horizontalAlignment = #UI_Align_Stretch
      This\verticalAlignment = #UI_Align_VStretch
      This\bgGadgetId = 0
      This\backgroundColor = 0
      This\borderColor = 0
      This\borderThickness = 0
      This\cornerRadius = 0
      This\hasBackground = #False
    }

    ; Constructeur 3: Position et dimensions
    Public Method Init(x_p.i, y_p.i, w_p.i, h_p.i) {
      Super\Init()
      This\x = x_p : This\y = y_p : This\width = w_p : This\height = h_p
      This\desiredWidth = w_p : This\desiredHeight = h_p
      This\paddingLeft = 0
      This\paddingTop = 0
      This\paddingRight = 0
      This\paddingBottom = 0
      This\horizontalAlignment = #UI_Align_Stretch
      This\verticalAlignment = #UI_Align_VStretch
      This\bgGadgetId = 0
      This\backgroundColor = 0
      This\borderColor = 0
      This\borderThickness = 0
      This\cornerRadius = 0
      This\hasBackground = #False
    }

    Public Method EnsureBgGadget() {
      If (This\bgGadgetId = 0) {
        This\bgGadgetId = CanvasGadget(#PB_Any, 0, 0, 10, 10)
        If (This\bgGadgetId) {
          DisableGadget(This\bgGadgetId, #True)
        }
      }
    }

    Public Method SetBackground(col.i) {
      This\backgroundColor = col
      This\hasBackground = #True
      This\EnsureBgGadget()
      This\DrawBackground(This\width, This\height)
    }

    Public Method.i GetBackground() {
      ProcedureReturn This\backgroundColor
    }

    Public Method SetBorderColor(col.i) {
      This\borderColor = col
      This\hasBackground = #True
      This\EnsureBgGadget()
      This\DrawBackground(This\width, This\height)
    }

    Public Method SetBorderThickness(th.i) {
      This\borderThickness = th
      This\hasBackground = #True
      This\EnsureBgGadget()
      This\DrawBackground(This\width, This\height)
    }

    Public Method SetCornerRadius(cr.i) {
      This\cornerRadius = cr
      This\hasBackground = #True
      This\EnsureBgGadget()
      This\DrawBackground(This\width, This\height)
    }

    Public Method SetBorder(col.i, thick.i, radius.i) {
      This\borderColor = col
      This\borderThickness = thick
      This\cornerRadius = radius
      This\hasBackground = #True
      This\EnsureBgGadget()
      This\DrawBackground(This\width, This\height)
    }

    Public Method DrawBackground(nw.i, nh.i) {
      If (This\hasBackground And This\bgGadgetId And IsGadget(This\bgGadgetId) And nw > 0 And nh > 0) {
        If (StartDrawing(CanvasOutput(This\bgGadgetId))) {
          Protected sRadius.i = DesktopScaledX(This\cornerRadius)
          Protected sThick.i = DesktopScaledX(This\borderThickness)
          If (sRadius > 0) {
            If (sThick > 0) {
              RoundBox(0, 0, nw, nh, sRadius, sRadius, This\borderColor)
              If (nw > sThick * 2 And nh > sThick * 2) {
                Protected inR.i = sRadius - sThick
                If inR < 0 : inR = 0 : EndIf
                RoundBox(sThick, sThick, nw - (sThick * 2), nh - (sThick * 2), inR, inR, This\backgroundColor)
              }
            } Else {
              RoundBox(0, 0, nw, nh, sRadius, sRadius, This\backgroundColor)
            }
          } Else {
            If (sThick > 0) {
              Box(0, 0, nw, nh, This\borderColor)
              If (nw > sThick * 2 And nh > sThick * 2) {
                Box(sThick, sThick, nw - (sThick * 2), nh - (sThick * 2), This\backgroundColor)
              }
            } Else {
              Box(0, 0, nw, nh, This\backgroundColor)
            }
          }
          StopDrawing()
        }
      }
    }

    Public Method SetPadding(l.i, t.i, r.i, b.i) {
      This\paddingLeft = l
      This\paddingTop = t
      This\paddingRight = r
      This\paddingBottom = b
      This\UpdateLayout()
    }

    Public Method SetPaddingAll(p.i) {
      This\paddingLeft = p
      This\paddingTop = p
      This\paddingRight = p
      This\paddingBottom = p
      This\UpdateLayout()
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

    Public Method AddChild(*child.UI::Component) {
      If *child
        AddElement(This\children())
        This\children() = *child
        This\UpdateLayout()
      EndIf
    }

    Public Method RemoveChild(*child.UI::Component) {
      If *child
        ForEach This\children()
          If This\children() = *child
            DeleteElement(This\children())
            Break
          EndIf
        Next
        This\UpdateLayout()
      EndIf
    }

    Public Method ClearChildren() {
      ClearList(This\children())
      This\UpdateLayout()
    }

    Public Method.i GetChildCount() {
      ProcedureReturn ListSize(This\children())
    }

    Public Method SetWidth(nw.i) {
      Super\SetWidth(nw)
      This\UpdateLayout()
    }

    Public Method SetHeight(nh.i) {
      Super\SetHeight(nh)
      This\UpdateLayout()
    }

    Public Method SetSize(nw.i, nh.i) {
      Super\SetSize(nw, nh)
      This\UpdateLayout()
    }

    Public Method UpdateLayout() {
      If This\width > 0 And This\height > 0
        This\Arrange(This\x, This\y, This\width, This\height)
      EndIf
    }

    Public Method Free() {
      ForEach This\children()
        Protected *child.UI::Component = This\children()
        If *child
          *child\Free()
        EndIf
      Next
      ClearList(This\children())
      If (This\bgGadgetId And IsGadget(This\bgGadgetId)) {
        FreeGadget(This\bgGadgetId)
        This\bgGadgetId = 0
      }
      Super\Free()
    }

    ; Default container arrange: arranges all children to stretch inside padding
    Public Method Arrange(nx.i, ny.i, nw.i, nh.i) {
      This\SetPosition(nx, ny, nw, nh)
      If (This\bgGadgetId And IsGadget(This\bgGadgetId)) {
        ResizeGadget(This\bgGadgetId, nx, ny, nw, nh)
        This\DrawBackground(nw, nh)
      }
      If (This\id And IsGadget(This\id)) {
        ResizeGadget(This\id, nx, ny, nw, nh)
      }

      Protected innerX.i = nx + This\paddingLeft
      Protected innerY.i = ny + This\paddingTop
      Protected innerW.i = nw - (This\paddingLeft + This\paddingRight)
      Protected innerH.i = nh - (This\paddingTop + This\paddingBottom)

      If innerW < 0 : innerW = 0 : EndIf
      If innerH < 0 : innerH = 0 : EndIf

      ForEach This\children()
        Protected *child.UI::Component = This\children()
        If *child
          Protected cx.i = innerX + *child\GetMarginLeft()
          Protected cy.i = innerY + *child\GetMarginTop()
          Protected cw.i = innerW - (*child\GetMarginLeft() + *child\GetMarginRight())
          Protected ch.i = innerH - (*child\GetMarginTop() + *child\GetMarginBottom())
          If cw < 0 : cw = 0 : EndIf
          If ch < 0 : ch = 0 : EndIf
          *child\Arrange(cx, cy, cw, ch)
        EndIf
      Next
    }
  }

}
