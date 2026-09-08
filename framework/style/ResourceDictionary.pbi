; ============================================================================
; PureBasic OOP GUI Framework - ResourceDictionary.pbi
; Resource Dictionary storing WPF-style Named & Implicit Styles
; Author:      MicrodevWeb & Google DeepMind Antigravity
; ============================================================================

XIncludeFile "Style.pbi"

Namespace UI {

  Class ResourceDictionary {
    Protected Map *styles.UI::Style()
    Protected Map *implicitStyles.UI::Style()

    Public Method Init() {
      ClearMap(This\styles())
      ClearMap(This\implicitStyles())
    }

    Public Method Free() {
      ForEach This\styles()
        If This\styles()
          This\styles()\Free()
        EndIf
      Next
      ClearMap(This\styles())

      ForEach This\implicitStyles()
        If This\implicitStyles()
          This\implicitStyles()\Free()
        EndIf
      Next
      ClearMap(This\implicitStyles())
    }

    Public Method AddStyle(*style.UI::Style) {
      If Not *style : ProcedureReturn : EndIf

      ; Résolution de l'héritage éventuel (BasedOn)
      Protected basedOnKey.s = *style\GetBasedOn()
      If basedOnKey <> ""
        Protected *base.UI::Style = This\GetStyle(basedOnKey)
        If *base
          *style\MergeBaseStyle(*base)
        EndIf
      EndIf

      Protected keyStr.s = *style\GetKey()
      If keyStr <> ""
        This\styles(UCase(keyStr)) = *style
      ElseIf *style\GetTargetType() <> ""
        ; Style implicite lié au nom du composant (ex: TargetType="CanvasButton")
        This\implicitStyles(UCase(*style\GetTargetType())) = *style
      EndIf
    }

    Public Method.i GetStyle(key_p.s) {
      Protected normKey.s = UCase(Trim(key_p))
      ; Support des syntaxes XAML "{StaticResource PrimaryButton}" ou "PrimaryButton"
      If Left(normKey, 16) = "{STATICRESOURCE "
        normKey = Trim(Mid(normKey, 17))
        If Right(normKey, 1) = "}" : normKey = Left(normKey, Len(normKey) - 1) : EndIf
      EndIf

      If FindMapElement(This\styles(), normKey)
        ProcedureReturn This\styles(normKey)
      EndIf
      ProcedureReturn 0
    }

    Public Method.i GetImplicitStyle(targetType_p.s) {
      Protected normType.s = UCase(Trim(targetType_p))
      If FindMapElement(This\implicitStyles(), normType)
        ProcedureReturn This\implicitStyles(normType)
      EndIf
      ProcedureReturn 0
    }

    Public Method.b HasStyle(key_p.s) {
      ProcedureReturn Bool(This\GetStyle(key_p) <> 0)
    }

    Public Method Clear() {
      ClearMap(This\styles())
      ClearMap(This\implicitStyles())
    }
  }

}
