; ============================================================================
; PureBasic OOP - Contextual Help System
; Dispatches F1 on OOP keywords and UI classes to dedicated HTML documentation
; ============================================================================

Procedure.s GetOOPHelpPage(Keyword.s)
  Protected kw.s = LCase(Trim(Keyword))
  
  ; Strip trailing punctuation or prefixes if any
  If Left(kw, 1) = "*" Or Left(kw, 1) = "#" Or Left(kw, 1) = "@"
    kw = Mid(kw, 2)
  EndIf
  
  Select kw
    ; OOP Keywords
    Case "class", "endclass", "abstract"
      ProcedureReturn "keywords/class.html"
      
    Case "method", "endmethod", "abstract method", "override"
      ProcedureReturn "keywords/method.html"
      
    Case "getter", "setter", "property", "endgetter", "endsetter", "endproperty"
      ProcedureReturn "keywords/properties.html"
      
    Case "extends", "super"
      ProcedureReturn "keywords/inheritance.html"
      
    Case "public", "protected", "private"
      ProcedureReturn "keywords/encapsulation.html"
      
    Case "new", "free", "init", "constructor", "destructor", "newobject", "freeobject"
      ProcedureReturn "keywords/lifecycle.html"
      
    Case "this", "cast", "typeof", "instanceof"
      ProcedureReturn "keywords/operators.html"
      
    ; UI Classes & Framework
    Case "application"
      ProcedureReturn "ui/application.html"
      
    Case "window"
      ProcedureReturn "ui/window.html"
      
    Case "gadget", "component", "customgadget"
      ProcedureReturn "ui/gadget.html"
      
    Case "button"
      ProcedureReturn "ui/button.html"
      
    Case "checkbox"
      ProcedureReturn "ui/checkbox.html"
      
    Case "combobox"
      ProcedureReturn "ui/combobox.html"
      
    Case "label"
      ProcedureReturn "ui/label.html"
      
    Case "progressbar"
      ProcedureReturn "ui/progressbar.html"
      
    Case "slider"
      ProcedureReturn "ui/slider.html"
      
    Case "textbox"
      ProcedureReturn "ui/textbox.html"
      
    Case "toggleswitch"
      ProcedureReturn "ui/toggleswitch.html"
      
    Default
      ProcedureReturn ""
  EndSelect
EndProcedure

Procedure.i OpenOOPHelp(PageSubPath.s)
  Protected LangFolder.s = "en"
  If UCase(CurrentLanguage$) = "FRANCAIS"
    LangFolder = "fr"
  EndIf
  
  If PageSubPath = ""
    PageSubPath = "index.html"
  EndIf
  
  ; Look in workspace / executable directory
  Protected AppDir.s = GetPathPart(ProgramFilename())
  Protected DocFilePath.s = AppDir + "doc\html\" + LangFolder + "\" + ReplaceString(PageSubPath, "/", "\")
  
  ; Fallback check relative to current working directory
  If FileSize(DocFilePath) <= 0
    DocFilePath = GetCurrentDirectory() + "doc\html\" + LangFolder + "\" + ReplaceString(PageSubPath, "/", "\")
  EndIf
  
  ; Fallback check in parent directory
  If FileSize(DocFilePath) <= 0
    DocFilePath = GetPathPart(RTrim(AppDir, "\")) + "doc\html\" + LangFolder + "\" + ReplaceString(PageSubPath, "/", "\")
  EndIf
  
  If FileSize(DocFilePath) > 0
    RunProgram(DocFilePath)
    ProcedureReturn #True
  Else
    Protected FileUrl.s = "file:///" + ReplaceString(DocFilePath, "\", "/")
    RunProgram(FileUrl)
    ProcedureReturn #True
  EndIf
  
  ProcedureReturn #False
EndProcedure
