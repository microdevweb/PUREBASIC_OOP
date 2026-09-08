; ============================================================================
; PureBasic OOP GUI Framework - Style.pbi
; WPF/XAML-style Declarative Style & Trigger System for CanvasControl
; Author:      MicrodevWeb & Google DeepMind Antigravity
; ============================================================================

Declare.i UI_ParseColor(colorStr.s, defaultColor.i = 0)

Procedure.i UI_ParseColor(colorStr.s, defaultColor.i = 0)
  colorStr = Trim(colorStr)
  If colorStr = "" : ProcedureReturn defaultColor : EndIf
  If Left(colorStr, 1) = "#"
    colorStr = Mid(colorStr, 2)
  ElseIf Left(colorStr, 2) = "0x" Or Left(colorStr, 2) = "0X"
    colorStr = Mid(colorStr, 3)
  ElseIf Left(colorStr, 1) = "$"
    colorStr = Mid(colorStr, 2)
  EndIf

  If Len(colorStr) = 6
    Protected r.i = Val("$" + Mid(colorStr, 1, 2))
    Protected g.i = Val("$" + Mid(colorStr, 3, 2))
    Protected b.i = Val("$" + Mid(colorStr, 5, 2))
    ProcedureReturn RGB(r, g, b)
  ElseIf Len(colorStr) = 3
    Protected r3.i = Val("$" + Mid(colorStr, 1, 1) + Mid(colorStr, 1, 1))
    Protected g3.i = Val("$" + Mid(colorStr, 2, 1) + Mid(colorStr, 2, 1))
    Protected b3.i = Val("$" + Mid(colorStr, 3, 1) + Mid(colorStr, 3, 1))
    ProcedureReturn RGB(r3, g3, b3)
  EndIf

  ProcedureReturn Val(colorStr)
EndProcedure

Structure UI_StyleSetter
  property.s
  value.s
EndStructure

Structure UI_StyleTrigger
  property.s
  value.s
  List setters.UI_StyleSetter()
EndStructure

