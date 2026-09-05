; ============================================================================
; PureBasic OOP MVVM Demo - TaskModel.pbi
; Pure Domain Model Entity
; ============================================================================

Namespace Demo::Models {

  Class TaskItem {
    Protected id.i
    Protected title.s
    Protected category.s
    Protected isCompleted.b

    Public Method Init(id_p.i, title_p.s, cat_p.s) {
      This\id = id_p
      This\title = title_p
      This\category = cat_p
      This\isCompleted = #False
    }

    Public Method Init(id_p.i, title_p.s, cat_p.s, done_p.b) {
      This\id = id_p
      This\title = title_p
      This\category = cat_p
      This\isCompleted = done_p
    }

    Public Method.i GetId() {
      ProcedureReturn This\id
    }

    Public Method.s GetTitle() {
      ProcedureReturn This\title
    }

    Public Method SetTitle(t.s) {
      This\title = t
    }

    Public Method.s GetCategory() {
      ProcedureReturn This\category
    }

    Public Method SetCategory(c.s) {
      This\category = c
    }

    Public Method.b IsCompleted() {
      ProcedureReturn This\isCompleted
    }

    Public Method SetCompleted(done.b) {
      This\isCompleted = done
    }

    Public Method.s ToTableRow() {
      Protected statusStr.s = "En cours"
      If This\isCompleted : statusStr = "Termine" : EndIf
      ProcedureReturn Str(This\id) + Chr(10) + This\title + Chr(10) + This\category + Chr(10) + statusStr
    }
  }

}
