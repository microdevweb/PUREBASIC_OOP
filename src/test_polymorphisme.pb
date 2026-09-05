; ============================================================================
; Test PureBasic OOP : Heritage, Polymorphisme & Super\
; Fichier source : test_polymorphisme.pb
; ============================================================================

; ----------------------------------------------------------------------------
; 1. CLASSE DE BASE : Animal
; ----------------------------------------------------------------------------
Abstract Class Animal
  Protected nom.s
  Protected age.i
  
  Public Method Init(nom_p.s, age_p.i)
  Public Method Crier()
  Public Method Manger(nourriture.s)
  Public Method Free()
EndClass

Method Animal::Init(nom_p.s, age_p.i)
  This\nom = nom_p
  This\age = age_p
EndMethod

Method Animal::Crier()
  PrintN("[Animal] " + This\nom + " (" + Str(This\age) + " ans) emet un son generique.")
EndMethod

Method Animal::Manger(nourriture.s)
  PrintN("[Animal] " + This\nom + " mange avec appetit : " + nourriture)
EndMethod

Method Animal::Free()
  PrintN("[Animal::Free] Nettoyage memoire pour : " + This\nom)
  FreeStructure(This)
EndMethod

; ----------------------------------------------------------------------------
; 2. CLASSE DERIVEE : Chien (Herite de Animal)
; ----------------------------------------------------------------------------
Class Chien Extends Animal
  Protected race.s
  
  Public Method Init(nom_p.s, age_p.i, race_p.s)
  Public Method Crier()
  Public Method Rapporter(objet.s)
  Public Method Free()
EndClass

Method Chien::Init(nom_p.s, age_p.i, race_p.s)
  Super\Init(nom_p, age_p)
  This\race = race_p
EndMethod

Method Chien::Crier()
  Super\Crier()
  PrintN("   ==> CHIEN (" + This\race + ") : Wouaf ! Wouaf ! Grrr !")
EndMethod

Method Chien::Rapporter(objet.s)
  PrintN("   ==> " + This\nom + " court et rapporte joyeusement : " + objet)
EndMethod

Method Chien::Free()
  PrintN("[Chien::Free] Liberation specifique du chien " + This\nom)
  Super\Free()
EndMethod

; ----------------------------------------------------------------------------
; 3. CLASSE DERIVEE : Chat (Herite de Animal)
; ----------------------------------------------------------------------------
Class Chat Extends Animal
  Protected nbVies.i
  
  Public Method Init(nom_p.s, age_p.i, nbVies_p.i)
  Public Method Crier()
  Public Method Ronronner()
  Public Method Free()
EndClass

Method Chat::Init(nom_p.s, age_p.i, nbVies_p.i)
  Super\Init(nom_p, age_p)
  This\nbVies = nbVies_p
EndMethod

Method Chat::Crier()
  Super\Crier()
  PrintN("   ==> CHAT (Vies restantes: " + Str(This\nbVies) + ") : Miaouuuu...")
EndMethod

Method Chat::Ronronner()
  PrintN("   ==> " + This\nom + " fait ronron sur le canape.")
EndMethod

Method Chat::Free()
  PrintN("[Chat::Free] Liberation specifique du chat " + This\nom)
  Super\Free()
EndMethod

; ============================================================================
; 4. PROGRAMME PRINCIPAL DE TEST & DEMONSTRATION DU POLYMORPHISME
; ============================================================================

OpenConsole()
CompilerIf #PB_Compiler_OS = #PB_OS_Windows
  SetConsoleOutputCP_(65001) ; Support UTF-8 en console Windows
CompilerEndIf

PrintN("=================================================================")
PrintN("       DEMONSTRATION DU SYSTEME ORIENTE OBJET PUREBASIC          ")
PrintN("=================================================================")
PrintN("")

; A. Instanciations avec types concrets
PrintN("--- 1. Instanciations et appels de methodes directes ---")
Define *chien.Chien = New Chien("Medor", 4, "Golden Retriever")
Define *chat.Chat = New Chat("Felix", 2, 9)

If *chien
  *chien\Crier()
  *chien\Manger("un os a moelle")
  *chien\Rapporter("la balle de tennis")
EndIf

PrintN("")
If *chat
  *chat\Crier()
  *chat\Manger("une boite de thon")
  *chat\Ronronner()
EndIf

PrintN("")
PrintN("--- 2. Demonstration du Polymorphisme Dynamique (Liste d'Animal) ---")

; B. Polymorphisme : tableau / liste de pointeurs de type de base (Animal)
NewList *refuge.Animal()

AddElement(*refuge()) : *refuge() = *chien
AddElement(*refuge()) : *refuge() = *chat
AddElement(*refuge()) : *refuge() = New Chien("Rex", 7, "Berger Allemand")
AddElement(*refuge()) : *refuge() = New Chat("Minouche", 1, 9)

PrintN("Nombre d'animaux dans le refuge : " + Str(ListSize(*refuge())))
PrintN("")

; Iteration polymorphe : chaque appel a Crier() et Free() dispatch vers la bonne classe !
ForEach *refuge()
  PrintN("-> Appel polymorphe sur animal [Index " + Str(ListIndex(*refuge())) + "] :")
  *refuge()\Crier()
  *refuge()\Manger("des croquettes")
  PrintN("")
Next

PrintN("--- 3. Nettoyage memoire polymorphe ---")
ForEach *refuge()
  *refuge()\Free()
Next
ClearList(*refuge())

PrintN("")
PrintN("=================================================================")
PrintN("               FIN DU TEST - TOUT S'EST DEROULE AVEC SUCCES      ")
PrintN("=================================================================")
PrintN("")
PrintN("Appuyez sur Entree pour quitter...")
Input()
CloseConsole()

; IDE Options = PureBasic 6.40 (Windows - x64)
; CursorPosition = 15
; Folding = -
; EnableXP
; DPIAware