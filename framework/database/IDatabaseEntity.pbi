; =============================================================================
; IDatabaseEntity.pbi - Persistable Entity Interface
; PureBasic OOP Framework - ORM Engine v2.0
; =============================================================================

XIncludeFile "IDatabase.pbi"

DeclareModule DatabaseEntities

  UseModule DatabaseEngine

  Interface IDatabaseEntity
    GetId.i()
    SetId(id.i)
    
    IsDirty.b()
    SetDirty(dirty.b)
    
    IsNew.b()
    SetNew(isNew.b)
    
    Save.b(db.IDatabase = 0)
    Delete.b(db.IDatabase = 0)
    Reload.b(db.IDatabase = 0)
    
    GetTableName.s()
    GetEntityName.s()
  EndInterface

EndDeclareModule

Module DatabaseEntities
EndModule
