; ============================================================================
; Test: Static Memory Leak Detection System (Transpiler Warning)
; ============================================================================

OpenConsole("PureBasic OOP - Test Leak Detection")

Class Document
  Private titre.s
  
  Public Method Init(titre_p.s) {
    This\titre = titre_p
  }
  
  Public Method Afficher() {
    PrintN("Document: " + This\titre)
  }
  
  Public Method Free() {
  }
EndClass

Procedure TraiterRapport()
  ; CAS 1 : ALERTE ! Cette instance n'est jamais liberee avant la fin de la procedure
  Protected *docTemporaire.Document = New Document("Rapport Annuel")
  *docTemporaire\Afficher()
  ; -> Manque Free(*docTemporaire) ou *docTemporaire\Free()
  *docTemporaire\Free()
EndProcedure

Procedure.i CreerDocumentModele()
  ; CAS 2 : SAIN. L'objet est retourne (transfert de propriete a l'appelant)
  Protected *modele.Document = New Document("Modele V1")
  ProcedureReturn *modele
EndProcedure

; ============================================================================
; MAIN PROGRAM
; ============================================================================

PrintN("--- Execution des tests ---")

; Execution de la procedure avec fuite
TraiterRapport()

; CAS 3 : SAIN dans Main (Alloue puis libere)
Define *monDoc.Document = New Document("Doc Main")
*monDoc\Afficher()
*monDoc\Free()

; CAS 4 : ALERTE dans Main ! (Alloue mais jamais libere)
Define *docOublie.Document = New Document("Oubli Final")
; -> Manque *docOublie\Free()
*docOublie\Free()
PrintN("")
PrintN("Tests termines ! Appuyez sur Entree pour quitter...")
Input()
CloseConsole()

; IDE Options = PureBasic 6.40 (Windows - x64)
; CursorPosition = 23
; FirstLine = 13
; Folding = -
; EnableXP
; DPIAware