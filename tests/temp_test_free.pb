Interface TestInterface
  Afficher()
  Free()
EndInterface

Structure Test_Inst
  *VTable.TestInterface
EndStructure

Procedure Test_Afficher(*This)
EndProcedure

Procedure Test_Free(*This)
EndProcedure

DataSection
  VTable:
    Data.i @Test_Afficher()
    Data.i @Test_Free()
EndDataSection

Define *inst.Test_Inst = AllocateStructure(Test_Inst)
*inst\VTable = ?VTable
Define *obj.TestInterface = *inst
*obj\Afficher()
*obj\Free()
