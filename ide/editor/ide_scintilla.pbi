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

#STYLE_DEFAULT = 32
#STYLE_LINENUMBER = 33
#STYLE_BRACELIGHT = 34
#STYLE_BRACEBAD = 35
#STYLE_CONTROLCHAR = 36
#STYLE_INDENTGUIDE = 37
#STYLE_CALLTIP = 38
#STYLE_FOLDDISPLAYTEXT = 39
#STYLE_LASTPREDEFINED = 39
#STYLE_MAX = 255

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

; Scintilla command messages
#SCI_STYLESETFONT = 2056
#SCI_STYLESETSIZE = 2055
#SCI_STYLESETBOLD = 2053
#SCI_STYLESETITALIC = 2054
#SCI_STYLESETFORE = 2051
#SCI_STYLESETBACK = 2052
#SCI_STYLECLEARALL = 2050
#SCI_SETKEYWORDS = 4005
#SCI_SETTEXT = 2181
#SCI_GETTEXT = 2182
#SCI_GETLENGTH = 2006
#SCI_GETCURRENTPOS = 2008
#SCI_SETCURRENTPOS = 2141
#SCI_SETSEL = 2160
#SCI_REPLACESEL = 2170
#SCI_INSERTTEXT = 2003
#SCI_LINEFROMPOSITION = 2166
#SCI_POSITIONFROMLINE = 2167
#SCI_GETLINEENDPOSITION = 2136
#SCI_GETTEXTRANGE = 2162
#SCI_SETMARGINTYPEN = 2240
#SCI_SETMARGINWIDTHN = 2242
#SCI_SETMARGINSENSITIVEN = 2246
#SCI_SETCARETLINEVISIBLE = 2096
#SCI_SETCARETLINEBACK = 2098
#SCI_SETCARETFORE = 2069
#SCI_SETSELFORE = 2067
#SCI_SETSELBACK = 2068
#SCI_SETTABWIDTH = 2036
#SCI_SETINDENT = 2122
#SCI_SETUSETABS = 2124
#SCI_AUTOCSHOW = 2100
#SCI_AUTOCCANCEL = 2101
#SCI_AUTOCACTIVE = 2102
#SCI_AUTOCSETSEPARATOR = 2106
#SCI_AUTOCSETIGNORECASE = 2115
#SCI_AUTOCSETORDER = 2660
#SC_MARGIN_NUMBER = 1

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
