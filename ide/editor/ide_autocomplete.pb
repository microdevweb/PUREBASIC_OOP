; ============================================================================
; Title:       ide_autocomplete.pb
; Description: Moteur d'autocomplétion contextuelle (seuil N lettres, mots-clés, symboles)
; Author:      Expert PureBasic OOP
; ============================================================================

EnableExplicit

XIncludeFile "ide_scintilla.pb"
XIncludeFile "../config/ide_settings.pb"
XIncludeFile "../data/ide_keywords.pb"

#SCI_WORDSTARTPOSITION = 2266
#SCI_WORDENDPOSITION = 2267

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

Procedure IDE_TriggerAutocomplete(gadgetId.i, forceManual.b = #False)
  If Not Settings\AutocompleteEnabled And Not forceManual
    ProcedureReturn
  EndIf
  
  Protected wordLen.i = 0
  Protected currentWord.s = IDE_GetCurrentWord(gadgetId, @wordLen)
  
  ; Vérifier le seuil de déclenchement défini par l'utilisateur (défaut : 2 lettres)
  If Not forceManual
    If wordLen < Settings\AutocompleteMinChars
      ; Si la liste était affichée et que la longueur descend sous le seuil, fermer
      If IDE_SendSci(gadgetId, #SCI_AUTOCACTIVE)
        IDE_SendSci(gadgetId, #SCI_AUTOCCANCEL)
      EndIf
      ProcedureReturn
    EndIf
  EndIf
  
  ; Récupérer la liste des mots-clés triés
  Protected fullList.s = IDE_GetFullAutocompleteWordList()
  Protected *utf8 = UTF8(fullList)
  If *utf8
    ; Déclencher la popup Scintilla
    IDE_SendSci(gadgetId, #SCI_AUTOCSHOW, wordLen, *utf8)
    FreeMemory(*utf8)
  EndIf
EndProcedure
