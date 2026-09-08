# -*- coding: utf-8 -*-
"""
Script to translate all French comments in PureBasic OOP framework and example files
into simplified English (ASCII only), preventing encoding/accent issues in PureBasic IDE.
"""

import os
import re

WORKSPACE = r"c:\PB\PB_PROJECT\PB_OOP_WORKSPACE\PUREBASIC_OOP_WORKSPACE"

TARGET_DIRS = [
    os.path.join(WORKSPACE, "examples", "07_project_dashboard"),
    os.path.join(WORKSPACE, "framework")
]

TRANSLATIONS = [
    # Top-level comments and headers
    (r"Point d'Entr[eé\xe9\xc3]e Principal", "Main Entry Point"),
    (r"Mod[eè\xe8\xc3]le M[eé\xe9\xc3]tier", "Business Model"),
    (r"Vue Fen[eê\xea\xc3]tre PureBasic OOP", "PureBasic OOP Window View"),
    (r"ViewModel MVVM R[eé\xe9\xc3]actif", "Reactive MVVM ViewModel"),
    (r"Fichier\s*:\s*", "File: "),
    (r"Inclusion de la Vue Principale \(Le Framework UI & MVVM est auto-inclus par le transpileur\s*!\)", "Include Main View (UI & MVVM framework is auto-included by transpiler)"),
    (r"Instanciation de l'Application PureBasic OOP", "Instantiate PureBasic OOP Application"),
    (r"Instanciation du ViewModel \(.*?état réactif.*?\)", "Instantiate ViewModel (Reactive state and business logic)"),
    (r"Instanciation du ViewModel \(.*?\)", "Instantiate ViewModel (Reactive state and business logic)"),
    (r"Instanciation de la Vue \(Injection du ViewModel en DataContext\)", "Instantiate View (Inject ViewModel into DataContext)"),
    (r"D[eé\xe9\xc3]finition de la fen[eê\xea\xc3]tre principale et lancement de la boucle d'[eé\xe9\xc3]v[eé\xe9\xc3]nements", "Set main window and run event loop"),
    (r"Lib[eé\xe9\xc3]ration propre.*", "Clean teardown"),

    # ViewModel comments and actions
    (r"Propri[eé\xe9\xc3]t[eé\xe9\xc3]s Observables DataBound [aà\xe0\xc3] l'interface", "Observable Properties DataBound to UI"),
    (r"Enregistrement des propri[eé\xe9\xc3]t[eé\xe9\xc3]s observables", "Register observable properties"),
    (r"---\s*Traitement des Commandes UI \(RelayCommands\)\s*---", "--- UI Commands Processing (RelayCommands) ---"),
    (r"Action\s*:\s*Enregistrer les modifications", "Action: Save changes"),
    (r"Action\s*:\s*Annuler les modifications", "Action: Cancel changes"),
    (r"Action\s*:\s*Supprimer le projet", "Action: Delete project"),
    (r"Action\s*:\s*Ajouter un nouveau projet", "Action: Add new project"),
    (r"Action\s*:\s*G[eé\xe9\xc3]n[eé\xe9\xc3]rer un rapport", "Action: Generate report"),
    (r"Actions\s*:\s*Navigation Sidebar", "Actions: Sidebar Navigation"),

    # Constructors
    (r"Constructeur 0:\s*Vierge \(pret pour LoadView\)", "Constructor 0: Blank (ready for LoadView)"),
    (r"Constructeur 1:\s*Titre uniquement \((\d+x\d+), Centerede? a l'ecran, Menu Systeme \+ Reduire \+ Agrandir \+ Redimensionnable\)", r"Constructor 1: Title only (\1, Centered on screen, System Menu + Minimize + Maximize + Resizable)"),
    (r"Constructeur 2:\s*Titre, Largeur, Hauteur \(Centerede? a l'ecran, Redimensionnable\)", "Constructor 2: Title, Width, Height (Centered on screen, Resizable)"),
    (r"Constructeur 3:\s*Titre, Largeur, Hauteur, Flags", "Constructor 3: Title, Width, Height, Flags"),
    (r"Constructeur 4:\s*Titre, X, Y, Largeur, Hauteur, Flags", "Constructor 4: Title, X, Y, Width, Height, Flags"),
    (r"Constructeur 4:\s*Titre, X, Y, Largeur, Hauteur", "Constructor 4: Title, X, Y, Width, Height"),
    (r"Constructeur 5:\s*Titre, X, Y, Largeur, Hauteur, Flags", "Constructor 5: Title, X, Y, Width, Height, Flags"),
    (r"Constructeur 6:\s*Complet \(Titre, X, Y, Largeur, Hauteur, Flags, ParentID\)", "Constructor 6: Full (Title, X, Y, Width, Height, Flags, ParentID)"),

    (r"Constructeur 1:\s*Par d[eé\xe9\xc3]faut\s*\((\d+x\d+)\)", r"Constructor 1: Default (\1)"),
    (r"Constructeur 1:\s*Par d[eé\xe9\xc3]faut\s*\(positionne par Layout 0,0, (\d+x\d+)\)", r"Constructor 1: Default (Positioned by Layout 0,0, \1)"),
    (r"Constructor 1:\s*Default\s*\(positionne par Layout 0,0, (\d+x\d+)\)", r"Constructor 1: Default (Positioned by Layout 0,0, \1)"),
    (r"Constructeur 1:\s*Par d[eé\xe9\xc3]faut", "Constructor 1: Default"),
    (r"Constructeur 0:\s*Par d[eé\xe9\xc3]faut", "Constructor 0: Default"),
    (r"Constructeur 0:\s*Titre par defaut \(0,0, (\d+x\d+)\)", r"Constructor 0: Default title (0,0, \1)"),
    (r"Constructeur 0:\s*Texte par defaut \(0,0, (\d+x\d+)\)", r"Constructor 0: Default text (0,0, \1)"),
    (r"Constructor 0:\s*Default \(date du jour, 0,0, (\d+x\d+)\)", r"Constructor 0: Default (Current date, 0,0, \1)"),
    (r"Constructeur 1:\s*Texte par defaut uniquement \(0,0, (\d+x\d+)\)", r"Constructor 1: Default text only (0,0, \1)"),
    (r"Constructeur 1:\s*Dimensions par defaut \((\d+x\d+)\)", r"Constructor 1: Default dimensions (\1)"),

    (r"Constructeur 2:\s*Dimensions personnalis[eé\xe9\xc3]es", "Constructor 2: Custom dimensions"),
    (r"Constructeur 2:\s*Dimensions sp[eé\xe9\xc3]cifi[eé\xe9\xc3]es", "Constructor 2: Specified dimensions"),
    (r"Constructeur 2:\s*Dimensions", "Constructor 2: Dimensions"),
    (r"Constructeur 1:\s*Dimensions", "Constructor 1: Dimensions"),
    (r"Constructeur 3:\s*Position et dimensions", "Constructor 3: Position and dimensions"),
    (r"Constructeur 4:\s*Complet avec flags", "Constructor 4: Full with flags"),
    (r"Constructeur 4:\s*Complet avec position et flags", "Constructor 4: Full with position and flags"),
    (r"Constructeur 4:\s*Position, dimensions et flags", "Constructor 4: Position, dimensions and flags"),
    (r"Constructeur 4:\s*Complet", "Constructor 4: Full"),
    (r"Constructeur 3:\s*Complet", "Constructor 3: Full"),
    (r"Constructeur 2:\s*Complet", "Constructor 2: Full"),
    (r"Constructeur 3:\s*Complet \(x, y, w, h, texte, etat\)", "Constructor 3: Full (x, y, w, h, text, state)"),

    (r"Constructeur 1:\s*Texte seul \((\d+x\d+)\)", r"Constructor 1: Text only (\1)"),
    (r"Constructeur 2:\s*Texte seul \((\d+x\d+)\)", r"Constructor 2: Text only (\1)"),
    (r"Constructeur 2:\s*Texte seul", "Constructor 2: Text only"),
    (r"Constructeur 2:\s*Texte et dimensions", "Constructor 2: Text and dimensions"),
    (r"Constructeur 3:\s*Texte et dimensions", "Constructor 3: Text and dimensions"),
    (r"Constructeur 4:\s*Position, dimensions et texte", "Constructor 4: Position, dimensions and text"),
    (r"Constructeur 3:\s*Position, dimensions et texte", "Constructor 3: Position, dimensions and text"),
    (r"Constructeur 1:\s*Texte seul \(Positionn[eé\xe9\xc3] par Layout 0,0, (\d+x\d+)\)", r"Constructor 1: Text only (Positioned by Layout 0,0, \1)"),
    (r"Constructeur 1:\s*Texte uniquement \(positionn[eé\xe9\xc3] par Layout 0,0, (\d+x\d+)\)", r"Constructor 1: Text only (Positioned by Layout 0,0, \1)"),
    (r"Constructeur 2:\s*Texte et [eé\xe9\xc3]tat coch[eé\xe9\xc3]", "Constructor 2: Text and checked state"),
    (r"Constructeur 1:\s*Texte et etat coche", "Constructor 1: Text and checked state"),
    (r"Constructeur 3:\s*Texte, dimensions et [eé\xe9\xc3]tat coch[eé\xe9\xc3]", "Constructor 3: Text, dimensions and checked state"),
    (r"Constructeur 2:\s*Texte, dimensions et etat", "Constructor 2: Text, dimensions and state"),
    (r"Constructeur 2:\s*Texte initial et dimensions", "Constructor 2: Initial text and dimensions"),
    (r"Constructeur 1:\s*Titre et dimensions", "Constructor 1: Title and dimensions"),

    (r"Constructeur 3:\s*Texte et Ic[oô\xf4\xc3]ne", "Constructor 3: Text and Icon"),
    (r"Constructeur 4:\s*Texte, Ic[oô\xf4\xc3]ne et Tag", "Constructor 4: Text, Icon and Tag"),
    (r"Constructeur 2:\s*Placeholder seul", "Constructor 2: Placeholder only"),
    (r"Constructeur 3:\s*Placeholder et dimensions", "Constructor 3: Placeholder and dimensions"),
    (r"Constructeur 4:\s*Position, dimensions et placeholder", "Constructor 4: Position, dimensions and placeholder"),
    (r"Constructeur 5:\s*Position, dimensions, placeholder et mode mot de passe", "Constructor 5: Position, dimensions, placeholder and password mode"),

    (r"Constructeur 1:\s*Masque personnalise", "Constructor 1: Custom mask"),
    (r"Constructeur 2:\s*Date et Masque", "Constructor 2: Date and Mask"),
    (r"Constructeur 3:\s*Date, Masque et dimensions", "Constructor 3: Date, Mask and dimensions"),

    (r"Constructeur 2:\s*Min et Max sp[eé\xe9\xc3]cifi[eé\xe9\xc3]s", "Constructor 2: Specified Min and Max"),
    (r"Constructor 1:\s*Default 0\.\.100 \(Positionne par Layout 0,0, (\d+x\d+)\)", r"Constructor 1: Default 0..100 (Positioned by Layout 0,0, \1)"),
    (r"Constructeur 3:\s*Min, Max et dimensions", "Constructor 3: Min, Max and dimensions"),
    (r"Constructeur 1:\s*Min et Max", "Constructor 1: Min and Max"),
    (r"Constructeur 2:\s*Min, Max et valeur initiale \((\d+x\d+) par defaut\)", r"Constructor 2: Min, Max and initial value (\1 default)"),
    (r"Constructeur 3:\s*Min, Max, valeur initiale et dimensions", "Constructor 3: Min, Max, initial value and dimensions"),

    (r"Constructeur 2:\s*[EÉeé\xe9\xc3]tat initial sp[eé\xe9\xc3]cifi[eé\xe9\xc3]", "Constructor 2: Specified initial state"),
    (r"Constructeur 3:\s*Dimensions et [eé\xe9\xc3]tat initial", "Constructor 3: Dimensions and initial state"),
    (r"Constructeur 4:\s*Position, dimensions et [eé\xe9\xc3]tat initial", "Constructor 4: Position, dimensions and initial state"),
    (r"Constructeur 4:\s*Position, dimensions et flags personnalis[eé\xe9\xc3]s", "Constructor 4: Position, dimensions and custom flags"),

    # Canvas & controls comments
    (r"M[eé\xe9\xc3]thode virtuelle surcharg[eé\xe9\xc3]e par les contr[oô\xf4\xc3]les Canvas", "Virtual method overridden by Canvas controls"),
    (r"Getters & Setters Synchronis[eé\xe9\xc3]s", "Synchronized Getters & Setters"),
    (r"Arri[eè\xe8\xc3]re-plan du conteneur parent \(pour transparence et coins arrondis propres\)", "Parent container background (for clean transparency and rounded corners)"),
    (r"Propri[eé\xe9\xc3]t[eé\xe9\xc3]s d'animation et de micro-interactions fluides", "Animation and smooth micro-interaction properties"),
    (r"Moteur de Styles et Triggers D[eé\xe9\xc3]claratifs \(WPF/XAML\)", "Declarative Style & Trigger Engine (WPF/XAML)"),
    (r"---\s*Initialisation des valeurs par d[eé\xe9\xc3]faut\s*---", "--- Initialize default values ---"),
    (r"Fond par d[eé\xe9\xc3]faut du th[eè\xe8\xc3]me clair / fen[eê\xea\xc3]tre", "Default light theme / window background"),
    (r"Palette par d[eé\xe9\xc3]faut moderne \(Light\)", "Modern default palette (Light)"),
    (r"Enregistrement des valeurs de base pour les triggers", "Store base values for triggers"),
    (r"---\s*Machine d'[eé\xe9\xc3]tats Visuels \(WPF VisualStateManager\)\s*---", "--- Visual State Machine (WPF VisualStateManager) ---"),
    (r"Application des triggers WPF actifs selon le nouvel [eé\xe9\xc3]tat", "Apply active WPF triggers for the new state"),
    (r"---\s*Getters / Setters pour les [eé\xe9\xc3]tats\s*---", "--- State Getters / Setters ---"),
    (r"---\s*Getters / Setters pour le Texte\s*---", "--- Text Getters / Setters ---"),
    (r"---\s*Getters / Setters pour les Couleurs et Styles\s*---", "--- Color & Style Getters / Setters ---"),
    (r"---\s*Helpers de Couleurs Actives selon l'[eé\xe9\xc3]tat\s*---", "--- Active Color Helpers by State ---"),
    (r"---\s*Helpers Graphiques Int[eé\xe9\xc3]gr[eé\xe9\xc3]s\s*---", "--- Built-in Graphics Helpers ---"),
    (r"Effacer l'arriere-plan du canvas avec la couleur du conteneur parent", "Clear canvas background with parent container color"),
    (r"Effacement avec la couleur du conteneur parent", "Clear with parent container color"),
    (r"Bordure d'accentuation lat[eé\xe9\xc3]rale gauche \(ex: indicateur d'onglet actif WPF\)", "Left accent border (e.g. WPF active tab indicator)"),
    (r"---\s*[EÉeé\xe9\xc3]v[eé\xe9\xc3]nements Souris, Clavier & Focus\s*---", "--- Mouse, Keyboard & Focus Events ---"),
    (r"---\s*Typographie Haute-Fid[eé\xe9\xc3]lit[eé\xe9\xc3]\s*---", "--- High-Fidelity Typography ---"),
    (r"Virtual Layout Arrange method: redessine imperativement le canvas des que sa taille reelle est fixee", "Virtual Layout Arrange method: redraws canvas as soon as real size is set"),
    (r"---\s*Getters / Setters pour les Etats\s*---", "--- State Getters / Setters ---"),
    (r"pour eviter les artefacts carres autour des coins arrondis", "Avoid square artifacts around rounded corners"),
    (r"Fond arrondi avec bordure", "Rounded background with border"),
    (r"Rectangle standard avec bordure", "Standard rectangle with border"),
    (r"Constructor 1:\s*Default \(Positionne par Layout 0,0, (\d+x\d+)\)", r"Constructor 1: Default (Positioned by Layout 0,0, \1)"),
    (r"---\s*Int[eé\xe9\xc3]gration du Syst[eè\xe8\xc3]me de Styles & Triggers D[eé\xe9\xc3]claratifs \(WPF/XAML\)\s*---", "--- Declarative Style & Trigger System Integration (WPF/XAML) ---"),
    (r"Appliquer les Setters de base d[eé\xe9\xc3]finis dans le Style", "Apply base Setters defined in Style"),
    (r"M[eé\xe9\xc3]morisation des valeurs appliqu[eé\xe9\xc3]es comme r[eé\xe9\xc3]f[eé\xe9\xc3]rence de base pour les triggers", "Store applied values as base reference for triggers"),
    (r"1\.\s*R[eé\xe9\xc3]tablir les valeurs de base", "1. Restore base values"),
    (r"2\.\s*Parcourir les triggers et activer ceux dont la condition est remplie", "2. Iterate triggers and activate matching ones"),
    (r"Si aucun trigger Scale n'est actif, et qu'on a boug[eé\xe9\xc3] de l'[eé\xe9\xc3]chelle de base, retour fluide", "If no scale trigger is active and scale changed, smoothly return to base"),
    (r"H[eé\xe9\xc3]riter de la couleur de fond du conteneur parent ou de la fen[eê\xea\xc3]tre", "Inherit background color from parent container or window"),
    (r"0\.\s*Recherche et application du Style WPF \(nomm[eé\xe9\xc3] ou implicite par TargetType\)", "0. Find and apply WPF Style (named or implicit by TargetType)"),
    (r"Parcourir les Setters et Triggers du Style", "Iterate over Style Setters and Triggers"),
    (r"Setters du trigger", "Trigger setters"),
    (r"3\.\s*Pressed Colors \(Clic enfonc[eé\xe9\xc3]\)", "3. Pressed Colors (Mouse pressed)"),
    (r"6\.\s*Typographie Haute-Fid[eé\xe9\xc3]lit[eé\xe9\xc3]", "6. High-Fidelity Typography"),
    (r"---\s*Fonctions d'Amorti Math[eé\xe9\xc3]matiques \(Easing\)\s*---", "--- Mathematical Easing Functions ---"),
    (r"---\s*V[eé\xe9\xc3]rification et Boucle de Rendu \(Tick 60 FPS\)\s*---", "--- Render Loop and Check (60 FPS Tick) ---"),
    (r"Dispatch valeur au contr[oô\xf4\xc3]le Canvas", "Dispatch value to Canvas control"),
    (r"---\s*Palettes Pr[eé\xe9\xc3]d[eé\xe9\xc3]finies Modernes \(WPF / WinUI 3 / Tailwind\)\s*---", "--- Modern Predefined Palettes (WPF / WinUI 3 / Tailwind) ---"),
    (r"Hover l[eé\xe9\xc3]g[eè\xe8\xc3]rement teint[eé\xe9\xc3]", "Lightly tinted hover"),
    (r"Pressed un peu plus soutenu", "Darker pressed state"),
    (r"---\s*Ic[oô\xf4\xc3]ne et Alignement\s*---", "--- Icon and Alignment ---"),
    (r"1\.\s*Fond et bordure arrondis selon l'[eé\xe9\xc3]tat visuel actif", "1. Rounded background and border based on active visual state"),
    (r"2\.\s*Anneau de focus si le gadget a le focus clavier", "2. Focus ring if gadget has keyboard focus"),
    (r"3\.\s*Pr[eé\xe9\xc3]paration de la police et du texte", "3. Prepare font and text"),
    (r"Centr[eé\xe9\xc3]", "Centered"),
    (r"4\.\s*Dessin de l'ic[oô\xf4\xc3]ne si pr[eé\xe9\xc3]sente", "4. Draw icon if present"),
    (r"5\.\s*Dessin du texte", "5. Draw text"),
    (r"---\s*Alignement & Propri[eé\xe9\xc3]t[eé\xe9\xc3]s de Texte\s*---", "--- Alignment & Text Properties ---"),
    (r"Mesure pr[eé\xe9\xc3]cise et dynamique de la largeur du texte vectoriel", "Precise dynamic measurement of vector text width"),
    (r"---\s*Troncature intelligente avec Ellipsis \(\.\.\.\)\s*---", "--- Smart Ellipsis Truncation (...) ---"),
    (r"---\s*Initialisation des styles par d[eé\xe9\xc3]faut\s*---", "--- Initialize default styles ---"),
    (r"Th[eè\xe8\xc3]me moderne WinUI 3", "Modern WinUI 3 theme"),
    (r"Typographie par d[eé\xe9\xc3]faut", "Default typography"),
    (r"Supprimer les retours a la ligne pour un champ simple ligne", "Remove line breaks for single-line field"),
    (r"---\s*Ajustement du defilement pour visibilite du curseur\s*---", "--- Adjust scroll offset to keep cursor visible ---"),
    (r"5\.\s*Decoupage pour eviter les debordements de texte", "5. Clip text to prevent overflow"),
    (r"6\.\s*Affichage du Placeholder si vide et non-focus", "6. Display placeholder if empty and unfocused"),
    (r"7\.\s*Gestion du Curseur / Caret Systeme Windows", "7. Windows system caret management"),
    (r"---\s*Gestion des enfants\s*---", "--- Child elements management ---"),
    (r"---\s*Liberation recursive de la memoire\s*---", "--- Recursive memory teardown ---"),
    (r"---\s*Helper constructeur interne\s*---", "--- Internal constructor helper ---"),
    (r"Theme moderne clair par defaut", "Default modern light theme"),
    (r"---\s*Construction de la liste virtuelle a plat\s*---", "--- Build flat virtual list ---"),
    (r"2\.\s*Parcours et dessin des noeuds visibles", "2. Render visible nodes"),
    (r"Verifier visibilite dans la zone de decoupe verticale", "Check visibility in vertical viewport"),
    (r"Calcul du niveau hierarchique", "Calculate hierarchy level"),
    (r"Fond du noeud \(Selectionne ou Survole\)", "Node background (Selected or Hovered)"),
    (r"Chevron vers le bas \(v\)", "Down chevron (v)"),
    (r"Chevron vers la droite \(>\)", "Right chevron (>)"),
    (r"Boite de la case", "Checkbox box"),
    (r"2\.4 Icone du noeud \(si definie\)", "2.4 Node icon (if defined)"),
    (r"2\.5 Texte du noeud", "2.5 Node text"),
    (r"2\.6 Boutons d'actions alignes a droite de la ligne", "2.6 Action buttons aligned to right of line"),
    (r"Bouton vectoriel par defaut \(petit cercle avec point\)", "Default vector button (circle with dot)"),
    (r"Stocker les coordonnees de rendu sur le noeud pour le hit-testing", "Store render coordinates on node for hit-testing"),
    (r"---\s*Gestion des Evenements Souris & Molette\s*---", "--- Mouse & Wheel Events Handling ---"),
    (r"Clic sur la barre de defilement", "Click on scrollbar"),
    (r"Determination du noeud clique", "Determine clicked node"),
    (r"1\.\s*Clic sur le chevron d'expansion \?", "1. Click on expand chevron?"),
    (r"2\.\s*Clic sur la case a cocher \?", "2. Click on checkbox?"),
    (r"3\.\s*Clic sur un bouton d'action \?", "3. Click on action button?"),
    (r"4\.\s*Clic sur le noeud \(Selection\)", "4. Click on node (Selection)"),
    (r"Deplacement de la molette / barre de defilement", "Mouse wheel / scrollbar movement"),
    (r"Detection du survol", "Hover detection"),
    (r"Row par defaut", "Default row"),
    (r"---\s*Boutons d'action par n[oœ\xc5\x93]ud\s*---", "--- Per-node action buttons ---"),
    (r"---\s*D[eé\xe9\xc3]pliage / Repliage r[eé\xe9\xc3]cursif\s*---", "--- Recursive expand / collapse ---"),
    (r"Remplacer si d[eé\xe9\xc3]j[aà\xe0\xc3] existant, sinon ajouter", "Replace if already exists, otherwise add"),
    (r"---\s*H[eé\xe9\xc3]ritage de Style \(BasedOn\)\s*---", "--- Style Inheritance (BasedOn) ---"),
    (r"1\.\s*Copier les Setters du style parent qui ne sont pas red[eé\xe9\xc3]finis ici", "1. Copy parent style Setters that are not overridden here"),
    (r"2\.\s*Copier les Triggers du style parent", "2. Copy parent style Triggers"),
    (r"R[eé\xe9\xc3]solution de l'h[eé\xe9\xc3]ritage [eé\xe9\xc3]ventuel \(BasedOn\)", "Resolve potential inheritance (BasedOn)"),
    (r"Style implicite li[eé\xe9\xc3] au nom du composant \(ex: TargetType=\"CanvasButton\"\)", 'Implicit style linked to component name (e.g. TargetType="CanvasButton")'),
    (r'Support des syntaxes XAML "\{StaticResource PrimaryButton\}" ou "PrimaryButton"', 'Support XAML syntaxes "{StaticResource PrimaryButton}" or "PrimaryButton"'),

    # XML comments
    (r"PureBasic OOP - Styles D[eé\xe9\xc3]claratifs WPF & Micro-Animations 60 FPS", "PureBasic OOP - Declarative WPF Styles & 60 FPS Micro-Animations"),
    (r"1\.\s*Style Implicite par d[eé\xe9\xc3]faut pour tous les CanvasButton", "1. Default Implicit Style for all CanvasButtons"),
    (r"4\.\s*Navigation Bar\s*:\s*Bouton Actif S[eé\xe9\xc3]lectionn[eé\xe9\xc3] \(Barre bleue lat[eé\xe9\xc3]rale\)", "4. Navigation Bar: Active Selected Button (Blue side indicator)"),
    (r"Carte Principale [EÉ\xe9\xc3]pur[eé\xe9\xc3]e\s*:\s*Formulaire Edit Project Details", "Main Card: Edit Project Details Form"),
    (r"Ligne 1\s*:\s*Nom du Projet, Date D[eé\xe9\xc3]but, Date Fin", "Row 1: Project Name, Start Date, End Date"),
    (r"Ligne 5\s*:\s*Barre d'Actions Inf[eé\xe9\xc3]rieure \(Save, Cancel, Delete\)", "Row 5: Bottom Action Bar (Save, Cancel, Delete)"),
]

