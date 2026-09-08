# Manuel de Référence PureBasic OOP - Version Alpha 1.3

Documentation officielle du transpileur Objet PureBasic, du framework d'interface graphique moderne et du moteur déclaratif MVVM (Model-View-ViewModel).

**Auteur :** MicrodevWeb  
**Version :** Alpha 1.3  
**Compatibilité :** PureBasic 6.x (Windows, Linux, macOS)  

---

## Sommaire

1. [Les Fondements de la Programmation Orientée Objet (POO)](#1-les-fondements-de-la-programmation-orientée-objet-poo)
2. [Syntaxe et Grammaire PureBasic OOP](#2-syntaxe-et-grammaire-purebasic-oop)
3. [Framework d'Interface Graphique Responsive](#3-framework-dinterface-graphique-responsive)
4. [Contrôles Vectoriels Haute Fidélité (CanvasControl)](#4-contrôles-vectoriels-haute-fidélité-canvascontrol)
5. [Moteur de Styles Déclaratifs WPF & Dictionnaires](#5-moteur-de-styles-déclaratifs-wpf--dictionnaires)
6. [Triggers Visuels & Micro-Animations 60 FPS (Easing)](#6-triggers-visuels--micro-animations-60-fps-easing)
7. [Vues Déclaratives XML & Chargeur Automatique (XMLLoader)](#7-vues-déclaratives-xml--chargeur-automatique-xmlloader)
8. [Architecture Réactive MVVM (Model-View-ViewModel)](#8-architecture-réactive-mvvm-model-view-viewmodel)
9. [Cycle de Vie Mémoire & Gestion Sans Fuite](#9-cycle-de-vie-mémoire--gestion-sans-fuite)
10. [Intégration dans l'IDE PureBasic & Fichiers Projets (.pbp)](#10-intégration-dans-lide-purebasic--fichiers-projets-pbp)

---

## 1. Les Fondements de la Programmation Orientée Objet (POO)

La Programmation Orientée Objet (POO) structure une application logicielle autour de **données** et de leurs **traitements associés**, regroupés dans des entités appelées **Objets**.

### 1.1 Classes et Objets
- **Classe** : Modèle formel ou plan définissant les champs d'état (attributs) et les comportements (méthodes).
- **Objet (Instance)** : Entité concrète allouée dynamiquement en mémoire avec `New NomClasse(...)`.

### 1.2 Encapsulation et Niveaux d'Accès
- **`Public`** : Accessible sans restriction depuis n'importe où dans le code.
- **`Protected`** : Accessible uniquement par la classe qui le déclare et par ses classes dérivées héritières.
- **`Private`** : Strictement réservé à la classe déclarante, invisible de l'extérieur et des classes dérivées.

### 1.3 Héritage (`Extends`)
L'héritage permet à une sous-classe de réutiliser, de spécialiser et d'étendre les données et méthodes d'une classe parente :
```oop
Class Animal {
  Protected nom.s
  Public Method Init(n.s) {
    This\nom = n
  }
  Public Method Parler() {
    MessageRequester("Animal", This\nom + " émet un son.")
  }
}

Class Chien Extends Animal {
  Public Method Parler() {
    MessageRequester("Chien", This\nom + " aboie : Wouf !")
  }
}
```

### 1.4 Polymorphisme & Table des Méthodes Virtuelles (VTable)
Chaque instance d'objet gère dynamiquement ses appels via une table de fonctions virtuelles (*VTable*). Les objets dérivés peuvent être manipulés de façon homogène via une référence de type parent, garantissant l'exécution de la méthode spécialisée au moment de l'exécution (*late binding*).

### 1.5 Abstraction
- **`Abstract Class`** : Classe modèle ne pouvant pas être instanciée directement.
- **`Abstract Method`** : Signature de méthode obligatoire sans implémentation dans la classe de base, devant obligatoirement être implémentée par les classes concrètes dérivées.

---

## 2. Syntaxe et Grammaire PureBasic OOP

Le transpileur PureBasic OOP convertit le code orienté objet en code procédural natif ultra-optimisé.

### 2.1 Déclaration de Classe
```oop
Namespace MonProjet {
  Class Utilisateur {
    Protected nom.s
    Protected email.s

    Public Method Init(n.s, e.s) {
      This\nom = n
      This\email = e
    }

    Public Method.s GetNom() {
      ProcedureReturn This\nom
    }
  }
}
```

### 2.2 Surcharge des Méthodes et Constructeurs (`Init`)
Plusieurs variantes d'une méthode ou d'un constructeur peuvent coexister avec des signatures de paramètres différentes :
```oop
Public Method Init() {
  Super\Init()
}
Public Method Init(titre.s) {
  Super\Init()
  This\SetTitre(titre)
}
Public Method Init(titre.s, largeur.i, hauteur.i) {
  Super\Init(largeur, hauteur)
  This\SetTitre(titre)
}
```

---

## 3. Framework d'Interface Graphique Responsive

La bibliothèque `framework/` encapsule l'intégralité des gadgets et fenêtres de PureBasic dans une hiérarchie modulaire de composants :

### 3.1 Conteneurs de Mise en Page (Layouts)
- **`UI::Layouts::StackPanel`** : Empilement linéaire séquentiel des composants visuels, horizontal ou vertical, avec espacement personnalisable (`Spacing`).
- **`UI::Layouts::DockPanel`** : Ancrage des composants sur les bordures (`Left`, `Top`, `Right`, `Bottom`), le dernier composant occupant automatiquement l'espace central restant.
- **`UI::Layouts::Grid`** : Grille matricielle responsive avec définition précise des lignes et colonnes en pixels (`120`), en dimensionnement automatique (`Auto`) ou en proportions pondérées (`*`, `2*`).

---

## 4. Contrôles Vectoriels Haute Fidélité (CanvasControl)

Nouveauté majeure d'**Alpha 1.3**, `UI::CanvasControl` est la classe de base vectorielle 2D opérant sur un `CanvasGadget()` avec double-buffering matériel natif :

- **`UI::CanvasButton`** : Bouton vectoriel avec palettes prédéfinies (Primary, Secondary, Success, Danger), icônes vectorielles et anneau de focus.
- **`UI::CanvasTextBox`** : Champ de saisie vectoriel avec texte indicatif (*placeholder*), caret clignotant fluide, mode mot de passe sécurisé et défilement horizontal automatique.
- **`UI::CanvasText`** : Rendu typographique vectoriel haute fidélité avec calcul géométrique précis et troncature automatique par points de suspension (*Ellipsis* `...`).
- **`UI::CanvasTree`** : Arborescence vectorielle interactive avec chevrons animés, cases à cocher et boutons d'action intégrés par ligne.

---

## 5. Moteur de Styles Déclaratifs WPF & Dictionnaires

Alpha 1.3 introduit la séparation totale entre le design et la logique applicative via les fichiers de styles XML (ex: `styles/Styles.xml`) :

```xml
<ResourceDictionary>
  <!-- Style Implicite ou Nommé -->
  <Style TargetType="CanvasButton" Key="PrimaryButton">
    <Setter Property="Background" Value="#4F46E5"/>
    <Setter Property="TextColor" Value="#FFFFFF"/>
    <Setter Property="CornerRadius" Value="8"/>
    <Setter Property="FontName" Value="Segoe UI"/>
    <Setter Property="FontSize" Value="10"/>

    <!-- Trigger interactif au survol de la souris -->
    <Trigger Property="IsMouseOver" Value="True">
      <Setter Property="Background" Value="#4338CA"/>
      <Setter Property="Scale" Value="1.04" Easing="Back" Duration="120"/>
    </Trigger>

    <!-- Trigger au clic enfoncé -->
    <Trigger Property="IsPressed" Value="True">
      <Setter Property="Background" Value="#3730A3"/>
      <Setter Property="Scale" Value="0.98" Easing="Cubic" Duration="80"/>
    </Trigger>
  </Style>
</ResourceDictionary>
```

---

## 6. Triggers Visuels & Micro-Animations 60 FPS (Easing)

L'interactivité moderne repose sur des transitions douces. Le moteur `UI::AnimationEngine` intègre des courbes d'amorti mathématiques sans nécessiter la moindre ligne de code impératif :
- **`Linear`** : Interpolation à vitesse constante.
- **`Cubic`** : Démarrage doux et freinage progressif.
- **`Back`** : Amorti élastique avec léger dépassement dynamique (*overshoot*).

---

## 7. Vues Déclaratives XML & Chargeur Automatique (XMLLoader)

L'interface graphique se conçoit entièrement dans des fichiers XML déclaratifs (`views/MaVue.xml`) :
```xml
<Window Title="Tableau de Bord" Width="960" Height="640">
  <DockPanel>
    <!-- Navigation Latérale Sombre -->
    <StackPanel Dock="Left" Width="220" Background="#18181B" Spacing="8" Padding="16">
      <CanvasButton Style="NavButton" Text="Accueil" Click="CmdNavHome"/>
      <CanvasButton Style="NavButtonActive" Text="Projets" Click="CmdNavProjects"/>
    </StackPanel>

    <!-- Contenu Principal -->
    <Grid Margin="24">
      <Grid.RowDefinitions>
        <RowDefinition Height="Auto"/>
        <RowDefinition Height="*"/>
      </Grid.RowDefinitions>
      <CanvasText Grid.Row="0" Text="Gestion de Projets" FontSize="16" FontBold="True"/>
      <CanvasTextBox Grid.Row="1" Style="FormInput" Text="{Binding ProjectName, Mode=TwoWay}" Placeholder="Nom du projet..."/>
    </Grid>
  </DockPanel>
</Window>
```

Le chargement se fait en une seule ligne :
```purebasic
Define *view.UI::Window = UI::XMLLoader::LoadView("views/MaVue.xml", *monViewModel)
```

---

## 8. Architecture Réactive MVVM (Model-View-ViewModel)

Le pattern **MVVM** garantit un découplage absolu entre la vue et les règles métier.

- **Modèle (`Model`)** : Structure de données pure.
- **Vue (`View`)** : Interface XML déclarative.
- **ViewModel** : Hérite de `MVVM::ViewModelBase`, expose des propriétés observables (`BindString`, `BindInt`, `BindBool`) et traite les commandes (`OnCommand`).
- **Liaison de données bidirectionnelle (`Mode=TwoWay`)** : Toute modification dans un champ met automatiquement à jour la propriété du ViewModel, et inversement.

---

## 9. Cycle de Vie Mémoire & Gestion Sans Fuite

PureBasic OOP applique une politique stricte de libération en cascade :
- L'appel à `*view\Free()` parcourt récursivement tous les conteneurs et gadgets enfants.
- L'appel à `*viewModel\Free()` libère l'intégralité des liaisons et dictionnaires de propriétés.
- L'application se termine avec **zéro fuite mémoire**.

---

## 10. Intégration dans l'IDE PureBasic & Fichiers Projets (.pbp)

Chaque exemple et application dispose d'un fichier de projet `.pbp` propre :
- Les fichiers de l'application utilisateur (`main.pb`, vues, modèles, styles) sont référencés dans le `.pbp`.
- Le framework OOP est automatiquement injecté par le transpileur lors de la compilation.
- Tous les commentaires de code applicatifs sont rédigés en anglais simplifié pur ASCII, éliminant tout conflit d'encodage (ANSI / UTF-8 / BOM) dans l'éditeur.
