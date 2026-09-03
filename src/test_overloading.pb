; ============================================================================
; Test Suite: Method Overloading & Multiple Constructors for PureBasic OOP
; ============================================================================

EnableExplicit

; ----------------------------------------------------------------------------
; Class 1: Calculatrice (Type Overloading)
; ----------------------------------------------------------------------------
Class Calculatrice
  Public Method.i Additionner(a.i, b.i)
    ProcedureReturn a + b
  EndMethod

  Public Method.s Additionner(a.s, b.s)
    ProcedureReturn a + " " + b
  EndMethod

  Public Method.d Additionner(a.d, b.d)
    ProcedureReturn a + b
  EndMethod
EndClass

; ----------------------------------------------------------------------------
; Class 2: Formateur (Arity Overloading)
; ----------------------------------------------------------------------------
Class Formateur
  Public Method.s Formater(val.i)
    ProcedureReturn "Nombre: " + Str(val)
  EndMethod

  Public Method.s Formater(val.i, prefixe.s)
    ProcedureReturn prefixe + ": " + Str(val)
  EndMethod

  Public Method.s Formater(val.i, prefixe.s, suffixe.s)
    ProcedureReturn prefixe + ": " + Str(val) + " (" + suffixe + ")"
  EndMethod
EndClass

; ----------------------------------------------------------------------------
; Class 3: Point2D (Multiple Constructors: Overloaded Init)
; ----------------------------------------------------------------------------
Class Point2D
  Public x.i
  Public y.i
  Public tag.s

  ; Constructeur 1: Point à l'origine (0, 0)
  Public Method Init()
    This\x = 0
    This\y = 0
    This\tag = "Origine"
  EndMethod

  ; Constructeur 2: Coordonnées spécifiques
  Public Method Init(px.i, py.i)
    This\x = px
    This\y = py
    This\tag = "Point"
  EndMethod

  ; Constructeur 3: Coordonnées + Tag
  Public Method Init(px.i, py.i, ptag.s)
    This\x = px
    This\y = py
    This\tag = ptag
  EndMethod

  Public Method.s ToString()
    ProcedureReturn "[" + This\tag + "] (" + Str(This\x) + ", " + Str(This\y) + ")"
  EndMethod
EndClass

; ----------------------------------------------------------------------------
; Main Verification Program
; ----------------------------------------------------------------------------
OpenConsole()
CompilerIf #PB_Compiler_OS = #PB_OS_Windows
  SetConsoleOutputCP_(65001)
CompilerEndIf
PrintN("=== TEST SUITE: METHOD OVERLOADING & MULTI-CONSTRUCTORS ===")
PrintN("")

; 1. Test Calculatrice (Type Overloading)
Define *calc.Calculatrice = New Calculatrice()

Define resI.i = *calc\Additionner(15, 25)
If resI = 40
  PrintN("[PASS] Additionner(15, 25) = 40 (Integer)")
Else
  PrintN("[FAIL] Additionner integer returned " + Str(resI))
EndIf

Define resS.s = *calc\Additionner("PureBasic", "OOP")
If resS = "PureBasic OOP"
  PrintN("[PASS] Additionner('PureBasic', 'OOP') = 'PureBasic OOP' (String)")
Else
  PrintN("[FAIL] Additionner string returned '" + resS + "'")
EndIf

Define resD.d = *calc\Additionner(12.5, 7.5)
If resD = 20.0
  PrintN("[PASS] Additionner(12.5, 7.5) = 20.0 (Double)")
Else
  PrintN("[FAIL] Additionner double returned " + StrD(resD))
EndIf

PrintN("")

; 2. Test Formateur (Arity Overloading)
Define *fmt.Formateur = New Formateur()

Define f1.s = *fmt\Formater(42)
If f1 = "Nombre: 42"
  PrintN("[PASS] Formater(42) = 'Nombre: 42'")
Else
  PrintN("[FAIL] Formater(42) = '" + f1 + "'")
EndIf

Define f2.s = *fmt\Formater(42, "Score")
If f2 = "Score: 42"
  PrintN("[PASS] Formater(42, 'Score') = 'Score: 42'")
Else
  PrintN("[FAIL] Formater(42, 'Score') = '" + f2 + "'")
EndIf

Define f3.s = *fmt\Formater(42, "Score", "Points")
If f3 = "Score: 42 (Points)"
  PrintN("[PASS] Formater(42, 'Score', 'Points') = 'Score: 42 (Points)'")
Else
  PrintN("[FAIL] Formater 3 args = '" + f3 + "'")
EndIf

PrintN("")

; 3. Test Point2D (Multiple Constructors)
Define *p1.Point2D = New Point2D()
Define *p2.Point2D = New Point2D(100, 200)
Define *p3.Point2D = New Point2D(50, 75, "PlayerSpawn")

Define strP1.s = *p1\ToString()
If strP1 = "[Origine] (0, 0)"
  PrintN("[PASS] New Point2D() -> " + strP1)
Else
  PrintN("[FAIL] New Point2D() -> " + strP1)
EndIf

Define strP2.s = *p2\ToString()
If strP2 = "[Point] (100, 200)"
  PrintN("[PASS] New Point2D(100, 200) -> " + strP2)
Else
  PrintN("[FAIL] New Point2D(100, 200) -> " + strP2)
EndIf

Define strP3.s = *p3\ToString()
If strP3 = "[PlayerSpawn] (50, 75)"
  PrintN("[PASS] New Point2D(50, 75, 'PlayerSpawn') -> " + strP3)
Else
  PrintN("[FAIL] New Point2D(50, 75, 'PlayerSpawn') -> " + strP3)
EndIf

Free(*calc)
Free(*fmt)
Free(*p1)
Free(*p2)
Free(*p3)

PrintN("")
PrintN("Appuyez sur Entree pour quitter...")
Input()
CloseConsole()
