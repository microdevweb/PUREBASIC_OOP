OpenConsole()
xmlPath.s = "demo_canvas_xml.xml"
If FileSize(xmlPath) <= 0
  xmlPath = "tests/demo_canvas_xml.xml"
EndIf
PrintN("Checking: " + xmlPath + " size=" + Str(FileSize(xmlPath)))
h = LoadXML(#PB_Any, xmlPath)
If Not h
  PrintN("LoadXML returned 0")
Else
  status = XMLStatus(h)
  PrintN("XMLStatus: " + Str(status))
  If status <> #PB_XML_Success
    PrintN("XMLError: " + XMLError(h) + " at line " + Str(XMLErrorLine(h)) + " col " + Str(XMLErrorPosition(h)))
  Else
    PrintN("XML Loaded successfully!")
  EndIf
  FreeXML(h)
EndIf
CloseConsole()
