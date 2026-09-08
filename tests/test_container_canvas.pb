; Test ContainerGadget with CanvasGadget children in PureBasic
OpenWindow(0, 100, 100, 600, 400, "Container Test", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
SetWindowColor(0, RGB(248, 250, 252))

con = ContainerGadget(#PB_Any, 0, 0, 180, 400, #PB_Container_BorderLess)
SetGadgetColor(con, #PB_Gadget_BackColor, RGB($18, $18, $1B))

btn1 = CanvasGadget(#PB_Any, 10, 20, 160, 40)
If StartVectorDrawing(CanvasVectorOutput(btn1))
  VectorSourceColor(RGBA($27, $27, $2A, 255))
  AddPathRoundBox(0, 0, 160, 40, 6)
  FillPath()
  VectorSourceColor(RGBA(255, 255, 255, 255))
  MovePathCursor(20, 12)
  DrawVectorParagraph("📁 Projects", 140, 20)
  StopVectorDrawing()
EndIf

CloseGadgetList()

; Main loop with 1 sec delay to screenshot
CreateImage(0, 600, 400)
StartDrawing(WindowOutput(0))
; let it show
StopDrawing()

Repeat
  Event = WindowEvent()
  If Event = 0
    Delay(20)
    count + 1
    If count > 30 : Break : EndIf
  EndIf
Until Event = #PB_Event_CloseWindow
