; ============================================================================
; Title:       PureBasic OOP Transpiler / Code Generator (Full OOP Engine)
; Description: Transpiles OOP syntax (.pbo) to native PureBasic code (.pb)
;              Supports Single Inheritance, Dynamic VTable Polymorphism,
;              Method Overriding, 'Super::' / 'Super\' calls, 'New' instantiation,
;              inline / out-of-class method bodies, Syntax/Semantic Checking,
;              and Source Line Mapping (.pb.map).
; Author:      MicrodevWeb
; ============================================================================

EnableExplicit

; ----------------------------------------------------------------------------
; Data Structures for OOP Meta-Model
; ----------------------------------------------------------------------------

Structure OOP_Field
  name.s          ; e.g. "nom.s"
  visibility.s    ; "Public", "Protected", "Private"
  srcLineNumber.i
EndStructure

Structure OOP_Method
  name.s          ; e.g. "Crier"
  rawDecl.s       ; e.g. "Public Method Crier()"
  params.s        ; e.g. "nourriture.s, quantite.i"
  returnType.s    ; e.g. ".i", ".s", ""
  visibility.s    ; "Public", "Protected", "Private"
  isOverride.b
  isAbstract.b
  srcLineNumber.i
EndStructure

Structure OOP_VTableSlot
  methodName.s
  implementingClass.s
  declaringClass.s
  params.s
  returnType.s
  isAbstract.b
  srcLineNumber.i
EndStructure

Structure OOP_Class
  name.s
  parentName.s    ; empty if base class
  isAbstract.b
  srcLineNumber.i
  List Fields.OOP_Field()
  List Methods.OOP_Method()
  List VTableSlots.OOP_VTableSlot()
  hasInit.b
  initParams.s
  hasFree.b
EndStructure

Structure OOP_SourceLine
  content.s
  srcLineNumber.i
EndStructure

Structure OOP_MethodBody
  className.s
  methodName.s
  params.s
  returnType.s
  srcLineNumber.i
  List BodyLines.OOP_SourceLine()
EndStructure

Structure OOP_GeneratedLine
  content.s
  srcLineNumber.i
EndStructure

; ----------------------------------------------------------------------------
; Global Transpiler State
; ----------------------------------------------------------------------------

Global NewList Classes.OOP_Class()
Global NewMap ClassMap.i() ; Map ClassName to ListIndex
Global NewList MethodBodies.OOP_MethodBody()
Global NewList MainLines.OOP_SourceLine()
Global NewList FileLines.s()
Global NewList GeneratedLines.OOP_GeneratedLine()

Global LastErrorMessage.s = ""
Global LastErrorLine.i = 0
Global LastErrorFile.s = ""

Procedure SetOOPError(lineNum.i, message.s)
  LastErrorLine = lineNum
  LastErrorMessage = message
  PrintN("[ERROR] Line " + Str(lineNum) + ": " + message)
EndProcedure

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

Procedure.s StripComment(text.s)
  Protected inQuotes.b = #False
  Protected i.i, lenT.i = Len(text)
  For i = 1 To lenT
    Protected c.s = Mid(text, i, 1)
    If c = Chr(34)
      inQuotes = ~inQuotes & 1
    ElseIf c = ";" And Not inQuotes
      ProcedureReturn Trim(Left(text, i - 1))
    EndIf
  Next
  ProcedureReturn Trim(text)
EndProcedure

Procedure.b IsValidFieldDeclaration(decl.s)
  Protected d.s = Trim(decl)
  Protected up.s = UCase(d)
  If up = "STRUCTUREUNION" Or up = "ENDSTRUCTUREUNION"
    ProcedureReturn #True
  EndIf
  If Left(up, 5) = "LIST " Or Left(up, 4) = "MAP " Or Left(up, 6) = "ARRAY "
    ProcedureReturn #True
  EndIf
  If Left(d, 1) = "*"
    ProcedureReturn #True
  EndIf
  If FindString(d, ".") > 0
    ProcedureReturn #True
  EndIf
  ProcedureReturn #False
