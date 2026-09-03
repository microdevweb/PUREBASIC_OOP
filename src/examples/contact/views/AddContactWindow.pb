; ============================================================================
; PureBasic OOP - Add Contact Window
; Dedicated Window for Creating New Contacts
; Author:      MicrodevWeb
; ============================================================================

XIncludeFile "../../../ui/UI.pb"
XIncludeFile "../models/Contact.pb"

Namespace ContactApp {

  Class AddContactWindow Extends UI::Window {
    Protected *rootPanel.UI::Layouts::StackPanel
    Protected *headerLabel.UI::Label

    Protected *txtFirstName.UI::TextBox
    Protected *txtLastName.UI::TextBox
    Protected *txtEmail.UI::TextBox
    Protected *txtPhone.UI::TextBox
    Protected *txtCompany.UI::TextBox
    Protected *txtNotes.UI::TextBox

    Protected *btnSave.UI::Button
    Protected *btnCancel.UI::Button

    Public Method Init(parentWinId.i = 0) {
      Protected winFlags.i = #PB_Window_SystemMenu | #PB_Window_ScreenCentered | #PB_Window_MinimizeGadget
      This\CreateWindowInternal("Add New Contact", #PB_Ignore, #PB_Ignore, 460, 520, winFlags, parentWinId)

      ; Root vertical panel
      This\*rootPanel = New UI::Layouts::StackPanel(#UI_Orientation_Vertical, 8)
      This\*rootPanel\SetMargin(16, 16, 16, 16)

      ; Header Title
      This\*headerLabel = New UI::Label("Create New Contact")
      This\*rootPanel\AddChild(This\*headerLabel)

      ; Form Fields
      This\*rootPanel\AddChild(New UI::Label("First Name:"))
      This\*txtFirstName = New UI::TextBox("", 420, 26)
      This\*rootPanel\AddChild(This\*txtFirstName)

      This\*rootPanel\AddChild(New UI::Label("Last Name:"))
      This\*txtLastName = New UI::TextBox("", 420, 26)
      This\*rootPanel\AddChild(This\*txtLastName)

      This\*rootPanel\AddChild(New UI::Label("Email Address:"))
      This\*txtEmail = New UI::TextBox("", 420, 26)
      This\*rootPanel\AddChild(This\*txtEmail)

      This\*rootPanel\AddChild(New UI::Label("Phone Number:"))
      This\*txtPhone = New UI::TextBox("", 420, 26)
      This\*rootPanel\AddChild(This\*txtPhone)

      This\*rootPanel\AddChild(New UI::Label("Company:"))
      This\*txtCompany = New UI::TextBox("", 420, 26)
      This\*rootPanel\AddChild(This\*txtCompany)

      This\*rootPanel\AddChild(New UI::Label("Notes:"))
      This\*txtNotes = New UI::TextBox("", 420, 26)
      This\*rootPanel\AddChild(This\*txtNotes)

      ; Button Bar (Horizontal StackPanel)
      Protected *btnBar.UI::Layouts::StackPanel = New UI::Layouts::StackPanel(#UI_Orientation_Horizontal, 10)
      *btnBar\SetHorizontalAlignment(#UI_Align_Right)
      *btnBar\SetMargin(0, 10, 0, 0)

      This\*btnCancel = New UI::Button("Cancel", 90, 32)
      *btnBar\AddChild(This\*btnCancel)

      This\*btnSave = New UI::Button("Save Contact", 120, 32)
      *btnBar\AddChild(This\*btnSave)

      This\*rootPanel\AddChild(*btnBar)

      This\SetContent(This\*rootPanel)
      This\UpdateLayout()
    }

    Public Method ResetFields() {
      This\*txtFirstName\SetText("")
      This\*txtLastName\SetText("")
      This\*txtEmail\SetText("")
      This\*txtPhone\SetText("")
      This\*txtCompany\SetText("")
      This\*txtNotes\SetText("")
    }

    Public Method.b IsSaveClicked(gadgetId.i) {
      ProcedureReturn Bool(This\*btnSave And gadgetId = This\*btnSave\GetId())
    }

    Public Method.b IsCancelClicked(gadgetId.i) {
      ProcedureReturn Bool(This\*btnCancel And gadgetId = This\*btnCancel\GetId())
    }

    Public Method.s GetFirstName() {
      ProcedureReturn This\*txtFirstName\GetText()
    }

    Public Method.s GetLastName() {
      ProcedureReturn This\*txtLastName\GetText()
    }

    Public Method.s GetEmail() {
      ProcedureReturn This\*txtEmail\GetText()
    }

    Public Method.s GetPhone() {
      ProcedureReturn This\*txtPhone\GetText()
    }

    Public Method.s GetCompany() {
      ProcedureReturn This\*txtCompany\GetText()
    }

    Public Method.s GetNotes() {
      ProcedureReturn This\*txtNotes\GetText()
    }

    Public Method.b ValidateInput() {
      Protected fn.s = Trim(This\*txtFirstName\GetText())
      Protected ln.s = Trim(This\*txtLastName\GetText())
      Protected em.s = Trim(This\*txtEmail\GetText())

      If (fn = "" And ln = "" And em = "")
        MessageRequester("Validation", "Please enter at least a First Name, Last Name, or Email Address.", #PB_MessageRequester_Warning)
        ProcedureReturn #False
      EndIf
      ProcedureReturn #True
    }
  }

}
