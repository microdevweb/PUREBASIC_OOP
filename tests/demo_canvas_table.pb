; ============================================================================
; PureBasic OOP GUI Framework - demo_canvas_table.pb
; Demonstration of UI::CanvasTable (High-DPI Virtual Table / DataGrid)
; Architecture: 100% Object-Oriented (Model, View, Encapsulated Window)
; Demonstrates: Resizable columns, Sorting, In-place editing, Checkboxes,
;               Image icons, Action buttons, Virtual scrolling, Themes (Light/Dark)
;               and full compatibility with PB_TABLE structure & callback pattern!
; Author: MicrodevWeb
; ============================================================================

UsePNGImageDecoder()

; ----------------------------------------------------------------------------
; Forward Declarations
; ----------------------------------------------------------------------------
Declare.s Person_GetFirstName(*p)
Declare Person_SetFirstName(*p, val.s)
Declare.s Person_GetSurname(*p)
Declare Person_SetSurname(*p, val.s)
Declare.i Person_GetAge(*p)
Declare Person_SetAge(*p, val.i)
Declare.f Person_GetSize(*p)
Declare Person_SetSize(*p, val.f)
Declare.d Person_GetWeight(*p)
Declare Person_SetWeight(*p, val.d)
Declare.i Person_GetIcon(*p)
Declare.i Person_GetIsActive(*p)
Declare Person_SetIsActive(*p, val.i)

Declare TableEvent_OnSelect(*row)
Declare TableEvent_OnCellEdit(*row, colIdx.i, newVal.s)
Declare TableEvent_OnHeaderClick(*col, order.i)
Declare TableEvent_OnCheck(*row, isChecked.b)
Declare TableEvent_OnButtonClick(*row, buttonId.i)
Declare Toolbar_OnAddClicked()
Declare Toolbar_OnToggleThemeClicked()

; ----------------------------------------------------------------------------
; 1. Embedded Asset Resources
; ----------------------------------------------------------------------------
DataSection
  war_img:
  IncludeBinary "../../PB_TABLE/PB_TABLE/images/warning.png"
  phone_img:
  IncludeBinary "../../PB_TABLE/PB_TABLE/images/phone.png"
  bus_img:
  IncludeBinary "../../PB_TABLE/PB_TABLE/images/busnes.png"
EndDataSection

; ----------------------------------------------------------------------------
; 2. Domain Data Model (OOP Class)
; ----------------------------------------------------------------------------
Namespace Demo {

  Class Person {
    Protected firstName.s
    Protected surname.s
    Protected age.l
    Protected size.f
    Protected weight.d
    Protected icon.i
    Protected isActive.b

    Public Method Init(fn.s, sn.s, a.l, s.f, w.d, ic.i, act.b) {
      This\firstName = fn
      This\surname = sn
      This\age = a
      This\size = s
      This\weight = w
      This\icon = ic
      This\isActive = act
    }

    Public Method.s GetFirstName() {
      ProcedureReturn This\firstName
    }

    Public Method SetFirstName(v.s) {
      This\firstName = v
    }

    Public Method.s GetSurname() {
      ProcedureReturn This\surname
    }

    Public Method SetSurname(v.s) {
      This\surname = v
    }

    Public Method.l GetAge() {
      ProcedureReturn This\age
    }

    Public Method SetAge(v.l) {
      This\age = v
    }

    Public Method.f GetSize() {
      ProcedureReturn This\size
    }

    Public Method SetSize(v.f) {
      This\size = v
    }

    Public Method.d GetWeight() {
      ProcedureReturn This\weight
    }

    Public Method SetWeight(v.d) {
      This\weight = v
    }

    Public Method.i GetIcon() {
      ProcedureReturn This\icon
    }

    Public Method SetIcon(v.i) {
      This\icon = v
    }

    Public Method.b GetIsActive() {
      ProcedureReturn This\isActive
    }

    Public Method SetIsActive(v.b) {
      This\isActive = v
    }

    Public Method.s GetFullName() {
      ProcedureReturn This\firstName + " " + This\surname
    }
  }

}

; ----------------------------------------------------------------------------
; 3. Model Getters & Setters for CanvasTable (Function Pointers)
; ----------------------------------------------------------------------------
Procedure.s Person_GetFirstName(*p.Demo::Person)
  ProcedureReturn *p\GetFirstName()
EndProcedure

Procedure Person_SetFirstName(*p.Demo::Person, val.s)
  *p\SetFirstName(val)
EndProcedure

