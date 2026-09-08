; ============================================================================
; Demo XML Declarative WPF CanvasControls
; ============================================================================

XIncludeFile "../framework/UI.pbi"

Procedure RunXmlApp()
  Protected *app.UI::Application = New UI::Application()
  Protected *win.UI::Window = New UI::Window()

  Protected xmlPath.s = "demo_canvas_xml.xml"
  If FileSize(xmlPath) <= 0
    xmlPath = "tests/demo_canvas_xml.xml"
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

RunXmlApp()
