; ============================================================================
; PureBasic OOP GUI Framework - ViewModelBase.pbi
; Base Class for all Application ViewModels
; Author:      MicrodevWeb
; ============================================================================

XIncludeFile "ObservableObject.pbi"
XIncludeFile "RelayCommand.pbi"

Namespace UI::MVVM {

  Class ViewModelBase Extends ObservableObject {
    Protected Map *commands.UI::MVVM::RelayCommand()

    Public Method Init() {
      Super::Init()
    }

    Public Method Free() {
      ForEach This\*commands()
        If This\*commands()
          This\*commands()\Free()
        EndIf
      Next
      ClearMap(This\*commands())
      Super::Free()
    }

    ; ------------------------------------------------------------------------
    ; Command Management
    ; ------------------------------------------------------------------------
    Public Method RegisterCommand(name_p.s, *cmd.UI::MVVM::RelayCommand) {
      If name_p <> "" And *cmd
        This\*commands(LCase(name_p)) = *cmd
      EndIf
    }

    Public Method.i GetCommand(name_p.s) {
      Protected cKey.s = LCase(name_p)
      If FindMapElement(This\*commands(), cKey)
        ProcedureReturn This\*commands()
      EndIf
      ProcedureReturn 0
    }

    Public Method.b ExecuteCommand(name_p.s, *param = 0) {
      Protected *cmd.UI::MVVM::RelayCommand = This\GetCommand(name_p)
      If *cmd
        If *cmd\CanExecute(*param)
          *cmd\Execute(*param)
          ProcedureReturn #True
        EndIf
      EndIf
      ; Fallback to virtual OnCommand for zero-boilerplate command handling
      ProcedureReturn This\OnCommand(name_p, *param)
    }

    Public Method.b OnCommand(name_p.s, *param = 0) {
      ProcedureReturn #False
    }
  }

}
