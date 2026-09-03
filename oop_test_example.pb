; ==============================================================================
; Application : PureBasic OOP - Exemple de Test Complet
; Author      : MicrodevWeb
; ==============================================================================

; --- 1. Définition de la Classe de Base : Human ---
Class Human
  Protected Name.s
  Protected Age.i

  Public Method Init(Name.s, Age.i)
    This\Name = Name
    This\Age  = Age
  EndMethod

  Public Method SayHello()
    MessageRequester("Human", "Hello, my name is " + This\Name + " and I am " + Str(This\Age) + " years old.")
  EndMethod
  
  Public Method Free()
    ; Clean up resources
  EndMethod
EndClass

; --- 2. Définition de la Classe Dérivée : Developer (Héritage) ---
Class Developer Extends Human
  Private FavoriteLanguage.s

  Public Method Init(Name.s, Age.i, FavoriteLanguage.s)
    Super\Init(Name, Age)
    This\FavoriteLanguage = FavoriteLanguage
  EndMethod

  Public Method SayHello()
    MessageRequester("Developer", "Hello world! I am " + This\Name + ", coding with " + This\FavoriteLanguage + "!")
  EndMethod
EndClass

; --- 3. Point d'Entrée Principal ---
Procedure Main()
  Protected *dev.Developer = New(Developer, "DevMicro", 30, "PureBasic OOP")
  
  If *dev
    *dev\SayHello()
    *dev\Free()
  EndIf
EndProcedure

Main()
