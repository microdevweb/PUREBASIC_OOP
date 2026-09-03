
; ============================================================================
; Test Multi-Fichiers (1 fichier par classe) avec Namespaces & Polymorphisme
; Fichier principal : src/test_multifile_project.pb
; ============================================================================

XIncludeFile "entities/Animal.pb"
XIncludeFile "entities/Dog.pb"
XIncludeFile "entities/Cat.pb"

; Import direct du namespace
Using Myname::Entities

OpenConsole()
PrintN("=================================================================")
PrintN("   Test Projet Multi-Fichiers & Namespaces (1 fichier/classe)   ")
PrintN("=================================================================")

; Instanciation des classes définies dans des fichiers séparés
Define *monChien.Dog = New Dog("Rex", 4, "Berger Allemand")
Define *monChat.Cat = New Cat("Felix", 2, "Gris tigre")

; Tableau polymorphique d'animaux
Dim *animaux.Animal(1)
*animaux(0) = *monChien
*animaux(1) = *monChat

PrintN("--- Appel polymorphique Crier() ---")
Define i.i
For i = 0 To 1
  *animaux(i)\Crier()
Next

PrintN("=================================================================")
PrintN("")
PrintN("Appuyez sur Entree pour quitter...")
Input()
CloseConsole()

; IDE Options = PureBasic 6.40 (Windows - x64)
; CursorPosition = 20
; EnableXP
; DPIAware