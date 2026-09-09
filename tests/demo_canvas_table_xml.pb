; ============================================================================
; PureBasic OOP GUI Framework - demo_canvas_table_xml.pb
; Declarative XML Loading of UI::CanvasTable
; ============================================================================

Procedure RunXmlDemo()
  Protected xml.s = ""
  xml + "<Window Title='Test XML CanvasTable' Width='700' Height='450' BackgroundColor='#F8FAFC'>" + #CRLF$
  xml + "  <DockPanel LastChildFill='True'>" + #CRLF$
  xml + "    <Label Text='Tableau déclaré en XML pur (XMLLoader)' Height='36' Margin='12,8,12,0' Dock='Top' />" + #CRLF$
  xml + "    <CanvasTable Name='myXmlTable' Dock='Fill' Margin='12,4,12,12' LineHeight='32' HeaderHeight='36' ShowAlternatingColors='True' ShowGridLines='True'>" + #CRLF$
  xml + "      <Column Title='Code' Width='80' Type='Text' Align='Center' />" + #CRLF$
  xml + "      <Column Title='Désignation' Width='220' Type='Text' Align='Left' Editable='True' />" + #CRLF$
  xml + "      <Column Title='Quantité' Width='90' Type='Number' Align='Right' Editable='True' />" + #CRLF$
  xml + "      <Column Title='Prix Unit.' Width='100' Type='Float' Align='Right' Editable='True' />" + #CRLF$
  xml + "      <Column Title='En Stock' Width='80' Type='CheckBox' Align='Center' />" + #CRLF$
  xml + "      <Row Cells='PRD-001;Clavier Mécanique RGB;15;89.90;1' />" + #CRLF$
  xml + "      <Row Cells='PRD-002;Souris Sans-Fil 16000 DPI;42;49.50;1' />" + #CRLF$
  xml + "      <Row Cells='PRD-003;Écran 27 pouces 4K UHD;8;349.00;1' />" + #CRLF$
  xml + "      <Row Cells='PRD-004;Casque Audio Hi-Fi;0;129.99;0' />" + #CRLF$
  xml + "      <Row Cells='PRD-005;Tapis de Souris XXL;120;19.90;1' />" + #CRLF$
  xml + "    </CanvasTable>" + #CRLF$
  xml + "  </DockPanel>" + #CRLF$
  xml + "</Window>"

  Protected *app.UI::Application = New UI::Application()
  Protected *win.UI::Window = New UI::Window()
  Protected *loader.UI::XMLLoader = New UI::XMLLoader()
  Protected loaded.b = *loader\LoadFromString(xml, *win)
  *loader\Free()

  If (loaded)
    *app\SetMainWindow(*win)
    *app\Run()
  EndIf
EndProcedure

RunXmlDemo()
