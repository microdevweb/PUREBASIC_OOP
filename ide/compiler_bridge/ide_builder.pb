; ============================================================================
; Title:       ide_builder.pb
; Description: Transpilation and native F5 compilation pipeline with live console output
; Author:      MicrodevWeb
; ============================================================================

EnableExplicit

XIncludeFile "../config/ide_settings.pb"

Prototype IDE_LogCallback(message.s, isError.b)

; ----------------------------------------------------------------------------
; Procedure:   IDE_FindPBCompiler
; Purpose:     Finds valid pbcompiler.exe path from config, standard paths, or PATH
; Parameters:  None
; Return:      Path to pbcompiler.exe or empty string
; ----------------------------------------------------------------------------
Procedure.s IDE_FindPBCompiler()
  ; 1. Check user configured path
  If FileSize(Settings\CompilerPath) > 0
    ProcedureReturn Settings\CompilerPath
  EndIf
  
  ; 2. Check standard Windows PureBasic installations
  Protected standardPath1.s = "C:\Program Files\PureBasic\Compilers\pbcompiler.exe"
  Protected standardPath2.s = "C:\Program Files (x86)\PureBasic\Compilers\pbcompiler.exe"
  Protected standardPath3.s = GetPathPart(ProgramFilename()) + "..\..\..\Compilers\pbcompiler.exe"
  
  If FileSize(standardPath1) > 0 : ProcedureReturn standardPath1 : EndIf
  If FileSize(standardPath2) > 0 : ProcedureReturn standardPath2 : EndIf
  If FileSize(standardPath3) > 0 : ProcedureReturn standardPath3 : EndIf
  
  ; 3. Search system PATH environment variable
  Protected envPath.s = GetEnvironmentVariable("PATH")
  Protected i.i, dirCount = CountString(envPath, ";") + 1, dir.s
  For i = 1 To dirCount
    dir = StringField(envPath, i, ";")
    If FileSize(dir + "\pbcompiler.exe") > 0
      ProcedureReturn dir + "\pbcompiler.exe"
    EndIf
  Next
  
  ProcedureReturn ""
EndProcedure

; ----------------------------------------------------------------------------
; Procedure:   IDE_BuildAndRun
; Purpose:     Transpiles .pbo to .pb, compiles with pbcompiler, and executes binary
; Parameters:  sourceCode.s       - Editor source text buffer
;              currentFilePath.s  - Path of active document
;              *logCb             - Callback procedure for console logging
; Return:      #True on success, #False on error
; ----------------------------------------------------------------------------
Procedure.b IDE_BuildAndRun(sourceCode.s, currentFilePath.s, *logCb.IDE_LogCallback)
  Protected workspaceDir.s = GetCurrentDirectory()
  Protected transpilerPath.s = workspaceDir + "compiler\transpiler.pb"
  Protected compilerExe.s = IDE_FindPBCompiler()
  
  If *logCb
    *logCb("[BUILD] Starting PureBasic OOP build pipeline...", #False)
  EndIf
  
  ; 1. Setup temporary build file paths
  Protected tempDir.s = GetTemporaryDirectory()
  Protected tempPBO.s = tempDir + "pbo_build_temp.pbo"
  Protected tempPB.s  = tempDir + "pbo_build_temp.pb"
  Protected tempEXE.s = tempDir + "pbo_build_temp.exe"
  
  ; Save active editor source into temporary file
  Protected file = CreateFile(#PB_Any, tempPBO)
  If Not file
    If *logCb : *logCb("[ERROR] Cannot create temporary file: " + tempPBO, #True) : EndIf
    ProcedureReturn #False
  EndIf
  WriteString(file, sourceCode, #PB_UTF8)
  CloseFile(file)
  
  If *logCb
    *logCb("[TRANSPILER] Converting OOP code (.pbo) to native PureBasic (.pb)...", #False)
  EndIf
  
  ; 2. Run OOP Transpiler
  If compilerExe = ""
    If *logCb
      *logCb("[WARNING] 'pbcompiler.exe' was not found. Please set compiler path in File -> Settings.", #True)
    EndIf
    ProcedureReturn #False
  EndIf
  
  Protected transpileCmd.s = #DQUOTE$ + transpilerPath + #DQUOTE$ + " /P " + #DQUOTE$ + tempPBO + #DQUOTE$ + " " + #DQUOTE$ + tempPB + #DQUOTE$
  Protected transProg = RunProgram(compilerExe, transpileCmd, workspaceDir, #PB_Program_Open | #PB_Program_Read | #PB_Program_Hide)
  
  If transProg
    While ProgramRunning(transProg)
      If AvailableProgramOutput(transProg)
        Protected transLog.s = ReadProgramString(transProg)
        If *logCb : *logCb("[TRANSPILER] " + transLog, #False) : EndIf
      EndIf
      Delay(10)
    Wend
    CloseProgram(transProg)
  EndIf
  
  ; Verify generated .pb file
  If FileSize(tempPB) <= 0
    If *logCb : *logCb("[ERROR] Transpilation failed. Target .pb file was not produced.", #True) : EndIf
    ProcedureReturn #False
  EndIf
  
  If *logCb
    *logCb("[COMPILER] Compiling binary with pbcompiler.exe...", #False)
  EndIf
  
  ; 3. Compile with native PureBasic compiler
  Protected compileParams.s = #DQUOTE$ + tempPB + #DQUOTE$ + " /EXE " + #DQUOTE$ + tempEXE + #DQUOTE$ + " /CONSOLE"
  Protected compProg = RunProgram(compilerExe, compileParams, workspaceDir, #PB_Program_Open | #PB_Program_Read | #PB_Program_Error | #PB_Program_Hide)
  Protected compError.b = #False
  
  If compProg
    While ProgramRunning(compProg)
      If AvailableProgramOutput(compProg)
        Protected compLog.s = ReadProgramString(compProg)
        If *logCb : *logCb("[PBCOMPILER] " + compLog, #False) : EndIf
      EndIf
      Protected errLog.s = ReadProgramError(compProg)
      If errLog <> ""
        compError = #True
        If *logCb : *logCb("[PBCOMPILER ERROR] " + errLog, #True) : EndIf
      EndIf
      Delay(10)
    Wend
    CloseProgram(compProg)
  EndIf
  
  If FileSize(tempEXE) <= 0
    If *logCb : *logCb("[ERROR] Binary compilation failed. See output logs above.", #True) : EndIf
    ProcedureReturn #False
  EndIf
  
  ; 4. Execute compiled binary
  If *logCb
    *logCb("[RUN] Launching executable: " + tempEXE, #False)
  EndIf
  
  RunProgram(tempEXE, "", GetPathPart(currentFilePath))
  ProcedureReturn #True
EndProcedure
