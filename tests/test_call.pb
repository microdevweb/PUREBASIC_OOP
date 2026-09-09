OpenConsole()
Structure Person
  name.s
EndStructure

Procedure SetName(*p.Person, val.s)
  *p\name = val
EndProcedure

Global p.Person
*fnSet = @SetName()
newVal.s = "André Dupond"
CallFunctionFast(*fnSet, @p, @newVal)
PrintN("Result: " + p\name)
CloseConsole()
