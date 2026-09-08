OpenConsole()
OpenWindow(0, 200, 200, 300, 200, "Test Canvas Events", #PB_Window_SystemMenu)
CanvasGadget(0, 50, 50, 200, 100, #PB_Canvas_Keyboard)

Repeat
  ev = WaitWindowEvent()
  If ev = #PB_Event_Gadget And EventGadget() = 0
    t = EventType()
    Select t
      Case #PB_EventType_MouseEnter : PrintN("MOUSE ENTER")
      Case #PB_EventType_MouseLeave : PrintN("MOUSE LEAVE")
      Case #PB_EventType_MouseMove  : ; PrintN("MOUSE MOVE")
      Case #PB_EventType_LeftButtonDown : PrintN("DOWN")
      Case #PB_EventType_LeftButtonUp : PrintN("UP")
      Default: PrintN("Other event: " + Str(t))
    EndSelect
  EndIf
Until ev = #PB_Event_CloseWindow
CloseConsole()
