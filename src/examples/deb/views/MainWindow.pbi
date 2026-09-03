
XIncludeFile "../../../ui/UI.pbi"
Using UI
Using UI::Controls
Using UI::Layouts

Class MainWindow Extends UI::Window
  ; BUTTONS
  Private *bt_new.UI::Button
  Private *bt_edit.UI::Button
  Private *bt_delete.UI::Button
  ; LAYOUT
  Private *main_layout.UI::Layouts::DockPanel
  Private *button_layout.UI::Layouts::StackPanel
  Public Method Init() 
    Super::Init("Contact V1")
    ; Instanciate buttons
    This\*bt_new = New UI::Button("add")
    ;This\*bt_new\SetSize(110,30)
    This\*bt_edit = New UI::Button("edit")
    ;This\*bt_edit\SetSize(110,30)
    This\*bt_delete = New UI::Button("delete")
    ;This\*bt_delete\SetSize(110,30)
    ; Instanciate layouts
    ; = button layout
    This\*button_layout = New UI::Layouts::StackPanel()
    This\*button_layout\SetMargin(10,10,10,10)
    This\*button_layout\SetOrientation(#UI_Orientation_Horizontal)
    This\*button_layout\AddChild(This\*bt_new)
    This\*button_layout\AddChild(This\*bt_edit)
    This\*button_layout\AddChild(This\*bt_delete)
    ; = main layout
    This\*main_layout = New UI::Layouts::DockPanel
    This\*main_layout\SetDock(This\*button_layout,#UI_Dock_Top)
    This\SetContent(This\*main_layout)
  EndMethod
EndClass
; IDE Options = PureBasic 6.40 (Windows - x64)
; CursorPosition = 22
; EnableXP
; DPIAware