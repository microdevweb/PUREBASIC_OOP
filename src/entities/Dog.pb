; File: src/entities/Dog.pb
; Dog class inheriting from Animal inside Namespace Myname::Entities

XIncludeFile "Animal.pb"

Namespace Myname::Entities

Class Dog Extends Animal
  Protected race.s
  
  Public Method Init(nom_p.s, age_p.i, race_p.s)
    Super::Init(nom_p, age_p)
    This\race = race_p
  EndMethod
  
  Public Method Crier()
    PrintN("[Chien] " + This\GetNom() + " (" + This\race + ", " + Str(This\GetAge()) + " ans) aboie : Wouaf ! Wouaf !")
  EndMethod
EndClass

EndNamespace

; IDE Options = PureBasic 6.40 (Windows - x64)
; CursorPosition = 3
; EnableXP
; DPIAware