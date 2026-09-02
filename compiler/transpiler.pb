; ============================================================================
; Title:       PureBasic OOP Transpiler / Code Generator (Full OOP Engine)
; Description: Transpiles OOP syntax (.pbo) to native PureBasic code (.pb)
;              Supports Single Inheritance, Dynamic VTable Polymorphism,
;              Method Overriding, 'Super::' / 'Super\' calls, 'New' instantiation,
;              and inline / out-of-class method bodies.
; Author:      MicrodevWeb
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
  isAbstract.b
EndStructure

Structure OOP_VTableSlot
  methodName.s
  implementingClass.s
  declaringClass.s
  params.s
  returnType.s
  isAbstract.b
EndStructure

Structure OOP_Class
  name.s
  parentName.s    ; empty if base class
  isAbstract.b
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
Global NewList FileLines.s()

; ----------------------------------------------------------------------------
; Helper Functions
; ----------------------------------------------------------------------------

Procedure.b IsIdentifierChar(c.s)
  Protected a.i = Asc(c)
  If (a >= 65 And a <= 90) Or (a >= 97 And a <= 122) Or (a >= 48 And a <= 57) Or a = 95
    ProcedureReturn #True
  EndIf
  ProcedureReturn #False
EndProcedure

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

; ----------------------------------------------------------------------------
; Parser Phase: Read and tokenize .pbo source
; ----------------------------------------------------------------------------

