; Test CanvasGadget with #PB_Canvas_Container
OpenWindow(0, 100, 100, 600, 400, "Canvas Container Test", #PB_Window_SystemMenu)
con = CanvasGadget(#PB_Any, 10, 10, 200, 300, #PB_Canvas_Container)
Debug "Built-in #PB_Canvas_Container works! ID: " + Str(con)

; Draw on the canvas background!
If StartDrawing(CanvasOutput(con))
  Box(0, 0, 200, 300, RGB($18, $18, $1B))
  StopDrawing()
EndIf

; Add a button inside!
btn = ButtonGadget(#PB_Any, 20, 20, 160, 30, "Inside Canvas!")

CloseGadgetList()

Debug "Button inside canvas container works!"
