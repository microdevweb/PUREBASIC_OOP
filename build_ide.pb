; ============================================================================
; Title:       build_ide.pb
; Description: Automated Build Engine for PureBasic OOP IDE
; Author:      MicrodevWeb
; ============================================================================

EnableExplicit

Global PBCompilerPath.s = "C:\Program Files\PureBasic\Compilers\pbcompiler.exe"
Global IDEOfficialPath.s = GetCurrentDirectory() + "ide_official\"
Global BuildPath.s = IDEOfficialPath + "PureBasicIDE\Build\"

Procedure LogMsg(msg.s)
  PrintN("[BUILD] " + msg)
EndProcedure

Procedure RunCommandQuiet(cmd.s, args.s, workDir.s = "")
  Protected prg = RunProgram(cmd, args, workDir, #PB_Program_Open | #PB_Program_Read | #PB_Program_Hide)
  If prg
    While ProgramRunning(prg)
      Protected out.s = ReadProgramString(prg)
      If out <> "" : PrintN("  " + out) : EndIf
    Wend
    Protected exitCode = ProgramExitCode(prg)
    CloseProgram(prg)
    ProcedureReturn exitCode
  EndIf
  ProcedureReturn -1
EndProcedure

OpenConsole("PureBasic OOP IDE Build Pipeline")
LogMsg("Starting PureBasic OOP IDE compilation pipeline...")

; 1. Create Build directory if missing
If FileSize(BuildPath) <> -2
  CreateDirectory(BuildPath)
EndIf

; 2. Compile DialogCompiler
LogMsg("Compiling DialogCompiler...")
RunCommandQuiet(PBCompilerPath, Chr(34) + IDEOfficialPath + "DialogManager\DialogCompiler.pb" + Chr(34) + " /EXE " + Chr(34) + BuildPath + "DialogCompiler.exe" + Chr(34) + " /CONSOLE /QUIET")

; 3. Compile all XML dialogs
LogMsg("Generating dialog pb files from XML...")
Define dialogList.s = "Find;Grep;Goto;CompilerOptions;AddTools;About;Preferences;Templates;StructureViewer;Projects;Build;Diff;FileMonitor;History;HistoryShutdown;CreateApp;Updates"
Define i.i, dlgName.s
For i = 1 To CountString(dialogList, ";") + 1
  dlgName = StringField(dialogList, i, ";")
  RunCommandQuiet(BuildPath + "DialogCompiler.exe", Chr(34) + IDEOfficialPath + "PureBasicIDE\dialogs\" + dlgName + ".xml" + Chr(34) + " " + Chr(34) + BuildPath + dlgName + ".pb" + Chr(34))
Next

; 4. Compile makebuildinfo and generate BuildInfo.pb
LogMsg("Generating BuildInfo.pb...")
RunCommandQuiet(PBCompilerPath, Chr(34) + IDEOfficialPath + "PureBasicIDE\tools\makebuildinfo.pb" + Chr(34) + " /EXE " + Chr(34) + BuildPath + "makebuildinfo.exe" + Chr(34) + " /CONSOLE /QUIET")
RunCommandQuiet(BuildPath + "makebuildinfo.exe", Chr(34) + BuildPath + Chr(34), IDEOfficialPath + "PureBasicIDE")

; 5. Compile maketheme and package themes
LogMsg("Packaging official themes (DefaultTheme & SilkTheme)...")
RunCommandQuiet(PBCompilerPath, Chr(34) + IDEOfficialPath + "PureBasicIDE\tools\maketheme.pb" + Chr(34) + " /EXE " + Chr(34) + BuildPath + "maketheme.exe" + Chr(34) + " /CONSOLE /QUIET")
RunCommandQuiet(BuildPath + "maketheme.exe", Chr(34) + BuildPath + "DefaultTheme.zip" + Chr(34) + " " + Chr(34) + IDEOfficialPath + "PureBasicIDE\data\DefaultTheme" + Chr(34))
RunCommandQuiet(BuildPath + "maketheme.exe", Chr(34) + BuildPath + "SilkTheme.zip" + Chr(34) + " " + Chr(34) + IDEOfficialPath + "PureBasicIDE\data\SilkTheme" + Chr(34))

; 6. Compile the main PureBasic OOP IDE executable
LogMsg("Compiling final executable pbo_ide.exe...")
Define targetExe.s = GetCurrentDirectory() + "pbo_ide.exe"
Define res = RunCommandQuiet(PBCompilerPath, Chr(34) + IDEOfficialPath + "PureBasicIDE\PureBasic.pb" + Chr(34) + " /EXE " + Chr(34) + targetExe + Chr(34) + " /THREAD /UNICODE /XP /USER /DPIAWARE /ICON " + Chr(34) + IDEOfficialPath + "PureBasicIDE\data\PBLogoBig.ico" + Chr(34), IDEOfficialPath + "PureBasicIDE")

If res = 0 And FileSize(targetExe) > 0
  LogMsg("SUCCESS! PureBasic OOP IDE successfully built at: " + targetExe)
Else
  LogMsg("ERROR: Failed to compile PureBasic OOP IDE.")
EndIf

LogMsg("Done.")
End 0
