Structure DataObj
  f.f
  d.d
EndStructure

Procedure SetMyDouble(*this.DataObj, val.d)
  *this\d = val
EndProcedure

Procedure SetMyFloat(*this.DataObj, val.f)
  *this\f = val
EndProcedure

Procedure TestSetter()
  Protected obj.DataObj
  Protected *fnSetD = @SetMyDouble()
  Protected valD.d = 99.45
  !movsd xmm1, [p.v_valD]
  CallFunctionFast(*fnSetD, @obj, 0)

  Protected *fnSetF = @SetMyFloat()
  Protected valF.f = 123.45
  !movss xmm1, [p.v_valF]
  CallFunctionFast(*fnSetF, @obj, 0)

  OpenConsole()
  PrintN("Set d: " + StrD(obj\d, 2))
  PrintN("Set f: " + StrF(obj\f, 2))
  CloseConsole()
EndProcedure

TestSetter()
