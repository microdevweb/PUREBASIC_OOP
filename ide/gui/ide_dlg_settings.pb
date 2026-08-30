; ============================================================================
; Title:       ide_dlg_settings.pb
; Description: Fenêtre de paramétrage (Coloration, Autocomplétion, Auto-close, Thèmes)
; Author:      Expert PureBasic OOP
; ============================================================================

EnableExplicit

XIncludeFile "../config/ide_settings.pb"

Enumeration SettingsWidgets
  #Dlg_Settings_Window
  #Dlg_Settings_Panel
  
  ; Onglet 1 : Édition & Saisie
  #Dlg_Chk_AC_Enable
  #Dlg_Spin_AC_MinChars
  #Dlg_Txt_AC_MinChars
  #Dlg_Chk_AutoCloseBlocks
  #Dlg_Chk_AutoCloseBrackets
  #Dlg_Chk_ShowLineNumbers
  #Dlg_Chk_HighlightLine
  #Dlg_Spin_TabWidth
  #Dlg_Txt_TabWidth
  
  ; Onglet 2 : Thème & Couleurs
  #Dlg_Cmb_ThemePreset
  #Dlg_Btn_Color_Bg
  #Dlg_Btn_Color_Fg
  #Dlg_Btn_Color_PBKw
  #Dlg_Btn_Color_OOPKw
  #Dlg_Btn_Color_String
  #Dlg_Btn_Color_Comment
  #Dlg_Btn_Color_Number
  #Dlg_Btn_Color_Function
  
  ; Onglet 3 : Compilateur
  #Dlg_Txt_CompilerPath
  #Dlg_Str_CompilerPath
  #Dlg_Btn_BrowseCompiler
  
  ; Boutons de dialogue
  #Dlg_Btn_Save
  #Dlg_Btn_Cancel
EndEnumeration

; Variable temporaire pour stocker les couleurs durant l'édition
Global TempTheme.IDE_ThemeColors

