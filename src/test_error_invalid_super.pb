; Test invalid Super\ call when no parent class exists
Class Solo
  Public Method Test()
    Super\Test() ; ERROR line 4: no parent
  EndMethod
EndClass

OpenConsole()
Define *s.Solo = New Solo()
CloseConsole()
