; ============================================================================
; Title:       ide_autocomplete.pb
; Description: Autocomplete trigger engine and word extraction
; Author:      MicrodevWeb
; ============================================================================

EnableExplicit

XIncludeFile "ide_scintilla.pbi"
XIncludeFile "../config/ide_settings.pbi"
XIncludeFile "../data/ide_keywords.pbi"

#SCI_WORDSTARTPOSITION = 2266
#SCI_WORDENDPOSITION = 2267

; ----------------------------------------------------------------------------
; Procedure:   IDE_GetCurrentWord
; Purpose:     Extracts current word fragment at cursor position
; Parameters:  gadgetId.i         - Scintilla gadget ID
;              *wordLen.Integer   - Pointer to integer receiving word length
; Return:      Extracted word string
; ----------------------------------------------------------------------------
Procedure.s IDE_GetCurrentWord(gadgetId.i, *wordLen.Integer)
  Protected currentPos = IDE_SendSci(gadgetId, #SCI_GETCURRENTPOS)
  Protected startPos = IDE_SendSci(gadgetId, #SCI_WORDSTARTPOSITION, currentPos, 1)
  
  If currentPos <= startPos
    If *wordLen : *wordLen\i = 0 : EndIf
    ProcedureReturn ""
  EndIf
  
  Protected len = currentPos - startPos
  If *wordLen : *wordLen\i = len : EndIf
  
  Structure Sci_TextRange_AC
    cpMin.l
    cpMax.l
    *lpstrText
  EndStructure
  
  Protected range.Sci_TextRange_AC
  Protected *buf = AllocateMemory(len + 2)
  If *buf
    range\cpMin = startPos
    range\cpMax = currentPos
    range\lpstrText = *buf
    IDE_SendSci(gadgetId, #SCI_GETTEXTRANGE, 0, @range)
    Protected w.s = PeekS(*buf, len, #PB_UTF8)
    FreeMemory(*buf)
    ProcedureReturn w
  EndIf
  ProcedureReturn ""
EndProcedure

; ----------------------------------------------------------------------------
; Procedure:   IDE_TriggerAutocomplete
; Purpose:     Displays Scintilla autocomplete popup if length matches threshold
; Parameters:  gadgetId.i    - Scintilla gadget ID
;              forceManual.b - Flag to ignore minimum char count (e.g. Ctrl+Space)
; Return:      None
; ----------------------------------------------------------------------------
Procedure IDE_TriggerAutocomplete(gadgetId.i, forceManual.b = #False)
  ; Check if autocomplete is enabled
  If Not Settings\AutocompleteEnabled And Not forceManual
    ProcedureReturn
  EndIf
  
  Protected wordLen.i = 0
  Protected currentWord.s = IDE_GetCurrentWord(gadgetId, @wordLen)
  
  ; Check minimum characters threshold (default: 2 letters)
  If Not forceManual
    If wordLen < Settings\AutocompleteMinChars
      ; Cancel existing autocomplete popup if below threshold
      If IDE_SendSci(gadgetId, #SCI_AUTOCACTIVE)
        IDE_SendSci(gadgetId, #SCI_AUTOCCANCEL)
      EndIf
      ProcedureReturn
    EndIf
  EndIf
  
  ; Fetch sorted keyword list and show popup
  Protected fullList.s = IDE_GetFullAutocompleteWordList()
  Protected *utf8 = UTF8(fullList)
  If *utf8
    IDE_SendSci(gadgetId, #SCI_AUTOCSHOW, wordLen, *utf8)
    FreeMemory(*utf8)
  EndIf
EndProcedure
