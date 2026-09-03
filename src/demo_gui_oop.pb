; ============================================================================
; Demonstration Complete du Framework GUI PureBasic OOP
; Fichier : src/demo_gui_oop.pb
; ============================================================================

XIncludeFile "ui/UI.pbi"

Using UI
Using UI::Controls

; ----------------------------------------------------------------------------
; 1. Classes Specialisees par Heritage pour les Evenements
; ----------------------------------------------------------------------------

; Bouton avec comportement encapsule
Class GreetButton Extends UI::Button {
  Protected *nameInput.UI::TextBox
  Protected *statusLabel.UI::Label

  Public Method BindControls(*input.UI::TextBox, *lbl.UI::Label) {
    This\*nameInput = *input
    This\*statusLabel = *lbl
  }

  Public Method OnClick() {
    Protected userName.s = "Visiteur"
    If (This\*nameInput) {
      Protected txt.s = This\*nameInput\GetText()
      If (txt <> "") {
        userName = txt
      }
    }
    If (This\*statusLabel) {
      This\*statusLabel\SetText("Bonjour " + userName + " ! Heure : " + FormatDate("%hh:%ii:%ss", Date()))
    }
  }
}

; Custom Toggle Switch avec evenement OnChange
Class ModeSwitch Extends UI::Controls::ToggleSwitch {
  Protected *statusLabel.UI::Label

  Public Method BindLabel(*lbl.UI::Label) {
    This\*statusLabel = *lbl
  }

  Public Method OnChange() {
    If (This\*statusLabel) {
      If (This\IsChecked()) {
        This\*statusLabel\SetText("Statut : Mode TURBO Active [ON]")
      } Else {
        This\*statusLabel\SetText("Statut : Mode Standard [OFF]")
      }
    }
  }
}

; Slider synchronise avec ProgressBar
Class VolumeSlider Extends UI::Slider {
  Protected *progress.UI::ProgressBar
  Protected *valLabel.UI::Label

  Public Method BindProgress(*pb.UI::ProgressBar, *lbl.UI::Label) {
    This\*progress = *pb
    This\*valLabel = *lbl
  }

  Public Method OnCustomEvent(eventType.i) {
    Protected curVal.i = This\GetValue()
    If (This\*progress) {
      This\*progress\SetValue(curVal)
    }
    If (This\*valLabel) {
      This\*valLabel\SetText("Niveau : " + Str(curVal) + "%")
    }
  }
}

; ----------------------------------------------------------------------------
; 2. Fenetre Principale Encapsulee
; ----------------------------------------------------------------------------

Class MainWindow Extends UI::Window {
  Protected *lblTitle.UI::Label
  Protected *lblPrompt.UI::Label
  Protected *txtInput.UI::TextBox
  Protected *btnGreet.GreetButton
  Protected *lblStatus.UI::Label
  Protected *lblSwitch.UI::Label
  Protected *switchTurbo.ModeSwitch
  Protected *lblSlider.UI::Label
  Protected *sliderVol.VolumeSlider
  Protected *progBar.UI::ProgressBar
  Protected *comboTheme.UI::ComboBox

  Public Method Init() {
    Super::Init("PureBasic OOP - Framework GUI Moderne", #PB_Ignore, #PB_Ignore, 480, 420, #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
    UI::RegisterWindow(This\id, This)

    ; Titre
    This\*lblTitle = New UI::Label(20, 15, 440, 25, "=== Demonstration GUI PureBasic OOP ===")
    
    ; Section Saisie & Bouton
    This\*lblPrompt = New UI::Label(20, 55, 100, 20, "Votre Nom :")
    This\*txtInput = New UI::TextBox(120, 52, 200, 25, "Developpeur PureBasic")
    
    This\*btnGreet = New GreetButton(330, 50, 130, 28, "Saluer !")

    ; Section Toggle Switch (Custom Gadget sur Canvas)
    This\*lblSwitch = New UI::Label(20, 100, 200, 20, "Custom Toggle Switch :")
    This\*switchTurbo = New ModeSwitch(230, 97, 50, 26, #False)

    ; Section Slider & ProgressBar
    This\*lblSlider = New UI::Label(20, 145, 150, 20, "Niveau : 50%")
    This\*sliderVol = New VolumeSlider(20, 170, 440, 25, 0, 100)
    This\*sliderVol\SetValue(50)

    This\*progBar = New UI::ProgressBar(20, 210, 440, 20, 0, 100)
    This\*progBar\SetValue(50)

    ; Section Theme ComboBox
    Protected *lblCombo.UI::Label = New UI::Label(20, 250, 100, 20, "Theme UI :")
    This\*comboTheme = New UI::ComboBox(120, 247, 180, 26)
    This\*comboTheme\AddItem("Theme Sombre Moderne")
    This\*comboTheme\AddItem("Theme Clair Classique")
    This\*comboTheme\AddItem("Theme PureBasic Silk")
    This\*comboTheme\SetSelectedIndex(0)

    ; Case a cocher
    Protected *chkOption.UI::CheckBox = New UI::CheckBox(20, 295, 250, 25, "Activer les notifications sonores")
    *chkOption\SetChecked(#True)

    ; Statut en bas
    This\*lblStatus = New UI::Label(20, 340, 440, 30, "Pret. Cliquez sur le bouton ou interagissez avec les widgets.")

    ; Liaison des controles
    This\*btnGreet\BindControls(This\*txtInput, This\*lblStatus)
    This\*switchTurbo\BindLabel(This\*lblStatus)
    This\*sliderVol\BindProgress(This\*progBar, This\*lblSlider)
  }

  Public Method.b OnClose() {
    ProcedureReturn #True ; Autorise la fermeture de la fenetre
  }
}

; ----------------------------------------------------------------------------
; 3. Point d'Entree du Programme
; ----------------------------------------------------------------------------

Define *app.UI::Application = New UI::Application()
Define *mainWin.MainWindow = New MainWindow()

*app\Run(*mainWin)