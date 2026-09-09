Procedure.d TestDouble(*this)
  ProcedureReturn 80.62
EndProcedure

Procedure.f TestFloat(*this)
  ProcedureReturn 175.10
EndProcedure

Procedure TestCall()
  Protected *fnD = @TestDouble()
  CallFunctionFast(*fnD, 0)
  Protected dVal.d
  !movsd [p.v_dVal], xmm0

  Protected *fnF = @TestFloat()
  CallFunctionFast(*fnF, 0)
  Protected fVal.f
  !movss [p.v_fVal], xmm0

  OpenConsole()
  PrintN("dVal: " + StrD(dVal, 2))
  PrintN("fVal: " + StrF(fVal, 2))
  CloseConsole()
EndProcedure

TestCall()
