; ============================================================================
; PureBasic OOP - Manuel de Référence (Français)
; Documentation officielle du transpileur et du framework GUI OOP
; Author:      MicrodevWeb
; ============================================================================

# Manuel de Référence PureBasic OOP (Français)

Bienvenue dans la documentation officielle du transpileur et du framework Orienté Objet pour PureBasic.

---

## 1. Les Fondements de la Programmation Orientée Objet (POO)

La Programmation Orientée Objet (POO) est un paradigme de programmation qui structure une application autour de **données** et de **traitements associés**, regroupés en entités cohérentes appelées **Objets**.

Elle repose sur 5 piliers fondamentaux :

### 1.1 Les Classes et les Objets
- **La Classe** : C'est le plan de construction (ou moule) qui définit la structure (attributs / champs) et le comportement (méthodes).
- **L'Objet (ou Instance)** : C'est une occurrence concrète créée en mémoire à partir d'une classe (par exemple, la classe `Chien` permet de créer l'objet `Médor`).

### 1.2 L'Encapsulation
L'encapsulation permet de regrouper les données et les fonctions qui les manipulent, tout en protégeant les données internes contre les accès extérieurs non autorisés :
- **`Public`** : Accessible depuis n'importe où (à l'intérieur et à l'extérieur de l'objet).
- **`Protected`** : Accessible uniquement par la classe qui le déclare et par ses classes filles (héritières).
- **`Private`** : Strictement réservé à la classe qui le déclare.

### 1.3 L'Héritage (`Extends`)
L'héritage permet à une classe dérivée (fille) de réutiliser et d'étendre les attributs et les méthodes d'une classe de base (parente). Cela favorise la réutilisation du code et l'organisation hiérarchique.

### 1.4 Le Polymorphisme (Dispatch Dynamique via VTable)
Le polymorphisme permet de manipuler différents types d'objets dérivés à travers une référence commune vers leur classe parente. Lors de l'appel d'une méthode, le programme exécute dynamiquement la version spécifique à la classe réelle de l'objet grâce à la table des méthodes virtuelles (*VTable*).

### 1.5 L'Abstraction (Classes et Méthodes Abstraites)
L'abstraction permet de définir un concept général sans en fournir toute l'implémentation :
- **Classe Abstraite** (`Abstract Class`) : Une classe incomplète servant de modèle ou de contrat. Elle **ne peut pas être instanciée directement**.
- **Méthode Abstraite** (`Abstract Method`) : Un prototype de méthode sans corps d'implémentation. Toute classe fille concrète a **l'obligation** d'implémenter cette méthode.
- **Méthode Concrète / Par Défaut** : Une classe abstraite peut aussi contenir des méthodes avec un code par défaut, que la classe fille peut conserver, surcharger totalement ou surcharger partiellement via `Super::`.

---

## 2. Syntaxe & Grammaire Objet PureBasic (.pbo)

### 2.1 Déclaration des Classes Abstraites et Concrètes

```oop
; ----------------------------------------------------------------------------
; 1. CLASSE ABSTRAITE (Modèle de base / Contrat)
; ----------------------------------------------------------------------------
Abstract Class FormeGeometrique
  Protected nom.s
  Protected couleur.s

  ; Constructeur
  Public Method Init(nom_p.s, couleur_p.s)

  ; Méthodes Abstraites (Obligatoires dans les classes filles concrètes)
  Public Abstract Method.d CalculerAire()
  Public Abstract Method.d CalculerPerimetre()
  Public Abstract Method Dessiner()

  ; Méthode concrète avec implémentation par défaut dans la classe abstraite
  Public Method AfficherInfos()
  
  ; Destructeur
  Public Method Free()
EndClass

; ----------------------------------------------------------------------------
; 2. CLASSE CONCRÈTE (Hérite de la classe abstraite)
; ----------------------------------------------------------------------------
Class Rectangle Extends FormeGeometrique
  Protected largeur.d
  Protected hauteur.d

  Public Method Init(nom_p.s, couleur_p.s, l.d, h.d)
  
  ; Implémentation obligatoire des méthodes abstraites du parent
  Public Method.d CalculerAire()
  Public Method.d CalculerPerimetre()
  Public Method Dessiner()
  
  ; Surcharge de la méthode concrète
  Public Method AfficherInfos()
  
  Public Method Free()
EndClass
```

