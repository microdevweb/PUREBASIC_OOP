Class Robot
  Public name.s
  
  Public Method Beep()
    PrintN("Beep")
    PrintN(UnknownCompilerCall12345()) ; ERROR at line 6 in PBO
  EndMethod
EndClass

OpenConsole()
Define *r.Robot = New Robot()
*r\Beep()
CloseConsole()
