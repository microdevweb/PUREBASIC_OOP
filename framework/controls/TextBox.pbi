; ============================================================================
; PureBasic OOP GUI Framework - TextBox.pbi
; Standard Text Input / StringGadget wrapper with Multi-Constructors
; Author:      MicrodevWeb
; ============================================================================

XIncludeFile "../Gadget.pbi"
XIncludeFile "../Application.pbi"

Namespace UI {

  Class TextBox Extends Gadget {

    ; Constructor 0: Default (vide, 0,0, 150x25)
    Public Method Init() {
      Super\Init()
      This\x = 0 : This\y = 0 : This\width = 150 : This\height = 25
      This\desiredWidth = 150 : This\desiredHeight = 25
      This\isVisible = #True : This\isEnabled = #True
      This\id = StringGadget(#PB_Any, 0, 0, 150, 25, "", 0)
      If (This\id) {
        UI_RegisterGadget(This\id, This)
      }
    }

    ; Constructor 1: Default text only (0,0, 150x25)
    Public Method Init(defaultText_p.s) {
      Super\Init()
      This\x = 0 : This\y = 0 : This\width = 150 : This\height = 25
      This\desiredWidth = 150 : This\desiredHeight = 25
      This\isVisible = #True : This\isEnabled = #True
      This\id = StringGadget(#PB_Any, 0, 0, 150, 25, defaultText_p, 0)
      If (This\id) {
        UI_RegisterGadget(This\id, This)
      }
    }

    ; Constructor 2: Text and dimensions
    Public Method Init(defaultText_p.s, w_p.i, h_p.i) {
      Super\Init()
      This\x = 0 : This\y = 0 : This\width = w_p : This\height = h_p
      This\desiredWidth = w_p : This\desiredHeight = h_p
      This\isVisible = #True : This\isEnabled = #True
      This\id = StringGadget(#PB_Any, 0, 0, w_p, h_p, defaultText_p, 0)
      If (This\id) {
        UI_RegisterGadget(This\id, This)
      }
    }

    ; Constructor 3: Position, dimensions and text
    Public Method Init(x_p.i, y_p.i, w_p.i, h_p.i, defaultText_p.s) {
      Super\Init()
      This\x = x_p : This\y = y_p : This\width = w_p : This\height = h_p
      This\desiredWidth = w_p : This\desiredHeight = h_p
      This\isVisible = #True : This\isEnabled = #True
      This\id = StringGadget(#PB_Any, x_p, y_p, w_p, h_p, defaultText_p, 0)
      If (This\id) {
        UI_RegisterGadget(This\id, This)
      }
    }

    ; Constructor 4: Full
    Public Method Init(x_p.i, y_p.i, w_p.i, h_p.i, defaultText_p.s, flags_p.i) {
      Super\Init()
      This\x = x_p : This\y = y_p : This\width = w_p : This\height = h_p
      This\desiredWidth = w_p : This\desiredHeight = h_p
      This\isVisible = #True : This\isEnabled = #True
      This\id = StringGadget(#PB_Any, x_p, y_p, w_p, h_p, defaultText_p, flags_p)
      If (This\id) {
        UI_RegisterGadget(This\id, This)
      }
    }

    Public Method.b IsReadOnly() {
      If (This\id And IsGadget(This\id)) {
        ProcedureReturn GetGadgetAttribute(This\id, #PB_String_ReadOnly)
      }
      ProcedureReturn #False
    }

    Public Method SetPlaceholder(ph_p.s) {
      If (This\id And IsGadget(This\id)) {
        CompilerIf #PB_Compiler_OS = #PB_OS_Windows
          SendMessage_(GadgetID(This\id), 5377, #True, @ph_p) ; #EM_SETCUEBANNER = 5377
        CompilerElse
          GadgetToolTip(This\id, ph_p)
        CompilerEndIf
      }
    }

    Public Method SetReadOnly(ro.b) {
      If (This\id And IsGadget(This\id)) {
        SetGadgetAttribute(This\id, #PB_String_ReadOnly, ro)
      }
    }

    Public Method Free() {
      If (This\id) {
        UI_UnregisterGadget(This\id)
        Super\Free()
      }
    }
  }

}
