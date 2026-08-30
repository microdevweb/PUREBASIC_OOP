; ============================================================================
; Title:       ide_parser_symbols.pb
; Description: Analyseur rapide de symboles (Classes, Méthodes) pour l'arbre et l'autocomplétion
; Author:      Expert PureBasic OOP
; ============================================================================

EnableExplicit

Structure IDE_Symbol
  name.s
  type.s        ; "Class", "Method", "Procedure"
  className.s   ; Classe parente pour les méthodes
  line.i        ; Numéro de ligne (1-indexé)
EndStructure

Global NewList IDE_FoundSymbols.IDE_Symbol()

Procedure IDE_ExtractSymbolsFromText(sourceCode.s)
  ClearList(IDE_FoundSymbols())
  
  Protected lineCount = CountString(sourceCode, #LF$) + 1
  Protected i.i, rawLine.s, line.s, upper.s
  Protected currentClass.s = ""
  
  For i = 1 To lineCount
    rawLine = StringField(sourceCode, i, #LF$)
    line = Trim(RemoveString(rawLine, #CR$))
    upper = UCase(line)
    
    ; 1. Détection de Class
    If Left(upper, 6) = "CLASS "
      Protected className.s = Trim(Mid(line, 7))
      If FindString(className, " ")
        className = StringField(className, 1, " ")
      EndIf
      currentClass = className
      
      AddElement(IDE_FoundSymbols())
      IDE_FoundSymbols()\name = className
      IDE_FoundSymbols()\type = "Class"
      IDE_FoundSymbols()\className = ""
      IDE_FoundSymbols()\line = i
      
    ElseIf Left(upper, 8) = "ENDCLASS"
      currentClass = ""
      
    ; 2. Détection de Method
    ElseIf FindString(upper, "METHOD ")
      Protected pMethod = FindString(upper, "METHOD ")
      Protected methodDecl.s = Trim(Mid(line, pMethod + 7))
      Protected methodName.s = methodDecl
      If FindString(methodName, "(")
        methodName = StringField(methodName, 1, "(")
      EndIf
      
      AddElement(IDE_FoundSymbols())
      IDE_FoundSymbols()\name = Trim(methodName)
      IDE_FoundSymbols()\type = "Method"
      IDE_FoundSymbols()\className = currentClass
      IDE_FoundSymbols()\line = i
      
    ; 3. Détection de Procedure standard
    ElseIf Left(upper, 10) = "PROCEDURE " Or Left(upper, 11) = "PROCEDUREC " Or Left(upper, 13) = "PROCEDUREDLL "
      Protected pProc = FindString(upper, "PROCEDURE")
      Protected procDecl.s = Trim(Mid(line, pProc + 9))
      If Left(procDecl, 1) = "." Or Left(procDecl, 1) = "$"
        ; Retirer le type de retour ex: Procedure.s Nom()
        Protected spacePos = FindString(procDecl, " ")
        If spacePos
          procDecl = Trim(Mid(procDecl, spacePos + 1))
        EndIf
      EndIf
      
      Protected procName.s = procDecl
      If FindString(procName, "(")
        procName = StringField(procName, 1, "(")
      EndIf
      
      AddElement(IDE_FoundSymbols())
      IDE_FoundSymbols()\name = Trim(procName)
      IDE_FoundSymbols()\type = "Procedure"
      IDE_FoundSymbols()\className = ""
      IDE_FoundSymbols()\line = i
    EndIf
  Next
EndProcedure
