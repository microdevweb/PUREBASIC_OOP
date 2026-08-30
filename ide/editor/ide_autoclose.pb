; ============================================================================
; Title:       ide_autoclose.pb
; Description: Automatic closing for code blocks (If/EndIf, Class/EndClass) and bracket pairs
; Author:      MicrodevWeb
; ============================================================================

EnableExplicit

XIncludeFile "ide_scintilla.pb"
XIncludeFile "../config/ide_settings.pb"

; ----------------------------------------------------------------------------
; Procedure:   IDE_GetClosingKeyword
; Purpose:     Determines closing statement for a given block opening line
; Parameters:  statement.s - Statement text from line
; Return:      Closing keyword string or empty string
; ----------------------------------------------------------------------------
Procedure.s IDE_GetClosingKeyword(statement.s)
  Protected upper.s = UCase(Trim(statement))
  Protected firstWord.s = StringField(upper, 1, " ")
  
  Select firstWord
    ; OOP block statements
    Case "CLASS"
      ProcedureReturn "EndClass"
    Case "METHOD"
      ProcedureReturn "EndMethod"
      
    ; PureBasic control flow statements
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
      
    ; Procedures and structure statements
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

; ----------------------------------------------------------------------------
; Procedure:   IDE_GetLineIndentation
; Purpose:     Extracts leading whitespace from line
; Parameters:  lineText.s - Line content string
; Return:      Whitespace indentation prefix
; ----------------------------------------------------------------------------
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

; ----------------------------------------------------------------------------
; Procedure:   IDE_HandleAutoClose
; Purpose:     Inserts closing pairs or closing block keywords on enter/type
; Parameters:  gadgetId.i  - Scintilla gadget ID
;              charAdded.i - ASCII/UTF-8 code of typed character
; Return:      None
; ----------------------------------------------------------------------------
Procedure IDE_HandleAutoClose(gadgetId.i, charAdded.i)
  If Not Settings\AutoCloseBlocks And Not Settings\AutoCloseBrackets
    ProcedureReturn
  EndIf
  
  Protected currentPos = IDE_SendSci(gadgetId, #SCI_GETCURRENTPOS)
  Protected *utf8
  
  ; 1. Auto-close pairs: (), [], {}, ""
  If Settings\AutoCloseBrackets
    Select charAdded
      Case Asc("(")
        *utf8 = UTF8(")")
        If *utf8 : IDE_SendSci(gadgetId, #SCI_INSERTTEXT, currentPos, *utf8) : FreeMemory(*utf8) : EndIf
      Case Asc("[")
        *utf8 = UTF8("]")
        If *utf8 : IDE_SendSci(gadgetId, #SCI_INSERTTEXT, currentPos, *utf8) : FreeMemory(*utf8) : EndIf
      Case Asc("{")
        *utf8 = UTF8("}")
        If *utf8 : IDE_SendSci(gadgetId, #SCI_INSERTTEXT, currentPos, *utf8) : FreeMemory(*utf8) : EndIf
      Case Asc(~"\"")
        *utf8 = UTF8(~"\"")
        If *utf8 : IDE_SendSci(gadgetId, #SCI_INSERTTEXT, currentPos, *utf8) : FreeMemory(*utf8) : EndIf
    EndSelect
  EndIf
  
  ; 2. Auto-close block keywords when Enter key is pressed (LF or CR)
  If Settings\AutoCloseBlocks And (charAdded = 10 Or charAdded = 13)
    Protected curLine = IDE_SendSci(gadgetId, #SCI_LINEFROMPOSITION, currentPos)
    If curLine > 0
      ; Inspect previous line
      Protected prevLineText.s = IDE_GetLineText(gadgetId, curLine - 1)
      Protected cleanPrev.s = Trim(prevLineText)
      
      Protected closingKw.s = IDE_GetClosingKeyword(cleanPrev)
      If closingKw <> ""
        Protected baseIndent.s = IDE_GetLineIndentation(prevLineText)
        Protected extraIndent.s = Space(Settings\TabWidth)
        
        ; Indent current line and insert closing keyword on next line
        Protected insertBlock.s = extraIndent + #CRLF$ + baseIndent + closingKw
        *utf8 = UTF8(insertBlock)
        If *utf8
          IDE_SendSci(gadgetId, #SCI_REPLACESEL, 0, *utf8)
          FreeMemory(*utf8)
          
          ; Position caret inside the block on the indented line
          Protected targetPos = currentPos + Len(extraIndent)
          IDE_SendSci(gadgetId, #SCI_SETCURRENTPOS, targetPos, 0)
          IDE_SendSci(gadgetId, #SCI_SETSEL, targetPos, targetPos)
        EndIf
      EndIf
    EndIf
  EndIf
EndProcedure
