; ============================================================================
; Application Gestionnaire de Taches (TodoApp) - Vue Fenetre Declarative XML
; File: views/MainWindow.pbi
; ============================================================================

XIncludeFile "../constants/AppConstants.pbi"
XIncludeFile "../viewmodels/TaskViewModel.pbi"

Namespace TodoApp {

  Class MainWindow Extends UI::Window {

    Public Method Init(*vm.TodoApp::TaskViewModel) {
      Super\Init()
      
      Protected xml.s
      xml + "<Window Title='Todo Manager - PureBasic OOP MVVM' Width='580' Height='450'>"
      xml + "  <DockPanel LastChildFill='true'>"
      
      ; --- 1. En-tete (Dock Top) ---
      xml + "    <StackPanel Dock='Top' Orientation='Vertical' Margin='15,10,15,5' Spacing='4'>"
      xml + "      <Label Text='My Reactive Todo Manager' Height='24'/>"
      xml + "      <Label Text='Demonstration PureBasic OOP MVVM Architecture' Height='18'/>"
      xml + "    </StackPanel>"
      
      ; --- 2. Pied de page / Statut (Dock Bottom) ---
      xml + "    <StackPanel Dock='Bottom' Orientation='Horizontal' Margin='15,8' Height='24'>"
      xml + "      <Label Text='{Binding " + #PROP_STATUS_MSG + "}' Width='550' Height='20'/>"
      xml + "    </StackPanel>"
      
      ; --- 3. Corps Principal (Dock Fill) ---
      xml + "    <StackPanel Dock='Fill' Orientation='Vertical' Spacing='8' Margin='15,10'>"
      
      ; Zone de saisie
      xml + "      <Label Text='New task title:' Height='18'/>"
      xml + "      <TextBox Text='{Binding " + #PROP_TASK_TITLE + ", Mode=TwoWay}' Height='28'/>"
      
      ; Boutons d'action
      xml + "      <StackPanel Orientation='Horizontal' Spacing='10' Height='34'>"
      xml + "        <Button Text='Add Task' Click='" + #CMD_ADD_TASK + "' Width='150' Height='32'/>"
      xml + "        <Button Text='Tout Effacer'     Click='" + #CMD_CLEAR_ALL + "' Width='120' Height='32'/>"
      xml + "      </StackPanel>"
      
      ; Compteur & Liste
      xml + "      <Label Text='Total tasks: {Binding " + #PROP_TASK_COUNT + "}' Margin='0,6,0,0' Height='20'/>"
      xml + "      <TextBox Text='{Binding " + #PROP_LIST_CONTENT + "}' Height='160'/>"
      
      xml + "    </StackPanel>"
      xml + "  </DockPanel>"
      xml + "</Window>"
      
      ; Chargement et DataBinding automatique
      This\LoadViewFromString(xml, *vm)
    }
  }

}
