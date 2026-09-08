; ============================================================================
; Demo WPF Styles & Micro-Animations Showcase
; ============================================================================

XIncludeFile "../framework/UI.pbi"

Procedure RunWpfStylesApp()
  Protected *app.UI::Application = New UI::Application()
  Protected *win.UI::Window = New UI::Window()

  Protected xmlPath.s = "demo_wpf_styles.xml"
  If FileSize(xmlPath) <= 0
    xmlPath = "tests/demo_wpf_styles.xml"
  EndIf

  Protected *loader.UI::XMLLoader = New UI::XMLLoader()
  Protected loaded.b = *loader\LoadFromFile(xmlPath, *win)
  *loader\Free()

  If (loaded)
    *app\SetMainWindow(*win)
    *app\Run()
  EndIf

  *win\Free()
  *app\Free()
EndProcedure

RunWpfStylesApp()
