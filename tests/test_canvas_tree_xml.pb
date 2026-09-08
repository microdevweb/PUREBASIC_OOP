; ============================================================================
; Test: test_canvas_tree_xml.pb
; Validates declarative XML loading of UI::CanvasTree with XMLLoader
; ============================================================================

XIncludeFile "../framework/UI.pbi"

Procedure RunXmlTest()
  Protected *app.UI::Application = New UI::Application()
  Protected *win.UI::Window = New UI::Window("Test XML CanvasTree", 600, 450)
  *app\SetMainWindow(*win)

  Protected xml.s = "<Window Width='600' Height='450'>" +
                    "  <DockPanel LastChildFill='True'>" +
                    "    <CanvasTree Name='MyTree' Dock='Fill' ShowCheckBoxes='True' ShowLines='True' LineHeight='30'>" +
                    "      <Node Text='Racine 1' Expanded='True'>" +
                    "        <Node Text='Enfant 1.1' Checked='True'/>" +
                    "        <Node Text='Enfant 1.2'/>" +
                    "      </Node>" +
                    "      <Node Text='Racine 2'>" +
                    "        <Node Text='Enfant 2.1'/>" +
                    "      </Node>" +
                    "    </CanvasTree>" +
                    "  </DockPanel>" +
                    "</Window>"

  Protected *loader.UI::XMLLoader = New UI::XMLLoader()
  Protected res.b = *loader\LoadFromString(xml, *win)

  If res
    Protected *tree.UI::CanvasTree = *win\FindControl("MyTree")
    If *tree
      ; Validate node counts
      Protected *root.UI::TreeNode = *tree\GetRoot()
      If *root\GetChildCount() = 2
        ; Success
      EndIf
    EndIf
  EndIf

  *loader\Free()
  *win\Free()
  *app\Free()
EndProcedure

RunXmlTest()
End
