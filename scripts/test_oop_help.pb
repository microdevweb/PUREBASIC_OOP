; ============================================================================
; Test suite for PureBasic OOP Contextual Help System
; ============================================================================

EnableExplicit

Global CurrentLanguage.s = "Francais"
Global CurrentLanguage$ = "Francais"

XIncludeFile "..\ide_official\PureBasicIDE\OOP_Help.pb"

Procedure AssertTrue(condition.i, testName.s)
  If condition
    PrintN("[PASS] " + testName)
  Else
    PrintN("[FAIL] " + testName)
    End 1
  EndIf
EndProcedure

OpenConsole("OOP Help System Validation")
PrintN("Starting OOP Help System Test Suite...")

; 1. Test Keywords Mapping
AssertTrue(Bool(GetOOPHelpPage("Class") = "keywords/class.html"), "Mapping: Class -> keywords/class.html")
AssertTrue(Bool(GetOOPHelpPage("EndClass") = "keywords/class.html"), "Mapping: EndClass -> keywords/class.html")
AssertTrue(Bool(GetOOPHelpPage("Abstract") = "keywords/class.html"), "Mapping: Abstract -> keywords/class.html")
AssertTrue(Bool(GetOOPHelpPage("Method") = "keywords/method.html"), "Mapping: Method -> keywords/method.html")
AssertTrue(Bool(GetOOPHelpPage("EndMethod") = "keywords/method.html"), "Mapping: EndMethod -> keywords/method.html")
AssertTrue(Bool(GetOOPHelpPage("Getter") = "keywords/properties.html"), "Mapping: Getter -> keywords/properties.html")
AssertTrue(Bool(GetOOPHelpPage("Setter") = "keywords/properties.html"), "Mapping: Setter -> keywords/properties.html")
AssertTrue(Bool(GetOOPHelpPage("Property") = "keywords/properties.html"), "Mapping: Property -> keywords/properties.html")
AssertTrue(Bool(GetOOPHelpPage("Extends") = "keywords/inheritance.html"), "Mapping: Extends -> keywords/inheritance.html")
AssertTrue(Bool(GetOOPHelpPage("Super") = "keywords/inheritance.html"), "Mapping: Super -> keywords/inheritance.html")
AssertTrue(Bool(GetOOPHelpPage("Public") = "keywords/encapsulation.html"), "Mapping: Public -> keywords/encapsulation.html")
AssertTrue(Bool(GetOOPHelpPage("Protected") = "keywords/encapsulation.html"), "Mapping: Protected -> keywords/encapsulation.html")
AssertTrue(Bool(GetOOPHelpPage("Private") = "keywords/encapsulation.html"), "Mapping: Private -> keywords/encapsulation.html")
AssertTrue(Bool(GetOOPHelpPage("New") = "keywords/lifecycle.html"), "Mapping: New -> keywords/lifecycle.html")
AssertTrue(Bool(GetOOPHelpPage("Free") = "keywords/lifecycle.html"), "Mapping: Free -> keywords/lifecycle.html")
AssertTrue(Bool(GetOOPHelpPage("This") = "keywords/operators.html"), "Mapping: This -> keywords/operators.html")
AssertTrue(Bool(GetOOPHelpPage("TypeOf") = "keywords/operators.html"), "Mapping: TypeOf -> keywords/operators.html")

; 2. Test UI Classes Mapping
AssertTrue(Bool(GetOOPHelpPage("Application") = "ui/application.html"), "Mapping: Application -> ui/application.html")
AssertTrue(Bool(GetOOPHelpPage("Window") = "ui/window.html"), "Mapping: Window -> ui/window.html")
AssertTrue(Bool(GetOOPHelpPage("Gadget") = "ui/gadget.html"), "Mapping: Gadget -> ui/gadget.html")
AssertTrue(Bool(GetOOPHelpPage("Button") = "ui/button.html"), "Mapping: Button -> ui/button.html")
AssertTrue(Bool(GetOOPHelpPage("CheckBox") = "ui/checkbox.html"), "Mapping: CheckBox -> ui/checkbox.html")
AssertTrue(Bool(GetOOPHelpPage("ComboBox") = "ui/combobox.html"), "Mapping: ComboBox -> ui/combobox.html")
AssertTrue(Bool(GetOOPHelpPage("Label") = "ui/label.html"), "Mapping: Label -> ui/label.html")
AssertTrue(Bool(GetOOPHelpPage("ProgressBar") = "ui/progressbar.html"), "Mapping: ProgressBar -> ui/progressbar.html")
AssertTrue(Bool(GetOOPHelpPage("Slider") = "ui/slider.html"), "Mapping: Slider -> ui/slider.html")
AssertTrue(Bool(GetOOPHelpPage("TextBox") = "ui/textbox.html"), "Mapping: TextBox -> ui/textbox.html")
AssertTrue(Bool(GetOOPHelpPage("ToggleSwitch") = "ui/toggleswitch.html"), "Mapping: ToggleSwitch -> ui/toggleswitch.html")

; 3. Test Fallback (Non-OOP purebasic keywords must return empty so native PB help handles them)
AssertTrue(Bool(GetOOPHelpPage("OpenWindow") = ""), "Fallback: OpenWindow -> empty (Native PB)")
AssertTrue(Bool(GetOOPHelpPage("MessageRequester") = ""), "Fallback: MessageRequester -> empty (Native PB)")
AssertTrue(Bool(GetOOPHelpPage("Delay") = ""), "Fallback: Delay -> empty (Native PB)")
AssertTrue(Bool(GetOOPHelpPage("PokeS") = ""), "Fallback: PokeS -> empty (Native PB)")

; 4. Test physical existence of documentation files
Define baseDir.s = "c:\PB\PB_PROJECT\PB_OOP_WORKSPACE\PUREBASIC_OOP_WORKSPACE\doc\html\"

Define Dim langs.s(1)
langs(0) = "fr"
langs(1) = "en"

Define Dim pages.s(17)
pages(0) = "index.html"
pages(1) = "keywords/class.html"
pages(2) = "keywords/method.html"
pages(3) = "keywords/properties.html"
pages(4) = "keywords/inheritance.html"
pages(5) = "keywords/encapsulation.html"
pages(6) = "keywords/lifecycle.html"
pages(7) = "keywords/operators.html"
pages(8) = "ui/application.html"
pages(9) = "ui/window.html"
pages(10) = "ui/gadget.html"
pages(11) = "ui/button.html"
pages(12) = "ui/checkbox.html"
pages(13) = "ui/combobox.html"
pages(14) = "ui/label.html"
pages(15) = "ui/progressbar.html"
pages(16) = "ui/slider.html"
pages(17) = "ui/toggleswitch.html"

Define l, p
For l = 0 To 1
  For p = 0 To 17
    Define checkPath.s = baseDir + langs(l) + "\" + ReplaceString(pages(p), "/", "\")
    AssertTrue(Bool(FileSize(checkPath) > 0), "File exists: " + langs(l) + "/" + pages(p))
  Next
Next

; 5. Test Logo Asset existence
AssertTrue(Bool(FileSize(baseDir + "assets\PB_OOP_LOGO.jpeg") > 0), "Asset exists: assets/PB_OOP_LOGO.jpeg")

PrintN("ALL TESTS PASSED SUCCESSFULLY! (100% OK)")
End 0
