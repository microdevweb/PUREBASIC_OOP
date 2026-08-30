; ============================================================================
; Title:       ide_builder.pb
; Description: Pipeline de Transpilation et Compilation F5 avec affichage console
; Author:      Expert PureBasic OOP
; ============================================================================

EnableExplicit

XIncludeFile "../config/ide_settings.pb"

Prototype IDE_LogCallback(message.s, isError.b)

Procedure.s IDE_FindPBCompiler()
  ; 1. Vérifier si le chemin configuré est valide
  If FileSize(Settings\CompilerPath) > 0
    ProcedureReturn Settings\CompilerPath
  EndIf
  
  ; 2. Vérifier les emplacements standards PureBasic sous Windows
  Protected standardPath1.s = "C:\Program Files\PureBasic\Compilers\pbcompiler.exe"
  Protected standardPath2.s = "C:\Program Files (x86)\PureBasic\Compilers\pbcompiler.exe"
  Protected standardPath3.s = GetPathPart(ProgramFilename()) + "..\..\..\Compilers\pbcompiler.exe"
  
  If FileSize(standardPath1) > 0 : ProcedureReturn standardPath1 : EndIf
  If FileSize(standardPath2) > 0 : ProcedureReturn standardPath2 : EndIf
  If FileSize(standardPath3) > 0 : ProcedureReturn standardPath3 : EndIf
  
  ; 3. Recherche dans le PATH système
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

Procedure.b IDE_BuildAndRun(sourceCode.s, currentFilePath.s, *logCb.IDE_LogCallback)
  Protected workspaceDir.s = GetCurrentDirectory()
  Protected transpilerPath.s = workspaceDir + "compiler\transpiler.pb"
  Protected compilerExe.s = IDE_FindPBCompiler()
  
  If *logCb
    *logCb("[BUILD] Démarrage du pipeline de compilation PureBasic OOP...", #False)
  EndIf
  
  ; 1. Fichiers temporaires pour le build
  Protected tempDir.s = GetTemporaryDirectory()
  Protected tempPBO.s = tempDir + "pbo_build_temp.pbo"
  Protected tempPB.s  = tempDir + "pbo_build_temp.pb"
  Protected tempEXE.s = tempDir + "pbo_build_temp.exe"
  
  ; Sauvegarde du code source actuel dans le fichier temporaire
  Protected file = CreateFile(#PB_Any, tempPBO)
  If Not file
    If *logCb : *logCb("[ERREUR] Impossible de créer le fichier temporaire : " + tempPBO, #True) : EndIf
    ProcedureReturn #False
  EndIf
  WriteString(file, sourceCode, #PB_UTF8)
  CloseFile(file)
  
  If *logCb
    *logCb("[TRANSPILER] Conversion du code POO (.pbo) vers PureBasic natif (.pb)...", #False)
  EndIf
  
  ; 2. Exécution du Transpileur
  ; Si on dispose de pbcompiler, on exécute transpiler.pb
  If compilerExe = ""
    If *logCb
      *logCb("[AVERTISSEMENT] 'pbcompiler.exe' n'a pas été trouvé. Veuillez configurer son chemin dans les Paramètres (Fichier -> Paramètres).", #True)
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
  
  ; Vérifier si le fichier .pb transpilé existe
  If FileSize(tempPB) <= 0
    If *logCb : *logCb("[ERREUR] Échec de la transpilation. Le fichier cible .pb n'a pas été généré.", #True) : EndIf
    ProcedureReturn #False
  EndIf
  
  If *logCb
    *logCb("[COMPILER] Compilation native avec pbcompiler.exe...", #False)
  EndIf
  
  ; 3. Compilation avec PureBasic Compiler
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
        If *logCb : *logCb("[PBCOMPILER ERREUR] " + errLog, #True) : EndIf
      EndIf
      Delay(10)
    Wend
    CloseProgram(compProg)
  EndIf
  
  If FileSize(tempEXE) <= 0
    If *logCb : *logCb("[ERREUR] Échec de la compilation binaire. Voir les détails ci-dessus.", #True) : EndIf
    ProcedureReturn #False
  EndIf
  
  ; 4. Exécution de l'application compilée
  If *logCb
    *logCb("[RUN] Lancement de l'exécutable généré : " + tempEXE, #False)
  EndIf
  
  RunProgram(tempEXE, "", GetPathPart(currentFilePath))
  ProcedureReturn #True
EndProcedure
