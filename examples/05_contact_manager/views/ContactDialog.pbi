; ============================================================================
; PureBasic OOP - Contact Add/Edit Dialog
; Author:      MicrodevWeb
; ============================================================================

XIncludeFile "../../../ui/UI.pbi"
XIncludeFile "../models/Contact.pbi"

Namespace ContactApp {

  Class ContactDialog Extends UI::Window {
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

    Protected contactId.i
    Protected isSaved.b

    Public Method Init(parentWinId.i = 0, titleText.s = "Contact Details") {
      This\CreateWindowInternal(titleText, #PB_Ignore, #PB_Ignore, 480, 520, #PB_Window_SystemMenu | #PB_Window_ScreenCentered, parentWinId)
      This\contactId = 0
      This\isSaved = #False

      ; Main Vertical StackPanel (with 15px margin around the dialog)
      This\*rootPanel = New UI::Layouts::StackPanel(#UI_Orientation_Vertical, 10)
      This\*rootPanel\SetMargin(15, 15, 15, 15)

      ; Header Title
      This\*headerLabel = New UI::Label(titleText)
      This\*rootPanel\AddChild(This\*headerLabel)

      ; Fields
      This\*rootPanel\AddChild(New UI::Label("First Name:"))
      This\*txtFirstName = New UI::TextBox("", 440, 26)
      This\*rootPanel\AddChild(This\*txtFirstName)

      This\*rootPanel\AddChild(New UI::Label("Last Name:"))
      This\*txtLastName = New UI::TextBox("", 440, 26)
      This\*rootPanel\AddChild(This\*txtLastName)

      This\*rootPanel\AddChild(New UI::Label("Email Address:"))
      This\*txtEmail = New UI::TextBox("", 440, 26)
      This\*rootPanel\AddChild(This\*txtEmail)

      This\*rootPanel\AddChild(New UI::Label("Phone Number:"))
      This\*txtPhone = New UI::TextBox("", 440, 26)
      This\*rootPanel\AddChild(This\*txtPhone)

      This\*rootPanel\AddChild(New UI::Label("Company:"))
      This\*txtCompany = New UI::TextBox("", 440, 26)
      This\*rootPanel\AddChild(This\*txtCompany)

      This\*rootPanel\AddChild(New UI::Label("Notes:"))
      This\*txtNotes = New UI::TextBox("", 440, 26)
      This\*rootPanel\AddChild(This\*txtNotes)

      ; Button Bar (Horizontal StackPanel)
      Protected *btnPanel.UI::Layouts::StackPanel = New UI::Layouts::StackPanel(#UI_Orientation_Horizontal, 12)
      *btnPanel\SetHorizontalAlignment(#UI_Align_Right)
      *btnPanel\SetMargin(0, 10, 0, 0)

      This\*btnCancel = New UI::Button("Cancel", 100, 32)
      *btnPanel\AddChild(This\*btnCancel)

      This\*btnSave = New UI::Button("Save Contact", 120, 32)
      *btnPanel\AddChild(This\*btnSave)

      This\*rootPanel\AddChild(*btnPanel)

      This\SetContent(This\*rootPanel)
      This\UpdateLayout()
    }

    Public Method SetContactData(id_p.i, fn_p.s, ln_p.s, em_p.s, ph_p.s, co_p.s, nt_p.s) {
      This\contactId = id_p
      This\*txtFirstName\SetText(fn_p)
      This\*txtLastName\SetText(ln_p)
      This\*txtEmail\SetText(em_p)
      This\*txtPhone\SetText(ph_p)
      This\*txtCompany\SetText(co_p)
      This\*txtNotes\SetText(nt_p)

      If (id_p > 0)
        This\*headerLabel\SetText("Edit Contact #" + Str(id_p))
      Else
        This\*headerLabel\SetText("Add New Contact")
      EndIf
    }

    Public Method.b IsSaveClicked(gadgetId.i) {
      If (This\*btnSave And gadgetId = This\*btnSave\GetId())
        ProcedureReturn #True
      EndIf
      ProcedureReturn #False
    }

    Public Method.b IsCancelClicked(gadgetId.i) {
      If (This\*btnCancel And gadgetId = This\*btnCancel\GetId())
        ProcedureReturn #True
      EndIf
      ProcedureReturn #False
    }

    Public Method.i GetContactId() {
      ProcedureReturn This\contactId
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