Namespace UI {

  Class Style {
    Protected targetType.s
    Protected key.s
    Protected basedOn.s
    Protected List setters.UI_StyleSetter()
    Protected List triggers.UI_StyleTrigger()

    Public Method Init() {
      This\targetType = ""
      This\key = ""
      This\basedOn = ""
      ClearList(This\setters())
      ClearList(This\triggers())
    }

    Public Method Init(targetType_p.s, key_p.s = "", basedOn_p.s = "") {
      This\targetType = targetType_p
      This\key = key_p
      This\basedOn = basedOn_p
      ClearList(This\setters())
      ClearList(This\triggers())
    }

    Public Method Free() {
      ClearList(This\setters())
      ForEach This\triggers()
        ClearList(This\triggers()\setters())
      Next
      ClearList(This\triggers())
    }

    Public Method.s GetTargetType() {
      ProcedureReturn This\targetType
    }

    Public Method SetTargetType(t_p.s) {
      This\targetType = t_p
    }

    Public Method.s GetKey() {
      ProcedureReturn This\key
    }

    Public Method SetKey(k_p.s) {
      This\key = k_p
    }

    Public Method.s GetBasedOn() {
      ProcedureReturn This\basedOn
    }

    Public Method SetBasedOn(b_p.s) {
      This\basedOn = b_p
    }

    ; --- Setters ---

    Public Method AddSetter(prop_p.s, val_p.s) {
      ; Remplacer si déjà existant, sinon ajouter
      ForEach This\setters()
        If UCase(This\setters()\property) = UCase(prop_p)
          This\setters()\value = val_p
          ProcedureReturn
        EndIf
      Next
      AddElement(This\setters())
      This\setters()\property = prop_p
      This\setters()\value = val_p
    }

    Public Method.i GetSetterCount() {
      ProcedureReturn ListSize(This\setters())
    }

    Public Method.s GetSetterProperty(idx.i) {
      If SelectElement(This\setters(), idx)
        ProcedureReturn This\setters()\property
      EndIf
      ProcedureReturn ""
    }

    Public Method.s GetSetterValue(idx.i) {
      If SelectElement(This\setters(), idx)
        ProcedureReturn This\setters()\value
      EndIf
      ProcedureReturn ""
    }

    Public Method.s FindSetterValue(prop_p.s, defaultVal.s = "") {
      ForEach This\setters()
        If UCase(This\setters()\property) = UCase(prop_p)
          ProcedureReturn This\setters()\value
        EndIf
      Next
      ProcedureReturn defaultVal
    }

    Public Method.b HasSetter(prop_p.s) {
      ForEach This\setters()
        If UCase(This\setters()\property) = UCase(prop_p)
          ProcedureReturn #True
        EndIf
      Next
      ProcedureReturn #False
    }

    ; --- Triggers ---

    Public Method.i AddTrigger(prop_p.s, val_p.s) {
      Protected idx.i = AddElement(This\triggers())
      This\triggers()\property = prop_p
      This\triggers()\value = val_p
      ClearList(This\triggers()\setters())
      ProcedureReturn ListIndex(This\triggers())
    }

    Public Method AddTriggerSetter(triggerIdx.i, prop_p.s, val_p.s) {
      If SelectElement(This\triggers(), triggerIdx)
        AddElement(This\triggers()\setters())
        This\triggers()\setters()\property = prop_p
        This\triggers()\setters()\value = val_p
      EndIf
    }

    Public Method.i GetTriggerCount() {
      ProcedureReturn ListSize(This\triggers())
    }

    Public Method.s GetTriggerProperty(triggerIdx.i) {
      If SelectElement(This\triggers(), triggerIdx)
        ProcedureReturn This\triggers()\property
      EndIf
      ProcedureReturn ""
    }

    Public Method.s GetTriggerValue(triggerIdx.i) {
      If SelectElement(This\triggers(), triggerIdx)
        ProcedureReturn This\triggers()\value
      EndIf
      ProcedureReturn ""
    }

    Public Method.i GetTriggerSetterCount(triggerIdx.i) {
      If SelectElement(This\triggers(), triggerIdx)
        ProcedureReturn ListSize(This\triggers()\setters())
      EndIf
      ProcedureReturn 0
    }

    Public Method.s GetTriggerSetterProperty(triggerIdx.i, setterIdx.i) {
      If SelectElement(This\triggers(), triggerIdx)
        If SelectElement(This\triggers()\setters(), setterIdx)
          ProcedureReturn This\triggers()\setters()\property
        EndIf
      EndIf
      ProcedureReturn ""
    }

    Public Method.s GetTriggerSetterValue(triggerIdx.i, setterIdx.i) {
      If SelectElement(This\triggers(), triggerIdx)
        If SelectElement(This\triggers()\setters(), setterIdx)
          ProcedureReturn This\triggers()\setters()\value
        EndIf
      EndIf
      ProcedureReturn ""
    }

    ; --- Héritage de Style (BasedOn) ---

    Public Method MergeBaseStyle(*baseStyle.UI::Style) {
      If Not *baseStyle : ProcedureReturn : EndIf

      ; 1. Copier les Setters du style parent qui ne sont pas redéfinis ici
      Protected bCount.i = *baseStyle\GetSetterCount()
      Protected i.i
      For i = 0 To bCount - 1
        Protected bProp.s = *baseStyle\GetSetterProperty(i)
        Protected bVal.s = *baseStyle\GetSetterValue(i)
        If Not This\HasSetter(bProp)
          This\AddSetter(bProp, bVal)
        EndIf
      Next

      ; 2. Copier les Triggers du style parent
      Protected tCount.i = *baseStyle\GetTriggerCount()
      Protected t.i, s.i
      For t = 0 To tCount - 1
        Protected tProp.s = *baseStyle\GetTriggerProperty(t)
        Protected tVal.s = *baseStyle\GetTriggerValue(t)
        Protected newTrigIdx.i = This\AddTrigger(tProp, tVal)
        Protected sCount.i = *baseStyle\GetTriggerSetterCount(t)
        For s = 0 To sCount - 1
          This\AddTriggerSetter(newTrigIdx, *baseStyle\GetTriggerSetterProperty(t, s), *baseStyle\GetTriggerSetterValue(t, s))
        Next
      Next
    }

  }

}