Procedure.s Person_GetSurname(*p.Demo::Person)
  ProcedureReturn *p\GetSurname()
EndProcedure

Procedure Person_SetSurname(*p.Demo::Person, val.s)
  *p\SetSurname(val)
EndProcedure

Procedure.i Person_GetAge(*p.Demo::Person)
  ProcedureReturn *p\GetAge()
EndProcedure

Procedure Person_SetAge(*p.Demo::Person, val.i)
  *p\SetAge(val)
EndProcedure

Procedure.f Person_GetSize(*p.Demo::Person)
  ProcedureReturn *p\GetSize()
EndProcedure

Procedure Person_SetSize(*p.Demo::Person, val.f)
  *p\SetSize(val)
EndProcedure

Procedure.d Person_GetWeight(*p.Demo::Person)
  ProcedureReturn *p\GetWeight()
EndProcedure

Procedure Person_SetWeight(*p.Demo::Person, val.d)
  *p\SetWeight(val)
EndProcedure

Procedure.i Person_GetIcon(*p.Demo::Person)
  ProcedureReturn *p\GetIcon()
EndProcedure

Procedure.i Person_GetIsActive(*p.Demo::Person)
  ProcedureReturn *p\GetIsActive()
EndProcedure

Procedure Person_SetIsActive(*p.Demo::Person, val.i)
  *p\SetIsActive(val)
EndProcedure


; ----------------------------------------------------------------------------
; 4. Encapsulated Main Window (OOP View & Controller)
; ----------------------------------------------------------------------------

