OpenConsole()
prg = RunProgram("compiler\transpiler.exe", "--check src\test_endcla.pb", "", #PB_Program_Open | #PB_Program_Read | #PB_Program_Hide)
If prg
  While ProgramRunning(prg)
    While AvailableProgramOutput(prg)
      PrintN("READ: " + ReadProgramString(prg))
    Wend
    Delay(5)
  Wend
  While AvailableProgramOutput(prg)
    PrintN("READ: " + ReadProgramString(prg))
  Wend
  PrintN("EXIT CODE: " + Str(ProgramExitCode(prg)))
  CloseProgram(prg)
Else
  PrintN("FAILED TO RUN PROGRAM")
EndIf
CloseConsole()
