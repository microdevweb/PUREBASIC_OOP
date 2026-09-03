; ============================================================================
; PureBasic OOP GUI Framework - StackPanel.pb
; Linear layout panel arranging child components sequentially (Vertical or Horizontal)
; Author:      MicrodevWeb
; ============================================================================

XIncludeFile "Container.pb"

Namespace UI::Layouts {

  Class StackPanel Extends UI::Layouts::Container {
    Protected orientation.i
    Protected spacing.i

    Public Method Init() {
      Super::Init()
      This\orientation = #UI_Orientation_Vertical
      This\spacing = 5
    }

    Public Method Init(orient.i) {
      Super::Init()
      This\orientation = orient
      This\spacing = 5
    }

    Public Method Init(orient.i, sp.i) {
      Super::Init()
      This\orientation = orient
      This\spacing = sp
    }

    Public Method Init(orient.i, sp.i, w_p.i, h_p.i) {
      Super::Init(w_p, h_p)
      This\orientation = orient
      This\spacing = sp
    }

    Public Method SetOrientation(o.i) {
      This\orientation = o
      This\UpdateLayout()
    }

    Public Method.i GetOrientation() {
      ProcedureReturn This\orientation
    }

    Public Method SetSpacing(sp.i) {
      This\spacing = sp
      This\UpdateLayout()
    }

    Public Method.i GetSpacing() {
      ProcedureReturn This\spacing
    }

    Public Method Arrange(nx.i, ny.i, nw.i, nh.i) {
      This\SetPosition(nx, ny, nw, nh)
      If This\id And IsGadget(This\id)
        ResizeGadget(This\id, nx, ny, nw, nh)
      EndIf

      Protected innerX.i = nx + This\paddingLeft
      Protected innerY.i = ny + This\paddingTop
      Protected innerW.i = nw - (This\paddingLeft + This\paddingRight)
      Protected innerH.i = nh - (This\paddingTop + This\paddingBottom)

      If innerW < 0 : innerW = 0 : EndIf
      If innerH < 0 : innerH = 0 : EndIf

      If This\orientation = #UI_Orientation_Vertical
        Protected currY.i = innerY

        ForEach This\children()
          Protected *childV.UI::Component = This\children()
          If *childV
            Protected cH.i = *childV\GetDesiredHeight()
            If *childV\GetMinHeight() > 0 And cH < *childV\GetMinHeight()
              cH = *childV\GetMinHeight()
            EndIf
            If *childV\GetMaxHeight() > 0 And cH > *childV\GetMaxHeight()
              cH = *childV\GetMaxHeight()
            EndIf

            Protected cX.i = innerX + *childV\GetMarginLeft()
            Protected cW.i = innerW - (*childV\GetMarginLeft() + *childV\GetMarginRight())
            If cW < 0 : cW = 0 : EndIf

            Select *childV\GetHorizontalAlignment()
              Case #UI_Align_Left
                cW = *childV\GetDesiredWidth()
              Case #UI_Align_Right
                cW = *childV\GetDesiredWidth()
                cX = innerX + innerW - cW - *childV\GetMarginRight()
              Case #UI_Align_Center
                cW = *childV\GetDesiredWidth()
                cX = innerX + (innerW - cW) / 2
            EndSelect

            *childV\Arrange(cX, currY + *childV\GetMarginTop(), cW, cH)
            currY = currY + cH + *childV\GetMarginTop() + *childV\GetMarginBottom() + This\spacing
          EndIf
        Next
      Else
        ; Horizontal Orientation
        Protected currX.i = innerX

        ForEach This\children()
          Protected *childH.UI::Component = This\children()
          If *childH
            Protected childW.i = *childH\GetDesiredWidth()
            If *childH\GetMinWidth() > 0 And childW < *childH\GetMinWidth()
              childW = *childH\GetMinWidth()
            EndIf
            If *childH\GetMaxWidth() > 0 And childW > *childH\GetMaxWidth()
              childW = *childH\GetMaxWidth()
            EndIf

            Protected childY.i = innerY + *childH\GetMarginTop()
            Protected childH.i = innerH - (*childH\GetMarginTop() + *childH\GetMarginBottom())
            If childH < 0 : childH = 0 : EndIf

            Select *childH\GetVerticalAlignment()
              Case #UI_Align_Top
                childH = *childH\GetDesiredHeight()
              Case #UI_Align_Bottom
                childH = *childH\GetDesiredHeight()
                childY = innerY + innerH - childH - *childH\GetMarginBottom()
              Case #UI_Align_Middle
                childH = *childH\GetDesiredHeight()
                childY = innerY + (innerH - childH) / 2
            EndSelect

            *childH\Arrange(currX + *childH\GetMarginLeft(), childY, childW, childH)
            currX = currX + childW + *childH\GetMarginLeft() + *childH\GetMarginRight() + This\spacing
          EndIf
        Next
      EndIf
    }
  }

}
