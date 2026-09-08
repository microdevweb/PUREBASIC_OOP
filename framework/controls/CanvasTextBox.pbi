; ============================================================================
; PureBasic OOP GUI Framework - CanvasTextBox.pbi
; Modern WPF/WinUI 3 Style Vector Text Input Control
; Features: Vector rounded border, focus ring, placeholder watermark,
;           native OS blinking caret, text selection (mouse & keyboard),
;           copy/paste/cut/undo shortcuts, password mode, high-DPI typography,
;           and MVVM Two-Way text binding.
; Author:      MicrodevWeb
; ============================================================================

XIncludeFile "../CanvasControl.pbi"
XIncludeFile "../Application.pbi"

Namespace UI {

  ; ==========================================================================
  ; Class: CanvasTextBox
  ; High-fidelity vector editable text field
  ; ==========================================================================
  Class CanvasTextBox Extends CanvasControl {
    Protected placeholder.s
    Protected placeholderColor.i
    Protected isPassword.b
    Protected passwordChar.s
    Protected isReadOnly.b
    Protected maxLength.i

    ; Selection & Caret State
    Protected cursorPos.i
    Protected selStart.i
    Protected selEnd.i
    Protected isSelecting.b
    Protected scrollOffset.i
    Protected caretHeight.i

    ; Focus & Selection Colors
    Protected activeBorderColor.i
    Protected selectionColor.i
    Protected selectionTextColor.i

    ; --- Initialize default styles ---
    Protected Method InitTextBoxDefaults() {
      This\placeholder = ""
      This\placeholderColor = RGB(156, 163, 175) ; Tailwind gray-400
      This\isPassword = #False
      This\passwordChar = Chr(9679) ; Bullet character
      If This\passwordChar = "" : This\passwordChar = "*" : EndIf
      This\isReadOnly = #False
      This\maxLength = 0

      This\cursorPos = 0
      This\selStart = 0
      This\selEnd = 0
      This\isSelecting = #False
      This\scrollOffset = 0
      This\caretHeight = 16

      ; Modern WinUI 3 theme
      This\background = RGB(255, 255, 255)
      This\foreground = RGB(17, 24, 39)
      This\hoverBackground = RGB(255, 255, 255)
      This\hoverForeground = RGB(17, 24, 39)
      This\pressedBackground = RGB(255, 255, 255)
      This\pressedForeground = RGB(17, 24, 39)
      This\disabledBackground = RGB(243, 244, 246)
      This\disabledForeground = RGB(156, 163, 175)

      This\borderColor = RGB(209, 213, 219)       ; Gray-300
      This\hoverBorderColor = RGB(156, 163, 175)  ; Gray-400
      This\pressedBorderColor = RGB(59, 130, 246) ; Blue-500
      This\activeBorderColor = RGB(59, 130, 246)  ; Blue-500
      This\borderThickness = 1
      This\cornerRadius = 6

      This\selectionColor = RGB(191, 219, 254)     ; Blue-200
      This\selectionTextColor = RGB(17, 24, 39)   ; Dark text on light blue selection

      This\paddingLeft = 10
      This\paddingTop = 6
      This\paddingRight = 10
      This\paddingBottom = 6

      ; Default typography
      This\SetTypography("Segoe UI", 10, #False)
    }

    ; Constructor 1: Default (200x32)
    Public Method Init() {
      Super\Init(200, 32)
      This\InitTextBoxDefaults()
      This\Redraw()
    }

    ; Constructor 2: Placeholder only
    Public Method Init(placeholder_p.s) {
      Super\Init(200, 32)
      This\InitTextBoxDefaults()
      This\placeholder = placeholder_p
      This\Redraw()
    }

    ; Constructor 3: Placeholder and dimensions
    Public Method Init(placeholder_p.s, w_p.i, h_p.i) {
      Super\Init(w_p, h_p)
      This\InitTextBoxDefaults()
      This\placeholder = placeholder_p
      This\Redraw()
    }

    ; Constructor 4: Position, dimensions and placeholder
    Public Method Init(x_p.i, y_p.i, w_p.i, h_p.i, placeholder_p.s) {
      Super\Init(x_p, y_p, w_p, h_p)
      This\InitTextBoxDefaults()
      This\placeholder = placeholder_p
      This\Redraw()
    }

    ; Constructor 5: Position, dimensions, placeholder and password mode
    Public Method Init(x_p.i, y_p.i, w_p.i, h_p.i, placeholder_p.s, isPassword_p.b) {
      Super\Init(x_p, y_p, w_p, h_p)
      This\InitTextBoxDefaults()
      This\placeholder = placeholder_p
      This\isPassword = isPassword_p
      This\Redraw()
    }

    ; --- Getters / Setters ---

    Public Method.s GetPlaceholder() {
      ProcedureReturn This\placeholder
    }

    Public Method SetPlaceholder(ph_p.s) {
      This\placeholder = ph_p
      This\Redraw()
    }

    Public Method.i GetPlaceholderColor() {
      ProcedureReturn This\placeholderColor
    }

    Public Method SetPlaceholderColor(col_p.i) {
      This\placeholderColor = col_p
      This\Redraw()
    }

    Public Method.b IsPassword() {
      ProcedureReturn This\isPassword
    }

    Public Method SetIsPassword(pw_p.b) {
      This\isPassword = pw_p
      This\Redraw()
    }

    Public Method.b IsReadOnly() {
      ProcedureReturn This\isReadOnly
    }

    Public Method SetReadOnly(ro_p.b) {
      This\isReadOnly = ro_p
      This\Redraw()
    }

    Public Method.i GetMaxLength() {
      ProcedureReturn This\maxLength
    }

    Public Method SetMaxLength(len_p.i) {
      This\maxLength = len_p
    }

    Public Method.i GetActiveBorderColor() {
      ProcedureReturn This\activeBorderColor
    }

    Public Method SetActiveBorderColor(col_p.i) {
      This\activeBorderColor = col_p
      This\Redraw()
    }

    Public Method.i GetSelectionColor() {
      ProcedureReturn This\selectionColor
    }

    Public Method SetSelectionColor(col_p.i) {
      This\selectionColor = col_p
      This\Redraw()
    }

    Public Method.i GetCursorPosition() {
      ProcedureReturn This\cursorPos
    }

    Public Method SetCursorPosition(pos_p.i) {
      Protected tLen.i = Len(This\text)
      If pos_p < 0 : pos_p = 0 : EndIf
      If pos_p > tLen : pos_p = tLen : EndIf
      This\cursorPos = pos_p
      This\selStart = pos_p
      This\selEnd = pos_p
      This\Redraw()
    }

    Public Method SetText(text_p.s) {
      This\text = text_p
      This\cursorPos = Len(text_p)
      This\selStart = This\cursorPos
      This\selEnd = This\cursorPos
      This\scrollOffset = 0
      This\Redraw()
    }

    ; --- Helpers d'Affichage & Selection ---

    Public Method.s GetDisplayText() {
      If (This\isPassword) {
        Protected pLen.i = Len(This\text)
        Protected res.s = ""
        Protected i.i
        For i = 1 To pLen
          res + This\passwordChar
        Next i
        ProcedureReturn res
      }
      ProcedureReturn This\text
    }

    Public Method.b HasSelection() {
      ProcedureReturn Bool(This\selStart <> This\selEnd)
    }

    Public Method GetSelectionBounds(*minOut.INTEGER, *maxOut.INTEGER) {
      If (This\selStart < This\selEnd) {
        *minOut\i = This\selStart
        *maxOut\i = This\selEnd
      } Else {
        *minOut\i = This\selEnd
        *maxOut\i = This\selStart
      }
    }

    Public Method ClearSelection() {
      This\selStart = This\cursorPos
      This\selEnd = This\cursorPos
    }

    Public Method SelectAll() {
      This\selStart = 0
      This\selEnd = Len(This\text)
      This\cursorPos = This\selEnd
    }

    Protected Method DeleteSelection() {
      If (This\HasSelection()) {
        Protected sMin.INTEGER, sMax.INTEGER
        This\GetSelectionBounds(@sMin, @sMax)
        This\text = Left(This\text, sMin\i) + Mid(This\text, sMax\i + 1)
        This\cursorPos = sMin\i
        This\ClearSelection()
        This\OnChange()
        PostEvent(#PB_Event_Gadget, EventWindow(), This\id, #PB_EventType_Change)
      }
    }

    ; --- Actions d'Edition ---

    Public Method InsertText(str_p.s) {
      If (This\isReadOnly) : ProcedureReturn : EndIf
      If (This\HasSelection())
        This\DeleteSelection()
      EndIf

      Protected curLen.i = Len(This\text)
      Protected insLen.i = Len(str_p)
      If (This\maxLength > 0 And (curLen + insLen) > This\maxLength)
        insLen = This\maxLength - curLen
        If insLen <= 0 : ProcedureReturn : EndIf
        str_p = Left(str_p, insLen)
      EndIf

      This\text = Left(This\text, This\cursorPos) + str_p + Mid(This\text, This\cursorPos + 1)
      This\cursorPos + Len(str_p)
      This\ClearSelection()
      This\OnChange()
      PostEvent(#PB_Event_Gadget, EventWindow(), This\id, #PB_EventType_Change)
      This\Redraw()
    }

    Public Method DeleteBackward() {
      If (This\isReadOnly) : ProcedureReturn : EndIf
      If (This\HasSelection()) {
        This\DeleteSelection()
        This\Redraw()
      } ElseIf (This\cursorPos > 0) {
        This\text = Left(This\text, This\cursorPos - 1) + Mid(This\text, This\cursorPos + 1)
        This\cursorPos - 1
        This\ClearSelection()
        This\OnChange()
        PostEvent(#PB_Event_Gadget, EventWindow(), This\id, #PB_EventType_Change)
        This\Redraw()
      }
    }

    Public Method DeleteForward() {
      If (This\isReadOnly) : ProcedureReturn : EndIf
      If (This\HasSelection()) {
        This\DeleteSelection()
        This\Redraw()
      } ElseIf (This\cursorPos < Len(This\text)) {
        This\text = Left(This\text, This\cursorPos) + Mid(This\text, This\cursorPos + 2)
        This\ClearSelection()
        This\OnChange()
        PostEvent(#PB_Event_Gadget, EventWindow(), This\id, #PB_EventType_Change)
        This\Redraw()
      }
    }

    Public Method Copy() {
      If (This\HasSelection()) {
        Protected sMin.INTEGER, sMax.INTEGER
        This\GetSelectionBounds(@sMin, @sMax)
        Protected selTxt.s = Mid(This\text, sMin\i + 1, sMax\i - sMin\i)
        If selTxt <> ""
          SetClipboardText(selTxt)
        EndIf
      }
    }

    Public Method Cut() {
      If (This\isReadOnly) : ProcedureReturn : EndIf
      If (This\HasSelection()) {
        This\Copy()
        This\DeleteSelection()
        This\Redraw()
      }
    }

    Public Method Paste() {
      If (This\isReadOnly) : ProcedureReturn : EndIf
      Protected clip.s = GetClipboardText()
      If clip <> ""
        ; Remove line breaks for single-line field
        clip = RemoveString(clip, #CR$)
        clip = RemoveString(clip, #LF$)
        This\InsertText(clip)
      EndIf
    }

    Public Method OnSubmit() {
    }

    ; --- Calcul de position de caractere selon coordonnee X ---

    Protected Method.i CharPosFromMouseX(targetX_p.i) {
      Protected dText.s = This\GetDisplayText()
      Protected textLen.i = Len(dText)
      If textLen = 0 : ProcedureReturn 0 : EndIf

      Protected relativeX.i = targetX_p - This\paddingLeft + This\scrollOffset
      If relativeX <= 0 : ProcedureReturn 0 : EndIf

      Protected pos.i = 0
      If (StartDrawing(CanvasOutput(This\id))) {
        If (This\fontID) : DrawingFont(This\fontID) : EndIf
        Protected prevW.i = 0
        Protected curW.i = 0
        Protected i.i
        For i = 1 To textLen
          curW = TextWidth(Left(dText, i))
          Protected charW.i = curW - prevW
          If relativeX < (prevW + (charW / 2))
            pos = i - 1
            Break
          ElseIf relativeX <= curW
            pos = i
            Break
          EndIf
          prevW = curW
          pos = i
        Next i
        StopDrawing()
      }
      ProcedureReturn pos
    }

    ; --- Adjust scroll offset to keep cursor visible ---

    Protected Method EnsureCursorVisible(availW_p.i) {
      Protected dText.s = This\GetDisplayText()
      Protected curPixX.i = TextWidth(Left(dText, This\cursorPos))

      If (curPixX - This\scrollOffset > availW_p - 10)
        This\scrollOffset = curPixX - availW_p + 15
      ElseIf (curPixX - This\scrollOffset < 5)
        This\scrollOffset = curPixX - 5
      EndIf
      If (This\scrollOffset < 0)
        This\scrollOffset = 0
      EndIf
    }

    ; --- Mouse, Keyboard & Focus Events ---

    Public Method OnFocus() {
      Super\OnFocus()
      This\Redraw()
    }

    Public Method OnLostFocus() {
      Super\OnLostFocus()
      CompilerIf #PB_Compiler_OS = #PB_OS_Windows
        If (This\id And IsGadget(This\id))
          HideCaret_(GadgetID(This\id))
          DestroyCaret_()
        EndIf
      CompilerEndIf
      This\isSelecting = #False
      This\Redraw()
    }

    Public Method OnMouseDown(mx_p.i, my_p.i, button_p.i) {
      Super\OnMouseDown(mx_p, my_p, button_p)
      If (This\id And IsGadget(This\id))
        SetActiveGadget(This\id)
      EndIf

      This\cursorPos = This\CharPosFromMouseX(mx_p)
      This\selStart = This\cursorPos
      This\selEnd = This\cursorPos
      This\isSelecting = #True
      This\Redraw()
    }

    Public Method OnMouseMove(mx_p.i, my_p.i) {
      Super\OnMouseMove(mx_p, my_p)
      If (This\isSelecting) {
        This\cursorPos = This\CharPosFromMouseX(mx_p)
        This\selEnd = This\cursorPos
        This\Redraw()
      }
    }

    Public Method OnMouseUp(mx_p.i, my_p.i, button_p.i) {
      Super\OnMouseUp(mx_p, my_p, button_p)
      This\isSelecting = #False
    }

    Public Method OnLeftDoubleClick(mx_p.i, my_p.i) {
      This\SelectAll()
      This\Redraw()
    }

    Public Method OnKeyDown(key_p.i) {
      Super\OnKeyDown(key_p)
      Protected isCtrl.b = Bool(GetGadgetAttribute(This\id, #PB_Canvas_Modifiers) & #PB_Canvas_Control)
      Protected isShift.b = Bool(GetGadgetAttribute(This\id, #PB_Canvas_Modifiers) & #PB_Canvas_Shift)

      Select (key_p)
        Case #PB_Key_Back:
          This\DeleteBackward()

        Case #PB_Key_Delete:
          This\DeleteForward()

        Case #PB_Key_Left:
          If isShift:
            If (This\cursorPos > 0)
              This\cursorPos - 1
              This\selEnd = This\cursorPos
            EndIf
          Else:
            If (This\HasSelection())
              Protected sMinL.INTEGER, sMaxL.INTEGER
              This\GetSelectionBounds(@sMinL, @sMaxL)
              This\cursorPos = sMinL\i
              This\ClearSelection()
            ElseIf (This\cursorPos > 0)
              This\cursorPos - 1
              This\ClearSelection()
            EndIf
          EndIf
          This\Redraw()

        Case #PB_Key_Right:
          Protected tLenR.i = Len(This\text)
          If isShift:
            If (This\cursorPos < tLenR)
              This\cursorPos + 1
              This\selEnd = This\cursorPos
            EndIf
          Else:
            If (This\HasSelection())
              Protected sMinR.INTEGER, sMaxR.INTEGER
              This\GetSelectionBounds(@sMinR, @sMaxR)
              This\cursorPos = sMaxR\i
              This\ClearSelection()
            ElseIf (This\cursorPos < tLenR)
              This\cursorPos + 1
              This\ClearSelection()
            EndIf
          EndIf
          This\Redraw()

        Case #PB_Key_Home:
          This\cursorPos = 0
          If isShift : This\selEnd = 0 : Else : This\ClearSelection() : EndIf
          This\Redraw()

        Case #PB_Key_End:
          This\cursorPos = Len(This\text)
          If isShift : This\selEnd = This\cursorPos : Else : This\ClearSelection() : EndIf
          This\Redraw()

        Case #PB_Key_A:
          If isCtrl
            This\SelectAll()
            This\Redraw()
          EndIf

        Case #PB_Key_C:
          If isCtrl
            This\Copy()
          EndIf

        Case #PB_Key_V:
          If isCtrl
            This\Paste()
          EndIf

        Case #PB_Key_X:
          If isCtrl
            This\Cut()
          EndIf

        Case #PB_Key_Return:
          This\OnSubmit()
      EndSelect
    }

    Public Method OnInput(char_p.i) {
      Super\OnInput(char_p)
      Protected isCtrl.b = Bool(GetGadgetAttribute(This\id, #PB_Canvas_Modifiers) & #PB_Canvas_Control)
      If (Not isCtrl And char_p >= 32)
        This\InsertText(Chr(char_p))
      EndIf
    }

    ; --- Rendu Graphique (OnPaint) ---

    Public Method OnPaint(w_p.i, h_p.i) {
      ; 1. Fond et bordure
      This\DrawControlBackground(w_p, h_p)

      ; 2. Anneau de Focus WPF / WinUI
      Protected scaledRad.i = DesktopScaledX(This\cornerRadius)
      If (This\isFocused) {
        If (scaledRad > 0) {
          RoundBox(0, 0, w_p, h_p, scaledRad, scaledRad, This\activeBorderColor)
          If (w_p > 4 And h_p > 4) {
            Protected inR.i = scaledRad - 2
            If inR < 0 : inR = 0 : EndIf
            RoundBox(2, 2, w_p - 4, h_p - 4, inR, inR, This\GetCurrentBackgroundColor())
          }
        } Else {
          Box(0, 0, w_p, h_p, This\activeBorderColor)
          If (w_p > 4 And h_p > 4) {
            Box(2, 2, w_p - 4, h_p - 4, This\GetCurrentBackgroundColor())
          }
        }
      }

      ; 3. Typographie
      If (This\fontID)
        DrawingFont(This\fontID)
      EndIf

      ; 4. Zone interieure de texte
      Protected padL.i = DesktopScaledX(This\paddingLeft)
      Protected padT.i = DesktopScaledY(This\paddingTop)
      Protected padR.i = DesktopScaledX(This\paddingRight)
      Protected padB.i = DesktopScaledY(This\paddingBottom)

      Protected availX.i = padL
      Protected availY.i = padT
      Protected availW.i = w_p - padL - padR
      Protected availH.i = h_p - padT - padB
      If availW < 10 : availW = 10 : EndIf
      If availH < 10 : availH = 10 : EndIf

      This\caretHeight = TextHeight("Ag")
      If This\caretHeight < 14 : This\caretHeight = 14 : EndIf
      If This\caretHeight > availH : This\caretHeight = availH : EndIf

      This\EnsureCursorVisible(availW)

      Protected dText.s = This\GetDisplayText()
      Protected curPixX.i = TextWidth(Left(dText, This\cursorPos))
      Protected caretDrawX.i = availX + curPixX - This\scrollOffset
      Protected caretDrawY.i = availY + (availH - This\caretHeight) / 2

      ; 5. Clip text to prevent overflow
      ClipOutput(availX, availY, availW, availH)

      ; 6. Display placeholder if empty and unfocused
      If (This\text = "" And Not This\isFocused And This\placeholder <> "") {
        DrawingMode(#PB_2DDrawing_Transparent)
        Protected phY.i = availY + (availH - TextHeight(This\placeholder)) / 2
        DrawText(availX, phY, This\placeholder, This\placeholderColor)
      } ElseIf (dText <> "") {
        Protected textY.i = availY + (availH - TextHeight(dText)) / 2
        Protected drawX.i = availX - This\scrollOffset

        If (This\HasSelection()) {
          Protected sMin.INTEGER, sMax.INTEGER
          This\GetSelectionBounds(@sMin, @sMax)
          Protected preText.s = Left(dText, sMin\i)
          Protected selText.s = Mid(dText, sMin\i + 1, sMax\i - sMin\i)
          Protected postText.s = Mid(dText, sMax\i + 1)

          Protected preW.i = TextWidth(preText)
          Protected selW.i = TextWidth(selText)

          ; Texte avant selection
          If preText <> ""
            DrawingMode(#PB_2DDrawing_Transparent)
            DrawText(drawX, textY, preText, This\GetCurrentForegroundColor())
          EndIf

          ; Surlignage de selection
          Protected selX.i = drawX + preW
          Protected selBoxY.i = textY - 1
          Protected selBoxH.i = TextHeight(dText) + 2
          Box(selX, selBoxY, selW, selBoxH, This\selectionColor)

          DrawingMode(#PB_2DDrawing_Transparent)
          DrawText(selX, textY, selText, This\selectionTextColor)

          ; Texte apres selection
          If postText <> ""
            DrawingMode(#PB_2DDrawing_Transparent)
            DrawText(selX + selW, textY, postText, This\GetCurrentForegroundColor())
          EndIf
        } Else {
          DrawingMode(#PB_2DDrawing_Transparent)
          DrawText(drawX, textY, dText, This\GetCurrentForegroundColor())
        }
      }

      UnclipOutput()

      ; 7. Windows system caret management
      CompilerIf #PB_Compiler_OS = #PB_OS_Windows
        If (This\isFocused And Not This\HasSelection() And This\id And IsGadget(This\id))
          CreateCaret_(GadgetID(This\id), 0, 2, This\caretHeight)
          SetCaretPos_(caretDrawX, caretDrawY)
          ShowCaret_(GadgetID(This\id))
        ElseIf (This\id And IsGadget(This\id))
          HideCaret_(GadgetID(This\id))
          DestroyCaret_()
        EndIf
      CompilerEndIf
    }

    ; --- Nettoyage ---

    Public Method Free() {
      CompilerIf #PB_Compiler_OS = #PB_OS_Windows
        If (This\isFocused And This\id And IsGadget(This\id))
          HideCaret_(GadgetID(This\id))
          DestroyCaret_()
        EndIf
      CompilerEndIf
      Super\Free()
    }
  }

}