Procedure.b ParsePBO(inputFile.s)
  Protected file = ReadFile(#PB_Any, inputFile)
  If Not file
    ProcedureReturn #False
  EndIf

  ClearList(FileLines())
  Protected isFirstLine.b = #True
  While Not Eof(file)
    AddElement(FileLines())
    FileLines() = ReadString(file)
    ; Strip UTF-8 BOM (EF BB BF) from the first line if present
    If isFirstLine
      If Left(FileLines(), 1) = Chr(239) Or Asc(Left(FileLines(), 1)) = 65279
        FileLines() = Mid(FileLines(), 2)  ; Remove the BOM character
      EndIf
      isFirstLine = #False
    EndIf
  Wend
  CloseFile(file)

  ClearList(Classes())
  ClearMap(ClassMap())
  ClearList(MethodBodies())
  ClearList(MainLines())

  Protected inClass.b = #False
  Protected inMethod.b = #False
  Protected inClassMethod.b = #False
  Protected *currentClass.OOP_Class = #Null
  Protected *currentMethod.OOP_MethodBody = #Null
  Protected rawLine.s, line.s, upper.s
  Protected p1.i, p2.i, p3.i

  Protected lineIdx.i = 0, totalLines.i = ListSize(FileLines())

  ForEach FileLines()
    rawLine = FileLines()
    line = Trim(rawLine)
    upper = UCase(line)

    ; 1. Parsing inside Class Method body (Inline method inside Class)
    If inClassMethod
      If Left(upper, 9) = "ENDMETHOD"
        inClassMethod = #False
        *currentMethod = #Null
        Continue
      Else
        AddElement(*currentMethod\BodyLines())
        *currentMethod\BodyLines() = rawLine
        Continue
      EndIf

    ; 2. Parsing inside Class definition
    ElseIf inClass
      If Left(upper, 8) = "ENDCLASS"
        inClass = #False
        *currentClass = #Null
        Continue
      Else
        ; Handle method declarations or inline method bodies:
        ; e.g. Public Method Init(...) or Abstract Method Dessiner() or Public Abstract Method.d Calculer()
        Protected isAbsMeth.b = #False
        Protected vis.s = "Public"
        Protected workLine.s = line
        Protected workUpper.s = upper
        Protected matchedPrefix.b = #False

        Repeat
          workUpper = UCase(Trim(workLine))
          If Left(workUpper, 8) = "ABSTRACT" And (Len(workUpper) = 8 Or Mid(workUpper, 9, 1) = " ")
            isAbsMeth = #True
            matchedPrefix = #True
            workLine = Trim(Mid(workLine, 9))
          ElseIf Left(workUpper, 6) = "PUBLIC" And (Len(workUpper) = 6 Or Mid(workUpper, 7, 1) = " ")
            vis = "Public"
            matchedPrefix = #True
            workLine = Trim(Mid(workLine, 7))
          ElseIf Left(workUpper, 9) = "PROTECTED" And (Len(workUpper) = 9 Or Mid(workUpper, 10, 1) = " ")
            vis = "Protected"
            matchedPrefix = #True
            workLine = Trim(Mid(workLine, 10))
          ElseIf Left(workUpper, 7) = "PRIVATE" And (Len(workUpper) = 7 Or Mid(workUpper, 8, 1) = " ")
            vis = "Private"
            matchedPrefix = #True
            workLine = Trim(Mid(workLine, 8))
          Else
            Break
          EndIf
        ForEver

        workUpper = UCase(Trim(workLine))
        If Left(workUpper, 6) = "METHOD" And (Len(workUpper) = 6 Or Mid(workUpper, 7, 1) = " " Or Mid(workUpper, 7, 1) = ".")
          ; Method declaration / inline definition inside class
          Protected methDecl.s = Trim(Mid(workLine, 7))
          Protected mName.s = "", mParams.s = "", mRet.s = ""
          
          ; Check return type in header if format Method.i Name(params)
          If Left(methDecl, 1) = "."
            p1 = FindString(methDecl, " ")
            If p1 > 0
              mRet = Left(methDecl, p1 - 1)
              methDecl = Trim(Mid(methDecl, p1 + 1))
            EndIf
          EndIf
          
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
          If mRet = ""
            p3 = FindString(mName, ".")
            If p3 > 0
              mRet = Mid(mName, p3)
              mName = Left(mName, p3 - 1)
            EndIf
          EndIf

          AddElement(*currentClass\Methods())
          *currentClass\Methods()\name = mName
          *currentClass\Methods()\rawDecl = line
          *currentClass\Methods()\params = mParams
          *currentClass\Methods()\returnType = mRet
          *currentClass\Methods()\visibility = vis
          *currentClass\Methods()\isAbstract = isAbsMeth
          
          If UCase(mName) = "INIT"
            *currentClass\hasInit = #True
            *currentClass\initParams = mParams
          ElseIf UCase(mName) = "FREE"
            *currentClass\hasFree = #True
          EndIf

          ; Abstract method cannot have an inline body
          If isAbsMeth
            Continue
          EndIf

          ; Check if this is an inline method or a single-line declaration
          ; Look ahead for an EndMethod before next declaration or EndClass
          Protected isInline.b = #False
          PushListPosition(FileLines())
          While NextElement(FileLines())
            Protected nextLine.s = Trim(UCase(FileLines()))
            If nextLine = "" Or Left(nextLine, 1) = ";"
              Continue
            ElseIf Left(nextLine, 9) = "ENDMETHOD"
              isInline = #True
              Break
            ElseIf Left(nextLine, 8) = "ENDCLASS" Or Left(nextLine, 6) = "PUBLIC" Or Left(nextLine, 9) = "PROTECTED" Or Left(nextLine, 7) = "PRIVATE" Or Left(nextLine, 6) = "METHOD" Or Left(nextLine, 8) = "ABSTRACT"
              isInline = #False
              Break
            EndIf
          Wend
          PopListPosition(FileLines())

          If isInline
            AddElement(MethodBodies())
            *currentMethod = @MethodBodies()
            *currentMethod\className = *currentClass\name
            *currentMethod\methodName = mName
            *currentMethod\params = mParams
            *currentMethod\returnType = mRet
            inClassMethod = #True
          EndIf
          Continue

        ElseIf matchedPrefix Or (line <> "" And Left(line, 1) <> ";")
          ; Field declaration: e.g. "nom.s", "age.i", "List items.s()"
          AddElement(*currentClass\Fields())
          *currentClass\Fields()\name = workLine
          *currentClass\Fields()\visibility = vis
          Continue
        EndIf
      EndIf

    ; 3. Parsing inside Out-of-Class Method Implementation (Method Class::Name())
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

    ; 4. Outside Class/Method (Root Level)
    Else
      Protected isClassDecl.b = #False
      Protected isAbsClass.b = #False
      Protected classHeader.s = ""
      
      If Left(upper, 14) = "ABSTRACT CLASS" And (Len(line) = 14 Or Mid(line, 15, 1) = " ")
        isClassDecl = #True
        isAbsClass = #True
        classHeader = Trim(Mid(line, 15))
      ElseIf Left(upper, 5) = "CLASS" And (Len(line) = 5 Or Mid(line, 6, 1) = " ")
        isClassDecl = #True
        isAbsClass = #False
        classHeader = Trim(Mid(line, 6))
      EndIf

      If isClassDecl
        ; Class definition start
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
        *currentClass\isAbstract = isAbsClass
        ClassMap(cName) = ListIndex(Classes())
        inClass = #True
        Continue

      ElseIf Left(upper, 6) = "METHOD" And (Len(line) = 6 Or Mid(line, 7, 1) = " " Or Mid(line, 7, 1) = ".")
        ; Method implementation: e.g. Method Chien::Crier() or Method.i Chien::Calculer(x.i) or Method.d Chien::CalculerAire()
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
  Next

  ProcedureReturn #True
EndProcedure

; ----------------------------------------------------------------------------
; Semantic Analysis Phase: VTable Construction & Polymorphism Resolution
; ----------------------------------------------------------------------------

Procedure.b BuildVTables()
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
        *c\VTableSlots()\declaringClass = *parent\VTableSlots()\declaringClass
        *c\VTableSlots()\params = *parent\VTableSlots()\params
        *c\VTableSlots()\returnType = *parent\VTableSlots()\returnType
        *c\VTableSlots()\isAbstract = *parent\VTableSlots()\isAbstract
      Next
      
      PopListPosition(Classes())
    EndIf

    ; Process methods defined in current class
    ForEach *c\Methods()
      Protected *m.OOP_Method = @*c\Methods()
      
      ; Constructors (Init) and Private methods do not go into VTable
      If *m\visibility = "Private" Or UCase(*m\name) = "INIT"
        Continue
      EndIf

      ; Check if overriding an existing VTable slot
      Protected isOverridden.b = #False
      ForEach *c\VTableSlots()
        If UCase(*c\VTableSlots()\methodName) = UCase(*m\name)
          ; Override slot with current class implementation
          *c\VTableSlots()\implementingClass = *c\name
          *c\VTableSlots()\params = *m\params
          *c\VTableSlots()\returnType = *m\returnType
          *c\VTableSlots()\isAbstract = *m\isAbstract
          *m\isOverride = #True
          isOverridden = #True
          Break
        EndIf
      Next

      If Not isOverridden
        ; New virtual method
        AddElement(*c\VTableSlots())
        *c\VTableSlots()\methodName = *m\name
        *c\VTableSlots()\implementingClass = *c\name
        *c\VTableSlots()\declaringClass = *c\name
        *c\VTableSlots()\params = *m\params
        *c\VTableSlots()\returnType = *m\returnType
        *c\VTableSlots()\isAbstract = *m\isAbstract
        *m\isOverride = #False
      EndIf
    Next
  Next

  ; Update VTable slots if out-of-class Method implementations are present
  ForEach MethodBodies()
    Protected *mb.OOP_MethodBody = @MethodBodies()
    If FindMapElement(ClassMap(), *mb\className)
      Protected cIdx.i = ClassMap(*mb\className)
      PushListPosition(Classes())
      SelectElement(Classes(), cIdx)
      Protected *targetCls.OOP_Class = @Classes()
      ForEach *targetCls\VTableSlots()
        If UCase(*targetCls\VTableSlots()\methodName) = UCase(*mb\methodName)
          *targetCls\VTableSlots()\implementingClass = *mb\className
          *targetCls\VTableSlots()\isAbstract = #False
        EndIf
      Next
      PopListPosition(Classes())
    EndIf
  Next

  ProcedureReturn #True
EndProcedure

Procedure.b ValidateOOPModel()
  ; 1. Check that concrete classes implement all abstract methods
  ForEach Classes()
    Protected *c.OOP_Class = @Classes()
    If Not *c\isAbstract
      ForEach *c\VTableSlots()
        If *c\VTableSlots()\isAbstract
          ; Check if there is an implementation in MethodBodies
          Protected hasImpl.b = #False
          ForEach MethodBodies()
            If MethodBodies()\className = *c\name And UCase(MethodBodies()\methodName) = UCase(*c\VTableSlots()\methodName)
              hasImpl = #True
              Break
            EndIf
          Next
          If Not hasImpl
            PrintN("[ERROR] Class '" + *c\name + "' must implement abstract method '" + *c\VTableSlots()\methodName + "' declared in abstract class '" + *c\VTableSlots()\declaringClass + "' (or be declared Abstract Class).")
            ProcedureReturn #False
          EndIf
        EndIf
      Next
    EndIf
  Next

  ; 2. Check that abstract classes are not instantiated in MainLines
  ForEach Classes()
    If Classes()\isAbstract
      Protected absName.s = Classes()\name
      Protected absUpper.s = UCase(absName)
      ForEach MainLines()
        Protected mLine.s = MainLines()
        Protected upLine.s = UCase(mLine)
        If FindString(upLine, "NEW(" + absUpper + ")") > 0 Or FindString(upLine, "NEW(" + absUpper + ",") > 0 Or FindString(upLine, "NEW( " + absUpper + ")") > 0 Or FindString(upLine, "NEW( " + absUpper + ",") > 0 Or FindString(upLine, "NEW " + absUpper + "(") > 0 Or FindString(upLine, "NEW  " + absUpper + "(") > 0
          PrintN("[ERROR] Cannot instantiate abstract class '" + absName + "'.")
          ProcedureReturn #False
        EndIf
      Next
    EndIf
  Next

  ProcedureReturn #True
EndProcedure

; ----------------------------------------------------------------------------
; Code Generation Phase: Emit PureBasic Code
; ----------------------------------------------------------------------------

Procedure.s TranspileMethodBodyLine(line.s, className.s, parentClassName.s)
  Protected res.s = line
  
  ; 1. Handle 'Super::Method(' or 'Super\Method(' calls
  Protected pSuper.i = FindString(res, "Super::")
  If pSuper = 0
    pSuper = FindString(res, "Super\")
  EndIf
  
  While pSuper > 0
    Protected sepLen.i = 7
    If Mid(res, pSuper, 6) = "Super\"
      sepLen = 6
    EndIf
    
    Protected pOpen.i = FindString(res, "(", pSuper)
    If pOpen > 0
      Protected methName.s = Trim(Mid(res, pSuper + sepLen, pOpen - (pSuper + sepLen)))
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
    If pSuper = 0
      pSuper = FindString(res, "Super\", pSuper + 1)
    EndIf
  Wend
  
  ; 2. Handle internal method calls 'This\Method(' -> '*This_vt\Method('
  If FindMapElement(ClassMap(), className)
    PushListPosition(Classes())
    SelectElement(Classes(), ClassMap(className))
    ForEach Classes()\VTableSlots()
      Protected mName.s = Classes()\VTableSlots()\methodName
      If mName <> ""
        res = ReplaceString(res, "This\" + mName + "(", "*This_vt\" + mName + "(")
        res = ReplaceString(res, "*This\" + mName + "(", "*This_vt\" + mName + "(")
      EndIf
    Next
    PopListPosition(Classes())
  EndIf

  ; 3. Replace remaining 'This' with '*This' cleanly (e.g. This\field and FreeStructure(This))
  res = ReplaceWord(res, "This", "*This")
  
  ProcedureReturn res
EndProcedure

Procedure.s TranspileMainLine(line.s)
  Protected res.s = line
  
  ; 1. Replace 'New(ClassName, ...)' or 'New ClassName(...)' with 'New_ClassName(...)'
  ForEach Classes()
    Protected cName.s = Classes()\name
    
    ; Replace New(ClassName, ...) -> New_ClassName(...)
    ; Replace New(ClassName) -> New_ClassName()
    res = ReplaceString(res, "New(" + cName + ",", "New_" + cName + "(")
    res = ReplaceString(res, "New(" + cName + ")", "New_" + cName + "()")
    res = ReplaceString(res, "New( " + cName + ",", "New_" + cName + "(")
    res = ReplaceString(res, "New( " + cName + " )", "New_" + cName + "()")
    
    ; Replace New ClassName(...) -> New_ClassName(...)
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

  ; Emit Forward Declarations (Declare)
  ForEach MethodBodies()
    Protected *mbDecl.OOP_MethodBody = @MethodBodies()
    Protected declHeader.s = "Declare" + *mbDecl\returnType + " " + *mbDecl\className + "_" + *mbDecl\methodName + "(*This." + *mbDecl\className + "_Inst"
    If *mbDecl\params <> ""
      declHeader + ", " + *mbDecl\params
    EndIf
    declHeader + ")"
    WriteStringN(file, declHeader)
  Next
  WriteStringN(file, "")

  ; Emit Procedure implementations
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
    WriteStringN(file, "  Protected *This_vt." + *mb\className + "_vt = *This")
    
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
    If Not *c\isAbstract
      WriteStringN(file, "  " + *c\name + "_VTable_Data:")
      ForEach *c\VTableSlots()
        WriteStringN(file, "    Data.i @" + *c\VTableSlots()\implementingClass + "_" + *c\VTableSlots()\methodName + "()")
      Next
    EndIf
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
    If *c\isAbstract
      Continue
    EndIf

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
; Public Transpiler Function for IDE / CLI
; ----------------------------------------------------------------------------

Procedure.b TranspileSourceFile(inputPBO.s, outputPB.s)
  If Not ParsePBO(inputPBO)
    ProcedureReturn #False
  EndIf
  If Not BuildVTables()
    ProcedureReturn #False
  EndIf
  If Not ValidateOOPModel()
    ProcedureReturn #False
  EndIf
  ProcedureReturn GenerateTargetPB(outputPB)
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

  If Not TranspileSourceFile(inputPBO, outputPB)
    PrintN("[ERROR] Failed to transpile file: " + inputPBO)
    CloseConsole()
    ProcedureReturn 1
  EndIf

  PrintN("[INFO] Parsed " + Str(ListSize(Classes())) + " classes, " + Str(ListSize(MethodBodies())) + " method implementations.")
  PrintN("[SUCCESS] Successfully transpiled to: " + outputPB)
  PrintN("=================================================================")
  CloseConsole()
  ProcedureReturn 0
EndProcedure

Main()
