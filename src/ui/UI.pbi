; ============================================================================
; PureBasic OOP GUI Framework - UI.pbi (Master Header)
; Include this file to access the entire OOP UI subsystem
; Author:      MicrodevWeb
; ============================================================================

XIncludeFile "Component.pbi"
XIncludeFile "Gadget.pbi"
XIncludeFile "CustomGadget.pbi"

; MVVM (Model-View-ViewModel) Architecture
XIncludeFile "mvvm/MVVM.pbi"

; Responsive Layouts (WPF-Style)
XIncludeFile "layout/Container.pbi"
XIncludeFile "layout/StackPanel.pbi"
XIncludeFile "layout/DockPanel.pbi"
XIncludeFile "layout/Grid.pbi"

; Standard Controls
XIncludeFile "controls/Button.pbi"
XIncludeFile "controls/TextBox.pbi"
XIncludeFile "controls/Label.pbi"
XIncludeFile "controls/CheckBox.pbi"
XIncludeFile "controls/ProgressBar.pbi"
XIncludeFile "controls/Slider.pbi"
XIncludeFile "controls/ComboBox.pbi"

; Custom Controls
XIncludeFile "controls/ToggleSwitch.pbi"
XIncludeFile "controls/ListIcon.pbi"

; Declarative XML / XAML Layout Loader
XIncludeFile "XMLLoader.pbi"

; Window & Application Dispatcher
XIncludeFile "Window.pbi"
XIncludeFile "Application.pbi"

