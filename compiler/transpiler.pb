; ============================================================================
; Title:       PureBasic OOP Transpiler / Code Generator (Full OOP Engine)
; Description: Transpiles OOP syntax (.pbo) to native PureBasic code (.pb)
;              Supports Single Inheritance, Dynamic VTable Polymorphism,
;              Method Overriding, Method Overloading (Surcharge de methodes),
;              Multiple Constructors (Init overloads), Default Parameters,
;              'Super::' / 'Super\' calls, 'New' instantiation,
;              inline / out-of-class method bodies, Syntax/Semantic Checking,
;              Source Line Mapping (.pb.map), Hierarchical Namespaces,
;              'Using' directives, Namespace Aliases, and Multi-File Includes.
; Author:      MicrodevWeb
; Version:     ALPHA 1.2 (Method Overloading & Multi-Constructors)
; ============================================================================

EnableExplicit

; ----------------------------------------------------------------------------
; Data Structures for OOP Meta-Model
; ----------------------------------------------------------------------------

Structure OOP_Field
  name.s          ; e.g. "nom.s"
  visibility.s    ; "Public", "Protected", "Private"
  srcLineNumber.i
  srcFile.s
EndStructure

Structure OOP_Method
  name.s              ; e.g. "Additionner"
  rawDecl.s           ; e.g. "Public Method Additionner(a.i, b.i)"
  params.s            ; e.g. "a.i, b.i = 10" (raw params with defaults)
  cleanParams.s       ; e.g. "a.i, b.i" (types only, defaults stripped)
  returnType.s        ; e.g. ".i", ".s", ""
  visibility.s        ; "Public", "Protected", "Private"
  isOverride.b
  isAbstract.b
  signature.s         ; e.g. "i_i", "s_s", "void"
  paramCount.i        ; Total parameters
  minParamCount.i     ; Minimum required parameters (excluding defaults)
  mangledMethodName.s ; Unique name in Interface & VTable e.g. "Additionner_i_i" or "Additionner"
  hasDefaults.b
  srcLineNumber.i
  srcFile.s
EndStructure

Structure OOP_VTableSlot
  methodName.s        ; mangled slot name (e.g. "Additionner_i_i" or "Additionner")
  baseMethodName.s    ; original method name (e.g. "Additionner")
  signature.s         ; e.g. "i_i"
  implementingClass.s ; fullName
  declaringClass.s    ; fullName
  params.s            ; raw params
  cleanParams.s       ; params without defaults
  returnType.s
  isAbstract.b
  paramCount.i
  minParamCount.i
  srcLineNumber.i
  srcFile.s
EndStructure

Structure OOP_InitConstructor
  params.s            ; raw parameters
  cleanParams.s       ; parameters without defaults
  signature.s         ; e.g. "i_i", "void"
  paramCount.i
  minParamCount.i
  mangledName.s       ; e.g. "New_ClassName_i_i" or "New_ClassName"
  initProcMangled.s   ; e.g. "ClassName_Init_i_i"
  srcLineNumber.i
  srcFile.s
EndStructure

#ORM_Rel_OneToMany   = 1
#ORM_Rel_ManyToOne   = 2
#ORM_Rel_ManyToMany  = 3
#ORM_Rel_OneToOne    = 4

#Cascade_None        = 0
#Cascade_Save        = 1
#Cascade_Delete      = 2
#Cascade_All         = 3

Structure OOP_Relation
  relationType.i
  propertyName.s
  targetClass.s
  foreignKey.s
  joinTable.s
  parentFk.s
  childFk.s
  cascade.i
  srcLineNumber.i
  srcFile.s
EndStructure

Structure OOP_Class
  name.s                ; Short name e.g. "Renderer"
  namespace.s           ; e.g. "Game::Graphics"
  fullName.s            ; e.g. "Game::Graphics::Renderer"
  mangledName.s         ; e.g. "Game_Graphics_Renderer"
  parentName.s          ; Raw parent name from Extends
  fullParentName.s      ; Resolved full parent name
  mangledParentName.s   ; Mangled parent name
  isAbstract.b
  isDatabaseEntity.b
  srcLineNumber.i
  srcFile.s
  List ImplementedInterfaces.s()
  List Relations.OOP_Relation()
  List Fields.OOP_Field()
  List Methods.OOP_Method()
  List VTableSlots.OOP_VTableSlot()
  List InitConstructors.OOP_InitConstructor()
  hasInit.b
  hasFree.b
  freeClassMangled.s
EndStructure

Structure OOP_SourceLine
  content.s
  srcLineNumber.i
  srcFile.s
EndStructure

Structure OOP_MethodBody
  className.s           ; Resolved fullName
  mangledClassName.s    ; Mangled class name
  methodName.s          ; Base method name
  signature.s           ; Computed param signature
  mangledMethodName.s   ; e.g. "Additionner_i_i" or "Additionner"
  params.s
  cleanParams.s
  returnType.s
  srcLineNumber.i
  srcFile.s
  List BodyLines.OOP_SourceLine()
EndStructure

Structure OOP_GeneratedLine
  content.s
  srcLineNumber.i
  srcFile.s
EndStructure

; ----------------------------------------------------------------------------
; Static Memory Leak Analysis Subsystem
; ----------------------------------------------------------------------------

#OOP_INSTANCE_ALLOCATED   = 0
#OOP_INSTANCE_FREED       = 1
#OOP_INSTANCE_TRANSFERRED = 2

Structure OOP_TrackedInstance
  varName.s
  className.s
  scopeName.s
  allocLineNumber.i
  allocFile.s
  state.i
EndStructure

Global StrictLeaks.b = #False
Global TotalLeaksDetected.i = 0
Global TotalInstancesManaged.i = 0

; ----------------------------------------------------------------------------
; Global Transpiler State
; ----------------------------------------------------------------------------

Global NewList Classes.OOP_Class()
Global NewMap ClassMap.i()          ; Map FullName & MangledName to ListIndex
Global NewList MethodBodies.OOP_MethodBody()
Global NewList MainLines.OOP_SourceLine()
Global NewList TypeDeclarations.OOP_SourceLine()
Global NewList HeaderDeclarations.OOP_SourceLine()
Global NewList FileSourceLines.OOP_SourceLine()
Global NewList GeneratedLines.OOP_GeneratedLine()

Global NewList NamespaceStack.s()
Global NewList UsingList.s()
Global NewMap NamespaceAliases.s()  ; Alias -> Target Namespace
Global NewMap IncludedFilesMap.i()

; Set of method names that are overloaded across the project
Global NewMap OverloadedMethodNames.i()

Global LastErrorMessage.s = ""
Global LastErrorLine.i = 0
Global LastErrorFile.s = ""

Procedure SetOOPError(lineNum.i, message.s, file.s = "")
  LastErrorLine = lineNum
  LastErrorMessage = message
  If file <> ""
    LastErrorFile = file
  EndIf
  PrintN("[ERROR] Line " + Str(lineNum) + ": " + message)
EndProcedure

; ----------------------------------------------------------------------------
; Helper Functions & Parameter Signature Utilities
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

Procedure.i FindCharOutsideQuotes(text.s, charToFind.s, startPos.i = 1)
  Protected inQuotes.b = #False
  Protected i.i, lenT.i = Len(text)
  For i = startPos To lenT
    Protected c.s = Mid(text, i, 1)
    If c = Chr(34)
      inQuotes = ~inQuotes & 1
    ElseIf Not inQuotes And c = charToFind
      ProcedureReturn i
    EndIf
  Next
  ProcedureReturn 0
EndProcedure

; Splits parameter string by comma taking quotes and parentheses into account
Procedure.i SplitParams(params.s, List outTokens.s())
  ClearList(outTokens())
  Protected p.s = Trim(params)
  If p = "" : ProcedureReturn 0 : EndIf
  
  Protected i.i, lenP.i = Len(p)
  Protected inQuotes.b = #False
  Protected parenDepth.i = 0
  Protected curToken.s = ""
  
  For i = 1 To lenP
    Protected c.s = Mid(p, i, 1)
    If c = Chr(34)
      inQuotes = ~inQuotes & 1
      curToken + c
    ElseIf c = "(" And Not inQuotes
      parenDepth + 1
      curToken + c
    ElseIf c = ")" And Not inQuotes
      If parenDepth > 0 : parenDepth - 1 : EndIf
      curToken + c
    ElseIf c = "," And Not inQuotes And parenDepth = 0
      AddElement(outTokens())
      outTokens() = Trim(curToken)
      curToken = ""
    Else
      curToken + c
    EndIf
  Next
  If Trim(curToken) <> ""
    AddElement(outTokens())
    outTokens() = Trim(curToken)
  EndIf
  ProcedureReturn ListSize(outTokens())
EndProcedure

; Extracts parameter type string e.g. "a.i" -> "i", "*buf" -> "p", "text.s = ''" -> "s"
Procedure.s ExtractParamType(paramDecl.s)
  Protected p.s = Trim(paramDecl)
  Protected pEq.i = FindString(p, "=")
  If pEq > 0
    p = Trim(Left(p, pEq - 1))
  EndIf
  If Left(p, 1) = "*"
    ProcedureReturn "p"
  EndIf
  Protected pDot.i = FindString(p, ".")
  If pDot > 0
    Protected t.s = LCase(Trim(Mid(p, pDot + 1)))
    ; Standard PB types
    If t = "i" Or t = "s" Or t = "d" Or t = "f" Or t = "q" Or t = "l" Or t = "b" Or t = "a" Or t = "u" Or t = "w" Or t = "c"
      ProcedureReturn t
    Else
      ; Custom structure / interface pointer
      ProcedureReturn "p"
    EndIf
  EndIf
  ; Default integer
  ProcedureReturn "i"
EndProcedure

; Calculates the signature string for a parameter declaration list e.g. "a.i, b.i" -> "i_i"
Procedure.s GetParamSignature(params.s)
  Protected NewList tokens.s()
  Protected count.i = SplitParams(params, tokens())
  If count = 0
    ProcedureReturn "void"
  EndIf
  Protected sig.s = ""
  ForEach tokens()
    Protected pType.s = ExtractParamType(tokens())
    If sig = ""
      sig = pType
    Else
      sig + "_" + pType
    EndIf
  Next
  ProcedureReturn sig
EndProcedure

; Removes "= defaultValue" from parameter declarations
Procedure.s GetCleanParams(params.s)
  Protected NewList tokens.s()
  Protected count.i = SplitParams(params, tokens())
  If count = 0 : ProcedureReturn "" : EndIf
  Protected res.s = ""
  ForEach tokens()
    Protected tok.s = tokens()
    Protected pEq.i = FindString(tok, "=")
    If pEq > 0
      tok = Trim(Left(tok, pEq - 1))
    EndIf
    If res = ""
      res = tok
    Else
      res + ", " + tok
    EndIf
  Next
  ProcedureReturn res
EndProcedure

; Counts minimum parameters (parameters without default values)
Procedure.i CountMinParameters(params.s)
  Protected NewList tokens.s()
  Protected count.i = SplitParams(params, tokens())
  If count = 0 : ProcedureReturn 0 : EndIf
  Protected minCount.i = 0
  ForEach tokens()
    If FindString(tokens(), "=") = 0
      minCount + 1
    EndIf
  Next
  ProcedureReturn minCount
EndProcedure

