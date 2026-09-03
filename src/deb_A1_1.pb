
XIncludeFile "ui/UI.pbi"

Using UI
Using UI::Controls

Class MainWindow Extends UI::Window
  Public Method Init() 
    Super::Init("Test",#PB_Ignore, #PB_Ignore, 480, 420, #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
  EndMethod 
  Public Method.b OnClose()
    ProcedureReturn #True
  EndMethod 
EndClass

Define *app.UI::Application = New UI::Application()
Define *mainWin.MainWindow = New MainWindow()

*app\Run()
; IDE Options = PureBasic 6.40 (Windows - x64)
; CursorPosition = 12
; EnableXP
; DPIAware