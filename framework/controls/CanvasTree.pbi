; ============================================================================
; PureBasic OOP GUI Framework - CanvasTree.pbi
; Modern DPI-Aware Canvas-rendered Hierarchical TreeView Control
; Features: Multi-level hierarchy, Vector chevrons, CheckBoxes, Node icons,
;           Custom per-node Action Buttons with callbacks, Virtual Scrolling,
;           Smooth Wheel/Drag Scrollbar, Theme support (Light/Dark), Keyboard Nav.
; Author:      MicrodevWeb
; ============================================================================

XIncludeFile "../CustomGadget.pbi"

; ----------------------------------------------------------------------------
; Data structures for Node Action Buttons
; ----------------------------------------------------------------------------
Structure UI_TreeNodeButton
  id.i
  icon.i
  *callback
  tooltip.s
  tag.s
  x.i
  y.i
  size.i
EndStructure

Namespace UI {

  ; ==========================================================================
  ; Class: TreeNode
  ; Represents a hierarchical item in UI::CanvasTree
  ; ==========================================================================
  Class TreeNode {
    Protected text.s
    Protected tag.s
    Protected dataContext.i
    Protected icon.i
    Protected isExpanded.b
    Protected isChecked.b
    Protected isSelected.b
    Protected hasCheckBox.b
    Protected *parent.UI::TreeNode
    Protected List *children.UI::TreeNode()
    Protected List buttons.UI_TreeNodeButton()

    ; Cached layout coordinates for fast hit-testing during render
    Protected renderY.i
    Protected renderH.i
    Protected level.i
    Protected expandX.i
    Protected expandY.i
    Protected expandSize.i
    Protected checkX.i
    Protected checkY.i
    Protected checkSize.i
    Protected rowW.i

    ; Constructor 1: Default
    Public Method Init() {
      This\text = ""
      This\icon = 0
      This\tag = ""
      This\dataContext = 0
      This\isExpanded = #False
      This\isChecked = #False
      This\isSelected = #False
      This\hasCheckBox = #False
      This\*parent = 0
    }

    ; Constructor 2: Text only
    Public Method Init(text_p.s) {
      This\text = text_p
      This\icon = 0
      This\tag = ""
      This\dataContext = 0
      This\isExpanded = #False
      This\isChecked = #False
      This\isSelected = #False
      This\hasCheckBox = #False
      This\*parent = 0
    }

    ; Constructor 3: Text and Icon
    Public Method Init(text_p.s, icon_p.i) {
      This\text = text_p
      This\icon = icon_p
      This\tag = ""
      This\dataContext = 0
      This\isExpanded = #False
      This\isChecked = #False
      This\isSelected = #False
      This\hasCheckBox = #False
      This\*parent = 0
    }

    ; Constructor 4: Text, Icon and Tag
    Public Method Init(text_p.s, icon_p.i, tag_p.s) {
      This\text = text_p
      This\icon = icon_p
      This\tag = tag_p
      This\dataContext = 0
      This\isExpanded = #False
      This\isChecked = #False
      This\isSelected = #False
      This\hasCheckBox = #False
      This\*parent = 0
    }

    ; --- Getters / Setters ---

    Public Method.s GetText() {
      ProcedureReturn This\text
    }

    Public Method SetText(text_p.s) {
      This\text = text_p
    }

    Public Method.s GetTag() {
      ProcedureReturn This\tag
    }

    Public Method SetTag(tag_p.s) {
      This\tag = tag_p
    }

    Public Method.i GetIcon() {
      ProcedureReturn This\icon
    }

    Public Method SetIcon(icon_p.i) {
      This\icon = icon_p
    }

    Public Method.i GetDataContext() {
      ProcedureReturn This\dataContext
    }

    Public Method SetDataContext(data_p.i) {
      This\dataContext = data_p
    }

    Public Method.b IsExpanded() {
      ProcedureReturn This\isExpanded
    }

    Public Method SetExpanded(state_p.b) {
      This\isExpanded = state_p
    }

    Public Method.b IsChecked() {
      ProcedureReturn This\isChecked
    }

    Public Method SetChecked(state_p.b) {
      This\isChecked = state_p
    }

    Public Method.b IsSelected() {
      ProcedureReturn This\isSelected
    }

    Public Method SetSelected(state_p.b) {
      This\isSelected = state_p
    }

    Public Method.b HasCheckBox() {
      ProcedureReturn This\hasCheckBox
    }

    Public Method SetHasCheckBox(state_p.b) {
      This\hasCheckBox = state_p
    }

    Public Method.i GetParent() {
      ProcedureReturn This\*parent
    }

    Public Method SetParent(*parent_p.UI::TreeNode) {
      This\*parent = *parent_p
    }

    ; --- Child elements management ---

    Public Method AddChild(*child_p.UI::TreeNode) {
      If (*child_p) {
        *child_p\SetParent(This)
        AddElement(This\children())
        This\children() = *child_p
      }
    }

    Public Method RemoveChild(*child_p.UI::TreeNode) {
      If (*child_p) {
        ForEach This\children() {
          If (This\children() = *child_p) {
            DeleteElement(This\children())
            Break
          }
        }
      }
    }

    Public Method.i GetChildCount() {
      ProcedureReturn ListSize(This\children())
    }

    Public Method.i GetChild(index_p.i) {
      If (index_p >= 0 And index_p < ListSize(This\children())) {
        SelectElement(This\children(), index_p)
        ProcedureReturn This\children()
      }
      ProcedureReturn 0
    }

    ; --- Per-node action buttons ---

    Public Method AddButton(id_p.i, icon_p.i, *callback_p, tooltip_p.s, tag_p.s) {
      AddElement(This\buttons())
      This\buttons()\id = id_p
      This\buttons()\icon = icon_p
      This\buttons()\callback = *callback_p
      This\buttons()\tooltip = tooltip_p
      This\buttons()\tag = tag_p
    }

    Public Method.i GetButtonCount() {
      ProcedureReturn ListSize(This\buttons())
    }

    Public Method SetButtonPos(index_p.i, x_p.i, y_p.i, size_p.i) {
      If (index_p >= 0 And index_p < ListSize(This\buttons())) {
        SelectElement(This\buttons(), index_p)
        This\buttons()\x = x_p
        This\buttons()\y = y_p
        This\buttons()\size = size_p
      }
    }

    Public Method.i GetButtonId(index_p.i) {
      If (index_p >= 0 And index_p < ListSize(This\buttons())) {
        SelectElement(This\buttons(), index_p)
        ProcedureReturn This\buttons()\id
      }
      ProcedureReturn -1
    }

    Public Method.i GetButtonIcon(index_p.i) {
      If (index_p >= 0 And index_p < ListSize(This\buttons())) {
        SelectElement(This\buttons(), index_p)
        ProcedureReturn This\buttons()\icon
      }
      ProcedureReturn 0
    }

    Public Method.i GetButtonCallback(index_p.i) {
      If (index_p >= 0 And index_p < ListSize(This\buttons())) {
        SelectElement(This\buttons(), index_p)
        ProcedureReturn This\buttons()\callback
      }
      ProcedureReturn 0
    }

    ; --- Layout Cache & Hit Testing ---

    Public Method SetRenderLayout(y_p.i, h_p.i, w_p.i, level_p.i, expX_p.i, expY_p.i, expSize_p.i, chkX_p.i, chkY_p.i, chkSize_p.i) {
      This\renderY = y_p
      This\renderH = h_p
      This\rowW = w_p
      This\level = level_p
      This\expandX = expX_p
      This\expandY = expY_p
      This\expandSize = expSize_p
      This\checkX = chkX_p
      This\checkY = chkY_p
      This\checkSize = chkSize_p
    }

    Public Method.i GetRenderY() {
      ProcedureReturn This\renderY
    }

    Public Method.i GetRenderH() {
      ProcedureReturn This\renderH
    }

    Public Method.b HitTestExpand(x_p.i, y_p.i) {
      If (This\expandSize > 0 And x_p >= This\expandX And x_p <= This\expandX + This\expandSize And y_p >= This\expandY And y_p <= This\expandY + This\expandSize) {
        ProcedureReturn #True
      }
      ProcedureReturn #False
    }

    Public Method.b HitTestCheck(x_p.i, y_p.i) {
      If (This\checkSize > 0 And x_p >= This\checkX And x_p <= This\checkX + This\checkSize And y_p >= This\checkY And y_p <= This\checkY + This\checkSize) {
        ProcedureReturn #True
      }
      ProcedureReturn #False
    }

    Public Method.i HitTestButton(x_p.i, y_p.i) {
      ForEach This\buttons() {
        If (x_p >= This\buttons()\x And x_p <= This\buttons()\x + This\buttons()\size And y_p >= This\buttons()\y And y_p <= This\buttons()\y + This\buttons()\size) {
          ProcedureReturn This\buttons()\id
        }
      }
      ProcedureReturn -1
    }

    ; --- Recursive expand / collapse ---

    Public Method ExpandAll() {
      This\isExpanded = #True
      ForEach This\children() {
        Protected *c.UI::TreeNode = This\children()
        If (*c) {
          *c\ExpandAll()
        }
      }
    }

    Public Method CollapseAll() {
      This\isExpanded = #False
      ForEach This\children() {
        Protected *c.UI::TreeNode = This\children()
        If (*c) {
          *c\CollapseAll()
        }
      }
    }

    ; --- Recursive memory teardown ---
    Public Method Free() {
      ForEach This\children() {
        Protected *c.UI::TreeNode = This\children()
        If (*c) {
          *c\Free()
        }
      }
      ClearList(This\children())
      ClearList(This\buttons())
    }
  }

  ; ==========================================================================
  ; Class: CanvasTree
  ; High-DPI Virtual Canvas TreeView Gadget
  ; ==========================================================================
  Class CanvasTree Extends CustomGadget {
    Protected *rootNode.UI::TreeNode
    Protected *selectedNode.UI::TreeNode
    Protected *hoveredNode.UI::TreeNode
    Protected hoveredElementType.i ; 0: None, 1: Expand, 2: CheckBox, 3: Icon, 4: Row/Text, 5: Button
    Protected hoveredButtonId.i
    Protected showCheckBoxes.b
    Protected showLines.b
    Protected lineHeight.i
    Protected indentWidth.i
    Protected scrollY.i
    Protected maxScrollY.i
    Protected totalContentHeight.i
    Protected isDraggingThumb.b
    Protected dragStartY.i
    Protected dragStartScrollY.i

    ; Theme colors
    Protected bgColor.i
    Protected fgColor.i
    Protected lineColor.i
    Protected selectBgColor.i
    Protected selectFgColor.i
    Protected hoverBgColor.i
    Protected chevronColor.i
    Protected checkColor.i
    Protected checkBgColor.i
    Protected scrollbarBgColor.i
    Protected scrollbarThumbColor.i

    ; Callbacks
    Protected *onSelectCallback
    Protected *onExpandCallback
    Protected *onCheckCallback
    Protected *onButtonClickCallback

    ; Flat list of visible nodes for fast virtual rendering & keyboard nav
    Protected List *visibleNodes.UI::TreeNode()

    ; --- Internal constructor helper ---
    Protected Method InitDefaults() {
      This\*rootNode = New UI::TreeNode("ROOT")
      This\*selectedNode = 0
      This\*hoveredNode = 0
      This\hoveredElementType = 0
      This\hoveredButtonId = -1
      This\showCheckBoxes = #False
      This\showLines = #True
      This\lineHeight = 26
      This\indentWidth = 20
      This\scrollY = 0
      This\maxScrollY = 0
      This\totalContentHeight = 0
      This\isDraggingThumb = #False
      This\*onSelectCallback = 0
      This\*onExpandCallback = 0
      This\*onCheckCallback = 0
      This\*onButtonClickCallback = 0

      ; Default modern light theme
      This\bgColor = RGB(255, 255, 255)
      This\fgColor = RGB(33, 37, 41)
      This\lineColor = RGB(225, 228, 232)
      This\selectBgColor = RGB(204, 232, 255)
      This\selectFgColor = RGB(0, 102, 204)
      This\hoverBgColor = RGB(242, 246, 250)
      This\chevronColor = RGB(110, 118, 129)
      This\checkColor = RGB(0, 120, 215)
      This\checkBgColor = RGB(255, 255, 255)
      This\scrollbarBgColor = RGB(245, 245, 247)
      This\scrollbarThumbColor = RGB(190, 192, 196)
    }

    ; Constructor 1: Default dimensions (250x300)
    Public Method Init() {
      Super\Init(250, 300)
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

    ; --- Configuration & Proprietes ---

    Public Method.i GetRoot() {
      ProcedureReturn This\*rootNode
    }

    Public Method.i GetSelectedNode() {
      ProcedureReturn This\*selectedNode
    }

    Public Method SetSelectedNode(*node_p.UI::TreeNode) {
      If (This\*selectedNode) {
        This\*selectedNode\SetSelected(#False)
      }
      This\*selectedNode = *node_p
      If (This\*selectedNode) {
        This\*selectedNode\SetSelected(#True)
      }
      This\Redraw()
    }

    Public Method SetShowCheckBoxes(show_p.b) {
      This\showCheckBoxes = show_p
      This\Redraw()
    }

    Public Method.b GetShowCheckBoxes() {
      ProcedureReturn This\showCheckBoxes
    }

    Public Method SetShowLines(show_p.b) {
      This\showLines = show_p
      This\Redraw()
    }

    Public Method.b GetShowLines() {
      ProcedureReturn This\showLines
    }

    Public Method SetLineHeight(h_p.i) {
      If (h_p > 10) {
        This\lineHeight = h_p
        This\RebuildVisibleList()
        This\Redraw()
      }
    }

    Public Method.i GetLineHeight() {
      ProcedureReturn This\lineHeight
    }

    Public Method SetIndentWidth(w_p.i) {
      If (w_p > 4) {
        This\indentWidth = w_p
        This\Redraw()
      }
    }

    Public Method SetFont(fontId_p.i) {
      This\fontID = fontId_p
      This\Redraw()
    }

    Public Method SetDarkMode(enable_p.b) {
      If (enable_p) {
        This\bgColor = RGB(30, 30, 32)
        This\fgColor = RGB(220, 220, 225)
        This\lineColor = RGB(55, 58, 64)
        This\selectBgColor = RGB(14, 99, 156)
        This\selectFgColor = RGB(255, 255, 255)
        This\hoverBgColor = RGB(45, 48, 54)
        This\chevronColor = RGB(160, 165, 175)
        This\checkColor = RGB(0, 122, 204)
        This\checkBgColor = RGB(40, 42, 46)
        This\scrollbarBgColor = RGB(35, 35, 38)
        This\scrollbarThumbColor = RGB(75, 78, 85)
      } Else {
        This\bgColor = RGB(255, 255, 255)
        This\fgColor = RGB(33, 37, 41)
        This\lineColor = RGB(225, 228, 232)
        This\selectBgColor = RGB(204, 232, 255)
        This\selectFgColor = RGB(0, 102, 204)
        This\hoverBgColor = RGB(242, 246, 250)
        This\chevronColor = RGB(110, 118, 129)
        This\checkColor = RGB(0, 120, 215)
        This\checkBgColor = RGB(255, 255, 255)
        This\scrollbarBgColor = RGB(245, 245, 247)
        This\scrollbarThumbColor = RGB(190, 192, 196)
      }
      This\Redraw()
    }

    Public Method SetColors(bg_p.i, fg_p.i, selBg_p.i, selFg_p.i, line_p.i) {
      This\bgColor = bg_p
      This\fgColor = fg_p
      This\selectBgColor = selBg_p
      This\selectFgColor = selFg_p
      This\lineColor = line_p
      This\Redraw()
    }

    ; Callbacks
    Public Method SetOnSelect(*callback_p) {
      This\*onSelectCallback = *callback_p
    }

    Public Method SetOnExpand(*callback_p) {
      This\*onExpandCallback = *callback_p
    }

    Public Method SetOnCheck(*callback_p) {
      This\*onCheckCallback = *callback_p
    }

    Public Method SetOnButtonClick(*callback_p) {
      This\*onButtonClickCallback = *callback_p
    }

    Public Method.i AddNode(*parent_p.UI::TreeNode, text_p.s, icon_p.i, tag_p.s) {
      Protected *targetParent.UI::TreeNode = *parent_p
      If (*targetParent = 0) {
        *targetParent = This\*rootNode
      }
      Protected *node.UI::TreeNode = New UI::TreeNode(text_p, icon_p, tag_p)
      *targetParent\AddChild(*node)
      This\RebuildVisibleList()
      This\Redraw()
      ProcedureReturn *node
    }

    Public Method Clear() {
      If (This\*rootNode) {
        This\*rootNode\Free()
        This\*rootNode = New UI::TreeNode("ROOT")
      }
      This\*selectedNode = 0
      This\*hoveredNode = 0
      This\scrollY = 0
      This\RebuildVisibleList()
      This\Redraw()
    }

    Public Method ExpandAll() {
      If (This\*rootNode) {
        This\*rootNode\ExpandAll()
        This\RebuildVisibleList()
        This\Redraw()
      }
    }

    Public Method CollapseAll() {
      If (This\*rootNode) {
        This\*rootNode\CollapseAll()
        This\RebuildVisibleList()
        This\Redraw()
      }
    }

    ; --- Build flat virtual list ---

    Protected Method PopulateFlatList(*parent_p.UI::TreeNode) {
      If Not *parent_p : ProcedureReturn : EndIf
      Protected i.i, count.i = *parent_p\GetChildCount()
      For i = 0 To count - 1
        Protected *child.UI::TreeNode = *parent_p\GetChild(i)
        If (*child) {
          AddElement(This\visibleNodes())
          This\visibleNodes() = *child
          If (*child\IsExpanded() And *child\GetChildCount() > 0) {
            This\PopulateFlatList(*child)
          }
        }
      Next
    }

    Public Method RebuildVisibleList() {
      ClearList(This\visibleNodes())
      This\PopulateFlatList(This\*rootNode)

      Protected scaledLineH.i = DesktopScaledY(This\lineHeight)
      This\totalContentHeight = ListSize(This\visibleNodes()) * scaledLineH

      Protected visibleH.i = This\height
      If (visibleH <= 0) : visibleH = 300 : EndIf
      If (This\totalContentHeight > visibleH) {
        This\maxScrollY = This\totalContentHeight - visibleH
      } Else {
        This\maxScrollY = 0
        This\scrollY = 0
      }
      If (This\scrollY > This\maxScrollY) {
        This\scrollY = This\maxScrollY
      }
      If (This\scrollY < 0) {
        This\scrollY = 0
      }
    }

    Public Method EnsureVisible(*node_p.UI::TreeNode) {
      If Not *node_p : ProcedureReturn : EndIf
      ; Make sure parents are expanded
      Protected *p.UI::TreeNode = *node_p\GetParent()
      While (*p And *p <> This\*rootNode)
        *p\SetExpanded(#True)
        *p = *p\GetParent()
      Wend
      This\RebuildVisibleList()

      ; Find node index in flat list
      Protected idx.i = 0, found.b = #False
      ForEach This\visibleNodes() {
        If (This\visibleNodes() = *node_p) {
          found = #True
          Break
        }
        idx + 1
      }

      If (found) {
        Protected scaledLineH.i = DesktopScaledY(This\lineHeight)
        Protected itemTop.i = idx * scaledLineH
        Protected itemBottom.i = itemTop + scaledLineH
        Protected visibleH.i = This\height

        If (itemTop < This\scrollY) {
          This\scrollY = itemTop
        } ElseIf (itemBottom > This\scrollY + visibleH) {
          This\scrollY = itemBottom - visibleH
        }
        This\Redraw()
      }
    }

    ; --- Rendu Graphique DPI-Aware (OnPaint) ---

    Public Method OnPaint(w.i, h.i) {
      ; DPI-scaled metrics
      Protected scaledLineH.i   = DesktopScaledY(This\lineHeight)
      Protected scaledIndent.i  = DesktopScaledX(This\indentWidth)
      Protected scaledChevron.i = DesktopScaledX(10)
      Protected scaledCheck.i   = DesktopScaledX(14)
      Protected scaledIcon.i    = DesktopScaledX(16)
      Protected scaledBtn.i     = DesktopScaledX(16)
      Protected scaledMargin.i  = DesktopScaledX(8)
      Protected scaledBarW.i    = DesktopScaledX(8)

      ; 1. Fond principal
      Box(0, 0, w, h, This\bgColor)

      If (This\fontID And IsFont(This\fontID)) {
        DrawingFont(FontID(This\fontID))
      }

      Protected currentY.i = -This\scrollY
      Protected availableRowW.i = w
      If (This\totalContentHeight > h) {
        availableRowW = w - scaledBarW - 2
      }

      ; 2. Render visible nodes
      ForEach This\visibleNodes() {
        Protected *node.UI::TreeNode = This\visibleNodes()
        If Not *node : Continue : EndIf

        ; Check visibility in vertical viewport
        If (currentY + scaledLineH >= 0 And currentY <= h) {
          ; Calculate hierarchy level
          Protected level.i = 0
          Protected *parentCheck.UI::TreeNode = *node\GetParent()
          While (*parentCheck And *parentCheck <> This\*rootNode)
            level + 1
            *parentCheck = *parentCheck\GetParent()
          Wend

          ; Node background (Selected or Hovered)
          Protected rowBg.i = This\bgColor
          Protected rowFg.i = This\fgColor
          If (*node\IsSelected()) {
            rowBg = This\selectBgColor
            rowFg = This\selectFgColor
            RoundBox(DesktopScaledX(2), currentY + 1, availableRowW - DesktopScaledX(4), scaledLineH - 2, 4, 4, rowBg)
          } ElseIf (*node = This\*hoveredNode And This\hoveredElementType = 4) {
            rowBg = This\hoverBgColor
            RoundBox(DesktopScaledX(2), currentY + 1, availableRowW - DesktopScaledX(4), scaledLineH - 2, 4, 4, rowBg)
          }

          Protected cursorX.i = scaledMargin + (level * scaledIndent)
          Protected midY.i = currentY + (scaledLineH / 2)

          ; 2.1 Lignes de liaison hierarchique (si activees)
          If (This\showLines And level > 0) {
            Protected lineStartX.i = cursorX - (scaledIndent / 2)
            LineXY(lineStartX, currentY, lineStartX, midY, This\lineColor)
            LineXY(lineStartX, midY, cursorX, midY, This\lineColor)
          }

          ; 2.2 Chevron d'expansion vectoriel (si enfants presents)
          Protected expX.i = 0, expY.i = 0, expSize.i = 0
          If (*node\GetChildCount() > 0) {
            expX = cursorX
            expY = midY - (scaledChevron / 2)
            expSize = scaledChevron

            Protected chevCol.i = This\chevronColor
            If (*node = This\*hoveredNode And This\hoveredElementType = 1) {
              chevCol = This\selectFgColor
            }

            Protected chRadius.i = scaledChevron / 2
            Protected chCenterX.i = cursorX + chRadius
            Protected chCenterY.i = midY

            If (*node\IsExpanded()) {
              ; Down chevron (v)
              LineXY(chCenterX - chRadius, chCenterY - (chRadius / 2), chCenterX, chCenterY + (chRadius / 2), chevCol)
              LineXY(chCenterX, chCenterY + (chRadius / 2), chCenterX + chRadius, chCenterY - (chRadius / 2), chevCol)
              ; Epaisseur vectorielle
              LineXY(chCenterX - chRadius, chCenterY - (chRadius / 2) + 1, chCenterX, chCenterY + (chRadius / 2) + 1, chevCol)
              LineXY(chCenterX, chCenterY + (chRadius / 2) + 1, chCenterX + chRadius, chCenterY - (chRadius / 2) + 1, chevCol)
            } Else {
              ; Right chevron (>)
              LineXY(chCenterX - (chRadius / 2), chCenterY - chRadius, chCenterX + (chRadius / 2), chCenterY, chevCol)
              LineXY(chCenterX + (chRadius / 2), chCenterY, chCenterX - (chRadius / 2), chCenterY + chRadius, chevCol)
              ; Epaisseur vectorielle
              LineXY(chCenterX - (chRadius / 2) + 1, chCenterY - chRadius, chCenterX + (chRadius / 2) + 1, chCenterY, chevCol)
              LineXY(chCenterX + (chRadius / 2) + 1, chCenterY, chCenterX - (chRadius / 2) + 1, chCenterY + chRadius, chevCol)
            }
          }
          cursorX + scaledChevron + DesktopScaledX(4)

          ; 2.3 Case a cocher (si globale ou specifique au noeud)
          Protected chkX.i = 0, chkY.i = 0, chkSize.i = 0
          If (This\showCheckBoxes Or *node\HasCheckBox()) {
            chkX = cursorX
            chkY = midY - (scaledCheck / 2)
            chkSize = scaledCheck

            ; Checkbox box
            RoundBox(cursorX, chkY, scaledCheck, scaledCheck, 3, 3, This\lineColor)
            RoundBox(cursorX + 1, chkY + 1, scaledCheck - 2, scaledCheck - 2, 2, 2, This\checkBgColor)

            If (*node\IsChecked()) {
              ; Remplissage accent
              RoundBox(cursorX + 2, chkY + 2, scaledCheck - 4, scaledCheck - 4, 2, 2, This\checkColor)
              ; Coche blanche
              Protected ckMidX.i = cursorX + (scaledCheck / 2) - 1
              Protected ckMidY.i = chkY + scaledCheck - 4
              LineXY(cursorX + 3, midY, ckMidX, ckMidY, RGB(255, 255, 255))
              LineXY(ckMidX, ckMidY, cursorX + scaledCheck - 3, chkY + 3, RGB(255, 255, 255))
              LineXY(cursorX + 3, midY - 1, ckMidX, ckMidY - 1, RGB(255, 255, 255))
              LineXY(ckMidX, ckMidY - 1, cursorX + scaledCheck - 3, chkY + 2, RGB(255, 255, 255))
            }
            cursorX + scaledCheck + DesktopScaledX(6)
          }

          ; 2.4 Node icon (if defined)
          If (*node\GetIcon() > 0 And IsImage(*node\GetIcon())) {
            Protected iconY.i = midY - (scaledIcon / 2)
            DrawingMode(#PB_2DDrawing_AlphaBlend)
            DrawImage(ImageID(*node\GetIcon()), cursorX, iconY, scaledIcon, scaledIcon)
            DrawingMode(#PB_2DDrawing_Default)
            cursorX + scaledIcon + DesktopScaledX(6)
          }

          ; 2.5 Node text
          Protected txtY.i = currentY + (scaledLineH - TextHeight(*node\GetText())) / 2
          DrawingMode(#PB_2DDrawing_Transparent)
          DrawText(cursorX, txtY, *node\GetText(), rowFg)
          DrawingMode(#PB_2DDrawing_Default)

          ; 2.6 Action buttons aligned to right of line
          Protected btnCount.i = *node\GetButtonCount()
          If (btnCount > 0) {
            Protected btnX.i = availableRowW - DesktopScaledX(6) - (btnCount * (scaledBtn + DesktopScaledX(4)))
            Protected bIdx.i
            For bIdx = 0 To btnCount - 1
              Protected btnY.i = midY - (scaledBtn / 2)
              *node\SetButtonPos(bIdx, btnX, btnY, scaledBtn)

              Protected bId.i = *node\GetButtonId(bIdx)
              Protected bIco.i = *node\GetButtonIcon(bIdx)

              ; Survol bouton
              If (*node = This\*hoveredNode And This\hoveredElementType = 5 And This\hoveredButtonId = bId) {
                RoundBox(btnX - 2, btnY - 2, scaledBtn + 4, scaledBtn + 4, 3, 3, This\lineColor)
              }

              If (bIco > 0 And IsImage(bIco)) {
                DrawingMode(#PB_2DDrawing_AlphaBlend)
                DrawImage(ImageID(bIco), btnX, btnY, scaledBtn, scaledBtn)
                DrawingMode(#PB_2DDrawing_Default)
              } Else {
                ; Default vector button (circle with dot)
                Circle(btnX + scaledBtn / 2, midY, scaledBtn / 2 - 1, This\chevronColor)
              }
              btnX + scaledBtn + DesktopScaledX(4)
            Next
          }

          ; Store render coordinates on node for hit-testing
          *node\SetRenderLayout(currentY, scaledLineH, availableRowW, level, expX, expY, expSize, chkX, chkY, chkSize)
        }
        currentY + scaledLineH
      }

      ; 3. Barre de defilement verticale virtuelle
      If (This\totalContentHeight > h) {
        Protected barX.i = w - scaledBarW
        Box(barX, 0, scaledBarW, h, This\scrollbarBgColor)

        Protected thumbH.i = (h * h) / This\totalContentHeight
        If (thumbH < DesktopScaledY(20)) : thumbH = DesktopScaledY(20) : EndIf
        Protected maxThumbY.i = h - thumbH
        Protected thumbY.i = 0
        If (This\maxScrollY > 0) {
          thumbY = (This\scrollY * maxThumbY) / This\maxScrollY
        }
        If (thumbY < 0) : thumbY = 0 : EndIf
        If (thumbY > maxThumbY) : thumbY = maxThumbY : EndIf

        Protected thumbCol.i = This\scrollbarThumbColor
        If (This\isDraggingThumb) {
          thumbCol = This\chevronColor
        }
        RoundBox(barX + 1, thumbY, scaledBarW - 2, thumbH, 3, 3, thumbCol)
      }
    }

    ; --- Mouse & Wheel Events Handling ---

    Public Method OnMouseDown(mx.i, my.i, button.i) {
      Protected scaledBarW.i = DesktopScaledX(8)
      Protected barX.i = This\width - scaledBarW

      ; Click on scrollbar
      If (This\totalContentHeight > This\height And mx >= barX) {
        This\isDraggingThumb = #True
        This\dragStartY = my
        This\dragStartScrollY = This\scrollY
        This\Redraw()
        ProcedureReturn
      }

      ; Determine clicked node
      Protected scaledLineH.i = DesktopScaledY(This\lineHeight)
      Protected clickedRow.i = (my + This\scrollY) / scaledLineH

      If (clickedRow >= 0 And clickedRow < ListSize(This\visibleNodes())) {
        SelectElement(This\visibleNodes(), clickedRow)
        Protected *node.UI::TreeNode = This\visibleNodes()

        If (*node) {
          ; 1. Click on expand chevron?
          If (*node\HitTestExpand(mx, my)) {
            *node\SetExpanded(1 - *node\IsExpanded())
            If (This\*onExpandCallback) {
              CallFunctionFast(This\*onExpandCallback, *node, *node\IsExpanded())
            }
            This\RebuildVisibleList()
            This\Redraw()
            ProcedureReturn
          }

          ; 2. Click on checkbox?
          If (*node\HitTestCheck(mx, my)) {
            *node\SetChecked(1 - *node\IsChecked())
            If (This\*onCheckCallback) {
              CallFunctionFast(This\*onCheckCallback, *node, *node\IsChecked())
            }
            This\Redraw()
            ProcedureReturn
          }

          ; 3. Click on action button?
          Protected hitBtnId.i = *node\HitTestButton(mx, my)
          If (hitBtnId >= 0) {
            Protected bIdx.i, count.i = *node\GetButtonCount()
            For bIdx = 0 To count - 1
              If (*node\GetButtonId(bIdx) = hitBtnId) {
                Protected *cb = *node\GetButtonCallback(bIdx)
                If (*cb) {
                  CallFunctionFast(*cb, *node, hitBtnId)
                }
                Break
              }
            Next
            If (This\*onButtonClickCallback) {
              CallFunctionFast(This\*onButtonClickCallback, *node, hitBtnId)
            }
            ProcedureReturn
          }

          ; 4. Click on node (Selection)
          This\SetSelectedNode(*node)
          If (This\*onSelectCallback) {
            CallFunctionFast(This\*onSelectCallback, *node)
          }
          This\Redraw()
        }
      }
    }

    Public Method OnMouseUp(mx.i, my.i, button.i) {
      If (This\isDraggingThumb) {
        This\isDraggingThumb = #False
        This\Redraw()
      }
    }

    Public Method OnMouseMove(mx.i, my.i) {
      ; Mouse wheel / scrollbar movement
      If (This\isDraggingThumb) {
        Protected deltaY.i = my - This\dragStartY
        Protected thumbH.i = (This\height * This\height) / This\totalContentHeight
        If (thumbH < DesktopScaledY(20)) : thumbH = DesktopScaledY(20) : EndIf
        Protected maxThumbY.i = This\height - thumbH
        If (maxThumbY > 0) {
          Protected scrollDelta.i = (deltaY * This\maxScrollY) / maxThumbY
          This\scrollY = This\dragStartScrollY + scrollDelta
          If (This\scrollY < 0) : This\scrollY = 0 : EndIf
          If (This\scrollY > This\maxScrollY) : This\scrollY = This\maxScrollY : EndIf
          This\Redraw()
        }
        ProcedureReturn
      }

      ; Hover detection
      Protected scaledLineH.i = DesktopScaledY(This\lineHeight)
      Protected rowIdx.i = (my + This\scrollY) / scaledLineH

      This\*hoveredNode = 0
      This\hoveredElementType = 0
      This\hoveredButtonId = -1

      If (rowIdx >= 0 And rowIdx < ListSize(This\visibleNodes())) {
        SelectElement(This\visibleNodes(), rowIdx)
        Protected *node.UI::TreeNode = This\visibleNodes()
        If (*node) {
          This\*hoveredNode = *node
          This\hoveredElementType = 4 ; Default row

          ; Chevron
          If (*node\HitTestExpand(mx, my)) {
            This\hoveredElementType = 1
          } ElseIf (*node\HitTestCheck(mx, my)) {
            This\hoveredElementType = 2
          } Else {
            Protected hBtn.i = *node\HitTestButton(mx, my)
            If (hBtn >= 0) {
              This\hoveredElementType = 5
              This\hoveredButtonId = hBtn
            }
          }
        }
      }
      This\Redraw()
    }

    Public Method OnMouseLeave() {
      This\*hoveredNode = 0
      This\hoveredElementType = 0
      This\hoveredButtonId = -1
      This\isDraggingThumb = #False
      This\Redraw()
    }

    Public Method OnMouseWheel(delta_p.i) {
      Protected stepSize.i = DesktopScaledY(This\lineHeight) * 2
      This\scrollY = This\scrollY - (delta_p * stepSize)
      If (This\scrollY < 0) : This\scrollY = 0 : EndIf
      If (This\scrollY > This\maxScrollY) : This\scrollY = This\maxScrollY : EndIf
      This\Redraw()
    }

    ; --- Navigation Clavier ---

    Public Method OnKeyDown(key_p.i) {
      Select (key_p) {
        Case #PB_Shortcut_Down:
          If (This\*selectedNode = 0) {
            If (FirstElement(This\visibleNodes())) {
              This\SetSelectedNode(This\visibleNodes())
              This\EnsureVisible(This\*selectedNode)
            }
          } Else {
            ForEach This\visibleNodes() {
              If (This\visibleNodes() = This\*selectedNode) {
                If (NextElement(This\visibleNodes())) {
                  This\SetSelectedNode(This\visibleNodes())
                  This\EnsureVisible(This\*selectedNode)
                }
                Break
              }
            }
          }

        Case #PB_Shortcut_Up:
          If (This\*selectedNode) {
            ForEach This\visibleNodes() {
              If (This\visibleNodes() = This\*selectedNode) {
                If (PreviousElement(This\visibleNodes())) {
                  This\SetSelectedNode(This\visibleNodes())
                  This\EnsureVisible(This\*selectedNode)
                }
                Break
              }
            }
          }

        Case #PB_Shortcut_Right:
          If (This\*selectedNode) {
            If (This\*selectedNode\GetChildCount() > 0 And Not This\*selectedNode\IsExpanded()) {
              This\*selectedNode\SetExpanded(#True)
              This\RebuildVisibleList()
              This\Redraw()
            }
          }

        Case #PB_Shortcut_Left:
          If (This\*selectedNode) {
            If (This\*selectedNode\IsExpanded() And This\*selectedNode\GetChildCount() > 0) {
              This\*selectedNode\SetExpanded(#False)
              This\RebuildVisibleList()
              This\Redraw()
            } ElseIf (This\*selectedNode\GetParent() And This\*selectedNode\GetParent() <> This\*rootNode) {
              This\SetSelectedNode(This\*selectedNode\GetParent())
              This\EnsureVisible(This\*selectedNode)
            }
          }

        Case #PB_Shortcut_Space:
          If (This\*selectedNode And (This\showCheckBoxes Or This\*selectedNode\HasCheckBox())) {
            This\*selectedNode\SetChecked(1 - This\*selectedNode\IsChecked())
            If (This\*onCheckCallback) {
              CallFunctionFast(This\*onCheckCallback, This\*selectedNode, This\*selectedNode\IsChecked())
            }
            This\Redraw()
          }
      }
    }

    ; --- Nettoyage ---

    Public Method Free() {
      If (This\*rootNode) {
        This\*rootNode\Free()
        This\*rootNode = 0
      }
      ClearList(This\visibleNodes())
      Super\Free()
    }
  }

}
