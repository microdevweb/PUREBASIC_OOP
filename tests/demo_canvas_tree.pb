; ============================================================================
; PureBasic OOP GUI Framework - demo_canvas_tree.pb
; Interactive Demonstration of the new UI::CanvasTree Control
; High-DPI Virtual TreeView with Chevrons, Checkboxes, Action Buttons & Themes
; Author: MicrodevWeb
; ============================================================================

XIncludeFile "../framework/UI.pbi"

; Déclaration des callbacks
Declare OnTreeSelect(*node.UI::TreeNode)
Declare OnTreeExpand(*node.UI::TreeNode, isExpanded.b)
Declare OnTreeCheck(*node.UI::TreeNode, isChecked.b)
Declare OnTreeActionBtn(*node.UI::TreeNode, buttonId.i)

Global *mainWin.UI::Window
Global *tree.UI::CanvasTree
Global *lblStatus.UI::Label

Procedure OnTreeSelect(*node.UI::TreeNode)
  If (*node And *lblStatus)
    Protected chkStr.s = "Non"
    If (*node\IsChecked()) : chkStr = "Oui" : EndIf
    *lblStatus\SetText("Nœud sélectionné: " + *node\GetText() + " | Tag: " + *node\GetTag() + " | Coché: " + chkStr)
  EndIf
EndProcedure

Procedure OnTreeExpand(*node.UI::TreeNode, isExpanded.b)
  If (*node And *lblStatus)
    Protected stateStr.s = "Replié"
    If (isExpanded) : stateStr = "Déplié" : EndIf
    *lblStatus\SetText("Événement Expand: " + *node\GetText() + " -> " + stateStr)
  EndIf
EndProcedure

Procedure OnTreeCheck(*node.UI::TreeNode, isChecked.b)
  If (*node And *lblStatus)
    Protected stateStr.s = "Décoché"
    If (isChecked) : stateStr = "Coché" : EndIf
    *lblStatus\SetText("Événement Check: " + *node\GetText() + " -> " + stateStr)
  EndIf
EndProcedure

Procedure OnTreeActionBtn(*node.UI::TreeNode, buttonId.i)
  If (*node And *lblStatus)
    *lblStatus\SetText("Action Bouton #" + Str(buttonId) + " cliqué sur le nœud: " + *node\GetText())
  EndIf
EndProcedure

; ----------------------------------------------------------------------------
; Point d'entrée de l'application
; ----------------------------------------------------------------------------

