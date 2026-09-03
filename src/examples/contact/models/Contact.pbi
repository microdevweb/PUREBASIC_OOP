; ============================================================================
; PureBasic OOP - Contact Model
; Author:      MicrodevWeb
; ============================================================================

Namespace ContactApp {

  Class Contact {
    Protected id.i
    Protected firstName.s
    Protected lastName.s
    Protected email.s
    Protected phone.s
    Protected company.s
    Protected notes.s

    Public Method Init() {
      This\id = 0
      This\firstName = ""
      This\lastName = ""
      This\email = ""
      This\phone = ""
      This\company = ""
      This\notes = ""
    }

    Public Method Init(id_p.i, fn_p.s, ln_p.s, em_p.s, ph_p.s, co_p.s, nt_p.s) {
      This\id = id_p
      This\firstName = fn_p
      This\lastName = ln_p
      This\email = em_p
      This\phone = ph_p
      This\company = co_p
      This\notes = nt_p
    }

    ; Getters and Setters
    Public Method.i GetId() {
      ProcedureReturn This\id
    }

    Public Method SetId(v.i) {
      This\id = v
    }

    Public Method.s GetFirstName() {
      ProcedureReturn This\firstName
    }

    Public Method SetFirstName(v.s) {
      This\firstName = v
    }

    Public Method.s GetLastName() {
      ProcedureReturn This\lastName
    }

    Public Method SetLastName(v.s) {
      This\lastName = v
    }

    Public Method.s GetEmail() {
      ProcedureReturn This\email
    }

    Public Method SetEmail(v.s) {
      This\email = v
    }

    Public Method.s GetPhone() {
      ProcedureReturn This\phone
    }

    Public Method SetPhone(v.s) {
      This\phone = v
    }

    Public Method.s GetCompany() {
      ProcedureReturn This\company
    }

    Public Method SetCompany(v.s) {
      This\company = v
    }

    Public Method.s GetNotes() {
      ProcedureReturn This\notes
    }

    Public Method SetNotes(v.s) {
      This\notes = v
    }

    Public Method.s GetFullName() {
      Protected fn.s = Trim(This\firstName)
      Protected ln.s = Trim(This\lastName)
      If (fn <> "" And ln <> "")
        ProcedureReturn fn + " " + ln
      ElseIf (fn <> "")
        ProcedureReturn fn
      Else
        ProcedureReturn ln
      EndIf
    }

    Public Method.b IsValid() {
      If (Trim(This\firstName) = "" And Trim(This\lastName) = "" And Trim(This\email) = "")
        ProcedureReturn #False
      EndIf
      ProcedureReturn #True
    }

    Public Method Free() {
    }
  }

}
