; Test unimplemented abstract method in concrete class
Abstract Class Animal
  Public Abstract Method Crier()
EndClass

Class Dog Extends Animal ; ERROR line 6: missing implementation of Crier
  Public name.s
EndClass

OpenConsole()
Define *d.Dog = New Dog()
CloseConsole()