Procedure UpdateColorButton(btnGadget.i, color.i, label.s)
  SetGadgetText(btnGadget, label + " ( #" + Hex(color, #PB_Long) + " )")
EndProcedure

Procedure IDE_OpenSettingsDialog(parentWindow.i)
  If IsWindow(#Dlg_Settings_Window)
    SetActiveWindow(#Dlg_Settings_Window)
    ProcedureReturn
  EndIf
  
  TempTheme = Settings\Colors
  
  Protected winW = 540, winH = 460
  OpenWindow(#Dlg_Settings_Window, 0, 0, winW, winH, "Paramètres de l'IDE PureBasic OOP", #PB_Window_SystemMenu | #PB_Window_WindowCentered, WindowID(parentWindow))
  
  PanelGadget(#Dlg_Settings_Panel, 10, 10, winW - 20, winH - 60)
  
  ; --------------------------------------------------------------------------
  ; Onglet 1 : Éditeur & Saisie
  ; --------------------------------------------------------------------------
  AddGadgetItem(#Dlg_Settings_Panel, -1, "Éditeur & Saisie")
  
  FrameGadget(#PB_Any, 15, 15, 480, 110, "Autocomplétion")
  CheckBoxGadget(#Dlg_Chk_AC_Enable, 30, 40, 440, 24, "Activer l'autocomplétion automatique")
  SetGadgetState(#Dlg_Chk_AC_Enable, Settings\AutocompleteEnabled)
  
  TextGadget(#Dlg_Txt_AC_MinChars, 30, 75, 280, 24, "Nombre de lettres avant autocomplétion :")
  SpinGadget(#Dlg_Spin_AC_MinChars, 320, 70, 70, 26, 1, 10, #PB_Spin_Numeric)
  SetGadgetState(#Dlg_Spin_AC_MinChars, Settings\AutocompleteMinChars)
  SetGadgetText(#Dlg_Spin_AC_MinChars, Str(Settings\AutocompleteMinChars))
  
  FrameGadget(#PB_Any, 15, 140, 480, 130, "Fermeture Automatique des Balises")
  CheckBoxGadget(#Dlg_Chk_AutoCloseBlocks, 30, 165, 440, 24, "Fermeture automatique des blocs (If/EndIf, Class/EndClass, etc.)")
  SetGadgetState(#Dlg_Chk_AutoCloseBlocks, Settings\AutoCloseBlocks)
  
  CheckBoxGadget(#Dlg_Chk_AutoCloseBrackets, 30, 195, 440, 24, "Fermeture automatique des paires : ( ), [ ], { }, " + Chr(34) + " " + Chr(34))
  SetGadgetState(#Dlg_Chk_AutoCloseBrackets, Settings\AutoCloseBrackets)
  
  CheckBoxGadget(#Dlg_Chk_ShowLineNumbers, 30, 225, 200, 24, "Afficher les numéros de ligne")
  SetGadgetState(#Dlg_Chk_ShowLineNumbers, Settings\ShowLineNumbers)
  
  CheckBoxGadget(#Dlg_Chk_HighlightLine, 250, 225, 200, 24, "Surligner la ligne active")
  SetGadgetState(#Dlg_Chk_HighlightLine, Settings\HighlightCurrentLine)
  
  FrameGadget(#PB_Any, 15, 280, 480, 70, "Indentation")
  TextGadget(#Dlg_Txt_TabWidth, 30, 305, 280, 24, "Largeur de tabulation (espaces) :")
  SpinGadget(#Dlg_Spin_TabWidth, 320, 300, 70, 26, 2, 8, #PB_Spin_Numeric)
  SetGadgetState(#Dlg_Spin_TabWidth, Settings\TabWidth)
  SetGadgetText(#Dlg_Spin_TabWidth, Str(Settings\TabWidth))
  
  ; --------------------------------------------------------------------------
  ; Onglet 2 : Thème & Couleurs Syntaxiques
  ; --------------------------------------------------------------------------
  AddGadgetItem(#Dlg_Settings_Panel, -1, "Coloration Syntaxique")
  
  TextGadget(#PB_Any, 20, 20, 120, 24, "Thème prédéfini :")
  ComboBoxGadget(#Dlg_Cmb_ThemePreset, 150, 16, 200, 26)
  AddGadgetItem(#Dlg_Cmb_ThemePreset, 0, "Dark Modern (VS Code Style)")
  AddGadgetItem(#Dlg_Cmb_ThemePreset, 1, "Classic PureBasic (Fond Blanc)")
  If Settings\ThemeName = "Classic PureBasic"
    SetGadgetState(#Dlg_Cmb_ThemePreset, 1)
  Else
    SetGadgetState(#Dlg_Cmb_ThemePreset, 0)
  EndIf
  
  FrameGadget(#PB_Any, 15, 60, 480, 280, "Couleurs Personnalisables")
  
  ButtonGadget(#Dlg_Btn_Color_Bg, 30, 85, 210, 30, "")
  UpdateColorButton(#Dlg_Btn_Color_Bg, TempTheme\BgColor, "Fond de l'éditeur")
  
  ButtonGadget(#Dlg_Btn_Color_Fg, 260, 85, 210, 30, "")
  UpdateColorButton(#Dlg_Btn_Color_Fg, TempTheme\FgColor, "Texte Standard")
  
  ButtonGadget(#Dlg_Btn_Color_PBKw, 30, 125, 210, 30, "")
  UpdateColorButton(#Dlg_Btn_Color_PBKw, TempTheme\KeywordPBColor, "Mots-Clés PB (If, For...)")
  
  ButtonGadget(#Dlg_Btn_Color_OOPKw, 260, 125, 210, 30, "")
  UpdateColorButton(#Dlg_Btn_Color_OOPKw, TempTheme\KeywordOOPColor, "Mots-Clés OOP (Class...)")
  
  ButtonGadget(#Dlg_Btn_Color_String, 30, 165, 210, 30, "")
  UpdateColorButton(#Dlg_Btn_Color_String, TempTheme\StringColor, "Chaînes de texte")
  
  ButtonGadget(#Dlg_Btn_Color_Comment, 260, 165, 210, 30, "")
  UpdateColorButton(#Dlg_Btn_Color_Comment, TempTheme\CommentColor, "Commentaires (;)")
  
  ButtonGadget(#Dlg_Btn_Color_Number, 30, 205, 210, 30, "")
  UpdateColorButton(#Dlg_Btn_Color_Number, TempTheme\NumberColor, "Nombres")
  
  ButtonGadget(#Dlg_Btn_Color_Function, 260, 205, 210, 30, "")
  UpdateColorButton(#Dlg_Btn_Color_Function, TempTheme\FunctionColor, "Fonctions")
  
  ; --------------------------------------------------------------------------
  ; Onglet 3 : Compilateur
  ; --------------------------------------------------------------------------
  AddGadgetItem(#Dlg_Settings_Panel, -1, "Compilateur PureBasic")
  
  FrameGadget(#PB_Any, 15, 20, 480, 120, "Chemin vers le binaire pbcompiler.exe")
  StringGadget(#Dlg_Str_CompilerPath, 30, 55, 380, 26, Settings\CompilerPath)
  ButtonGadget(#Dlg_Btn_BrowseCompiler, 420, 55, 60, 26, "...")
  TextGadget(#PB_Any, 30, 90, 440, 35, "Requis pour compiler et exécuter les projets (touche F5).")
  
  CloseGadgetList()
  
  ; Boutons du bas
  ButtonGadget(#Dlg_Btn_Save, winW - 220, winH - 40, 100, 30, "Enregistrer")
  ButtonGadget(#Dlg_Btn_Cancel, winW - 110, winH - 40, 100, 30, "Annuler")
EndProcedure

Procedure IDE_HandleSettingsEvents(event.i, eventGadget.i)
  Select event
    Case #PB_Event_Gadget
      Select eventGadget
        ; 1. Changement de Preset de Thème
        Case #Dlg_Cmb_ThemePreset
          If GetGadgetState(#Dlg_Cmb_ThemePreset) = 1
            IDE_Theme_SetClassicPB(@TempTheme)
          Else
            IDE_Theme_SetDarkModern(@TempTheme)
          EndIf
          UpdateColorButton(#Dlg_Btn_Color_Bg, TempTheme\BgColor, "Fond de l'éditeur")
          UpdateColorButton(#Dlg_Btn_Color_Fg, TempTheme\FgColor, "Texte Standard")
          UpdateColorButton(#Dlg_Btn_Color_PBKw, TempTheme\KeywordPBColor, "Mots-Clés PB (If, For...)")
          UpdateColorButton(#Dlg_Btn_Color_OOPKw, TempTheme\KeywordOOPColor, "Mots-Clés OOP (Class...)")
          UpdateColorButton(#Dlg_Btn_Color_String, TempTheme\StringColor, "Chaînes de texte")
          UpdateColorButton(#Dlg_Btn_Color_Comment, TempTheme\CommentColor, "Commentaires (;)")
          UpdateColorButton(#Dlg_Btn_Color_Number, TempTheme\NumberColor, "Nombres")
          UpdateColorButton(#Dlg_Btn_Color_Function, TempTheme\FunctionColor, "Fonctions")
          
        ; 2. Sélecteurs de couleurs individuels
        Case #Dlg_Btn_Color_Bg
          Protected col = ColorRequester(TempTheme\BgColor)
          If col <> -1 : TempTheme\BgColor = col : UpdateColorButton(#Dlg_Btn_Color_Bg, col, "Fond de l'éditeur") : EndIf
        Case #Dlg_Btn_Color_Fg
          col = ColorRequester(TempTheme\FgColor)
          If col <> -1 : TempTheme\FgColor = col : UpdateColorButton(#Dlg_Btn_Color_Fg, col, "Texte Standard") : EndIf
        Case #Dlg_Btn_Color_PBKw
          col = ColorRequester(TempTheme\KeywordPBColor)
          If col <> -1 : TempTheme\KeywordPBColor = col : UpdateColorButton(#Dlg_Btn_Color_PBKw, col, "Mots-Clés PB (If, For...)") : EndIf
        Case #Dlg_Btn_Color_OOPKw
          col = ColorRequester(TempTheme\KeywordOOPColor)
          If col <> -1 : TempTheme\KeywordOOPColor = col : UpdateColorButton(#Dlg_Btn_Color_OOPKw, col, "Mots-Clés OOP (Class...)") : EndIf
        Case #Dlg_Btn_Color_String
          col = ColorRequester(TempTheme\StringColor)
          If col <> -1 : TempTheme\StringColor = col : UpdateColorButton(#Dlg_Btn_Color_String, col, "Chaînes de texte") : EndIf
        Case #Dlg_Btn_Color_Comment
          col = ColorRequester(TempTheme\CommentColor)
          If col <> -1 : TempTheme\CommentColor = col : UpdateColorButton(#Dlg_Btn_Color_Comment, col, "Commentaires (;)") : EndIf
        Case #Dlg_Btn_Color_Number
          col = ColorRequester(TempTheme\NumberColor)
          If col <> -1 : TempTheme\NumberColor = col : UpdateColorButton(#Dlg_Btn_Color_Number, col, "Nombres") : EndIf
        Case #Dlg_Btn_Color_Function
          col = ColorRequester(TempTheme\FunctionColor)
          If col <> -1 : TempTheme\FunctionColor = col : UpdateColorButton(#Dlg_Btn_Color_Function, col, "Fonctions") : EndIf
          
        ; 3. Parcourir compilateur
        Case #Dlg_Btn_BrowseCompiler
          Protected file.s = OpenFileRequester("Sélectionner pbcompiler.exe", Settings\CompilerPath, "Exécutables (*.exe)|*.exe|Tous les fichiers (*.*)|*.*", 0)
          If file <> ""
            SetGadgetText(#Dlg_Str_CompilerPath, file)
          EndIf
          
        ; 4. Bouton Enregistrer
        Case #Dlg_Btn_Save
          Settings\AutocompleteEnabled  = GetGadgetState(#Dlg_Chk_AC_Enable)
          Settings\AutocompleteMinChars = GetGadgetState(#Dlg_Spin_AC_MinChars)
          If Settings\AutocompleteMinChars < 1 : Settings\AutocompleteMinChars = 1 : EndIf
          
          Settings\AutoCloseBlocks      = GetGadgetState(#Dlg_Chk_AutoCloseBlocks)
          Settings\AutoCloseBrackets    = GetGadgetState(#Dlg_Chk_AutoCloseBrackets)
          Settings\ShowLineNumbers      = GetGadgetState(#Dlg_Chk_ShowLineNumbers)
          Settings\HighlightCurrentLine = GetGadgetState(#Dlg_Chk_HighlightLine)
          Settings\TabWidth             = GetGadgetState(#Dlg_Spin_TabWidth)
          Settings\CompilerPath         = GetGadgetText(#Dlg_Str_CompilerPath)
          
          If GetGadgetState(#Dlg_Cmb_ThemePreset) = 1
            Settings\ThemeName = "Classic PureBasic"
          Else
            Settings\ThemeName = "Dark Modern"
          EndIf
          Settings\Colors = TempTheme
          CurrentTheme = TempTheme
          
          IDE_Settings_Save()
          CloseWindow(#Dlg_Settings_Window)
          ProcedureReturn #True ; Signale une mise à jour des paramètres
          
        ; 5. Bouton Annuler
        Case #Dlg_Btn_Cancel
          CloseWindow(#Dlg_Settings_Window)
      EndSelect
      
    Case #PB_Event_CloseWindow
      If EventWindow() = #Dlg_Settings_Window
        CloseWindow(#Dlg_Settings_Window)
      EndIf
  EndSelect
  
  ProcedureReturn #False
EndProcedure
