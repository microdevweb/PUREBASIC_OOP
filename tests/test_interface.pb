DeclareModule Core
  Interface IChild
    GetName.s()
  EndInterface

  Interface IParent
    GetChild.i()
  EndInterface
EndDeclareModule

Module Core
EndModule

Structure Child_Inst
  *vTable
  name.s
EndStructure

Structure Parent_Inst
  *vTable
  child.Child_Inst
EndStructure

Procedure.s Child_GetName(*this.Child_Inst)
  ProcedureReturn *this\name
EndProcedure

Procedure.i Parent_GetChild(*this.Parent_Inst)
  ProcedureReturn @*this\child
EndProcedure

DataSection
  Child_VT:
    Data.i @Child_GetName()
  Parent_VT:
    Data.i @Parent_GetChild()
EndDataSection

Define p.Parent_Inst
p\vTable = ?Parent_VT
p\child\vTable = ?Child_VT
p\child\name = "Baby"

Define *parent.Core::IParent = @p
Define *child.Core::IChild = *parent\GetChild()

OpenConsole()
PrintN("Child name: " + *child\GetName())
CloseConsole()
