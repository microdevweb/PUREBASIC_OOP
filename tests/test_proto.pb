Prototype.f Proto_GetF(*dataContext)
Prototype.d Proto_GetD(*dataContext)

Procedure.f MyF(*dummy)
  ProcedureReturn 175.10
EndProcedure

Procedure.d MyD(*dummy)
  ProcedureReturn 80.62
EndProcedure

Define fnF.Proto_GetF = @MyF()
Define fnD.Proto_GetD = @MyD()

OpenConsole()
PrintN("Float: " + StrF(fnF(0), 2))
PrintN("Double: " + StrD(fnD(0), 2))
CloseConsole()
