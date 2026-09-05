Class people
  Protected name.s
  Protected first_name.s
  
  Public Method Init(name.s, first_name.s)
    This\name = name
    This\first_name = first_name
  EndMethod
  
  ; Getter & Setter for name
  Public Method.s Get_name()
    ProcedureReturn This\name
  EndMethod

  Public Method Set_name(val.s)
    This\name = val
  EndMethod

  ; Getter & Setter for first_name
  Public Method.s Get_first_name()
    ProcedureReturn This\first_name
  EndMethod

  Public Method Set_first_name(val.s)
    This\first_name = val
  EndMethod

  Public Method say_hello()
    MessageRequester("Hello", "Hello " + This\Get_first_name() + " " + This\Get_name())
  EndMethod
  
  Public Method Free()
  EndMethod
EndClass 

Procedure Main()
  Protected *dev.people = New people("Bielen", "Pierre")
  If *dev
    *dev\say_hello()
    *dev\Set_first_name("Jean")
    *dev\say_hello()
  EndIf
EndProcedure

Main()
