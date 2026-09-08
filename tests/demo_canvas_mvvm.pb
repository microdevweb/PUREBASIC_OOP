; ============================================================================
; Demo: CanvasControl & Modern MVVM DataBinding (Hover, Press, Command, Text)
; Author: MicrodevWeb & Google DeepMind Antigravity
; Demonstrating:
;   - UI::CanvasButton with Vector Rounded rendering and WPF Visual States
;   - UI::CanvasText with High-DPI typography & alignments
;   - UI::CanvasTextBox with caret, selection, focus ring & Two-Way Text binding
;   - MVVM Two-Way Binding on IsMouseOver (Hover detection in ViewModel)
;   - MVVM Two-Way Binding on Text (Live text sync with ViewModel)
;   - MVVM Command binding on Button click (OnCommand zero-boilerplate)
; ============================================================================

XIncludeFile "../framework/UI.pbi"

Declare Demo_OnVMPropChanged(*vm, *pKeyPtr)

; ----------------------------------------------------------------------------
; ViewModel: MainViewModel
; ----------------------------------------------------------------------------
Namespace Demo {

  Class MainViewModel Extends MVVM::ViewModelBase {
    Protected clickCount.i

    Public Method Init() {
      Super\Init()
      This\clickCount = 0

      This\SetString("StatusText", "Survolez ou cliquez sur les boutons, ou tapez dans le champ de texte")
      This\SetString("ClickMessage", "Clics : 0")
      This\SetBool("IsHovered", #False)
      This\SetString("UserName", "microdev")
      This\SetString("UserGreeting", "Bonjour microdev ! (Saisie en direct MVVM)")

      ; Enregistrement d'un observer pour surveiller les proprietes en live
      This\RegisterObserver(This, @Demo_OnVMPropChanged())
    }

    Public Method OnIncrement() {
      This\clickCount + 1
      This\SetString("ClickMessage", "Clics : " + Str(This\clickCount))
      This\SetString("StatusText", "Commande 'IncrementClick' recue ! (Total: " + Str(This\clickCount) + ")")
    }

    Public Method OnReset() {
      This\clickCount = 0
      This\SetString("ClickMessage", "Clics : 0")
      This\SetString("StatusText", "Compteur reinitialise a zero !")
    }

    ; Gestionnaire de commandes centralise MVVM
    Public Method.b OnCommand(name_p.s, *param = 0) {
      Select (LCase(name_p))
        Case "incrementclick":
          This\OnIncrement()
          ProcedureReturn #True

        Case "resetclick":
          This\OnReset()
          ProcedureReturn #True
      EndSelect
      ProcedureReturn #False
    }
  }

}

Procedure Demo_OnVMPropChanged(*vm.Demo::MainViewModel, *pKeyPtr)
  If Not *pKeyPtr : ProcedureReturn : EndIf
  Protected pKey.s = PeekS(*pKeyPtr)
  If pKey = "ishovered"
    Protected isHov.b = *vm\GetBool("ishovered")
    If isHov
      *vm\SetString("StatusText", "[MVVM Two-Way] La souris SURVOLE le bouton Primary !")
    Else
      *vm\SetString("StatusText", "[MVVM Two-Way] La souris a QUITTE le bouton.")
    EndIf
  ElseIf pKey = "username"
    Protected uName.s = *vm\GetString("username")
    *vm\SetString("UserGreeting", "Bonjour " + uName + " ! (Saisie en direct MVVM)")
  EndIf
EndProcedure


; ----------------------------------------------------------------------------
; Application GUI
; ----------------------------------------------------------------------------
Procedure RunApp()
  Protected *app.UI::Application = New UI::Application()
  Protected *win.UI::Window = New UI::Window("WPF / WinUI CanvasControl & MVVM Architecture", 100, 100, 740, 580, #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
  *win\SetBackgroundColor(RGB(248, 249, 250))

  ; ViewModel
  Protected *vm.Demo::MainViewModel = New Demo::MainViewModel()
  *win\SetDataContext(*vm)

  ; Root Container : StackPanel vertical
  Protected *rootStack.UI::Layouts::StackPanel = New UI::Layouts::StackPanel(#UI_Orientation_Vertical)
  *rootStack\SetMargin(20, 20, 20, 20)

  ; 1. Header Title
  Protected *titleText.UI::CanvasText = New UI::CanvasText("WPF-Style CanvasControl & MVVM Engine", 700, 36)
  *titleText\SetForeground(RGB(17, 24, 39))
  *titleText\SetAlignment(#UI_TextAlign_Left, #UI_TextAlign_Middle)
  *rootStack\AddChild(*titleText)

  ; 2. Subtitle
  Protected *subText.UI::CanvasText = New UI::CanvasText("Composants vectoriels haute-performance, machine d'etats visuels et Two-Way Binding MVVM.", 700, 24)
  *subText\SetForeground(RGB(107, 114, 128))
  *subText\SetAlignment(#UI_TextAlign_Left, #UI_TextAlign_Middle)
  *rootStack\AddChild(*subText)

  ; 3. Separator spacing
  Protected *spacer1.UI::CanvasText = New UI::CanvasText("", 700, 10)
  *rootStack\AddChild(*spacer1)

  ; 4. Live Status Banner (CanvasText avec bordure et fond dynamique)
  Protected *bannerText.UI::CanvasText = New UI::CanvasText("", 700, 42)
  *bannerText\SetBackground(RGB(239, 246, 255))
  *bannerText\SetForeground(RGB(29, 78, 216))
  *bannerText\SetBorder(RGB(191, 219, 254), 1, 6)
  *bannerText\SetPadding(12, 0, 12, 0)
  *bannerText\SetAlignment(#UI_TextAlign_Left, #UI_TextAlign_Middle)
  *bannerText\SetTransparent(#False)
  *rootStack\AddChild(*bannerText)

  ; MVVM Binding One-Way du StatusText sur la banniere
  UI_MVVM_RegisterBinding(*bannerText, "Text", *vm, "StatusText", #UI_BindingMode_OneWay)

  ; 5. Separator spacing
  Protected *spacer2.UI::CanvasText = New UI::CanvasText("", 700, 14)
  *rootStack\AddChild(*spacer2)

  ; 6. Section Saisie de Texte Vectorielle (CanvasTextBox avec Two-Way Binding)
  Protected *tbSectionTitle.UI::CanvasText = New UI::CanvasText("Saisie Vectorielle & MVVM Two-Way Binding :", 700, 24)
  *tbSectionTitle\SetForeground(RGB(55, 65, 81))
  *tbSectionTitle\SetAlignment(#UI_TextAlign_Left, #UI_TextAlign_Middle)
  *rootStack\AddChild(*tbSectionTitle)

  Protected *tbRow.UI::Layouts::StackPanel = New UI::Layouts::StackPanel(#UI_Orientation_Horizontal)
  *tbRow\SetMargin(0, 0, 0, 12)

  Protected *txtInput.UI::CanvasTextBox = New UI::CanvasTextBox("Entrez un nom...", 320, 36)
  *txtInput\SetCornerRadius(6)
  *txtInput\SetActiveBorderColor(RGB(37, 99, 235))
  *tbRow\AddChild(*txtInput)

  ; Two-Way Binding sur la saisie de texte !
  UI_MVVM_RegisterBinding(*txtInput, "Text", *vm, "UserName", #UI_BindingMode_TwoWay)

  ; Apercu live lie a UserGreeting
  Protected *greetingText.UI::CanvasText = New UI::CanvasText("", 360, 36)
  *greetingText\SetForeground(RGB(4, 120, 87))
  *greetingText\SetBackground(RGB(236, 253, 245))
  *greetingText\SetBorder(RGB(167, 243, 208), 1, 6)
  *greetingText\SetPadding(10, 0, 10, 0)
  *greetingText\SetMargin(16, 0, 0, 0)
  *greetingText\SetTransparent(#False)
  *greetingText\SetAlignment(#UI_TextAlign_Left, #UI_TextAlign_Middle)
  *tbRow\AddChild(*greetingText)

  ; One-Way Binding sur l'apercu
  UI_MVVM_RegisterBinding(*greetingText, "Text", *vm, "UserGreeting", #UI_BindingMode_OneWay)

  *rootStack\AddChild(*tbRow)

  ; 7. Separator spacing
  Protected *spacer3.UI::CanvasText = New UI::CanvasText("", 700, 14)
  *rootStack\AddChild(*spacer3)

  ; 8. Action Buttons Container
  Protected *buttonBar.UI::Layouts::StackPanel = New UI::Layouts::StackPanel(#UI_Orientation_Horizontal)
  *buttonBar\SetMargin(0, 0, 0, 16)

  ; Bouton 1 : Primary avec Style WPF, Commande MVVM et Two-Way Hover Binding
  Protected *btnPrimary.UI::CanvasButton = New UI::CanvasButton("Clic +1 (Primary)", 180, 38)
  *btnPrimary\SetPrimaryStyle()
  *btnPrimary\SetCornerRadius(8)
  *buttonBar\AddChild(*btnPrimary)

  ; Commande MVVM 'IncrementClick'
  UI_MVVM_RegisterCommandBinding(*btnPrimary, *vm, "IncrementClick")
  ; Two-Way Binding du survol souris sur IsHovered
  UI_MVVM_RegisterBinding(*btnPrimary, "IsMouseOver", *vm, "IsHovered", #UI_BindingMode_TwoWay)

  ; Bouton 2 : Outline avec Commande 'ResetClick'
  Protected *btnReset.UI::CanvasButton = New UI::CanvasButton("Reset Compteur", 150, 38)
  *btnReset\SetOutlineStyle(RGB(220, 38, 38))
  *btnReset\SetCornerRadius(8)
  *btnReset\SetMargin(12, 0, 0, 0)
  *buttonBar\AddChild(*btnReset)
  UI_MVVM_RegisterCommandBinding(*btnReset, *vm, "ResetClick")

  ; Bouton 3 : Style Pilule
  Protected *btnPill.UI::CanvasButton = New UI::CanvasButton("Style Pilule", 120, 38)
  *btnPill\SetDefaultStyle()
  *btnPill\SetCornerRadius(19)
  *btnPill\SetMargin(12, 0, 0, 0)
  *buttonBar\AddChild(*btnPill)

  *rootStack\AddChild(*buttonBar)

  ; 9. Counter Display (CanvasText grand format centre)
  Protected *counterDisplay.UI::CanvasText = New UI::CanvasText("Clics : 0", 700, 50)
  *counterDisplay\SetForeground(RGB(31, 41, 55))
  *counterDisplay\SetAlignment(#UI_TextAlign_Center, #UI_TextAlign_Middle)
  *counterDisplay\SetBackground(RGB(243, 244, 246))
  *counterDisplay\SetBorder(RGB(229, 231, 235), 1, 8)
  *counterDisplay\SetTransparent(#False)
  *rootStack\AddChild(*counterDisplay)

  ; MVVM Binding du compteur
  UI_MVVM_RegisterBinding(*counterDisplay, "Text", *vm, "ClickMessage", #UI_BindingMode_OneWay)

  ; Attachement du StackPanel a la fenetre
  *win\SetContent(*rootStack)

  ; Run Application Loop
  *app\SetMainWindow(*win)
  *app\Run()

  ; Nettoyage
  *vm\Free()
  *win\Free()
  *app\Free()
EndProcedure

RunApp()
