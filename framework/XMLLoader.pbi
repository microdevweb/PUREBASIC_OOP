; ============================================================================
; PureBasic OOP GUI Framework - XMLLoader.pbi
; Declarative XML / XAML Layout & View Loader for PureBasic OOP UI
; Author:      MicrodevWeb
; ============================================================================

XIncludeFile "Component.pbi"
XIncludeFile "Gadget.pbi"
XIncludeFile "Window.pbi"
XIncludeFile "layout/Container.pbi"
XIncludeFile "layout/StackPanel.pbi"
XIncludeFile "layout/DockPanel.pbi"
XIncludeFile "layout/Grid.pbi"
XIncludeFile "controls/Button.pbi"
XIncludeFile "controls/TextBox.pbi"
XIncludeFile "controls/Label.pbi"
XIncludeFile "controls/CheckBox.pbi"
XIncludeFile "controls/RadioButton.pbi"
XIncludeFile "controls/ProgressBar.pbi"
XIncludeFile "controls/Slider.pbi"
XIncludeFile "controls/ComboBox.pbi"
XIncludeFile "controls/SpinBox.pbi"
XIncludeFile "controls/Editor.pbi"
XIncludeFile "controls/ListView.pbi"
XIncludeFile "controls/TreeView.pbi"
XIncludeFile "controls/DatePicker.pbi"
XIncludeFile "controls/GroupBox.pbi"
XIncludeFile "controls/TabControl.pbi"
XIncludeFile "controls/ListIcon.pbi"
XIncludeFile "controls/ToggleSwitch.pbi"