---

### 2.2 Surcharge des Constructeurs (`Init`) & Règle Explicite

Dans PureBasic OOP, une classe peut définir **plusieurs constructeurs surchargés** pour s'adapter aux différents besoins (du cas le plus simple au cas le plus complet) :

```oop
Class Personne
  Protected nom.s
  Protected age.i

  ; Constructeur 1: Sans paramètre
  Public Method Init()
    This\nom = "Anonyme"
    This\age = 0
  EndMethod

  ; Constructeur 2: Nom seul
  Public Method Init(nom_p.s)
    This\nom = nom_p
    This\age = 0
  EndMethod

  ; Constructeur 3: Nom et Âge
  Public Method Init(nom_p.s, age_p.i)
    This\nom = nom_p
    This\age = age_p
  EndMethod
EndClass

; Instanciation selon le constructeur choisi :
Define *p1.Personne = New Personne()
Define *p2.Personne = New Personne("Alice")
Define *p3.Personne = New Personne("Bob", 30)
```

> **Règle des constructeurs explicites** :
> Chaque classe définit explicitement ses propres constructeurs. Une classe fille n'hérite pas automatiquement des constructeurs de sa classe parente sans les déclarer ; elle appelle le constructeur parent souhaité via `Super::Init(...)`.

---

## 3. Framework GUI Réactif & Composants (`src/ui/`)

Le framework GUI fournit des contrôles et des panneaux de mise en page réactifs (Responsive Layouts) permettant de concevoir des interfaces modernes sans calculs manuels de coordonnées absolues.

### 3.1 Liste Complète des Constructeurs des Contrôles UI

| Composant | Constructeurs Disponibles (du plus simple au plus complet) | Description & Paramètres |
| :--- | :--- | :--- |
| **`UI::Button`** | `Init(text.s)`<br>`Init(text.s, w.i, h.i)`<br>`Init(x.i, y.i, w.i, h.i, text.s)`<br>`Init(x.i, y.i, w.i, h.i, text.s, flags.i)` | Bouton standard cliquable. 120x30 par défaut pour les layouts automatiques. |
| **`UI::TextBox`** | `Init()`<br>`Init(defaultText.s)`<br>`Init(defaultText.s, w.i, h.i)`<br>`Init(x.i, y.i, w.i, h.i, defaultText.s)`<br>`Init(x.i, y.i, w.i, h.i, defaultText.s, flags.i)` | Champ de saisie texte monoposte. 150x25 par défaut. |
| **`UI::Label`** | `Init(text.s)`<br>`Init(text.s, w.i, h.i)`<br>`Init(x.i, y.i, w.i, h.i, text.s)`<br>`Init(x.i, y.i, w.i, h.i, text.s, flags.i)` | Libellé texte statique. |
| **`UI::CheckBox`** | `Init(text.s)`<br>`Init(text.s, checked.b)`<br>`Init(text.s, w.i, h.i, checked.b)`<br>`Init(x.i, y.i, w.i, h.i, text.s, flags.i)` | Case à cocher booléenne. |
| **`UI::ComboBox`** | `Init()`<br>`Init(w.i, h.i)`<br>`Init(x.i, y.i, w.i, h.i)`<br>`Init(x.i, y.i, w.i, h.i, flags.i)` | Liste déroulante sélectionnable. |
| **`UI::ProgressBar`** | `Init()` *(0..100)*<br>`Init(min.i, max.i)`<br>`Init(min.i, max.i, w.i, h.i)`<br>`Init(x.i, y.i, w.i, h.i, min.i, max.i, flags.i)` | Barre de progression. |
| **`UI::Slider`** | `Init()` *(0..100)*<br>`Init(min.i, max.i)`<br>`Init(min.i, max.i, w.i, h.i)`<br>`Init(x.i, y.i, w.i, h.i, min.i, max.i, flags.i)` | Curseur réglable TrackBar. |
| **`UI::ListIcon`** | `Init(title.s, colWidth.i)`<br>`Init(title.s, colWidth.i, flags.i)`<br>`Init(x.i, y.i, w.i, h.i, title.s, colWidth.i)`<br>`Init(x.i, y.i, w.i, h.i, title.s, colWidth.i, flags.i)` | Table / Grille de données multi-colonnes. |
| **`UI::Controls::ToggleSwitch`** | `Init()`<br>`Init(checked.b)`<br>`Init(w.i, h.i, checked.b)`<br>`Init(x.i, y.i, w.i, h.i, checked.b)` | Interrupteur moderne vectoriel (Canvas). |

