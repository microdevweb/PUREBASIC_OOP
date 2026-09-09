; ============================================================================
; PureBasic OOP GUI Framework - demo_canvas_table.pb
; Demonstration of UI::CanvasTable (High-DPI Virtual Table / DataGrid)
; Demonstrates: Resizable columns, Sorting, In-place editing, Checkboxes,
;               Image icons, Action buttons, Virtual scrolling, Themes (Light/Dark)
;               and full compatibility with PB_TABLE structure & callback pattern!
; Author: MicrodevWeb
; ============================================================================

UsePNGImageDecoder()

; ----------------------------------------------------------------------------
; 1. Data Model (from PB_TABLE example1.pb)
; ----------------------------------------------------------------------------
Structure Person
  firstName.s
  surname.s
  age.l
  size.f
  weight.d
  icon.i
  isActive.b
EndStructure

Global NewList myPeople.Person()
Global img_warning.i, img_phone.i, img_busnes.i

; Catch embedded test images
DataSection
  war_img:
  IncludeBinary "../../PB_TABLE/PB_TABLE/images/warning.png"
  phone_img:
  IncludeBinary "../../PB_TABLE/PB_TABLE/images/phone.png"
  bus_img:
  IncludeBinary "../../PB_TABLE/PB_TABLE/images/busnes.png"
EndDataSection

