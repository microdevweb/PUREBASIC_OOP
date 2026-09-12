; =============================================================================
; EntitySet.pbi - Generic Collection for 1-N and N-N ORM Relationships
; PureBasic OOP Framework - ORM Engine v2.0
; =============================================================================

XIncludeFile "IDatabaseEntity.pbi"

DeclareModule EntitySet

  UseModule DatabaseEngine
  UseModule DatabaseEntities

  Interface IEntitySet
    Add(*entity)
    Remove(*entity)
    Clear()
    Count.i()
    Get.i(index.i)
    Contains.b(*entity)
    
    IsLoaded.b()
    SetLoaded(loaded.b)
    IsDirty.b()
    SetDirty(dirty.b)
    
    ; Tracking pour la persistance (insertions/suppressions de liaisons)
    GetAddedCount.i()
    GetAddedItem.i(index.i)
    GetRemovedCount.i()
    GetRemovedItem.i(index.i)
    ResetTracking()
    
    Free()
  EndInterface

  Declare.i New()

EndDeclareModule

Module EntitySet

  Structure _EntitySet_Internal
    *vTable
    List items.i()
    List addedItems.i()
    List removedItems.i()
    isLoaded.b
    isDirty.b
  EndStructure

  Procedure Add(*this._EntitySet_Internal, *entity)
    If Not *entity : ProcedureReturn : EndIf
    ForEach *this\items()
      If *this\items() = *entity
        ProcedureReturn
      EndIf
    Next
    
    AddElement(*this\items())
    *this\items() = *entity
    
    AddElement(*this\addedItems())
    *this\addedItems() = *entity
    *this\isDirty = #True
  EndProcedure

  Procedure Remove(*this._EntitySet_Internal, *entity)
    If Not *entity : ProcedureReturn : EndIf
    ForEach *this\items()
      If *this\items() = *entity
        DeleteElement(*this\items())
        AddElement(*this\removedItems())
        *this\removedItems() = *entity
        *this\isDirty = #True
        Break
      EndIf
    Next
  EndProcedure

  Procedure Clear(*this._EntitySet_Internal)
    ForEach *this\items()
      AddElement(*this\removedItems())
      *this\removedItems() = *this\items()
    Next
    ClearList(*this\items())
    *this\isDirty = #True
  EndProcedure

  Procedure.i Count(*this._EntitySet_Internal)
    ProcedureReturn ListSize(*this\items())
  EndProcedure

  Procedure.i Get(*this._EntitySet_Internal, index.i)
    If SelectElement(*this\items(), index)
      ProcedureReturn *this\items()
    EndIf
    ProcedureReturn 0
  EndProcedure

  Procedure.b Contains(*this._EntitySet_Internal, *entity)
    ForEach *this\items()
      If *this\items() = *entity
        ProcedureReturn #True
      EndIf
    Next
    ProcedureReturn #False
  EndProcedure

  Procedure.b IsLoaded(*this._EntitySet_Internal)
    ProcedureReturn *this\isLoaded
  EndProcedure

  Procedure SetLoaded(*this._EntitySet_Internal, loaded.b)
    *this\isLoaded = loaded
  EndProcedure

  Procedure.b IsDirty(*this._EntitySet_Internal)
    ProcedureReturn *this\isDirty
  EndProcedure

  Procedure SetDirty(*this._EntitySet_Internal, dirty.b)
    *this\isDirty = dirty
  EndProcedure

  Procedure.i GetAddedCount(*this._EntitySet_Internal)
    ProcedureReturn ListSize(*this\addedItems())
  EndProcedure

  Procedure.i GetAddedItem(*this._EntitySet_Internal, index.i)
    If SelectElement(*this\addedItems(), index)
      ProcedureReturn *this\addedItems()
    EndIf
    ProcedureReturn 0
  EndProcedure

  Procedure.i GetRemovedCount(*this._EntitySet_Internal)
    ProcedureReturn ListSize(*this\removedItems())
  EndProcedure

  Procedure.i GetRemovedItem(*this._EntitySet_Internal, index.i)
    If SelectElement(*this\removedItems(), index)
      ProcedureReturn *this\removedItems()
    EndIf
    ProcedureReturn 0
  EndProcedure

  Procedure ResetTracking(*this._EntitySet_Internal)
    ClearList(*this\addedItems())
    ClearList(*this\removedItems())
    *this\isDirty = #False
  EndProcedure

  Procedure Free(*this._EntitySet_Internal)
    ClearList(*this\items())
    ClearList(*this\addedItems())
    ClearList(*this\removedItems())
    FreeStructure(*this)
  EndProcedure

  ; VTable
  DataSection
    EntitySet_VTable:
      Data.i @Add()
      Data.i @Remove()
      Data.i @Clear()
      Data.i @Count()
      Data.i @Get()
      Data.i @Contains()
      Data.i @IsLoaded()
      Data.i @SetLoaded()
      Data.i @IsDirty()
      Data.i @SetDirty()
      Data.i @GetAddedCount()
      Data.i @GetAddedItem()
      Data.i @GetRemovedCount()
      Data.i @GetRemovedItem()
      Data.i @ResetTracking()
      Data.i @Free()
  EndDataSection

  Procedure.i New()
    Protected *obj._EntitySet_Internal = AllocateStructure(_EntitySet_Internal)
    *obj\vTable = ?EntitySet_VTable
    *obj\isLoaded = #True
    *obj\isDirty = #False
    ProcedureReturn *obj
  EndProcedure

EndModule
