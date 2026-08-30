; ============================================================================
; Title:       ide_scintilla.pb
; Description: Initialisation, configuration et wrappers Scintilla
; Author:      Expert PureBasic OOP
; ============================================================================

EnableExplicit

; Constantes Scintilla non prédéfinies
#SCI_SETLEXER = 4001
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

; Initialisation Scintilla
Procedure.b IDE_InitScintilla()
  ProcedureReturn #True
EndProcedure

; Wrapper d'envoi de messages Scintilla
Procedure.i IDE_SendSci(gadgetId.i, msg.i, wParam.i = 0, lParam.i = 0)
  ProcedureReturn ScintillaSendMessage(gadgetId, msg, wParam, lParam)
EndProcedure

; Définition du texte de l'éditeur
Procedure IDE_SetEditorText(gadgetId.i, text.s)
  Protected *utf8 = UTF8(text)
  If *utf8
    IDE_SendSci(gadgetId, #SCI_SETTEXT, 0, *utf8)
    FreeMemory(*utf8)
  EndIf
EndProcedure

; Récupération du texte complet
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

; Récupération du numéro de ligne courante (0-indexé)
Procedure.i IDE_GetCurrentLine(gadgetId.i)
  Protected pos = IDE_SendSci(gadgetId, #SCI_GETCURRENTPOS)
  ProcedureReturn IDE_SendSci(gadgetId, #SCI_LINEFROMPOSITION, pos)
EndProcedure

; Récupération du texte d'une ligne spécifique
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
