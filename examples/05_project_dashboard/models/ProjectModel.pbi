; ============================================================================
; Project Dashboard (WPF Modern UI) - Business Model
; File: models/ProjectModel.pbi
; ============================================================================

Namespace Dashboard {

  Class ProjectModel {
    Protected name.s
    Protected startDate.s
    Protected endDate.s
    Protected priority.s
    Protected status.s
    Protected description.s
    Protected isUrgent.b

    Public Method Init() {
      This\Reset()
    }

    Public Method Reset() {
      This\name        = "Modern UI Core Engine"
      This\startDate   = "01/10/2026"
      This\endDate     = "15/12/2026"
      This\priority    = "High"
      This\status      = "Active"
      This\description = ""
      This\isUrgent    = #False
    }

    Public Method.s GetName() {
      ProcedureReturn This\name
    }

    Public Method SetName(v.s) {
      This\name = v
    }

    Public Method.s GetStartDate() {
      ProcedureReturn This\startDate
    }

    Public Method SetStartDate(v.s) {
      This\startDate = v
    }

    Public Method.s GetEndDate() {
      ProcedureReturn This\endDate
    }

    Public Method SetEndDate(v.s) {
      This\endDate = v
    }

    Public Method.s GetPriority() {
      ProcedureReturn This\priority
    }

    Public Method SetPriority(v.s) {
      This\priority = v
    }

    Public Method.s GetStatus() {
      ProcedureReturn This\status
    }

    Public Method SetStatus(v.s) {
      This\status = v
    }

    Public Method.s GetDescription() {
      ProcedureReturn This\description
    }

    Public Method SetDescription(v.s) {
      This\description = v
    }

    Public Method.b GetIsUrgent() {
      ProcedureReturn This\isUrgent
    }

    Public Method SetIsUrgent(v.b) {
      This\isUrgent = v
    }

    Public Method CopyFrom(*other.Dashboard::ProjectModel) {
      If *other
        This\name        = *other\GetName()
        This\startDate   = *other\GetStartDate()
        This\endDate     = *other\GetEndDate()
        This\priority    = *other\GetPriority()
        This\status      = *other\GetStatus()
        This\description = *other\GetDescription()
        This\isUrgent    = *other\GetIsUrgent()
      EndIf
    }

    Public Method Free() {
    }
  }

}