Procedure RunApp()
  Protected *app.UI::Application = New UI::Application()

  ; Fenêtre principale 960x600 responsive
  *mainWin = New UI::Window("Démonstration PureBasic OOP - UI::CanvasTree (DPI-Aware)", 960, 600)
  *app\SetMainWindow(*mainWin)

  ; Conteneur racine : DockPanel
  Protected *rootDock.UI::Layouts::DockPanel = New UI::Layouts::DockPanel()
  *rootDock\SetLastChildFill(#True)

  ; 1. Barre d'état en bas
  *lblStatus = New UI::Label("Prêt. Cliquez sur un nœud, un chevron ou une case à cocher.")
  *lblStatus\SetHeight(30)
  *lblStatus\SetMargin(8, 4, 8, 4)
  *rootDock\AddDockChild(*lblStatus, #UI_Dock_Bottom)

  ; 2. Arbre CanvasTree amarré à gauche
  *tree = New UI::CanvasTree(340, 500)
  *tree\SetMargin(10, 10, 10, 10)
  *tree\SetShowCheckBoxes(#True)
  *tree\SetShowLines(#True)
  *tree\SetLineHeight(28)

  ; Configuration des Callbacks
  *tree\SetOnSelect(@OnTreeSelect())
  *tree\SetOnExpand(@OnTreeExpand())
  *tree\SetOnCheck(@OnTreeCheck())
  *tree\SetOnButtonClick(@OnTreeActionBtn())

  ; --- Remplissage de l'arborescence ---
  Protected *rootItem.UI::TreeNode = *tree\GetRoot()

  ; Branche Projet
  Protected *nodeProject.UI::TreeNode = *tree\AddNode(*rootItem, "Mon Projet PureBasic", 0, "project")
  *nodeProject\AddButton(1, 0, 0, "Paramètres", "btn_settings")
  *nodeProject\SetExpanded(#True)

  ; Sous-branche Sources
  Protected *nodeSrc.UI::TreeNode = *tree\AddNode(*nodeProject, "Sources (.pb / .pbi)", 0, "folder_src")
  *nodeSrc\SetExpanded(#True)
  *tree\AddNode(*nodeSrc, "Main.pb", 0, "file_main")
  *tree\AddNode(*nodeSrc, "Config.pbi", 0, "file_config")
  *tree\AddNode(*nodeSrc, "Utilities.pbi", 0, "file_util")

  ; Sous-branche Framework UI
  Protected *nodeFw.UI::TreeNode = *tree\AddNode(*nodeProject, "Framework UI", 0, "folder_fw")
  *nodeFw\SetExpanded(#True)
  *nodeFw\AddButton(2, 0, 0, "Ouvrir dossier", "btn_open")
  
  Protected *nodeControls.UI::TreeNode = *tree\AddNode(*nodeFw, "controls", 0, "folder_controls")
  *nodeControls\SetExpanded(#True)
  *tree\AddNode(*nodeControls, "CanvasTree.pbi", 0, "file_tree")
  *tree\AddNode(*nodeControls, "CustomGadget.pbi", 0, "file_custom")
  *tree\AddNode(*nodeControls, "ToggleSwitch.pbi", 0, "file_toggle")
  *tree\AddNode(*nodeControls, "Button.pbi", 0, "file_btn")
  *tree\AddNode(*nodeControls, "TreeView.pbi", 0, "file_native_tree")

  Protected *nodeLayouts.UI::TreeNode = *tree\AddNode(*nodeFw, "layout", 0, "folder_layout")
  *tree\AddNode(*nodeLayouts, "DockPanel.pbi", 0, "file_dock")
  *tree\AddNode(*nodeLayouts, "Grid.pbi", 0, "file_grid")
  *tree\AddNode(*nodeLayouts, "StackPanel.pbi", 0, "file_stack")

  ; Branche Documentation & Ressources
  Protected *nodeDocs.UI::TreeNode = *tree\AddNode(*rootItem, "Documentation & Guides", 0, "folder_docs")
  *tree\AddNode(*nodeDocs, "Architecture_OOP.md", 0, "doc_arch")
  *tree\AddNode(*nodeDocs, "High_DPI_Guide.md", 0, "doc_dpi")
  *tree\AddNode(*nodeDocs, "Changelog_v1.3.md", 0, "doc_log")

  ; Branche Tests
  Protected *nodeTests.UI::TreeNode = *tree\AddNode(*rootItem, "Tests Unitaires", 0, "folder_tests")
  *tree\AddNode(*nodeTests, "test_leak_detection.pb", 0, "test_leak")
  *tree\AddNode(*nodeTests, "demo_canvas_tree.pb", 0, "test_tree")

  *rootDock\AddDockChild(*tree, #UI_Dock_Left)

  ; 3. Panneau droit d'informations et réglages
  Protected *rightPanel.UI::Layouts::StackPanel = New UI::Layouts::StackPanel()
  *rightPanel\SetOrientation(#UI_Orientation_Vertical)
  *rightPanel\SetMargin(10, 10, 10, 10)

  Protected *lblTitle.UI::Label = New UI::Label("Contrôle UI::CanvasTree")
  *lblTitle\SetMargin(0, 0, 0, 12)
  *rightPanel\AddChild(*lblTitle)

  Protected *lblDesc.UI::Label = New UI::Label("Arbre virtuel haute performance dans un CanvasGadget unique avec support High-DPI natif, chevrons vectoriels anti-aliasés, cases à cocher, boutons d'action par nœud et navigation clavier (flèches, Espace).")
  *lblDesc\SetMargin(0, 0, 0, 15)
  *rightPanel\AddChild(*lblDesc)

  Protected *btnExpandAll.UI::Button = New UI::Button("Déplier Tout l'Arbre")
  *btnExpandAll\SetMargin(0, 0, 0, 8)
  *rightPanel\AddChild(*btnExpandAll)

  Protected *btnCollapseAll.UI::Button = New UI::Button("Replier Tout l'Arbre")
  *btnCollapseAll\SetMargin(0, 0, 0, 8)
  *rightPanel\AddChild(*btnCollapseAll)

  Protected *btnToggleChecks.UI::Button = New UI::Button("Basculer Cases à Cocher")
  *btnToggleChecks\SetMargin(0, 0, 0, 8)
  *rightPanel\AddChild(*btnToggleChecks)

  Protected *btnToggleLines.UI::Button = New UI::Button("Basculer Lignes d'Arborescence")
  *btnToggleLines\SetMargin(0, 0, 0, 8)
  *rightPanel\AddChild(*btnToggleLines)

  Protected *btnToggleDark.UI::Button = New UI::Button("Basculer Mode Sombre / Clair")
  *btnToggleDark\SetMargin(0, 0, 0, 8)
  *rightPanel\AddChild(*btnToggleDark)

  *rootDock\AddDockChild(*rightPanel, #UI_Dock_Fill)

  ; Définir le contenu de la fenêtre
  *mainWin\SetContent(*rootDock)

  ; Boucle d'événements simplifiée avec gestion des boutons du panneau
  Protected isRunning.b = #True
  Protected isDark.b = #False

  While isRunning
    Protected ev.i = WaitWindowEvent()
    Protected evWin.i = EventWindow()
    Protected evGadget.i = EventGadget()
    Protected evType.i = EventType()

    If ev = #PB_Event_CloseWindow
      isRunning = #False
    ElseIf ev = #PB_Event_Gadget
      If evGadget = *btnExpandAll\GetID()
        *tree\ExpandAll()
      ElseIf evGadget = *btnCollapseAll\GetID()
        *tree\CollapseAll()
      ElseIf evGadget = *btnToggleChecks\GetID()
        *tree\SetShowCheckBoxes(1 - *tree\GetShowCheckBoxes())
      ElseIf evGadget = *btnToggleLines\GetID()
        *tree\SetShowLines(1 - *tree\GetShowLines())
      ElseIf evGadget = *btnToggleDark\GetID()
        isDark = 1 - isDark
        *tree\SetDarkMode(isDark)
      ElseIf FindMapElement(UI_GadgetMap(), Str(evGadget))
        Protected *g.UI::Gadget = UI_GadgetMap()
        If *g
          Select (evType)
            Case #PB_EventType_LeftClick:
              *g\OnClick()
            Case #PB_EventType_Change:
              *g\OnChange()
            Case #PB_EventType_Focus:
              *g\OnFocus()
            Case #PB_EventType_LostFocus:
              *g\OnLostFocus()
            Case #PB_EventType_RightClick:
              *g\OnRightClick()
            Default:
              *g\OnCustomEvent(evType)
          EndSelect
        EndIf
      EndIf
    ElseIf ev = #PB_Event_SizeWindow
      *mainWin\OnResize(WindowWidth(evWin), WindowHeight(evWin))
    EndIf
  Wend

  ; Libération propre de toutes les ressources
  *mainWin\Free()
  *app\Free()
EndProcedure

RunApp()
End
