; ============================================================================
; Title:       PureBasic OOP Transpiler / Code Generator (Full OOP Engine)
; Description: Transpiles OOP syntax (.pbo) to native PureBasic code (.pb)
;              Supports Single Inheritance, Dynamic VTable Polymorphism,
;              Method Overriding, 'Super::' calls, and Encapsulation.
; Author:      Expert PureBasic OOP Architect
; ============================================================================

EnableExplicit

; ----------------------------------------------------------------------------
; Data Structures for OOP Meta-Model
; ----------------------------------------------------------------------------

Structure OOP_Field
  name.s          ; e.g. "nom.s"
  visibility.s    ; "Public", "Protected", "Private"
EndStructure

Structure OOP_Method
  name.s          ; e.g. "Crier"
  rawDecl.s       ; e.g. "Public Method Crier()"
  params.s        ; e.g. "nourriture.s, quantite.i"
  returnType.s    ; e.g. ".i", ".s", ""
  visibility.s    ; "Public", "Protected", "Private"
  isOverride.b
EndStructure

Structure OOP_VTableSlot
  methodName.s
  implementingClass.s
  params.s
  returnType.s
EndStructure

Structure OOP_Class
  name.s
  parentName.s    ; empty if base class
  List Fields.OOP_Field()
  List Methods.OOP_Method()
  List VTableSlots.OOP_VTableSlot()
  hasInit.b
  initParams.s
  hasFree.b
EndStructure

Structure OOP_MethodBody
  className.s
  methodName.s
  params.s
  returnType.s
  List BodyLines.s()
EndStructure

; ----------------------------------------------------------------------------
; Global Transpiler State
; ----------------------------------------------------------------------------

Global NewList Classes.OOP_Class()
Global NewMap ClassMap.i() ; Map ClassName to ListIndex
Global NewList MethodBodies.OOP_MethodBody()
Global NewList MainLines.s()

; ----------------------------------------------------------------------------
; Helper String Functions
; ----------------------------------------------------------------------------

Procedure.s ExtractParamTypes(params.s)
  ; Strips default values or trims spaces
  ProcedureReturn Trim(params)
EndProcedure

Procedure.s CleanLine(line.s)
  Protected clean.s = Trim(line)
  ProcedureReturn clean
EndProcedure

Procedure.b IsIdentifierChar(c.s)
  Protected a.i = Asc(c)
  If (a >= 65 And a <= 90) Or (a >= 97 And a <= 122) Or (a >= 48 And a <= 57) Or a = 95
    ProcedureReturn #True
  EndIf
  ProcedureReturn #False
EndProcedure

; ----------------------------------------------------------------------------
; Parser Phase: Read and tokenize .pbo source
; ----------------------------------------------------------------------------

