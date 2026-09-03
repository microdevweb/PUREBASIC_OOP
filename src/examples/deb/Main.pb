
XIncludeFile "views/MainWindow.pbi"
XIncludeFile "../../ui/UI.pbi"

Global *mainWin.MainWindow,*app.UI::Application

Procedure Init()
  *mainWin = New MainWindow()
  *app = New UI::Application()
  *app\SetMainWindow(*mainWin)
EndProcedure

Init()
*app\Run()

; IDE Options = PureBasic 6.40 (Windows - x64)
; CursorPosition = 1
; Folding = -
; EnableXP
; DPIAware