img_warning = CatchImage(#PB_Any, ?war_img)
img_phone   = CatchImage(#PB_Any, ?phone_img)
img_busnes  = CatchImage(#PB_Any, ?bus_img)

; ----------------------------------------------------------------------------
; 2. Field Getters & Setters (PB_TABLE compatible prototypes)
; ----------------------------------------------------------------------------
Procedure.s GetFirstName(*this.Person)
  ProcedureReturn *this\firstName
EndProcedure

Procedure SetFirstName(*this.Person, val.s)
  *this\firstName = val
EndProcedure

Procedure.s GetSurname(*this.Person)
  ProcedureReturn *this\surname
EndProcedure

Procedure SetSurname(*this.Person, val.s)
  *this\surname = val
EndProcedure

Procedure.i GetAge(*this.Person)
  ProcedureReturn *this\age
EndProcedure

Procedure SetAge(*this.Person, val.i)
  *this\age = val
EndProcedure

Procedure.f GetSize(*this.Person)
  ProcedureReturn *this\size
EndProcedure

Procedure SetSize(*this.Person, val.f)
  *this\size = val
EndProcedure

Procedure.d GetWeight(*this.Person)
  ProcedureReturn *this\weight
EndProcedure

Procedure SetWeight(*this.Person, val.d)
  *this\weight = val
EndProcedure

Procedure.i GetIcon(*this.Person)
  ProcedureReturn *this\icon
EndProcedure

Procedure.i GetIsActive(*this.Person)
  ProcedureReturn *this\isActive
EndProcedure

Procedure SetIsActive(*this.Person, val.i)
  *this\isActive = val
EndProcedure

; ----------------------------------------------------------------------------
; 3. Global References & UI Elements
; ----------------------------------------------------------------------------
Global *mainWin.UI::Window
Global *table.UI::CanvasTable
Global *lblStatus.UI::Label
Global *txtFirstName.UI::TextBox
Global *txtSurname.UI::TextBox
Global *txtAge.UI::TextBox
Global *txtSize.UI::TextBox
Global *txtWeight.UI::TextBox
Global *btnDarkMode.UI::CanvasButton
Global *btnFilter.UI::CanvasButton
Global isDark.b = #True

; ----------------------------------------------------------------------------
; 4. Callbacks
; ----------------------------------------------------------------------------
Procedure OnTableSelect(*row.UI::TableRow)
  If (*row And *row\GetDataContext())
    Protected *p.Person = *row\GetDataContext()
    If (*txtFirstName) : *txtFirstName\SetText(*p\firstName) : EndIf
    If (*txtSurname)   : *txtSurname\SetText(*p\surname)     : EndIf
    If (*txtAge)       : *txtAge\SetText(Str(*p\age))        : EndIf
    If (*txtSize)      : *txtSize\SetText(StrF(*p\size, 2))  : EndIf
    If (*txtWeight)    : *txtWeight\SetText(StrD(*p\weight, 2)) : EndIf
    If (*lblStatus)
      *lblStatus\SetText("Sélection: " + *p\firstName + " " + *p\surname + " | Âge: " + Str(*p\age) + " | Actif: " + Str(*p\isActive))
    EndIf
  EndIf
EndProcedure

Procedure OnTableCellEdit(*row.UI::TableRow, colIdx.i, newVal.s)
  If (*row And *row\GetDataContext())
    Protected *p.Person = *row\GetDataContext()
    If (*lblStatus)
      *lblStatus\SetText("Édition cellule Col #" + Str(colIdx) + " validée -> " + newVal + " (pour " + *p\firstName + " " + *p\surname + ")")
    EndIf
    ; Synchroniser le panneau de détail
    OnTableSelect(*row)
  EndIf
EndProcedure

Procedure OnTableHeaderClick(*col.UI::TableColumn, order.i)
  Protected orderStr.s = "Aucun"
  If (order = #UI_TableSort_Asc)  : orderStr = "Croissant (▲)" : EndIf
  If (order = #UI_TableSort_Desc) : orderStr = "Décroissant (▼)" : EndIf
  If (*lblStatus)
    *lblStatus\SetText("Tri sur la colonne '" + *col\GetTitle() + "' -> " + orderStr)
  EndIf
EndProcedure

Procedure OnTableCheck(*row.UI::TableRow, isChecked.b)
  If (*row And *row\GetDataContext())
    Protected *p.Person = *row\GetDataContext()
    *p\isActive = isChecked
    If (*lblStatus)
      *lblStatus\SetText("Statut Actif basculé pour " + *p\firstName + " " + *p\surname + " -> " + Str(isChecked))
    EndIf
  EndIf
EndProcedure

Procedure OnTableActionButton(*row.UI::TableRow, buttonId.i)
  If (*row And *row\GetDataContext())
    Protected *p.Person = *row\GetDataContext()
    If (buttonId = 1) ; Edit button
      If (*lblStatus)
        *lblStatus\SetText("Action [Édition] cliquée pour " + *p\firstName + " " + *p\surname)
      EndIf
      *table\StartEdit(*table\GetSelectedIndex(), 0)
    ElseIf (buttonId = 2) ; Delete button
      If (*lblStatus)
        *lblStatus\SetText("Action [Supprimer] cliquée pour " + *p\firstName + " " + *p\surname)
      EndIf
      *table\RemoveRow(*table\GetSelectedIndex())
    EndIf
  EndIf
EndProcedure

Procedure OnToggleTheme(*btn.UI::CanvasButton)
  isDark = Bool(Not isDark)
  *table\SetDarkMode(isDark)
  If (isDark)
    *btn\SetText("Mode Clair ☀️")
    *btn\SetDarkStyle()
  Else
    *btn\SetText("Mode Sombre 🌙")
    *btn\SetDefaultStyle()
  EndIf
EndProcedure

Procedure OnAddPerson(*btn.UI::CanvasButton)
  AddElement(myPeople())
  myPeople()\firstName = "Nouvel"
  myPeople()\surname = "Utilisateur"
  myPeople()\age = Random(50, 20)
  myPeople()\size = 175.0 + Random(15)
  myPeople()\weight = 70.0 + Random(20)
  myPeople()\icon = img_busnes
  myPeople()\isActive = #True

  Protected *newRow.UI::TableRow = *table\AddRowData(@myPeople())
  *table\SetSelectedIndex(*table\GetRowCount() - 1)
  If (*lblStatus)
    *lblStatus\SetText("Ajout d'une nouvelle personne (Total: " + Str(*table\GetRowCount()) + " lignes)")
  EndIf
EndProcedure

; ----------------------------------------------------------------------------
; 5. Data Generator
; ----------------------------------------------------------------------------
Procedure GenerateData()
  *table\SetDarkMode(#True)
  AddElement(myPeople())
  myPeople()\firstName = "Pierre" : myPeople()\surname = "Bielen" : myPeople()\age = 55
  myPeople()\size = 175.10 : myPeople()\weight = 80.62 : myPeople()\icon = img_busnes : myPeople()\isActive = #True
  *table\AddRowData(@myPeople())

  AddElement(myPeople())
  myPeople()\firstName = "André" : myPeople()\surname = "Dupond" : myPeople()\age = 48
  myPeople()\size = 165.25 : myPeople()\weight = 70.43 : myPeople()\icon = img_warning : myPeople()\isActive = #False
  *table\AddRowData(@myPeople())

  AddElement(myPeople())
  myPeople()\firstName = "Paul" : myPeople()\surname = "Godelaine" : myPeople()\age = 49
  myPeople()\size = 170.38 : myPeople()\weight = 90.76 : myPeople()\icon = img_phone : myPeople()\isActive = #True
  *table\AddRowData(@myPeople())

  AddElement(myPeople())
  myPeople()\firstName = "Eric" : myPeople()\surname = "Bosly" : myPeople()\age = 50
  myPeople()\size = 164.19 : myPeople()\weight = 110.25 : myPeople()\icon = img_busnes : myPeople()\isActive = #True
  *table\AddRowData(@myPeople())

  ; Generate 50 additional items to test virtual scrolling performance
  Protected i.i, remSize.i, remWeight.i
  For i = 1 To 50
    AddElement(myPeople())
    myPeople()\firstName = "Employé " + Str(i)
    myPeople()\surname = "Nom" + Str(i)
    myPeople()\age = Random(65, 22)
    remSize = i % 25
    remWeight = i % 35
    myPeople()\size = 160.0 + remSize
    myPeople()\weight = 60.0 + remWeight
    If (i % 3 = 0)
      myPeople()\icon = img_warning
      myPeople()\isActive = #False
    ElseIf (i % 3 = 1)
      myPeople()\icon = img_phone
      myPeople()\isActive = #True
    Else
      myPeople()\icon = img_busnes
      myPeople()\isActive = #True
    EndIf
    *table\AddRowData(@myPeople())
  Next
EndProcedure

; ----------------------------------------------------------------------------
; 6. Application Builder & Main Entry
; ----------------------------------------------------------------------------
Procedure RunApp()
  Protected *app.UI::Application = New UI::Application()

  ; Window 1000x640 responsive
  *mainWin = New UI::Window("Démonstrateur PureBasic OOP - UI::CanvasTable (Modern High-DPI Virtual DataGrid)", 1040, 660)
  *app\SetMainWindow(*mainWin)

  ; Root container: DockPanel
  Protected *rootDock.UI::Layouts::DockPanel = New UI::Layouts::DockPanel()
  *rootDock\SetLastChildFill(#True)

  ; 1. Top toolbar
  Protected *topBar.UI::Layouts::StackPanel = New UI::Layouts::StackPanel(#UI_Orientation_Horizontal)
  *topBar\SetHeight(48)
  *topBar\SetMargin(10, 8, 10, 4)
  *topBar\SetSpacing(10)

  Protected *btnAdd.UI::CanvasButton = New UI::CanvasButton("➕ Ajouter Ligne", 140, 34)
  *btnAdd\SetPrimaryStyle()
  *topBar\AddChild(*btnAdd)
  BindGadgetEvent(*btnAdd\GetId(), @OnAddPerson(), #PB_EventType_LeftClick)

  *btnDarkMode = New UI::CanvasButton("Mode Sombre 🌙", 140, 34)
  *topBar\AddChild(*btnDarkMode)
  BindGadgetEvent(*btnDarkMode\GetId(), @OnToggleTheme(), #PB_EventType_LeftClick)

  *rootDock\AddDockChild(*topBar, #UI_Dock_Top)

  ; 2. Bottom status bar
  *lblStatus = New UI::Label("Prêt. Cliquez sur un en-tête pour trier, glissez les séparateurs pour redimensionner, double-cliquez pour éditer.")
  *lblStatus\SetHeight(28)
  *lblStatus\SetMargin(12, 4, 12, 4)
  *rootDock\AddDockChild(*lblStatus, #UI_Dock_Bottom)

  ; 3. Right detail inspector form (StackPanel)
  Protected *detailPanel.UI::Layouts::StackPanel = New UI::Layouts::StackPanel(#UI_Orientation_Vertical)
  *detailPanel\SetWidth(280)
  *detailPanel\SetMargin(8, 8, 12, 8)
  *detailPanel\SetSpacing(6)

  Protected *lblFicTitle.UI::Label = New UI::Label("Fiche Détail Client")
  *detailPanel\AddChild(*lblFicTitle)

  Protected *lblFN.UI::Label = New UI::Label("Prénom :")
  *detailPanel\AddChild(*lblFN)
  *txtFirstName = New UI::TextBox("", 260, 30)
  *detailPanel\AddChild(*txtFirstName)

  Protected *lblSN.UI::Label = New UI::Label("Nom :")
  *detailPanel\AddChild(*lblSN)
  *txtSurname = New UI::TextBox("", 260, 30)
  *detailPanel\AddChild(*txtSurname)

  Protected *lblAge.UI::Label = New UI::Label("Âge :")
  *detailPanel\AddChild(*lblAge)
  *txtAge = New UI::TextBox("", 260, 30)
  *detailPanel\AddChild(*txtAge)

  Protected *lblSize.UI::Label = New UI::Label("Taille (cm) :")
  *detailPanel\AddChild(*lblSize)
  *txtSize = New UI::TextBox("", 260, 30)
  *detailPanel\AddChild(*txtSize)

  Protected *lblWeight.UI::Label = New UI::Label("Poids (kg) :")
  *detailPanel\AddChild(*lblWeight)
  *txtWeight = New UI::TextBox("", 260, 30)
  *detailPanel\AddChild(*txtWeight)

  *rootDock\AddDockChild(*detailPanel, #UI_Dock_Right)

  ; 4. Center: UI::CanvasTable
  *table = New UI::CanvasTable(700, 520)
  *table\SetMargin(10, 4, 4, 8)
  *table\SetLineHeight(30)
  *table\SetHeaderHeight(34)
  *table\SetShowAlternatingColors(#True)
  *table\SetShowGridLines(#True)

  ; Add columns with types and getters/setters (PB_TABLE pattern)
  Protected *colActif.UI::TableColumn = *table\AddColumn("Actif", 55, #UI_TableCol_CheckBox, #UI_TableAlign_Center)
  *colActif\SetGetter(@GetIsActive())
  *colActif\SetSetter(@SetIsActive())

  Protected *colIcon.UI::TableColumn = *table\AddColumn("Statut", 60, #UI_TableCol_Image, #UI_TableAlign_Center)
  *colIcon\SetGetter(@GetIcon())

  Protected *colFN.UI::TableColumn = *table\AddColumn("Prénom", 130, #UI_TableCol_Text, #UI_TableAlign_Left)
  *colFN\SetGetter(@GetFirstName())
  *colFN\SetSetter(@SetFirstName())

  Protected *colSN.UI::TableColumn = *table\AddColumn("Nom", 130, #UI_TableCol_Text, #UI_TableAlign_Left)
  *colSN\SetGetter(@GetSurname())
  *colSN\SetSetter(@SetSurname())

  Protected *colAge.UI::TableColumn = *table\AddColumn("Âge", 75, #UI_TableCol_Number, #UI_TableAlign_Right)
  *colAge\SetDecimals(0)
  *colAge\SetGetter(@GetAge())
  *colAge\SetSetter(@SetAge())

  Protected *colSize.UI::TableColumn = *table\AddColumn("Taille", 85, #UI_TableCol_Float, #UI_TableAlign_Right)
  *colSize\SetDecimals(2)
  *colSize\SetGetter(@GetSize())
  *colSize\SetSetter(@SetSize())

  Protected *colWeight.UI::TableColumn = *table\AddColumn("Poids (kg)", 95, #UI_TableCol_Double, #UI_TableAlign_Right)
  *colWeight\SetDecimals(2)
  *colWeight\SetGetter(@GetWeight())
  *colWeight\SetSetter(@SetWeight())

  ; Column with action buttons
  Protected *colAction.UI::TableColumn = *table\AddColumn("Actions", 80, #UI_TableCol_ActionButtons, #UI_TableAlign_Center)
  *colAction\AddButton(1, 0, "Édit", "Modifier la ligne")
  *colAction\AddButton(2, 0, "Suppr", "Supprimer la ligne")
  *colAction\SetSortable(#False)

  ; Hook callbacks
  *table\SetOnSelect(@OnTableSelect())
  *table\SetOnCellEdit(@OnTableCellEdit())
  *table\SetOnHeaderClick(@OnTableHeaderClick())
  *table\SetOnCheck(@OnTableCheck())
  *table\SetOnButtonClick(@OnTableActionButton())

  ; Populate data
  GenerateData()
  *table\SetDarkMode(#True)

  ; Select first row by default
  *table\SetSelectedIndex(0)

  *rootDock\AddDockChild(*table, #UI_Dock_Fill)
  *mainWin\SetContent(*rootDock)

  *app\Run()
EndProcedure

RunApp()
