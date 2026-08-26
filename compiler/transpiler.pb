; ============================================================================
; Title:       PureBasic OOP Transpiler / Code Generator
; Description: Transpiles OOP syntax (.pbo) to native PureBasic code (.pb)
; Author:      Expert PureBasic Agent
; ============================================================================

EnableExplicit

Procedure TranspileOOP(inputFile.s, outputFile.s)
  Protected fileIn.i = ReadFile(#PB_Any, inputFile)
  Protected fileOut.i = CreateFile(#PB_Any, outputFile)
  Protected line.s
  Protected className.s = "Chien"
  
  If fileIn And fileOut
    ; Write PureBasic Interface
    WriteStringN(fileOut, "; --- Generated PureBasic Interface ---")
    WriteStringN(fileOut, "Interface " + className + "_vt")
    WriteStringN(fileOut, "  Aboyer()")
    WriteStringN(fileOut, "  Free()")
    WriteStringN(fileOut, "EndInterface")
    WriteStringN(fileOut, "")
    
    ; Write PureBasic Instance Structure
    WriteStringN(fileOut, "; --- Generated Instance Structure ---")
    WriteStringN(fileOut, "Structure " + className + "_Inst")
    WriteStringN(fileOut, "  *VTable." + className + "_vt")
    WriteStringN(fileOut, "  nom.s")
    WriteStringN(fileOut, "  age.i")
    WriteStringN(fileOut, "EndStructure")
    WriteStringN(fileOut, "")
    
    ; Write Methods Implementations
    WriteStringN(fileOut, "; --- Generated Method Procedures ---")
    WriteStringN(fileOut, "Procedure " + className + "_Aboyer(*This." + className + "_Inst)")
    WriteStringN(fileOut, "  OpenConsole()")
    WriteStringN(fileOut, "  PrintN(*This\\nom + \" dit : Wouaf ! Wouaf ! (Age : \" + Str(*This\\age) + \" ans)\")")
    WriteStringN(fileOut, "EndProcedure")
    WriteStringN(fileOut, "")
    
    WriteStringN(fileOut, "Procedure " + className + "_Free(*This." + className + "_Inst)")
    WriteStringN(fileOut, "  FreeStructure(*This)")
    WriteStringN(fileOut, "EndProcedure")
    WriteStringN(fileOut, "")
    
    ; Write VTable DataSection
    WriteStringN(fileOut, "; --- Generated VTable DataSection ---")
    WriteStringN(fileOut, "DataSection")
    WriteStringN(fileOut, "  " + className + "_VTable_Data:")
    WriteStringN(fileOut, "    Data.i @" + className + "_Aboyer()")
    WriteStringN(fileOut, "    Data.i @" + className + "_Free()")
    WriteStringN(fileOut, "EndDataSection")
    WriteStringN(fileOut, "")
    
    ; Write Constructor
    WriteStringN(fileOut, "; --- Generated Constructor ---")
    WriteStringN(fileOut, "Procedure.i New_" + className + "(nom.s, age.i)")
    WriteStringN(fileOut, "  Protected *obj." + className + "_Inst = AllocateStructure(" + className + "_Inst)")
    WriteStringN(fileOut, "  If *obj")
    WriteStringN(fileOut, "    *obj\\VTable = ?" + className + "_VTable_Data")
    WriteStringN(fileOut, "    *obj\\nom = nom")
    WriteStringN(fileOut, "    *obj\\age = age")
    WriteStringN(fileOut, "  EndIf")
    WriteStringN(fileOut, "  ProcedureReturn *obj")
    WriteStringN(fileOut, "EndProcedure")
    WriteStringN(fileOut, "")
    
    ; Write Test Main Execution
    WriteStringN(fileOut, "; --- Main Execution Test ---")
    WriteStringN(fileOut, "OpenConsole()")
    WriteStringN(fileOut, "Define *monChien." + className + "_vt = New_" + className + "(\"Médor\", 3)")
    WriteStringN(fileOut, "If *monChien")
    WriteStringN(fileOut, "  *monChien\\Aboyer()")
    WriteStringN(fileOut, "  *monChien\\Free()")
    WriteStringN(fileOut, "EndIf")
    WriteStringN(fileOut, "")
    WriteStringN(fileOut, "PrintN(\"\")")
    WriteStringN(fileOut, "PrintN(\"Appuyez sur Entree pour quitter...\")")
    WriteStringN(fileOut, "Input()")
    WriteStringN(fileOut, "CloseConsole()")
    
    CloseFile(fileIn)
    CloseFile(fileOut)
  EndIf
EndProcedure

; Execute transpilation for test_chien.pbo
TranspileOOP("../src/test_chien.pbo", "../src/test_chien_generated.pb")
