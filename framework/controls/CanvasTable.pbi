; ============================================================================
; PureBasic OOP GUI Framework - CanvasTable.pbi
; Modern High-DPI Virtual Canvas Table / DataGrid Control
; Features: Resizable & Sortable columns, In-place cell editing, Virtual scrolling,
;           Integrated vector scrollbars, CheckBox & Action button columns,
;           Keyboard navigation, Light/Dark themes, Direct Structure & Cell data.
; Author:      MicrodevWeb
; ============================================================================

; ----------------------------------------------------------------------------
; Column Types & Alignments (Matching PB_TABLE types for 100% compatibility)
; ----------------------------------------------------------------------------
#UI_TableCol_Text          = 0
#UI_TableCol_Number        = 1 ; Integer
#UI_TableCol_Float         = 2
#UI_TableCol_Double        = 3
#UI_TableCol_Image         = 4
#UI_TableCol_CheckBox      = 5
#UI_TableCol_ActionButtons = 6

#UI_TableAlign_Left        = 0
#UI_TableAlign_Center      = 1
#UI_TableAlign_Right       = 2

#UI_TableSort_None         = 0
#UI_TableSort_Asc          = 1
#UI_TableSort_Desc         = 2


; ----------------------------------------------------------------------------
; Data structures for Table Action Buttons
; ----------------------------------------------------------------------------
Structure UI_TableActionButton
  id.i
  icon.i
  text.s
  *callback
  tooltip.s
  tag.s
  x.i
  y.i
  w.i
  h.i
EndStructure

