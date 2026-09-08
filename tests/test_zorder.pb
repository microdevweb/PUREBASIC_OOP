OpenWindow(0, 100, 100, 600, 400, "Z-Order Test", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
SetWindowColor(0, RGB(248, 250, 252))

; Background canvas
bg = CanvasGadget(#PB_Any, 0, 0, 180, 400)
If StartDrawing(CanvasOutput(bg))
  Box(0, 0, 180, 400, RGB($18, $18, $1B))
  StopDrawing()
EndIf

; Button on top
btn = CanvasGadget(#PB_Any, 10, 20, 160, 40)
If StartDrawing(CanvasOutput(btn))
  RoundBox(0, 0, 160, 40, 6, 6, RGB($27, $27, $2A))
  DrawText(20, 12, "📁 Projects", RGB(255, 255, 255), RGB($27, $27, $2A))
  StopDrawing()
EndIf

Repeat
  Event = WaitWindowEvent(50)
  If Event = #PB_Event_Gadget
    If EventGadget() = btn
      Debug "Button clicked!"
    EndIf
  EndIf
Until Event = #PB_Event_CloseWindow