EndProcedure

Procedure.b ParsePBO(inputFile.s)
  LastErrorFile = inputFile
  LastErrorLine = 0
  LastErrorMessage = ""

  Protected file = ReadFile(#PB_Any, inputFile)
  If Not file
    SetOOPError(1, "Cannot open source file: " + inputFile)
    ProcedureReturn #False
  EndIf

  ClearList(FileLines())
  Protected isFirstLine.b = #True
  While Not Eof(file)
    AddElement(FileLines())
    FileLines() = ReadString(file)
    ; Strip UTF-8 BOM if present
    If isFirstLine
      If Left(FileLines(), 1) = Chr(239) Or Asc(Left(FileLines(), 1)) = 65279
        FileLines() = Mid(FileLines(), 2)
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
  Protected currentLineNum.i = 0
  Protected classStartLine.i = 0
  Protected methodStartLine.i = 0

  ForEach FileLines()
    currentLineNum + 1
    rawLine = FileLines()
    line = StripComment(rawLine)
    upper = UCase(line)

    ; 1. Parsing inside Inline Class Method Body
    If inClassMethod
      If Left(upper, 9) = "ENDMETHOD"
        inClassMethod = #False
        *currentMethod = #Null
        Continue
      Else
        AddElement(*currentMethod\BodyLines())
        *currentMethod\BodyLines()\content = rawLine
        *currentMethod\BodyLines()\srcLineNumber = currentLineNum
        Continue
      EndIf

    ; 2. Parsing inside Class definition
    ElseIf inClass
      If Left(upper, 8) = "ENDCLASS"
        inClass = #False
        *currentClass = #Null
        Continue
      ElseIf Left(upper, 9) = "ENDMETHOD"
        SetOOPError(currentLineNum, "Unexpected 'EndMethod' inside Class definition without matching Method header")
        ProcedureReturn #False
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

          ; Check duplicate method declaration in same class
          ForEach *currentClass\Methods()
            If UCase(*currentClass\Methods()\name) = UCase(mName)
              SetOOPError(currentLineNum, "Duplicate Method '" + mName + "' in Class '" + *currentClass\name + "'")
              ProcedureReturn #False
            EndIf
          Next

          AddElement(*currentClass\Methods())
          *currentClass\Methods()\name = mName
          *currentClass\Methods()\rawDecl = line
          *currentClass\Methods()\params = mParams
          *currentClass\Methods()\returnType = mRet
          *currentClass\Methods()\visibility = vis
          *currentClass\Methods()\isAbstract = isAbsMeth
          *currentClass\Methods()\srcLineNumber = currentLineNum
          
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
            *currentMethod\srcLineNumber = currentLineNum
            inClassMethod = #True
            methodStartLine = currentLineNum
          EndIf
          Continue

        ElseIf matchedPrefix Or (line <> "" And Left(line, 1) <> ";")
          If Not IsValidFieldDeclaration(workLine)
            SetOOPError(currentLineNum, "Syntax error or invalid declaration '" + workLine + "' in Class '" + *currentClass\name + "'")
            ProcedureReturn #False
          EndIf
          ; Field declaration
          AddElement(*currentClass\Fields())
          *currentClass\Fields()\name = workLine
          *currentClass\Fields()\visibility = vis
          *currentClass\Fields()\srcLineNumber = currentLineNum
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
        *currentMethod\BodyLines()\content = rawLine
        *currentMethod\BodyLines()\srcLineNumber = currentLineNum
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

        If cName = ""
          SetOOPError(currentLineNum, "Missing class name in Class declaration")
          ProcedureReturn #False
        EndIf

        If FindMapElement(ClassMap(), cName)
          SetOOPError(currentLineNum, "Duplicate Class '" + cName + "'")
          ProcedureReturn #False
        EndIf

        AddElement(Classes())
        *currentClass = @Classes()
        *currentClass\name = cName
        *currentClass\parentName = pName
        *currentClass\isAbstract = isAbsClass
        *currentClass\srcLineNumber = currentLineNum
        ClassMap(cName) = ListIndex(Classes())
        inClass = #True
        classStartLine = currentLineNum
        Continue

      ElseIf Left(upper, 8) = "ENDCLASS"
        SetOOPError(currentLineNum, "Unexpected 'EndClass' without preceding Class declaration")
        ProcedureReturn #False

      ElseIf Left(upper, 9) = "ENDMETHOD"
        SetOOPError(currentLineNum, "Unexpected 'EndMethod' without preceding Method implementation")
        ProcedureReturn #False

      ElseIf Left(upper, 6) = "METHOD" And (Len(upper) = 6 Or Mid(upper, 7, 1) = " " Or Mid(upper, 7, 1) = ".")
        ; Out-of-class method implementation: Method ClassName::MethodName(params)
        Protected outDecl.s = Trim(Mid(line, 7))
        Protected outRet.s = ""
        
        If Left(outDecl, 1) = "."
          p1 = FindString(outDecl, " ")
          If p1 > 0
            outRet = Left(outDecl, p1 - 1)
            outDecl = Trim(Mid(outDecl, p1 + 1))
          EndIf
        EndIf
        
        Protected c_name.s = "", m_name.s = "", m_params.s = ""
        p1 = FindString(outDecl, "::")
        If p1 > 0
          c_name = Trim(Left(outDecl, p1 - 1))
          Protected afterScope.s = Trim(Mid(outDecl, p1 + 2))
          p2 = FindString(afterScope, "(")
          If p2 > 0
            m_name = Trim(Left(afterScope, p2 - 1))
            p3 = FindString(afterScope, ")", p2)
            If p3 > p2
              m_params = Trim(Mid(afterScope, p2 + 1, p3 - p2 - 1))
            EndIf
          Else
            m_name = afterScope
          EndIf
        Else
          SetOOPError(currentLineNum, "Out-of-class Method implementation must use 'ClassName::MethodName' syntax")
          ProcedureReturn #False
        EndIf

        ; Check if class exists
        If Not FindMapElement(ClassMap(), c_name)
          SetOOPError(currentLineNum, "Method implementation for undefined Class '" + c_name + "'")
          ProcedureReturn #False
        EndIf

        ; Check if method was declared in the class or inherited
        Protected isDeclared.b = #False
        PushListPosition(Classes())
        SelectElement(Classes(), ClassMap(c_name))
        ForEach Classes()\Methods()
          If UCase(Classes()\Methods()\name) = UCase(m_name)
            isDeclared = #True
            If outRet = "" And Classes()\Methods()\returnType <> ""
              outRet = Classes()\Methods()\returnType
            EndIf
            If m_params = "" And Classes()\Methods()\params <> ""
              m_params = Classes()\Methods()\params
            EndIf
            Break
          EndIf
        Next
        PopListPosition(Classes())

        AddElement(MethodBodies())
        *currentMethod = @MethodBodies()
        *currentMethod\className = c_name
        *currentMethod\methodName = m_name
        *currentMethod\params = m_params
        *currentMethod\returnType = outRet
        *currentMethod\srcLineNumber = currentLineNum
        inMethod = #True
        methodStartLine = currentLineNum
        Continue

      Else
        ; Regular PureBasic top-level line
        AddElement(MainLines())
        MainLines()\content = rawLine
        MainLines()\srcLineNumber = currentLineNum
      EndIf
    EndIf
  Next

  ; Validate open blocks
  If inClass
    SetOOPError(classStartLine, "Unclosed Class '" + *currentClass\name + "' - missing EndClass")
    ProcedureReturn #False
  EndIf

  If inMethod Or inClassMethod
    SetOOPError(methodStartLine, "Unclosed Method '" + *currentMethod\methodName + "' - missing EndMethod")
    ProcedureReturn #False
  EndIf

  ProcedureReturn #True
EndProcedure

; ----------------------------------------------------------------------------
; Semantic Analysis & VTable Construction
; ----------------------------------------------------------------------------

Procedure.b BuildVTables()
  ForEach Classes()
    Protected *c.OOP_Class = @Classes()
    ClearList(*c\VTableSlots())

    ; Inherit slots from parent class
    If *c\parentName <> ""
      If Not FindMapElement(ClassMap(), *c\parentName)
        SetOOPError(*c\srcLineNumber, "Class '" + *c\name + "' extends unknown parent class '" + *c\parentName + "'")
        ProcedureReturn #False
      EndIf
      
      Protected parentIdx.i = ClassMap(*c\parentName)
      PushListPosition(Classes())
      SelectElement(Classes(), parentIdx)
      Protected *parent.OOP_Class = @Classes()
      ForEach *parent\VTableSlots()
        AddElement(*c\VTableSlots())
        *c\VTableSlots()\methodName = *parent\VTableSlots()\methodName
        *c\VTableSlots()\implementingClass = *parent\VTableSlots()\implementingClass
        *c\VTableSlots()\declaringClass = *parent\VTableSlots()\declaringClass
        *c\VTableSlots()\params = *parent\VTableSlots()\params
        *c\VTableSlots()\returnType = *parent\VTableSlots()\returnType
        *c\VTableSlots()\isAbstract = *parent\VTableSlots()\isAbstract
        *c\VTableSlots()\srcLineNumber = *parent\VTableSlots()\srcLineNumber
      Next
      PopListPosition(Classes())
    EndIf

    ; Process methods declared in current class
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
          *c\VTableSlots()\implementingClass = *c\name
          *c\VTableSlots()\params = *m\params
          *c\VTableSlots()\returnType = *m\returnType
          *c\VTableSlots()\isAbstract = *m\isAbstract
          *c\VTableSlots()\srcLineNumber = *m\srcLineNumber
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
        *c\VTableSlots()\srcLineNumber = *m\srcLineNumber
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
            SetOOPError(*c\srcLineNumber, "Class '" + *c\name + "' must implement abstract method '" + *c\VTableSlots()\methodName + "' declared in abstract class '" + *c\VTableSlots()\declaringClass + "' (or be declared Abstract Class).")
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
        Protected mLine.s = MainLines()\content
        Protected upLine.s = UCase(mLine)
        If FindString(upLine, "NEW(" + absUpper + ")") > 0 Or FindString(upLine, "NEW(" + absUpper + ",") > 0 Or FindString(upLine, "NEW( " + absUpper + ")") > 0 Or FindString(upLine, "NEW( " + absUpper + ",") > 0 Or FindString(upLine, "NEW " + absUpper + "(") > 0 Or FindString(upLine, "NEW  " + absUpper + "(") > 0
          SetOOPError(MainLines()\srcLineNumber, "Cannot instantiate abstract class '" + absName + "'")
          ProcedureReturn #False
        EndIf
      Next
    EndIf
  Next

  ; 3. Check Super:: calls in method bodies
  ForEach MethodBodies()
    Protected *body.OOP_MethodBody = @MethodBodies()
    Protected parentClsName.s = ""
    If FindMapElement(ClassMap(), *body\className)
      parentClsName = Classes()\parentName
    EndIf

    ForEach *body\BodyLines()
      Protected bLine.s = *body\BodyLines()\content
      Protected pSup.i = FindString(bLine, "Super::")
      If pSup = 0
        pSup = FindString(bLine, "Super\")
      EndIf
      If pSup > 0
        If parentClsName = ""
          SetOOPError(*body\BodyLines()\srcLineNumber, "Cannot call 'Super::' in Class '" + *body\className + "' because it does not inherit from any class")
          ProcedureReturn #False
        EndIf
      EndIf
    Next
  Next

  ProcedureReturn #True
EndProcedure

; ----------------------------------------------------------------------------
; Code Generation Phase: Emit PureBasic Code & Source Map
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

  ; 3. Replace remaining 'This' with '*This'
  res = ReplaceWord(res, "This", "*This")
  
  ProcedureReturn res
EndProcedure

Procedure.s TranspileMainLine(line.s)
  Protected res.s = line
  
  ForEach Classes()
    Protected cName.s = Classes()\name
    
    res = ReplaceString(res, "New(" + cName + ",", "New_" + cName + "(")
    res = ReplaceString(res, "New(" + cName + ")", "New_" + cName + "()")
    res = ReplaceString(res, "New( " + cName + ",", "New_" + cName + "(")
    res = ReplaceString(res, "New( " + cName + " )", "New_" + cName + "()")
    
    res = ReplaceString(res, "New " + cName + "(", "New_" + cName + "(")
    res = ReplaceString(res, "New  " + cName + "(", "New_" + cName + "(")
    
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

Procedure EmitLine(content.s, srcLine.i = 0)
  AddElement(GeneratedLines())
  GeneratedLines()\content = content
  GeneratedLines()\srcLineNumber = srcLine
EndProcedure

Procedure.b GenerateTargetPB(outputFile.s, inputPBO.s)
  ClearList(GeneratedLines())

  EmitLine("; ============================================================================")
  EmitLine("; Generated by PureBasic OOP Transpiler (Native OOP Engine)")
  EmitLine("; Do not edit directly - modify the corresponding .pbo source file.")
  EmitLine("; ============================================================================")
  EmitLine("")
  EmitLine("EnableExplicit")
  EmitLine("")

  ; 1. Generate Interfaces
  EmitLine("; " + RSet("", 76, "-"))
  EmitLine("; 1. PUREBASIC INTERFACES (VTABLE PROTOTYPES)")
  EmitLine("; " + RSet("", 76, "-"))
  EmitLine("")

  ForEach Classes()
    Protected *c.OOP_Class = @Classes()
    If *c\parentName <> ""
      EmitLine("Interface " + *c\name + "_vt Extends " + *c\parentName + "_vt", *c\srcLineNumber)
    Else
      EmitLine("Interface " + *c\name + "_vt", *c\srcLineNumber)
    EndIf

    ForEach *c\Methods()
      Protected *m.OOP_Method = @*c\Methods()
      If *m\visibility <> "Private" And UCase(*m\name) <> "INIT"
        If *c\parentName = "" Or Not *m\isOverride
          EmitLine("  " + *m\name + *m\returnType + "(" + *m\params + ")", *m\srcLineNumber)
        EndIf
      EndIf
    Next

    EmitLine("EndInterface")
    EmitLine("")
  Next

  ; 2. Generate Instance Structures
  EmitLine("; " + RSet("", 76, "-"))
  EmitLine("; 2. INSTANCE STRUCTURES")
  EmitLine("; " + RSet("", 76, "-"))
  EmitLine("")

  ForEach Classes()
    *c = @Classes()
    If *c\parentName <> ""
      EmitLine("Structure " + *c\name + "_Inst Extends " + *c\parentName + "_Inst", *c\srcLineNumber)
    Else
      EmitLine("Structure " + *c\name + "_Inst", *c\srcLineNumber)
      EmitLine("  *VTable." + *c\name + "_vt")
    EndIf

    ForEach *c\Fields()
      EmitLine("  " + *c\Fields()\name, *c\Fields()\srcLineNumber)
    Next

    EmitLine("EndStructure")
    EmitLine("")
  Next

  ; 3. Generate Method Procedures
  EmitLine("; " + RSet("", 76, "-"))
  EmitLine("; 3. METHOD PROCEDURES IMPLEMENTATION")
  EmitLine("; " + RSet("", 76, "-"))
  EmitLine("")

  ; Forward Declarations
  ForEach MethodBodies()
    Protected *mbDecl.OOP_MethodBody = @MethodBodies()
    Protected declHeader.s = "Declare" + *mbDecl\returnType + " " + *mbDecl\className + "_" + *mbDecl\methodName + "(*This." + *mbDecl\className + "_Inst"
    If *mbDecl\params <> ""
      declHeader + ", " + *mbDecl\params
    EndIf
    declHeader + ")"
    EmitLine(declHeader, *mbDecl\srcLineNumber)
  Next
  EmitLine("")

  ; Implementations
  ForEach MethodBodies()
    Protected *mb.OOP_MethodBody = @MethodBodies()
    Protected parentOfClass.s = ""
    If FindMapElement(ClassMap(), *mb\className)
      parentOfClass = Classes()\parentName
    EndIf

    Protected procHeader.s = "Procedure" + *mb\returnType + " " + *mb\className + "_" + *mb\methodName + "(*This." + *mb\className + "_Inst"
    If *mb\params <> ""
      procHeader + ", " + *mb\params
    EndIf
    procHeader + ")"
    
    EmitLine(procHeader, *mb\srcLineNumber)
    EmitLine("  Protected *This_vt." + *mb\className + "_vt = *This", *mb\srcLineNumber)
    
    ForEach *mb\BodyLines()
      Protected transpiledBody.s = TranspileMethodBodyLine(*mb\BodyLines()\content, *mb\className, parentOfClass)
      EmitLine("  " + transpiledBody, *mb\BodyLines()\srcLineNumber)
    Next
    
    EmitLine("EndProcedure", *mb\srcLineNumber)
    EmitLine("")
  Next

  ; Auto-generate default Free() destructor
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
        EmitLine("Procedure " + *c\name + "_Free(*This." + *c\name + "_Inst)", *c\srcLineNumber)
        EmitLine("  FreeStructure(*This)", *c\srcLineNumber)
        EmitLine("EndProcedure")
        EmitLine("")
      EndIf
    EndIf
  Next

  ; 4. Generate VTable DataSections
  EmitLine("; " + RSet("", 76, "-"))
  EmitLine("; 4. VTABLE DATASECTIONS (DYNAMIC DISPATCH)")
  EmitLine("; " + RSet("", 76, "-"))
  EmitLine("")
  EmitLine("DataSection")

  ForEach Classes()
    *c = @Classes()
    If Not *c\isAbstract
      EmitLine("  " + *c\name + "_VTable_Data:", *c\srcLineNumber)
      ForEach *c\VTableSlots()
        EmitLine("    Data.i @" + *c\VTableSlots()\implementingClass + "_" + *c\VTableSlots()\methodName + "()", *c\VTableSlots()\srcLineNumber)
      Next
    EndIf
  Next

  EmitLine("EndDataSection")
  EmitLine("")

  ; 5. Generate Constructors
  EmitLine("; " + RSet("", 76, "-"))
  EmitLine("; 5. CONSTRUCTORS & FACTORY FUNCTIONS")
  EmitLine("; " + RSet("", 76, "-"))
  EmitLine("")

  ForEach Classes()
    *c = @Classes()
    If *c\isAbstract
      Continue
    EndIf

    Protected ctorParams.s = ""
    If *c\hasInit
      ctorParams = *c\initParams
    EndIf

    EmitLine("Procedure.i New_" + *c\name + "(" + ctorParams + ")", *c\srcLineNumber)
    EmitLine("  Protected *obj." + *c\name + "_Inst = AllocateStructure(" + *c\name + "_Inst)", *c\srcLineNumber)
    EmitLine("  If *obj")
    EmitLine("    *obj\VTable = ?" + *c\name + "_VTable_Data")
    If *c\hasInit
      Protected callInitParams.s = "*obj"
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
      EmitLine("    " + *c\name + "_Init(" + callInitParams + ")", *c\srcLineNumber)
    EndIf
    EmitLine("  EndIf")
    EmitLine("  ProcedureReturn *obj")
    EmitLine("EndProcedure")
    EmitLine("")
  Next

  ; 6. Generate Main Execution Code
  EmitLine("; " + RSet("", 76, "-"))
  EmitLine("; 6. MAIN PROGRAM EXECUTION")
  EmitLine("; " + RSet("", 76, "-"))
  EmitLine("")

  ForEach MainLines()
    Protected transpiledMain.s = TranspileMainLine(MainLines()\content)
    EmitLine(transpiledMain, MainLines()\srcLineNumber)
  Next

  ; Write Target .pb File
  Protected file = CreateFile(#PB_Any, outputFile)
  If Not file
    SetOOPError(1, "Cannot create output file: " + outputFile)
    ProcedureReturn #False
  EndIf

  ForEach GeneratedLines()
    WriteStringN(file, GeneratedLines()\content)
  Next
  CloseFile(file)

  ; Write Target .pb.map File
  Protected mapFile.s = outputFile + ".map"
  Protected fMap = CreateFile(#PB_Any, mapFile)
  If fMap
    WriteStringN(fMap, "# PBO_SOURCEMAP_V1")
    WriteStringN(fMap, "SOURCE:" + inputPBO)
    WriteStringN(fMap, "TARGET:" + outputFile)
    WriteStringN(fMap, "MAP:")
    Protected pbLineIdx.i = 0
    ForEach GeneratedLines()
      pbLineIdx + 1
      If GeneratedLines()\srcLineNumber > 0
        WriteStringN(fMap, Str(pbLineIdx) + ":" + Str(GeneratedLines()\srcLineNumber))
      EndIf
    Next
    CloseFile(fMap)
  EndIf

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
  ProcedureReturn GenerateTargetPB(outputPB, inputPBO)
EndProcedure

Procedure.b CheckSourceFileSyntax(inputPBO.s)
  If Not ParsePBO(inputPBO)
    ProcedureReturn #False
  EndIf
  If Not BuildVTables()
    ProcedureReturn #False
  EndIf
  If Not ValidateOOPModel()
    ProcedureReturn #False
  EndIf
  ProcedureReturn #True
EndProcedure

; ----------------------------------------------------------------------------
; Main CLI Entry Point
; ----------------------------------------------------------------------------

Procedure.i Main()
  OpenConsole()

  Protected argCount.i = CountProgramParameters()
  Protected arg0.s = ProgramParameter(0)
  Protected arg1.s = ProgramParameter(1)

  ; Support --check or -c syntax checking flag
  If UCase(arg0) = "--CHECK" Or UCase(arg0) = "-C" Or UCase(arg0) = "/CHECK"
    Protected checkFile.s = arg1
    If checkFile = ""
      PrintN("[ERROR] Missing filename for --check")
      CloseConsole()
      ProcedureReturn 1
    EndIf
    If CheckSourceFileSyntax(checkFile)
      PrintN("[OK]")
      CloseConsole()
      ProcedureReturn 0
    Else
      CloseConsole()
      ProcedureReturn 1
    EndIf
  EndIf

  Protected inputPBO.s = arg0
  Protected outputPB.s = arg1

  If inputPBO = ""
    inputPBO = "../src/test_polymorphisme.pbo"
    outputPB = "../src/test_polymorphisme_generated.pb"
  EndIf

  If outputPB = ""
    outputPB = ReplaceString(inputPBO, ".pbo", "_generated.pb", #PB_String_NoCase)
  EndIf
  PrintN("=================================================================")
  PrintN("           PureBasic OOP Transpiler (Native Engine)              ")
  PrintN("=================================================================")
  PrintN("Input  PBO : " + inputPBO)
  PrintN("Output PB  : " + outputPB)
  PrintN("")

  If Not TranspileSourceFile(inputPBO, outputPB)
    PrintN("[ERROR] Transpilation failed for file: " + inputPBO)
    CloseConsole()
    ProcedureReturn 1
  EndIf

  PrintN("[INFO] Parsed " + Str(ListSize(Classes())) + " classes, " + Str(ListSize(MethodBodies())) + " method implementations.")
  PrintN("[SUCCESS] Successfully transpiled to: " + outputPB)
  PrintN("=================================================================")
  CloseConsole()
  ProcedureReturn 0
EndProcedure

End Main()
