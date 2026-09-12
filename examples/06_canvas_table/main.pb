; ============================================================================
; PureBasic OOP GUI Framework - Example 06: CanvasTable
; High-DPI Vector Data Table / DataGrid with Virtual Scrolling
; Version: ALPHA 1.4
; ============================================================================

XIncludeFile "../../framework/UI.pbi"

EnableExplicit

Declare OnRowSelected(*row.UI::TableRow)
Declare OnAddRowClicked()
Declare OnRemoveRowClicked()

Global *table.UI::CanvasTable
Global *statusLabel.UI::CanvasText
Global nextId.i = 6

Procedure Main()
  Protected winW.i = 960
  Protected winH.i = 580
  
  ; 1. Initialiser l'Application et la Fenêtre Principale
  Protected *app.UI::Application = New UI::Application("PureBasic OOP - CanvasTable Demo")
  Protected *win.UI::Window = New UI::Window("Démonstration UI::CanvasTable (Vector DataGrid - Alpha 1.4)", winW, winH)
  *win\SetBackgroundColor(RGB(241, 245, 249)) ; Fond ardoise clair moderne
  
  ; 2. En-tête / Titre
  Protected *title.UI::CanvasText = New UI::CanvasText(24, 16, 450, 26, "Catalogue Produits - UI::CanvasTable")
  *title\SetTypography("Segoe UI", 13, #True)
  *title\SetForeground(RGB(15, 23, 42))
  
  *statusLabel = New UI::CanvasText(24, 44, 450, 20, "Prêt. Sélectionnez une ligne pour afficher les détails.")
  *statusLabel\SetTypography("Segoe UI", 9, #False)
  *statusLabel\SetForeground(RGB(100, 116, 139))
  
  ; 3. Boutons d'action
  Protected *btnAdd.UI::CanvasButton = New UI::CanvasButton(winW - 250, 20, 105, 34, "+ Ajouter")
  *btnAdd\SetSuccessStyle()
  BindGadgetEvent(*btnAdd\GetID(), @OnAddRowClicked(), #PB_EventType_LeftClick)
  
  Protected *btnRemove.UI::CanvasButton = New UI::CanvasButton(winW - 135, 20, 110, 34, "Supprimer")
  *btnRemove\SetDangerStyle()
  BindGadgetEvent(*btnRemove\GetID(), @OnRemoveRowClicked(), #PB_EventType_LeftClick)
  
  ; 4. Tableau Vectoriel : UI::CanvasTable
  *table = New UI::CanvasTable(24, 76, winW - 48, winH - 96)
  *table\SetHeaderHeight(34)
  *table\SetLineHeight(30)
  *table\SetShowAlternatingColors(#True)
  *table\SetEvenRowColors(RGB(255, 255, 255), RGB(15, 23, 42))
  *table\SetOddRowColors(RGB(248, 250, 252), RGB(15, 23, 42))
  
  ; 5. Définition des colonnes
  *table\AddColumn("Réf.", 90, #UI_TableCol_Text, #UI_TableAlign_Center)
  *table\AddColumn("Désignation", 280, #UI_TableCol_Text, #UI_TableAlign_Left)
  *table\AddColumn("Catégorie", 160, #UI_TableCol_Text, #UI_TableAlign_Left)
  *table\AddColumn("Prix (€)", 110, #UI_TableCol_Number, #UI_TableAlign_Right)
  *table\AddColumn("Stock", 90, #UI_TableCol_Number, #UI_TableAlign_Right)
  *table\AddColumn("En Vente", 90, #UI_TableCol_CheckBox, #UI_TableAlign_Center)
  
  ; 6. Données initiales
  *table\AddRowCells("ART-001", "Clavier Mécanique RGB Sans-Fil", "Périphériques", "129.90", "42", "1", "", "")
  *table\AddRowCells("ART-002", "Souris Ergonomique 16000 DPI", "Périphériques", "59.00", "118", "1", "", "")
  *table\AddRowCells("ART-003", "Écran 27'' IPS 144Hz HDR", "Affichage", "279.50", "15", "1", "", "")
  *table\AddRowCells("ART-004", "Casque Audio Haute Fidélité", "Audio", "149.00", "0", "0", "", "")
  *table\AddRowCells("ART-005", "Tapis de Bureau XXL Imperméable", "Accessoires", "24.90", "230", "1", "", "")
  
  ; 7. Événement de sélection
  *table\SetOnSelect(@OnRowSelected())
  
  ; 8. Lancer l'application
  *app\SetMainWindow(*win)
  *app\Run()
  
  ; 9. Nettoyage
  *win\Free()
  *app\Free()
EndProcedure

Procedure OnRowSelected(*row.UI::TableRow)
  If *row And *statusLabel
    Protected ref.s = *row\GetCellText(0)
    Protected desc.s = *row\GetCellText(1)
    Protected prix.s = *row\GetCellText(3)
    *statusLabel\SetText("Article sélectionné : " + ref + " — " + desc + " (" + prix + " €)")
    *statusLabel\Redraw()
  EndIf
EndProcedure

Procedure OnAddRowClicked()
  If *table
    Protected code.s = "ART-00" + Str(nextId)
    *table\AddRowCells(code, "Nouvel Article Démo #" + Str(nextId), "Divers", "49.99", "10", "1", "", "")
    nextId + 1
    If *statusLabel
      *statusLabel\SetText("Article " + code + " ajouté avec succès au tableau.")
      *statusLabel\Redraw()
    EndIf
  EndIf
EndProcedure

Procedure OnRemoveRowClicked()
  If *table
    Protected selIdx.i = *table\GetSelectedIndex()
    If selIdx >= 0
      *table\RemoveRow(selIdx)
      If *statusLabel
        *statusLabel\SetText("Ligne " + Str(selIdx + 1) + " supprimée du tableau.")
        *statusLabel\Redraw()
      EndIf
    Else
      MessageRequester("Information", "Veuillez sélectionner une ligne dans le tableau à supprimer.", #PB_MessageRequester_Info)
    EndIf
  EndIf
EndProcedure

Main()
