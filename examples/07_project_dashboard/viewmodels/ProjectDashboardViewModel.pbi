; ============================================================================
; Project Dashboard (WPF Modern UI) - ViewModel MVVM Réactif
; Fichier : viewmodels/ProjectDashboardViewModel.pbi
; ============================================================================

XIncludeFile "../models/ProjectModel.pbi"

Namespace Dashboard {

  Class ProjectDashboardViewModel Extends MVVM::ViewModelBase {
    Public *model.Dashboard::ProjectModel
    
    ; Propri�t�s Observables DataBound à l'interface
    Public *ProjectName.MVVM::StringProperty
    Public *StartDate.MVVM::StringProperty
    Public *EndDate.MVVM::StringProperty
    Public *Priority.MVVM::StringProperty
    Public *Status.MVVM::StringProperty
    Public *Description.MVVM::StringProperty
    Public *SearchQuery.MVVM::StringProperty
    Public *StatusNotification.MVVM::StringProperty
    Public *ActiveNavTab.MVVM::StringProperty

    Public Method Init() {
      Super\Init()

      This\*model = New Dashboard::ProjectModel()

      ; Enregistrement des propri�t�s observables
      This\*ProjectName        = This\BindString("ProjectName", This\*model\GetName())
      This\*StartDate          = This\BindString("StartDate", This\*model\GetStartDate())
      This\*EndDate            = This\BindString("EndDate", This\*model\GetEndDate())
      This\*Priority           = This\BindString("Priority", This\*model\GetPriority())
      This\*Status             = This\BindString("Status", This\*model\GetStatus())
      This\*Description        = This\BindString("Description", This\*model\GetDescription())
      This\*SearchQuery        = This\BindString("SearchQuery", "")
      This\*StatusNotification = This\BindString("StatusNotification", "Prêt.")
      This\*ActiveNavTab       = This\BindString("ActiveNavTab", "Projects")
    }

    Public Method Free() {
      If This\*model
        This\*model\Free()
        This\*model = 0
      EndIf
      Super\Free()
    }

    ; --- Traitement des Commandes UI (RelayCommands) ---
    Public Method.b OnCommand(cmdName.s, *param = 0) {
      Select cmdName
        ; Action : Enregistrer les modifications
        Case "CmdSaveChanges"
          Protected pName.s = Trim(This\*ProjectName\GetValue())
          If pName = ""
            This\*StatusNotification\SetValue("⚠ Le nom du projet ne peut pas être vide.")
            ProcedureReturn #True
          EndIf
          
          This\*model\SetName(pName)
          This\*model\SetStartDate(This\*StartDate\GetValue())
          This\*model\SetEndDate(This\*EndDate\GetValue())
          This\*model\SetDescription(This\*Description\GetValue())
          This\*StatusNotification\SetValue("✔ Projet '" + pName + "' enregistré avec succès.")
          ProcedureReturn #True

        ; Action : Annuler les modifications
        Case "CmdCancel"
          This\*ProjectName\SetValue(This\*model\GetName())
          This\*StartDate\SetValue(This\*model\GetStartDate())
          This\*EndDate\SetValue(This\*model\GetEndDate())
          This\*Description\SetValue(This\*model\GetDescription())
          This\*StatusNotification\SetValue("↩ Modifications annulées.")
          ProcedureReturn #True

        ; Action : Supprimer le projet
        Case "CmdDelete"
          This\*ProjectName\SetValue("")
          This\*StartDate\SetValue("")
          This\*EndDate\SetValue("")
          This\*Description\SetValue("")
          This\*StatusNotification\SetValue("🗑 Donn�es du projet r�initialis�es.")
          ProcedureReturn #True

        ; Action : Ajouter un nouveau projet
        Case "CmdAddProject"
          This\*ProjectName\SetValue("Nouveau Projet")
          This\*StartDate\SetValue("01/01/2027")
          This\*EndDate\SetValue("30/06/2027")
          This\*Description\SetValue("Nouveau projet initialisé...")
          This\*StatusNotification\SetValue("✨ Nouveau modèle de projet créé.")
          ProcedureReturn #True

        ; Action : Générer un rapport
        Case "CmdGenerateReport"
          Protected curName.s = This\*ProjectName\GetValue()
          This\*StatusNotification\SetValue("📊 Rapport synthétique généré pour '" + curName + "'.")
          ProcedureReturn #True

        ; Actions : Navigation Sidebar
        Case "CmdNavDashboard"
          This\*ActiveNavTab\SetValue("Dashboard")
          This\*StatusNotification\SetValue("Navigation : Vue Dashboard.")
          ProcedureReturn #True

        Case "CmdNavProjects"
          This\*ActiveNavTab\SetValue("Projects")
          This\*StatusNotification\SetValue("Navigation : Vue Projets.")
          ProcedureReturn #True

        Case "CmdNavTasks"
          This\*ActiveNavTab\SetValue("Tasks")
          This\*StatusNotification\SetValue("Navigation : Vue Tâches.")
          ProcedureReturn #True

        Case "CmdNavAnalytics"
          This\*ActiveNavTab\SetValue("Analytics")
          This\*StatusNotification\SetValue("Navigation : Vue Statistiques & Analytics.")
          ProcedureReturn #True

        Case "CmdNavSettings"
          This\*ActiveNavTab\SetValue("Settings")
          This\*StatusNotification\SetValue("Navigation : Vue Paramètres.")
          ProcedureReturn #True

      EndSelect

      ProcedureReturn #False
    }
  }

}

; IDE Options = PureBasic 6.40 (Windows - x64)
; CursorPosition = 81
; FirstLine = 63
; EnableXP
; DPIAware