; ============================================================================
; Test PureBasic OOP avec Syntaxe C-Style ({ })
; Fichier : src/test_c_style.pb
; ============================================================================

Namespace App::Geometry {

  Abstract Class Shape {
    Protected name.s

    Public Method Init(nom.s) {
      This\name = nom
    }

    Public Abstract Method.d GetArea()
    Public Abstract Method Draw()

    Public Method PrintInfo() {
      PrintN("[Forme] " + This\name + " | Aire = " + StrD(This\GetArea(), 2))
    }
  }

  Class Circle Extends Shape {
    Protected radius.d

    Public Method Init(nom.s, r.d) {
      Super\Init(nom)
      This\radius = r
    }

    Public Method.d GetArea() {
      ProcedureReturn 3.14159 * This\radius * This\radius
    }

    Public Method Draw() {
      PrintN("  -> Dessin du cercle (rayon = " + StrD(This\radius, 2) + ")")
    }
  }

  Class Rectangle Extends Shape {
    Protected width.d, height.d

    Public Method Init(nom.s, w.d, h.d) {
      Super\Init(nom)
      This\width = w
      This\height = h
    }

    Public Method.d GetArea() {
      ProcedureReturn This\width * This\height
    }

    Public Method Draw() {
      PrintN("  -> Dessin du rectangle (" + StrD(This\width, 2) + " x " + StrD(This\height, 2) + ")")
    }
  }

}

; Procédure C-Style avec If/Else et For
Procedure TestCalcul(facteur.i) {
  PrintN("--- Execution Procedure TestCalcul(" + Str(facteur) + ") ---")
  Protected i.i
  For i = 1 To 3 {
    If (i % 2 = 0) {
      PrintN("  Nombre pair : " + Str(i * facteur))
    } Else {
      PrintN("  Nombre impair : " + Str(i * facteur))
    }
  }
}

; Programme Principal
Using App::Geometry

OpenConsole()
PrintN("=================================================================")
PrintN("        Test PureBasic OOP avec Double Syntaxe C-Style ({ })     ")
PrintN("=================================================================")

TestCalcul(10)
PrintN("")

Dim *shapes.Shape(1)
*shapes(0) = New Circle("MonCercle", 5.0)
*shapes(1) = New Rectangle("MonRectangle", 4.0, 6.0)

PrintN("--- Parcours Polymorphique ---")
Define j.i
For j = 0 To 1 {
  *shapes(j)\PrintInfo()
  *shapes(j)\Draw()
}

PrintN("=================================================================")
PrintN("")
PrintN("Appuyez sur Entree pour quitter...")
Input()
CloseConsole()
