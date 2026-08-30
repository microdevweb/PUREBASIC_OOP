; ============================================================================
; Title:       ide_parser_symbols.pb
; Description: Fast symbol parser (Classes, Methods, Procedures) for tree explorer
; Author:      MicrodevWeb
; ============================================================================

EnableExplicit

; ----------------------------------------------------------------------------
; Structure:   IDE_Symbol
; Purpose:     Stores parsed symbol metadata for code outline navigation
; ----------------------------------------------------------------------------
Structure IDE_Symbol
  name.s        ; Symbol name (e.g. "Chien", "Aboyer")
  type.s        ; "Class", "Method", or "Procedure"
  className.s   ; Parent class name for methods
  line.i        ; 1-based source line number
EndStructure

Global NewList IDE_FoundSymbols.IDE_Symbol()

; ----------------------------------------------------------------------------
; Procedure:   IDE_ExtractSymbolsFromText
; Purpose:     Parses source text line by line to discover classes and methods
; Parameters:  sourceCode.s - Entire source code string
; Return:      None
; ----------------------------------------------------------------------------
Procedure IDE_ExtractSymbolsFromText(sourceCode.s)
  ClearList(IDE_FoundSymbols())
  
  Protected lineCount = CountString(sourceCode, #LF$) + 1
  Protected i.i, rawLine.s, line.s, upper.s
  Protected currentClass.s = ""
  
  For i = 1 To lineCount
    rawLine = StringField(sourceCode, i, #LF$)
    line = Trim(RemoveString(rawLine, #CR$))
    upper = UCase(line)
    
    ; 1. Match Class declaration
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
      
    ; 2. Match Method declaration
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
      
    ; 3. Match native Procedure declaration
    ElseIf Left(upper, 10) = "PROCEDURE " Or Left(upper, 11) = "PROCEDUREC " Or Left(upper, 13) = "PROCEDUREDLL "
      Protected pProc = FindString(upper, "PROCEDURE")
      Protected procDecl.s = Trim(Mid(line, pProc + 9))
      If Left(procDecl, 1) = "." Or Left(procDecl, 1) = "$"
        ; Strip return type signature, e.g. Procedure.s Name()
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
