; File: src/entities/Cat.pbi
; Cat class inheriting from Animal inside Namespace Myname::Entities

XIncludeFile "Animal.pbi"

Namespace Myname::Entities

Class Cat Extends Animal
  Protected couleur.s
  
  Public Method Init(nom_p.s, age_p.i, couleur_p.s)
    Super::Init(nom_p, age_p)
    This\couleur = couleur_p
  EndMethod
  
  Public Method Crier()
    PrintN("[Chat] " + This\GetNom() + " (pelage " + This\couleur + ") miaule : Miaou...")
  EndMethod
EndClass

EndNamespace

; IDE Options = PureBasic 6.40 (Windows - x64)
; CursorPosition = 1
; EnableXP
; DPIAware