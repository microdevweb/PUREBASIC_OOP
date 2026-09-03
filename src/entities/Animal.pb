; File: src/entities/Animal.pb
; Single class file inside Namespace Myname::Entities

Namespace Myname::Entities

Abstract Class Animal
  Protected nom.s
  Protected age.i
  
  Public Method Init(nom_p.s, age_p.i)
    This\nom = nom_p
    This\age = age_p
  EndMethod
  
  Public Abstract Method Crier()
  
  Public Method GetNom.s()
    ProcedureReturn This\nom
  EndMethod
  
  Public Method GetAge.i()
    ProcedureReturn This\age
  EndMethod
EndClass

EndNamespace

; IDE Options = PureBasic 6.40 (Windows - x64)
; CursorPosition = 1
; EnableXP
; DPIAware