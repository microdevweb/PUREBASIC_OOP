; ============================================================================
; Title:       ide_autoclose.pb
; Description: Fermeture automatique des blocs (If/EndIf, Class/EndClass, etc.) et paires (), "", etc.
; Author:      Expert PureBasic OOP
; ============================================================================

EnableExplicit

XIncludeFile "ide_scintilla.pb"
XIncludeFile "../config/ide_settings.pb"

; Détecte si le mot correspond à un bloc ouvrant nécessitant une fermeture automatique
Procedure.s IDE_GetClosingKeyword(statement.s)
  Protected upper.s = UCase(Trim(statement))
  Protected firstWord.s = StringField(upper, 1, " ")
  
  Select firstWord
    ; OOP Blocks
    Case "CLASS"
      ProcedureReturn "EndClass"
    Case "METHOD"
      ProcedureReturn "EndMethod"
      
    ; PB Control Flow Blocks
    Case "IF"
      ProcedureReturn "EndIf"
    Case "SELECT"
      ProcedureReturn "EndSelect"
    Case "WHILE"
      ProcedureReturn "Wend"
    Case "REPEAT"
      ProcedureReturn "Until "
    Case "FOR", "FOREACH"
      ProcedureReturn "Next"
      
    ; PB Structure / Procedure Blocks
    Case "PROCEDURE", "PROCEDUREC", "PROCEDUREDLL", "PROCEDURECDLL"
      ProcedureReturn "EndProcedure"
    Case "STRUCTURE", "STRUCTUREUNION"
      ProcedureReturn "EndStructure"
    Case "INTERFACE"
      ProcedureReturn "EndInterface"
    Case "ENUMERATION", "ENUMERATIONBINARY"
      ProcedureReturn "EndEnumeration"
    Case "MACRO"
      ProcedureReturn "EndMacro"
    Case "MODULE"
      ProcedureReturn "EndModule"
    Case "DECLAREMODULE"
      ProcedureReturn "EndDeclareModule"
    Case "DATASECTION"
      ProcedureReturn "EndDataSection"
      
    Default
      ProcedureReturn ""
  EndSelect
EndProcedure

; Calcule l'indentation d'une ligne
Procedure.s IDE_GetLineIndentation(lineText.s)
  Protected indent.s = ""
  Protected i.i, char.s
  For i = 1 To Len(lineText)
    char = Mid(lineText, i, 1)
    If char = " " Or char = Chr(9)
      indent + char
    Else
      Break
    EndIf
  Next
  ProcedureReturn indent
EndProcedure

; Appel lors de la frappe d'un caractère ou de la touche Entrée
Procedure IDE_HandleAutoClose(gadgetId.i, charAdded.i)
  If Not Settings\AutoCloseBlocks And Not Settings\AutoCloseBrackets
    ProcedureReturn
  EndIf
  
  Protected currentPos = IDE_SendSci(gadgetId, #SCI_GETCURRENTPOS)
  
  ; 1. Gestion des paires de délimiteurs (), [], {}, ""
  If Settings\AutoCloseBrackets
    Select charAdded
      Case Asc("(")
        IDE_SendSci(gadgetId, #SCI_INSERTTEXT, currentPos, UTF8(")"))
      Case Asc("[")
        IDE_SendSci(gadgetId, #SCI_INSERTTEXT, currentPos, UTF8("]"))
      Case Asc("{")
        IDE_SendSci(gadgetId, #SCI_INSERTTEXT, currentPos, UTF8("}"))
      Case Asc(~"\"")
        ; Vérifier si on n'est pas déjà juste avant un guillemet
        IDE_SendSci(gadgetId, #SCI_INSERTTEXT, currentPos, UTF8(~"\""))
    EndSelect
  EndIf
  
  ; 2. Gestion de la fermeture automatique des blocs lors de l'appui sur Entrée (LF ou CR)
  If Settings\AutoCloseBlocks And (charAdded = 10 Or charAdded = 13)
    Protected curLine = IDE_SendSci(gadgetId, #SCI_LINEFROMPOSITION, currentPos)
    If curLine > 0
      ; Analyser la ligne précédente
      Protected prevLineText.s = IDE_GetLineText(gadgetId, curLine - 1)
      Protected cleanPrev.s = Trim(prevLineText)
      
      Protected closingKw.s = IDE_GetClosingKeyword(cleanPrev)
      If closingKw <> ""
        Protected baseIndent.s = IDE_GetLineIndentation(prevLineText)
        Protected extraIndent.s = Space(Settings\TabWidth)
        
        ; Indentation de la ligne actuelle + insertion du mot de fermeture sur la ligne suivante
        Protected insertBlock.s = extraIndent + #CRLF$ + baseIndent + closingKw
        Protected *utf8 = UTF8(insertBlock)
        If *utf8
          IDE_SendSci(gadgetId, #SCI_REPLACESEL, 0, *utf8)
          FreeMemory(*utf8)
          
          ; Repositionner le curseur à l'intérieur du bloc (sur la ligne indentée)
          Protected targetPos = currentPos + Len(extraIndent)
          IDE_SendSci(gadgetId, #SCI_SETCURRENTPOS, targetPos, 0)
          IDE_SendSci(gadgetId, #SCI_SETSEL, targetPos, targetPos)
        EndIf
      EndIf
    EndIf
  EndIf
EndProcedure