Procedure.b ParsePBO(inputFile.s)
  Protected file = ReadFile(#PB_Any, inputFile)
  If Not file
    ProcedureReturn #False
  EndIf

  ClearList(Classes())
  ClearMap(ClassMap())
  ClearList(MethodBodies())
  ClearList(MainLines())

  Protected inClass.b = #False
  Protected inMethod.b = #False
  Protected *currentClass.OOP_Class = #Null
  Protected *currentMethod.OOP_MethodBody = #Null
  Protected rawLine.s, line.s, upper.s
  Protected p1.i, p2.i, p3.i, word1.s, word2.s, word3.s, word4.s

  While Not Eof(file)
    rawLine = ReadString(file)
    line = Trim(rawLine)
    upper = UCase(line)

    ; 1. Parsing inside Class definition
    If inClass
      If Left(upper, 8) = "ENDCLASS"
        inClass = #False
        *currentClass = #Null
        Continue
      ElseIf Left(upper, 6) = "PUBLIC" Or Left(upper, 9) = "PROTECTED" Or Left(upper, 7) = "PRIVATE"
        ; Field or Method declaration
        Protected vis.s = "Public"
        Protected rest.s = ""
        If Left(upper, 6) = "PUBLIC"
          vis = "Public"
          rest = Trim(Mid(line, 7))
        ElseIf Left(upper, 9) = "PROTECTED"
          vis = "Protected"
          rest = Trim(Mid(line, 10))
        ElseIf Left(upper, 7) = "PRIVATE"
          vis = "Private"
          rest = Trim(Mid(line, 8))
        EndIf

        Protected restUpper.s = UCase(rest)
        If Left(restUpper, 6) = "METHOD"
          ; Method declaration in class
          Protected methDecl.s = Trim(Mid(rest, 7))
          Protected mName.s, mParams.s = "", mRet.s = ""
          
          p1 = FindString(methDecl, "(")
          If p1 > 0
            mName = Trim(Left(methDecl, p1 - 1))
            p2 = FindString(methDecl, ")", p1)
            If p2 > p1
              mParams = Trim(Mid(methDecl, p1 + 1, p2 - p1 - 1))
            EndIf
          Else
            mName = methDecl
          EndIf
          
          ; Check return type in mName (e.g. GetAge.i)
          p3 = FindString(mName, ".")
          If p3 > 0
            mRet = Mid(mName, p3)
            mName = Left(mName, p3 - 1)
          EndIf

          AddElement(*currentClass\Methods())
          *currentClass\Methods()\name = mName
          *currentClass\Methods()\rawDecl = line
          *currentClass\Methods()\params = mParams
          *currentClass\Methods()\returnType = mRet
          *currentClass\Methods()\visibility = vis
          
          If UCase(mName) = "INIT"
            *currentClass\hasInit = #True
            *currentClass\initParams = mParams
          ElseIf UCase(mName) = "FREE"
            *currentClass\hasFree = #True
          EndIf

        Else
          ; Field declaration: e.g. "nom.s", "age.i", "List items.s()"
          AddElement(*currentClass\Fields())
          *currentClass\Fields()\name = rest
          *currentClass\Fields()\visibility = vis
        EndIf
        Continue
      EndIf

    ; 2. Parsing inside Method Implementation
    ElseIf inMethod
      If Left(upper, 9) = "ENDMETHOD"
        inMethod = #False
        *currentMethod = #Null
        Continue
      Else
        AddElement(*currentMethod\BodyLines())
        *currentMethod\BodyLines() = rawLine
        Continue
      EndIf

    ; 3. Outside Class/Method (Root Level)
    Else
      If Left(upper, 5) = "CLASS" And (Len(line) = 5 Or Mid(line, 6, 1) = " ")
        ; Class definition start
        Protected classHeader.s = Trim(Mid(line, 6))
        Protected cName.s = "", pName.s = ""
        p1 = FindString(UCase(classHeader), "EXTENDS")
        If p1 > 0
          cName = Trim(Left(classHeader, p1 - 1))
          pName = Trim(Mid(classHeader, p1 + 7))
        Else
          cName = classHeader
        EndIf

        AddElement(Classes())
        *currentClass = @Classes()
        *currentClass\name = cName
        *currentClass\parentName = pName
        ClassMap(cName) = ListIndex(Classes())
        inClass = #True
        Continue

      ElseIf Left(upper, 6) = "METHOD" And (Len(line) = 6 Or Mid(line, 7, 1) = " ")
        ; Method implementation: e.g. Method Chien::Crier() or Method.i Chien::Calculer(x.i)
        Protected implHeader.s = Trim(Mid(line, 7))
        Protected implRet.s = ""
        If Left(implHeader, 1) = "."
          p1 = FindString(implHeader, " ")
          If p1 > 0
            implRet = Left(implHeader, p1 - 1)
            implHeader = Trim(Mid(implHeader, p1 + 1))
          EndIf
        EndIf

        p1 = FindString(implHeader, "::")
        If p1 > 0
          Protected targetClass.s = Trim(Left(implHeader, p1 - 1))
          Protected targetMethAndParams.s = Trim(Mid(implHeader, p1 + 2))
          Protected targetMeth.s = "", targetParams.s = ""
          
          p2 = FindString(targetMethAndParams, "(")
          If p2 > 0
            targetMeth = Trim(Left(targetMethAndParams, p2 - 1))
            p3 = FindString(targetMethAndParams, ")", p2)
            If p3 > p2
              targetParams = Trim(Mid(targetMethAndParams, p2 + 1, p3 - p2 - 1))
            EndIf
          Else
            targetMeth = targetMethAndParams
          EndIf
          
          ; Check return type on method name if not already extracted
          If implRet = ""
            p3 = FindString(targetMeth, ".")
            If p3 > 0
              implRet = Mid(targetMeth, p3)
              targetMeth = Left(targetMeth, p3 - 1)
            EndIf
          EndIf

          AddElement(MethodBodies())
          *currentMethod = @MethodBodies()
          *currentMethod\className = targetClass
          *currentMethod\methodName = targetMeth
          *currentMethod\params = targetParams
          *currentMethod\returnType = implRet
          inMethod = #True
          Continue
        EndIf
      Else
        ; Normal PB code or Main code (.pbo instantiation)
        AddElement(MainLines())
        MainLines() = rawLine
      EndIf
    EndIf
  Wend

  CloseFile(file)
  ProcedureReturn #True
EndProcedure

; ----------------------------------------------------------------------------
; Semantic Analysis Phase: VTable Construction & Polymorphism Resolution
; ----------------------------------------------------------------------------

Procedure BuildVTables()
  ForEach Classes()
    Protected *c.OOP_Class = @Classes()
    ClearList(*c\VTableSlots())

    ; If class has a parent, inherit parent's VTable slots in order
    If *c\parentName <> "" And FindMapElement(ClassMap(), *c\parentName)
      Protected parentIdx.i = ClassMap(*c\parentName)
      PushListPosition(Classes())
      SelectElement(Classes(), parentIdx)
      Protected *parent.OOP_Class = @Classes()
      
      ; Copy parent VTable slots
      ForEach *parent\VTableSlots()
        AddElement(*c\VTableSlots())
        *c\VTableSlots()\methodName = *parent\VTableSlots()\methodName
        *c\VTableSlots()\implementingClass = *parent\VTableSlots()\implementingClass
        *c\VTableSlots()\params = *parent\VTableSlots()\params
        *c\VTableSlots()\returnType = *parent\VTableSlots()\returnType
      Next
      
      PopListPosition(Classes())
    EndIf

    ; Now process this class's methods
    ForEach *c\Methods()
      Protected *m.OOP_Method = @*c\Methods()
      
      ; Exclude Private methods from VTable (they are direct calls)
      If *m\visibility = "Private"
        Continue
      EndIf
      ; Exclude Init from VTable (Init is constructor helper)
      If UCase(*m\name) = "INIT"
        Continue
      EndIf

      ; Check if this method overrides a slot in the inherited VTable
      Protected foundSlot.b = #False
      ForEach *c\VTableSlots()
        If UCase(*c\VTableSlots()\methodName) = UCase(*m\name)
          ; Override implementation
          *c\VTableSlots()\implementingClass = *c\name
          *c\VTableSlots()\params = *m\params
          *c\VTableSlots()\returnType = *m\returnType
          *m\isOverride = #True
          foundSlot = #True
          Break
        EndIf
      Next

      ; If not found in parent VTable, append as a new method
      If Not foundSlot
        AddElement(*c\VTableSlots())
        *c\VTableSlots()\methodName = *m\name
        *c\VTableSlots()\implementingClass = *c\name
        *c\VTableSlots()\params = *m\params
        *c\VTableSlots()\returnType = *m\returnType
      EndIf
    Next
  Next
EndProcedure

; ----------------------------------------------------------------------------
; Code Generation Phase: Emit PureBasic Code
; ----------------------------------------------------------------------------

Procedure.s ReplaceWord(text.s, findWord.s, replaceWith.s)
  Protected res.s = ""
  Protected lenT.i = Len(text)
  Protected lenW.i = Len(findWord)
  Protected i.i = 1
  
  While i <= lenT
    If Mid(text, i, lenW) = findWord
      Protected isStart.b = #False
      Protected isEnd.b = #False
      
      If i = 1
        isStart = #True
      Else
        Protected prevChar.s = Mid(text, i - 1, 1)
        If Not IsIdentifierChar(prevChar) And prevChar <> "*"
          isStart = #True
        EndIf
      EndIf
      
      If (i + lenW > lenT)
        isEnd = #True
      Else
        Protected nextChar.s = Mid(text, i + lenW, 1)
        If Not IsIdentifierChar(nextChar)
          isEnd = #True
        EndIf
      EndIf
      
      If isStart And isEnd
        res + replaceWith
        i + lenW
        Continue
      EndIf
    EndIf
    
    res + Mid(text, i, 1)
    i + 1
  Wend
  
  ProcedureReturn res
EndProcedure

Procedure.s TranspileMethodBodyLine(line.s, className.s, parentClassName.s)
  Protected res.s = line
  
  ; 1. Handle 'Super::Method(' calls
  Protected pSuper.i = FindString(res, "Super::")
  While pSuper > 0
    Protected pOpen.i = FindString(res, "(", pSuper)
    If pOpen > 0
      Protected methName.s = Trim(Mid(res, pSuper + 7, pOpen - (pSuper + 7)))
      Protected before.s = Left(res, pSuper - 1)
      Protected after.s = Mid(res, pOpen + 1)
      
      Protected trimmedAfter.s = Trim(after)
      If Left(trimmedAfter, 1) = ")"
        res = before + parentClassName + "_" + methName + "(*This" + after
      Else
        res = before + parentClassName + "_" + methName + "(*This, " + after
      EndIf
    EndIf
    pSuper = FindString(res, "Super::", pSuper + 1)
  Wend
  
  ; 2. Replace 'This' with '*This' cleanly (both This\field and FreeStructure(This))
  res = ReplaceWord(res, "This", "*This")
  
  ProcedureReturn res
EndProcedure

Procedure.s TranspileMainLine(line.s)
  Protected res.s = line
  
  ; 1. Replace 'New ClassName(' with 'New_ClassName('
  ForEach Classes()
    Protected cName.s = Classes()\name
    res = ReplaceString(res, "New " + cName + "(", "New_" + cName + "(")
    res = ReplaceString(res, "New  " + cName + "(", "New_" + cName + "(")
    
    ; 2. Replace type annotations .ClassName with .ClassName_vt
    res = ReplaceString(res, "." + cName + " ", "." + cName + "_vt ")
    res = ReplaceString(res, "." + cName + "=", "." + cName + "_vt =")
    res = ReplaceString(res, "." + cName + ",", "." + cName + "_vt,")
    res = ReplaceString(res, "." + cName + ")", "." + cName + "_vt)")
    res = ReplaceString(res, "." + cName + "(", "." + cName + "_vt(")
    res = ReplaceString(res, "." + cName + "\", "." + cName + "_vt\")
    If Right(res, Len("." + cName)) = "." + cName
      res = Left(res, Len(res) - Len("." + cName)) + "." + cName + "_vt"
    EndIf
  Next
  
  ProcedureReturn res
EndProcedure

Procedure.b GenerateTargetPB(outputFile.s)
  Protected file = CreateFile(#PB_Any, outputFile)
  If Not file
    ProcedureReturn #False
  EndIf

  WriteStringN(file, "; ============================================================================")
  WriteStringN(file, "; Generated by PureBasic OOP Transpiler (Native OOP Engine)")
  WriteStringN(file, "; Do not edit directly - modify the corresponding .pbo source file.")
  WriteStringN(file, "; ============================================================================")
  WriteStringN(file, "")
  WriteStringN(file, "EnableExplicit")
  WriteStringN(file, "")

  ; --------------------------------------------------------------------------
  ; 1. Generate Interfaces
  ; --------------------------------------------------------------------------
  WriteStringN(file, "; " + RSet("", 76, "-"))
  WriteStringN(file, "; 1. PUREBASIC INTERFACES (VTABLE PROTOTYPES)")
  WriteStringN(file, "; " + RSet("", 76, "-"))
  WriteStringN(file, "")

  ForEach Classes()
    Protected *c.OOP_Class = @Classes()
    If *c\parentName <> ""
      WriteStringN(file, "Interface " + *c\name + "_vt Extends " + *c\parentName + "_vt")
    Else
      WriteStringN(file, "Interface " + *c\name + "_vt")
    EndIf

    ; For root class: output all VTable methods
    ; For derived class: output ONLY new methods (not in parent)
    ForEach *c\Methods()
      Protected *m.OOP_Method = @*c\Methods()
      If *m\visibility <> "Private" And UCase(*m\name) <> "INIT"
        If *c\parentName = "" Or Not *m\isOverride
          WriteStringN(file, "  " + *m\name + *m\returnType + "(" + *m\params + ")")
        EndIf
      EndIf
    Next

    WriteStringN(file, "EndInterface")
    WriteStringN(file, "")
  Next

  ; --------------------------------------------------------------------------
  ; 2. Generate Instance Structures
  ; --------------------------------------------------------------------------
  WriteStringN(file, "; " + RSet("", 76, "-"))
  WriteStringN(file, "; 2. INSTANCE STRUCTURES")
  WriteStringN(file, "; " + RSet("", 76, "-"))
  WriteStringN(file, "")

  ForEach Classes()
    *c = @Classes()
    If *c\parentName <> ""
      WriteStringN(file, "Structure " + *c\name + "_Inst Extends " + *c\parentName + "_Inst")
    Else
      WriteStringN(file, "Structure " + *c\name + "_Inst")
      WriteStringN(file, "  *VTable." + *c\name + "_vt")
    EndIf

    ; Fields
    ForEach *c\Fields()
      WriteStringN(file, "  " + *c\Fields()\name)
    Next

    WriteStringN(file, "EndStructure")
    WriteStringN(file, "")
  Next

  ; --------------------------------------------------------------------------
  ; 3. Generate Method Procedures
  ; --------------------------------------------------------------------------
  WriteStringN(file, "; " + RSet("", 76, "-"))
  WriteStringN(file, "; 3. METHOD PROCEDURES IMPLEMENTATION")
  WriteStringN(file, "; " + RSet("", 76, "-"))
  WriteStringN(file, "")

  ; Emit Prototypes/Declare if needed, or Procedures directly
  ForEach MethodBodies()
    Protected *mb.OOP_MethodBody = @MethodBodies()
    Protected parentOfClass.s = ""
    If FindMapElement(ClassMap(), *mb\className)
      parentOfClass = Classes()\parentName
    EndIf

    ; Header
    Protected procHeader.s = "Procedure" + *mb\returnType + " " + *mb\className + "_" + *mb\methodName + "(*This." + *mb\className + "_Inst"
    If *mb\params <> ""
      procHeader + ", " + *mb\params
    EndIf
    procHeader + ")"
    
    WriteStringN(file, procHeader)
    
    ; Body Lines
    ForEach *mb\BodyLines()
      Protected transpiledBody.s = TranspileMethodBodyLine(*mb\BodyLines(), *mb\className, parentOfClass)
      WriteStringN(file, "  " + transpiledBody)
    Next
    
    WriteStringN(file, "EndProcedure")
    WriteStringN(file, "")
  Next

  ; Auto-generate default Free() destructor if declared in class but no custom implementation provided
  ForEach Classes()
    *c = @Classes()
    If *c\hasFree
      Protected hasCustomFree.b = #False
      ForEach MethodBodies()
        If MethodBodies()\className = *c\name And UCase(MethodBodies()\methodName) = "FREE"
          hasCustomFree = #True
          Break
        EndIf
      Next
      If Not hasCustomFree
        WriteStringN(file, "Procedure " + *c\name + "_Free(*This." + *c\name + "_Inst)")
        WriteStringN(file, "  FreeStructure(*This)")
        WriteStringN(file, "EndProcedure")
        WriteStringN(file, "")
      EndIf
    EndIf
  Next

  ; --------------------------------------------------------------------------
  ; 4. Generate VTable DataSections
  ; --------------------------------------------------------------------------
  WriteStringN(file, "; " + RSet("", 76, "-"))
  WriteStringN(file, "; 4. VTABLE DATASECTIONS (DYNAMIC DISPATCH)")
  WriteStringN(file, "; " + RSet("", 76, "-"))
  WriteStringN(file, "")
  WriteStringN(file, "DataSection")

  ForEach Classes()
    *c = @Classes()
    WriteStringN(file, "  " + *c\name + "_VTable_Data:")
    ForEach *c\VTableSlots()
      WriteStringN(file, "    Data.i @" + *c\VTableSlots()\implementingClass + "_" + *c\VTableSlots()\methodName + "()")
    Next
  Next

  WriteStringN(file, "EndDataSection")
  WriteStringN(file, "")

  ; --------------------------------------------------------------------------
  ; 5. Generate Constructors
  ; --------------------------------------------------------------------------
  WriteStringN(file, "; " + RSet("", 76, "-"))
  WriteStringN(file, "; 5. CONSTRUCTORS & FACTORY FUNCTIONS")
  WriteStringN(file, "; " + RSet("", 76, "-"))
  WriteStringN(file, "")

  ForEach Classes()
    *c = @Classes()
    Protected ctorParams.s = ""
    If *c\hasInit
      ctorParams = *c\initParams
    EndIf

    WriteStringN(file, "Procedure.i New_" + *c\name + "(" + ctorParams + ")")
    WriteStringN(file, "  Protected *obj." + *c\name + "_Inst = AllocateStructure(" + *c\name + "_Inst)")
    WriteStringN(file, "  If *obj")
    WriteStringN(file, "    *obj\VTable = ?" + *c\name + "_VTable_Data")
    If *c\hasInit
      ; Pass parameters to Init
      Protected callInitParams.s = "*obj"
      ; Parse param names from ctorParams
      Protected cleanParams.s = ""
      Protected i.i, numParams.i = CountString(ctorParams, ",") + 1
      If Trim(ctorParams) <> ""
        For i = 1 To numParams
          Protected pToken.s = Trim(StringField(ctorParams, i, ","))
          Protected pVar.s = StringField(pToken, 1, " ")
          pVar = StringField(pVar, 1, "=")
          pVar = StringField(pVar, 1, ".")
          callInitParams + ", " + pVar
        Next
      EndIf
      WriteStringN(file, "    " + *c\name + "_Init(" + callInitParams + ")")
    EndIf
    WriteStringN(file, "  EndIf")
    WriteStringN(file, "  ProcedureReturn *obj")
    WriteStringN(file, "EndProcedure")
    WriteStringN(file, "")
  Next

  ; --------------------------------------------------------------------------
  ; 6. Generate Main Execution Code
  ; --------------------------------------------------------------------------
  WriteStringN(file, "; " + RSet("", 76, "-"))
  WriteStringN(file, "; 6. MAIN PROGRAM EXECUTION")
  WriteStringN(file, "; " + RSet("", 76, "-"))
  WriteStringN(file, "")

  ForEach MainLines()
    Protected transpiledMain.s = TranspileMainLine(MainLines())
    WriteStringN(file, transpiledMain)
  Next

  CloseFile(file)
  ProcedureReturn #True
EndProcedure

; ----------------------------------------------------------------------------
; Main CLI Entry Point
; ----------------------------------------------------------------------------

Procedure.i Main()
  Protected inputPBO.s = ProgramParameter(0)
  Protected outputPB.s = ProgramParameter(1)

  If inputPBO = ""
    ; Default development path
    inputPBO = "../src/test_polymorphisme.pbo"
    outputPB = "../src/test_polymorphisme_generated.pb"
  EndIf

  If outputPB = ""
    outputPB = ReplaceString(inputPBO, ".pbo", "_generated.pb", #PB_String_NoCase)
  EndIf

  OpenConsole()
  PrintN("=================================================================")
  PrintN("           PureBasic OOP Transpiler (Native Engine)              ")
  PrintN("=================================================================")
  PrintN("Input  PBO : " + inputPBO)
  PrintN("Output PB  : " + outputPB)
  PrintN("")

  If Not ParsePBO(inputPBO)
    PrintN("[ERROR] Failed to open and parse input file: " + inputPBO)
    CloseConsole()
    ProcedureReturn 1
  EndIf

  PrintN("[INFO] Parsed " + Str(ListSize(Classes())) + " classes, " + Str(ListSize(MethodBodies())) + " method implementations.")
  
  BuildVTables()
  PrintN("[INFO] Built VTables and resolved method overrides.")

  If Not GenerateTargetPB(outputPB)
    PrintN("[ERROR] Failed to write generated PureBasic code: " + outputPB)
    CloseConsole()
    ProcedureReturn 2
  EndIf

  PrintN("[SUCCESS] Successfully transpiled to: " + outputPB)
  PrintN("=================================================================")
  CloseConsole()
  ProcedureReturn 0
EndProcedure

Main()
