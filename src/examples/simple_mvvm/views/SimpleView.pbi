; ============================================================================
; PureBasic OOP MVVM - SimpleView.pbi
; Code-behind for SimpleView.xml with Timer-based Hover Detection
; Author:      MicrodevWeb
; ============================================================================

XIncludeFile "../../../ui/UI.pbi"
XIncludeFile "../viewmodels/SimpleViewModel.pbi"

Namespace Demo::Views {

  Class SimpleView Extends UI::Window {
    Protected *viewModel.Demo::ViewModels::SimpleViewModel
    Protected lastHoveredBtn.i

    Public Method Init(*vm.Demo::ViewModels::SimpleViewModel) {
      Super::Init()
      This\*viewModel = *vm
      This\lastHoveredBtn = 0

      ; 1. Resolve XML file path
      Protected xmlFile.s = #PB_Compiler_FilePath + "SimpleView.xml"
      If Not FileSize(xmlFile) > 0
        xmlFile = #PB_Compiler_FilePath + "views/SimpleView.xml"
      EndIf
      If Not FileSize(xmlFile) > 0
        xmlFile = GetPathPart(ProgramFilename()) + "views/SimpleView.xml"
      EndIf
      If Not FileSize(xmlFile) > 0
        xmlFile = GetPathPart(ProgramFilename()) + "SimpleView.xml"
      EndIf
      If Not FileSize(xmlFile) > 0
        xmlFile = "src/examples/simple_mvvm/views/SimpleView.xml"
      EndIf
      If Not FileSize(xmlFile) > 0
        xmlFile = "views/SimpleView.xml"
      EndIf

      ; 2. Load declarative view with DataContext (ViewModel)
      Protected loaded.b = #False
      If FileSize(xmlFile) > 0
        loaded = This\LoadView(xmlFile, *vm)
      EndIf

      If Not loaded
        ; Embedded fallback XML
        Protected defaultXml.s = "<Window Title='PureBasic OOP - Simple MVVM Test' Width='560' Height='400'>" +
          "<DockPanel LastChildFill='true'>" +
          "  <StackPanel Dock='Top' Orientation='Vertical' Margin='15,10,15,5'>" +
          "    <Label Text='MVVM DataBinding and Hover Test' Height='24'/>" +
          "  </StackPanel>" +
          "  <StackPanel Dock='Bottom' Orientation='Horizontal' Margin='15,5' Height='26'>" +
          "    <Label Text='{Binding StatusText}' Width='500' Height='20'/>" +
          "  </StackPanel>" +
          "  <StackPanel Dock='Fill' Orientation='Vertical' Spacing='8' Margin='15,10'>" +
          "    <Label Text='Actions (Click or Hover):' Height='20'/>" +
          "    <StackPanel Orientation='Horizontal' Spacing='10' Height='36'>" +
          "      <Button Name='btn1' Text='Button 1' Click='ClickBtn1' Width='100' Height='32'/>" +
          "      <Button Name='btn2' Text='Button 2' Click='ClickBtn2' Width='100' Height='32'/>" +
          "      <Button Name='btn3' Text='Button 3' Click='ClickBtn3' Width='100' Height='32'/>" +
          "      <Button Name='btnReset' Text='Reset' Click='Reset' Width='90' Height='32'/>" +
          "    </StackPanel>" +
          "    <Label Text='Click Notification:' Margin='0,5,0,0' Height='20'/>" +
          "    <TextBox Name='txtClick' Text='{Binding ClickMessage}' Height='28'/>" +
          "    <Label Text='Hover Notification:' Margin='0,5,0,0' Height='20'/>" +
          "    <TextBox Name='txtHover' Text='{Binding HoverMessage}' Height='28'/>" +
          "    <Label Text='{Binding TotalClicksText}' Margin='0,5,0,0' Height='22'/>" +
          "  </StackPanel>" +
          "</DockPanel>" +
          "</Window>"
        loaded = This\LoadViewFromString(defaultXml, *vm)
      EndIf

      If Not loaded
        MessageRequester("Error", "Failed to load SimpleView.")
        ProcedureReturn
      EndIf

      ; 3. Start Window Timer for hover detection (50 ms interval)
      If This\GetID() And IsWindow(This\GetID())
        AddWindowTimer(This\GetID(), 100, 50)
      EndIf
    }

    Public Method OnTimer(timerId.i) {
      If timerId = 100 And This\GetID() And IsWindow(This\GetID()) And This\*viewModel
        Protected mx.i = WindowMouseX(This\GetID())
        Protected my.i = WindowMouseY(This\GetID())

        Protected *btn1.UI::Component = This\FindControl("btn1")
        Protected *btn2.UI::Component = This\FindControl("btn2")
        Protected *btn3.UI::Component = This\FindControl("btn3")
        Protected *btnReset.UI::Component = This\FindControl("btnReset")

        Protected hovered.i = 0
        If *btn1 And mx >= *btn1\GetX() And mx <= *btn1\GetX() + *btn1\GetWidth() And my >= *btn1\GetY() And my <= *btn1\GetY() + *btn1\GetHeight()
          hovered = 1
        ElseIf *btn2 And mx >= *btn2\GetX() And mx <= *btn2\GetX() + *btn2\GetWidth() And my >= *btn2\GetY() And my <= *btn2\GetY() + *btn2\GetHeight()
          hovered = 2
        ElseIf *btn3 And mx >= *btn3\GetX() And mx <= *btn3\GetX() + *btn3\GetWidth() And my >= *btn3\GetY() And my <= *btn3\GetY() + *btn3\GetHeight()
          hovered = 3
        ElseIf *btnReset And mx >= *btnReset\GetX() And mx <= *btnReset\GetX() + *btnReset\GetWidth() And my >= *btnReset\GetY() And my <= *btnReset\GetY() + *btnReset\GetHeight()
          hovered = 4
        EndIf

        If hovered <> This\lastHoveredBtn
          This\lastHoveredBtn = hovered
          If hovered = 1
            This\*viewModel\OnHoverButton(1)
          ElseIf hovered = 2
            This\*viewModel\OnHoverButton(2)
          ElseIf hovered = 3
            This\*viewModel\OnHoverButton(3)
          ElseIf hovered = 4
            This\*viewModel\SetString("HoverMessage", "You are hovering Reset Button")
          Else
            This\*viewModel\OnHoverButton(0)
          EndIf
        EndIf
      EndIf
    }
  }

}
