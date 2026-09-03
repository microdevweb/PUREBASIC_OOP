
XIncludeFile "views/MainWindow.pb"
XIncludeFile "../../ui/UI.pb"

Global *mainWin.MainWindow,*app.UI::Application

Procedure Init()
  *mainWin = New MainWindow()
  *app = New UI::Application()
  *app\SetMainWindow(*mainWin)
EndProcedure

Init()
*app\Run()

; IDE Options = PureBasic 6.40 (Windows - x64)
; CursorPosition = 13
; Folding = -
; EnableXP
; DPIAware