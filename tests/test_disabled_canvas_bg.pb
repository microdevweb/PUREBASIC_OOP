; Test disabled CanvasGadget as transparent-to-mouse visual background panel
OpenWindow(0, 100, 100, 600, 400, "Background Canvas Test", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
SetWindowColor(0, RGB(248, 250, 252))

; 1. Create background canvas and disable it
bg = CanvasGadget(#PB_Any, 0, 0, 180, 400)
DisableGadget(bg, #True)
If StartDrawing(CanvasOutput(bg))
  Box(0, 0, 180, 400, RGB($18, $18, $1B))
  StopDrawing()
EndIf

; 2. Create card background canvas and disable it
card = CanvasGadget(#PB_Any, 200, 50, 360, 200)
DisableGadget(card, #True)
If StartDrawing(CanvasOutput(card))
  RoundBox(0, 0, 360, 200, 8, 8, RGB($E2, $E8, $F0))
  RoundBox(1, 1, 358, 198, 7, 7, RGB(255, 255, 255))
  StopDrawing()
EndIf

; 3. Create interactive button inside card
btn = ButtonGadget(#PB_Any, 220, 80, 120, 30, "Click Me!")

Repeat
  Event = WaitWindowEvent(50)
  If Event = #PB_Event_Gadget
    If EventGadget() = btn
      Debug "Interactive button clicked successfully!"
      Break
    EndIf
  EndIf
  count + 1
  If count > 60 : Break : EndIf
Until Event = #PB_Event_CloseWindow
