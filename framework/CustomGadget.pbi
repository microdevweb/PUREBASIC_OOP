; ============================================================================
; PureBasic OOP GUI Framework - CustomGadget.pbi
; Base class for 2D Vector-rendered / Canvas Custom Gadgets
; Inherits from modern CanvasControl (WPF styling tokens & visual state machine)
; Author:      MicrodevWeb
; ============================================================================

XIncludeFile "CanvasControl.pbi"

Namespace UI {

  Abstract Class CustomGadget Extends CanvasControl {

    ; Constructor 1: Default (100x30)
    Public Method Init() {
      Super\Init()
    }

    ; Constructor 2: Custom dimensions
    Public Method Init(w_p.i, h_p.i) {
      Super\Init(w_p, h_p)
    }

    ; Constructor 3: Position and dimensions
    Public Method Init(x_p.i, y_p.i, w_p.i, h_p.i) {
      Super\Init(x_p, y_p, w_p, h_p)
    }

    ; Constructor 4: Full with flags
    Public Method Init(x_p.i, y_p.i, w_p.i, h_p.i, flags_p.i) {
      Super\Init(x_p, y_p, w_p, h_p, flags_p)
    }

    Public Method Free() {
      Super\Free()
    }

  }

}