---

### 3.2 Panneaux de Disposition Réactive (Layouts)

| Panneau Layout | Constructeurs Disponibles | Rôle & Comportement |
| :--- | :--- | :--- |
| **`UI::Layouts::StackPanel`** | `Init()` *(Vertical, 5px)*<br>`Init(orientation.i)`<br>`Init(orientation.i, spacing.i)`<br>`Init(orientation.i, spacing.i, w.i, h.i)` | Empile les composants en ligne (`#UI_Orientation_Horizontal`) ou en colonne (`#UI_Orientation_Vertical`). |
| **`UI::Layouts::DockPanel`** | `Init()` *(LastChildFill = #True)*<br>`Init(lastChildFill.b)`<br>`Init(lastChildFill.b, w.i, h.i)` | Ancre les enfants sur les bords (`#UI_Dock_Top`, `#UI_Dock_Bottom`, `#UI_Dock_Left`, `#UI_Dock_Right`) et remplit le centre. |
| **`UI::Layouts::Grid`** | `Init()`<br>`Init(w.i, h.i)` | Grille 2D flexible avec dimensionnement en pixels, `"Auto"` ou proportionnel Star (`"*"` / `"2*"`). |
| **`UI::Window`** | `Init(title.s)`<br>`Init(title.s, w.i, h.i)`<br>`Init(title.s, w.i, h.i, flags.i)`<br>`Init(title.s, x.i, y.i, w.i, h.i, flags.i, parentWin.i)` | Fenêtre GUI réactive intégrant automatiquement le redimensionnement. |

---

## 4. Exemple d'Application Réactive Multi-Fenêtres

```oop
XIncludeFile "ui/UI.pbo"
Using UI
Using UI::Layouts

Class MainWindow Extends UI::Window {
  Protected *rootDock.DockPanel
  Protected *toolbar.StackPanel
  Protected *btnNew.Button
  Protected *table.ListIcon

  Public Method Init() {
    ; Fenêtre 800x600 centrée et redimensionnable
    Super::Init("Gestionnaire de Contacts", 800, 600)

    ; Panneau racine Dock
    This\*rootDock = New DockPanel(#True)
    This\SetRootComponent(This\*rootDock)

    ; Barre d'outils en haut (Dock Top)
    This\*toolbar = New StackPanel(#UI_Orientation_Horizontal, 8)
    This\*btnNew = New Button("+ Nouveau Contact")
    This\*toolbar\AddChild(This\*btnNew)
    This\*rootDock\AddDockChild(This\*toolbar, #UI_Dock_Top)

    ; Table centrale (remplit tout l'espace restant)
    This\*table = New ListIcon("Nom", 200)
    This\*table\AddColumn(1, "Email", 250)
    This\*rootDock\AddDockChild(This\*table, #UI_Dock_Fill)
  }
}

Define *app.UI::Application = New UI::Application()
Define *win.MainWindow = New MainWindow()
*app\Run()
```

---

## 5. Guide de Compilation & Exécution

### Transpiler un fichier source `.pbo` vers `.pb` :
```cmd
"compiler/transpiler.exe" "src/main.pbo" "src/main_generated.pb"
```

### Compiler avec le compilateur officiel PureBasic :
```cmd
"C:\Program Files\PureBasic\Compilers\pbcompiler.exe" "src/main_generated.pb" /EXE "src/app.exe" /THREAD /UNICODE /XP /USER /DPIAWARE /QUIET
```
