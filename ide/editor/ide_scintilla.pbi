; ============================================================================
; Title:       ide_scintilla.pb
; Description: Scintilla component initialisation, message dispatch, and text helpers
; Author:      MicrodevWeb
; ============================================================================

EnableExplicit

; Scintilla message and token constants
#SCI_SETLEXER = 4001
#SCI_SETREADONLY = 2171
#SCLEX_CONTAINER = 0
#SCLEX_NULL = 1
#SCLEX_PUREBASIC = 67

#SCE_B_DEFAULT = 0
#SCE_B_COMMENT = 1
#SCE_B_NUMBER = 2
#SCE_B_KEYWORD = 3
#SCE_B_STRING = 4
#SCE_B_PREPROCESSOR = 5
#SCE_B_OPERATOR = 6
#SCE_B_IDENTIFIER = 7
#SCE_B_DATE = 8
#SCE_B_STRINGEOL = 9
#SCE_B_KEYWORD2 = 10
#SCE_B_KEYWORD3 = 11
#SCE_B_KEYWORD4 = 12
#SCE_B_CONSTANT = 13
#SCE_B_ASM = 14
#SCE_B_LABEL = 15
#SCE_B_ERROR = 16
#SCE_B_HEXNUMBER = 17
#SCE_B_BINNUMBER = 18

; ----------------------------------------------------------------------------
; Procedure:   IDE_InitScintilla
; Purpose:     Initializes Scintilla runtime support
; Parameters:  None
; Return:      #True if ready
; ----------------------------------------------------------------------------
Procedure.b IDE_InitScintilla()
  ProcedureReturn #True
EndProcedure

; ----------------------------------------------------------------------------
; Procedure:   IDE_SendSci
; Purpose:     Sends a message directly to Scintilla component
; Parameters:  gadgetId.i - Target Scintilla gadget ID
;              msg.i      - Scintilla message constant
;              wParam.i   - First message parameter
;              lParam.i   - Second message parameter
; Return:      Result value from Scintilla
; ----------------------------------------------------------------------------
Procedure.i IDE_SendSci(gadgetId.i, msg.i, wParam.i = 0, lParam.i = 0)
  ProcedureReturn ScintillaSendMessage(gadgetId, msg, wParam, lParam)
EndProcedure

; ----------------------------------------------------------------------------
; Procedure:   IDE_SetEditorText
; Purpose:     Sets the entire document text in UTF-8 encoding
; Parameters:  gadgetId.i - Scintilla gadget ID
;              text.s     - String to put into editor
; Return:      None
; ----------------------------------------------------------------------------
Procedure IDE_SetEditorText(gadgetId.i, text.s)
  Protected *utf8 = UTF8(text)
  If *utf8
    IDE_SendSci(gadgetId, #SCI_SETTEXT, 0, *utf8)
    FreeMemory(*utf8)
  EndIf
EndProcedure

; ----------------------------------------------------------------------------
; Procedure:   IDE_GetEditorText
; Purpose:     Retrieves the entire document text from Scintilla buffer
; Parameters:  gadgetId.i - Scintilla gadget ID
; Return:      Document content as string
; ----------------------------------------------------------------------------
Procedure.s IDE_GetEditorText(gadgetId.i)
  Protected length = IDE_SendSci(gadgetId, #SCI_GETLENGTH)
  If length <= 0
    ProcedureReturn ""
  EndIf
  
  Protected *buffer = AllocateMemory(length + 2)
  If *buffer
    IDE_SendSci(gadgetId, #SCI_GETTEXT, length + 1, *buffer)
    Protected res.s = PeekS(*buffer, length, #PB_UTF8)
    FreeMemory(*buffer)
    ProcedureReturn res
  EndIf
  ProcedureReturn ""
EndProcedure

; ----------------------------------------------------------------------------
; Procedure:   IDE_GetCurrentLine
; Purpose:     Gets the zero-based line index of current caret position
; Parameters:  gadgetId.i - Scintilla gadget ID
; Return:      Line index (0-based)
; ----------------------------------------------------------------------------
Procedure.i IDE_GetCurrentLine(gadgetId.i)
  Protected pos = IDE_SendSci(gadgetId, #SCI_GETCURRENTPOS)
  ProcedureReturn IDE_SendSci(gadgetId, #SCI_LINEFROMPOSITION, pos)
EndProcedure

; ----------------------------------------------------------------------------
; Procedure:   IDE_GetLineText
; Purpose:     Extracts text for a specific line number
; Parameters:  gadgetId.i  - Scintilla gadget ID
;              lineIndex.i - Zero-based line index
; Return:      Line text content
; ----------------------------------------------------------------------------
Procedure.s IDE_GetLineText(gadgetId.i, lineIndex.i)
  Protected startPos = IDE_SendSci(gadgetId, #SCI_POSITIONFROMLINE, lineIndex)
  Protected endPos = IDE_SendSci(gadgetId, #SCI_GETLINEENDPOSITION, lineIndex)
  Protected len = endPos - startPos
  If len <= 0 : ProcedureReturn "" : EndIf
  
  Structure Sci_TextRange
    cpMin.l
    cpMax.l
    *lpstrText
  EndStructure
  
  Protected range.Sci_TextRange
  Protected *buffer = AllocateMemory(len + 4)
  If *buffer
    range\cpMin = startPos
    range\cpMax = endPos
    range\lpstrText = *buffer
    IDE_SendSci(gadgetId, #SCI_GETTEXTRANGE, 0, @range)
    Protected lineStr.s = PeekS(*buffer, len, #PB_UTF8)
    FreeMemory(*buffer)
    ProcedureReturn lineStr
  EndIf
  ProcedureReturn ""
EndProcedure