def clean_file(path):
    with open(path, "rb") as f:
        raw = f.read()

    # Try utf-8 first, then latin-1
    try:
        text = raw.decode("utf-8")
    except UnicodeDecodeError:
        text = raw.decode("latin-1")

    # If it's ProjectDashboardViewModel.pbi, also translate notification strings to clean simplified English
    if "ProjectDashboardViewModel.pbi" in path:
        text = text.replace('"Prêt."', '"Ready."')
        text = text.replace('"Pr\xc3\xaat."', '"Ready."')
        text = text.replace('This\\*StatusNotification\\SetValue("⚠️ Le nom du projet ne peut pas être vide.")', 'This\\*StatusNotification\\SetValue("[!] Project name cannot be empty.")')
        text = text.replace('This\\*StatusNotification\\SetValue("✔ Projet \'" + pName + "\' enregistré avec succès.")', 'This\\*StatusNotification\\SetValue("[OK] Project \'" + pName + "\' saved successfully.")')
        text = text.replace('This\\*StatusNotification\\SetValue("↩ Modifications annulées.")', 'This\\*StatusNotification\\SetValue("Modifications cancelled.")')
        text = text.replace('This\\*StatusNotification\\SetValue("🗑 Données du projet réinitialisées.")', 'This\\*StatusNotification\\SetValue("Project data reset.")')
        text = text.replace('This\\*Description\\SetValue("Nouveau projet initialisé...")', 'This\\*Description\\SetValue("New project initialized...")')
        text = text.replace('This\\*StatusNotification\\SetValue("✨ Nouveau modèle de projet créé.")', 'This\\*StatusNotification\\SetValue("New project template created.")')

    if "CanvasTextBox.pbi" in path:
        text = text.replace("; Bullet '\u25cf'", "; Bullet character")
        text = text.replace("; Bullet '\xe2\x97\x8f'", "; Bullet character")

    # Apply regex translations
    for pattern, replacement in TRANSLATIONS:
        text = re.sub(pattern, replacement, text)

    # In comment lines, replace any remaining common French accents with standard ASCII
    lines = []
    for line in text.splitlines(keepends=True):
        if ";" in line or "<!--" in line:
            sep = ";" if ";" in line else "<!--"
            parts = line.split(sep, 1)
            comment = parts[1]
            acc_map = {
                'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
                'É': 'E', 'È': 'E', 'Ê': 'E',
                'à': 'a', 'â': 'a', 'À': 'A',
                'î': 'i', 'ï': 'i', 'Î': 'I',
                'ô': 'o', 'ö': 'o', 'Ô': 'O',
                'ù': 'u', 'û': 'u', 'ü': 'u', 'Ù': 'U',
                'ç': 'c', 'Ç': 'C',
                'œ': 'oe', 'Œ': 'Oe',
                '’': "'", '‘': "'", '“': '"', '”': '"',
                '«': '"', '»': '"',
                '\ufffd': ''
            }
            for k, v in acc_map.items():
                comment = comment.replace(k, v)
            line = parts[0] + sep + comment
        lines.append(line)

    new_text = "".join(lines)

    has_bom = raw.startswith(b"\xef\xbb\xbf")
    new_bytes = new_text.encode("utf-8")
    if has_bom and not new_bytes.startswith(b"\xef\xbb\xbf"):
        new_bytes = b"\xef\xbb\xbf" + new_bytes

    if new_bytes != raw:
        with open(path, "wb") as f:
            f.write(new_bytes)
        return True
    return False

def main():
    count = 0
    for target in TARGET_DIRS:
        for root, _, files in os.walk(target):
            for f in files:
                if f.endswith((".pb", ".pbi", ".pbo", ".xml")) and not f.endswith("main_transpiled.pb"):
                    p = os.path.join(root, f)
                    if clean_file(p):
                        count += 1
                        print(f"Updated: {os.path.relpath(p, WORKSPACE)}")
    print(f"Total files updated: {count}")

if __name__ == "__main__":
    main()
