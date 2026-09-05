; ============================================================================
; PureBasic OOP MVVM - SimpleViewModel.pbi
; Simple ViewModel for testing MVVM DataBinding and Commands
; Author:      MicrodevWeb
; ============================================================================

XIncludeFile "../../../ui/UI.pbi"

Namespace Demo::ViewModels {

  Class SimpleViewModel Extends UI::MVVM::ViewModelBase {
    Protected clickCount.i

    Public Method Init() {
      Super::Init()
      This\clickCount = 0

      ; Initial State Properties
      This\Set("ClickMessage", "No button clicked yet")
      This\Set("HoverMessage", "Hover over any button to test mouse hover")
      This\Set("TotalClicksText", "Total Clicks: 0")
      This\Set("StatusText", "Status: Ready")
    }

    ; Direct virtual command dispatcher (No external procedures needed!)
    Public Method.b OnCommand(cmd.s, *param = 0) {
      Select cmd
        Case "ClickBtn1"
          This\clickCount + 1
          This\Set("ClickMessage", "You clicked on Button 1")
          This\Set("TotalClicksText", "Total Clicks: " + Str(This\clickCount))
          This\Set("StatusText", "Status: Button 1 clicked")
          ProcedureReturn #True

        Case "ClickBtn2"
          This\clickCount + 1
          This\Set("ClickMessage", "You clicked on Button 2")
          This\Set("TotalClicksText", "Total Clicks: " + Str(This\clickCount))
          This\Set("StatusText", "Status: Button 2 clicked")
          ProcedureReturn #True

        Case "ClickBtn3"
          This\clickCount + 1
          This\Set("ClickMessage", "You clicked on Button 3")
          This\Set("TotalClicksText", "Total Clicks: " + Str(This\clickCount))
          This\Set("StatusText", "Status: Button 3 clicked")
          ProcedureReturn #True

        Case "Reset"
          This\clickCount = 0
          This\Set("ClickMessage", "Values reset to default")
          This\Set("HoverMessage", "Hover over any button to test mouse hover")
          This\Set("TotalClicksText", "Total Clicks: 0")
          This\Set("StatusText", "Status: Reset completed")
          ProcedureReturn #True
      EndSelect

      ProcedureReturn #False
    }

    Public Method OnHoverButton(btnIndex.i) {
      If btnIndex > 0
        This\Set("HoverMessage", "You are hovering Button " + Str(btnIndex))
      Else
        This\Set("HoverMessage", "No button hovered")
      EndIf
    }
  }

}