Namespace UI {

  ; ==========================================================================
  ; Class: TableColumn
  ; Represents a column specification in UI::CanvasTable
  ; ==========================================================================
  Class TableColumn {
    Protected id.i
    Protected title.s
    Protected width.i
    Protected minWidth.i
    Protected colType.i
    Protected align.i
    Protected isSortable.b
    Protected isEditable.b
    Protected isResizable.b
    Protected sortOrder.i      ; 0: None, 1: Asc, 2: Desc
    Protected imageSize.f      ; Relative to row height (e.g. 0.7)
    Protected decimals.i       ; For floating point numbers
    Protected *getter          ; Prototype.s (*dataContext)
    Protected *setter          ; Prototype (*dataContext, value.s)
    Protected List buttons.UI_TableActionButton()

    Protected Method InitDefaults() {
      This\id = 0
      This\title = "Column"
      This\width = 120
      This\minWidth = 40
      This\colType = #UI_TableCol_Text
      This\align = #UI_TableAlign_Left
      This\isSortable = #True
      This\isEditable = #False
      This\isResizable = #True
      This\sortOrder = #UI_TableSort_None
      This\imageSize = 0.7
      This\decimals = 2
      This\*getter = 0
      This\*setter = 0
    }

    ; Constructor 1: Default
    Public Method Init()  {
      This\InitDefaults()
    }

    ; Constructor 2: Title and Width
    Public Method Init(title_p.s, width_p.i) {
      This\InitDefaults()
      This\title = title_p
      This\width = width_p
    }

    ; Constructor 3: Title, Width and Type
    Public Method Init(title_p.s, width_p.i, colType_p.i) {
      This\InitDefaults()
      This\title = title_p
      This\width = width_p
      This\colType = colType_p
      If (colType_p = #UI_TableCol_Number Or colType_p = #UI_TableCol_Float Or colType_p = #UI_TableCol_Double)
        This\align = #UI_TableAlign_Right
      ElseIf (colType_p = #UI_TableCol_CheckBox Or colType_p = #UI_TableCol_Image Or colType_p = #UI_TableCol_ActionButtons)
        This\align = #UI_TableAlign_Center
      EndIf
    }

    ; Constructor 4: Full parameters
    Public Method Init(title_p.s, width_p.i, colType_p.i, align_p.i, isSortable_p.b, isEditable_p.b) {
      This\InitDefaults()
      This\title = title_p
      This\width = width_p
      This\colType = colType_p
      This\align = align_p
      This\isSortable = isSortable_p
      This\isEditable = isEditable_p
    }

    ; --- Getters / Setters ---

    Public Method.i GetId()  {
      ProcedureReturn This\id
    }
    Public Method SetId(id_p.i)  {
      This\id = id_p
    }

    Public Method.s GetTitle()  {
      ProcedureReturn This\title
    }
    Public Method SetTitle(title_p.s)  {
      This\title = title_p
    }

    Public Method.i GetWidth()  {
      ProcedureReturn This\width
    }
    Public Method SetWidth(w_p.i) {
      If (w_p < This\minWidth) : w_p = This\minWidth : EndIf
      This\width = w_p
    }

    Public Method.i GetMinWidth()  {
      ProcedureReturn This\minWidth
    }
    Public Method SetMinWidth(minW_p.i)  {
      This\minWidth = minW_p
    }

    Public Method.i GetColType()  {
      ProcedureReturn This\colType
    }
    Public Method SetColType(type_p.i)  {
      This\colType = type_p
    }

    Public Method.i GetAlign()  {
      ProcedureReturn This\align
    }
    Public Method SetAlign(align_p.i)  {
      This\align = align_p
    }

    Public Method.b IsSortable()  {
      ProcedureReturn This\isSortable
    }
    Public Method SetSortable(sort_p.b)  {
      This\isSortable = sort_p
    }

    Public Method.b IsEditable()  {
      ProcedureReturn This\isEditable
    }
    Public Method SetEditable(edit_p.b)  {
      This\isEditable = edit_p
    }

    Public Method.b IsResizable()  {
      ProcedureReturn This\isResizable
    }
    Public Method SetResizable(resize_p.b)  {
      This\isResizable = resize_p
    }

    Public Method.i GetSortOrder()  {
      ProcedureReturn This\sortOrder
    }
    Public Method SetSortOrder(order_p.i)  {
      This\sortOrder = order_p
    }

    Public Method.f GetImageSize()  {
      ProcedureReturn This\imageSize
    }
    Public Method SetImageSize(size_p.f)  {
      This\imageSize = size_p
    }

    Public Method.i GetDecimals()  {
      ProcedureReturn This\decimals
    }
    Public Method SetDecimals(dec_p.i)  {
      This\decimals = dec_p
    }

    Public Method.i GetGetter()  {
      ProcedureReturn This\*getter
    }
    Public Method SetGetter(*getter_p)  {
      This\*getter = *getter_p
    }

    Public Method.i GetSetter()  {
      ProcedureReturn This\*setter
    }
    Public Method SetSetter(*setter_p) {
      This\*setter = *setter_p
      If (*setter_p) : This\isEditable = #True : EndIf
    }

    ; Per-column action buttons (for #UI_TableCol_ActionButtons)
    Public Method AddButton(id_p.i, icon_p.i, text_p.s, tooltip_p.s) {
      AddElement(This\buttons())
      This\buttons()\id = id_p
      This\buttons()\icon = icon_p
      This\buttons()\text = text_p
      This\buttons()\callback = 0
      This\buttons()\tooltip = tooltip_p
      This\buttons()\tag = ""
    }

    Public Method AddButtonEx(id_p.i, icon_p.i, text_p.s, *callback_p, tooltip_p.s, tag_p.s) {
      AddElement(This\buttons())
      This\buttons()\id = id_p
      This\buttons()\icon = icon_p
      This\buttons()\text = text_p
      This\buttons()\callback = *callback_p
      This\buttons()\tooltip = tooltip_p
      This\buttons()\tag = tag_p
    }

    Public Method.i GetButtonCount()  {
      ProcedureReturn ListSize(This\buttons())
    }

    Public Method.i GetButtonId(index_p.i) {
      If (index_p >= 0 And index_p < ListSize(This\buttons()))
        SelectElement(This\buttons(), index_p)
        ProcedureReturn This\buttons()\id
      EndIf
      ProcedureReturn -1
    }

    Public Method.i GetButtonIcon(index_p.i) {
      If (index_p >= 0 And index_p < ListSize(This\buttons()))
        SelectElement(This\buttons(), index_p)
        ProcedureReturn This\buttons()\icon
      EndIf
      ProcedureReturn 0
    }

    Public Method.s GetButtonText(index_p.i) {
      If (index_p >= 0 And index_p < ListSize(This\buttons()))
        SelectElement(This\buttons(), index_p)
        ProcedureReturn This\buttons()\text
      EndIf
      ProcedureReturn ""
    }

    Public Method.i GetButtonCallback(index_p.i) {
      If (index_p >= 0 And index_p < ListSize(This\buttons()))
        SelectElement(This\buttons(), index_p)
        ProcedureReturn This\buttons()\callback
      EndIf
      ProcedureReturn 0
    }

    Public Method SetButtonLayout(index_p.i, x_p.i, y_p.i, w_p.i, h_p.i) {
      If (index_p >= 0 And index_p < ListSize(This\buttons()))
        SelectElement(This\buttons(), index_p)
        This\buttons()\x = x_p
        This\buttons()\y = y_p
        This\buttons()\w = w_p
        This\buttons()\h = h_p
      EndIf
    }

    Public Method.i HitTestButton(x_p.i, y_p.i) {
      ForEach This\buttons() {
        If (x_p >= This\buttons()\x And x_p <= This\buttons()\x + This\buttons()\w And y_p >= This\buttons()\y And y_p <= This\buttons()\y + This\buttons()\h)
          ProcedureReturn This\buttons()\id
        EndIf
      }
      ProcedureReturn -1
    }

    Public Method Free()  {
      ClearList(This\buttons())
    }
  }

  ; ==========================================================================
  ; Class: TableRow
  ; Represents a row item in UI::CanvasTable
  ; ==========================================================================
  Class TableRow {
    Protected id.i
    Protected tag.s
    Protected isSelected.b
    Protected isChecked.b
    Protected *dataContext     ; Pointer to user-defined record structure
    Protected icon.i
    Protected List cells.s()   ; Independent cell values

    Protected Method InitDefaults() {
      This\id = 0
      This\tag = ""
      This\isSelected = #False
      This\isChecked = #False
      This\*dataContext = 0
      This\icon = 0
    }

    Public Method Init()  {
      This\InitDefaults()
    }

    Public Method Init(*data_p) {
      This\InitDefaults()
      This\*dataContext = *data_p
    }

    Public Method.i GetId()  {
      ProcedureReturn This\id
    }
    Public Method SetId(id_p.i)  {
      This\id = id_p
    }

    Public Method.s GetTag()  {
      ProcedureReturn This\tag
    }
    Public Method SetTag(tag_p.s)  {
      This\tag = tag_p
    }

    Public Method.b IsSelected()  {
      ProcedureReturn This\isSelected
    }
    Public Method SetSelected(sel_p.b)  {
      This\isSelected = sel_p
    }

    Public Method.b IsChecked()  {
      ProcedureReturn This\isChecked
    }
    Public Method SetChecked(chk_p.b)  {
      This\isChecked = chk_p
    }

    Public Method.i GetDataContext()  {
      ProcedureReturn This\*dataContext
    }
    Public Method SetDataContext(*data_p)  {
      This\*dataContext = *data_p
    }

    Public Method.i GetIcon()  {
      ProcedureReturn This\icon
    }
    Public Method SetIcon(icon_p.i)  {
      This\icon = icon_p
    }

    Public Method.s GetCellText(colIdx_p.i) {
      If (colIdx_p >= 0 And colIdx_p < ListSize(This\cells()))
        SelectElement(This\cells(), colIdx_p)
        ProcedureReturn This\cells()
      EndIf
      ProcedureReturn ""
    }

    Public Method SetCellText(colIdx_p.i, val_p.s) {
      While (ListSize(This\cells()) <= colIdx_p)
        AddElement(This\cells())
        This\cells() = ""
      Wend
      SelectElement(This\cells(), colIdx_p)
      This\cells() = val_p
    }

    Public Method AddCell(val_p.s) {
      AddElement(This\cells())
      This\cells() = val_p
    }

    Public Method ClearCells()  {
      ClearList(This\cells())
    }

    Public Method Free()  {
      ClearList(This\cells())
    }
  }

  ; ==========================================================================
  ; Class: CanvasTable
  ; High-DPI Virtual Vector-Rendered Table / DataGrid
  ; ==========================================================================
  Class CanvasTable Extends CustomGadget {
    ; Column & Row Collections
    Protected List *columns.UI::TableColumn()
    Protected List *rows.UI::TableRow()

    ; Selection state
    Protected selectedRowIndex.i
    Protected selectedColIndex.i

    ; Hover state
    Protected hoveredRowIndex.i
    Protected hoveredColIndex.i
    Protected hoveredSplitterIndex.i   ; Column splitter index being hovered (-1 if none)
    Protected hoveredButtonId.i

    ; Resizing state
    Protected isResizingColumn.b
    Protected resizingColIndex.i
    Protected resizeStartX.i
    Protected resizeStartWidth.i

    ; Virtual Scrolling & Metrics
    Protected scrollX.i
    Protected scrollY.i
    Protected maxScrollX.i
    Protected maxScrollY.i
    Protected totalContentWidth.i
    Protected totalContentHeight.i
    Protected headerHeight.i
    Protected lineHeight.i
    Protected scrollbarSize.i

    ; Scrollbar Dragging state
    Protected isDraggingVThumb.b
    Protected dragStartY.i
    Protected dragStartScrollY.i
    Protected isDraggingHThumb.b
    Protected dragStartX.i
    Protected dragStartScrollX.i

    ; In-place Cell Editing
    Protected isEditing.b
    Protected editingRowIndex.i
    Protected editingColIndex.i
    Protected editGadgetId.i

    ; Table Options & Appearance
    Protected showHeader.b
    Protected showGridLines.b
    Protected showAlternatingColors.b
    Protected isMultiSelect.b
    Protected isFullRowSelect.b
    Protected isDarkMode.b

    ; Theme Palette
    Protected bgColor.i
    Protected fgColor.i
    Protected altRowBgColor.i
    Protected headerBgColor.i
    Protected headerFgColor.i
    Protected headerBorderColor.i
    Protected gridLineColor.i
    Protected hoverBgColor.i
    Protected selectBgColor.i
    Protected selectFgColor.i
    Protected checkColor.i
    Protected checkBgColor.i
    Protected scrollbarBgColor.i
    Protected scrollbarThumbColor.i
    Protected scrollbarThumbHoverColor.i

    ; Callbacks
    Protected *onSelectCallback
    Protected *onCellEditCallback
    Protected *onHeaderClickCallback
    Protected *onCheckCallback
    Protected *onButtonClickCallback

    ; --- Internal Defaults ---
    Protected Method InitDefaults() {
      This\selectedRowIndex = -1
      This\selectedColIndex = -1
      This\hoveredRowIndex = -1
      This\hoveredColIndex = -1
      This\hoveredSplitterIndex = -1
      This\hoveredButtonId = -1

      This\isResizingColumn = #False
      This\resizingColIndex = -1
      This\resizeStartX = 0
      This\resizeStartWidth = 0

      This\scrollX = 0
      This\scrollY = 0
      This\maxScrollX = 0
      This\maxScrollY = 0
      This\totalContentWidth = 0
      This\totalContentHeight = 0
      This\headerHeight = 32
      This\lineHeight = 28
      This\scrollbarSize = 10

      This\isDraggingVThumb = #False
      This\isDraggingHThumb = #False

      This\isEditing = #False
      This\editingRowIndex = -1
      This\editingColIndex = -1
      This\editGadgetId = 0

      This\showHeader = #True
      This\showGridLines = #True
      This\showAlternatingColors = #True
      This\isMultiSelect = #False
      This\isFullRowSelect = #True
      This\isDarkMode = #False

      This\*onSelectCallback = 0
      This\*onCellEditCallback = 0
      This\*onHeaderClickCallback = 0
      This\*onCheckCallback = 0
      This\*onButtonClickCallback = 0

      ; Default Modern Light Theme (Clean Tailwind / WinUI Style)
      This\bgColor = RGB(255, 255, 255)
      This\fgColor = RGB(17, 24, 39)
      This\altRowBgColor = RGB(249, 250, 251)
      This\headerBgColor = RGB(243, 244, 246)
      This\headerFgColor = RGB(55, 65, 81)
      This\headerBorderColor = RGB(229, 231, 235)
      This\gridLineColor = RGB(243, 244, 246)
      This\hoverBgColor = RGB(238, 242, 255)
      This\selectBgColor = RGB(224, 231, 255)
      This\selectFgColor = RGB(67, 56, 202)
      This\checkColor = RGB(79, 70, 229)
      This\checkBgColor = RGB(255, 255, 255)
      This\scrollbarBgColor = RGB(245, 245, 247)
      This\scrollbarThumbColor = RGB(209, 213, 219)
      This\scrollbarThumbHoverColor = RGB(156, 163, 175)
    }

    ; Constructor 1: Default dimensions
    Public Method Init() {
      Super\Init(400, 300)
      This\InitDefaults()
      This\Redraw()
    }

    ; Constructor 2: Custom dimensions
    Public Method Init(w_p.i, h_p.i) {
      Super\Init(w_p, h_p)
      This\InitDefaults()
      This\Redraw()
    }

    ; Constructor 3: Position and dimensions
    Public Method Init(x_p.i, y_p.i, w_p.i, h_p.i) {
      Super\Init(x_p, y_p, w_p, h_p)
      This\InitDefaults()
      This\Redraw()
    }

    ; Constructor 4: Position, dimensions and flags
    Public Method Init(x_p.i, y_p.i, w_p.i, h_p.i, flags_p.i) {
      Super\Init(x_p, y_p, w_p, h_p, flags_p)
      This\InitDefaults()
      This\Redraw()
    }

    ; --- Configuration & Options ---

    Public Method SetDarkMode(enable_p.b) {
      This\isDarkMode = enable_p
      If (enable_p) {
        This\bgColor = RGB(20, 20, 24)
        This\fgColor = RGB(226, 232, 240)
        This\altRowBgColor = RGB(26, 26, 32)
        This\headerBgColor = RGB(30, 30, 36)
        This\headerFgColor = RGB(203, 213, 225)
        This\headerBorderColor = RGB(45, 45, 55)
        This\gridLineColor = RGB(38, 38, 48)
        This\hoverBgColor = RGB(38, 38, 52)
        This\selectBgColor = RGB(49, 58, 92)
        This\selectFgColor = RGB(255, 255, 255)
        This\checkColor = RGB(99, 102, 241)
        This\checkBgColor = RGB(30, 30, 36)
        This\scrollbarBgColor = RGB(26, 26, 32)
        This\scrollbarThumbColor = RGB(70, 70, 85)
        This\scrollbarThumbHoverColor = RGB(100, 100, 120)
      } Else {
        This\bgColor = RGB(255, 255, 255)
        This\fgColor = RGB(17, 24, 39)
        This\altRowBgColor = RGB(249, 250, 251)
        This\headerBgColor = RGB(243, 244, 246)
        This\headerFgColor = RGB(55, 65, 81)
        This\headerBorderColor = RGB(229, 231, 235)
        This\gridLineColor = RGB(243, 244, 246)
        This\hoverBgColor = RGB(238, 242, 255)
        This\selectBgColor = RGB(224, 231, 255)
        This\selectFgColor = RGB(67, 56, 202)
        This\checkColor = RGB(79, 70, 229)
        This\checkBgColor = RGB(255, 255, 255)
        This\scrollbarBgColor = RGB(245, 245, 247)
        This\scrollbarThumbColor = RGB(209, 213, 219)
        This\scrollbarThumbHoverColor = RGB(156, 163, 175)
      }
      This\Redraw()
    }

    Public Method.b GetDarkMode()  {
      ProcedureReturn This\isDarkMode
    }

    Public Method SetShowHeader(show_p.b) {
      This\showHeader = show_p
      This\RecalculateScroll()
      This\Redraw()
    }

    Public Method.b GetShowHeader()  {
      ProcedureReturn This\showHeader
    }

    Public Method SetShowGridLines(show_p.b) {
      This\showGridLines = show_p
      This\Redraw()
    }

    Public Method.b GetShowGridLines()  {
      ProcedureReturn This\showGridLines
    }

    Public Method SetShowAlternatingColors(show_p.b) {
      This\showAlternatingColors = show_p
      This\Redraw()
    }

    Public Method.b GetShowAlternatingColors()  {
      ProcedureReturn This\showAlternatingColors
    }

    Public Method SetHeaderHeight(h_p.i) {
      If (h_p >= 20) {
        This\headerHeight = h_p
        This\RecalculateScroll()
        This\Redraw()
      }
    }

    Public Method.i GetHeaderHeight()  {
      ProcedureReturn This\headerHeight
    }

    Public Method SetLineHeight(h_p.i) {
      If (h_p >= 18) {
        This\lineHeight = h_p
        This\RecalculateScroll()
        This\Redraw()
      }
    }

    Public Method.i GetLineHeight()  {
      ProcedureReturn This\lineHeight
    }

    ; Callbacks
    Public Method SetOnSelect(*cb)  {
      This\*onSelectCallback = *cb
    }
    Public Method SetOnCellEdit(*cb)  {
      This\*onCellEditCallback = *cb
    }
    Public Method SetOnHeaderClick(*cb)  {
      This\*onHeaderClickCallback = *cb
    }
    Public Method SetOnCheck(*cb)  {
      This\*onCheckCallback = *cb
    }
    Public Method SetOnButtonClick(*cb)  {
      This\*onButtonClickCallback = *cb
    }

    ; --- Columns Management ---

    Public Method.i AddColumn(title_p.s, width_p.i, colType_p.i = #UI_TableCol_Text, align_p.i = #UI_TableAlign_Left) {
      Protected *col.UI::TableColumn = New UI::TableColumn(title_p, width_p, colType_p)
      *col\SetAlign(align_p)
      *col\SetId(ListSize(This\columns()))
      AddElement(This\columns())
      This\columns() = *col
      This\RecalculateScroll()
      This\Redraw()
      ProcedureReturn *col
    }

    Public Method.i GetColumnCount()  {
      ProcedureReturn ListSize(This\columns())
    }

    Public Method.i GetColumn(index_p.i) {
      If (index_p >= 0 And index_p < ListSize(This\columns()))
        SelectElement(This\columns(), index_p)
        ProcedureReturn This\columns()
      EndIf
      ProcedureReturn 0
    }

    Public Method ClearColumns() {
      ForEach This\columns() {
        Protected *c.UI::TableColumn = This\columns()
        If (*c) : *c\Free() : EndIf
      }
      ClearList(This\columns())
      This\RecalculateScroll()
      This\Redraw()
    }

    ; --- Rows & Data Management ---

    Public Method.i AddRow() {
      Protected *row.UI::TableRow = New UI::TableRow()
      *row\SetId(ListSize(This\rows()))
      AddElement(This\rows())
      This\rows() = *row
      This\RecalculateScroll()
      This\Redraw()
      ProcedureReturn *row
    }

    Public Method.i AddRowData(*dataContext_p) {
      Protected *row.UI::TableRow = New UI::TableRow(*dataContext_p)
      *row\SetId(ListSize(This\rows()))
      AddElement(This\rows())
      This\rows() = *row
      This\RecalculateScroll()
      This\Redraw()
      ProcedureReturn *row
    }

    Public Method.i AddRowCells(c0.s, c1.s = "", c2.s = "", c3.s = "", c4.s = "", c5.s = "", c6.s = "", c7.s = "") {
      Protected *row.UI::TableRow = New UI::TableRow()
      *row\SetId(ListSize(This\rows()))
      *row\AddCell(c0)
      If (c1 <> "") : *row\AddCell(c1) : EndIf
      If (c2 <> "") : *row\AddCell(c2) : EndIf
      If (c3 <> "") : *row\AddCell(c3) : EndIf
      If (c4 <> "") : *row\AddCell(c4) : EndIf
      If (c5 <> "") : *row\AddCell(c5) : EndIf
      If (c6 <> "") : *row\AddCell(c6) : EndIf
      If (c7 <> "") : *row\AddCell(c7) : EndIf
      AddElement(This\rows())
      This\rows() = *row
      This\RecalculateScroll()
      This\Redraw()
      ProcedureReturn *row
    }

    Public Method.i GetRowCount()  {
      ProcedureReturn ListSize(This\rows())
    }

    Public Method.i GetRow(index_p.i) {
      If (index_p >= 0 And index_p < ListSize(This\rows()))
        SelectElement(This\rows(), index_p)
        ProcedureReturn This\rows()
      EndIf
      ProcedureReturn 0
    }

    Public Method RemoveRow(index_p.i) {
      If (index_p >= 0 And index_p < ListSize(This\rows()))
        SelectElement(This\rows(), index_p)
        Protected *r.UI::TableRow = This\rows()
        If (*r) : *r\Free() : EndIf
        DeleteElement(This\rows())
        If (This\selectedRowIndex >= ListSize(This\rows()))
          This\selectedRowIndex = ListSize(This\rows()) - 1
        EndIf
        This\RecalculateScroll()
        This\Redraw()
      EndIf
    }

    Public Method ClearRows() {
      This\CancelEdit()
      ForEach This\rows() {
        Protected *r.UI::TableRow = This\rows()
        If (*r) : *r\Free() : EndIf
      }
      ClearList(This\rows())
      This\selectedRowIndex = -1
      This\scrollY = 0
      This\RecalculateScroll()
      This\Redraw()
    }

    Public Method ClearAll() {
      This\ClearRows()
      This\ClearColumns()
    }

    ; --- Selection Management ---

    Public Method.i GetSelectedIndex()  {
      ProcedureReturn This\selectedRowIndex
    }

    Public Method SetSelectedIndex(index_p.i) {
      If (index_p < 0 Or index_p >= ListSize(This\rows()))
        index_p = -1
      EndIf

      ; Deselect previous
      If (This\selectedRowIndex >= 0 And This\selectedRowIndex < ListSize(This\rows()))
        SelectElement(This\rows(), This\selectedRowIndex)
        This\rows()\SetSelected(#False)
      EndIf

      This\selectedRowIndex = index_p

      ; Select new
      If (This\selectedRowIndex >= 0)
        SelectElement(This\rows(), This\selectedRowIndex)
        This\rows()\SetSelected(#True)
        This\EnsureRowVisible(This\selectedRowIndex)
        If (This\*onSelectCallback)
          Protected *cbSelect = This\*onSelectCallback
          CallFunctionFast(*cbSelect, This\rows())
        EndIf
      EndIf

      This\Redraw()
    }

    Public Method.i GetSelectedRow() {
      If (This\selectedRowIndex >= 0 And This\selectedRowIndex < ListSize(This\rows()))
        SelectElement(This\rows(), This\selectedRowIndex)
        ProcedureReturn This\rows()
      EndIf
      ProcedureReturn 0
    }

    ; --- Value Retrieval Helper (Dual Mode: Getter Callback or Direct Cell) ---

    Public Method.s GetCellValue(*row.UI::TableRow, colIdx_p.i) {
      If Not *row : ProcedureReturn "" : EndIf
      Protected *col.UI::TableColumn = This\GetColumn(colIdx_p)
      If Not *col : ProcedureReturn "" : EndIf

      ; 1. Direct Getter callback if registered on column (PB_TABLE compatibility)
      If (*col\GetGetter() And *row\GetDataContext())
        Protected *fnGet = *col\GetGetter()
        Select *col\GetColType()
          Case #UI_TableCol_Number:
            Protected valL.i = CallFunctionFast(*fnGet, *row\GetDataContext())
            ProcedureReturn Str(valL)

          Case #UI_TableCol_Float:
            CallFunctionFast(*fnGet, *row\GetDataContext())
            Protected valF.f
            !movss [p.v_valF], xmm0
            ProcedureReturn StrF(valF, *col\GetDecimals())

          Case #UI_TableCol_Double:
            CallFunctionFast(*fnGet, *row\GetDataContext())
            Protected valD.d
            !movsd [p.v_valD], xmm0
            ProcedureReturn StrD(valD, *col\GetDecimals())

          Case #UI_TableCol_Image:
            Protected imgVal.i = CallFunctionFast(*fnGet, *row\GetDataContext())
            ProcedureReturn Str(imgVal)

          Case #UI_TableCol_CheckBox:
            Protected chkVal.i = CallFunctionFast(*fnGet, *row\GetDataContext())
            ProcedureReturn Str(chkVal)

          Default:
            Protected *strPtr = CallFunctionFast(*fnGet, *row\GetDataContext())
            If (*strPtr) : ProcedureReturn PeekS(*strPtr) : EndIf
            ProcedureReturn ""
        EndSelect
      EndIf

      ; 2. Fallback to row cell storage
      Protected cellTxt.s = *row\GetCellText(colIdx_p)
      If (cellTxt <> "")
        ProcedureReturn cellTxt
      EndIf

      If (*col\GetColType() = #UI_TableCol_CheckBox)
        ProcedureReturn Str(*row\IsChecked())
      ElseIf (*col\GetColType() = #UI_TableCol_Image And *row\GetIcon() > 0)
        ProcedureReturn Str(*row\GetIcon())
      EndIf

      ProcedureReturn ""
    }

    Public Method SetCellValue(*row.UI::TableRow, colIdx_p.i, value_p.s) {
      If Not *row : ProcedureReturn : EndIf
      Protected *col.UI::TableColumn = This\GetColumn(colIdx_p)
      If Not *col : ProcedureReturn : EndIf

      ; 1. Direct Setter callback if registered on column
      If (*col\GetSetter() And *row\GetDataContext())
        Protected *fnSet = *col\GetSetter()
        Select *col\GetColType()
          Case #UI_TableCol_Number:
            CallFunctionFast(*fnSet, *row\GetDataContext(), Val(value_p))

          Case #UI_TableCol_Float:
            Protected setValF.f = ValF(value_p)
            !movss xmm1, [p.v_setValF]
            CallFunctionFast(*fnSet, *row\GetDataContext(), 0)

          Case #UI_TableCol_Double:
            Protected setValD.d = ValD(value_p)
            !movsd xmm1, [p.v_setValD]
            CallFunctionFast(*fnSet, *row\GetDataContext(), 0)

          Case #UI_TableCol_CheckBox:
            CallFunctionFast(*fnSet, *row\GetDataContext(), Val(value_p))

          Default:
            CallFunctionFast(*fnSet, *row\GetDataContext(), @value_p)
        EndSelect
      EndIf

      ; 2. Store in row cells
      If (*col\GetColType() = #UI_TableCol_CheckBox)
        *row\SetChecked(Bool(Val(value_p) <> 0))
      Else
        *row\SetCellText(colIdx_p, value_p)
      EndIf
    }

    ; --- Virtual Scrolling Calculations ---

    Protected Method RecalculateScroll() {
      ; Total content width (scaled)
      Protected tw.i = 0
      ForEach This\columns() {
        tw + DesktopScaledX(This\columns()\GetWidth())
      }
      This\totalContentWidth = tw

      ; Total content height (scaled)
      Protected scaledLineH.i = DesktopScaledY(This\lineHeight)
      If (scaledLineH <= 0) : scaledLineH = 1 : EndIf
      This\totalContentHeight = ListSize(This\rows()) * scaledLineH

      Protected scaledHdrH.i = 0
      If (This\showHeader)
        scaledHdrH = DesktopScaledY(This\headerHeight)
      EndIf
      Protected scaledBarW.i = DesktopScaledX(This\scrollbarSize)

      Protected viewW.i = This\width
      Protected viewH.i = This\height - scaledHdrH
      If (viewW <= 0) : viewW = 400 : EndIf
      If (viewH <= 0) : viewH = 300 : EndIf

      If (This\totalContentHeight > viewH)
        viewW - scaledBarW
      EndIf
      If (This\totalContentWidth > viewW)
        viewH - scaledBarW
      EndIf
      If (viewW <= 0) : viewW = 100 : EndIf
      If (viewH <= 0) : viewH = 100 : EndIf

      ; Max vertical scroll
      If (This\totalContentHeight > viewH)
        This\maxScrollY = This\totalContentHeight - viewH
      Else
        This\maxScrollY = 0
        This\scrollY = 0
      EndIf
      If (This\scrollY > This\maxScrollY) : This\scrollY = This\maxScrollY : EndIf
      If (This\scrollY < 0) : This\scrollY = 0 : EndIf

      ; Max horizontal scroll
      If (This\totalContentWidth > viewW)
        This\maxScrollX = This\totalContentWidth - viewW
      Else
        This\maxScrollX = 0
        This\scrollX = 0
      EndIf
      If (This\scrollX > This\maxScrollX) : This\scrollX = This\maxScrollX : EndIf
      If (This\scrollX < 0) : This\scrollX = 0 : EndIf
    }

    Public Method EnsureRowVisible(rowIdx_p.i) {
      If (rowIdx_p < 0 Or rowIdx_p >= ListSize(This\rows())) : ProcedureReturn : EndIf
      Protected scaledLineH.i = DesktopScaledY(This\lineHeight)
      Protected rowY.i = rowIdx_p * scaledLineH

      Protected scaledHdrH.i = 0
      If (This\showHeader) : scaledHdrH = DesktopScaledY(This\headerHeight) : EndIf
      Protected viewH.i = This\height - scaledHdrH

      If (rowY < This\scrollY)
        This\scrollY = rowY
      ElseIf (rowY + scaledLineH > This\scrollY + viewH)
        This\scrollY = (rowY + scaledLineH) - viewH
      EndIf
      If (This\scrollY > This\maxScrollY) : This\scrollY = This\maxScrollY : EndIf
      If (This\scrollY < 0) : This\scrollY = 0 : EndIf
    }

    ; --- Column Sorting ---

    Public Method SortByColumn(colIdx_p.i) {
      Protected *col.UI::TableColumn = This\GetColumn(colIdx_p)
      If Not *col : ProcedureReturn : EndIf
      If Not *col\IsSortable() : ProcedureReturn : EndIf

      ; Toggle sort order: None -> Asc -> Desc -> Asc
      Protected newOrder.i = #UI_TableSort_Asc
      If (*col\GetSortOrder() = #UI_TableSort_Asc)
        newOrder = #UI_TableSort_Desc
      ElseIf (*col\GetSortOrder() = #UI_TableSort_Desc)
        newOrder = #UI_TableSort_Asc
      EndIf

      ; Reset other columns sort order
      ForEach This\columns() {
        This\columns()\SetSortOrder(#UI_TableSort_None)
      }
      *col\SetSortOrder(newOrder)

      ; Perform fast in-memory sort on rows
      Protected nRows.i = ListSize(This\rows())
      If (nRows > 1)
        ; Sort using array for optimal speed
        Structure SortItem
          *row.UI::TableRow
          strVal.s
          numVal.d
        EndStructure
        Dim sortArr.SortItem(nRows - 1)

        Protected idx.i = 0
        ForEach This\rows() {
          sortArr(idx)\row = This\rows()
          Protected rawVal.s = This\GetCellValue(This\rows(), colIdx_p)
          sortArr(idx)\strVal = rawVal
          If (*col\GetColType() = #UI_TableCol_Number Or *col\GetColType() = #UI_TableCol_Float Or *col\GetColType() = #UI_TableCol_Double)
            sortArr(idx)\numVal = ValD(rawVal)
          ElseIf (*col\GetColType() = #UI_TableCol_CheckBox)
            sortArr(idx)\numVal = Val(rawVal)
          EndIf
          idx + 1
        }

        ; In-place sort on array
        Protected i.i, j.i
        For i = 0 To nRows - 2
          For j = i + 1 To nRows - 1
            Protected mustSwap.b = #False
            If (*col\GetColType() = #UI_TableCol_Number Or *col\GetColType() = #UI_TableCol_Float Or *col\GetColType() = #UI_TableCol_Double Or *col\GetColType() = #UI_TableCol_CheckBox)
              If (newOrder = #UI_TableSort_Asc)
                If (sortArr(i)\numVal > sortArr(j)\numVal) : mustSwap = #True : EndIf
              Else
                If (sortArr(i)\numVal < sortArr(j)\numVal) : mustSwap = #True : EndIf
              EndIf
            Else
              If (newOrder = #UI_TableSort_Asc)
                If (UCase(sortArr(i)\strVal) > UCase(sortArr(j)\strVal)) : mustSwap = #True : EndIf
              Else
                If (UCase(sortArr(i)\strVal) < UCase(sortArr(j)\strVal)) : mustSwap = #True : EndIf
              EndIf
            EndIf

            If (mustSwap)
              Protected tmpR.SortItem
              tmpR\row = sortArr(i)\row
              tmpR\strVal = sortArr(i)\strVal
              tmpR\numVal = sortArr(i)\numVal

              sortArr(i)\row = sortArr(j)\row
              sortArr(i)\strVal = sortArr(j)\strVal
              sortArr(i)\numVal = sortArr(j)\numVal

              sortArr(j)\row = tmpR\row
              sortArr(j)\strVal = tmpR\strVal
              sortArr(j)\numVal = tmpR\numVal
            EndIf
          Next
        Next

        ; Rebuild linked list from sorted array
        ClearList(This\rows())
        For i = 0 To nRows - 1
          AddElement(This\rows())
          This\rows() = sortArr(i)\row
        Next
        FreeArray(sortArr())
      EndIf

      If (This\*onHeaderClickCallback)
        Protected *cbHdr = This\*onHeaderClickCallback
        CallFunctionFast(*cbHdr, *col, newOrder)
      EndIf

      This\Redraw()
    }

    ; --- In-Place Cell Editing Implementation ---

    Public Method StartEdit(rowIdx_p.i, colIdx_p.i) {
      If (rowIdx_p < 0 Or rowIdx_p >= ListSize(This\rows())) : ProcedureReturn : EndIf
      If (colIdx_p < 0 Or colIdx_p >= ListSize(This\columns())) : ProcedureReturn : EndIf

      Protected *col.UI::TableColumn = This\GetColumn(colIdx_p)
      If Not *col : ProcedureReturn : EndIf
      If Not *col\IsEditable() : ProcedureReturn : EndIf

      Protected *row.UI::TableRow = This\GetRow(rowIdx_p)
      If Not *row : ProcedureReturn : EndIf

      ; If already editing, commit previous
      If (This\isEditing)
        This\CommitEdit()
      EndIf

      ; Special case: CheckBox toggles immediately without popup editor
      If (*col\GetColType() = #UI_TableCol_CheckBox)
        Protected curVal.b = *row\IsChecked()
        Protected newVal.b = Bool(Not curVal)
        This\SetCellValue(*row, colIdx_p, Str(newVal))
        If (This\*onCheckCallback)
          Protected *cbCheck = This\*onCheckCallback
          CallFunctionFast(*cbCheck, *row, newVal)
        EndIf
        This\Redraw()
        ProcedureReturn
      EndIf

      ; Calculate cell screen position
      Protected scaledHdrH.i = 0
      If (This\showHeader) : scaledHdrH = DesktopScaledY(This\headerHeight) : EndIf
      Protected scaledLineH.i = DesktopScaledY(This\lineHeight)

      ; Find column X
      Protected colX.i = 0
      Protected i.i
      For i = 0 To colIdx_p - 1
        colX + DesktopScaledX(This\columns()\GetWidth())
      Next
      colX - This\scrollX

      Protected colW.i = DesktopScaledX(*col\GetWidth())
      Protected cellY.i = scaledHdrH + (rowIdx_p * scaledLineH) - This\scrollY

      ; Check if visible
      If (cellY < scaledHdrH Or cellY + scaledLineH > This\height Or colX + colW < 0 Or colX > This\width)
        ProcedureReturn
      EndIf

      ; Global window position of canvas gadget
      Protected gx.i = GadgetX(This\id) + colX
      Protected gy.i = GadgetY(This\id) + cellY

      This\editingRowIndex = rowIdx_p
      This\editingColIndex = colIdx_p
      This\isEditing = #True

      Protected initialText.s = This\GetCellValue(*row, colIdx_p)

      ; Create overlay StringGadget
      This\editGadgetId = StringGadget(#PB_Any, gx, gy, colW, scaledLineH, initialText)
      If (This\editGadgetId)
        SetActiveGadget(This\editGadgetId)
        ; Set font matching canvas if set
        If (This\fontID)
          SetGadgetFont(This\editGadgetId, This\fontID)
        EndIf
      EndIf
    }

    Public Method CommitEdit() {
      If (This\isEditing And This\editGadgetId And IsGadget(This\editGadgetId))
        Protected newVal.s = GetGadgetText(This\editGadgetId)
        Protected *row.UI::TableRow = This\GetRow(This\editingRowIndex)
        If (*row)
          This\SetCellValue(*row, This\editingColIndex, newVal)
          If (This\*onCellEditCallback)
            Protected *cbEdit = This\*onCellEditCallback
            CallFunctionFast(*cbEdit, *row, This\editingColIndex, @newVal)
          EndIf
        EndIf
        FreeGadget(This\editGadgetId)
        This\editGadgetId = 0
        This\isEditing = #False
        This\Redraw()
      EndIf
    }

    Public Method CancelEdit() {
      If (This\isEditing And This\editGadgetId And IsGadget(This\editGadgetId))
        FreeGadget(This\editGadgetId)
        This\editGadgetId = 0
        This\isEditing = #False
        This\Redraw()
      EndIf
    }

    ; --- High-Performance 2D Vector Rendering (OnPaint) ---

    Public Method OnPaint(w_p.i, h_p.i) {
      Protected scaledHdrH.i = 0
      If (This\showHeader)
        scaledHdrH = DesktopScaledY(This\headerHeight)
      EndIf
      Protected scaledLineH.i = DesktopScaledY(This\lineHeight)
      Protected scaledBarW.i = DesktopScaledX(This\scrollbarSize)

      ; 1. Clear background
      Box(0, 0, w_p, h_p, This\bgColor)

      ; Available viewport dimensions
      Protected availW.i = w_p
      If (This\totalContentHeight > h_p - scaledHdrH)
        availW - scaledBarW
      EndIf
      Protected availH.i = h_p
      If (This\totalContentWidth > w_p)
        availH - scaledBarW
      EndIf

      ; 2. Render Data Rows (Virtual Viewport with Clipping)
      Protected contentH.i = availH - scaledHdrH
      If (contentH > 0 And availW > 0)
        ClipOutput(0, scaledHdrH, availW, contentH)

        Protected firstVisibleRow.i = This\scrollY / scaledLineH
        If (firstVisibleRow < 0) : firstVisibleRow = 0 : EndIf
        Protected lastVisibleRow.i = (This\scrollY + contentH) / scaledLineH + 1
        If (lastVisibleRow >= ListSize(This\rows()))
          lastVisibleRow = ListSize(This\rows()) - 1
        EndIf

        Protected rowIdx.i
        For rowIdx = firstVisibleRow To lastVisibleRow
          SelectElement(This\rows(), rowIdx)
          Protected *row.UI::TableRow = This\rows()
          Protected rowY.i = scaledHdrH + (rowIdx * scaledLineH) - This\scrollY

          ; 2.1 Row Background (Selected, Hovered, Alternating or Normal)
          Protected curRowBg.i = This\bgColor
          Protected curRowFg.i = This\fgColor

          If (*row\IsSelected())
            curRowBg = This\selectBgColor
            curRowFg = This\selectFgColor
          ElseIf (rowIdx = This\hoveredRowIndex)
            curRowBg = This\hoverBgColor
          ElseIf (This\showAlternatingColors And (rowIdx % 2 = 1))
            curRowBg = This\altRowBgColor
          EndIf

          Box(0, rowY, availW, scaledLineH, curRowBg)

          ; 2.2 Row Cells
          Protected colX.i = 0 - This\scrollX
          Protected colIdx.i = 0
          ForEach This\columns() {
            Protected *col.UI::TableColumn = This\columns()
            Protected colW.i = DesktopScaledX(*col\GetWidth())

            ; Draw cell only if within horizontal viewport
            If (colX + colW > 0 And colX < availW)
              Protected cellPadX.i = DesktopScaledX(8)
              Protected midCellY.i = rowY + (scaledLineH / 2)

              Select (*col\GetColType())
                Case #UI_TableCol_CheckBox:
                  ; Draw modern vector checkbox
                  Protected chkSize.i = DesktopScaledX(16)
                  Protected chkX.i = colX + (colW - chkSize) / 2
                  Protected chkY.i = midCellY - (chkSize / 2)

                  RoundBox(chkX, chkY, chkSize, chkSize, 3, 3, This\headerBorderColor)
                  RoundBox(chkX + 1, chkY + 1, chkSize - 2, chkSize - 2, 2, 2, This\checkBgColor)

                  Protected isChecked.b = Bool(Val(This\GetCellValue(*row, colIdx)) <> 0)
                  If (isChecked)
                    RoundBox(chkX + 2, chkY + 2, chkSize - 4, chkSize - 4, 2, 2, This\checkColor)
                    ; White checkmark
                    Protected ckMidX.i = chkX + (chkSize / 2) - 1
                    Protected ckMidY.i = chkY + chkSize - 4
                    LineXY(chkX + 3, midCellY, ckMidX, ckMidY, RGB(255, 255, 255))
                    LineXY(ckMidX, ckMidY, chkX + chkSize - 4, chkY + 4, RGB(255, 255, 255))
                    LineXY(chkX + 3, midCellY - 1, ckMidX, ckMidY - 1, RGB(255, 255, 255))
                    LineXY(ckMidX, ckMidY - 1, chkX + chkSize - 4, chkY + 3, RGB(255, 255, 255))
                  EndIf

                Case #UI_TableCol_Image:
                  ; Draw image / icon
                  Protected imgVal.i = Val(This\GetCellValue(*row, colIdx))
                  If (imgVal > 0 And IsImage(imgVal))
                    Protected imgSize.i = scaledLineH * *col\GetImageSize()
                    Protected imgX.i = colX + (colW - imgSize) / 2
                    Protected imgY.i = midCellY - (imgSize / 2)
                    DrawingMode(#PB_2DDrawing_AlphaBlend)
                    DrawImage(ImageID(imgVal), imgX, imgY, imgSize, imgSize)
                    DrawingMode(#PB_2DDrawing_Default)
                  EndIf

                Case #UI_TableCol_ActionButtons:
                  ; Draw per-column action buttons
                  Protected btnCount.i = *col\GetButtonCount()
                  If (btnCount > 0)
                    Protected btnSize.i = DesktopScaledX(22)
                    Protected totalBtnsW.i = btnCount * (btnSize + DesktopScaledX(4))
                    Protected startBtnX.i = colX + (colW - totalBtnsW) / 2
                    Protected bIdx.i
                    For bIdx = 0 To btnCount - 1
                      Protected curBtnX.i = startBtnX + bIdx * (btnSize + DesktopScaledX(4))
                      Protected curBtnY.i = midCellY - (btnSize / 2)
                      *col\SetButtonLayout(bIdx, curBtnX, curBtnY, btnSize, btnSize)

                      Protected bIco.i = *col\GetButtonIcon(bIdx)
                      Protected bId.i = *col\GetButtonId(bIdx)
                      Protected bTxt.s = *col\GetButtonText(bIdx)

                      ; Modern button styling
                      Protected bBg.i = RGB(241, 245, 249)
                      Protected bFg.i = RGB(71, 85, 105)
                      Protected bBrd.i = RGB(203, 213, 225)
                      If (This\isDarkMode)
                        bBg = RGB(51, 65, 85)
                        bFg = RGB(226, 232, 240)
                        bBrd = RGB(71, 85, 105)
                      EndIf
                      If (rowIdx = This\hoveredRowIndex And This\hoveredButtonId = bId)
                        bBg = RGB(224, 231, 255)
                        bFg = RGB(67, 56, 202)
                        bBrd = RGB(99, 102, 241)
                      EndIf

                      RoundBox(curBtnX, curBtnY, btnSize, btnSize, 4, 4, bBrd)
                      RoundBox(curBtnX + 1, curBtnY + 1, btnSize - 2, btnSize - 2, 3, 3, bBg)

                      If (bIco > 0 And IsImage(bIco))
                        DrawingMode(#PB_2DDrawing_AlphaBlend)
                        DrawImage(ImageID(bIco), curBtnX + 2, curBtnY + 2, btnSize - 4, btnSize - 4)
                        DrawingMode(#PB_2DDrawing_Default)
                      ElseIf (bTxt <> "")
                        DrawingMode(#PB_2DDrawing_Transparent)
                        Protected charTxt.s = Left(bTxt, 1)
                        Protected bTw.i = TextWidth(charTxt)
                        Protected bTh.i = TextHeight(charTxt)
                        DrawText(curBtnX + (btnSize - bTw) / 2, curBtnY + (btnSize - bTh) / 2, charTxt, bFg)
                        DrawingMode(#PB_2DDrawing_Default)
                      EndIf
                    Next
                  EndIf

                Default:
                  ; Text & Number columns
                  Protected cellText.s = This\GetCellValue(*row, colIdx)
                  If (cellText <> "")
                    DrawingMode(#PB_2DDrawing_Transparent)
                    If (This\fontID) : DrawingFont(This\fontID) : EndIf

                    Protected txtW.i = TextWidth(cellText)
                    Protected txtH.i = TextHeight(cellText)
                    Protected txtY.i = rowY + (scaledLineH - txtH) / 2
                    Protected txtX.i = colX + cellPadX

                    Select (*col\GetAlign())
                      Case #UI_TableAlign_Center:
                        txtX = colX + (colW - txtW) / 2
                      Case #UI_TableAlign_Right:
                        txtX = colX + colW - txtW - cellPadX
                    EndSelect

                    ; Clip long text with ellipsis
                    Protected maxAllowedW.i = colW - (cellPadX * 2)
                    If (txtW > maxAllowedW And maxAllowedW > 10)
                      Protected truncText.s = cellText
                      While (TextWidth(truncText + "...") > maxAllowedW And Len(truncText) > 1)
                        truncText = Left(truncText, Len(truncText) - 1)
                      Wend
                      truncText + "..."
                      DrawText(colX + cellPadX, txtY, truncText, curRowFg)
                    Else
                      DrawText(txtX, txtY, cellText, curRowFg)
                    EndIf

                    DrawingMode(#PB_2DDrawing_Default)
                  EndIf
              EndSelect

              ; Cell vertical grid line
              If (This\showGridLines)
                LineXY(colX + colW - 1, rowY, colX + colW - 1, rowY + scaledLineH, This\gridLineColor)
              EndIf
            EndIf

            colX + colW
            colIdx + 1
          }

          ; Row bottom separator
          If (This\showGridLines)
            LineXY(0, rowY + scaledLineH - 1, availW, rowY + scaledLineH - 1, This\gridLineColor)
          EndIf
        Next

        UnclipOutput()
      EndIf

      ; 3. Render Header (with Clipping & Fixed on top)
      If (This\showHeader And scaledHdrH > 0)
        ClipOutput(0, 0, availW, scaledHdrH)

        ; Header Background & Border
        Box(0, 0, availW, scaledHdrH, This\headerBgColor)
        LineXY(0, scaledHdrH - 1, availW, scaledHdrH - 1, This\headerBorderColor)

        Protected hColX.i = 0 - This\scrollX
        Protected hColIdx.i = 0
        ForEach This\columns() {
          Protected *hCol.UI::TableColumn = This\columns()
          Protected hColW.i = DesktopScaledX(*hCol\GetWidth())

          If (hColX + hColW > 0 And hColX < availW)
            ; Header Title Text
            DrawingMode(#PB_2DDrawing_Transparent)
            If (This\fontID) : DrawingFont(This\fontID) : EndIf

            Protected hTitle.s = *hCol\GetTitle()
            Protected hTxtW.i = TextWidth(hTitle)
            Protected hTxtH.i = TextHeight(hTitle)
            Protected hTxtY.i = (scaledHdrH - hTxtH) / 2
            Protected hTxtX.i = hColX + DesktopScaledX(8)

            Select (*hCol\GetAlign())
              Case #UI_TableAlign_Center:
                hTxtX = hColX + (hColW - hTxtW) / 2
              Case #UI_TableAlign_Right:
                hTxtX = hColX + hColW - hTxtW - DesktopScaledX(8)
            EndSelect

            DrawText(hTxtX, hTxtY, hTitle, This\headerFgColor)

            ; Sort Chevron Indicator (▲ / ▼)
            If (*hCol\GetSortOrder() <> #UI_TableSort_None)
              Protected chevX.i = hColX + hColW - DesktopScaledX(16)
              Protected chevMidY.i = scaledHdrH / 2
              Protected chevSize.i = DesktopScaledX(4)

              If (*hCol\GetSortOrder() = #UI_TableSort_Asc)
                ; Up Arrow (▲)
                LineXY(chevX - chevSize, chevMidY + chevSize, chevX, chevMidY - chevSize, This\selectFgColor)
                LineXY(chevX, chevMidY - chevSize, chevX + chevSize, chevMidY + chevSize, This\selectFgColor)
                LineXY(chevX - chevSize, chevMidY + chevSize, chevX + chevSize, chevMidY + chevSize, This\selectFgColor)
              Else
                ; Down Arrow (▼)
                LineXY(chevX - chevSize, chevMidY - chevSize, chevX, chevMidY + chevSize, This\selectFgColor)
                LineXY(chevX, chevMidY + chevSize, chevX + chevSize, chevMidY - chevSize, This\selectFgColor)
                LineXY(chevX - chevSize, chevMidY - chevSize, chevX + chevSize, chevMidY - chevSize, This\selectFgColor)
              EndIf
            EndIf

            DrawingMode(#PB_2DDrawing_Default)

            ; Header column separator line
            LineXY(hColX + hColW - 1, 4, hColX + hColW - 1, scaledHdrH - 5, This\headerBorderColor)
          EndIf

          hColX + hColW
          hColIdx + 1
        }

        UnclipOutput()
      EndIf

      ; 4. Render Virtual Scrollbars
      ; 4.1 Vertical Scrollbar
      If (This\totalContentHeight > availH - scaledHdrH And This\totalContentHeight > 0)
        Protected vBarX.i = w_p - scaledBarW
        Protected vBarY.i = scaledHdrH
        Protected vBarH.i = availH - scaledHdrH
        Box(vBarX, vBarY, scaledBarW, vBarH, This\scrollbarBgColor)

        Protected vThumbH.i = DesktopScaledY(20)
        If (This\totalContentHeight > 0)
          vThumbH = (vBarH * vBarH) / This\totalContentHeight
        EndIf
        If (vThumbH < DesktopScaledY(20)) : vThumbH = DesktopScaledY(20) : EndIf
        Protected vThumbY.i = vBarY
        If (This\maxScrollY > 0)
          vThumbY + ((vBarH - vThumbH) * This\scrollY) / This\maxScrollY
        EndIf

        Protected curVThumbCol.i = This\scrollbarThumbColor
        If (This\isDraggingVThumb) : curVThumbCol = This\scrollbarThumbHoverColor : EndIf
        RoundBox(vBarX + 2, vThumbY, scaledBarW - 4, vThumbH, 3, 3, curVThumbCol)
      EndIf

      ; 4.2 Horizontal Scrollbar
      If (This\totalContentWidth > availW And This\totalContentWidth > 0)
        Protected hBarX.i = 0
        Protected hBarY.i = h_p - scaledBarW
        Protected hBarW.i = availW
        Box(hBarX, hBarY, hBarW, scaledBarW, This\scrollbarBgColor)

        Protected hThumbW.i = DesktopScaledX(20)
        If (This\totalContentWidth > 0)
          hThumbW = (hBarW * hBarW) / This\totalContentWidth
        EndIf
        If (hThumbW < DesktopScaledX(20)) : hThumbW = DesktopScaledX(20) : EndIf
        Protected hThumbX.i = hBarX
        If (This\maxScrollX > 0)
          hThumbX + ((hBarW - hThumbW) * This\scrollX) / This\maxScrollX
        EndIf

        Protected curHThumbCol.i = This\scrollbarThumbColor
        If (This\isDraggingHThumb) : curHThumbCol = This\scrollbarThumbHoverColor : EndIf
        RoundBox(hThumbX, hBarY + 2, hThumbW, scaledBarW - 4, 3, 3, curHThumbCol)
      EndIf

      ; 4.3 Corner Box (if both scrollbars active)
      If (This\totalContentHeight > availH - scaledHdrH And This\totalContentWidth > availW)
        Box(w_p - scaledBarW, h_p - scaledBarW, scaledBarW, scaledBarW, This\scrollbarBgColor)
      EndIf
    }

    ; --- Mouse & Keyboard Event Handlers ---

    Public Method OnMouseMove(mx_p.i, my_p.i) {

      Protected scaledHdrH.i = 0
      If (This\showHeader) : scaledHdrH = DesktopScaledY(This\headerHeight) : EndIf
      Protected scaledLineH.i = DesktopScaledY(This\lineHeight)
      If (scaledLineH <= 0) : scaledLineH = 1 : EndIf
      Protected scaledBarW.i = DesktopScaledX(This\scrollbarSize)

      ; 1. Dragging Vertical Scrollbar Thumb
      If (This\isDraggingVThumb)
        Protected vBarH.i = This\height - scaledHdrH
        Protected vThumbH.i = DesktopScaledY(20)
        If (This\totalContentHeight > 0)
          vThumbH = (vBarH * vBarH) / This\totalContentHeight
        EndIf
        If (vThumbH < DesktopScaledY(20)) : vThumbH = DesktopScaledY(20) : EndIf
        Protected travelH.i = vBarH - vThumbH
        If (travelH > 0 And This\maxScrollY > 0)
          Protected deltaY.i = my_p - This\dragStartY
          This\scrollY = This\dragStartScrollY + (deltaY * This\maxScrollY) / travelH
          If (This\scrollY < 0) : This\scrollY = 0 : EndIf
          If (This\scrollY > This\maxScrollY) : This\scrollY = This\maxScrollY : EndIf
          This\Redraw()
        EndIf
        ProcedureReturn
      EndIf

      ; 2. Dragging Horizontal Scrollbar Thumb
      If (This\isDraggingHThumb)
        Protected hBarW.i = This\width
        If (This\totalContentHeight > This\height - scaledHdrH) : hBarW - scaledBarW : EndIf
        Protected hThumbW.i = DesktopScaledX(20)
        If (This\totalContentWidth > 0)
          hThumbW = (hBarW * hBarW) / This\totalContentWidth
        EndIf
        If (hThumbW < DesktopScaledX(20)) : hThumbW = DesktopScaledX(20) : EndIf
        Protected travelW.i = hBarW - hThumbW
        If (travelW > 0 And This\maxScrollX > 0)
          Protected deltaX.i = mx_p - This\dragStartX
          This\scrollX = This\dragStartScrollX + (deltaX * This\maxScrollX) / travelW
          If (This\scrollX < 0) : This\scrollX = 0 : EndIf
          If (This\scrollX > This\maxScrollX) : This\scrollX = This\maxScrollX : EndIf
          This\Redraw()
        EndIf
        ProcedureReturn
      EndIf

      ; 3. Resizing Column Width (Live Drag)
      If (This\isResizingColumn And This\resizingColIndex >= 0)
        Protected *resizeCol.UI::TableColumn = This\GetColumn(This\resizingColIndex)
        If (*resizeCol)
          Protected diffX.i = mx_p - This\resizeStartX
          Protected newWidth.i = DesktopUnscaledX(This\resizeStartWidth + diffX)
          If (newWidth < *resizeCol\GetMinWidth()) : newWidth = *resizeCol\GetMinWidth() : EndIf
          *resizeCol\SetWidth(newWidth)
          This\RecalculateScroll()
          This\Redraw()
        EndIf
        ProcedureReturn
      EndIf

      ; 4. Header Splitter Hover Detection
      This\hoveredSplitterIndex = -1
      If (This\showHeader And my_p <= scaledHdrH)
        Protected curX.i = 0 - This\scrollX
        Protected colIdx.i = 0
        ForEach This\columns() {
          Protected *c.UI::TableColumn = This\columns()
          Protected cW.i = DesktopScaledX(*c\GetWidth())
          Protected splitX.i = curX + cW

          ; Hit test within 4 pixels of column divider
          If (*c\IsResizable() And Abs(mx_p - splitX) <= DesktopScaledX(4))
            This\hoveredSplitterIndex = colIdx
            SetGadgetAttribute(This\id, #PB_Canvas_Cursor, #PB_Cursor_LeftRight)
            ProcedureReturn
          EndIf
          curX + cW
          colIdx + 1
        }
      EndIf

      SetGadgetAttribute(This\id, #PB_Canvas_Cursor, #PB_Cursor_Default)

      ; 5. Data Rows Hover Detection
      If (my_p > scaledHdrH And my_p < This\height)
        Protected rowHover.i = (my_p - scaledHdrH + This\scrollY) / scaledLineH
        If (rowHover >= 0 And rowHover < ListSize(This\rows()))
          If (This\hoveredRowIndex <> rowHover)
            This\hoveredRowIndex = rowHover
            This\Redraw()
          EndIf
        Else
          If (This\hoveredRowIndex <> -1)
            This\hoveredRowIndex = -1
            This\Redraw()
          EndIf
        EndIf
      Else
        If (This\hoveredRowIndex <> -1)
          This\hoveredRowIndex = -1
          This\Redraw()
        EndIf
      EndIf
    }

    Public Method OnMouseDown(mx_p.i, my_p.i, button_p.i) {
      If (button_p <> #PB_Canvas_LeftButton) : ProcedureReturn : EndIf

      Protected scaledHdrH.i = 0
      If (This\showHeader) : scaledHdrH = DesktopScaledY(This\headerHeight) : EndIf
      Protected scaledLineH.i = DesktopScaledY(This\lineHeight)
      Protected scaledBarW.i = DesktopScaledX(This\scrollbarSize)

      ; 1. Check Vertical Scrollbar click
      If (This\totalContentHeight > This\height - scaledHdrH And mx_p >= This\width - scaledBarW)
        This\isDraggingVThumb = #True
        This\dragStartY = my_p
        This\dragStartScrollY = This\scrollY
        ProcedureReturn
      EndIf

      ; 2. Check Horizontal Scrollbar click
      If (This\totalContentWidth > This\width And my_p >= This\height - scaledBarW)
        This\isDraggingHThumb = #True
        This\dragStartX = mx_p
        This\dragStartScrollX = This\scrollX
        ProcedureReturn
      EndIf

      ; 3. Check Header Click (Column Resize or Sort)
      If (This\showHeader And my_p <= scaledHdrH)
        ; Check if resizing divider
        If (This\hoveredSplitterIndex >= 0)
          This\isResizingColumn = #True
          This\resizingColIndex = This\hoveredSplitterIndex
          This\resizeStartX = mx_p
          Protected *rCol.UI::TableColumn = This\GetColumn(This\resizingColIndex)
          If (*rCol) : This\resizeStartWidth = DesktopScaledX(*rCol\GetWidth()) : EndIf
          ProcedureReturn
        EndIf

        ; Header column sort click
        Protected hX.i = 0 - This\scrollX
        Protected hIdx.i = 0
        ForEach This\columns() {
          Protected *col.UI::TableColumn = This\columns()
          Protected cW.i = DesktopScaledX(*col\GetWidth())
          If (mx_p >= hX And mx_p < hX + cW)
            This\SortByColumn(hIdx)
            ProcedureReturn
          EndIf
          hX + cW
          hIdx + 1
        }
        ProcedureReturn
      EndIf

      ; 4. Check Data Row Click
      If (my_p > scaledHdrH)
        Protected clickedRow.i = (my_p - scaledHdrH + This\scrollY) / scaledLineH
        If (clickedRow >= 0 And clickedRow < ListSize(This\rows()))
          ; Find clicked column
          Protected cX.i = 0 - This\scrollX
          Protected clickedCol.i = -1
          Protected colI.i = 0
          ForEach This\columns() {
            Protected *cCol.UI::TableColumn = This\columns()
            Protected colWidth.i = DesktopScaledX(*cCol\GetWidth())
            If (mx_p >= cX And mx_p < cX + colWidth)
              clickedCol = colI
              Break
            EndIf
            cX + colWidth
            colI + 1
          }

          ; Check if CheckBox column was clicked -> Toggle immediately
          If (clickedCol >= 0)
            Protected *targetCol.UI::TableColumn = This\GetColumn(clickedCol)
            If (*targetCol And *targetCol\GetColType() = #UI_TableCol_CheckBox)
              This\SetSelectedIndex(clickedRow)
              This\StartEdit(clickedRow, clickedCol)
              ProcedureReturn
            EndIf

            ; Check if Action Button was clicked
            If (*targetCol And *targetCol\GetColType() = #UI_TableCol_ActionButtons)
              Protected btnId.i = *targetCol\HitTestButton(mx_p, my_p)
              If (btnId >= 0)
                SelectElement(This\rows(), clickedRow)
                If (This\*onButtonClickCallback)
                  Protected *cbBtn = This\*onButtonClickCallback
                  CallFunctionFast(*cbBtn, This\rows(), btnId)
                EndIf
                ProcedureReturn
              EndIf
            EndIf
          EndIf

          ; Standard Row Selection
          This\SetSelectedIndex(clickedRow)
        EndIf
      EndIf
    }

    Public Method OnMouseUp(mx_p.i, my_p.i, button_p.i) {
      If (This\isDraggingVThumb)
        This\isDraggingVThumb = #False
        This\Redraw()
      EndIf
      If (This\isDraggingHThumb)
        This\isDraggingHThumb = #False
        This\Redraw()
      EndIf
      If (This\isResizingColumn)
        This\isResizingColumn = #False
        This\resizingColIndex = -1
        This\Redraw()
      EndIf
    }

    Public Method OnMouseWheel(delta_p.i) {
      Protected scaledLineH.i = DesktopScaledY(This\lineHeight)
      ; 3 lines per notch
      This\scrollY - (delta_p * scaledLineH * 3)
      If (This\scrollY < 0) : This\scrollY = 0 : EndIf
      If (This\scrollY > This\maxScrollY) : This\scrollY = This\maxScrollY : EndIf
      This\Redraw()
    }

    Public Method OnKeyDown(key_p.i) {
      Select (key_p)
        Case #PB_Shortcut_Up:
          If (This\selectedRowIndex > 0)
            This\SetSelectedIndex(This\selectedRowIndex - 1)
          EndIf
        Case #PB_Shortcut_Down:
          If (This\selectedRowIndex < ListSize(This\rows()) - 1)
            This\SetSelectedIndex(This\selectedRowIndex + 1)
          EndIf
        Case #PB_Shortcut_PageUp:
          Protected scaledLineH.i = DesktopScaledY(This\lineHeight)
          Protected pageCount.i = This\height / scaledLineH
          Protected newPgUp.i = This\selectedRowIndex - pageCount
          If (newPgUp < 0) : newPgUp = 0 : EndIf
          This\SetSelectedIndex(newPgUp)
        Case #PB_Shortcut_PageDown:
          Protected pageCnt.i = This\height / DesktopScaledY(This\lineHeight)
          Protected newPgDn.i = This\selectedRowIndex + pageCnt
          If (newPgDn >= ListSize(This\rows())) : newPgDn = ListSize(This\rows()) - 1 : EndIf
          This\SetSelectedIndex(newPgDn)
        Case #PB_Shortcut_Home:
          If (ListSize(This\rows()) > 0) : This\SetSelectedIndex(0) : EndIf
        Case #PB_Shortcut_End:
          If (ListSize(This\rows()) > 0) : This\SetSelectedIndex(ListSize(This\rows()) - 1) : EndIf
        Case #PB_Shortcut_Return:
          ; Trigger in-place edit on first editable column of selected row
          If (This\selectedRowIndex >= 0)
            Protected colIdx.i = 0
            ForEach This\columns() {
              If (This\columns()\IsEditable())
                This\StartEdit(This\selectedRowIndex, colIdx)
                Break
              EndIf
              colIdx + 1
            }
          EndIf
        Case #PB_Shortcut_Escape:
          This\CancelEdit()
      EndSelect
    }

    Public Method OnMouseLeave() {
      This\hoveredRowIndex = -1
      This\hoveredSplitterIndex = -1
      SetGadgetAttribute(This\id, #PB_Canvas_Cursor, #PB_Cursor_Default)
      This\Redraw()
    }

    Public Method Free() {
      This\CancelEdit()
      This\ClearAll()
      Super\Free()
    }
  }

}