Namespace Demo {

  Class TableDemoWindow Extends UI::Window {
    ; Encapsulated UI Controls
    Protected *table.UI::CanvasTable
    Protected *lblStatus.UI::Label
    Protected *txtFirstName.UI::TextBox
    Protected *txtSurname.UI::TextBox
    Protected *txtAge.UI::TextBox
    Protected *txtSize.UI::TextBox
    Protected *txtWeight.UI::TextBox
    Protected *btnAdd.UI::CanvasButton
    Protected *btnDarkMode.UI::CanvasButton
    Protected isDark.b

    ; Model Collection
    Protected List *people.Demo::Person()

    ; Cached Assets
    Protected img_warning.i
    Protected img_phone.i
    Protected img_busnes.i

    ; Constructor
    Public Method Init() {
      Super\Init("Démonstrateur PureBasic OOP - UI::CanvasTable (Modern High-DPI Virtual DataGrid)", 1040, 660, #PB_Window_SystemMenu | #PB_Window_ScreenCentered | #PB_Window_SizeGadget | #PB_Window_MaximizeGadget | #PB_Window_MinimizeGadget)
      UI::RegisterWindow(This\id, This)

      This\isDark = #False
      This\LoadAssets()
      This\BuildUI()
      This\ConfigureTable()
      This\GenerateSampleData()

      ; Select first row by default
      If (This\*table\GetRowCount() > 0)
        This\*table\SetSelectedIndex(0)
        This\OnRowSelected(This\*table\GetRow(0))
      EndIf
    }

    Public Method LoadAssets() {
      This\img_warning = CatchImage(#PB_Any, ?war_img)
      This\img_phone   = CatchImage(#PB_Any, ?phone_img)
      This\img_busnes  = CatchImage(#PB_Any, ?bus_img)
    }

    Public Method BuildUI() {
      ; Root Layout: DockPanel
      Protected *rootDock.UI::Layouts::DockPanel = New UI::Layouts::DockPanel()
      *rootDock\SetLastChildFill(#True)

      ; 1. Top Toolbar (StackPanel Horizontal)
      Protected *topBar.UI::Layouts::StackPanel = New UI::Layouts::StackPanel(#UI_Orientation_Horizontal)
      *topBar\SetHeight(48)
      *topBar\SetMargin(10, 8, 10, 4)
      *topBar\SetSpacing(10)

      This\*btnAdd = New UI::CanvasButton("➕ Ajouter Ligne", 140, 34)
      This\*btnAdd\SetPrimaryStyle()
      *topBar\AddChild(This\*btnAdd)
      BindGadgetEvent(This\*btnAdd\GetId(), @Toolbar_OnAddClicked(), #PB_EventType_LeftClick)

      This\*btnDarkMode = New UI::CanvasButton("Mode Sombre 🌙", 140, 34)
      *topBar\AddChild(This\*btnDarkMode)
      BindGadgetEvent(This\*btnDarkMode\GetId(), @Toolbar_OnToggleThemeClicked(), #PB_EventType_LeftClick)

      *rootDock\AddDockChild(*topBar, #UI_Dock_Top)

      ; 2. Bottom Status Bar
      This\*lblStatus = New UI::Label("Prêt. Cliquez sur un en-tête pour trier, glissez les séparateurs pour redimensionner, double-cliquez pour éditer.")
      This\*lblStatus\SetHeight(28)
      This\*lblStatus\SetMargin(12, 4, 12, 4)
      *rootDock\AddDockChild(This\*lblStatus, #UI_Dock_Bottom)

      ; 3. Right Detail Inspector Form
      Protected *detailPanel.UI::Layouts::StackPanel = New UI::Layouts::StackPanel(#UI_Orientation_Vertical)
      *detailPanel\SetWidth(280)
      *detailPanel\SetMargin(8, 8, 12, 8)
      *detailPanel\SetSpacing(6)

      Protected *lblFicTitle.UI::Label = New UI::Label("Fiche Détail Client")
      *detailPanel\AddChild(*lblFicTitle)

      Protected *lblFN.UI::Label = New UI::Label("Prénom :")
      *detailPanel\AddChild(*lblFN)
      This\*txtFirstName = New UI::TextBox("", 260, 30)
      *detailPanel\AddChild(This\*txtFirstName)

      Protected *lblSN.UI::Label = New UI::Label("Nom :")
      *detailPanel\AddChild(*lblSN)
      This\*txtSurname = New UI::TextBox("", 260, 30)
      *detailPanel\AddChild(This\*txtSurname)

      Protected *lblAge.UI::Label = New UI::Label("Âge :")
      *detailPanel\AddChild(*lblAge)
      This\*txtAge = New UI::TextBox("", 260, 30)
      *detailPanel\AddChild(This\*txtAge)

      Protected *lblSize.UI::Label = New UI::Label("Taille (cm) :")
      *detailPanel\AddChild(*lblSize)
      This\*txtSize = New UI::TextBox("", 260, 30)
      *detailPanel\AddChild(This\*txtSize)

      Protected *lblWeight.UI::Label = New UI::Label("Poids (kg) :")
      *detailPanel\AddChild(*lblWeight)
      This\*txtWeight = New UI::TextBox("", 260, 30)
      *detailPanel\AddChild(This\*txtWeight)

      *rootDock\AddDockChild(*detailPanel, #UI_Dock_Right)

      ; 4. Center: CanvasTable
      This\*table = New UI::CanvasTable(700, 520)
      This\*table\SetMargin(10, 4, 4, 8)
      This\*table\SetLineHeight(30)
      This\*table\SetHeaderHeight(34)
      This\*table\SetShowAlternatingColors(#True)
      This\*table\SetShowGridLines(#True)

      *rootDock\AddDockChild(This\*table, #UI_Dock_Fill)
      This\SetContent(*rootDock)
    }

    Public Method ConfigureTable() {
      ; Add columns with types and getters/setters (PB_TABLE pattern)
      Protected *colActif.UI::TableColumn = This\*table\AddColumn("Actif", 55, #UI_TableCol_CheckBox, #UI_TableAlign_Center)
      *colActif\SetGetter(@Person_GetIsActive())
      *colActif\SetSetter(@Person_SetIsActive())

      Protected *colIcon.UI::TableColumn = This\*table\AddColumn("Statut", 60, #UI_TableCol_Image, #UI_TableAlign_Center)
      *colIcon\SetGetter(@Person_GetIcon())

      Protected *colFN.UI::TableColumn = This\*table\AddColumn("Prénom", 130, #UI_TableCol_Text, #UI_TableAlign_Left)
      *colFN\SetGetter(@Person_GetFirstName())
      *colFN\SetSetter(@Person_SetFirstName())

      Protected *colSN.UI::TableColumn = This\*table\AddColumn("Nom", 130, #UI_TableCol_Text, #UI_TableAlign_Left)
      *colSN\SetGetter(@Person_GetSurname())
      *colSN\SetSetter(@Person_SetSurname())

      Protected *colAge.UI::TableColumn = This\*table\AddColumn("Âge", 75, #UI_TableCol_Number, #UI_TableAlign_Right)
      *colAge\SetDecimals(0)
      *colAge\SetGetter(@Person_GetAge())
      *colAge\SetSetter(@Person_SetAge())

      Protected *colSize.UI::TableColumn = This\*table\AddColumn("Taille", 85, #UI_TableCol_Float, #UI_TableAlign_Right)
      *colSize\SetDecimals(2)
      *colSize\SetGetter(@Person_GetSize())
      *colSize\SetSetter(@Person_SetSize())

      Protected *colWeight.UI::TableColumn = This\*table\AddColumn("Poids (kg)", 95, #UI_TableCol_Double, #UI_TableAlign_Right)
      *colWeight\SetDecimals(2)
      *colWeight\SetGetter(@Person_GetWeight())
      *colWeight\SetSetter(@Person_SetWeight())

      ; Column with action buttons
      Protected *colAction.UI::TableColumn = This\*table\AddColumn("Actions", 80, #UI_TableCol_ActionButtons, #UI_TableAlign_Center)
      *colAction\AddButton(1, 0, "Édit", "Modifier la ligne")
      *colAction\AddButton(2, 0, "Suppr", "Supprimer la ligne")
      *colAction\SetSortable(#False)

      ; Hook table event callbacks
      This\*table\SetOnSelect(@TableEvent_OnSelect())
      This\*table\SetOnCellEdit(@TableEvent_OnCellEdit())
      This\*table\SetOnHeaderClick(@TableEvent_OnHeaderClick())
      This\*table\SetOnCheck(@TableEvent_OnCheck())
      This\*table\SetOnButtonClick(@TableEvent_OnButtonClick())
    }

    Public Method AddPerson(fn.s, sn.s, a.l, s.f, w.d, ic.i, act.b) {
      Protected *p.Demo::Person = New Demo::Person(fn, sn, a, s, w, ic, act)
      AddElement(This\*people())
      This\*people() = *p
      This\*table\AddRowData(*p)
    }

    Public Method GenerateSampleData() {
      This\AddPerson("Pierre", "Bielen", 55, 175.10, 80.62, This\img_busnes, #True)
      This\AddPerson("André", "Dupond", 48, 165.25, 70.43, This\img_warning, #False)
      This\AddPerson("Paul", "Godelaine", 49, 170.38, 90.76, This\img_phone, #True)
      This\AddPerson("Eric", "Bosly", 50, 164.19, 110.25, This\img_busnes, #True)

      ; 50 additional items to showcase virtual scrolling performance
      Protected i.i, remSize.i, remWeight.i, ic.i, act.b
      For i = 1 To 50
        remSize = i % 25
        remWeight = i % 35
        If (i % 3 = 0)
          ic = This\img_warning
          act = #False
        ElseIf (i % 3 = 1)
          ic = This\img_phone
          act = #True
        Else
          ic = This\img_busnes
          act = #True
        EndIf
        This\AddPerson("Employé " + Str(i), "Nom" + Str(i), Random(65, 22), 160.0 + remSize, 60.0 + remWeight, ic, act)
      Next
    }

    Public Method OnAddRandomPerson() {
      This\AddPerson("Nouvel", "Utilisateur", Random(50, 20), 175.0 + Random(15), 70.0 + Random(20), This\img_busnes, #True)
      This\*table\SetSelectedIndex(This\*table\GetRowCount() - 1)
      If (This\*lblStatus)
        This\*lblStatus\SetText("Ajout d'une nouvelle personne (Total: " + Str(This\*table\GetRowCount()) + " lignes)")
      EndIf
    }

    Public Method OnRowSelected(*row.UI::TableRow) {
      If (*row And *row\GetDataContext())
        Protected *p.Demo::Person = *row\GetDataContext()
        If (This\*txtFirstName) : This\*txtFirstName\SetText(*p\GetFirstName()) : EndIf
        If (This\*txtSurname)   : This\*txtSurname\SetText(*p\GetSurname())     : EndIf
        If (This\*txtAge)       : This\*txtAge\SetText(Str(*p\GetAge()))        : EndIf
        If (This\*txtSize)      : This\*txtSize\SetText(StrF(*p\GetSize(), 2))  : EndIf
        If (This\*txtWeight)    : This\*txtWeight\SetText(StrD(*p\GetWeight(), 2)) : EndIf
        If (This\*lblStatus)
          This\*lblStatus\SetText("Sélection: " + *p\GetFullName() + " | Âge: " + Str(*p\GetAge()) + " | Actif: " + Str(*p\GetIsActive()))
        EndIf
      EndIf
    }

    Public Method OnCellEdited(*row.UI::TableRow, colIdx.i, newVal.s) {
      If (*row And *row\GetDataContext())
        Protected *p.Demo::Person = *row\GetDataContext()
        If (This\*lblStatus)
          This\*lblStatus\SetText("Édition cellule Col #" + Str(colIdx) + " validée -> " + newVal + " (pour " + *p\GetFullName() + ")")
        EndIf
        This\OnRowSelected(*row)
      EndIf
    }

    Public Method OnHeaderClicked(*col.UI::TableColumn, order.i) {
      Protected orderStr.s = "Aucun"
      If (order = #UI_TableSort_Asc)  : orderStr = "Croissant (▲)" : EndIf
      If (order = #UI_TableSort_Desc) : orderStr = "Décroissant (▼)" : EndIf
      If (This\*lblStatus)
        This\*lblStatus\SetText("Tri sur la colonne '" + *col\GetTitle() + "' -> " + orderStr)
      EndIf
    }

    Public Method OnRowChecked(*row.UI::TableRow, isChecked.b) {
      If (*row And *row\GetDataContext())
        Protected *p.Demo::Person = *row\GetDataContext()
        *p\SetIsActive(isChecked)
        If (This\*lblStatus)
          This\*lblStatus\SetText("Statut Actif basculé pour " + *p\GetFullName() + " -> " + Str(isChecked))
        EndIf
      EndIf
    }

    Public Method OnRowActionButton(*row.UI::TableRow, buttonId.i) {
      If (*row And *row\GetDataContext())
        Protected *p.Demo::Person = *row\GetDataContext()
        If (buttonId = 1) ; Edit button
          If (This\*lblStatus)
            This\*lblStatus\SetText("Action [Édition] cliquée pour " + *p\GetFullName())
          EndIf
          This\*table\StartEdit(This\*table\GetSelectedIndex(), 0)
        ElseIf (buttonId = 2) ; Delete button
          If (This\*lblStatus)
            This\*lblStatus\SetText("Action [Supprimer] cliquée pour " + *p\GetFullName())
          EndIf
          This\*table\RemoveRow(This\*table\GetSelectedIndex())
        EndIf
      EndIf
    }

    Public Method ToggleTheme() {
      This\isDark = Bool(Not This\isDark)
      This\*table\SetDarkMode(This\isDark)
      If (This\isDark)
        This\*btnDarkMode\SetText("Mode Clair ☀️")
        This\*btnDarkMode\SetDarkStyle()
      Else
        This\*btnDarkMode\SetText("Mode Sombre 🌙")
        This\*btnDarkMode\SetDefaultStyle()
      EndIf
    }
  }

}

; ----------------------------------------------------------------------------
; 5. Event Delegate Glue (PureBasic C/StdCall Dispatchers to Window Object)
; ----------------------------------------------------------------------------
Global *activeDemoWindow.Demo::TableDemoWindow

Procedure TableEvent_OnSelect(*row.UI::TableRow)
  If (*activeDemoWindow) : *activeDemoWindow\OnRowSelected(*row) : EndIf
EndProcedure

Procedure TableEvent_OnCellEdit(*row.UI::TableRow, colIdx.i, newVal.s)
  If (*activeDemoWindow) : *activeDemoWindow\OnCellEdited(*row, colIdx, newVal) : EndIf
EndProcedure

Procedure TableEvent_OnHeaderClick(*col.UI::TableColumn, order.i)
  If (*activeDemoWindow) : *activeDemoWindow\OnHeaderClicked(*col, order) : EndIf
EndProcedure

Procedure TableEvent_OnCheck(*row.UI::TableRow, isChecked.b)
  If (*activeDemoWindow) : *activeDemoWindow\OnRowChecked(*row, isChecked) : EndIf
EndProcedure

Procedure TableEvent_OnButtonClick(*row.UI::TableRow, buttonId.i)
  If (*activeDemoWindow) : *activeDemoWindow\OnRowActionButton(*row, buttonId) : EndIf
EndProcedure

Procedure Toolbar_OnAddClicked()
  If (*activeDemoWindow) : *activeDemoWindow\OnAddRandomPerson() : EndIf
EndProcedure

Procedure Toolbar_OnToggleThemeClicked()
  If (*activeDemoWindow) : *activeDemoWindow\ToggleTheme() : EndIf
EndProcedure


; ----------------------------------------------------------------------------
; 6. Application Entry Point
; ----------------------------------------------------------------------------
Define *app.UI::Application = New UI::Application()
*activeDemoWindow = New Demo::TableDemoWindow()
*app\SetMainWindow(*activeDemoWindow)
*app\Run()
