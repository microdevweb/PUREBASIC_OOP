; ============================================================================
; PureBasic OOP MVVM - SimpleViewModel.pbi
; Simple ViewModel for testing MVVM DataBinding and Commands
; Author:      MicrodevWeb
; ============================================================================

XIncludeFile "../../../ui/UI.pbi"

; Forward declarations for command callbacks
Declare SimpleVM_OnClickBtn1(*param)
Declare SimpleVM_OnClickBtn2(*param)
Declare SimpleVM_OnClickBtn3(*param)
Declare SimpleVM_OnReset(*param)

Global *CurrentSimpleViewModel = 0

Namespace Demo::ViewModels {

  Class SimpleViewModel Extends UI::MVVM::ViewModelBase {
    Protected clickCount.i

    Public Method Init() {
      Super::Init()
      *CurrentSimpleViewModel = This
      This\clickCount = 0

      ; 1. Initial State Properties
      This\SetString("ClickMessage", "No button clicked yet")
      This\SetString("HoverMessage", "Hover over any button to test mouse hover")
      This\SetString("TotalClicksText", "Total Clicks: 0")
      This\SetString("StatusText", "Status: Ready")

      ; 2. Register Commands
      Protected *cmd1.UI::MVVM::RelayCommand = New UI::MVVM::RelayCommand(@SimpleVM_OnClickBtn1())
      This\RegisterCommand("ClickBtn1Command", *cmd1)

      Protected *cmd2.UI::MVVM::RelayCommand = New UI::MVVM::RelayCommand(@SimpleVM_OnClickBtn2())
      This\RegisterCommand("ClickBtn2Command", *cmd2)

      Protected *cmd3.UI::MVVM::RelayCommand = New UI::MVVM::RelayCommand(@SimpleVM_OnClickBtn3())
      This\RegisterCommand("ClickBtn3Command", *cmd3)

      Protected *cmdReset.UI::MVVM::RelayCommand = New UI::MVVM::RelayCommand(@SimpleVM_OnReset())
      This\RegisterCommand("ResetCommand", *cmdReset)
    }

    Public Method OnClickButton(btnIndex.i) {
      This\clickCount + 1
      This\SetString("ClickMessage", "You clicked on Button " + Str(btnIndex))
      This\SetString("TotalClicksText", "Total Clicks: " + Str(This\clickCount))
      This\SetString("StatusText", "Status: Button " + Str(btnIndex) + " clicked")
    }

    Public Method OnHoverButton(btnIndex.i) {
      If btnIndex > 0
        This\SetString("HoverMessage", "You are hovering Button " + Str(btnIndex))
      Else
        This\SetString("HoverMessage", "No button hovered")
      EndIf
    }

    Public Method OnReset() {
      This\clickCount = 0
      This\SetString("ClickMessage", "Values reset to default")
      This\SetString("HoverMessage", "Hover over any button to test mouse hover")
      This\SetString("TotalClicksText", "Total Clicks: 0")
      This\SetString("StatusText", "Status: Reset completed")
    }
  }

}

Procedure SimpleVM_OnClickBtn1(*param)
  If *CurrentSimpleViewModel
    Protected *vm1.Demo::ViewModels::SimpleViewModel = *CurrentSimpleViewModel
    *vm1\OnClickButton(1)
  EndIf
EndProcedure

Procedure SimpleVM_OnClickBtn2(*param)
  If *CurrentSimpleViewModel
    Protected *vm2.Demo::ViewModels::SimpleViewModel = *CurrentSimpleViewModel
    *vm2\OnClickButton(2)
  EndIf
EndProcedure

Procedure SimpleVM_OnClickBtn3(*param)
  If *CurrentSimpleViewModel
    Protected *vm3.Demo::ViewModels::SimpleViewModel = *CurrentSimpleViewModel
    *vm3\OnClickButton(3)
  EndIf
EndProcedure

Procedure SimpleVM_OnReset(*param)
  If *CurrentSimpleViewModel
    Protected *vmReset.Demo::ViewModels::SimpleViewModel = *CurrentSimpleViewModel
    *vmReset\OnReset()
  EndIf
EndProcedure