Namespace UI {

  Class XMLLoader {
    Protected currentXmlDir.s

    Public Method Init() {
      This\currentXmlDir = ""
    }

    Public Method Free() {
    }

    ; ------------------------------------------------------------------------
    ; Helper: Parse margin or padding strings ("10", "10,5", "10,5,10,5")
    ; ------------------------------------------------------------------------
    Protected Method ParseBoxValues(valStr.s, *outL.INTEGER, *outT.INTEGER, *outR.INTEGER, *outB.INTEGER) {
      valStr = Trim(valStr)
      If valStr = ""
        *outL\i = 0 : *outT\i = 0 : *outR\i = 0 : *outB\i = 0
        ProcedureReturn
      EndIf

      Protected count.i = CountString(valStr, ",") + 1
      If count = 1
        Protected v.i = Val(valStr)
        *outL\i = v : *outT\i = v : *outR\i = v : *outB\i = v
      ElseIf count = 2
        Protected vH.i = Val(Trim(StringField(valStr, 1, ",")))
        Protected vV.i = Val(Trim(StringField(valStr, 2, ",")))
        *outL\i = vH : *outT\i = vV : *outR\i = vH : *outB\i = vV
      ElseIf count >= 4
        *outL\i = Val(Trim(StringField(valStr, 1, ",")))
        *outT\i = Val(Trim(StringField(valStr, 2, ",")))
        *outR\i = Val(Trim(StringField(valStr, 3, ",")))
        *outB\i = Val(Trim(StringField(valStr, 4, ",")))
      EndIf
    }

    ; ------------------------------------------------------------------------
    ; Helper: Parse Color (#RRGGBB, #RGB, $BBGGRR, 0xRRGGBB)
    ; ------------------------------------------------------------------------
    Protected Method.i ParseColor(colorStr.s, defaultColor.i) {
      colorStr = Trim(colorStr)
      If colorStr = "" : ProcedureReturn defaultColor : EndIf
      If Left(colorStr, 1) = "#"
        colorStr = Mid(colorStr, 2)
      ElseIf Left(colorStr, 2) = "0x" Or Left(colorStr, 2) = "0X"
        colorStr = Mid(colorStr, 3)
      ElseIf Left(colorStr, 1) = "$"
        colorStr = Mid(colorStr, 2)
      EndIf

      If Len(colorStr) = 6
        Protected r.i = Val("$" + Mid(colorStr, 1, 2))
        Protected g.i = Val("$" + Mid(colorStr, 3, 2))
        Protected b.i = Val("$" + Mid(colorStr, 5, 2))
        ProcedureReturn RGB(r, g, b)
      ElseIf Len(colorStr) = 3
        Protected r3.i = Val("$" + Mid(colorStr, 1, 1) + Mid(colorStr, 1, 1))
        Protected g3.i = Val("$" + Mid(colorStr, 2, 1) + Mid(colorStr, 2, 1))
        Protected b3.i = Val("$" + Mid(colorStr, 3, 1) + Mid(colorStr, 3, 1))
        ProcedureReturn RGB(r3, g3, b3)
      EndIf

      ProcedureReturn Val(colorStr)
    }

    ; ------------------------------------------------------------------------
    ; Helper: Parse WPF/XAML <Window.Resources> or <Resources> Styles & Triggers
    ; ------------------------------------------------------------------------
    Protected Method ParseResources(resNode.i, *targetWindow.UI::Window) {
      If Not *targetWindow : ProcedureReturn : EndIf
      Protected *resDict.UI::ResourceDictionary = *targetWindow\GetResources()
      If Not *resDict : ProcedureReturn : EndIf

      Protected *child = ChildXMLNode(resNode)
      While *child
        If XMLNodeType(*child) = #PB_XML_Normal
          Protected childTag.s = UCase(GetXMLNodeName(*child))
          If childTag = "STYLE"
            Protected targetType.s = GetXMLAttribute(*child, "TargetType")
            Protected keyStr.s = GetXMLAttribute(*child, "x:Key")
            If keyStr = "" : keyStr = GetXMLAttribute(*child, "Key") : EndIf
            Protected basedOnStr.s = GetXMLAttribute(*child, "BasedOn")

            Protected *style.UI::Style = New UI::Style(targetType, keyStr, basedOnStr)

            ; Iterate over Style Setters and Triggers
            Protected *propNode = ChildXMLNode(*child)
            While *propNode
              If XMLNodeType(*propNode) = #PB_XML_Normal
                Protected propTag.s = UCase(GetXMLNodeName(*propNode))
                If propTag = "SETTER"
                  Protected sProp.s = GetXMLAttribute(*propNode, "Property")
                  Protected sVal.s = GetXMLAttribute(*propNode, "Value")
                  *style\AddSetter(sProp, sVal)
                ElseIf propTag = "TRIGGER"
                  Protected tProp.s = GetXMLAttribute(*propNode, "Property")
                  Protected tVal.s = GetXMLAttribute(*propNode, "Value")
                  Protected trigIdx.i = *style\AddTrigger(tProp, tVal)

                  ; Trigger setters
                  Protected *tChild = ChildXMLNode(*propNode)
                  While *tChild
                    If XMLNodeType(*tChild) = #PB_XML_Normal And UCase(GetXMLNodeName(*tChild)) = "SETTER"
                      Protected tsProp.s = GetXMLAttribute(*tChild, "Property")
                      Protected tsVal.s = GetXMLAttribute(*tChild, "Value")
                      *style\AddTriggerSetter(trigIdx, tsProp, tsVal)
                    EndIf
                    *tChild = NextXMLNode(*tChild)
                  Wend
                EndIf
              EndIf
              *propNode = NextXMLNode(*propNode)
            Wend

            *resDict\AddStyle(*style)
          ElseIf childTag = "RESOURCEDICTIONARY"
            Protected srcPath.s = GetXMLAttribute(*child, "Source")
            If srcPath = "" : srcPath = GetXMLAttribute(*child, "source") : EndIf
            If srcPath <> ""
              Protected fullSrcPath.s = srcPath
              If This\currentXmlDir <> "" And FileSize(fullSrcPath) <= 0
                If FileSize(This\currentXmlDir + srcPath) > 0
                  fullSrcPath = This\currentXmlDir + srcPath
                ElseIf FileSize(This\currentXmlDir + "../" + srcPath) > 0
                  fullSrcPath = This\currentXmlDir + "../" + srcPath
                EndIf
              EndIf
              CompilerIf Defined(OOP_PROJECT_DIR, #PB_Constant)
                If FileSize(fullSrcPath) <= 0 And FileSize(#OOP_PROJECT_DIR + srcPath) > 0
                  fullSrcPath = #OOP_PROJECT_DIR + srcPath
                ElseIf FileSize(fullSrcPath) <= 0 And FileSize(#OOP_PROJECT_DIR + "styles/" + GetFilePart(srcPath)) > 0
                  fullSrcPath = #OOP_PROJECT_DIR + "styles/" + GetFilePart(srcPath)
                EndIf
              CompilerEndIf
              CompilerIf Defined(OOP_WORKSPACE_DIR, #PB_Constant)
                If FileSize(fullSrcPath) <= 0 And FileSize(#OOP_WORKSPACE_DIR + "examples/07_project_dashboard/" + srcPath) > 0
                  fullSrcPath = #OOP_WORKSPACE_DIR + "examples/07_project_dashboard/" + srcPath
                ElseIf FileSize(fullSrcPath) <= 0 And FileSize(#OOP_WORKSPACE_DIR + "examples/07_project_dashboard/styles/" + GetFilePart(srcPath)) > 0
                  fullSrcPath = #OOP_WORKSPACE_DIR + "examples/07_project_dashboard/styles/" + GetFilePart(srcPath)
                EndIf
              CompilerEndIf
              If FileSize(fullSrcPath) <= 0 And FileSize(GetPathPart(ProgramFilename()) + srcPath) > 0
                fullSrcPath = GetPathPart(ProgramFilename()) + srcPath
              EndIf
              If FileSize(fullSrcPath) <= 0 And FileSize("styles/" + srcPath) > 0
                fullSrcPath = "styles/" + srcPath
              EndIf
              If FileSize(fullSrcPath) > 0
                Protected extXml.i = LoadXML(#PB_Any, fullSrcPath)
                If extXml And XMLStatus(extXml) = #PB_XML_Success
                  Protected *extRoot = MainXMLNode(extXml)
                  If *extRoot
                    This\ParseResources(*extRoot, *targetWindow)
                  EndIf
                  FreeXML(extXml)
                EndIf
              EndIf
            Else
              ; Dictionnaire inline
              This\ParseResources(*child, *targetWindow)
            EndIf
          ElseIf childTag = "RESOURCEDICTIONARY.MERGEDDICTIONARIES"
            This\ParseResources(*child, *targetWindow)
          EndIf
        EndIf
        *child = NextXMLNode(*child)
      Wend
    }

    ; ------------------------------------------------------------------------
    ; Helper: Apply CanvasControl styling tokens (WPF Hover, Pressed, Colors, Typo)
    ; ------------------------------------------------------------------------
    Protected Method ApplyCanvasControlAttributes(*ctrl.UI::CanvasControl, node.i, *targetWindow.UI::Window, *parentContainer.UI::Layouts::Container = 0) {
      If Not *ctrl : ProcedureReturn : EndIf

      ; Inherit background color from parent container or window
      If *parentContainer And *parentContainer\GetBackground() <> 0
        *ctrl\SetParentBackground(*parentContainer\GetBackground())
      ElseIf *targetWindow
        *ctrl\SetParentBackground(*targetWindow\GetBackgroundColor())
      EndIf

      ; 0. Find and apply WPF Style (named or implicit by TargetType)
      If *targetWindow
        Protected *resDict.UI::ResourceDictionary = *targetWindow\GetResources()
        If *resDict
          Protected *styleToApply.UI::Style = 0
          Protected styleKey.s = GetXMLAttribute(node, "Style")
          If styleKey <> ""
            *styleToApply = *resDict\GetStyle(styleKey)
          Else
            Protected nodeTypeName.s = GetXMLNodeName(node)
            *styleToApply = *resDict\GetImplicitStyle(nodeTypeName)
          EndIf

          If *styleToApply
            *ctrl\ApplyStyle(*styleToApply)
          EndIf
        EndIf
      EndIf

      ; 1. Normal Colors & Background
      Protected bgStr.s = GetXMLAttribute(node, "Background")
      If bgStr = "" : bgStr = GetXMLAttribute(node, "Bg") : EndIf
      If bgStr <> "" And Left(bgStr, 1) <> "{"
        *ctrl\SetBackground(This\ParseColor(bgStr, *ctrl\GetBackground()))
      EndIf

      Protected fgStr.s = GetXMLAttribute(node, "Foreground")
      If fgStr = "" : fgStr = GetXMLAttribute(node, "Fg") : EndIf
      If fgStr <> "" And Left(fgStr, 1) <> "{"
        *ctrl\SetForeground(This\ParseColor(fgStr, *ctrl\GetForeground()))
      EndIf

      ; 2. Hover Colors (Survol souris)
      Protected hovBgStr.s = GetXMLAttribute(node, "HoverBackground")
      If hovBgStr = "" : hovBgStr = GetXMLAttribute(node, "HoverBg") : EndIf
      If hovBgStr <> ""
        *ctrl\SetHoverBackground(This\ParseColor(hovBgStr, *ctrl\GetHoverBackground()))
      EndIf

      Protected hovFgStr.s = GetXMLAttribute(node, "HoverForeground")
      If hovFgStr = "" : hovFgStr = GetXMLAttribute(node, "HoverFg") : EndIf
      If hovFgStr <> ""
        *ctrl\SetHoverForeground(This\ParseColor(hovFgStr, *ctrl\GetHoverForeground()))
      EndIf

      Protected hovBorderStr.s = GetXMLAttribute(node, "HoverBorderColor")
      If hovBorderStr <> ""
        *ctrl\SetHoverBorderColor(This\ParseColor(hovBorderStr, *ctrl\GetHoverBorderColor()))
      EndIf

      ; 3. Pressed Colors (Mouse pressed)
      Protected prBgStr.s = GetXMLAttribute(node, "PressedBackground")
      If prBgStr = "" : prBgStr = GetXMLAttribute(node, "PressedBg") : EndIf
      If prBgStr <> ""
        *ctrl\SetPressedBackground(This\ParseColor(prBgStr, *ctrl\GetPressedBackground()))
      EndIf

      Protected prFgStr.s = GetXMLAttribute(node, "PressedForeground")
      If prFgStr = "" : prFgStr = GetXMLAttribute(node, "PressedFg") : EndIf
      If prFgStr <> ""
        *ctrl\SetPressedForeground(This\ParseColor(prFgStr, *ctrl\GetPressedForeground()))
      EndIf

      Protected prBorderStr.s = GetXMLAttribute(node, "PressedBorderColor")
      If prBorderStr <> ""
        *ctrl\SetPressedBorderColor(This\ParseColor(prBorderStr, *ctrl\GetPressedBorderColor()))
      EndIf

      ; 4. Border & Geometry
      Protected borderStr.s = GetXMLAttribute(node, "BorderColor")
      If borderStr <> ""
        *ctrl\SetBorderColor(This\ParseColor(borderStr, *ctrl\GetBorderColor()))
      EndIf

      Protected thickStr.s = GetXMLAttribute(node, "BorderThickness")
      If thickStr <> ""
        *ctrl\SetBorderThickness(Val(thickStr))
      EndIf

      Protected borderLeftThickStr.s = GetXMLAttribute(node, "BorderLeftThickness")
      If borderLeftThickStr <> ""
        *ctrl\SetBorderLeftThickness(Val(borderLeftThickStr))
      EndIf

      Protected borderLeftColorStr.s = GetXMLAttribute(node, "BorderLeftColor")
      If borderLeftColorStr <> ""
        *ctrl\SetBorderLeftColor(This\ParseColor(borderLeftColorStr, *ctrl\GetBorderLeftColor()))
      EndIf

      Protected radStr.s = GetXMLAttribute(node, "CornerRadius")
      If radStr <> ""
        *ctrl\SetCornerRadius(Val(radStr))
      EndIf

      ; 5. Padding
      Protected padStr.s = GetXMLAttribute(node, "Padding")
      If padStr <> ""
        Protected pL.INTEGER, pT.INTEGER, pR.INTEGER, pB.INTEGER
        This\ParseBoxValues(padStr, @pL, @pT, @pR, @pB)
        *ctrl\SetPadding(pL\i, pT\i, pR\i, pB\i)
      EndIf

      ; 6. High-Fidelity Typography
      Protected fontNameStr.s = GetXMLAttribute(node, "FontName")
      If fontNameStr = "" : fontNameStr = GetXMLAttribute(node, "FontFamily") : EndIf
      Protected fontSizeStr.s = GetXMLAttribute(node, "FontSize")
      Protected fontBoldStr.s = UCase(Trim(GetXMLAttribute(node, "FontBold")))
      If fontBoldStr = "" : fontBoldStr = UCase(Trim(GetXMLAttribute(node, "FontWeight"))) : EndIf
      Protected isBold.b = #False
      If fontBoldStr = "TRUE" Or fontBoldStr = "BOLD" Or fontBoldStr = "1" : isBold = #True : EndIf

      If fontNameStr <> "" Or fontSizeStr <> ""
        If fontNameStr = "" : fontNameStr = "Segoe UI" : EndIf
        Protected fSize.i = 10
        If fontSizeStr <> "" : fSize = Val(fontSizeStr) : EndIf
        *ctrl\SetTypography(fontNameStr, fSize, isBold)
      EndIf
    }

    ; ------------------------------------------------------------------------
    ; Helper: Apply common component attributes (Name, Width, Height, Margins, Alignments)
    ; ------------------------------------------------------------------------
    Protected Method ApplyCommonAttributes(*comp.UI::Component, node.i, *targetWindow.UI::Window) {
      If Not *comp : ProcedureReturn : EndIf

      ; Name / ID for named control registration
      Protected nameStr.s = GetXMLAttribute(node, "Name")
      If nameStr = "" : nameStr = GetXMLAttribute(node, "name") : EndIf
      If nameStr = "" : nameStr = GetXMLAttribute(node, "ID") : EndIf
      If nameStr = "" : nameStr = GetXMLAttribute(node, "id") : EndIf
      If nameStr <> ""
        *comp\SetTag(nameStr)
        If *targetWindow
          *targetWindow\RegisterControl(nameStr, *comp)
        EndIf
      EndIf

      ; Dimensions
      Protected wStr.s = GetXMLAttribute(node, "Width")
      If wStr = "" : wStr = GetXMLAttribute(node, "width") : EndIf
      If wStr <> "" : *comp\SetWidth(Val(wStr)) : EndIf

      Protected hStr.s = GetXMLAttribute(node, "Height")
      If hStr = "" : hStr = GetXMLAttribute(node, "height") : EndIf
      If hStr <> "" : *comp\SetHeight(Val(hStr)) : EndIf

      Protected minW.s = GetXMLAttribute(node, "MinWidth")
      If minW <> "" : *comp\SetMinWidth(Val(minW)) : EndIf

      Protected minH.s = GetXMLAttribute(node, "MinHeight")
      If minH <> "" : *comp\SetMinHeight(Val(minH)) : EndIf

      Protected maxW.s = GetXMLAttribute(node, "MaxWidth")
      If maxW <> "" : *comp\SetMaxWidth(Val(maxW)) : EndIf

      Protected maxH.s = GetXMLAttribute(node, "MaxHeight")
      If maxH <> "" : *comp\SetMaxHeight(Val(maxH)) : EndIf

      ; Margins
      Protected mStr.s = GetXMLAttribute(node, "Margin")
      If mStr = "" : mStr = GetXMLAttribute(node, "margin") : EndIf
      If mStr <> ""
        Protected mL.INTEGER, mT.INTEGER, mR.INTEGER, mB.INTEGER
        This\ParseBoxValues(mStr, @mL, @mT, @mR, @mB)
        *comp\SetMargin(mL\i, mT\i, mR\i, mB\i)
      EndIf

      Protected mLStr.s = GetXMLAttribute(node, "MarginLeft")
      If mLStr <> "" : *comp\SetMargin(Val(mLStr), *comp\GetMarginTop(), *comp\GetMarginRight(), *comp\GetMarginBottom()) : EndIf

      Protected mTStr.s = GetXMLAttribute(node, "MarginTop")
      If mTStr <> "" : *comp\SetMargin(*comp\GetMarginLeft(), Val(mTStr), *comp\GetMarginRight(), *comp\GetMarginBottom()) : EndIf

      Protected mRStr.s = GetXMLAttribute(node, "MarginRight")
      If mRStr <> "" : *comp\SetMargin(*comp\GetMarginLeft(), *comp\GetMarginTop(), Val(mRStr), *comp\GetMarginBottom()) : EndIf

      Protected mBStr.s = GetXMLAttribute(node, "MarginBottom")
      If mBStr <> "" : *comp\SetMargin(*comp\GetMarginLeft(), *comp\GetMarginTop(), *comp\GetMarginRight(), Val(mBStr)) : EndIf

      ; Alignments
      Protected hAlignStr.s = UCase(Trim(GetXMLAttribute(node, "HorizontalAlignment")))
      If hAlignStr = "" : hAlignStr = UCase(Trim(GetXMLAttribute(node, "horizontalAlignment"))) : EndIf
      If hAlignStr = "" : hAlignStr = UCase(Trim(GetXMLAttribute(node, "Align"))) : EndIf
      If hAlignStr = "" : hAlignStr = UCase(Trim(GetXMLAttribute(node, "HAlign"))) : EndIf
      If hAlignStr <> ""
        Select hAlignStr
          Case "LEFT"    : *comp\SetHorizontalAlignment(#UI_Align_Left)
          Case "CENTER"  : *comp\SetHorizontalAlignment(#UI_Align_Center)
          Case "RIGHT"   : *comp\SetHorizontalAlignment(#UI_Align_Right)
          Case "STRETCH" : *comp\SetHorizontalAlignment(#UI_Align_Stretch)
        EndSelect
      EndIf

      Protected vAlignStr.s = UCase(Trim(GetXMLAttribute(node, "VerticalAlignment")))
      If vAlignStr = "" : vAlignStr = UCase(Trim(GetXMLAttribute(node, "verticalAlignment"))) : EndIf
      If vAlignStr = "" : vAlignStr = UCase(Trim(GetXMLAttribute(node, "VAlign"))) : EndIf
      If vAlignStr <> ""
        Select vAlignStr
          Case "TOP"      : *comp\SetVerticalAlignment(#UI_Align_Top)
          Case "MIDDLE", "CENTER" : *comp\SetVerticalAlignment(#UI_Align_Middle)
          Case "BOTTOM"   : *comp\SetVerticalAlignment(#UI_Align_Bottom)
          Case "STRETCH", "VSTRETCH" : *comp\SetVerticalAlignment(#UI_Align_VStretch)
        EndSelect
      EndIf

      ; Visibility & Enabled
      Protected visStr.s = UCase(Trim(GetXMLAttribute(node, "IsVisible")))
      If visStr = "" : visStr = UCase(Trim(GetXMLAttribute(node, "Visible"))) : EndIf
      If visStr = "FALSE" Or visStr = "0"
        *comp\SetVisible(#False)
      EndIf

      Protected enStr.s = UCase(Trim(GetXMLAttribute(node, "IsEnabled")))
      If enStr = "" : enStr = UCase(Trim(GetXMLAttribute(node, "Enabled"))) : EndIf
      If enStr = "FALSE" Or enStr = "0"
        *comp\SetEnabled(#False)
      EndIf

      ; Visual Styling (Background, Border, CornerRadius for Container and Controls)
      Protected bgVal.s = GetXMLAttribute(node, "Background")
      If bgVal = "" : bgVal = GetXMLAttribute(node, "Bg") : EndIf
      If bgVal <> "" And Left(bgVal, 1) <> "{"
        *comp\SetBackground(This\ParseColor(bgVal, *comp\GetBackground()))
      EndIf

      Protected bcVal.s = GetXMLAttribute(node, "BorderColor")
      If bcVal = "" : bcVal = GetXMLAttribute(node, "BorderBrush") : EndIf
      If bcVal <> ""
        *comp\SetBorderColor(This\ParseColor(bcVal, 0))
      EndIf

      Protected btVal.s = GetXMLAttribute(node, "BorderThickness")
      If btVal <> "" : *comp\SetBorderThickness(Val(btVal)) : EndIf

      Protected crVal.s = GetXMLAttribute(node, "CornerRadius")
      If crVal <> "" : *comp\SetCornerRadius(Val(crVal)) : EndIf

      ; MVVM DataBindings
      This\ApplyDataBindings(*comp, node, *targetWindow)
    }

    ; ------------------------------------------------------------------------
    ; Helper: Parse {Binding Path=..., Mode=...}
    ; ------------------------------------------------------------------------
    Protected Method.b ParseBindingExpression(attrVal.s, *outPropName.STRING, *outMode.INTEGER) {
      attrVal = Trim(attrVal)
      If Left(attrVal, 1) = "{" And Right(attrVal, 1) = "}"
        Protected inside.s = Trim(Mid(attrVal, 2, Len(attrVal) - 2))
        If LCase(Left(inside, 7)) = "binding"
          inside = Trim(Mid(inside, 8))
          *outMode\i = #UI_BindingMode_OneWay
          *outPropName\s = ""

          Protected count.i = CountString(inside, ",") + 1
          Protected i.i
          For i = 1 To count
            Protected part.s = Trim(StringField(inside, i, ","))
            If LCase(Left(part, 5)) = "path="
              *outPropName\s = Trim(Mid(part, 6))
            ElseIf LCase(Left(part, 5)) = "mode="
              Protected mStr.s = UCase(Trim(Mid(part, 6)))
              If mStr = "TWOWAY"
                *outMode\i = #UI_BindingMode_TwoWay
              ElseIf mStr = "ONEWAY"
                *outMode\i = #UI_BindingMode_OneWay
              EndIf
            ElseIf *outPropName\s = "" And Not FindString(part, "=")
              *outPropName\s = part
            EndIf
          Next
          ProcedureReturn #True
        EndIf
      EndIf
      ProcedureReturn #False
    }

    Protected Method ApplyDataBindings(*comp.UI::Component, node.i, *targetWindow.UI::Window) {
      If Not *comp Or Not *targetWindow : ProcedureReturn : EndIf
      Protected *vm.MVVM::ViewModelBase = *targetWindow\GetDataContext()
      If Not *vm : ProcedureReturn : EndIf

      Protected propName.STRING, modeVal.INTEGER

      ; 1. Text Binding
      Protected textAttr.s = GetXMLAttribute(node, "Text")
      If textAttr = "" : textAttr = GetXMLAttribute(node, "text") : EndIf
      If This\ParseBindingExpression(textAttr, @propName, @modeVal)
        UI_MVVM_RegisterBinding(*comp, "Text", *vm, propName\s, modeVal\i)
      EndIf

      ; 2. Checked / State Binding
      Protected chkAttr.s = GetXMLAttribute(node, "Checked")
      If chkAttr = "" : chkAttr = GetXMLAttribute(node, "checked") : EndIf
      If This\ParseBindingExpression(chkAttr, @propName, @modeVal)
        UI_MVVM_RegisterBinding(*comp, "Checked", *vm, propName\s, modeVal\i)
      EndIf

      ; 3. Value / Progress Binding
      Protected valAttr.s = GetXMLAttribute(node, "Value")
      If valAttr = "" : valAttr = GetXMLAttribute(node, "value") : EndIf
      If This\ParseBindingExpression(valAttr, @propName, @modeVal)
        UI_MVVM_RegisterBinding(*comp, "Value", *vm, propName\s, modeVal\i)
      EndIf

      ; 4. Command / Click Binding
      Protected cmdAttr.s = GetXMLAttribute(node, "Command")
      If cmdAttr = "" : cmdAttr = GetXMLAttribute(node, "command") : EndIf
      If cmdAttr = "" : cmdAttr = GetXMLAttribute(node, "Click") : EndIf
      If cmdAttr = "" : cmdAttr = GetXMLAttribute(node, "click") : EndIf
      If cmdAttr = "" : cmdAttr = GetXMLAttribute(node, "OnClick") : EndIf
      If cmdAttr = "" : cmdAttr = GetXMLAttribute(node, "onclick") : EndIf
      If cmdAttr <> ""
        If This\ParseBindingExpression(cmdAttr, @propName, @modeVal)
          UI_MVVM_RegisterCommandBinding(*comp, *vm, propName\s)
        Else
          UI_MVVM_RegisterCommandBinding(*comp, *vm, cmdAttr)
        EndIf
      EndIf

      ; 5. Hover / MouseOver Binding
      Protected hovAttr.s = GetXMLAttribute(node, "IsMouseOver")
      If hovAttr = "" : hovAttr = GetXMLAttribute(node, "IsHovered") : EndIf
      If This\ParseBindingExpression(hovAttr, @propName, @modeVal)
        UI_MVVM_RegisterBinding(*comp, "IsMouseOver", *vm, propName\s, modeVal\i)
      EndIf

      ; 6. Pressed Binding
      Protected pressAttr.s = GetXMLAttribute(node, "IsPressed")
      If This\ParseBindingExpression(pressAttr, @propName, @modeVal)
        UI_MVVM_RegisterBinding(*comp, "IsPressed", *vm, propName\s, modeVal\i)
      EndIf

      ; 7. Background / Foreground Binding
      Protected bgAttr.s = GetXMLAttribute(node, "Background")
      If This\ParseBindingExpression(bgAttr, @propName, @modeVal)
        UI_MVVM_RegisterBinding(*comp, "Background", *vm, propName\s, modeVal\i)
      EndIf
      Protected fgAttr.s = GetXMLAttribute(node, "Foreground")
      If This\ParseBindingExpression(fgAttr, @propName, @modeVal)
        UI_MVVM_RegisterBinding(*comp, "Foreground", *vm, propName\s, modeVal\i)
      EndIf
    }

    Protected Method ParseCanvasTreeNodes(*tree.UI::CanvasTree, *parentNode.UI::TreeNode, xmlNode.i) {
      Protected *childXml = ChildXMLNode(xmlNode)
      While *childXml
        If XMLNodeType(*childXml) = #PB_XML_Normal And (UCase(GetXMLNodeName(*childXml)) = "NODE" Or UCase(GetXMLNodeName(*childXml)) = "ITEM")
          Protected nodeTxt.s = GetXMLAttribute(*childXml, "Text")
          If nodeTxt = "" : nodeTxt = GetXMLAttribute(*childXml, "text") : EndIf
          If nodeTxt = "" : nodeTxt = GetXMLNodeText(*childXml) : EndIf
          Protected nodeTag.s = GetXMLAttribute(*childXml, "Tag")
          If nodeTag = "" : nodeTag = GetXMLAttribute(*childXml, "tag") : EndIf

          Protected *newNode.UI::TreeNode = *tree\AddNode(*parentNode, nodeTxt, 0, nodeTag)

          Protected expStr.s = UCase(Trim(GetXMLAttribute(*childXml, "Expanded")))
          If expStr = "TRUE" Or expStr = "1" : *newNode\SetExpanded(#True) : EndIf

          Protected chkStr.s = UCase(Trim(GetXMLAttribute(*childXml, "Checked")))
          If chkStr = "TRUE" Or chkStr = "1" : *newNode\SetChecked(#True) : EndIf

          Protected hasChkStr.s = UCase(Trim(GetXMLAttribute(*childXml, "HasCheckBox")))
          If hasChkStr = "TRUE" Or hasChkStr = "1" : *newNode\SetHasCheckBox(#True) : EndIf

          This\ParseCanvasTreeNodes(*tree, *newNode, *childXml)
        EndIf
        *childXml = NextXMLNode(*childXml)
      Wend
      *tree\RebuildVisibleList()
    }

    Protected Method ParseCanvasTableColumnsAndRows(*table.UI::CanvasTable, xmlNode.i) {
      Protected *childXml = ChildXMLNode(xmlNode)
      While *childXml
        If XMLNodeType(*childXml) = #PB_XML_Normal
          Protected childTag.s = UCase(GetXMLNodeName(*childXml))
          If childTag = "COLUMN"
            Protected colTitle.s = GetXMLAttribute(*childXml, "Title")
            If colTitle = "" : colTitle = GetXMLAttribute(*childXml, "title") : EndIf
            Protected colWidth.i = Val(GetXMLAttribute(*childXml, "Width"))
            If colWidth <= 0 : colWidth = 100 : EndIf

            Protected colType.i = #UI_TableCol_Text
            Protected typeStr.s = UCase(Trim(GetXMLAttribute(*childXml, "Type")))
            Select typeStr
              Case "NUMBER", "NUMERIC", "INT", "INTEGER", "FLOAT", "DOUBLE":
                colType = #UI_TableCol_Number
              Case "IMAGE", "ICON":
                colType = #UI_TableCol_Image
              Case "CHECKBOX", "BOOL", "BOOLEAN":
                colType = #UI_TableCol_CheckBox
              Case "BUTTONS", "ACTIONBUTTONS", "ACTIONS":
                colType = #UI_TableCol_ActionButtons
            EndSelect

            Protected colAlign.i = #UI_TableAlign_Left
            Protected alignStr.s = UCase(Trim(GetXMLAttribute(*childXml, "Align")))
            Select alignStr
              Case "CENTER":
                colAlign = #UI_TableAlign_Center
              Case "RIGHT":
                colAlign = #UI_TableAlign_Right
            EndSelect

            Protected *newCol.UI::TableColumn = *table\AddColumn(colTitle, colWidth, colType, colAlign)

            Protected editStr.s = UCase(Trim(GetXMLAttribute(*childXml, "Editable")))
            If editStr = "TRUE" Or editStr = "1" : *newCol\SetEditable(#True) : EndIf

            Protected sortStr.s = UCase(Trim(GetXMLAttribute(*childXml, "Sortable")))
            If sortStr = "FALSE" Or sortStr = "0" : *newCol\SetSortable(#False) : EndIf

            Protected resizStr.s = UCase(Trim(GetXMLAttribute(*childXml, "Resizable")))
            If resizStr = "FALSE" Or resizStr = "0" : *newCol\SetResizable(#False) : EndIf

          ElseIf childTag = "ROW"
            Protected *newRow.UI::TableRow = *table\AddRow()
            Protected rowTag.s = GetXMLAttribute(*childXml, "Tag")
            If rowTag <> "" : *newRow\SetTag(rowTag) : EndIf

            Protected rowCells.s = GetXMLAttribute(*childXml, "Cells")
            If rowCells <> ""
              Protected cCount.i = CountString(rowCells, ";") + 1
              Protected cIdx.i
              For cIdx = 1 To cCount
                *newRow\AddCell(StringField(rowCells, cIdx, ";"))
              Next
            Else
              ; Child <Cell> tags
              Protected *cellXml = ChildXMLNode(*childXml)
              While *cellXml
                If XMLNodeType(*cellXml) = #PB_XML_Normal And UCase(GetXMLNodeName(*cellXml)) = "CELL"
                  *newRow\AddCell(GetXMLNodeText(*cellXml))
                EndIf
                *cellXml = NextXMLNode(*cellXml)
              Wend
            EndIf
          EndIf
        EndIf
        *childXml = NextXMLNode(*childXml)
      Wend
    }

    ; ------------------------------------------------------------------------
    ; Recursive XML Node Parser
    ; ------------------------------------------------------------------------
    Public Method.i ParseNode(node.i, *targetWindow.UI::Window, *parentContainer.UI::Layouts::Container = 0) {
      If Not node Or XMLNodeType(node) <> #PB_XML_Normal
        ProcedureReturn 0
      EndIf

      Protected tag.s = UCase(Trim(GetXMLNodeName(node)))
      Protected *createdComp.UI::Component = 0

      Select tag
        ; ====================================================================
        ; 1. WINDOW
        ; ====================================================================
        Case "WINDOW"
          Protected title.s = GetXMLAttribute(node, "Title")
          If title = "" : title = GetXMLAttribute(node, "title") : EndIf
          If title = "" : title = "PureBasic OOP Window" : EndIf

          Protected winW.i = Val(GetXMLAttribute(node, "Width"))
          If winW <= 0 : winW = 800 : EndIf

          Protected winH.i = Val(GetXMLAttribute(node, "Height"))
          If winH <= 0 : winH = 600 : EndIf

          If *targetWindow
            If *targetWindow\GetID() = 0
              *targetWindow\CreateWindowInternal(title, #PB_Ignore, #PB_Ignore, winW, winH, #PB_Window_SystemMenu | #PB_Window_ScreenCentered | #PB_Window_SizeGadget | #PB_Window_MinimizeGadget | #PB_Window_MaximizeGadget, 0)
            Else
              *targetWindow\SetTitle(title)
              *targetWindow\SetSize(winW, winH)
            EndIf
            Protected winBgStr.s = GetXMLAttribute(node, "Background")
            If winBgStr = "" : winBgStr = GetXMLAttribute(node, "Bg") : EndIf
            If winBgStr <> ""
              *targetWindow\SetBackgroundColor(This\ParseColor(winBgStr, RGB(248, 249, 250)))
            EndIf
          EndIf

          ; Parse children inside Window (first container becomes root content)
          Protected *childNode = ChildXMLNode(node)
          While *childNode
            If XMLNodeType(*childNode) = #PB_XML_Normal
              Protected cTag.s = UCase(GetXMLNodeName(*childNode))
              If cTag = "WINDOW.RESOURCES" Or cTag = "RESOURCES"
                This\ParseResources(*childNode, *targetWindow)
              Else
                Protected *rootChild.UI::Component = This\ParseNode(*childNode, *targetWindow, 0)
                If *rootChild And *targetWindow
                  *targetWindow\SetContent(*rootChild)
                  Break
                EndIf
              EndIf
            EndIf
            *childNode = NextXMLNode(*childNode)
          Wend
          ProcedureReturn *targetWindow

        ; ====================================================================
        ; 2. LAYOUT PANELS
        ; ====================================================================
        Case "DOCKPANEL"
          Protected *dockPanel.UI::Layouts::DockPanel = New UI::Layouts::DockPanel()
          Protected fillStr.s = UCase(Trim(GetXMLAttribute(node, "LastChildFill")))
          If fillStr = "FALSE" Or fillStr = "0"
            *dockPanel\SetLastChildFill(#False)
          EndIf

          Protected padStr.s = GetXMLAttribute(node, "Padding")
          If padStr <> ""
            Protected pL.INTEGER, pT.INTEGER, pR.INTEGER, pB.INTEGER
            This\ParseBoxValues(padStr, @pL, @pT, @pR, @pB)
            *dockPanel\SetPadding(pL\i, pT\i, pR\i, pB\i)
          EndIf

          This\ApplyCommonAttributes(*dockPanel, node, *targetWindow)
          *createdComp = *dockPanel

          ; Parse children of DockPanel
          Protected *dChildNode = ChildXMLNode(node)
          While *dChildNode
            If XMLNodeType(*dChildNode) = #PB_XML_Normal
              Protected *cChild.UI::Component = This\ParseNode(*dChildNode, *targetWindow, *dockPanel)
              If *cChild
                Protected dockStr.s = UCase(Trim(GetXMLAttribute(*dChildNode, "Dock")))
                If dockStr = "" : dockStr = UCase(Trim(GetXMLAttribute(*dChildNode, "dock"))) : EndIf
                Protected dockType.i = #UI_Dock_Fill
                Select dockStr
                  Case "TOP"    : dockType = #UI_Dock_Top
                  Case "BOTTOM" : dockType = #UI_Dock_Bottom
                  Case "LEFT"   : dockType = #UI_Dock_Left
                  Case "RIGHT"  : dockType = #UI_Dock_Right
                  Case "FILL"   : dockType = #UI_Dock_Fill
                EndSelect
                *dockPanel\SetDock(*cChild, dockType)
              EndIf
            EndIf
            *dChildNode = NextXMLNode(*dChildNode)
          Wend

        Case "STACKPANEL"
          Protected *stackPanel.UI::Layouts::StackPanel = New UI::Layouts::StackPanel()
          Protected orientStr.s = UCase(Trim(GetXMLAttribute(node, "Orientation")))
          If orientStr = "HORIZONTAL"
            *stackPanel\SetOrientation(#UI_Orientation_Horizontal)
          Else
            *stackPanel\SetOrientation(#UI_Orientation_Vertical)
          EndIf

          Protected spStr.s = GetXMLAttribute(node, "Spacing")
          If spStr <> "" : *stackPanel\SetSpacing(Val(spStr)) : EndIf

          Protected sPadStr.s = GetXMLAttribute(node, "Padding")
          If sPadStr <> ""
            Protected spL.INTEGER, spT.INTEGER, spR.INTEGER, spB.INTEGER
            This\ParseBoxValues(sPadStr, @spL, @spT, @spR, @spB)
            *stackPanel\SetPadding(spL\i, spT\i, spR\i, spB\i)
          EndIf

          This\ApplyCommonAttributes(*stackPanel, node, *targetWindow)
          *createdComp = *stackPanel

          ; Parse children of StackPanel
          Protected *sChildNode = ChildXMLNode(node)
          While *sChildNode
            If XMLNodeType(*sChildNode) = #PB_XML_Normal
              Protected *sChild.UI::Component = This\ParseNode(*sChildNode, *targetWindow, *stackPanel)
              If *sChild
                *stackPanel\AddChild(*sChild)
              EndIf
            EndIf
            *sChildNode = NextXMLNode(*sChildNode)
          Wend

        Case "GRID"
          Protected *grid.UI::Layouts::Grid = New UI::Layouts::Grid()
          Protected rowsStr.s = GetXMLAttribute(node, "Rows")
          If rowsStr = "" : rowsStr = GetXMLAttribute(node, "rows") : EndIf
          If rowsStr <> ""
            Protected rCount.i = CountString(rowsStr, ",") + 1
            Protected rIdx.i
            For rIdx = 1 To rCount
              *grid\AddRow(Trim(StringField(rowsStr, rIdx, ",")))
            Next rIdx
          EndIf

          Protected colsStr.s = GetXMLAttribute(node, "Columns")
          If colsStr = "" : colsStr = GetXMLAttribute(node, "columns") : EndIf
          If colsStr = "" : colsStr = GetXMLAttribute(node, "Cols") : EndIf
          If colsStr <> ""
            Protected cCount.i = CountString(colsStr, ",") + 1
            Protected cIdx.i
            For cIdx = 1 To cCount
              *grid\AddColumn(Trim(StringField(colsStr, cIdx, ",")))
            Next cIdx
          EndIf

          Protected gPadStr.s = GetXMLAttribute(node, "Padding")
          If gPadStr <> ""
            Protected gpL.INTEGER, gpT.INTEGER, gpR.INTEGER, gpB.INTEGER
            This\ParseBoxValues(gPadStr, @gpL, @gpT, @gpR, @gpB)
            *grid\SetPadding(gpL\i, gpT\i, gpR\i, gpB\i)
          EndIf

          This\ApplyCommonAttributes(*grid, node, *targetWindow)
          *createdComp = *grid

          ; Parse children of Grid
          Protected *gChildNode = ChildXMLNode(node)
          While *gChildNode
            If XMLNodeType(*gChildNode) = #PB_XML_Normal
              Protected *gChild.UI::Component = This\ParseNode(*gChildNode, *targetWindow, *grid)
              If *gChild
                Protected rowVal.i = Val(GetXMLAttribute(*gChildNode, "Row"))
                If rowVal = 0 : rowVal = Val(GetXMLAttribute(*gChildNode, "Grid.Row")) : EndIf
                Protected colVal.i = Val(GetXMLAttribute(*gChildNode, "Col"))
                If colVal = 0 : colVal = Val(GetXMLAttribute(*gChildNode, "Column")) : EndIf
                If colVal = 0 : colVal = Val(GetXMLAttribute(*gChildNode, "Grid.Column")) : EndIf
                Protected rowSpan.i = Val(GetXMLAttribute(*gChildNode, "RowSpan"))
                If rowSpan <= 0 : rowSpan = Val(GetXMLAttribute(*gChildNode, "Grid.RowSpan")) : EndIf
                If rowSpan <= 0 : rowSpan = 1 : EndIf
                Protected colSpan.i = Val(GetXMLAttribute(*gChildNode, "ColSpan"))
                If colSpan <= 0 : colSpan = Val(GetXMLAttribute(*gChildNode, "Grid.ColumnSpan")) : EndIf
                If colSpan <= 0 : colSpan = 1 : EndIf

                *grid\SetCellSpan(*gChild, rowVal, colVal, rowSpan, colSpan)
              EndIf
            EndIf
            *gChildNode = NextXMLNode(*gChildNode)
          Wend

        Case "CONTAINER"
          Protected *container.UI::Layouts::Container = New UI::Layouts::Container()
          Protected cPadStr.s = GetXMLAttribute(node, "Padding")
          If cPadStr <> ""
            Protected cpL.INTEGER, cpT.INTEGER, cpR.INTEGER, cpB.INTEGER
            This\ParseBoxValues(cPadStr, @cpL, @cpT, @cpR, @cpB)
            *container\SetPadding(cpL\i, cpT\i, cpR\i, cpB\i)
          EndIf

          This\ApplyCommonAttributes(*container, node, *targetWindow)
          *createdComp = *container

          Protected *cntChildNode = ChildXMLNode(node)
          While *cntChildNode
            If XMLNodeType(*cntChildNode) = #PB_XML_Normal
              Protected *cntChild.UI::Component = This\ParseNode(*cntChildNode, *targetWindow, *container)
              If *cntChild
                *container\AddChild(*cntChild)
              EndIf
            EndIf
            *cntChildNode = NextXMLNode(*cntChildNode)
          Wend

        Case "BORDER"
          Protected *border.UI::Layouts::Container = New UI::Layouts::Container()
          Protected bPadStr.s = GetXMLAttribute(node, "Padding")
          If bPadStr <> ""
            Protected bpL.INTEGER, bpT.INTEGER, bpR.INTEGER, bpB.INTEGER
            This\ParseBoxValues(bPadStr, @bpL, @bpT, @bpR, @bpB)
            *border\SetPadding(bpL\i, bpT\i, bpR\i, bpB\i)
          EndIf

          This\ApplyCommonAttributes(*border, node, *targetWindow)
          *createdComp = *border

          Protected *bChildNode = ChildXMLNode(node)
          While *bChildNode
            If XMLNodeType(*bChildNode) = #PB_XML_Normal
              Protected *bChild.UI::Component = This\ParseNode(*bChildNode, *targetWindow, *border)
              If *bChild
                *border\AddChild(*bChild)
              EndIf
            EndIf
            *bChildNode = NextXMLNode(*bChildNode)
          Wend

        ; ====================================================================
        ; 3. STANDARD & CUSTOM CONTROLS
        ; ====================================================================
        Case "BUTTON"
          Protected btnText.s = GetXMLAttribute(node, "Text")
          If btnText = "" : btnText = GetXMLAttribute(node, "text") : EndIf
          Protected *btn.UI::Button = New UI::Button(btnText)
          This\ApplyCommonAttributes(*btn, node, *targetWindow)
          *createdComp = *btn

        Case "TEXTBOX", "STRING"
          Protected tbText.s = GetXMLAttribute(node, "Text")
          Protected *tb.UI::TextBox = New UI::TextBox(tbText)
          Protected tbPlaceholder.s = GetXMLAttribute(node, "Placeholder")
          If tbPlaceholder <> ""
            *tb\SetPlaceholder(tbPlaceholder)
          EndIf
          This\ApplyCommonAttributes(*tb, node, *targetWindow)
          *createdComp = *tb

        Case "LABEL", "TEXT"
          Protected lblText.s = GetXMLAttribute(node, "Text")
          Protected *lbl.UI::Label = New UI::Label(lblText)
          This\ApplyCommonAttributes(*lbl, node, *targetWindow)
          *createdComp = *lbl

        Case "CHECKBOX"
          Protected cbText.s = GetXMLAttribute(node, "Text")
          Protected cbChkStr.s = UCase(Trim(GetXMLAttribute(node, "Checked")))
          Protected cbChk.b = #False
          If cbChkStr = "TRUE" Or cbChkStr = "1" : cbChk = #True : EndIf
          Protected *cb.UI::CheckBox = New UI::CheckBox(cbText, cbChk)
          This\ApplyCommonAttributes(*cb, node, *targetWindow)
          *createdComp = *cb

        Case "PROGRESSBAR"
          Protected pbMin.i = Val(GetXMLAttribute(node, "Min"))
          Protected pbMax.i = Val(GetXMLAttribute(node, "Max"))
          If pbMax <= 0 : pbMax = 100 : EndIf
          Protected pbVal.i = Val(GetXMLAttribute(node, "Value"))
          Protected *pb.UI::ProgressBar = New UI::ProgressBar(pbMin, pbMax)
          If pbVal > 0 : *pb\SetValue(pbVal) : EndIf
          This\ApplyCommonAttributes(*pb, node, *targetWindow)
          *createdComp = *pb

        Case "SLIDER", "TRACKBAR"
          Protected slMin.i = Val(GetXMLAttribute(node, "Min"))
          Protected slMax.i = Val(GetXMLAttribute(node, "Max"))
          If slMax <= 0 : slMax = 100 : EndIf
          Protected slVal.i = Val(GetXMLAttribute(node, "Value"))
          Protected *sl.UI::Slider = New UI::Slider(slMin, slMax)
          If slVal > 0 : *sl\SetValue(slVal) : EndIf
          This\ApplyCommonAttributes(*sl, node, *targetWindow)
          *createdComp = *sl

        Case "COMBOBOX"
          Protected *combo.UI::ComboBox = New UI::ComboBox()
          Protected cboItems.s = GetXMLAttribute(node, "Items")
          If cboItems <> ""
            Protected iCount.i = CountString(cboItems, ",") + 1
            Protected ci.i
            For ci = 1 To iCount
              *combo\AddItem(Trim(StringField(cboItems, ci, ",")))
            Next
          EndIf
          Protected cboSel.s = GetXMLAttribute(node, "SelectedIndex")
          If cboSel <> ""
            *combo\SetSelectedIndex(Val(cboSel))
          EndIf
          This\ApplyCommonAttributes(*combo, node, *targetWindow)
          *createdComp = *combo

          ; Parse child <Item> nodes
          Protected *itemNode = ChildXMLNode(node)
          While *itemNode
            If XMLNodeType(*itemNode) = #PB_XML_Normal And UCase(GetXMLNodeName(*itemNode)) = "ITEM"
              Protected itemText.s = GetXMLAttribute(*itemNode, "Text")
              If itemText = "" : itemText = GetXMLNodeText(*itemNode) : EndIf
              *combo\AddItem(itemText)
            EndIf
            *itemNode = NextXMLNode(*itemNode)
          Wend

        Case "LISTICON"
          Protected colsAttr.s = GetXMLAttribute(node, "Columns")
          Protected *li.UI::ListIcon = 0
          Protected liTitle.s = "Item"
          Protected liWidth.i = 150
          If colsAttr <> ""
            Protected firstColDef.s = StringField(colsAttr, 1, ",")
            liTitle = Trim(StringField(firstColDef, 1, ":"))
            liWidth = Val(Trim(StringField(firstColDef, 2, ":")))
            If liWidth <= 0 : liWidth = 100 : EndIf
          Else
            Protected firstColTitleDef.s = GetXMLAttribute(node, "FirstColumnTitle")
            If firstColTitleDef <> "" : liTitle = firstColTitleDef : EndIf
            Protected firstColWidthDef.i = Val(GetXMLAttribute(node, "FirstColumnWidth"))
            If firstColWidthDef > 0 : liWidth = firstColWidthDef : EndIf
          EndIf

          *li = New UI::ListIcon(liTitle, liWidth)

          If colsAttr <> ""
            Protected colTotal.i = CountString(colsAttr, ",") + 1
            Protected liColIdx.i
            For liColIdx = 2 To colTotal
              Protected cDef.s = StringField(colsAttr, liColIdx, ",")
              Protected cTitle.s = Trim(StringField(cDef, 1, ":"))
              Protected cWidth.i = Val(Trim(StringField(cDef, 2, ":")))
              If cWidth <= 0 : cWidth = 100 : EndIf
              *li\AddColumn(liColIdx - 1, cTitle, cWidth)
            Next
          EndIf

          This\ApplyCommonAttributes(*li, node, *targetWindow)
          *createdComp = *li

          ; Parse child <Column> nodes and <Item> nodes
          Protected *liSubNode = ChildXMLNode(node)
          Protected colPos.i = 1
          While *liSubNode
            If XMLNodeType(*liSubNode) = #PB_XML_Normal
              Protected subTag.s = UCase(GetXMLNodeName(*liSubNode))
              If subTag = "COLUMN"
                Protected colTitle.s = GetXMLAttribute(*liSubNode, "Title")
                Protected colWidth.i = Val(GetXMLAttribute(*liSubNode, "Width"))
                If colWidth <= 0 : colWidth = 100 : EndIf
                *li\AddColumn(colPos, colTitle, colWidth)
                colPos + 1
              ElseIf subTag = "ITEM"
                Protected lItemText.s = GetXMLAttribute(*liSubNode, "Text")
                If lItemText = "" : lItemText = GetXMLNodeText(*liSubNode) : EndIf
                *li\AddItem(-1, lItemText, 0)
              EndIf
            EndIf
            *liSubNode = NextXMLNode(*liSubNode)
          Wend

        Case "TOGGLESWITCH"
          Protected tsChkStr.s = UCase(Trim(GetXMLAttribute(node, "Checked")))
          Protected tsChk.b = #False
          If tsChkStr = "TRUE" Or tsChkStr = "1" : tsChk = #True : EndIf
          Protected *ts.UI::ToggleSwitch = New UI::ToggleSwitch(tsChk)
          This\ApplyCommonAttributes(*ts, node, *targetWindow)
          *createdComp = *ts

        Case "EDITOR", "TEXTAREA"
          Protected edText.s = GetXMLAttribute(node, "Text")
          If edText = "" : edText = GetXMLNodeText(node) : EndIf
          Protected *ed.UI::Editor = New UI::Editor()
          If edText <> "" : *ed\SetText(edText) : EndIf
          This\ApplyCommonAttributes(*ed, node, *targetWindow)
          *createdComp = *ed

        Case "RADIOBUTTON", "OPTION"
          Protected rbText.s = GetXMLAttribute(node, "Text")
          If rbText = "" : rbText = GetXMLNodeText(node) : EndIf
          Protected rbChkStr.s = UCase(Trim(GetXMLAttribute(node, "Checked")))
          Protected rbChk.b = #False
          If rbChkStr = "TRUE" Or rbChkStr = "1" : rbChk = #True : EndIf
          Protected *rb.UI::RadioButton = New UI::RadioButton(rbText, rbChk)
          Protected rbGrp.s = GetXMLAttribute(node, "Group")
          If rbGrp <> "" : *rb\SetGroup(Val(rbGrp)) : EndIf
          This\ApplyCommonAttributes(*rb, node, *targetWindow)
          *createdComp = *rb

        Case "LISTVIEW"
          Protected *lv.UI::ListView = New UI::ListView()
          Protected lvItems.s = GetXMLAttribute(node, "Items")
          If lvItems <> ""
            Protected lviCount.i = CountString(lvItems, ",") + 1
            Protected lvi.i
            For lvi = 1 To lviCount
              *lv\AddItem(Trim(StringField(lvItems, lvi, ",")))
            Next
          EndIf
          This\ApplyCommonAttributes(*lv, node, *targetWindow)
          *createdComp = *lv
          Protected *lvItemNode = ChildXMLNode(node)
          While *lvItemNode
            If XMLNodeType(*lvItemNode) = #PB_XML_Normal And UCase(GetXMLNodeName(*lvItemNode)) = "ITEM"
              Protected lvItemText.s = GetXMLAttribute(*lvItemNode, "Text")
              If lvItemText = "" : lvItemText = GetXMLNodeText(*lvItemNode) : EndIf
              *lv\AddItem(lvItemText)
            EndIf
            *lvItemNode = NextXMLNode(*lvItemNode)
          Wend

        Case "SPINBOX", "SPIN"
          Protected spMin.i = Val(GetXMLAttribute(node, "Min"))
          Protected spMax.i = Val(GetXMLAttribute(node, "Max"))
          If spMax <= spMin : spMax = 100 : EndIf
          Protected spVal.i = Val(GetXMLAttribute(node, "Value"))
          Protected *sp.UI::SpinBox = New UI::SpinBox(spMin, spMax, spVal)
          This\ApplyCommonAttributes(*sp, node, *targetWindow)
          *createdComp = *sp

        Case "GROUPBOX", "FRAME"
          Protected gbText.s = GetXMLAttribute(node, "Text")
          If gbText = "" : gbText = GetXMLAttribute(node, "Caption") : EndIf
          Protected *gb.UI::GroupBox = New UI::GroupBox(gbText)
          This\ApplyCommonAttributes(*gb, node, *targetWindow)
          *createdComp = *gb

        Case "TREEVIEW", "TREE"
          Protected *tv.UI::TreeView = New UI::TreeView()
          This\ApplyCommonAttributes(*tv, node, *targetWindow)
          *createdComp = *tv

        Case "DATEPICKER", "DATE"
          Protected dpMask.s = GetXMLAttribute(node, "Mask")
          If dpMask = "" : dpMask = "%dd/%mm/%yyyy" : EndIf
          Protected *dp.UI::DatePicker = New UI::DatePicker(dpMask)
          This\ApplyCommonAttributes(*dp, node, *targetWindow)
          *createdComp = *dp

        Case "TABCONTROL", "PANEL"
          Protected *tc.UI::TabControl = New UI::TabControl()
          This\ApplyCommonAttributes(*tc, node, *targetWindow)
          *createdComp = *tc
          Protected *tabNode = ChildXMLNode(node)
          While *tabNode
            If XMLNodeType(*tabNode) = #PB_XML_Normal And (UCase(GetXMLNodeName(*tabNode)) = "TAB" Or UCase(GetXMLNodeName(*tabNode)) = "ITEM")
              Protected tabTitle.s = GetXMLAttribute(*tabNode, "Title")
              If tabTitle = "" : tabTitle = GetXMLAttribute(*tabNode, "Text") : EndIf
              *tc\AddTab(tabTitle)
            EndIf
            *tabNode = NextXMLNode(*tabNode)
          Wend

        Case "CANVAS"
          Protected *cv.UI::Canvas = New UI::Canvas()
          This\ApplyCommonAttributes(*cv, node, *targetWindow)
          *createdComp = *cv

        Case "CANVASTREE"
          Protected *ct.UI::CanvasTree = New UI::CanvasTree()
          Protected ctChkStr.s = UCase(Trim(GetXMLAttribute(node, "ShowCheckBoxes")))
          If ctChkStr = "TRUE" Or ctChkStr = "1" : *ct\SetShowCheckBoxes(#True) : EndIf
          Protected ctLineStr.s = UCase(Trim(GetXMLAttribute(node, "ShowLines")))
          If ctLineStr = "FALSE" Or ctLineStr = "0" : *ct\SetShowLines(#False) : EndIf
          Protected ctLineHStr.s = GetXMLAttribute(node, "LineHeight")
          If ctLineHStr <> "" : *ct\SetLineHeight(Val(ctLineHStr)) : EndIf
          Protected ctDarkStr.s = UCase(Trim(GetXMLAttribute(node, "DarkMode")))
          If ctDarkStr = "TRUE" Or ctDarkStr = "1" : *ct\SetDarkMode(#True) : EndIf

          This\ApplyCommonAttributes(*ct, node, *targetWindow)
          *createdComp = *ct

          ; Parse child <Node> tags recursively
          This\ParseCanvasTreeNodes(*ct, *ct\GetRoot(), node)

        Case "CANVASTABLE", "TABLE", "DATAGRID"
          Protected *ctbl.UI::CanvasTable = New UI::CanvasTable()
          Protected ctblDark.s = UCase(Trim(GetXMLAttribute(node, "DarkMode")))
          If ctblDark = "TRUE" Or ctblDark = "1" : *ctbl\SetDarkMode(#True) : EndIf
          Protected ctblHdr.s = UCase(Trim(GetXMLAttribute(node, "ShowHeader")))
          If ctblHdr = "FALSE" Or ctblHdr = "0" : *ctbl\SetShowHeader(#False) : EndIf
          Protected ctblGrid.s = UCase(Trim(GetXMLAttribute(node, "ShowGridLines")))
          If ctblGrid = "FALSE" Or ctblGrid = "0" : *ctbl\SetShowGridLines(#False) : EndIf
          Protected ctblAlt.s = UCase(Trim(GetXMLAttribute(node, "ShowAlternatingColors")))
          If ctblAlt = "" : ctblAlt = UCase(Trim(GetXMLAttribute(node, "AlternatingColors"))) : EndIf
          If ctblAlt = "FALSE" Or ctblAlt = "0" : *ctbl\SetShowAlternatingColors(#False) : EndIf

          Protected ctblEvenBg.s = GetXMLAttribute(node, "EvenRowBg")
          If ctblEvenBg = "" : ctblEvenBg = GetXMLAttribute(node, "PairBg") : EndIf
          Protected ctblEvenFg.s = GetXMLAttribute(node, "EvenRowFg")
          If ctblEvenFg = "" : ctblEvenFg = GetXMLAttribute(node, "PairFg") : EndIf
          If ctblEvenBg <> "" Or ctblEvenFg <> ""
            Protected eBg.i = *ctbl\GetEvenRowBgColor()
            Protected eFg.i = *ctbl\GetEvenRowFgColor()
            If ctblEvenBg <> "" : eBg = This\ParseColor(ctblEvenBg, eBg) : EndIf
            If ctblEvenFg <> "" : eFg = This\ParseColor(ctblEvenFg, eFg) : EndIf
            *ctbl\SetEvenRowColors(eBg, eFg)
          EndIf

          Protected ctblOddBg.s = GetXMLAttribute(node, "OddRowBg")
          If ctblOddBg = "" : ctblOddBg = GetXMLAttribute(node, "DootBg") : EndIf
          If ctblOddBg = "" : ctblOddBg = GetXMLAttribute(node, "AltRowBg") : EndIf
          Protected ctblOddFg.s = GetXMLAttribute(node, "OddRowFg")
          If ctblOddFg = "" : ctblOddFg = GetXMLAttribute(node, "DootFg") : EndIf
          If ctblOddFg = "" : ctblOddFg = GetXMLAttribute(node, "AltRowFg") : EndIf
          If ctblOddBg <> "" Or ctblOddFg <> ""
            Protected oBg.i = *ctbl\GetOddRowBgColor()
            Protected oFg.i = *ctbl\GetOddRowFgColor()
            If ctblOddBg <> "" : oBg = This\ParseColor(ctblOddBg, oBg) : EndIf
            If ctblOddFg <> "" : oFg = This\ParseColor(ctblOddFg, oFg) : EndIf
            *ctbl\SetOddRowColors(oBg, oFg)
          EndIf

          Protected ctblLineH.s = GetXMLAttribute(node, "LineHeight")
          If ctblLineH <> "" : *ctbl\SetLineHeight(Val(ctblLineH)) : EndIf
          Protected ctblHdrH.s = GetXMLAttribute(node, "HeaderHeight")
          If ctblHdrH <> "" : *ctbl\SetHeaderHeight(Val(ctblHdrH)) : EndIf

          This\ApplyCommonAttributes(*ctbl, node, *targetWindow)
          *createdComp = *ctbl

          This\ParseCanvasTableColumnsAndRows(*ctbl, node)

        Case "CANVASBUTTON"
          Protected cbtnText.s = GetXMLAttribute(node, "Text")
          If cbtnText = "" : cbtnText = GetXMLAttribute(node, "text") : EndIf
          Protected *cbtn.UI::CanvasButton = New UI::CanvasButton()
          If cbtnText <> "" : *cbtn\SetText(cbtnText) : EndIf

          Protected btnVar.s = UCase(Trim(GetXMLAttribute(node, "Variant")))
          If btnVar = "" : btnVar = UCase(Trim(GetXMLAttribute(node, "Style"))) : EndIf
          Select btnVar
            Case "PRIMARY" : *cbtn\SetPrimaryStyle()
            Case "SUCCESS" : *cbtn\SetSuccessStyle()
            Case "DANGER"  : *cbtn\SetDangerStyle()
            Case "DARK"    : *cbtn\SetDarkStyle()
            Case "OUTLINE" : *cbtn\SetOutlineStyle(RGB(37, 99, 235))
            Case "GHOST"   : *cbtn\SetGhostStyle(RGB(17, 24, 39))
            Default        : *cbtn\SetDefaultStyle()
          EndSelect

          Protected btnRad.s = GetXMLAttribute(node, "CornerRadius")
          If btnRad <> "" : *cbtn\SetCornerRadius(Val(btnRad)) : EndIf

          Protected btnAlignStr.s = UCase(Trim(GetXMLAttribute(node, "HAlign")))
          If btnAlignStr = "" : btnAlignStr = UCase(Trim(GetXMLAttribute(node, "TextAlignment"))) : EndIf
          If btnAlignStr = "LEFT"
            *cbtn\SetTextAlignment(1)
          ElseIf btnAlignStr = "RIGHT"
            *cbtn\SetTextAlignment(2)
          ElseIf btnAlignStr = "CENTER"
            *cbtn\SetTextAlignment(0)
          EndIf

          This\ApplyCommonAttributes(*cbtn, node, *targetWindow)
          This\ApplyCanvasControlAttributes(*cbtn, node, *targetWindow, *parentContainer)
          *createdComp = *cbtn

        Case "CANVASTEXT"
          Protected ctxtText.s = GetXMLAttribute(node, "Text")
          If ctxtText = "" : ctxtText = GetXMLAttribute(node, "text") : EndIf
          If ctxtText = "" : ctxtText = GetXMLNodeText(node) : EndIf
          Protected *ctxt.UI::CanvasText = New UI::CanvasText()
          If ctxtText <> "" And Left(ctxtText, 1) <> "{"
            *ctxt\SetText(ctxtText)
          EndIf

          Protected ctxthAlignStr.s = UCase(Trim(GetXMLAttribute(node, "HAlign")))
          If ctxthAlignStr = "" : ctxthAlignStr = UCase(Trim(GetXMLAttribute(node, "TextAlignment"))) : EndIf
          Protected hAlignCode.i = #UI_TextAlign_Left
          Select ctxthAlignStr
            Case "CENTER" : hAlignCode = #UI_TextAlign_Center
            Case "RIGHT"  : hAlignCode = #UI_TextAlign_Right
          EndSelect

          Protected ctxtvAlignStr.s = UCase(Trim(GetXMLAttribute(node, "VAlign")))
          Protected vAlignCode.i = #UI_TextAlign_Middle
          Select ctxtvAlignStr
            Case "TOP"    : vAlignCode = #UI_TextAlign_Top
            Case "BOTTOM" : vAlignCode = #UI_TextAlign_Bottom
          EndSelect

          *ctxt\SetAlignment(hAlignCode, vAlignCode)

          Protected ctxtEllipsis.s = UCase(Trim(GetXMLAttribute(node, "Ellipsis")))
          If ctxtEllipsis = "FALSE" Or ctxtEllipsis = "0" : *ctxt\SetEllipsis(#False) : EndIf

          Protected ctxtTrans.s = UCase(Trim(GetXMLAttribute(node, "Transparent")))
          If ctxtTrans = "FALSE" Or ctxtTrans = "0" : *ctxt\SetTransparent(#False) : EndIf

          This\ApplyCommonAttributes(*ctxt, node, *targetWindow)
          This\ApplyCanvasControlAttributes(*ctxt, node, *targetWindow, *parentContainer)
          *createdComp = *ctxt

        Case "CANVASTEXTBOX"
          Protected ctbText.s = GetXMLAttribute(node, "Text")
          If ctbText = "" : ctbText = GetXMLAttribute(node, "text") : EndIf
          Protected ctbPH.s = GetXMLAttribute(node, "Placeholder")
          If ctbPH = "" : ctbPH = GetXMLAttribute(node, "placeholder") : EndIf

          Protected *ctb.UI::CanvasTextBox = New UI::CanvasTextBox()
          If ctbText <> "" And Left(ctbText, 1) <> "{"
            *ctb\SetText(ctbText)
          EndIf
          If ctbPH <> "" : *ctb\SetPlaceholder(ctbPH) : EndIf

          Protected ctbPHCol.s = GetXMLAttribute(node, "PlaceholderColor")
          If ctbPHCol <> ""
            *ctb\SetPlaceholderColor(This\ParseColor(ctbPHCol, *ctb\GetPlaceholderColor()))
          EndIf

          Protected ctbActCol.s = GetXMLAttribute(node, "ActiveBorderColor")
          If ctbActCol = "" : ctbActCol = GetXMLAttribute(node, "FocusBorderColor") : EndIf
          If ctbActCol <> ""
            *ctb\SetActiveBorderColor(This\ParseColor(ctbActCol, *ctb\GetActiveBorderColor()))
          EndIf

          Protected ctbPassStr.s = UCase(Trim(GetXMLAttribute(node, "IsPassword")))
          If ctbPassStr = "TRUE" Or ctbPassStr = "1" : *ctb\SetIsPassword(#True) : EndIf

          Protected ctbROStr.s = UCase(Trim(GetXMLAttribute(node, "IsReadOnly")))
          If ctbROStr = "TRUE" Or ctbROStr = "1" : *ctb\SetReadOnly(#True) : EndIf

          Protected ctbMaxLStr.s = GetXMLAttribute(node, "MaxLength")
          If ctbMaxLStr <> "" : *ctb\SetMaxLength(Val(ctbMaxLStr)) : EndIf

          This\ApplyCommonAttributes(*ctb, node, *targetWindow)
          This\ApplyCanvasControlAttributes(*ctb, node, *targetWindow, *parentContainer)
          *createdComp = *ctb

      EndSelect

      ProcedureReturn *createdComp
    }

    ; ------------------------------------------------------------------------
    ; Public Entry Points: LoadFromFile and LoadFromString
    ; ------------------------------------------------------------------------
    Public Method.b LoadFromFile(xmlPath.s, *targetWindow.UI::Window) {
      Protected actualPath.s = xmlPath
      If FileSize(actualPath) <= 0
        CompilerIf Defined(OOP_PROJECT_DIR, #PB_Constant)
          If FileSize(#OOP_PROJECT_DIR + xmlPath) > 0
            actualPath = #OOP_PROJECT_DIR + xmlPath
          ElseIf FileSize(#OOP_PROJECT_DIR + "views/" + GetFilePart(xmlPath)) > 0
            actualPath = #OOP_PROJECT_DIR + "views/" + GetFilePart(xmlPath)
          ElseIf FileSize(#OOP_PROJECT_DIR + GetFilePart(xmlPath)) > 0
            actualPath = #OOP_PROJECT_DIR + GetFilePart(xmlPath)
          EndIf
        CompilerEndIf
      EndIf

      If FileSize(actualPath) <= 0
        CompilerIf Defined(OOP_WORKSPACE_DIR, #PB_Constant)
          If FileSize(#OOP_WORKSPACE_DIR + xmlPath) > 0
            actualPath = #OOP_WORKSPACE_DIR + xmlPath
          ElseIf FileSize(#OOP_WORKSPACE_DIR + "examples/07_project_dashboard/" + xmlPath) > 0
            actualPath = #OOP_WORKSPACE_DIR + "examples/07_project_dashboard/" + xmlPath
          ElseIf FileSize(#OOP_WORKSPACE_DIR + "examples/07_project_dashboard/views/" + GetFilePart(xmlPath)) > 0
            actualPath = #OOP_WORKSPACE_DIR + "examples/07_project_dashboard/views/" + GetFilePart(xmlPath)
          EndIf
        CompilerEndIf
      EndIf

      If FileSize(actualPath) <= 0
        If FileSize(GetPathPart(ProgramFilename()) + xmlPath) > 0
          actualPath = GetPathPart(ProgramFilename()) + xmlPath
        ElseIf FileSize(GetPathPart(ProgramFilename()) + GetFilePart(xmlPath)) > 0
          actualPath = GetPathPart(ProgramFilename()) + GetFilePart(xmlPath)
        ElseIf FileSize("tests/" + xmlPath) > 0
          actualPath = "tests/" + xmlPath
        ElseIf FileSize("examples/07_project_dashboard/" + xmlPath) > 0
          actualPath = "examples/07_project_dashboard/" + xmlPath
        EndIf
      EndIf

      If FileSize(actualPath) <= 0
        MessageRequester("PureBasic OOP - UI Error", "Impossible de charger la vue XML :" + #LF$ + xmlPath + #LF$ + #LF$ + "Fichier introuvable sur le disque.", #PB_MessageRequester_Error)
        ProcedureReturn #False
      EndIf

      This\currentXmlDir = GetPathPart(actualPath)

      Protected xmlHandle.i = LoadXML(#PB_Any, actualPath)
      If Not xmlHandle Or XMLStatus(xmlHandle) <> #PB_XML_Success
        Protected errTxt.s = "Erreur de syntaxe XML dans : " + actualPath
        If xmlHandle
          errTxt + #LF$ + "Ligne " + Str(XMLErrorLine(xmlHandle)) + " : " + XMLError(xmlHandle)
          FreeXML(xmlHandle)
        EndIf
        MessageRequester("PureBasic OOP - Erreur XML", errTxt, #PB_MessageRequester_Error)
        ProcedureReturn #False
      EndIf

      Protected *mainNode = MainXMLNode(xmlHandle)
      If *mainNode
        This\ParseNode(*mainNode, *targetWindow, 0)
      EndIf

      FreeXML(xmlHandle)
      ProcedureReturn #True
    }

    Public Method.b LoadFromString(xmlContent.s, *targetWindow.UI::Window) {
      If xmlContent = ""
        ProcedureReturn #False
      EndIf

      Protected xmlHandle.i = ParseXML(#PB_Any, xmlContent)
      If Not xmlHandle Or XMLStatus(xmlHandle) <> #PB_XML_Success
        If xmlHandle : FreeXML(xmlHandle) : EndIf
        ProcedureReturn #False
      EndIf

      Protected *mainNode = MainXMLNode(xmlHandle)
      If *mainNode
        This\ParseNode(*mainNode, *targetWindow, 0)
      EndIf

      FreeXML(xmlHandle)
      ProcedureReturn #True
    }

  }

}
