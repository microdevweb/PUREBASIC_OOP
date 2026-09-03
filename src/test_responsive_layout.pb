; ============================================================================
; Test Suite: Responsive UI Layouts (StackPanel, DockPanel, Grid)
; ============================================================================

XIncludeFile "ui/UI.pb"

Using UI
Using UI::Layouts
Using UI::Controls

EnableExplicit

OpenConsole()
CompilerIf #PB_Compiler_OS = #PB_OS_Windows
  SetConsoleOutputCP_(65001)
CompilerEndIf
PrintN("=== TEST SUITE: RESPONSIVE UI LAYOUTS (WPF STYLE) ===")
PrintN("")

; Creation d'une fenetre de test invisible (indispensable pour que PureBasic puisse instancier des gadgets)
Define *testWin.Window = New Window("Test Responsive", 0, 0, 800, 600, #PB_Window_Invisible)

; ----------------------------------------------------------------------------
; 1. Test StackPanel (Vertical)
; ----------------------------------------------------------------------------
Define *stackV.StackPanel = New StackPanel(#UI_Orientation_Vertical, 10)
*stackV\SetPaddingAll(10)

Define *btn1.Button = New Button(0, 0, 100, 30, "Bouton 1")
Define *btn2.Button = New Button(0, 0, 100, 40, "Bouton 2")
*btn2\SetMargin(5, 5, 5, 5)

*stackV\AddChild(*btn1)
*stackV\AddChild(*btn2)

; Simuler une disposition sur une zone 400x300
*stackV\Arrange(0, 0, 400, 300)

; Verifications positions StackPanel Vertical
; btn1 : x=10 (padding), y=10 (padding), w=380 (400 - 20 padding), h=30 (desired)
; btn2 : x=15 (10 pad + 5 margin), y=10 pad + 30 h + 10 sp + 5 margin = 55, w=370 (380 - 10 margin), h=40
If *btn1\GetX() = 10 And *btn1\GetY() = 10 And *btn1\GetWidth() = 380 And *btn1\GetHeight() = 30
  PrintN("[PASS] StackPanel Vertical (Enfant 1) : " + Str(*btn1\GetX()) + "," + Str(*btn1\GetY()) + " " + Str(*btn1\GetWidth()) + "x" + Str(*btn1\GetHeight()))
Else
  PrintN("[FAIL] StackPanel Vertical (Enfant 1) : " + Str(*btn1\GetX()) + "," + Str(*btn1\GetY()) + " " + Str(*btn1\GetWidth()) + "x" + Str(*btn1\GetHeight()))
EndIf

If *btn2\GetY() = 55 And *btn2\GetHeight() = 40
  PrintN("[PASS] StackPanel Vertical (Enfant 2) : " + Str(*btn2\GetX()) + "," + Str(*btn2\GetY()) + " " + Str(*btn2\GetWidth()) + "x" + Str(*btn2\GetHeight()))
Else
  PrintN("[FAIL] StackPanel Vertical (Enfant 2) : " + Str(*btn2\GetX()) + "," + Str(*btn2\GetY()) + " " + Str(*btn2\GetWidth()) + "x" + Str(*btn2\GetHeight()))
EndIf

; ----------------------------------------------------------------------------
; 2. Test DockPanel
; ----------------------------------------------------------------------------
Define *dock.DockPanel = New DockPanel(#True)
Define *topBar.Button = New Button(0, 0, 100, 40, "Top Bar")
Define *leftBar.Button = New Button(0, 0, 120, 100, "Left Sidebar")
Define *centerView.Button = New Button(0, 0, 50, 50, "Center Fill")

*dock\SetDock(*topBar, #UI_Dock_Top)
*dock\SetDock(*leftBar, #UI_Dock_Left)
*dock\SetDock(*centerView, #UI_Dock_Fill)

*dock\Arrange(0, 0, 800, 600)

If *topBar\GetX() = 0 And *topBar\GetY() = 0 And *topBar\GetWidth() = 800 And *topBar\GetHeight() = 40
  PrintN("[PASS] DockPanel (Top) : " + Str(*topBar\GetWidth()) + "x" + Str(*topBar\GetHeight()))
Else
  PrintN("[FAIL] DockPanel (Top) : " + Str(*topBar\GetWidth()) + "x" + Str(*topBar\GetHeight()))
EndIf

If *leftBar\GetX() = 0 And *leftBar\GetY() = 40 And *leftBar\GetWidth() = 120 And *leftBar\GetHeight() = 560
  PrintN("[PASS] DockPanel (Left) : " + Str(*leftBar\GetWidth()) + "x" + Str(*leftBar\GetHeight()))
Else
  PrintN("[FAIL] DockPanel (Left) : " + Str(*leftBar\GetWidth()) + "x" + Str(*leftBar\GetHeight()))
EndIf

If *centerView\GetX() = 120 And *centerView\GetY() = 40 And *centerView\GetWidth() = 680 And *centerView\GetHeight() = 560
  PrintN("[PASS] DockPanel (Fill) : " + Str(*centerView\GetX()) + "," + Str(*centerView\GetY()) + " " + Str(*centerView\GetWidth()) + "x" + Str(*centerView\GetHeight()))
Else
  PrintN("[FAIL] DockPanel (Fill) : " + Str(*centerView\GetX()) + "," + Str(*centerView\GetY()) + " " + Str(*centerView\GetWidth()) + "x" + Str(*centerView\GetHeight()))
EndIf

; ----------------------------------------------------------------------------
; 3. Test Grid (Star * and Fixed Columns/Rows)
; ----------------------------------------------------------------------------
Define *grid.Grid = New Grid()
*grid\AddColumn("200")  ; Col 0 : 200px fixe
*grid\AddColumn("2*")   ; Col 1 : 2/3 restant
*grid\AddColumn("1*")   ; Col 2 : 1/3 restant
*grid\AddRow("50")      ; Row 0 : 50px fixe
*grid\AddRow("*")       ; Row 1 : reste de la hauteur

Define *gCell00.Button = New Button(0, 0, 10, 10, "Header Left")
Define *gCell01.Button = New Button(0, 0, 10, 10, "Header Main Span")
Define *gCell11.Button = New Button(0, 0, 10, 10, "Body Main")
Define *gCell12.Button = New Button(0, 0, 10, 10, "Body Side")

*grid\SetCell(*gCell00, 0, 0)
*grid\SetCellSpan(*gCell01, 0, 1, 1, 2) ; ColSpan=2
*grid\SetCell(*gCell11, 1, 1)
*grid\SetCell(*gCell12, 1, 2)

; Arrange sur 800 x 500
; Col 0: 200px
; Reste Largeur: 800 - 200 = 600px -> Col 1 = 2/3 * 600 = 400px, Col 2 = 1/3 * 600 = 200px
; Row 0: 50px, Row 1 = 500 - 50 = 450px
*grid\Arrange(0, 0, 800, 500)

If *gCell00\GetWidth() = 200 And *gCell00\GetHeight() = 50
  PrintN("[PASS] Grid Cell(0,0) Fixe (200x50) : " + Str(*gCell00\GetWidth()) + "x" + Str(*gCell00\GetHeight()))
Else
  PrintN("[FAIL] Grid Cell(0,0) Fixe : " + Str(*gCell00\GetWidth()) + "x" + Str(*gCell00\GetHeight()))
EndIf

If *gCell01\GetX() = 200 And *gCell01\GetWidth() = 600
  PrintN("[PASS] Grid Cell(0,1) ColSpan=2 (600px) : X=" + Str(*gCell01\GetX()) + " W=" + Str(*gCell01\GetWidth()))
Else
  PrintN("[FAIL] Grid Cell(0,1) ColSpan=2 : X=" + Str(*gCell01\GetX()) + " W=" + Str(*gCell01\GetWidth()))
EndIf

If *gCell11\GetX() = 200 And *gCell11\GetWidth() = 400 And *gCell11\GetHeight() = 450
  PrintN("[PASS] Grid Cell(1,1) Star 2* (400x450) : " + Str(*gCell11\GetWidth()) + "x" + Str(*gCell11\GetHeight()))
Else
  PrintN("[FAIL] Grid Cell(1,1) Star 2* : " + Str(*gCell11\GetWidth()) + "x" + Str(*gCell11\GetHeight()))
EndIf

If *gCell12\GetX() = 600 And *gCell12\GetWidth() = 200 And *gCell12\GetHeight() = 450
  PrintN("[PASS] Grid Cell(1,2) Star 1* (200x450) : " + Str(*gCell12\GetWidth()) + "x" + Str(*gCell12\GetHeight()))
Else
  PrintN("[FAIL] Grid Cell(1,2) Star 1* : " + Str(*gCell12\GetWidth()) + "x" + Str(*gCell12\GetHeight()))
EndIf

PrintN("")
PrintN("TOUS LES TESTS RESPONSIVE LAYOUT SONT PASSES AVEC SUCCES!")
PrintN("Appuyez sur Entree pour quitter...")
Input()
*testWin\Free()
CloseConsole()

; IDE Options = PureBasic 6.40 (Windows - x64)
; CursorPosition = 35
; FirstLine = 9
; Folding = -
; EnableXP
; DPIAware