; Infers argument type from an expression passed to a method call
Procedure.s InferArgType(argExpr.s)
  Protected a.s = Trim(argExpr)
  If a = "" : ProcedureReturn "void" : EndIf
  
  ; String literal
  If Left(a, 1) = Chr(34) Or Left(a, 2) = "~" + Chr(34)
    ProcedureReturn "s"
  EndIf
  
  ; Check if it's a method call like *obj\GetText() or *obj\GetFirstName()
  If Left(a, 1) = "*" And FindString(a, "\") > 0
    Protected slashPos.i = FindString(a, "\")
    Protected methPart.s = Trim(Mid(a, slashPos + 1))
    Protected parenPos.i = FindString(methPart, "(")
    If parenPos > 0
      Protected methNameOnly.s = Trim(Left(methPart, parenPos - 1))
      Protected pDotRet.i = FindString(methNameOnly, ".")
      If pDotRet > 0
        Protected explicitRet.s = LCase(Mid(methNameOnly, pDotRet + 1))
        If explicitRet = "s" Or explicitRet = "d" Or explicitRet = "f" Or explicitRet = "i" Or explicitRet = "b"
          ProcedureReturn explicitRet
        EndIf
      EndIf
      ; Check in MethodBodies for return type
      PushListPosition(MethodBodies())
      ForEach MethodBodies()
        If UCase(MethodBodies()\methodName) = UCase(methNameOnly)
          If MethodBodies()\returnType = ".s"
            PopListPosition(MethodBodies())
            ProcedureReturn "s"
          ElseIf MethodBodies()\returnType = ".d"
            PopListPosition(MethodBodies())
            ProcedureReturn "d"
          ElseIf MethodBodies()\returnType = ".f"
            PopListPosition(MethodBodies())
            ProcedureReturn "f"
          ElseIf MethodBodies()\returnType = ".b"
            PopListPosition(MethodBodies())
            ProcedureReturn "b"
          ElseIf MethodBodies()\returnType = ".i"
            PopListPosition(MethodBodies())
            ProcedureReturn "i"
          EndIf
        EndIf
      Next
      PopListPosition(MethodBodies())
    EndIf
  EndIf

  ; Pointer or memory address
  If Left(a, 1) = "@" Or Left(a, 1) = "*" Or Left(a, 8) = "#Null"
    ProcedureReturn "p"
  EndIf
  
  ; String variable or string function call
  If Right(a, 1) = "$" Or Right(a, 2) = ".s" Or Right(a, 2) = ".S"
    ProcedureReturn "s"
  EndIf
  Protected aUp.s = UCase(a)
  If Left(aUp, 4) = "STR(" Or Left(aUp, 5) = "STRF(" Or Left(aUp, 5) = "STRD(" Or Left(aUp, 5) = "LEFT(" Or Left(aUp, 6) = "RIGHT(" Or Left(aUp, 4) = "MID(" Or Left(aUp, 6) = "UCASE(" Or Left(aUp, 6) = "LCASE(" Or Left(aUp, 5) = "TRIM(" Or Left(aUp, 4) = "CHR("
    ProcedureReturn "s"
  EndIf
  
  ; Float / Double literal with decimal dot
  If FindString(a, ".") > 0
    Protected isNum.b = #True
    Protected i.i, lenA.i = Len(a)
    For i = 1 To lenA
      Protected c.s = Mid(a, i, 1)
      If Not ((Asc(c) >= 48 And Asc(c) <= 57) Or c = "." Or c = "-" Or c = "+")
        isNum = #False
        Break
      EndIf
    Next
    If isNum
      ProcedureReturn "d"
    EndIf
  EndIf
  
  ; Double / Float explicit suffix
  If Right(a, 2) = ".d" Or Right(a, 2) = ".D"
    ProcedureReturn "d"
  ElseIf Right(a, 2) = ".f" Or Right(a, 2) = ".F"
    ProcedureReturn "f"
  ElseIf Right(a, 2) = ".q" Or Right(a, 2) = ".Q"
    ProcedureReturn "q"
  EndIf
  
  ; Default integer
  ProcedureReturn "i"
EndProcedure

; Computes the argument signature of an argument list in a call
Procedure.s GetCallArgSignature(argList.s, *outArgCount.Integer = 0)
  Protected NewList tokens.s()
  Protected count.i = SplitParams(argList, tokens())
  If *outArgCount
    *outArgCount\i = count
  EndIf
  If count = 0
    ProcedureReturn "void"
  EndIf
  Protected sig.s = ""
  ForEach tokens()
    Protected aType.s = InferArgType(tokens())
    If sig = ""
      sig = aType
    Else
      sig + "_" + aType
    EndIf
  Next
  ProcedureReturn sig
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

Procedure.s MangleIdentifier(id.s)
  Protected clean.s = id
  While Left(clean, 2) = "::"
    clean = Mid(clean, 3)
  Wend
  ProcedureReturn ReplaceString(clean, "::", "_")
EndProcedure

Procedure.s GetCurrentNamespace()
  Protected ns.s = ""
  ForEach NamespaceStack()
    If ns = ""
      ns = NamespaceStack()
    Else
      ns + "::" + NamespaceStack()
    EndIf
  Next
  ProcedureReturn ns
EndProcedure

Procedure.s ResolveClassName(ident.s, currentNS.s)
  Protected raw.s = Trim(ident)
  If raw = "" : ProcedureReturn "" : EndIf
  
  Protected result.s = raw
  PushListPosition(Classes())
  
  ; 1. Root qualifier "::ClassName"
  If Left(raw, 2) = "::"
    Protected rootName.s = Mid(raw, 3)
    ForEach Classes()
      If UCase(Classes()\fullName) = UCase(rootName) Or (Classes()\namespace = "" And UCase(Classes()\name) = UCase(rootName))
        result = Classes()\fullName
        Break
      EndIf
    Next
    PopListPosition(Classes())
    ProcedureReturn result
  EndIf
  
  ; 2. Check Alias prefix (e.g. GFX::Renderer where GFX = Game::Graphics)
  Protected pColon.i = FindString(raw, "::")
  If pColon > 0
    Protected aliasKey.s = Left(raw, pColon - 1)
    Protected aliasRest.s = Mid(raw, pColon + 2)
    If FindMapElement(NamespaceAliases(), UCase(aliasKey))
      Protected unaliased.s = NamespaceAliases() + "::" + aliasRest
      ForEach Classes()
        If UCase(Classes()\fullName) = UCase(unaliased)
          result = Classes()\fullName
          Break
        EndIf
      Next
      If result = raw
        result = unaliased
      EndIf
      PopListPosition(Classes())
      ProcedureReturn result
    EndIf
  EndIf
  
  ; 3. Check exact match on fullName
  ForEach Classes()
    If UCase(Classes()\fullName) = UCase(raw)
      result = Classes()\fullName
      PopListPosition(Classes())
      ProcedureReturn result
    EndIf
  Next

  ; 4. Check relative to current namespace
  If currentNS <> ""
    Protected testNS.s = currentNS
    While testNS <> ""
      Protected testFull.s = testNS + "::" + raw
      ForEach Classes()
        If UCase(Classes()\fullName) = UCase(testFull)
          result = Classes()\fullName
          Break 2
        EndIf
      Next
      Protected pLastColon.i = 0
      Protected k.i
      For k = Len(testNS) - 1 To 1 Step -1
        If Mid(testNS, k, 2) = "::"
          pLastColon = k
          Break
        EndIf
      Next
      If pLastColon > 0
        testNS = Left(testNS, pLastColon - 1)
      Else
        testNS = ""
      EndIf
    Wend
    If result <> raw
      PopListPosition(Classes())
      ProcedureReturn result
    EndIf
  EndIf

  ; 5. Check in UsingList namespaces
  Protected NewList matches.s()
  ForEach UsingList()
    Protected usingFull.s = UsingList() + "::" + raw
    ForEach Classes()
      If UCase(Classes()\fullName) = UCase(usingFull)
        AddElement(matches())
        matches() = Classes()\fullName
      EndIf
    Next
  Next
  
  If ListSize(matches()) = 1
    FirstElement(matches())
    result = matches()
    PopListPosition(Classes())
    ProcedureReturn result
  ElseIf ListSize(matches()) > 1
    FirstElement(matches())
    Protected m1.s = matches()
    NextElement(matches())
    Protected m2.s = matches()
    SetOOPError(LastErrorLine, "Ambiguous class reference '" + raw + "': matches both '" + m1 + "' and '" + m2 + "'")
    PopListPosition(Classes())
    ProcedureReturn ""
  EndIf

  ; 5b. Support UI::MVVM:: legacy alias
  If Left(UCase(raw), 10) = "UI::MVVM::"
    Protected strippedMvvm.s = Mid(raw, 5) ; "MVVM::..."
    ForEach Classes()
      If UCase(Classes()\fullName) = UCase(strippedMvvm)
        result = Classes()\fullName
        PopListPosition(Classes())
        ProcedureReturn result
      EndIf
    Next
  EndIf

  ; 6. Check root/global namespace
  ForEach Classes()
    If Classes()\namespace = "" And UCase(Classes()\name) = UCase(raw)
      result = Classes()\fullName
      Break
    EndIf
  Next

  PopListPosition(Classes())
  ProcedureReturn result
EndProcedure

; ----------------------------------------------------------------------------
; Multi-file Recursive Loader
; ----------------------------------------------------------------------------

Global BaseDirectory.s = ""

Procedure.s CanonicalizePath(path.s)
  path = ReplaceString(path, "/", "\")
  CompilerIf #PB_Compiler_OS = #PB_OS_Windows
    Protected buf.s = Space(2048)
    If GetFullPathName_(@path, 2048, @buf, 0)
      ProcedureReturn buf
    EndIf
  CompilerEndIf
  While FindString(path, "\.\") > 0
    path = ReplaceString(path, "\.\", "\")
  Wend
  While FindString(path, "\..\") > 0
    Protected pDotDot.i = FindString(path, "\..\")
    If pDotDot > 0
      Protected pPrevSlash.i = 0
      Protected i.i
      For i = pDotDot - 1 To 1 Step -1
        If Mid(path, i, 1) = "\"
          pPrevSlash = i
          Break
        EndIf
      Next
      If pPrevSlash > 0
        path = Left(path, pPrevSlash) + Mid(path, pDotDot + 4)
      Else
        Break
      EndIf
    EndIf
  Wend
  ProcedureReturn path
EndProcedure

Procedure.b LoadSourceLinesRecursive(filePath.s)
  filePath = CanonicalizePath(filePath)
  Protected normPath.s = GetPathPart(filePath)
  If normPath = ""
    filePath = GetCurrentDirectory() + filePath
    filePath = CanonicalizePath(filePath)
  EndIf

  Protected file = ReadFile(#PB_Any, filePath)
  If Not file And BaseDirectory <> ""
    Protected altPath.s = CanonicalizePath(BaseDirectory + GetFilePart(filePath))
    file = ReadFile(#PB_Any, altPath)
    If file
      filePath = altPath
    Else
      altPath = CanonicalizePath(BaseDirectory + filePath)
      file = ReadFile(#PB_Any, altPath)
      If file
        filePath = altPath
      EndIf
    EndIf
  EndIf
  If Not file
    Protected curAlt.s = CanonicalizePath(GetCurrentDirectory() + filePath)
    file = ReadFile(#PB_Any, curAlt)
    If file
      filePath = curAlt
    EndIf
  EndIf

  If Not file
    SetOOPError(1, "Cannot open source file: " + filePath)
    ProcedureReturn #False
  EndIf

  Protected fileFormat.i = ReadStringFormat(file)
  If fileFormat = #PB_Ascii
    fileFormat = #PB_UTF8
  EndIf

  Protected isFirstLine.b = #True
  Protected lineNum.i = 0
  Protected dir.s = GetPathPart(filePath)

  While Not Eof(file)
    lineNum + 1
    Protected rawLine.s = ReadString(file, fileFormat)
    If isFirstLine
      While rawLine <> "" And (Asc(Left(rawLine, 1)) = 65279 Or Asc(Left(rawLine, 1)) = 239 Or Asc(Left(rawLine, 1)) = 187 Or Asc(Left(rawLine, 1)) = 191 Or Asc(Left(rawLine, 1)) = 0)
        rawLine = Mid(rawLine, 2)
      Wend
      isFirstLine = #False
    EndIf

    Protected trimmed.s = Trim(rawLine)
    Protected upper.s = UCase(trimmed)

    ; Check IncludeFile or XIncludeFile
    If Left(upper, 12) = "INCLUDEFILE " Or Left(upper, 13) = "XINCLUDEFILE "
      Protected isXInclude.b = #False
      If Left(upper, 13) = "XINCLUDEFILE " : isXInclude = #True : EndIf

      Protected pQuote1.i = FindString(trimmed, Chr(34))
      Protected pQuote2.i = 0
      If pQuote1 > 0
        pQuote2 = FindString(trimmed, Chr(34), pQuote1 + 1)
      EndIf

      If pQuote1 > 0 And pQuote2 > pQuote1
        Protected incPath.s = Mid(trimmed, pQuote1 + 1, pQuote2 - pQuote1 - 1)
        incPath = ReplaceString(incPath, "/", "\")
        Protected isAbs.b = #False
        If Mid(incPath, 2, 1) = ":" Or Left(incPath, 2) = "\\"
          isAbs = #True
        EndIf
        
        Protected finalIncPath.s = incPath
        If Not isAbs
          If FindString(LCase(dir), "temp\") = 0
            finalIncPath = dir + incPath
          Else
            finalIncPath = ""
          EndIf
          
          If finalIncPath = "" Or FileSize(finalIncPath) <= 0
            If BaseDirectory <> "" And FileSize(CanonicalizePath(BaseDirectory + incPath)) > 0
              finalIncPath = CanonicalizePath(BaseDirectory + incPath)
            ElseIf FileSize(CanonicalizePath(GetCurrentDirectory() + incPath)) > 0
              finalIncPath = CanonicalizePath(GetCurrentDirectory() + incPath)
            ElseIf dir <> "" And FileSize(CanonicalizePath(dir + incPath)) > 0
              finalIncPath = CanonicalizePath(dir + incPath)
            Else
              ; Fallback: search in subdirectories (e.g. examples/**/incPath)
              Protected examDir = ExamineDirectory(#PB_Any, GetCurrentDirectory() + "examples\", "*.*")
              If examDir
                While NextDirectoryEntry(examDir)
                  If DirectoryEntryType(examDir) = #PB_DirectoryEntry_Directory
                    Protected subDirName.s = DirectoryEntryName(examDir)
                    If subDirName <> "." And subDirName <> ".."
                      Protected cand.s = CanonicalizePath(GetCurrentDirectory() + "examples\" + subDirName + "\" + incPath)
                      If FileSize(cand) > 0
                        finalIncPath = cand
                        Break
                      EndIf
                    EndIf
                  EndIf
                Wend
                FinishDirectory(examDir)
              EndIf
              If finalIncPath = "" Or FileSize(finalIncPath) <= 0
                finalIncPath = dir + incPath
              EndIf
            EndIf
          EndIf
        EndIf
        finalIncPath = CanonicalizePath(finalIncPath)

        If isXInclude And FindMapElement(IncludedFilesMap(), UCase(finalIncPath))
          Continue
        EndIf

        IncludedFilesMap(UCase(finalIncPath)) = 1
        If Not LoadSourceLinesRecursive(finalIncPath)
          CloseFile(file)
          ProcedureReturn #False
        EndIf
        Continue
      EndIf
    EndIf

    AddElement(FileSourceLines())
    FileSourceLines()\content = rawLine
    FileSourceLines()\srcLineNumber = lineNum
    FileSourceLines()\srcFile = filePath
  Wend

  CloseFile(file)
  ProcedureReturn #True
EndProcedure

; ----------------------------------------------------------------------------
; C-Style Braces Preprocessor
; ----------------------------------------------------------------------------

Enumeration
  #CBLOCK_NAMESPACE
  #CBLOCK_CLASS
  #CBLOCK_METHOD
  #CBLOCK_PROCEDURE
  #CBLOCK_IF
  #CBLOCK_ELSEIF
  #CBLOCK_ELSE
  #CBLOCK_WHILE
  #CBLOCK_FOR
  #CBLOCK_FOREACH
  #CBLOCK_REPEAT
  #CBLOCK_SELECT
  #CBLOCK_STRUCTURE
  #CBLOCK_ENUMERATION
  #CBLOCK_INTERFACE
  #CBLOCK_MODULE
  #CBLOCK_DECLAREMODULE
  #CBLOCK_WITH
  #CBLOCK_COMPILERIF
EndEnumeration

Structure CBlockEntry
  type.i
  openLine.i
  openFile.s
EndStructure

Global NewList CBlockStack.CBlockEntry()

Procedure.i DetectBlockOpener(code.s)
  Protected up.s = UCase(Trim(code))
  If Left(up, 10) = "NAMESPACE "
    ProcedureReturn #CBLOCK_NAMESPACE
  ElseIf Left(up, 6) = "CLASS " Or Left(up, 15) = "ABSTRACT CLASS "
    ProcedureReturn #CBLOCK_CLASS
  ElseIf Left(up, 7) = "METHOD " Or Left(up, 7) = "METHOD." Or Left(up, 14) = "PUBLIC METHOD " Or Left(up, 14) = "PUBLIC METHOD." Or Left(up, 17) = "PROTECTED METHOD " Or Left(up, 17) = "PROTECTED METHOD." Or Left(up, 15) = "PRIVATE METHOD " Or Left(up, 15) = "PRIVATE METHOD." Or Left(up, 16) = "OVERRIDE METHOD " Or Left(up, 16) = "OVERRIDE METHOD."
    ProcedureReturn #CBLOCK_METHOD
  ElseIf Left(up, 9) = "PROCEDURE" Or Left(up, 18) = "RUNTIME PROCEDURE "
    ProcedureReturn #CBLOCK_PROCEDURE
  ElseIf Left(up, 3) = "IF " Or Left(up, 3) = "IF(" Or up = "IF"
    ProcedureReturn #CBLOCK_IF
  ElseIf Left(up, 7) = "ELSEIF " Or Left(up, 7) = "ELSEIF(" Or up = "ELSEIF"
    ProcedureReturn #CBLOCK_ELSEIF
  ElseIf up = "ELSE" Or Left(up, 5) = "ELSE "
    ProcedureReturn #CBLOCK_ELSE
  ElseIf Left(up, 6) = "WHILE " Or Left(up, 6) = "WHILE(" Or up = "WHILE"
    ProcedureReturn #CBLOCK_WHILE
  ElseIf Left(up, 4) = "FOR "
    ProcedureReturn #CBLOCK_FOR
  ElseIf Left(up, 8) = "FOREACH "
    ProcedureReturn #CBLOCK_FOREACH
  ElseIf up = "REPEAT" Or Left(up, 7) = "REPEAT "
    ProcedureReturn #CBLOCK_REPEAT
  ElseIf Left(up, 7) = "SELECT "
    ProcedureReturn #CBLOCK_SELECT
  ElseIf Left(up, 10) = "STRUCTURE "
    ProcedureReturn #CBLOCK_STRUCTURE
  ElseIf up = "ENUMERATION" Or Left(up, 12) = "ENUMERATION "
    ProcedureReturn #CBLOCK_ENUMERATION
  ElseIf Left(up, 10) = "INTERFACE "
    ProcedureReturn #CBLOCK_INTERFACE
  ElseIf Left(up, 7) = "MODULE "
    ProcedureReturn #CBLOCK_MODULE
  ElseIf Left(up, 14) = "DECLAREMODULE "
    ProcedureReturn #CBLOCK_DECLAREMODULE
  ElseIf Left(up, 5) = "WITH "
    ProcedureReturn #CBLOCK_WITH
  ElseIf Left(up, 11) = "COMPILERIF " Or Left(up, 11) = "COMPILERIF("
    ProcedureReturn #CBLOCK_COMPILERIF
  EndIf
  ProcedureReturn -1
EndProcedure

Procedure.b PreprocessCurlyBraces()
  ClearList(CBlockStack())
  Protected pendingOpener.i = -1
  Protected pendingLine.i = 0
  Protected pendingFile.s = ""

  ForEach FileSourceLines()
    Protected raw.s = FileSourceLines()\content
    Protected lineNum.i = FileSourceLines()\srcLineNumber
    Protected srcFile.s = FileSourceLines()\srcFile

    Protected i.i, inStr.b = #False
    Protected codeEnd.i = Len(raw)
    Protected lenRaw.i = Len(raw)
    
    For i = 1 To lenRaw
      Protected ch.s = Mid(raw, i, 1)
      If ch = Chr(34)
        inStr = ~inStr & 1
      ElseIf ch = ";" And Not inStr
        codeEnd = i - 1
        Break
      EndIf
    Next

    Protected codePart.s = Left(raw, codeEnd)
    Protected commentPart.s = Mid(raw, codeEnd + 1)
    Protected trimmedCode.s = Trim(codePart)

    If trimmedCode = ""
      Continue
    EndIf

    ; Standalone opening brace on its own line: "{"
    If trimmedCode = "{"
      If pendingOpener >= 0
        AddElement(CBlockStack())
        CBlockStack()\type = pendingOpener
        CBlockStack()\openLine = pendingLine
        CBlockStack()\openFile = pendingFile
        pendingOpener = -1
        FileSourceLines()\content = commentPart
        Continue
      Else
        SetOOPError(lineNum, "Unexpected '{' without preceding block statement")
        ProcedureReturn #False
      EndIf
    EndIf

    If pendingOpener >= 0
      pendingOpener = -1
    EndIf

    ; Closing brace variations
    If Left(trimmedCode, 1) = "}"
      If ListSize(CBlockStack()) = 0
        SetOOPError(lineNum, "Unexpected '}' without matching opening block")
        ProcedureReturn #False
      EndIf

      LastElement(CBlockStack())
      Protected topType.i = CBlockStack()\type
      DeleteElement(CBlockStack())

      Protected restOfCode.s = Trim(Mid(trimmedCode, 2))
      Protected restUpper.s = UCase(restOfCode)

      If Left(restUpper, 4) = "ELSE"
        If Left(restUpper, 6) = "ELSEIF"
          Protected hasOpenBrace.b = #False
          If Right(restOfCode, 1) = "{"
            hasOpenBrace = #True
            restOfCode = Trim(Left(restOfCode, Len(restOfCode) - 1))
          EndIf
          If hasOpenBrace
            AddElement(CBlockStack())
            CBlockStack()\type = #CBLOCK_ELSEIF
            CBlockStack()\openLine = lineNum
            CBlockStack()\openFile = srcFile
          EndIf
          FileSourceLines()\content = restOfCode + commentPart
          Continue
        Else
          Protected hasOpenBrace2.b = #False
          If Right(restOfCode, 1) = "{"
            hasOpenBrace2 = #True
            restOfCode = Trim(Left(restOfCode, Len(restOfCode) - 1))
          EndIf
          If hasOpenBrace2
            AddElement(CBlockStack())
            CBlockStack()\type = #CBLOCK_ELSE
            CBlockStack()\openLine = lineNum
            CBlockStack()\openFile = srcFile
          EndIf
          If restOfCode = "" : restOfCode = "Else" : EndIf
          FileSourceLines()\content = restOfCode + commentPart
          Continue
        EndIf
      ElseIf Left(restUpper, 5) = "UNTIL"
        FileSourceLines()\content = restOfCode + commentPart
        Continue
      Else
        Protected endKeyword.s = ""
        Select topType
          Case #CBLOCK_NAMESPACE:     endKeyword = "EndNamespace"
          Case #CBLOCK_CLASS:         endKeyword = "EndClass"
          Case #CBLOCK_METHOD:        endKeyword = "EndMethod"
          Case #CBLOCK_PROCEDURE:     endKeyword = "EndProcedure"
          Case #CBLOCK_IF, #CBLOCK_ELSE, #CBLOCK_ELSEIF: endKeyword = "EndIf"
          Case #CBLOCK_WHILE:         endKeyword = "Wend"
          Case #CBLOCK_FOR, #CBLOCK_FOREACH: endKeyword = "Next"
          Case #CBLOCK_REPEAT:        endKeyword = "Until #True"
          Case #CBLOCK_SELECT:        endKeyword = "EndSelect"
          Case #CBLOCK_STRUCTURE:     endKeyword = "EndStructure"
          Case #CBLOCK_ENUMERATION:   endKeyword = "EndEnumeration"
          Case #CBLOCK_INTERFACE:     endKeyword = "EndInterface"
          Case #CBLOCK_MODULE:        endKeyword = "EndModule"
          Case #CBLOCK_DECLAREMODULE: endKeyword = "EndDeclareModule"
          Case #CBLOCK_WITH:          endKeyword = "EndWith"
          Case #CBLOCK_COMPILERIF:    endKeyword = "CompilerEndIf"
        EndSelect

        FileSourceLines()\content = endKeyword + commentPart
        Continue
      EndIf
    EndIf

    ; Opening line with trailing "{"
    If Right(trimmedCode, 1) = "{"
      Protected strippedCode.s = Trim(Left(trimmedCode, Len(trimmedCode) - 1))
      Protected openerType.i = DetectBlockOpener(strippedCode)
      If openerType >= 0
        AddElement(CBlockStack())
        CBlockStack()\type = openerType
        CBlockStack()\openLine = lineNum
        CBlockStack()\openFile = srcFile

        FileSourceLines()\content = strippedCode + commentPart
        Continue
      EndIf
    Else
      Protected possibleOpener.i = DetectBlockOpener(trimmedCode)
      If possibleOpener >= 0
        pendingOpener = possibleOpener
        pendingLine = lineNum
        pendingFile = srcFile
      EndIf
    EndIf

  Next

  If ListSize(CBlockStack()) > 0
    LastElement(CBlockStack())
    SetOOPError(CBlockStack()\openLine, "Missing closing brace '}' for block opened at line " + Str(CBlockStack()\openLine))
    ProcedureReturn #False
  EndIf

  ProcedureReturn #True
EndProcedure

Procedure.b ParseRelationDirective(workLine.s, *currentClass.OOP_Class, currentLineNum.i, currentFile.s)
  Protected up.s = UCase(workLine)
  Protected relType.i = 0
  Protected rest.s = ""
  
  If Left(up, 8) = "HASMANY "
    relType = #ORM_Rel_OneToMany
    rest = Trim(Mid(workLine, 9))
  ElseIf Left(up, 10) = "BELONGSTO "
    relType = #ORM_Rel_ManyToOne
    rest = Trim(Mid(workLine, 11))
  ElseIf Left(up, 11) = "MANYTOMANY "
    relType = #ORM_Rel_ManyToMany
    rest = Trim(Mid(workLine, 12))
  ElseIf Left(up, 7) = "HASONE "
    relType = #ORM_Rel_OneToOne
    rest = Trim(Mid(workLine, 8))
  Else
    ProcedureReturn #False
  EndIf
  
  Protected parenOpen.i = FindString(rest, "(")
  Protected parenClose.i = FindString(rest, ")", parenOpen + 1)
  Protected targetPart.s = ""
  Protected paramsPart.s = ""
  
  If parenOpen > 0 And parenClose > parenOpen
    targetPart = Trim(Left(rest, parenOpen - 1))
    paramsPart = Mid(rest, parenOpen + 1, parenClose - parenOpen - 1)
  Else
    targetPart = Trim(rest)
  EndIf
  
  Protected dotPos.i = FindString(targetPart, ".")
  If dotPos = 0
    SetOOPError(currentLineNum, "Relation declaration must specify property and target type (e.g. HasMany telephones.Telephone)", currentFile)
    ProcedureReturn #False
  EndIf
  
  Protected propName.s   = Trim(Left(targetPart, dotPos - 1))
  Protected targetClass.s = Trim(Mid(targetPart, dotPos + 1))
  
  ; Default parameters
  Protected fk.s        = LCase(*currentClass\name) + "_id"
  Protected joinTbl.s   = ""
  Protected parentFk.s  = LCase(*currentClass\name) + "_id"
  Protected childFk.s   = LCase(targetClass) + "_id"
  Protected cascade.i   = #Cascade_All
  
  If relType = #ORM_Rel_ManyToOne
    fk = LCase(propName) + "_id"
  ElseIf relType = #ORM_Rel_ManyToMany
    joinTbl = LCase(*currentClass\name) + "_" + LCase(targetClass) + "s"
  EndIf
  
  If paramsPart <> ""
    Protected numPairs.i = CountString(paramsPart, ",") + 1
    Protected pIdx.i
    For pIdx = 1 To numPairs
      Protected pair.s = Trim(StringField(paramsPart, pIdx, ","))
      Protected eqPos.i = FindString(pair, "=")
      If eqPos > 0
        Protected k.s = Trim(UCase(Left(pair, eqPos - 1)))
        Protected v.s = Trim(Mid(pair, eqPos + 1))
        If Left(v, 1) = Chr(34) And Right(v, 1) = Chr(34)
          v = Mid(v, 2, Len(v) - 2)
        EndIf
        
        Select k
          Case "FOREIGNKEY", "FK"
            fk = v
          Case "JOINTABLE"
            joinTbl = v
          Case "PARENTFOREIGNKEY", "PARENTFK"
            parentFk = v
          Case "CHILDFOREIGNKEY", "CHILDFK"
            childFk = v
          Case "CASCADE"
            Protected upV.s = UCase(v)
            If FindString(upV, "ALL") > 0 Or upV = "3"
              cascade = #Cascade_All
            ElseIf FindString(upV, "DELETE") > 0 Or upV = "2"
              cascade = #Cascade_Delete
            ElseIf FindString(upV, "SAVE") > 0 Or upV = "1"
              cascade = #Cascade_Save
            Else
              cascade = #Cascade_None
            EndIf
        EndSelect
      EndIf
    Next
  EndIf
  
  AddElement(*currentClass\Relations())
  *currentClass\Relations()\relationType = relType
  *currentClass\Relations()\propertyName = propName
  *currentClass\Relations()\targetClass = targetClass
  *currentClass\Relations()\foreignKey = fk
  *currentClass\Relations()\joinTable = joinTbl
  *currentClass\Relations()\parentFk = parentFk
  *currentClass\Relations()\childFk = childFk
  *currentClass\Relations()\cascade = cascade
  *currentClass\Relations()\srcLineNumber = currentLineNum
  *currentClass\Relations()\srcFile = currentFile
  
  *currentClass\isDatabaseEntity = #True
  
  AddElement(*currentClass\Fields())
  If relType = #ORM_Rel_OneToMany Or relType = #ORM_Rel_ManyToMany
    *currentClass\Fields()\name = propName + ".EntitySet::IEntitySet"
  ElseIf relType = #ORM_Rel_ManyToOne
    *currentClass\Fields()\name = propName + "." + targetClass
    Protected hasFkField.b = #False
    PushListPosition(*currentClass\Fields())
    ForEach *currentClass\Fields()
      If LCase(StringField(*currentClass\Fields()\name, 1, ".")) = LCase(fk)
        hasFkField = #True
        Break
      EndIf
    Next
    PopListPosition(*currentClass\Fields())
    If Not hasFkField
      AddElement(*currentClass\Fields())
      *currentClass\Fields()\name = fk + ".i"
      *currentClass\Fields()\visibility = "Public"
      *currentClass\Fields()\srcLineNumber = currentLineNum
      *currentClass\Fields()\srcFile = currentFile
    EndIf
  Else ; OneToOne
    *currentClass\Fields()\name = propName + "." + targetClass
  EndIf
  *currentClass\Fields()\visibility = "Public"
  *currentClass\Fields()\srcLineNumber = currentLineNum
  *currentClass\Fields()\srcFile = currentFile
  
  ProcedureReturn #True
EndProcedure

; ----------------------------------------------------------------------------
; Parser Phase (.pbo -> AST / OOP Meta-Model)
; ----------------------------------------------------------------------------

Procedure.b ParsePBO(inputFile.s)
  LastErrorFile = inputFile
  LastErrorLine = 0
  LastErrorMessage = ""

  ClearList(FileSourceLines())
  ClearMap(IncludedFilesMap())
  ClearList(NamespaceStack())
  ClearList(UsingList())
  ClearMap(NamespaceAliases())

  IncludedFilesMap(UCase(CanonicalizePath(inputFile))) = 1
  If Not LoadSourceLinesRecursive(inputFile)
    ProcedureReturn #False
  EndIf

  ; Auto-detect Framework usage (UI::, MVVM::, Using UI, Using MVVM, etc.)
  Protected needsFramework.b = #False
  ForEach FileSourceLines()
    Protected chkUp.s = UCase(FileSourceLines()\content)
    If FindString(chkUp, "UI::") > 0 Or FindString(chkUp, "MVVM::") > 0 Or FindString(chkUp, "USING UI") > 0 Or FindString(chkUp, "USING MVVM") > 0 Or FindString(chkUp, "VIEWMODELBASE") > 0 Or FindString(chkUp, "OBSERVABLEOBJECT") > 0 Or FindString(chkUp, "STRINGPROPERTY") > 0 Or FindString(chkUp, "INTPROPERTY") > 0 Or FindString(chkUp, "<WINDOW") > 0 Or FindString(chkUp, "<STACKPANEL") > 0 Or FindString(chkUp, "<DOCKPANEL") > 0 Or FindString(chkUp, "<GRID") > 0
      needsFramework = #True
      Break
    EndIf
  Next

  If needsFramework
    Protected frameworkUIPath.s = CanonicalizePath(GetPathPart(ProgramFilename()) + "..\framework\UI.pbi")
    If FileSize(frameworkUIPath) <= 0
      frameworkUIPath = CanonicalizePath(GetCurrentDirectory() + "framework\UI.pbi")
    EndIf
    If FileSize(frameworkUIPath) <= 0 And BaseDirectory <> ""
      frameworkUIPath = CanonicalizePath(BaseDirectory + "..\framework\UI.pbi")
    EndIf
    If FileSize(frameworkUIPath) <= 0 And BaseDirectory <> ""
      frameworkUIPath = CanonicalizePath(BaseDirectory + "framework\UI.pbi")
    EndIf

    If FileSize(frameworkUIPath) > 0 And Not FindMapElement(IncludedFilesMap(), UCase(frameworkUIPath))
      ; Save user lines
      NewList UserSourceLines.OOP_SourceLine()
      CopyList(FileSourceLines(), UserSourceLines())
      ClearList(FileSourceLines())
      
      ; Load Framework first
      IncludedFilesMap(UCase(frameworkUIPath)) = 1
      If LoadSourceLinesRecursive(frameworkUIPath)
        ; Append User lines after framework
        ForEach UserSourceLines()
          AddElement(FileSourceLines())
          FileSourceLines()\content = UserSourceLines()\content
          FileSourceLines()\srcLineNumber = UserSourceLines()\srcLineNumber
          FileSourceLines()\srcFile = UserSourceLines()\srcFile
        Next
      Else
        ; Fallback: restore user lines
        CopyList(UserSourceLines(), FileSourceLines())
      EndIf
      ClearList(UserSourceLines())
    EndIf
  EndIf

  If Not PreprocessCurlyBraces()
    ProcedureReturn #False
  EndIf

  ClearList(Classes())
  ClearMap(ClassMap())
  ClearList(MethodBodies())
  ClearList(MainLines())
  ClearList(HeaderDeclarations())
  ClearMap(OverloadedMethodNames())

  Protected inClass.b = #False
  Protected inMethod.b = #False
  Protected inClassMethod.b = #False
  Protected inTopEnum.b = #False
  Protected inTopStruct.b = #False
  Protected inTopMacro.b = #False
  Protected *currentClass.OOP_Class = #Null
  Protected *currentMethod.OOP_MethodBody = #Null
  Protected rawLine.s, line.s, upper.s
  Protected p1.i, p2.i, p3.i, pEnd.i
  Protected currentLineNum.i = 0
  Protected currentFile.s = ""
  Protected classStartLine.i = 0
  Protected methodStartLine.i = 0

  ForEach FileSourceLines()
    currentLineNum = FileSourceLines()\srcLineNumber
    currentFile = FileSourceLines()\srcFile
    rawLine = FileSourceLines()\content
    line = StripComment(rawLine)
    upper = UCase(line)

    ; 0. Top-Level Namespace, EndNamespace, Using, and Aliases
    If Not inClass And Not inMethod And Not inClassMethod
      If Left(upper, 10) = "NAMESPACE "
        Protected nsArg.s = Trim(Mid(line, 11))
        Protected pEq.i = FindString(nsArg, "=")
        If pEq > 0
          Protected aliasName.s = Trim(Left(nsArg, pEq - 1))
          Protected targetNs.s = Trim(Mid(nsArg, pEq + 1))
          NamespaceAliases(UCase(aliasName)) = targetNs
          Continue
        Else
          AddElement(NamespaceStack())
          NamespaceStack() = nsArg
          Continue
        EndIf

      ElseIf upper = "ENDNAMESPACE"
        If ListSize(NamespaceStack()) > 0
          LastElement(NamespaceStack())
          DeleteElement(NamespaceStack())
        Else
          SetOOPError(currentLineNum, "Unexpected 'EndNamespace' without matching 'Namespace'")
          ProcedureReturn #False
        EndIf
        Continue

      ElseIf Left(upper, 6) = "USING "
        Protected usingNs.s = Trim(Mid(line, 7))
        AddElement(UsingList())
        UsingList() = usingNs
        Continue
      EndIf
    EndIf

    ; 1. Parsing inside an Inline Method Body
    If inClassMethod
      If Left(upper, 9) = "ENDMETHOD"
        inClassMethod = #False
        *currentMethod = #Null
        Continue
      Else
        AddElement(*currentMethod\BodyLines())
        *currentMethod\BodyLines()\content = rawLine
        *currentMethod\BodyLines()\srcLineNumber = currentLineNum
        *currentMethod\BodyLines()\srcFile = currentFile
        Continue
      EndIf

    ; 2. Parsing inside a Class Definition
    ElseIf inClass
      If Left(upper, 8) = "ENDCLASS"
        If *currentClass\isDatabaseEntity
          Protected hasId.b = #False
          Protected hasDirty.b = #False
          Protected hasNew.b = #False
          ForEach *currentClass\Fields()
            Protected fBase.s = LCase(Trim(StringField(*currentClass\Fields()\name, 1, ".")))
            If fBase = "id" : hasId = #True : EndIf
            If fBase = "orm_isdirty" : hasDirty = #True : EndIf
            If fBase = "orm_isnew" : hasNew = #True : EndIf
          Next
          If Not hasId
            ResetList(*currentClass\Fields())
            InsertElement(*currentClass\Fields())
            *currentClass\Fields()\name = "id.i"
            *currentClass\Fields()\visibility = "Public"
            *currentClass\Fields()\srcLineNumber = currentLineNum
            *currentClass\Fields()\srcFile = currentFile
          EndIf
          If Not hasDirty
            AddElement(*currentClass\Fields())
            *currentClass\Fields()\name = "orm_isDirty.b"
            *currentClass\Fields()\visibility = "Protected"
            *currentClass\Fields()\srcLineNumber = currentLineNum
            *currentClass\Fields()\srcFile = currentFile
          EndIf
          If Not hasNew
            AddElement(*currentClass\Fields())
            *currentClass\Fields()\name = "orm_isNew.b"
            *currentClass\Fields()\visibility = "Protected"
            *currentClass\Fields()\srcLineNumber = currentLineNum
            *currentClass\Fields()\srcFile = currentFile
          EndIf
        EndIf
        inClass = #False
        *currentClass = #Null
        Continue

      ElseIf Left(upper, 9) = "ENDMETHOD"
        SetOOPError(currentLineNum, "Unexpected 'EndMethod' inside Class without preceding Method")
        ProcedureReturn #False

      Else
        Protected vis.s = "Public"
        Protected workLine.s = line
        Protected matchedPrefix.b = #False

        If Left(upper, 7) = "PUBLIC "
          vis = "Public" : workLine = Trim(Mid(line, 8)) : matchedPrefix = #True
        ElseIf Left(upper, 10) = "PROTECTED "
          vis = "Protected" : workLine = Trim(Mid(line, 11)) : matchedPrefix = #True
        ElseIf Left(upper, 8) = "PRIVATE "
          vis = "Private" : workLine = Trim(Mid(line, 9)) : matchedPrefix = #True
        EndIf

        Protected workUpper.s = UCase(workLine)
        Protected isAbsMeth.b = #False
        If Left(workUpper, 9) = "ABSTRACT "
          isAbsMeth = #True
          workLine = Trim(Mid(workLine, 10))
          workUpper = UCase(workLine)
        EndIf

        ; Check Method declaration
        If Left(workUpper, 6) = "METHOD" And (Len(workUpper) = 6 Or Mid(workUpper, 7, 1) = " " Or Mid(workUpper, 7, 1) = ".")
          Protected mDecl.s = Trim(Mid(workLine, 7))
          Protected mRet.s = ""
          
          If Left(mDecl, 1) = "."
            p1 = FindString(mDecl, " ")
            p2 = FindString(mDecl, "(")
            pEnd = p1
            If pEnd = 0 Or (p2 > 0 And p2 < pEnd) : pEnd = p2 : EndIf
            If pEnd > 0
              mRet = Left(mDecl, pEnd - 1)
              mDecl = Trim(Mid(mDecl, pEnd))
            EndIf
          EndIf

          p1 = FindString(mDecl, "(")
          p2 = FindString(mDecl, ")")
          If p1 = 0 Or p2 = 0 Or p2 < p1
            SetOOPError(currentLineNum, "Invalid method declaration syntax: " + line)
            ProcedureReturn #False
          EndIf

          Protected mName.s = Trim(Left(mDecl, p1 - 1))
          Protected mParams.s = Trim(Mid(mDecl, p1 + 1, p2 - p1 - 1))

          Protected pDotInName.i = FindString(mName, ".")
          If pDotInName > 0
            If mRet = ""
              mRet = Mid(mName, pDotInName)
            EndIf
            mName = Left(mName, pDotInName - 1)
          EndIf

          Protected mSig.s = GetParamSignature(mParams)
          Protected mCleanParams.s = GetCleanParams(mParams)
          Protected NewList mParamsList.s()
          Protected mTotalParams.i = SplitParams(mParams, mParamsList())
          Protected mMinParams.i = CountMinParameters(mParams)
          Protected hasDef.b = #False
          If mMinParams < mTotalParams
            hasDef = #True
          EndIf

          AddElement(*currentClass\Methods())
          *currentClass\Methods()\name = mName
          *currentClass\Methods()\rawDecl = line
          *currentClass\Methods()\params = mParams
          *currentClass\Methods()\cleanParams = mCleanParams
          *currentClass\Methods()\returnType = mRet
          *currentClass\Methods()\visibility = vis
          *currentClass\Methods()\isAbstract = isAbsMeth
          *currentClass\Methods()\signature = mSig
          *currentClass\Methods()\paramCount = mTotalParams
          *currentClass\Methods()\minParamCount = mMinParams
          *currentClass\Methods()\hasDefaults = hasDef
          *currentClass\Methods()\mangledMethodName = mName ; will be updated if overloaded
          *currentClass\Methods()\srcLineNumber = currentLineNum
          *currentClass\Methods()\srcFile = currentFile

          If UCase(mName) = "INIT"
            *currentClass\hasInit = #True
            Protected alreadyInClassInit.b = #False
            ForEach *currentClass\InitConstructors()
              If *currentClass\InitConstructors()\signature = mSig
                alreadyInClassInit = #True
                Break
              EndIf
            Next
            If Not alreadyInClassInit
              AddElement(*currentClass\InitConstructors())
              *currentClass\InitConstructors()\params = mParams
              *currentClass\InitConstructors()\cleanParams = mCleanParams
              *currentClass\InitConstructors()\signature = mSig
              *currentClass\InitConstructors()\paramCount = mTotalParams
              *currentClass\InitConstructors()\minParamCount = mMinParams
              *currentClass\InitConstructors()\srcLineNumber = currentLineNum
              *currentClass\InitConstructors()\srcFile = currentFile
            EndIf
          ElseIf UCase(mName) = "FREE"
            *currentClass\hasFree = #True
            *currentClass\freeClassMangled = *currentClass\mangledName
          EndIf

          If isAbsMeth
            Continue
          EndIf

          ; Check if this is an inline method or a single-line declaration
          Protected isInline.b = #False
          PushListPosition(FileSourceLines())
          While NextElement(FileSourceLines())
            Protected nextLine.s = Trim(UCase(FileSourceLines()\content))
            If nextLine = "" Or Left(nextLine, 1) = ";"
              Continue
            ElseIf Left(nextLine, 9) = "ENDMETHOD"
              isInline = #True
              Break
            ElseIf Left(nextLine, 8) = "ENDCLASS" Or Left(nextLine, 6) = "METHOD" Or Left(nextLine, 13) = "PUBLIC METHOD" Or Left(nextLine, 16) = "PROTECTED METHOD" Or Left(nextLine, 14) = "PRIVATE METHOD"
              isInline = #False
              Break
            EndIf
          Wend
          PopListPosition(FileSourceLines())

          If isInline
            AddElement(MethodBodies())
            *currentMethod = @MethodBodies()
            *currentMethod\className = *currentClass\fullName
            *currentMethod\mangledClassName = *currentClass\mangledName
            *currentMethod\methodName = mName
            *currentMethod\signature = mSig
            *currentMethod\mangledMethodName = mName
            *currentMethod\params = mParams
            *currentMethod\cleanParams = mCleanParams
            *currentMethod\returnType = mRet
            *currentMethod\srcLineNumber = currentLineNum
            *currentMethod\srcFile = currentFile
            inClassMethod = #True
            methodStartLine = currentLineNum
          EndIf
          Continue

        ElseIf matchedPrefix Or (line <> "" And Left(line, 1) <> ";")
          Protected upWorkLine.s = UCase(workLine)
          If Left(upWorkLine, 8) = "HASMANY " Or Left(upWorkLine, 10) = "BELONGSTO " Or Left(upWorkLine, 11) = "MANYTOMANY " Or Left(upWorkLine, 7) = "HASONE "
            If ParseRelationDirective(workLine, *currentClass, currentLineNum, currentFile)
              Continue
            Else
              ProcedureReturn #False
            EndIf
          EndIf

          If Not IsValidFieldDeclaration(workLine)
            SetOOPError(currentLineNum, "Syntax error or invalid declaration '" + workLine + "' in Class '" + *currentClass\fullName + "'")
            ProcedureReturn #False
          EndIf
          AddElement(*currentClass\Fields())
          *currentClass\Fields()\name = workLine
          *currentClass\Fields()\visibility = vis
          *currentClass\Fields()\srcLineNumber = currentLineNum
          *currentClass\Fields()\srcFile = currentFile
          Continue
        EndIf
      EndIf

    ; 3. Parsing inside Out-of-Class Method Implementation (Method Class::Name(params))
    ElseIf inMethod
      If Left(upper, 9) = "ENDMETHOD"
        inMethod = #False
        *currentMethod = #Null
        Continue
      Else
        AddElement(*currentMethod\BodyLines())
        *currentMethod\BodyLines()\content = rawLine
        *currentMethod\BodyLines()\srcLineNumber = currentLineNum
        *currentMethod\BodyLines()\srcFile = currentFile
        Continue
      EndIf

    ; 4. Top-Level Code: Class Declaration, Out-of-Class Method, or Regular PB Code
    Else
      If Left(upper, 6) = "CLASS " Or Left(upper, 15) = "ABSTRACT CLASS "
        Protected isAbsClass.b = #False
        Protected classDecl.s = Trim(Mid(line, 7))
        If Left(upper, 15) = "ABSTRACT CLASS "
          isAbsClass = #True
          classDecl = Trim(Mid(line, 16))
        EndIf

        Protected cName.s = ""
        Protected pName.s = ""
        Protected ifacesPart.s = ""
        
        Protected pImp.i = FindString(UCase(classDecl), " IMPLEMENTS ")
        If pImp = 0
          pImp = FindString(UCase(classDecl), " IMPLEMENT ")
        EndIf
        
        If pImp > 0
          Protected impKeywordLen.i = 11
          If Mid(UCase(classDecl), pImp, 12) = " IMPLEMENTS "
            impKeywordLen = 12
          EndIf
          ifacesPart = Trim(Mid(classDecl, pImp + impKeywordLen))
          classDecl = Trim(Left(classDecl, pImp - 1))
        EndIf

        p1 = FindString(UCase(classDecl), " EXTENDS ")
        If p1 > 0
          cName = Trim(Left(classDecl, p1 - 1))
          pName = Trim(Mid(classDecl, p1 + 9))
        Else
          cName = Trim(classDecl)
        EndIf

        If cName = ""
          SetOOPError(currentLineNum, "Missing class name in Class declaration")
          ProcedureReturn #False
        EndIf

        Protected currentNS.s = GetCurrentNamespace()
        Protected fullCName.s = cName
        If currentNS <> ""
          fullCName = currentNS + "::" + cName
        EndIf
        Protected mangledCName.s = MangleIdentifier(fullCName)

        If FindMapElement(ClassMap(), UCase(fullCName))
          SetOOPError(currentLineNum, "Duplicate Class '" + fullCName + "'")
          ProcedureReturn #False
        EndIf

        AddElement(Classes())
        *currentClass = @Classes()
        *currentClass\name = cName
        *currentClass\namespace = currentNS
        *currentClass\fullName = fullCName
        *currentClass\mangledName = mangledCName
        *currentClass\parentName = pName
        *currentClass\isAbstract = isAbsClass
        *currentClass\srcLineNumber = currentLineNum
        *currentClass\srcFile = currentFile
        
        If ifacesPart <> ""
          Protected numIfaces.i = CountString(ifacesPart, ",") + 1
          Protected ifIdx.i
          For ifIdx = 1 To numIfaces
            Protected ifaceName.s = Trim(StringField(ifacesPart, ifIdx, ","))
            If ifaceName <> ""
              AddElement(*currentClass\ImplementedInterfaces())
              *currentClass\ImplementedInterfaces() = ifaceName
              Protected upperIface.s = UCase(ifaceName)
              If upperIface = "IDATABASEENTITY" Or upperIface = "DATABASEENTITIES::IDATABASEENTITY" Or upperIface = "ENTITY"
                *currentClass\isDatabaseEntity = #True
              EndIf
            EndIf
          Next
        EndIf
        If UCase(pName) = "ENTITY" Or UCase(pName) = "ORM::ENTITY"
          *currentClass\isDatabaseEntity = #True
        EndIf
        
        ClassMap(UCase(fullCName)) = ListIndex(Classes())
        ClassMap(UCase(mangledCName)) = ListIndex(Classes())
        If currentNS = ""
          ClassMap(UCase(cName)) = ListIndex(Classes())
        EndIf

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
        Protected outDecl.s = Trim(Mid(line, 7))
        Protected outRet.s = ""
        
        If Left(outDecl, 1) = "."
          p1 = FindString(outDecl, " ")
          p2 = FindString(outDecl, "(")
          pEnd = p1
          If pEnd = 0 Or (p2 > 0 And p2 < pEnd) : pEnd = p2 : EndIf
          If pEnd > 0
            outRet = Left(outDecl, pEnd - 1)
            outDecl = Trim(Mid(outDecl, pEnd))
          EndIf
        EndIf

        p1 = FindString(outDecl, "(")
        p2 = FindString(outDecl, ")")
        If p1 = 0 Or p2 = 0 Or p2 < p1
          SetOOPError(currentLineNum, "Invalid out-of-class method syntax: " + line)
          ProcedureReturn #False
        EndIf

        Protected fullTargetName.s = Trim(Left(outDecl, p1 - 1))
        Protected m_params.s = Trim(Mid(outDecl, p1 + 1, p2 - p1 - 1))

        p3 = 0
        Protected scanPos.i = 1
        While #True
          Protected foundSep.i = FindString(fullTargetName, "::", scanPos)
          If foundSep > 0
            p3 = foundSep
            scanPos = foundSep + 2
          Else
            Break
          EndIf
        Wend

        If p3 = 0
          SetOOPError(currentLineNum, "Out-of-class Method must specify 'ClassName::MethodName': " + line)
          ProcedureReturn #False
        EndIf

        Protected classPart.s = Trim(Left(fullTargetName, p3 - 1))
        Protected m_name.s = Trim(Mid(fullTargetName, p3 + 2))

        Protected pDotOutName.i = FindString(m_name, ".")
        If pDotOutName > 0
          If outRet = ""
            outRet = Mid(m_name, pDotOutName)
          EndIf
          m_name = Left(m_name, pDotOutName - 1)
        EndIf

        Protected resolvedClass.s = ResolveClassName(classPart, GetCurrentNamespace())
        Protected resolvedMangled.s = MangleIdentifier(resolvedClass)

        If Not FindMapElement(ClassMap(), UCase(resolvedClass))
          SetOOPError(currentLineNum, "Method implementation for unknown class '" + classPart + "'")
          ProcedureReturn #False
        EndIf

        Protected outSig.s = GetParamSignature(m_params)
        Protected outCleanParams.s = GetCleanParams(m_params)
        Protected NewList outParamsList.s()
        Protected outTotalParams.i = SplitParams(m_params, outParamsList())
        Protected outMinParams.i = CountMinParameters(m_params)

        Protected targetClassIdx.i = ClassMap(UCase(resolvedClass))
        PushListPosition(Classes())
        SelectElement(Classes(), targetClassIdx)
        If UCase(m_name) = "INIT"
          Classes()\hasInit = #True
          Protected alreadyHasInit.b = #False
          ForEach Classes()\InitConstructors()
            If Classes()\InitConstructors()\signature = outSig
              alreadyHasInit = #True
              Break
            EndIf
          Next
          If Not alreadyHasInit
            AddElement(Classes()\InitConstructors())
            Classes()\InitConstructors()\params = m_params
            Classes()\InitConstructors()\cleanParams = outCleanParams
            Classes()\InitConstructors()\signature = outSig
            Classes()\InitConstructors()\paramCount = outTotalParams
            Classes()\InitConstructors()\minParamCount = outMinParams
            Classes()\InitConstructors()\srcLineNumber = currentLineNum
            Classes()\InitConstructors()\srcFile = currentFile
          EndIf
        ElseIf UCase(m_name) = "FREE"
          Classes()\hasFree = #True
          Classes()\freeClassMangled = Classes()\mangledName
        EndIf
        PopListPosition(Classes())

        AddElement(MethodBodies())
        *currentMethod = @MethodBodies()
        *currentMethod\className = resolvedClass
        *currentMethod\mangledClassName = resolvedMangled
        *currentMethod\methodName = m_name
        *currentMethod\signature = outSig
        *currentMethod\mangledMethodName = m_name
        *currentMethod\params = m_params
        *currentMethod\cleanParams = outCleanParams
        *currentMethod\returnType = outRet
        *currentMethod\srcLineNumber = currentLineNum
        *currentMethod\srcFile = currentFile
        inMethod = #True
        methodStartLine = currentLineNum
        Continue

      Else
        Protected trimmedUpper.s = Trim(upper)
        If Left(trimmedUpper, 12) = "ENUMERATION " Or trimmedUpper = "ENUMERATION"
          inTopEnum = #True
        ElseIf Left(trimmedUpper, 10) = "STRUCTURE " Or trimmedUpper = "STRUCTURE"
          inTopStruct = #True
        ElseIf Left(trimmedUpper, 6) = "MACRO " Or trimmedUpper = "MACRO"
          inTopMacro = #True
        EndIf

        If inTopEnum Or inTopStruct Or inTopMacro Or Left(trimmedUpper, 1) = "#"
          AddElement(TypeDeclarations())
          TypeDeclarations()\content = rawLine
          TypeDeclarations()\srcLineNumber = currentLineNum
          TypeDeclarations()\srcFile = currentFile

          If trimmedUpper = "ENDENUMERATION" : inTopEnum = #False : EndIf
          If trimmedUpper = "ENDSTRUCTURE" : inTopStruct = #False : EndIf
          If trimmedUpper = "ENDMACRO" : inTopMacro = #False : EndIf
        ElseIf Left(trimmedUpper, 7) = "GLOBAL " Or Left(trimmedUpper, 7) = "NEWMAP " Or Left(trimmedUpper, 8) = "NEWLIST " Or Left(trimmedUpper, 4) = "DIM " Or Left(trimmedUpper, 9) = "THREADED " Or Left(trimmedUpper, 7) = "SHARED " Or Left(trimmedUpper, 8) = "DECLARE " Or Left(trimmedUpper, 8) = "DECLARE."
          AddElement(HeaderDeclarations())
          HeaderDeclarations()\content = rawLine
          HeaderDeclarations()\srcLineNumber = currentLineNum
          HeaderDeclarations()\srcFile = currentFile
        Else
          AddElement(MainLines())
          MainLines()\content = rawLine
          MainLines()\srcLineNumber = currentLineNum
          MainLines()\srcFile = currentFile
        EndIf
      EndIf
    EndIf
  Next

  If inClass
    SetOOPError(classStartLine, "Unclosed Class '" + *currentClass\fullName + "' - missing EndClass")
    ProcedureReturn #False
  EndIf

  If inMethod Or inClassMethod
    SetOOPError(methodStartLine, "Unclosed Method '" + *currentMethod\methodName + "' - missing EndMethod")
    ProcedureReturn #False
  EndIf

  ProcedureReturn #True
EndProcedure

; ----------------------------------------------------------------------------
; Semantic Analysis & Overloading Resolution & VTable Construction
; ----------------------------------------------------------------------------

Procedure ProcessEntityClassMetadata(*c.OOP_Class)
  If Not *c\isDatabaseEntity : ProcedureReturn : EndIf

  Protected hasMethod.b, hasGetter.b, hasSetter.b, hasAdd.b, hasCount.b

  ; 1. Auto-inject foreign key fields into target classes for HasMany relations
  ForEach *c\Relations()
    If *c\Relations()\relationType = #ORM_Rel_OneToMany
      Protected tgtClass.s = *c\Relations()\targetClass
      If FindMapElement(ClassMap(), UCase(tgtClass))
        PushListPosition(Classes())
        SelectElement(Classes(), ClassMap(UCase(tgtClass)))
        Protected hasTargetFk.b = #False
        ForEach Classes()\Fields()
          If LCase(StringField(Classes()\Fields()\name, 1, ".")) = LCase(*c\Relations()\foreignKey)
            hasTargetFk = #True
            Break
          EndIf
        Next
        If Not hasTargetFk
          AddElement(Classes()\Fields())
          Classes()\Fields()\name = *c\Relations()\foreignKey + ".i"
          Classes()\Fields()\visibility = "Public"
          Classes()\Fields()\srcLineNumber = *c\srcLineNumber
          Classes()\Fields()\srcFile = *c\srcFile
        EndIf
        PopListPosition(Classes())
      EndIf
    EndIf
  Next

  ; 2. Auto-generate getters and setters for all public fields
  Protected NewList fieldsCopy.OOP_Field()
  CopyList(*c\Fields(), fieldsCopy())
  
  ForEach fieldsCopy()
    Protected fFull.s = fieldsCopy()\name
    Protected fName.s = Trim(StringField(fFull, 1, "."))
    Protected fType.s = Trim(StringField(fFull, 2, "."))
    Protected fNameLow.s = LCase(fName)
    
    If fNameLow = "id" Or Left(fNameLow, 4) = "orm_" Or fNameLow = "*vtable" Or Left(fName, 1) = "*"
      Continue
    EndIf
    
    If FindString(UCase(fType), "IENTITYSET") > 0
      ; Relation collection field (IEntitySet)
      ; Get_<fName>() / <fName>()
      hasGetter = #False
      ForEach *c\Methods()
        If UCase(*c\Methods()\name) = UCase(fName) Or UCase(*c\Methods()\name) = UCase("Get_" + fName)
          hasGetter = #True : Break
        EndIf
      Next
      If Not hasGetter
        AddElement(*c\Methods())
        *c\Methods()\name = fName
        *c\Methods()\rawDecl = "Public Method.i " + fName + "()"
        *c\Methods()\params = ""
        *c\Methods()\cleanParams = ""
        *c\Methods()\returnType = ".i"
        *c\Methods()\visibility = "Public"
        *c\Methods()\signature = "void"
        *c\Methods()\paramCount = 0
        *c\Methods()\minParamCount = 0
        *c\Methods()\mangledMethodName = fName
        *c\Methods()\srcLineNumber = *c\srcLineNumber
        *c\Methods()\srcFile = *c\srcFile

        AddElement(MethodBodies())
        MethodBodies()\className = *c\fullName
        MethodBodies()\mangledClassName = *c\mangledName
        MethodBodies()\methodName = fName
        MethodBodies()\signature = "void"
        MethodBodies()\mangledMethodName = fName
        MethodBodies()\params = ""
        MethodBodies()\cleanParams = ""
        MethodBodies()\returnType = ".i"
        MethodBodies()\srcLineNumber = *c\srcLineNumber
        MethodBodies()\srcFile = *c\srcFile
        AddElement(MethodBodies()\BodyLines())
        MethodBodies()\BodyLines()\content = "ProcedureReturn *This\" + fName
      EndIf

      ; Add_<fName>(*child)
      hasAdd = #False
      ForEach *c\Methods()
        If UCase(*c\Methods()\name) = UCase("Add_" + fName)
          hasAdd = #True : Break
        EndIf
      Next
      If Not hasAdd
        AddElement(*c\Methods())
        *c\Methods()\name = "Add_" + fName
        *c\Methods()\rawDecl = "Public Method Add_" + fName + "(*item)"
        *c\Methods()\params = "*item"
        *c\Methods()\cleanParams = "*item"
        *c\Methods()\returnType = ""
        *c\Methods()\visibility = "Public"
        *c\Methods()\signature = "p"
        *c\Methods()\paramCount = 1
        *c\Methods()\minParamCount = 1
        *c\Methods()\mangledMethodName = "Add_" + fName
        *c\Methods()\srcLineNumber = *c\srcLineNumber
        *c\Methods()\srcFile = *c\srcFile

        AddElement(MethodBodies())
        MethodBodies()\className = *c\fullName
        MethodBodies()\mangledClassName = *c\mangledName
        MethodBodies()\methodName = "Add_" + fName
        MethodBodies()\signature = "p"
        MethodBodies()\mangledMethodName = "Add_" + fName
        MethodBodies()\params = "*item"
        MethodBodies()\cleanParams = "*item"
        MethodBodies()\returnType = ""
        MethodBodies()\srcLineNumber = *c\srcLineNumber
        MethodBodies()\srcFile = *c\srcFile
        AddElement(MethodBodies()\BodyLines())
        MethodBodies()\BodyLines()\content = "If *This\" + fName + " : *This\" + fName + "\Add(*item) : EndIf"
      EndIf

      ; Count_<fName>()
      hasCount = #False
      ForEach *c\Methods()
        If UCase(*c\Methods()\name) = UCase("Count_" + fName)
          hasCount = #True : Break
        EndIf
      Next
      If Not hasCount
        AddElement(*c\Methods())
        *c\Methods()\name = "Count_" + fName
        *c\Methods()\rawDecl = "Public Method.i Count_" + fName + "()"
        *c\Methods()\params = ""
        *c\Methods()\cleanParams = ""
        *c\Methods()\returnType = ".i"
        *c\Methods()\visibility = "Public"
        *c\Methods()\signature = "void"
        *c\Methods()\paramCount = 0
        *c\Methods()\minParamCount = 0
        *c\Methods()\mangledMethodName = "Count_" + fName
        *c\Methods()\srcLineNumber = *c\srcLineNumber
        *c\Methods()\srcFile = *c\srcFile

        AddElement(MethodBodies())
        MethodBodies()\className = *c\fullName
        MethodBodies()\mangledClassName = *c\mangledName
        MethodBodies()\methodName = "Count_" + fName
        MethodBodies()\signature = "void"
        MethodBodies()\mangledMethodName = "Count_" + fName
        MethodBodies()\params = ""
        MethodBodies()\cleanParams = ""
        MethodBodies()\returnType = ".i"
        MethodBodies()\srcLineNumber = *c\srcLineNumber
        MethodBodies()\srcFile = *c\srcFile
        AddElement(MethodBodies()\BodyLines())
        MethodBodies()\BodyLines()\content = "If *This\" + fName + " : ProcedureReturn *This\" + fName + "\Count() : EndIf : ProcedureReturn 0"
      EndIf

    Else
      ; Standard scalar field: generate Get_<fName>() and Set_<fName>(val)
      Protected retT.s = "." + fType
      If fType = "" : retT = ".i" : fType = "i" : EndIf
      
      hasGetter = #False
      ForEach *c\Methods()
        If UCase(*c\Methods()\name) = UCase("Get_" + fName)
          hasGetter = #True : Break
        EndIf
      Next
      If Not hasGetter
        AddElement(*c\Methods())
        *c\Methods()\name = "Get_" + fName
        *c\Methods()\rawDecl = "Public Method" + retT + " Get_" + fName + "()"
        *c\Methods()\params = ""
        *c\Methods()\cleanParams = ""
        *c\Methods()\returnType = retT
        *c\Methods()\visibility = "Public"
        *c\Methods()\signature = "void"
        *c\Methods()\paramCount = 0
        *c\Methods()\minParamCount = 0
        *c\Methods()\mangledMethodName = "Get_" + fName
        *c\Methods()\srcLineNumber = *c\srcLineNumber
        *c\Methods()\srcFile = *c\srcFile

        AddElement(MethodBodies())
        MethodBodies()\className = *c\fullName
        MethodBodies()\mangledClassName = *c\mangledName
        MethodBodies()\methodName = "Get_" + fName
        MethodBodies()\signature = "void"
        MethodBodies()\mangledMethodName = "Get_" + fName
        MethodBodies()\params = ""
        MethodBodies()\cleanParams = ""
        MethodBodies()\returnType = retT
        MethodBodies()\srcLineNumber = *c\srcLineNumber
        MethodBodies()\srcFile = *c\srcFile
        AddElement(MethodBodies()\BodyLines())
        MethodBodies()\BodyLines()\content = "ProcedureReturn *This\" + fName
      EndIf

      hasSetter = #False
      ForEach *c\Methods()
        If UCase(*c\Methods()\name) = UCase("Set_" + fName)
          hasSetter = #True : Break
        EndIf
      Next
      If Not hasSetter
        AddElement(*c\Methods())
        *c\Methods()\name = "Set_" + fName
        *c\Methods()\rawDecl = "Public Method Set_" + fName + "(val" + retT + ")"
        *c\Methods()\params = "val" + retT
        *c\Methods()\cleanParams = "val" + retT
        *c\Methods()\returnType = ""
        *c\Methods()\visibility = "Public"
        *c\Methods()\signature = fType
        *c\Methods()\paramCount = 1
        *c\Methods()\minParamCount = 1
        *c\Methods()\mangledMethodName = "Set_" + fName
        *c\Methods()\srcLineNumber = *c\srcLineNumber
        *c\Methods()\srcFile = *c\srcFile

        AddElement(MethodBodies())
        MethodBodies()\className = *c\fullName
        MethodBodies()\mangledClassName = *c\mangledName
        MethodBodies()\methodName = "Set_" + fName
        MethodBodies()\signature = fType
        MethodBodies()\mangledMethodName = "Set_" + fName
        MethodBodies()\params = "val" + retT
        MethodBodies()\cleanParams = "val" + retT
        MethodBodies()\returnType = ""
        MethodBodies()\srcLineNumber = *c\srcLineNumber
        MethodBodies()\srcFile = *c\srcFile
        AddElement(MethodBodies()\BodyLines())
        MethodBodies()\BodyLines()\content = "*This\" + fName + " = val"
        AddElement(MethodBodies()\BodyLines())
        MethodBodies()\BodyLines()\content = "*This\orm_isDirty = #True"
      EndIf
    EndIf
  Next
  ClearList(fieldsCopy())

  ; 3. Auto-inject the 11 IDatabaseEntity methods into *c\Methods() & MethodBodies()
  Protected Dim eNames.s(10)
  Protected Dim eRets.s(10)
  Protected Dim eParams.s(10)
  Protected Dim eClean.s(10)
  Protected Dim eSigs.s(10)
  Protected Dim eParamCounts.i(10)
  Protected Dim eMinParams.i(10)

  eNames(0) = "GetId"        : eRets(0) = ".i" : eParams(0) = "" : eClean(0) = "" : eSigs(0) = "void" : eParamCounts(0) = 0 : eMinParams(0) = 0
  eNames(1) = "SetId"        : eRets(1) = ""   : eParams(1) = "id.i" : eClean(1) = "id.i" : eSigs(1) = "i" : eParamCounts(1) = 1 : eMinParams(1) = 1
  eNames(2) = "IsDirty"      : eRets(2) = ".b" : eParams(2) = "" : eClean(2) = "" : eSigs(2) = "void" : eParamCounts(2) = 0 : eMinParams(2) = 0
  eNames(3) = "SetDirty"     : eRets(3) = ""   : eParams(3) = "dirty.b" : eClean(3) = "dirty.b" : eSigs(3) = "b" : eParamCounts(3) = 1 : eMinParams(3) = 1
  eNames(4) = "IsNew"        : eRets(4) = ".b" : eParams(4) = "" : eClean(4) = "" : eSigs(4) = "void" : eParamCounts(4) = 0 : eMinParams(4) = 0
  eNames(5) = "SetNew"       : eRets(5) = ""   : eParams(5) = "isNew.b" : eClean(5) = "isNew.b" : eSigs(5) = "b" : eParamCounts(5) = 1 : eMinParams(5) = 1
  eNames(6) = "Save"         : eRets(6) = ".b" : eParams(6) = "db.DatabaseEngine::IDatabase = 0" : eClean(6) = "db.DatabaseEngine::IDatabase = 0" : eSigs(6) = "IDatabase" : eParamCounts(6) = 1 : eMinParams(6) = 0
  eNames(7) = "Delete"       : eRets(7) = ".b" : eParams(7) = "db.DatabaseEngine::IDatabase = 0" : eClean(7) = "db.DatabaseEngine::IDatabase = 0" : eSigs(7) = "IDatabase" : eParamCounts(7) = 1 : eMinParams(7) = 0
  eNames(8) = "Reload"       : eRets(8) = ".b" : eParams(8) = "db.DatabaseEngine::IDatabase = 0" : eClean(8) = "db.DatabaseEngine::IDatabase = 0" : eSigs(8) = "IDatabase" : eParamCounts(8) = 1 : eMinParams(8) = 0
  eNames(9) = "GetTableName" : eRets(9) = ".s" : eParams(9) = "" : eClean(9) = "" : eSigs(9) = "void" : eParamCounts(9) = 0 : eMinParams(9) = 0
  eNames(10) = "GetEntityName": eRets(10) = ".s": eParams(10) = "" : eClean(10) = "" : eSigs(10) = "void": eParamCounts(10) = 0 : eMinParams(10) = 0

  Protected i.i
  For i = 0 To 10
    hasMethod = #False
    ForEach *c\Methods()
      If UCase(*c\Methods()\name) = UCase(eNames(i))
        hasMethod = #True : Break
      EndIf
    Next
    If Not hasMethod
      AddElement(*c\Methods())
      *c\Methods()\name = eNames(i)
      *c\Methods()\rawDecl = "Public Method" + eRets(i) + " " + eNames(i) + "(" + eParams(i) + ")"
      *c\Methods()\params = eParams(i)
      *c\Methods()\cleanParams = eClean(i)
      *c\Methods()\returnType = eRets(i)
      *c\Methods()\visibility = "Public"
      *c\Methods()\signature = eSigs(i)
      *c\Methods()\paramCount = eParamCounts(i)
      *c\Methods()\minParamCount = eMinParams(i)
      *c\Methods()\mangledMethodName = eNames(i)
      *c\Methods()\srcLineNumber = *c\srcLineNumber
      *c\Methods()\srcFile = *c\srcFile
    EndIf

    Protected hasBody.b = #False
    ForEach MethodBodies()
      If MethodBodies()\className = *c\fullName And UCase(MethodBodies()\methodName) = UCase(eNames(i))
        hasBody = #True : Break
      EndIf
    Next
    If Not hasBody
      AddElement(MethodBodies())
      MethodBodies()\className = *c\fullName
      MethodBodies()\mangledClassName = *c\mangledName
      MethodBodies()\methodName = eNames(i)
      MethodBodies()\signature = eSigs(i)
      MethodBodies()\mangledMethodName = eNames(i)
      MethodBodies()\params = eParams(i)
      MethodBodies()\cleanParams = eClean(i)
      MethodBodies()\returnType = eRets(i)
      MethodBodies()\srcLineNumber = *c\srcLineNumber
      MethodBodies()\srcFile = *c\srcFile

      Select i
        Case 0 ; GetId
          AddElement(MethodBodies()\BodyLines()) : MethodBodies()\BodyLines()\content = "ProcedureReturn *This\id"
        Case 1 ; SetId
          AddElement(MethodBodies()\BodyLines()) : MethodBodies()\BodyLines()\content = "*This\id = id"
        Case 2 ; IsDirty
          AddElement(MethodBodies()\BodyLines()) : MethodBodies()\BodyLines()\content = "ProcedureReturn *This\orm_isDirty"
        Case 3 ; SetDirty
          AddElement(MethodBodies()\BodyLines()) : MethodBodies()\BodyLines()\content = "*This\orm_isDirty = dirty"
        Case 4 ; IsNew
          AddElement(MethodBodies()\BodyLines()) : MethodBodies()\BodyLines()\content = "ProcedureReturn *This\orm_isNew"
        Case 5 ; SetNew
          AddElement(MethodBodies()\BodyLines()) : MethodBodies()\BodyLines()\content = "*This\orm_isNew = isNew"
        Case 6 ; Save
          AddElement(MethodBodies()\BodyLines()) : MethodBodies()\BodyLines()\content = "Protected targetDb.DatabaseEngine::IDatabase = db"
          AddElement(MethodBodies()\BodyLines()) : MethodBodies()\BodyLines()\content = "If targetDb = 0 : targetDb = Database::GetDefault() : EndIf"
          AddElement(MethodBodies()\BodyLines()) : MethodBodies()\BodyLines()\content = "If targetDb = 0 : ProcedureReturn #False : EndIf"
          AddElement(MethodBodies()\BodyLines()) : MethodBodies()\BodyLines()\content = "ProcedureReturn targetDb\Save(*This)"
        Case 7 ; Delete
          AddElement(MethodBodies()\BodyLines()) : MethodBodies()\BodyLines()\content = "Protected targetDb.DatabaseEngine::IDatabase = db"
          AddElement(MethodBodies()\BodyLines()) : MethodBodies()\BodyLines()\content = "If targetDb = 0 : targetDb = Database::GetDefault() : EndIf"
          AddElement(MethodBodies()\BodyLines()) : MethodBodies()\BodyLines()\content = "If targetDb = 0 : ProcedureReturn #False : EndIf"
          AddElement(MethodBodies()\BodyLines()) : MethodBodies()\BodyLines()\content = "ProcedureReturn targetDb\Delete(*This)"
        Case 8 ; Reload
          AddElement(MethodBodies()\BodyLines()) : MethodBodies()\BodyLines()\content = "Protected targetDb.DatabaseEngine::IDatabase = db"
          AddElement(MethodBodies()\BodyLines()) : MethodBodies()\BodyLines()\content = "If targetDb = 0 : targetDb = Database::GetDefault() : EndIf"
          AddElement(MethodBodies()\BodyLines()) : MethodBodies()\BodyLines()\content = "If targetDb = 0 Or *This\id = 0 : ProcedureReturn #False : EndIf"
          AddElement(MethodBodies()\BodyLines()) : MethodBodies()\BodyLines()\content = "NewMap vals.s()"
          AddElement(MethodBodies()\BodyLines()) : MethodBodies()\BodyLines()\content = "If ORM_CRUD::SelectById(targetDb\GetHandle(), " + Chr(34) + *c\name + Chr(34) + ", *This\id, vals())"
          AddElement(MethodBodies()\BodyLines()) : MethodBodies()\BodyLines()\content = "  " + *c\mangledName + "_Deserialize(*This, vals())"
          AddElement(MethodBodies()\BodyLines()) : MethodBodies()\BodyLines()\content = "  *This\orm_isDirty = #False"
          AddElement(MethodBodies()\BodyLines()) : MethodBodies()\BodyLines()\content = "  *This\orm_isNew = #False"
          AddElement(MethodBodies()\BodyLines()) : MethodBodies()\BodyLines()\content = "  ProcedureReturn #True"
          AddElement(MethodBodies()\BodyLines()) : MethodBodies()\BodyLines()\content = "EndIf"
          AddElement(MethodBodies()\BodyLines()) : MethodBodies()\BodyLines()\content = "ProcedureReturn #False"
        Case 9 ; GetTableName
          AddElement(MethodBodies()\BodyLines()) : MethodBodies()\BodyLines()\content = "ProcedureReturn " + Chr(34) + LCase(*c\name) + "s" + Chr(34)
        Case 10 ; GetEntityName
          AddElement(MethodBodies()\BodyLines()) : MethodBodies()\BodyLines()\content = "ProcedureReturn " + Chr(34) + *c\name + Chr(34)
      EndSelect
    EndIf
  Next
EndProcedure

Procedure.b BuildVTables()
  ; Step 0: Process database entity classes (inject methods, fields, relations)
  ForEach Classes()
    If Classes()\isDatabaseEntity
      ProcessEntityClassMetadata(@Classes())
    EndIf
  Next

  ; Step 1: Detect method overloading within each class and across hierarchy
  ForEach Classes()
    Protected *c.OOP_Class = @Classes()
    Protected NewMap methodCount.i()
    
    ; Count occurrences of each method name in class
    ForEach *c\Methods()
      Protected mKey.s = UCase(*c\Methods()\name)
      methodCount(mKey) + 1
    Next

    ; Mark overloaded methods
    ForEach *c\Methods()
      mKey = UCase(*c\Methods()\name)
      If methodCount(mKey) > 1
        *c\Methods()\mangledMethodName = *c\Methods()\name + "_" + *c\Methods()\signature
        OverloadedMethodNames(mKey) = 1
      Else
        *c\Methods()\mangledMethodName = *c\Methods()\name
      EndIf
    Next

    ; Name mangling for constructors
    If ListSize(*c\InitConstructors()) > 1
      ForEach *c\InitConstructors()
        *c\InitConstructors()\mangledName = "New_" + *c\mangledName + "_" + *c\InitConstructors()\signature
        *c\InitConstructors()\initProcMangled = *c\mangledName + "_Init_" + *c\InitConstructors()\signature
      Next
    ElseIf ListSize(*c\InitConstructors()) = 1
      FirstElement(*c\InitConstructors())
      *c\InitConstructors()\mangledName = "New_" + *c\mangledName
      *c\InitConstructors()\initProcMangled = *c\mangledName + "_Init"
    EndIf
  Next

  ; Step 2: Build VTable Slots with inheritance
  ForEach Classes()
    *c = @Classes()
    ClearList(*c\VTableSlots())

    ; Inherit slots from parent class
    If *c\parentName <> ""
      *c\fullParentName = ResolveClassName(*c\parentName, *c\namespace)
      *c\mangledParentName = MangleIdentifier(*c\fullParentName)

      If Not FindMapElement(ClassMap(), UCase(*c\fullParentName))
        SetOOPError(*c\srcLineNumber, "Class '" + *c\fullName + "' extends unknown parent class '" + *c\parentName + "'")
        ProcedureReturn #False
      EndIf
      
      Protected parentIdx.i = ClassMap(UCase(*c\fullParentName))
      PushListPosition(Classes())
      SelectElement(Classes(), parentIdx)
      Protected *parent.OOP_Class = @Classes()
      ForEach *parent\VTableSlots()
        AddElement(*c\VTableSlots())
        *c\VTableSlots()\methodName = *parent\VTableSlots()\methodName
        *c\VTableSlots()\baseMethodName = *parent\VTableSlots()\baseMethodName
        *c\VTableSlots()\signature = *parent\VTableSlots()\signature
        *c\VTableSlots()\implementingClass = *parent\VTableSlots()\implementingClass
        *c\VTableSlots()\declaringClass = *parent\VTableSlots()\declaringClass
        *c\VTableSlots()\params = *parent\VTableSlots()\params
        *c\VTableSlots()\cleanParams = *parent\VTableSlots()\cleanParams
        *c\VTableSlots()\returnType = *parent\VTableSlots()\returnType
        *c\VTableSlots()\isAbstract = *parent\VTableSlots()\isAbstract
        *c\VTableSlots()\paramCount = *parent\VTableSlots()\paramCount
        *c\VTableSlots()\minParamCount = *parent\VTableSlots()\minParamCount
        *c\VTableSlots()\srcLineNumber = *parent\VTableSlots()\srcLineNumber
        *c\VTableSlots()\srcFile = *parent\VTableSlots()\srcFile
      Next
      PopListPosition(Classes())
    ElseIf *c\isDatabaseEntity
      ; Root entity class: populate the 11 IDatabaseEntity slots first
      Protected Dim eSlotNames.s(10)
      Protected Dim eSlotRets.s(10)
      Protected Dim eSlotParams.s(10)
      Protected Dim eSlotClean.s(10)
      Protected Dim eSlotSigs.s(10)
      Protected Dim eSlotCounts.i(10)
      Protected Dim eSlotMin.i(10)

      eSlotNames(0) = "GetId"        : eSlotRets(0) = ".i" : eSlotParams(0) = "" : eSlotClean(0) = "" : eSlotSigs(0) = "void" : eSlotCounts(0) = 0 : eSlotMin(0) = 0
      eSlotNames(1) = "SetId"        : eSlotRets(1) = ""   : eSlotParams(1) = "id.i" : eSlotClean(1) = "id.i" : eSlotSigs(1) = "i" : eSlotCounts(1) = 1 : eSlotMin(1) = 1
      eSlotNames(2) = "IsDirty"      : eSlotRets(2) = ".b" : eSlotParams(2) = "" : eSlotClean(2) = "" : eSlotSigs(2) = "void" : eSlotCounts(2) = 0 : eSlotMin(2) = 0
      eSlotNames(3) = "SetDirty"     : eSlotRets(3) = ""   : eSlotParams(3) = "dirty.b" : eSlotClean(3) = "dirty.b" : eSlotSigs(3) = "b" : eSlotCounts(3) = 1 : eSlotMin(3) = 1
      eSlotNames(4) = "IsNew"        : eSlotRets(4) = ".b" : eSlotParams(4) = "" : eSlotClean(4) = "" : eSlotSigs(4) = "void" : eSlotCounts(4) = 0 : eSlotMin(4) = 0
      eSlotNames(5) = "SetNew"       : eSlotRets(5) = ""   : eSlotParams(5) = "isNew.b" : eSlotClean(5) = "isNew.b" : eSlotSigs(5) = "b" : eSlotCounts(5) = 1 : eSlotMin(5) = 1
      eSlotNames(6) = "Save"         : eSlotRets(6) = ".b" : eSlotParams(6) = "db.DatabaseEngine::IDatabase = 0" : eSlotClean(6) = "db.DatabaseEngine::IDatabase = 0" : eSlotSigs(6) = "IDatabase" : eSlotCounts(6) = 1 : eSlotMin(6) = 0
      eSlotNames(7) = "Delete"       : eSlotRets(7) = ".b" : eSlotParams(7) = "db.DatabaseEngine::IDatabase = 0" : eSlotClean(7) = "db.DatabaseEngine::IDatabase = 0" : eSlotSigs(7) = "IDatabase" : eSlotCounts(7) = 1 : eSlotMin(7) = 0
      eSlotNames(8) = "Reload"       : eSlotRets(8) = ".b" : eSlotParams(8) = "db.DatabaseEngine::IDatabase = 0" : eSlotClean(8) = "db.DatabaseEngine::IDatabase = 0" : eSlotSigs(8) = "IDatabase" : eSlotCounts(8) = 1 : eSlotMin(8) = 0
      eSlotNames(9) = "GetTableName" : eSlotRets(9) = ".s" : eSlotParams(9) = "" : eSlotClean(9) = "" : eSlotSigs(9) = "void" : eSlotCounts(9) = 0 : eSlotMin(9) = 0
      eSlotNames(10) = "GetEntityName": eSlotRets(10) = ".s": eSlotParams(10) = "" : eSlotClean(10) = "" : eSlotSigs(10) = "void": eSlotCounts(10) = 0 : eSlotMin(10) = 0

      Protected iSlot.i
      For iSlot = 0 To 10
        AddElement(*c\VTableSlots())
        *c\VTableSlots()\methodName = eSlotNames(iSlot)
        *c\VTableSlots()\baseMethodName = eSlotNames(iSlot)
        *c\VTableSlots()\signature = eSlotSigs(iSlot)
        *c\VTableSlots()\implementingClass = *c\fullName
        *c\VTableSlots()\declaringClass = *c\fullName
        *c\VTableSlots()\params = eSlotParams(iSlot)
        *c\VTableSlots()\cleanParams = eSlotClean(iSlot)
        *c\VTableSlots()\returnType = eSlotRets(iSlot)
        *c\VTableSlots()\isAbstract = #False
        *c\VTableSlots()\paramCount = eSlotCounts(iSlot)
        *c\VTableSlots()\minParamCount = eSlotMin(iSlot)
        *c\VTableSlots()\srcLineNumber = *c\srcLineNumber
        *c\VTableSlots()\srcFile = *c\srcFile
      Next
    EndIf

    ; Process methods declared in current class
    ForEach *c\Methods()
      Protected *m.OOP_Method = @*c\Methods()
      
      ; Constructors and Private methods do not go into VTable
      If *m\visibility = "Private" Or UCase(*m\name) = "INIT"
        Continue
      EndIf

      ; Check if overriding an existing VTable slot (matching baseMethodName AND signature)
      Protected isOverridden.b = #False
      ForEach *c\VTableSlots()
        If UCase(*c\VTableSlots()\baseMethodName) = UCase(*m\name) And *c\VTableSlots()\signature = *m\signature
          *c\VTableSlots()\implementingClass = *c\fullName
          *c\VTableSlots()\isAbstract = *m\isAbstract
          *c\VTableSlots()\methodName = *m\mangledMethodName
          *m\isOverride = #True
          isOverridden = #True
          Break
        EndIf
      Next

      ; If not overriding, append new VTable slot
      If Not isOverridden
        AddElement(*c\VTableSlots())
        *c\VTableSlots()\methodName = *m\mangledMethodName
        *c\VTableSlots()\baseMethodName = *m\name
        *c\VTableSlots()\signature = *m\signature
        *c\VTableSlots()\implementingClass = *c\fullName
        *c\VTableSlots()\declaringClass = *c\fullName
        *c\VTableSlots()\params = *m\params
        *c\VTableSlots()\cleanParams = *m\cleanParams
        *c\VTableSlots()\returnType = *m\returnType
        *c\VTableSlots()\isAbstract = *m\isAbstract
        *c\VTableSlots()\paramCount = *m\paramCount
        *c\VTableSlots()\minParamCount = *m\minParamCount
        *c\VTableSlots()\srcLineNumber = *m\srcLineNumber
        *c\VTableSlots()\srcFile = *m\srcFile
      EndIf
    Next


    ; Inherit Free if not explicitly defined
    If Not *c\hasFree And *c\parentName <> ""
      Protected curP.s = *c\fullParentName
      While curP <> ""
        If FindMapElement(ClassMap(), UCase(curP))
          PushListPosition(Classes())
          SelectElement(Classes(), ClassMap(UCase(curP)))
          If Classes()\hasFree
            *c\hasFree = #True
            *c\freeClassMangled = Classes()\freeClassMangled
            PopListPosition(Classes())
            Break
          EndIf
          curP = Classes()\fullParentName
          PopListPosition(Classes())
        Else
          Break
        EndIf
      Wend
    EndIf
  Next

  ; Step 3: Align MethodBodies with mangled names
  ForEach MethodBodies()
    Protected *b.OOP_MethodBody = @MethodBodies()
    If FindMapElement(ClassMap(), UCase(*b\className))
      PushListPosition(Classes())
      SelectElement(Classes(), ClassMap(UCase(*b\className)))
      If UCase(*b\methodName) = "INIT"
        If ListSize(Classes()\InitConstructors()) > 1
          *b\mangledMethodName = "Init_" + *b\signature
        Else
          *b\mangledMethodName = "Init"
        EndIf
      Else
        ForEach Classes()\Methods()
          If UCase(Classes()\Methods()\name) = UCase(*b\methodName) And Classes()\Methods()\signature = *b\signature
            *b\mangledMethodName = Classes()\Methods()\mangledMethodName
            Break
          EndIf
        Next
      EndIf
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
          Protected hasImpl.b = #False
          ForEach MethodBodies()
            If MethodBodies()\className = *c\fullName And UCase(MethodBodies()\mangledMethodName) = UCase(*c\VTableSlots()\methodName)
              hasImpl = #True
              Break
            EndIf
          Next
          If Not hasImpl
            SetOOPError(*c\srcLineNumber, "Class '" + *c\fullName + "' must implement abstract method '" + *c\VTableSlots()\baseMethodName + "' declared in abstract class '" + *c\VTableSlots()\declaringClass + "' (or be declared Abstract Class).")
            ProcedureReturn #False
          EndIf
        EndIf
      Next
    EndIf
  Next

  ; 2. Check that abstract classes are not instantiated in MainLines
  ForEach Classes()
    If Classes()\isAbstract
      Protected absFull.s = Classes()\fullName
      Protected absShort.s = Classes()\name
      Protected absUpperFull.s = UCase(absFull)
      Protected absUpperShort.s = UCase(absShort)

      ForEach MainLines()
        Protected mLine.s = MainLines()\content
        Protected upLine.s = UCase(mLine)
        If FindString(upLine, "NEW " + absUpperFull + "(") > 0 Or FindString(upLine, "NEW " + absUpperShort + "(") > 0 Or FindString(upLine, "NEW(" + absUpperFull + ")") > 0 Or FindString(upLine, "NEW(" + absUpperShort + ")") > 0
          SetOOPError(MainLines()\srcLineNumber, "Cannot instantiate abstract class '" + absFull + "'")
          ProcedureReturn #False
        EndIf
      Next
    EndIf
  Next

  ; 3. Check Super:: calls in method bodies
  ForEach MethodBodies()
    Protected *body.OOP_MethodBody = @MethodBodies()
    Protected parentClsName.s = ""
    If FindMapElement(ClassMap(), UCase(*body\className))
      SelectElement(Classes(), ClassMap(UCase(*body\className)))
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
; Static Memory Leak Checker Engine
; ----------------------------------------------------------------------------

Procedure ProcessLineAllocation(cleanLine.s, lineNum.i, srcFile.s, scopeType.s, scopeName.s, List trackedList.OOP_TrackedInstance())
  Protected pEq.i = FindCharOutsideQuotes(cleanLine, "=")
  If pEq <= 1 : ProcedureReturn : EndIf
  
  Protected leftSide.s = Trim(Left(cleanLine, pEq - 1))
  Protected rightSide.s = Trim(Mid(cleanLine, pEq + 1))
  
  ; Check if rightSide starts with "New " or "New("
  Protected upRight.s = UCase(rightSide)
  Protected isNew.b = #False
  Protected clsName.s = ""
  
  If Left(upRight, 4) = "NEW " Or Left(upRight, 5) = "NEW  "
    Protected afterNew.s = Trim(Mid(rightSide, 5))
    Protected pOpen.i = FindString(afterNew, "(")
    If pOpen > 0
      clsName = Trim(Left(afterNew, pOpen - 1))
      isNew = #True
    EndIf
  ElseIf Left(upRight, 4) = "NEW("
    Protected afterParen.s = Trim(Mid(rightSide, 5))
    Protected pComma.i = FindString(afterParen, ",")
    Protected pClose.i = FindString(afterParen, ")")
    Protected pEndCls.i = pComma
    If pEndCls = 0 Or (pClose > 0 And pClose < pEndCls)
      pEndCls = pClose
    EndIf
    If pEndCls > 0
      clsName = Trim(Left(afterParen, pEndCls - 1))
      isNew = #True
    EndIf
  EndIf
  
  If Not isNew Or clsName = "" : ProcedureReturn : EndIf
  
  ; Extract variable name from leftSide
  Protected upLeft.s = UCase(leftSide)
  If Left(upLeft, 7) = "DEFINE " : leftSide = Trim(Mid(leftSide, 8)) : EndIf
  If Left(upLeft, 10) = "PROTECTED " : leftSide = Trim(Mid(leftSide, 11)) : EndIf
  If Left(upLeft, 7) = "GLOBAL " : leftSide = Trim(Mid(leftSide, 8)) : EndIf
  If Left(upLeft, 7) = "STATIC " : leftSide = Trim(Mid(leftSide, 8)) : EndIf
  If Left(upLeft, 9) = "THREADED " : leftSide = Trim(Mid(leftSide, 10)) : EndIf
  If Left(upLeft, 7) = "SHARED " : leftSide = Trim(Mid(leftSide, 8)) : EndIf
  
  Protected varName.s = leftSide
  Protected pDot.i = FindString(varName, ".")
  If pDot > 0
    varName = Trim(Left(varName, pDot - 1))
  EndIf
  Protected pSpace.i = FindString(varName, " ")
  If pSpace > 0
    varName = Trim(Left(varName, pSpace - 1))
  EndIf
  
  If varName = "" : ProcedureReturn : EndIf
  
  ; Check if variable was already allocated in this scope without being freed (Reassignment leak)
  ForEach trackedList()
    If trackedList()\varName = varName And trackedList()\state = #OOP_INSTANCE_ALLOCATED
      PrintN("[WARN_LEAK] Line " + Str(lineNum) + " in " + GetFilePart(srcFile) + ": Variable '" + varName + "' is reassigned with 'New' without releasing its previous instance of Class '" + trackedList()\className + "' (allocated at Line " + Str(trackedList()\allocLineNumber) + ").")
      TotalLeaksDetected + 1
      trackedList()\state = #OOP_INSTANCE_FREED ; Mark old as warned to avoid duplicate warning
      Break
    EndIf
  Next
  
  ; Register new tracked instance
  AddElement(trackedList())
  trackedList()\varName = varName
  trackedList()\className = clsName
  trackedList()\scopeName = scopeName
  trackedList()\allocLineNumber = lineNum
  trackedList()\allocFile = srcFile
  trackedList()\state = #OOP_INSTANCE_ALLOCATED
EndProcedure

Procedure ProcessLineLifecycle(cleanLine.s, List trackedList.OOP_TrackedInstance())
  If ListSize(trackedList()) = 0 : ProcedureReturn : EndIf
  
  Protected upLine.s = UCase(cleanLine)
  Protected isProcRet.b = Bool(Left(upLine, 15) = "PROCEDURERETURN")
  Protected hasTransferCall.b = Bool(FindString(cleanLine, "AddChild") > 0 Or 
                                     FindString(cleanLine, "AddElement") > 0 Or 
                                     FindString(cleanLine, "Register") > 0 Or 
                                     FindString(cleanLine, "SetCell") > 0 Or 
                                     FindString(cleanLine, "SetDock") > 0 Or 
                                     FindString(cleanLine, "SetContent") > 0 Or 
                                     FindString(cleanLine, "AddPanel") > 0 Or 
                                     FindString(cleanLine, "AddControl") > 0 Or 
                                     FindString(cleanLine, "SetMainWindow") > 0)
  Protected isFieldAssign.b = Bool((FindString(cleanLine, "This\") > 0 Or FindString(cleanLine, "*This\") > 0) And FindString(cleanLine, "=") > 0)

  ForEach trackedList()
    If trackedList()\state = #OOP_INSTANCE_ALLOCATED
      Protected vName.s = trackedList()\varName
      Protected cName.s = trackedList()\className

      ; 1. Check for Free
      If FindString(cleanLine, vName + "\Free(") > 0 Or 
         FindString(cleanLine, vName + "\Free (") > 0 Or 
         FindString(cleanLine, "Free(" + vName + ")") > 0 Or 
         FindString(cleanLine, "Free (" + vName + ")") > 0 Or 
         FindString(cleanLine, "FreeStructure(" + vName + ")") > 0 Or 
         FindString(cleanLine, "FreeStructure (" + vName + ")") > 0 Or 
         FindString(cleanLine, "Free_" + cName + "(" + vName + ")") > 0 Or 
         FindString(cleanLine, "Free " + vName) > 0
        trackedList()\state = #OOP_INSTANCE_FREED
        Continue
      EndIf

      ; 2. Check for Ownership Transfer (ProcedureReturn, This\field =, AddChild, SetCell, SetDock, SetContent...)
      If isProcRet And FindString(cleanLine, vName) > 0
        trackedList()\state = #OOP_INSTANCE_TRANSFERRED
        Continue
      EndIf

      If isFieldAssign And FindString(cleanLine, vName) > 0
        trackedList()\state = #OOP_INSTANCE_TRANSFERRED
        Continue
      EndIf

      If hasTransferCall And FindString(cleanLine, vName) > 0
        trackedList()\state = #OOP_INSTANCE_TRANSFERRED
        Continue
      EndIf
    EndIf
  Next
EndProcedure

Procedure CheckScopeInstances(List trackedList.OOP_TrackedInstance(), scopeType.s, scopeName.s)
  ForEach trackedList()
    If trackedList()\state = #OOP_INSTANCE_ALLOCATED
      ; Filter out internal framework files so only user code is warned
      Protected isFrameworkFile.b = #False
      Protected allocF.s = LCase(trackedList()\allocFile)
      If FindString(allocF, "framework\") > 0 Or FindString(allocF, "framework/") > 0 Or 
         GetFilePart(allocF) = "xmlloader.pbi" Or GetFilePart(allocF) = "animationengine.pbi" Or 
         GetFilePart(allocF) = "ui.pbi"
        isFrameworkFile = #True
      EndIf
      
      If Not isFrameworkFile
        TotalLeaksDetected + 1
        PrintN("[WARN_LEAK] Line " + Str(trackedList()\allocLineNumber) + " in " + GetFilePart(trackedList()\allocFile) + ": Instance '" + trackedList()\varName + "' of Class '" + trackedList()\className + "' was allocated with 'New' but is never released in " + scopeType + " '" + scopeName + "'.")
      Else
        TotalInstancesManaged + 1
      EndIf
    Else
      TotalInstancesManaged + 1
    EndIf
  Next
  ClearList(trackedList())
EndProcedure

Procedure.b CheckMemoryLeaks()
  TotalLeaksDetected = 0
  TotalInstancesManaged = 0
  
  ; 1. Check all Class Method Bodies
  ForEach MethodBodies()
    Protected NewList methodTracked.OOP_TrackedInstance()
    Protected methScope.s = MethodBodies()\className + "::" + MethodBodies()\methodName
    
    ForEach MethodBodies()\BodyLines()
      Protected rawL.s = MethodBodies()\BodyLines()\content
      Protected cleanL.s = StripComment(rawL)
      If cleanL = "" : Continue : EndIf
      
      ProcessLineAllocation(cleanL, MethodBodies()\BodyLines()\srcLineNumber, MethodBodies()\BodyLines()\srcFile, "Method", methScope, methodTracked())
      ProcessLineLifecycle(cleanL, methodTracked())
    Next
    
    CheckScopeInstances(methodTracked(), "Method", methScope)
  Next
  
  ; 2. Check MainLines (Top-level + regular Procedures)
  Protected NewList mainTracked.OOP_TrackedInstance()
  Protected NewList procTracked.OOP_TrackedInstance()
  Protected inProc.b = #False
  Protected curProcName.s = ""
  
  ForEach MainLines()
    rawL = MainLines()\content
    cleanL = StripComment(rawL)
    If cleanL = "" : Continue : EndIf
    
    Protected upL.s = UCase(cleanL)
    If Left(upL, 10) = "PROCEDURE " Or Left(upL, 10) = "PROCEDURE." Or Left(upL, 11) = "PROCEDUREC " Or Left(upL, 11) = "PROCEDUREC."
      inProc = #True
      curProcName = Trim(Mid(cleanL, FindString(cleanL, " ") + 1))
      Protected pParen.i = FindString(curProcName, "(")
      If pParen > 0 : curProcName = Trim(Left(curProcName, pParen - 1)) : EndIf
      Protected pDotProc.i = FindString(curProcName, ".")
      If pDotProc > 0 : curProcName = Trim(Mid(curProcName, pDotProc + 1)) : EndIf
      ClearList(procTracked())
      Continue
    ElseIf upL = "ENDPROCEDURE"
      If inProc
        CheckScopeInstances(procTracked(), "Procedure", curProcName)
        inProc = #False
        curProcName = ""
      EndIf
      Continue
    EndIf
    
    If inProc
      ProcessLineAllocation(cleanL, MainLines()\srcLineNumber, MainLines()\srcFile, "Procedure", curProcName, procTracked())
      ProcessLineLifecycle(cleanL, procTracked())
    Else
      ProcessLineAllocation(cleanL, MainLines()\srcLineNumber, MainLines()\srcFile, "Scope", "Main", mainTracked())
      ProcessLineLifecycle(cleanL, mainTracked())
    EndIf
  Next
  
  If inProc
    CheckScopeInstances(procTracked(), "Procedure", curProcName)
  EndIf
  CheckScopeInstances(mainTracked(), "Scope", "Main")
  
  ; Summary
  If TotalLeaksDetected > 0
    PrintN("")
    PrintN("[INFO] Static Memory Analysis: " + Str(TotalLeaksDetected) + " potential memory leak(s) detected, " + Str(TotalInstancesManaged) + " instance(s) properly managed.")
    PrintN("")
    If StrictLeaks
      SetOOPError(0, "Strict leak check failed: " + Str(TotalLeaksDetected) + " potential memory leak(s) detected.")
      ProcedureReturn #False
    EndIf
  ElseIf TotalInstancesManaged > 0
    PrintN("[INFO] Static Memory Analysis: 0 leaks detected, all " + Str(TotalInstancesManaged) + " instance(s) properly managed.")
  EndIf
  
  ProcedureReturn #True
EndProcedure

; ----------------------------------------------------------------------------
; Code Generation Phase: Emit PureBasic Code & Source Map
; ----------------------------------------------------------------------------

Declare.s TranspileMainLine(line.s)

; Resolves overloaded method calls on object instances: *obj\Method(args) -> *obj\Method_sig(args)
Procedure.s ResolveOverloadedMethodCalls(line.s)
  Protected res.s = line
  If MapSize(OverloadedMethodNames()) = 0 : ProcedureReturn res : EndIf

  ForEach OverloadedMethodNames()
    Protected mName.s = MapKey(OverloadedMethodNames())
    Protected searchPattern.s = "\" + mName + "("
    Protected pCall.i = FindString(UCase(res), searchPattern)
    
    While pCall > 0
      ; Find matching closing parenthesis
      Protected pOpen.i = pCall + Len(searchPattern) - 1
      Protected i.i, depth.i = 1, inQuote.b = #False
      Protected pClose.i = 0
      Protected lenR.i = Len(res)
      
      For i = pOpen + 1 To lenR
        Protected ch.s = Mid(res, i, 1)
        If ch = Chr(34)
          inQuote = ~inQuote & 1
        ElseIf ch = "(" And Not inQuote
          depth + 1
        ElseIf ch = ")" And Not inQuote
          depth - 1
          If depth = 0
            pClose = i
            Break
          EndIf
        EndIf
      Next

      If pClose > pOpen
        Protected argList.s = Trim(Mid(res, pOpen + 1, pClose - pOpen - 1))
        Protected argCount.i = 0
        Protected callSig.s = GetCallArgSignature(argList, argCount)
        
        ; Find best matching VTableSlot across classes
        Protected bestMangled.s = ""
        PushListPosition(Classes())
        ForEach Classes()
          ForEach Classes()\VTableSlots()
            If UCase(Classes()\VTableSlots()\baseMethodName) = mName
              ; Exact signature match
              If Classes()\VTableSlots()\signature = callSig
                bestMangled = Classes()\VTableSlots()\methodName
                Break 2
              ; Arity match
              ElseIf Classes()\VTableSlots()\paramCount = argCount
                bestMangled = Classes()\VTableSlots()\methodName
              EndIf
            EndIf
          Next
        Next
        PopListPosition(Classes())

        If bestMangled <> ""
          res = Left(res, pCall) + bestMangled + "(" + Mid(res, pOpen + 1)
        EndIf
      EndIf

      pCall = FindString(UCase(res), searchPattern, pCall + Len(searchPattern))
    Wend
  Next

  ProcedureReturn res
EndProcedure

Procedure.s TranspileMethodBodyLine(line.s, className.s, parentMangledName.s)
  Protected res.s = line
  
  ; 1. Replace Super::Method(args) with Parent_Method(*This, args)
  If parentMangledName <> ""
    Protected pSuper.i = FindString(res, "Super::")
    If pSuper = 0
      pSuper = FindString(res, "Super\")
    EndIf
    While pSuper > 0
      Protected sepLen.i = 7
      If Mid(res, pSuper, 6) = "Super\"
        sepLen = 6
      EndIf

      Protected pParenOpen.i = FindString(res, "(", pSuper)
      If pParenOpen > pSuper
        Protected superMethod.s = Trim(Mid(res, pSuper + sepLen, pParenOpen - (pSuper + sepLen)))
        Protected pClose.i = 0
        Protected i.i, depth.i = 1, inQuote.b = #False
        Protected lenR.i = Len(res)
        
        For i = pParenOpen + 1 To lenR
          Protected ch.s = Mid(res, i, 1)
          If ch = Chr(34)
            inQuote = ~inQuote & 1
          ElseIf ch = "(" And Not inQuote
            depth + 1
          ElseIf ch = ")" And Not inQuote
            depth - 1
            If depth = 0
              pClose = i
              Break
            EndIf
          EndIf
        Next

        If pClose > pParenOpen
          Protected superArgList.s = Trim(Mid(res, pParenOpen + 1, pClose - pParenOpen - 1))
          Protected callTarget.s = ""
          
          Protected foundParent.b = #False
          PushListPosition(Classes())
          ForEach Classes()
            If Classes()\mangledName = parentMangledName
              foundParent = #True
              Break
            EndIf
          Next
          
          If foundParent
            If UCase(superMethod) = "INIT"
              If ListSize(Classes()\InitConstructors()) > 1
                Protected argCount.i = 0
                Protected callSig.s = GetCallArgSignature(superArgList, @argCount)
                Protected bestMatch.s = ""
                ForEach Classes()\InitConstructors()
                  If Classes()\InitConstructors()\signature = callSig
                    bestMatch = Classes()\InitConstructors()\initProcMangled
                    Break
                  ElseIf argCount >= Classes()\InitConstructors()\minParamCount And argCount <= Classes()\InitConstructors()\paramCount
                    bestMatch = Classes()\InitConstructors()\initProcMangled
                  EndIf
                Next
                If bestMatch <> ""
                  callTarget = bestMatch
                Else
                  FirstElement(Classes()\InitConstructors())
                  callTarget = Classes()\InitConstructors()\initProcMangled
                EndIf
              ElseIf ListSize(Classes()\InitConstructors()) = 1
                FirstElement(Classes()\InitConstructors())
                callTarget = Classes()\InitConstructors()\initProcMangled
              Else
                callTarget = parentMangledName + "_Init"
              EndIf
            Else
              ; Method overloading check on parent
              Protected mCount.i = 0
              ForEach Classes()\Methods()
                If UCase(Classes()\Methods()\name) = UCase(superMethod)
                  mCount + 1
                EndIf
              Next
              If mCount > 1
                Protected mArgCount.i = 0
                Protected mCallSig.s = GetCallArgSignature(superArgList, @mArgCount)
                ForEach Classes()\Methods()
                  If UCase(Classes()\Methods()\name) = UCase(superMethod) And Classes()\Methods()\signature = mCallSig
                    callTarget = parentMangledName + "_" + Classes()\Methods()\mangledMethodName
                    Break
                  EndIf
                Next
                If callTarget = ""
                  callTarget = parentMangledName + "_" + superMethod
                EndIf
              Else
                callTarget = parentMangledName + "_" + superMethod
              EndIf
            EndIf
          Else
            callTarget = parentMangledName + "_" + superMethod
          EndIf
          PopListPosition(Classes())
          
          Protected beforeSuper.s = Left(res, pSuper - 1)
          Protected afterClose.s = Mid(res, pClose + 1)
          
          If superArgList = ""
            res = beforeSuper + callTarget + "(*This)" + afterClose
          Else
            res = beforeSuper + callTarget + "(*This, " + superArgList + ")" + afterClose
          EndIf
        Else
          Break
        EndIf
      Else
        Break
      EndIf
      pSuper = FindString(res, "Super::")
      If pSuper = 0
        pSuper = FindString(res, "Super\")
      EndIf
    Wend
  EndIf

  res = TranspileMainLine(res)

  ; 2. Replace This\Method(args) with *This_vt\Method(args)
  If FindMapElement(ClassMap(), UCase(className))
    PushListPosition(Classes())
    SelectElement(Classes(), ClassMap(UCase(className)))
    ForEach Classes()\VTableSlots()
      Protected mSlotName.s = Classes()\VTableSlots()\methodName
      If mSlotName <> ""
        res = ReplaceString(res, "This\" + mSlotName + "(", "*This_vt\" + mSlotName + "(")
        res = ReplaceString(res, "*This\" + mSlotName + "(", "*This_vt\" + mSlotName + "(")
      EndIf
    Next
    PopListPosition(Classes())
  EndIf

  ; 3. Replace remaining 'This' with '*This'
  res = ReplaceWord(res, "This", "*This")
  res = ReplaceString(res, "*This\*", "*This\")
  res = ReplaceString(res, "*This_vt\*", "*This_vt\")
  
  ProcedureReturn res
EndProcedure

; Resolves 'New ClassName(args)' expressions to correct constructor factory
Procedure.s ResolveNewExpressions(line.s)
  Protected res.s = line
  
  PushListPosition(Classes())
  ForEach Classes()
    Protected cFull.s = Classes()\fullName
    Protected cShort.s = Classes()\name
    Protected cMangled.s = Classes()\mangledName
    Protected isMultiInit.b = Bool(ListSize(Classes()\InitConstructors()) > 1)
    
    Protected NewList searchPrefixes.s()
    AddElement(searchPrefixes()) : searchPrefixes() = "New " + cFull + "("
    AddElement(searchPrefixes()) : searchPrefixes() = "New  " + cFull + "("
    AddElement(searchPrefixes()) : searchPrefixes() = "New(" + cFull + ")"
    AddElement(searchPrefixes()) : searchPrefixes() = "New(" + cFull + ","
    
    If cShort <> cFull
      AddElement(searchPrefixes()) : searchPrefixes() = "New " + cShort + "("
      AddElement(searchPrefixes()) : searchPrefixes() = "New  " + cShort + "("
      AddElement(searchPrefixes()) : searchPrefixes() = "New(" + cShort + ")"
      AddElement(searchPrefixes()) : searchPrefixes() = "New(" + cShort + ","
    EndIf
    
    ForEach searchPrefixes()
      Protected prefix.s = searchPrefixes()
      Protected pNew.i = FindString(res, prefix)
      
      While pNew > 0
        Protected pOpen.i = FindString(res, "(", pNew)
        If pOpen > 0
          Protected pClose.i = 0
          Protected i.i, depth.i = 1, inQuote.b = #False
          Protected lenR.i = Len(res)
          
          For i = pOpen + 1 To lenR
            Protected ch.s = Mid(res, i, 1)
            If ch = Chr(34)
              inQuote = ~inQuote & 1
            ElseIf ch = "(" And Not inQuote
              depth + 1
            ElseIf ch = ")" And Not inQuote
              depth - 1
              If depth = 0
                pClose = i
                Break
              EndIf
            EndIf
          Next
          
          If pClose > pOpen
            Protected argList.s = Trim(Mid(res, pOpen + 1, pClose - pOpen - 1))
            If Left(prefix, 4) = "New(" And FindString(prefix, ",") > 0
              Protected pFirstComma.i = FindString(argList, ",")
              If pFirstComma > 0
                argList = Trim(Mid(argList, pFirstComma + 1))
              EndIf
            EndIf
            Protected argCount.i = 0
            Protected callSig.s = GetCallArgSignature(argList, @argCount)
            Protected chosenFactory.s = "New_" + cMangled
            
            If isMultiInit
              Protected bestMatch.s = ""
              ForEach Classes()\InitConstructors()
                If Classes()\InitConstructors()\signature = callSig
                  bestMatch = Classes()\InitConstructors()\mangledName
                  Break
                ElseIf argCount >= Classes()\InitConstructors()\minParamCount And argCount <= Classes()\InitConstructors()\paramCount
                  bestMatch = Classes()\InitConstructors()\mangledName
                EndIf
              Next
              If bestMatch <> ""
                chosenFactory = bestMatch
              Else
                FirstElement(Classes()\InitConstructors())
                chosenFactory = Classes()\InitConstructors()\mangledName
              EndIf
            EndIf
            
            Protected beforeNew.s = Left(res, pNew - 1)
            Protected afterClose.s = Mid(res, pClose + 1)
            res = beforeNew + chosenFactory + "(" + argList + ")" + afterClose
            pNew = FindString(res, prefix, pNew + Len(chosenFactory) + 1)
            Continue
          EndIf
        EndIf
        pNew = FindString(res, prefix, pNew + Len(prefix))
      Wend
    Next
  Next
  PopListPosition(Classes())
  
  ProcedureReturn res
EndProcedure

Procedure.s TranspileMainLine(line.s)
  Protected res.s = line
  
  ; 0. Resolve Overloaded Method Calls (e.g. *m\Additionner(10, 20) -> *m\Additionner_i_i(10, 20))
  res = ResolveOverloadedMethodCalls(res)

  ; 1. Resolve Constructors (New Class(...) -> New_Class_sig(...))
  res = ResolveNewExpressions(res)

  ; 1.5 Support standalone 'Free(*obj)' syntax
  Protected trimmedForFree.s = Trim(res)
  If Left(trimmedForFree, 5) = "Free(" Or Left(trimmedForFree, 6) = "Free (" Or (Left(trimmedForFree, 5) = "Free " And FindString(trimmedForFree, "*") > 0)
    res = ReplaceWord(res, "Free", "FreeStructure")
  EndIf

  PushListPosition(Classes())
  ForEach Classes()
    Protected cFull.s = Classes()\fullName
    Protected cShort.s = Classes()\name
    Protected cMangled.s = Classes()\mangledName
    
    ; Type annotations (.ClassName -> .ClassName_vt)
    res = ReplaceString(res, "." + cFull + " ", "." + cMangled + "_vt ")
    res = ReplaceString(res, "." + cFull + "=", "." + cMangled + "_vt =")
    res = ReplaceString(res, "." + cFull + ",", "." + cMangled + "_vt,")
    res = ReplaceString(res, "." + cFull + ")", "." + cMangled + "_vt)")
    res = ReplaceString(res, "." + cFull + "(", "." + cMangled + "_vt(")
    res = ReplaceString(res, "." + cFull + "\", "." + cMangled + "_vt\")
    If Right(res, Len("." + cFull)) = "." + cFull
      res = Left(res, Len(res) - Len("." + cFull)) + "." + cMangled + "_vt"
    EndIf

    ; Check Alias references
    ForEach NamespaceAliases()
      Protected aKey.s = MapKey(NamespaceAliases())
      Protected aTarget.s = NamespaceAliases()
      If Classes()\namespace = aTarget
        Protected aFull.s = aKey + "::" + cShort
        res = ReplaceString(res, "New " + aFull + "(", "New_" + cMangled + "(")
        res = ReplaceString(res, "New(" + aFull + ",", "New_" + cMangled + "(")
        res = ReplaceString(res, "New(" + aFull + ")", "New_" + cMangled + "()")
        res = ReplaceString(res, "." + aFull + " ", "." + cMangled + "_vt ")
        res = ReplaceString(res, "." + aFull + "=", "." + cMangled + "_vt =")
        res = ReplaceString(res, "." + aFull + ",", "." + cMangled + "_vt,")
        res = ReplaceString(res, "." + aFull + ")", "." + cMangled + "_vt)")
      EndIf
    Next

    ; Replace ShortName if in UsingList or root
    Protected canUseShort.b = #False
    If Classes()\namespace = ""
      canUseShort = #True
    Else
      ForEach UsingList()
        If UCase(UsingList()) = UCase(Classes()\namespace)
          canUseShort = #True
          Break
        EndIf
      Next
    EndIf

    If canUseShort
      res = ReplaceString(res, "New(" + cShort + ",", "New_" + cMangled + "(")
      res = ReplaceString(res, "New(" + cShort + ")", "New_" + cMangled + "()")
      res = ReplaceString(res, "New( " + cShort + ",", "New_" + cMangled + "(")
      res = ReplaceString(res, "New( " + cShort + " )", "New_" + cMangled + "()")
      res = ReplaceString(res, "New " + cShort + "(", "New_" + cMangled + "(")
      res = ReplaceString(res, "New  " + cShort + "(", "New_" + cMangled + "(")
      
      res = ReplaceString(res, "." + cShort + " ", "." + cMangled + "_vt ")
      res = ReplaceString(res, "." + cShort + "=", "." + cMangled + "_vt =")
      res = ReplaceString(res, "." + cShort + ",", "." + cMangled + "_vt,")
      res = ReplaceString(res, "." + cShort + ")", "." + cMangled + "_vt)")
      res = ReplaceString(res, "." + cShort + "(", "." + cMangled + "_vt(")
      res = ReplaceString(res, "." + cShort + "\", "." + cMangled + "_vt\")
      If Right(res, Len("." + cShort)) = "." + cShort
        res = Left(res, Len(res) - Len("." + cShort)) + "." + cMangled + "_vt"
      EndIf
    EndIf
  Next
  PopListPosition(Classes())
  
  ; Protect PureBasic Modules with :: so they are not broken by :: -> _
  res = ReplaceString(res, "DatabaseEngine::", "@@MOD_DBENGINE@@")
  res = ReplaceString(res, "DatabaseEntities::", "@@MOD_DBENTITIES@@")
  res = ReplaceString(res, "Database::", "@@MOD_DB@@")
  res = ReplaceString(res, "EntitySet::", "@@MOD_ENTITYSET@@")
  res = ReplaceString(res, "ORM::", "@@MOD_ORM@@")
  res = ReplaceString(res, "ORM_Schema::", "@@MOD_ORMSCHEMA@@")
  res = ReplaceString(res, "ORM_CRUD::", "@@MOD_ORMCRUD@@")
  res = ReplaceString(res, "ORM_Relations::", "@@MOD_ORMREL@@")
  res = ReplaceString(res, "ORM_Entity::", "@@MOD_ORMENTITY@@")
  res = ReplaceString(res, "ORM_Transaction::", "@@MOD_ORMTRANS@@")
  res = ReplaceString(res, "ORM_Lock::", "@@MOD_ORMLOCK@@")
  res = ReplaceString(res, "UI::", "@@MOD_UI@@")
  res = ReplaceString(res, "MVVM::", "@@MOD_MVVM@@")

  res = ReplaceString(res, "::", "_")

  res = ReplaceString(res, "@@MOD_DBENGINE@@", "DatabaseEngine::")
  res = ReplaceString(res, "@@MOD_DBENTITIES@@", "DatabaseEntities::")
  res = ReplaceString(res, "@@MOD_DB@@", "Database::")
  res = ReplaceString(res, "@@MOD_ENTITYSET@@", "EntitySet::")
  res = ReplaceString(res, "@@MOD_ORM@@", "ORM::")
  res = ReplaceString(res, "@@MOD_ORMSCHEMA@@", "ORM_Schema::")
  res = ReplaceString(res, "@@MOD_ORMCRUD@@", "ORM_CRUD::")
  res = ReplaceString(res, "@@MOD_ORMREL@@", "ORM_Relations::")
  res = ReplaceString(res, "@@MOD_ORMENTITY@@", "ORM_Entity::")
  res = ReplaceString(res, "@@MOD_ORMTRANS@@", "ORM_Transaction::")
  res = ReplaceString(res, "@@MOD_ORMLOCK@@", "ORM_Lock::")
  res = ReplaceString(res, "@@MOD_UI@@", "UI::")
  res = ReplaceString(res, "@@MOD_MVVM@@", "MVVM::")
  
  ProcedureReturn res
EndProcedure

Procedure EmitLine(content.s, srcLine.i = 0, srcFile.s = "")
  AddElement(GeneratedLines())
  GeneratedLines()\content = content
  GeneratedLines()\srcLineNumber = srcLine
  GeneratedLines()\srcFile = srcFile
EndProcedure

Procedure EmitEntityRegistration()
  Protected hasEntity.b = #False
  ForEach Classes()
    If Classes()\isDatabaseEntity : hasEntity = #True : Break : EndIf
  Next
  If Not hasEntity : ProcedureReturn : EndIf

  EmitLine("; " + RSet("", 76, "-"))
  EmitLine("; 5.5 ORM ENTITY SERIALIZATION, DESERIALIZATION & REGISTRATION")
  EmitLine("; " + RSet("", 76, "-"))
  EmitLine("")

  ; Emit Serialization, Deserialization, and CascadeSave helpers for each entity
  ForEach Classes()
    Protected *c.OOP_Class = @Classes()
    If *c\isDatabaseEntity
      Protected cMangled.s = *c\mangledName
      Protected tblName.s = LCase(*c\name) + "s"

      ; 1. Serialization
      EmitLine("Procedure " + cMangled + "_Serialize(*This." + cMangled + "_Inst, Map values.s())")
      EmitLine("  ClearMap(values())")
      ForEach *c\Fields()
        Protected fDecl.s = *c\Fields()\name
        Protected numItems.i = CountString(fDecl, ",") + 1
        Protected fIdx.i
        For fIdx = 1 To numItems
          Protected item.s = Trim(StringField(fDecl, fIdx, ","))
          If item = "" : Continue : EndIf
          Protected pDot.i = FindString(item, ".")
          Protected baseName.s = item
          Protected typeCode.s = "s"
          If pDot > 0
            baseName = Trim(Left(item, pDot - 1))
            typeCode = LCase(Trim(Mid(item, pDot + 1)))
          EndIf
          If baseName = "id" Or baseName = "orm_isDirty" Or baseName = "orm_isNew" : Continue : EndIf
          
          Protected isRel.b = #False
          ForEach *c\Relations()
            If *c\Relations()\propertyName = baseName : isRel = #True : Break : EndIf
          Next
          If isRel : Continue : EndIf

          Select typeCode
            Case "s"
              EmitLine("  values(" + Chr(34) + baseName + Chr(34) + ") = *This\" + baseName)
            Case "f", "d"
              EmitLine("  values(" + Chr(34) + baseName + Chr(34) + ") = StrF(*This\" + baseName + ")")
            Default
              EmitLine("  values(" + Chr(34) + baseName + Chr(34) + ") = Str(*This\" + baseName + ")")
          EndSelect
        Next
      Next
      EmitLine("EndProcedure")
      EmitLine("")

      ; 2. Deserialization
      EmitLine("Procedure " + cMangled + "_Deserialize(*This." + cMangled + "_Inst, Map values.s())")
      EmitLine("  If FindMapElement(values(), " + Chr(34) + "id" + Chr(34) + ") : *This\id = Val(values()) : EndIf")
      ForEach *c\Fields()
        fDecl = *c\Fields()\name
        numItems = CountString(fDecl, ",") + 1
        For fIdx = 1 To numItems
          item = Trim(StringField(fDecl, fIdx, ","))
          If item = "" : Continue : EndIf
          pDot = FindString(item, ".")
          baseName = item
          typeCode = "s"
          If pDot > 0
            baseName = Trim(Left(item, pDot - 1))
            typeCode = LCase(Trim(Mid(item, pDot + 1)))
          EndIf
          If baseName = "id" Or baseName = "orm_isDirty" Or baseName = "orm_isNew" : Continue : EndIf
          
          isRel = #False
          ForEach *c\Relations()
            If *c\Relations()\propertyName = baseName : isRel = #True : Break : EndIf
          Next
          If isRel : Continue : EndIf

          Select typeCode
            Case "s"
              EmitLine("  If FindMapElement(values(), " + Chr(34) + baseName + Chr(34) + ") : *This\" + baseName + " = values() : EndIf")
            Case "f", "d"
              EmitLine("  If FindMapElement(values(), " + Chr(34) + baseName + Chr(34) + ") : *This\" + baseName + " = ValF(values()) : EndIf")
            Default
              EmitLine("  If FindMapElement(values(), " + Chr(34) + baseName + Chr(34) + ") : *This\" + baseName + " = Val(values()) : EndIf")
          EndSelect
        Next
      Next
      EmitLine("EndProcedure")
      EmitLine("")

      ; 3. SaveChildren procs for each relation
      ForEach *c\Relations()
        Protected *r.OOP_Relation = @*c\Relations()
        Protected relProcName.s = cMangled + "_SaveChildren_" + *r\propertyName
        EmitLine("Procedure " + relProcName + "(*This." + cMangled + "_Inst, db.i)")
        EmitLine("  Protected targetDb.DatabaseEngine::IDatabase = Database::WrapHandle(db)")
        EmitLine("  If Not targetDb : targetDb = Database::GetDefault() : EndIf")
        EmitLine("  If Not targetDb : ProcedureReturn : EndIf")

        If *r\relationType = #ORM_Rel_OneToMany
          ; HasMany
          EmitLine("  If *This\" + *r\propertyName)
          EmitLine("    Protected count.i = *This\" + *r\propertyName + "\Count()")
          EmitLine("    Protected i.i")
          EmitLine("    For i = 0 To count - 1")
          EmitLine("      Protected item.DatabaseEntities::IDatabaseEntity = *This\" + *r\propertyName + "\Get(i)")
          EmitLine("      If item")
          Protected targetClsMangled.s = MangleIdentifier(*r\targetClass)
          EmitLine("        Protected *itemInst." + targetClsMangled + "_Inst = item")
          EmitLine("        *itemInst\" + *r\foreignKey + " = *This\id")
          EmitLine("        item\Save(targetDb)")
          EmitLine("      EndIf")
          EmitLine("    Next")
          If *r\cascade = #Cascade_Delete Or *r\cascade = #Cascade_All
            EmitLine("    count = *This\" + *r\propertyName + "\GetRemovedCount()")
            EmitLine("    For i = 0 To count - 1")
            EmitLine("      Protected remItem.DatabaseEntities::IDatabaseEntity = *This\" + *r\propertyName + "\GetRemovedItem(i)")
            EmitLine("      If remItem : remItem\Delete(targetDb) : EndIf")
            EmitLine("    Next")
          EndIf
          EmitLine("    *This\" + *r\propertyName + "\ResetTracking()")
          EmitLine("  EndIf")

        ElseIf *r\relationType = #ORM_Rel_ManyToMany
          ; ManyToMany
          EmitLine("  If *This\" + *r\propertyName + " And *This\id > 0")
          EmitLine("    ORM_Relations::SyncManyToManyLinks(db, " + Chr(34) + *r\joinTable + Chr(34) + ", " + Chr(34) + *r\parentFk + Chr(34) + ", *This\id, " + Chr(34) + *r\childFk + Chr(34) + ", *This\" + *r\propertyName + ")")
          EmitLine("  EndIf")
        EndIf

        EmitLine("EndProcedure")
        EmitLine("")
      Next

    EndIf
  Next

  ; 4. Register_All_Entities procedure
  EmitLine("Procedure Register_All_Entities()")
  EmitLine("  NewList currentFields.ORM_Schema::ORM_FieldDef()")
  EmitLine("  NewList currentRelations.ORM_Schema::ORM_RelationDef()")
  EmitLine("")
  ForEach Classes()
    *c = @Classes()
    If *c\isDatabaseEntity
      cMangled = *c\mangledName
      tblName = LCase(*c\name) + "s"

      EmitLine("  ; Register entity " + *c\name)
      EmitLine("  ClearList(currentFields())")
      EmitLine("  ClearList(currentRelations())")

      ForEach *c\Fields()
        fDecl = *c\Fields()\name
        numItems = CountString(fDecl, ",") + 1
        For fIdx = 1 To numItems
          item = Trim(StringField(fDecl, fIdx, ","))
          If item = "" : Continue : EndIf
          pDot = FindString(item, ".")
          baseName = item
          typeCode = "s"
          If pDot > 0
            baseName = Trim(Left(item, pDot - 1))
            typeCode = LCase(Trim(Mid(item, pDot + 1)))
          EndIf
          If baseName = "id" Or baseName = "orm_isDirty" Or baseName = "orm_isNew" : Continue : EndIf
          
          isRel = #False
          ForEach *c\Relations()
            If *c\Relations()\propertyName = baseName : isRel = #True : Break : EndIf
          Next
          If isRel : Continue : EndIf

          Protected ormTypeConst.s = "ORM_Entity::#ORM_Type_String"
          Select typeCode
            Case "s" : ormTypeConst = "ORM_Entity::#ORM_Type_String"
            Case "i", "l", "q" : ormTypeConst = "ORM_Entity::#ORM_Type_Integer"
            Case "b" : ormTypeConst = "ORM_Entity::#ORM_Type_Bool"
            Case "f", "d" : ormTypeConst = "ORM_Entity::#ORM_Type_Double"
          EndSelect

          EmitLine("  AddElement(currentFields()) : currentFields()\name = " + Chr(34) + baseName + Chr(34) + " : currentFields()\typeCode = " + ormTypeConst)
        Next
      Next

      ForEach *c\Relations()
        *r = @*c\Relations()
        Protected relTypeConst.s = "ORM_Entity::#ORM_Rel_OneToMany"
        If *r\relationType = #ORM_Rel_ManyToMany
          relTypeConst = "ORM_Entity::#ORM_Rel_ManyToMany"
        ElseIf *r\relationType = #ORM_Rel_ManyToOne
          relTypeConst = "ORM_Entity::#ORM_Rel_ManyToOne"
        ElseIf *r\relationType = #ORM_Rel_OneToOne
          relTypeConst = "ORM_Entity::#ORM_Rel_OneToOne"
        EndIf

        EmitLine("  AddElement(currentRelations())")
        EmitLine("  currentRelations()\relationType = " + relTypeConst)
        EmitLine("  currentRelations()\propertyName = " + Chr(34) + *r\propertyName + Chr(34))
        EmitLine("  currentRelations()\childEntityType = " + Chr(34) + *r\targetClass + Chr(34))
        EmitLine("  currentRelations()\childTable = " + Chr(34) + LCase(*r\targetClass) + "s" + Chr(34))
        EmitLine("  currentRelations()\fkColumn = " + Chr(34) + *r\foreignKey + Chr(34))
        EmitLine("  currentRelations()\joinTable = " + Chr(34) + *r\joinTable + Chr(34))
        EmitLine("  currentRelations()\parentFkColumn = " + Chr(34) + *r\parentFk + Chr(34))
        EmitLine("  currentRelations()\childFkColumn = " + Chr(34) + *r\childFk + Chr(34))
        EmitLine("  currentRelations()\cascadeSave = #True")
        EmitLine("  currentRelations()\saveChildrenProc = @" + cMangled + "_SaveChildren_" + *r\propertyName + "()")
      Next

      EmitLine("  ORM_Schema::RegisterEntity(" + Chr(34) + *c\name + Chr(34) + ", " + Chr(34) + tblName + Chr(34) + ", currentFields(), currentRelations(), @" + cMangled + "_Serialize(), @" + cMangled + "_Deserialize(), @New_" + cMangled + "(), #True)")
      EmitLine("")
    EndIf
  Next
  EmitLine("EndProcedure")
  EmitLine("")
EndProcedure

Procedure.b GenerateTargetPB(outputFile.s, inputPBO.s)
  ClearList(GeneratedLines())

  EmitLine("; ============================================================================")
  EmitLine("; Generated by PureBasic OOP Transpiler (Native OOP Engine - ALPHA 1.2)")
  EmitLine("; Do not edit directly - modify the corresponding .pbo source file.")
  EmitLine("; ============================================================================")
  EmitLine("")
  EmitLine("EnableExplicit")
  EmitLine("")

  ; Project and Workspace directory constants for runtime resource location
  Protected projDirConst.s = BaseDirectory
  If projDirConst = "" : projDirConst = GetCurrentDirectory() : EndIf
  If Right(projDirConst, 1) <> "\" : projDirConst + "\" : EndIf
  EmitLine("#OOP_PROJECT_DIR = " + Chr(34) + projDirConst + Chr(34))
  EmitLine("#OOP_WORKSPACE_DIR = " + Chr(34) + GetCurrentDirectory() + Chr(34))
  EmitLine("")

  Protected hasEntity.b = #False
  ForEach Classes()
    If Classes()\isDatabaseEntity : hasEntity = #True : Break : EndIf
  Next
  If hasEntity
    EmitLine("; PureBasic OOP Framework - Database & ORM Engine Integration")
    EmitLine("XIncludeFile #OOP_WORKSPACE_DIR + " + Chr(34) + "framework/database/ORM.pbi" + Chr(34))
    EmitLine("UseModule Database")
    EmitLine("UseModule DatabaseEngine")
    EmitLine("UseModule DatabaseEntities")
    EmitLine("UseModule EntitySet")
    EmitLine("UseModule ORM_Schema")
    EmitLine("")
  EndIf

  ; 0.5 Generate Top-Level Type Declarations (Structures, Enums, Constants, Macros)
  EmitLine("; " + RSet("", 76, "-"))
  EmitLine("; 0.5 GLOBAL TYPE DECLARATIONS, STRUCTURES & CONSTANTS")
  EmitLine("; " + RSet("", 76, "-"))
  EmitLine("")
  ForEach TypeDeclarations()
    EmitLine(TranspileMainLine(TypeDeclarations()\content), TypeDeclarations()\srcLineNumber, TypeDeclarations()\srcFile)
  Next
  EmitLine("")

  ; 1. Generate Interfaces
  EmitLine("; " + RSet("", 76, "-"))
  EmitLine("; 1. PUREBASIC INTERFACES (VTABLE PROTOTYPES)")
  EmitLine("; " + RSet("", 76, "-"))
  EmitLine("")

  ForEach Classes()
    Protected *c.OOP_Class = @Classes()
    If *c\mangledParentName <> ""
      EmitLine("Interface " + *c\mangledName + "_vt Extends " + *c\mangledParentName + "_vt", *c\srcLineNumber, *c\srcFile)
    ElseIf *c\isDatabaseEntity
      EmitLine("Interface " + *c\mangledName + "_vt Extends DatabaseEntities::IDatabaseEntity", *c\srcLineNumber, *c\srcFile)
    Else
      EmitLine("Interface " + *c\mangledName + "_vt", *c\srcLineNumber, *c\srcFile)
    EndIf

    ForEach *c\Methods()
      Protected *m.OOP_Method = @*c\Methods()
      If *m\visibility <> "Private" And UCase(*m\name) <> "INIT"
        If *c\isDatabaseEntity And *c\mangledParentName = ""
          Protected uMN.s = UCase(*m\name)
          If uMN = "GETID" Or uMN = "SETID" Or uMN = "ISDIRTY" Or uMN = "SETDIRTY" Or uMN = "ISNEW" Or uMN = "SETNEW" Or uMN = "SAVE" Or uMN = "DELETE" Or uMN = "RELOAD" Or uMN = "GETTABLENAME" Or uMN = "GETENTITYNAME"
            Continue
          EndIf
        EndIf
        If *c\mangledParentName = "" Or Not *m\isOverride
          EmitLine("  " + *m\mangledMethodName + *m\returnType + "(" + TranspileMainLine(*m\cleanParams) + ")", *m\srcLineNumber, *m\srcFile)
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
    If *c\mangledParentName <> ""
      EmitLine("Structure " + *c\mangledName + "_Inst Extends " + *c\mangledParentName + "_Inst", *c\srcLineNumber, *c\srcFile)
    Else
      EmitLine("Structure " + *c\mangledName + "_Inst", *c\srcLineNumber, *c\srcFile)
      EmitLine("  *VTable." + *c\mangledName + "_vt")
    EndIf

    ForEach *c\Fields()
      Protected fDecl.s = *c\Fields()\name
      Protected numItems.i = CountString(fDecl, ",") + 1
      Protected fIdx.i
      For fIdx = 1 To numItems
        Protected item.s = Trim(StringField(fDecl, fIdx, ","))
        If item <> ""
          EmitLine("  " + TranspileMainLine(item), *c\Fields()\srcLineNumber, *c\Fields()\srcFile)
        EndIf
      Next
    Next

    EmitLine("EndStructure")
    EmitLine("")
  Next

  ; 2.5 Generate Global Variables, Maps, Lists & Declarations
  EmitLine("; " + RSet("", 76, "-"))
  EmitLine("; 2.5 GLOBAL VARIABLES, MAPS, LISTS & FORWARD DECLARATIONS")
  EmitLine("; " + RSet("", 76, "-"))
  EmitLine("")
  ForEach HeaderDeclarations()
    EmitLine(TranspileMainLine(HeaderDeclarations()\content), HeaderDeclarations()\srcLineNumber, HeaderDeclarations()\srcFile)
  Next
  EmitLine("")

  If hasEntity
    ForEach Classes()
      If Classes()\isDatabaseEntity
        Protected clsMang.s = Classes()\mangledName
        EmitLine("Declare " + clsMang + "_Serialize(*This." + clsMang + "_Inst, Map values.s())")
        EmitLine("Declare " + clsMang + "_Deserialize(*This." + clsMang + "_Inst, Map values.s())")
        ForEach Classes()\Relations()
          EmitLine("Declare " + clsMang + "_SaveChildren_" + Classes()\Relations()\propertyName + "(*This." + clsMang + "_Inst, db.i)")
        Next
      EndIf
    Next
    EmitLine("Declare Register_All_Entities()")
    EmitLine("")
  EndIf

  ; 3. Generate Method Procedures (Forward Declares & Implementations)
  EmitLine("; " + RSet("", 76, "-"))
  EmitLine("; 3. METHOD PROCEDURES IMPLEMENTATION")
  EmitLine("; " + RSet("", 76, "-"))
  EmitLine("")

  ForEach MethodBodies()
    Protected *b.OOP_MethodBody = @MethodBodies()
    Protected pDecl.s = ""
    If *b\cleanParams <> ""
      pDecl = "*This." + *b\mangledClassName + "_Inst, " + TranspileMainLine(*b\cleanParams)
    Else
      pDecl = "*This." + *b\mangledClassName + "_Inst"
    EndIf

    EmitLine("Declare" + *b\returnType + " " + *b\mangledClassName + "_" + *b\mangledMethodName + "(" + pDecl + ")", *b\srcLineNumber, *b\srcFile)
  Next
  EmitLine("")

  ; Constructors & Free forward declarations
  ForEach Classes()
    *c = @Classes()
    If Not *c\isAbstract
      If ListSize(*c\InitConstructors()) > 1
        ForEach *c\InitConstructors()
          If *c\InitConstructors()\cleanParams <> ""
            EmitLine("Declare.i " + *c\InitConstructors()\mangledName + "(" + TranspileMainLine(*c\InitConstructors()\cleanParams) + ")", *c\srcLineNumber, *c\srcFile)
          Else
            EmitLine("Declare.i " + *c\InitConstructors()\mangledName + "()", *c\srcLineNumber, *c\srcFile)
          EndIf
        Next
      ElseIf ListSize(*c\InitConstructors()) = 1
        FirstElement(*c\InitConstructors())
        If *c\InitConstructors()\cleanParams <> ""
          EmitLine("Declare.i " + *c\InitConstructors()\mangledName + "(" + TranspileMainLine(*c\InitConstructors()\cleanParams) + ")", *c\srcLineNumber, *c\srcFile)
        Else
          EmitLine("Declare.i " + *c\InitConstructors()\mangledName + "()", *c\srcLineNumber, *c\srcFile)
        EndIf
      Else
        EmitLine("Declare.i New_" + *c\mangledName + "()", *c\srcLineNumber, *c\srcFile)
      EndIf
      EmitLine("Declare Free_" + *c\mangledName + "(*obj." + *c\mangledName + "_Inst)", *c\srcLineNumber, *c\srcFile)
    EndIf
  Next
  EmitLine("")

  ; Method Procedures Bodies
  ForEach MethodBodies()
    *b = @MethodBodies()
    If *b\cleanParams <> ""
      pDecl = "*This." + *b\mangledClassName + "_Inst, " + TranspileMainLine(*b\cleanParams)
    Else
      pDecl = "*This." + *b\mangledClassName + "_Inst"
    EndIf

    EmitLine("Procedure" + *b\returnType + " " + *b\mangledClassName + "_" + *b\mangledMethodName + "(" + pDecl + ")", *b\srcLineNumber, *b\srcFile)
    EmitLine("  Protected *This_vt." + *b\mangledClassName + "_vt = *This", *b\srcLineNumber, *b\srcFile)
    
    Protected parentMangled.s = ""
    If FindMapElement(ClassMap(), UCase(*b\className))
      PushListPosition(Classes())
      SelectElement(Classes(), ClassMap(UCase(*b\className)))
      parentMangled = Classes()\mangledParentName
      PopListPosition(Classes())
    EndIf

    ForEach *b\BodyLines()
      Protected transformedLine.s = TranspileMethodBodyLine(*b\BodyLines()\content, *b\className, parentMangled)
      EmitLine("  " + transformedLine, *b\BodyLines()\srcLineNumber, *b\BodyLines()\srcFile)
    Next

    EmitLine("EndProcedure")
    EmitLine("")
  Next

  ; 4. Generate VTables DataSections
  EmitLine("; " + RSet("", 76, "-"))
  EmitLine("; 4. VTABLE DATASECTIONS (DYNAMIC DISPATCH)")
  EmitLine("; " + RSet("", 76, "-"))
  EmitLine("")

  EmitLine("DataSection")
  ForEach Classes()
    *c = @Classes()
    If Not *c\isAbstract
      EmitLine("  " + *c\mangledName + "_VTable_Data:", *c\srcLineNumber, *c\srcFile)
      ForEach *c\VTableSlots()
        Protected slotImpl.s = *c\VTableSlots()\implementingClass
        Protected slotMangled.s = MangleIdentifier(slotImpl)
        EmitLine("    Data.i @" + slotMangled + "_" + *c\VTableSlots()\methodName + "()", *c\VTableSlots()\srcLineNumber, *c\VTableSlots()\srcFile)
      Next
    EndIf
  Next
  EmitLine("EndDataSection")
  EmitLine("")

  ; 5. Generate Constructors & Destructors
  EmitLine("; " + RSet("", 76, "-"))
  EmitLine("; 5. CONSTRUCTORS & FACTORY FUNCTIONS")
  EmitLine("; " + RSet("", 76, "-"))
  EmitLine("")

  ForEach Classes()
    *c = @Classes()
    If Not *c\isAbstract
      If ListSize(*c\InitConstructors()) > 0
        ForEach *c\InitConstructors()
          Protected initArgDecl.s = TranspileMainLine(*c\InitConstructors()\cleanParams)
          Protected initArgPass.s = ""
          If initArgDecl <> ""
            Protected pCount.i = CountString(initArgDecl, ",") + 1
            Protected pIdx.i
            For pIdx = 1 To pCount
              Protected paramToken.s = Trim(StringField(initArgDecl, pIdx, ","))
              Protected pDot.i = FindString(paramToken, ".")
              If pDot > 0
                paramToken = Left(paramToken, pDot - 1)
              EndIf
              If initArgPass = ""
                initArgPass = paramToken
              Else
                initArgPass + ", " + paramToken
              EndIf
            Next
          EndIf

          If initArgDecl <> ""
            EmitLine("Procedure.i " + *c\InitConstructors()\mangledName + "(" + initArgDecl + ")", *c\srcLineNumber, *c\srcFile)
          Else
            EmitLine("Procedure.i " + *c\InitConstructors()\mangledName + "()", *c\srcLineNumber, *c\srcFile)
          EndIf
          
          EmitLine("  Protected *obj." + *c\mangledName + "_Inst = AllocateStructure(" + *c\mangledName + "_Inst)", *c\srcLineNumber, *c\srcFile)
          EmitLine("  If *obj", *c\srcLineNumber, *c\srcFile)
          EmitLine("    *obj\VTable = ?" + *c\mangledName + "_VTable_Data", *c\srcLineNumber, *c\srcFile)
          If *c\isDatabaseEntity
            EmitLine("    *obj\orm_isNew = #True", *c\srcLineNumber, *c\srcFile)
            EmitLine("    *obj\orm_isDirty = #False", *c\srcLineNumber, *c\srcFile)
            ForEach *c\Relations()
              If *c\Relations()\relationType = #ORM_Rel_OneToMany Or *c\Relations()\relationType = #ORM_Rel_ManyToMany
                EmitLine("    *obj\" + *c\Relations()\propertyName + " = EntitySet::New()", *c\srcLineNumber, *c\srcFile)
              EndIf
            Next
          EndIf
          If initArgPass <> ""
            EmitLine("    " + *c\InitConstructors()\initProcMangled + "(*obj, " + initArgPass + ")", *c\srcLineNumber, *c\srcFile)
          Else
            EmitLine("    " + *c\InitConstructors()\initProcMangled + "(*obj)", *c\srcLineNumber, *c\srcFile)
          EndIf
          EmitLine("  EndIf", *c\srcLineNumber, *c\srcFile)
          EmitLine("  ProcedureReturn *obj", *c\srcLineNumber, *c\srcFile)
          EmitLine("EndProcedure")
          EmitLine("")
        Next
      Else
        ; Default parameterless constructor
        EmitLine("Procedure.i New_" + *c\mangledName + "()", *c\srcLineNumber, *c\srcFile)
        EmitLine("  Protected *obj." + *c\mangledName + "_Inst = AllocateStructure(" + *c\mangledName + "_Inst)", *c\srcLineNumber, *c\srcFile)
        EmitLine("  If *obj", *c\srcLineNumber, *c\srcFile)
        EmitLine("    *obj\VTable = ?" + *c\mangledName + "_VTable_Data", *c\srcLineNumber, *c\srcFile)
        If *c\isDatabaseEntity
          EmitLine("    *obj\orm_isNew = #True", *c\srcLineNumber, *c\srcFile)
          EmitLine("    *obj\orm_isDirty = #False", *c\srcLineNumber, *c\srcFile)
          ForEach *c\Relations()
            If *c\Relations()\relationType = #ORM_Rel_OneToMany Or *c\Relations()\relationType = #ORM_Rel_ManyToMany
              EmitLine("    *obj\" + *c\Relations()\propertyName + " = EntitySet::New()", *c\srcLineNumber, *c\srcFile)
            EndIf
          Next
        EndIf
        EmitLine("  EndIf", *c\srcLineNumber, *c\srcFile)
        EmitLine("  ProcedureReturn *obj", *c\srcLineNumber, *c\srcFile)
        EmitLine("EndProcedure")
        EmitLine("")
      EndIf

      ; Free wrapper
      EmitLine("Procedure Free_" + *c\mangledName + "(*obj." + *c\mangledName + "_Inst)", *c\srcLineNumber, *c\srcFile)
      EmitLine("  If *obj", *c\srcLineNumber, *c\srcFile)
      If *c\isDatabaseEntity
        ForEach *c\Relations()
          If *c\Relations()\relationType = #ORM_Rel_OneToMany Or *c\Relations()\relationType = #ORM_Rel_ManyToMany
            EmitLine("    If *obj\" + *c\Relations()\propertyName + " : *obj\" + *c\Relations()\propertyName + "\Free() : EndIf", *c\srcLineNumber, *c\srcFile)
          EndIf
        Next
      EndIf
      If *c\hasFree
        Protected callFreeMangled.s = *c\mangledName
        If *c\freeClassMangled <> ""
          callFreeMangled = *c\freeClassMangled
        EndIf
        EmitLine("    " + callFreeMangled + "_Free(*obj)", *c\srcLineNumber, *c\srcFile)
      EndIf
      EmitLine("    FreeStructure(*obj)", *c\srcLineNumber, *c\srcFile)
      EmitLine("  EndIf", *c\srcLineNumber, *c\srcFile)
      EmitLine("EndProcedure")
      EmitLine("")
    EndIf
  Next

  ; Emit Entity Registration & Helpers (Serialize, Deserialize, SaveChildren)
  EmitEntityRegistration()

  ; 6. Generate Main Program Execution
  EmitLine("; " + RSet("", 76, "-"))
  EmitLine("; 6. MAIN PROGRAM EXECUTION")
  EmitLine("; " + RSet("", 76, "-"))
  EmitLine("")

  If hasEntity
    EmitLine("Register_All_Entities()")
    EmitLine("")
  EndIf

  ForEach MainLines()
    Protected transpiledMain.s = TranspileMainLine(MainLines()\content)
    EmitLine(transpiledMain, MainLines()\srcLineNumber, MainLines()\srcFile)
  Next

  ; Write output file
  Protected outFile = CreateFile(#PB_Any, outputFile)
  If Not outFile
    SetOOPError(1, "Cannot create output file: " + outputFile)
    ProcedureReturn #False
  EndIf
  WriteStringFormat(outFile, #PB_UTF8)

  ; Write .map file
  Protected mapFile.s = outputFile + ".map"
  Protected fMap = CreateFile(#PB_Any, mapFile)
  If fMap
    WriteStringFormat(fMap, #PB_UTF8)
    WriteStringN(fMap, "# PBO_SOURCEMAP_V1", #PB_UTF8)
    WriteStringN(fMap, "SOURCE:" + inputPBO, #PB_UTF8)
    WriteStringN(fMap, "TARGET:" + outputFile, #PB_UTF8)
    WriteStringN(fMap, "MAP:", #PB_UTF8)
  EndIf

  Protected genLineNum.i = 0
  ForEach GeneratedLines()
    genLineNum + 1
    WriteStringN(outFile, GeneratedLines()\content, #PB_UTF8)
    If fMap And GeneratedLines()\srcLineNumber > 0
      WriteStringN(fMap, Str(genLineNum) + ":" + Str(GeneratedLines()\srcLineNumber), #PB_UTF8)
    EndIf
  Next

  CloseFile(outFile)
  If fMap : CloseFile(fMap) : EndIf

  ProcedureReturn #True
EndProcedure

; ----------------------------------------------------------------------------
; Transpiler Orchestration
; ----------------------------------------------------------------------------

Procedure.b TranspileSourceFile(inputFile.s, outputFile.s)
  If Not ParsePBO(inputFile)
    ProcedureReturn #False
  EndIf

  If Not BuildVTables()
    ProcedureReturn #False
  EndIf

  If Not ValidateOOPModel()
    ProcedureReturn #False
  EndIf

  If Not CheckMemoryLeaks()
    ProcedureReturn #False
  EndIf

  If Not GenerateTargetPB(outputFile, inputFile)
    ProcedureReturn #False
  EndIf

  ProcedureReturn #True
EndProcedure

Procedure.b CheckSourceFileSyntax(inputFile.s)
  If Not ParsePBO(inputFile)
    ProcedureReturn #False
  EndIf

  If Not BuildVTables()
    ProcedureReturn #False
  EndIf

  If Not ValidateOOPModel()
    ProcedureReturn #False
  EndIf

  If Not CheckMemoryLeaks()
    ProcedureReturn #False
  EndIf

  ProcedureReturn #True
EndProcedure

; ----------------------------------------------------------------------------
; Main Entry Point (CLI)
Procedure.i Main()
  OpenConsole()

  Protected argCount.i = CountProgramParameters()
  Protected i.i = 0
  Protected checkMode.b = #False
  Protected checkFile.s = ""
  Protected inputPBO.s = ""
  Protected outputPB.s = ""
  
  While i < argCount
    Protected param.s = ProgramParameter(i)
    If UCase(param) = "--BASE-DIR" Or UCase(param) = "-B"
      i + 1
      If i < argCount
        BaseDirectory = ProgramParameter(i)
        If FindString(LCase(BaseDirectory), "temp\") > 0
          BaseDirectory = ""
        EndIf
        If BaseDirectory <> "" And Right(BaseDirectory, 1) <> "\"
          BaseDirectory + "\"
        EndIf
      EndIf
    ElseIf UCase(param) = "--CHECK" Or UCase(param) = "-C" Or UCase(param) = "/CHECK"
      checkMode = #True
      i + 1
      If i < argCount
        checkFile = ProgramParameter(i)
      EndIf
    ElseIf UCase(param) = "--STRICT-LEAKS"
      StrictLeaks = #True
    Else
      If inputPBO = ""
        inputPBO = param
      ElseIf outputPB = ""
        outputPB = param
      EndIf
    EndIf
    i + 1
  Wend

  If checkMode
    If checkFile = "" : checkFile = inputPBO : EndIf
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

  If BaseDirectory = "" Or FindString(LCase(BaseDirectory), "temp\") > 0
    If inputPBO <> "" And FindString(LCase(inputPBO), "temp\") = 0
      BaseDirectory = GetPathPart(inputPBO)
    Else
      BaseDirectory = GetCurrentDirectory()
    EndIf
  EndIf
  If BaseDirectory <> "" And Right(BaseDirectory, 1) <> "\"
    BaseDirectory + "\"
  EndIf

  If inputPBO = ""
    inputPBO = "../src/test_overloading.pbo"
    outputPB = "../src/test_overloading_generated.pb"
  EndIf

  If outputPB = ""
    outputPB = ReplaceString(inputPBO, ".pbo", "_generated.pb", #PB_String_NoCase)
  EndIf
  PrintN("=================================================================")
  PrintN("   PureBasic OOP Transpiler (Native Engine) - ALPHA 1.2 (Overload)")
  PrintN("=================================================================")
  PrintN("Input  PBO : " + inputPBO)
  PrintN("Output PB  : " + outputPB)
  If BaseDirectory <> ""
    PrintN("Base Dir   : " + BaseDirectory)
  EndIf
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
