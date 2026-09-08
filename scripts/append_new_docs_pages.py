# -*- coding: utf-8 -*-
"""
Script to append the 8 new Alpha 1.3 documentation pages and update index.html
in scripts/generate_all_html_docs.py.
"""

import os

GEN_SCRIPT = r"c:\PB\PB_PROJECT\PB_OOP_WORKSPACE\PUREBASIC_OOP_WORKSPACE\scripts\generate_all_html_docs.py"

NEW_PAGES_CODE = '''
# ============================================================================
# ALPHA 1.3 NEW PAGES: CANVAS CONTROLS, STYLES, ANIMATIONS, XML LOADER
# ============================================================================

# ----------------------------------------------------------------------------
# CanvasControl (Base)
# ----------------------------------------------------------------------------
save_page("fr", "ui/canvascontrol.html", "Classe CanvasControl", "Classe de base pour tous les contrôles vectoriels 2D haute fidélité avec styles, micro-animations et double buffering.", "badge-ui", "CANVAS", """
<div class='doc-section'>
  <h2 class='section-title'>Présentation</h2>
  <p><code>UI::CanvasControl</code> hérite de <code>UI::Gadget</code> et constitue le socle graphique moderne de PureBasic OOP. Conçu sur un <code>CanvasGadget()</code> natif avec double-buffering, il prend en charge nativement les coins arrondis (CornerRadius), les bordures vectorielles, les échelles dynamiques (Scale), les micro-animations fluides à 60 FPS et le moteur de styles déclaratifs WPF/XAML.</p>
</div>

<div class='doc-section'>
  <h2 class='section-title'>Méthodes Principales</h2>
  <table class='method-table'>
    <thead>
      <tr><th>Méthode</th><th>Description</th></tr>
    </thead>
    <tbody>
      <tr><td><code>ApplyStyle(*style.UI::Style)</code></td><td>Applique un style WPF avec setters et triggers dynamiques.</td></tr>
      <tr><td><code>SetCornerRadius(radius.i)</code></td><td>Définit le rayon des arrondis vectoriels en pixels.</td></tr>
      <tr><td><code>SetBorderColor(color.i)</code></td><td>Définit la couleur de la bordure vectorielle.</td></tr>
      <tr><td><code>SetBorderThickness(thickness.i)</code></td><td>Définit l'épaisseur du contour vectoriel.</td></tr>
      <tr><td><code>SetScale(factor.d)</code></td><td>Modifie l'échelle géométrique du composant pour les zooms de micro-interaction.</td></tr>
      <tr><td><code>SetVisualState(state.i)</code></td><td>Active un état visuel (#STATE_NORMAL, #STATE_HOVER, #STATE_PRESSED, #STATE_DISABLED).</td></tr>
      <tr><td><code>Redraw()</code></td><td>Déclenche le rendu vectoriel immédiat du contrôle.</td></tr>
    </tbody>
  </table>
</div>
""", "canvascontrol")

save_page("en", "ui/canvascontrol.html", "CanvasControl Class", "Base class for all modern high-fidelity 2D vector controls featuring styles, micro-animations, and double buffering.", "badge-ui", "CANVAS", """
<div class='doc-section'>
  <h2 class='section-title'>Overview</h2>
  <p><code>UI::CanvasControl</code> extends <code>UI::Gadget</code> and provides the modern vector foundation for PureBasic OOP. Built on native <code>CanvasGadget()</code> with full double-buffering, it natively supports vector rounded corners (CornerRadius), borders, dynamic zoom scaling (Scale), 60 FPS micro-animations, and declarative WPF/XAML styles.</p>
</div>

<div class='doc-section'>
  <h2 class='section-title'>Core Methods</h2>
  <table class='method-table'>
    <thead>
      <tr><th>Method</th><th>Description</th></tr>
    </thead>
    <tbody>
      <tr><td><code>ApplyStyle(*style.UI::Style)</code></td><td>Applies a WPF style with property setters and dynamic triggers.</td></tr>
      <tr><td><code>SetCornerRadius(radius.i)</code></td><td>Sets the corner radius for smooth vector rounding.</td></tr>
      <tr><td><code>SetBorderColor(color.i)</code></td><td>Sets the vector outline border color.</td></tr>
      <tr><td><code>SetBorderThickness(thickness.i)</code></td><td>Sets the stroke width of the border.</td></tr>
      <tr><td><code>SetScale(factor.d)</code></td><td>Adjusts the geometrical scale factor for smooth hover zooms.</td></tr>
      <tr><td><code>SetVisualState(state.i)</code></td><td>Switches the active visual state (#STATE_NORMAL, #STATE_HOVER, #STATE_PRESSED).</td></tr>
      <tr><td><code>Redraw()</code></td><td>Triggers immediate vector repaint of the component.</td></tr>
    </tbody>
  </table>
</div>
""", "canvascontrol")

# ----------------------------------------------------------------------------
# CanvasButton
# ----------------------------------------------------------------------------
save_page("fr", "ui/canvasbutton.html", "Classe CanvasButton", "Bouton vectoriel moderne avec animations au survol, styles WPF, icônes et anneau de focus.", "badge-ui", "CANVAS", """
<div class='doc-section'>
  <h2 class='section-title'>Présentation</h2>
  <p><code>UI::CanvasButton</code> est un bouton vectoriel moderne offrant une expérience utilisateur fluide digne des applications de bureau actuelles. Il supporte les thèmes prédéfinis (Primary, Secondary, Success, Danger, Dark, Light), les icônes vectorielles et les micro-animations à l'activation.</p>
</div>

<div class='doc-section'>
  <h2 class='section-title'>Exemple d'utilisation</h2>
  <div class='code-container'>
    <pre><code><span class='comment'>; Création d'un bouton primaire avec coins arrondis</span>
<span class='kw'>Define</span> *btn.UI::CanvasButton = <span class='kw'>New</span> UI::CanvasButton(0, 0, 140, 36, <span class='str'>"Enregistrer"</span>)
*btn\\SetPalettePrimary()
*btn\\SetCornerRadius(8)
*btn\\SetFontName(<span class='str'>"Segoe UI"</span>)
*btn\\SetFontSize(10)</code></pre>
  </div>
</div>
""", "canvasbutton")

save_page("en", "ui/canvasbutton.html", "CanvasButton Class", "Modern vector button control with hover animations, WPF styles, icons, and focus rings.", "badge-ui", "CANVAS", """
<div class='doc-section'>
  <h2 class='section-title'>Overview</h2>
  <p><code>UI::CanvasButton</code> is a high-fidelity vector button providing smooth interactive micro-animations. It natively supports built-in modern palettes (Primary, Secondary, Success, Danger, Dark, Light), vector icons, and declarative trigger styling.</p>
</div>

<div class='doc-section'>
  <h2 class='section-title'>Usage Example</h2>
  <div class='code-container'>
    <pre><code><span class='comment'>; Create a styled primary button with rounded corners</span>
<span class='kw'>Define</span> *btn.UI::CanvasButton = <span class='kw'>New</span> UI::CanvasButton(0, 0, 140, 36, <span class='str'>"Save Changes"</span>)
*btn\\SetPalettePrimary()
*btn\\SetCornerRadius(8)
*btn\\SetFontName(<span class='str'>"Segoe UI"</span>)
*btn\\SetFontSize(10)</code></pre>
  </div>
</div>
""", "canvasbutton")

# ----------------------------------------------------------------------------
# CanvasTextBox
# ----------------------------------------------------------------------------
save_page("fr", "ui/canvastextbox.html", "Classe CanvasTextBox", "Champ de saisie de texte vectoriel avec placeholder, mode mot de passe, défilement et curseur clignotant.", "badge-ui", "CANVAS", """
<div class='doc-section'>
  <h2 class='section-title'>Présentation</h2>
  <p><code>UI::CanvasTextBox</code> remplace les champs de saisie natifs par un contrôle vectoriel personnalisable à l'extrême. Il intègre un texte indicatif (placeholder), la sélection de texte à la souris, un curseur (caret) clignotant fluide, le défilement horizontal automatique et le masquage sécurisé pour mot de passe.</p>
</div>

<div class='doc-section'>
  <h2 class='section-title'>Méthodes Clés</h2>
  <ul>
    <li><code>SetPlaceholder(text.s)</code> : Définit le texte indicatif lorsque le champ est vide.</li>
    <li><code>SetPasswordMode(isPassword.b)</code> : Active ou désactive le masquage des caractères par des puces.</li>
    <li><code>SetText(text.s)</code> / <code>GetText()</code> : Accesseurs de la chaîne saisie.</li>
    <li><code>SetCornerRadius(radius.i)</code> : Coins arrondis modernes.</li>
  </ul>
</div>
""", "canvastextbox")

save_page("en", "ui/canvastextbox.html", "CanvasTextBox Class", "Modern vector text input field featuring placeholder text, password mode, scrolling, and blinking caret.", "badge-ui", "CANVAS", """
<div class='doc-section'>
  <h2 class='section-title'>Overview</h2>
  <p><code>UI::CanvasTextBox</code> provides a sleek vector input control replacing traditional native text boxes. It supports stylish placeholders, mouse selection, blinking system caret, smooth horizontal scroll tracking, and password masking.</p>
</div>

<div class='doc-section'>
  <h2 class='section-title'>Key Methods</h2>
  <ul>
    <li><code>SetPlaceholder(text.s)</code> : Sets placeholder text shown when input is empty and unfocused.</li>
    <li><code>SetPasswordMode(isPassword.b)</code> : Toggles secure bullet character masking.</li>
    <li><code>SetText(text.s)</code> / <code>GetText()</code> : Value getters and setters.</li>
    <li><code>SetCornerRadius(radius.i)</code> : Custom rounded corner radius.</li>
  </ul>
</div>
""", "canvastextbox")

# ----------------------------------------------------------------------------
# CanvasText
# ----------------------------------------------------------------------------
save_page("fr", "ui/canvastext.html", "Classe CanvasText", "Libellé vectoriel haute fidélité avec typographie personnalisée et troncature intelligente par ellipse (...).", "badge-ui", "CANVAS", """
<div class='doc-section'>
  <h2 class='section-title'>Présentation</h2>
  <p><code>UI::CanvasText</code> permet d'afficher des textes avec une typographie vectorielle nette et sans bavure. Lorsque le texte dépasse l'espace alloué, il applique automatiquement une troncature élégante avec points de suspension (Ellipsis <code>...</code>).</p>
</div>
""", "canvastext")

save_page("en", "ui/canvastext.html", "CanvasText Class", "High-fidelity vector text label with custom typography and automated ellipsis truncation (...).", "badge-ui", "CANVAS", """
<div class='doc-section'>
  <h2 class='section-title'>Overview</h2>
  <p><code>UI::CanvasText</code> renders crisp vector labels with fine-grained control over font weight, size, and color. It automatically calculates text layout and appends an ellipsis (<code>...</code>) when bounded text overflows.</p>
</div>
""", "canvastext")

# ----------------------------------------------------------------------------
# CanvasTree
# ----------------------------------------------------------------------------
save_page("fr", "ui/canvastree.html", "Classe CanvasTree", "Arborescence vectorielle moderne avec nœuds hiérarchiques, chevrons, cases à cocher et actions intégrées.", "badge-ui", "CANVAS", """
<div class='doc-section'>
  <h2 class='section-title'>Présentation</h2>
  <p><code>UI::CanvasTree</code> offre une arborescence vectorielle fluide et interactive. Chaque nœud peut disposer d'un chevron de dépliage animé, d'une case à cocher, d'une icône dédiée et de boutons d'action alignés à droite.</p>
</div>
""", "canvastree")

save_page("en", "ui/canvastree.html", "CanvasTree Class", "Modern vector treeview control featuring hierarchical nodes, chevrons, checkboxes, and inline action buttons.", "badge-ui", "CANVAS", """
<div class='doc-section'>
  <h2 class='section-title'>Overview</h2>
  <p><code>UI::CanvasTree</code> delivers an interactive hierarchical tree view. Each node supports expandable animated chevrons, checkboxes, custom icons, and right-aligned interactive action buttons.</p>
</div>
""", "canvastree")

# ----------------------------------------------------------------------------
# Styles & Resource Dictionaries
# ----------------------------------------------------------------------------
save_page("fr", "ui/styles.html", "Moteur de Styles WPF & Dictionnaires", "Système de styles déclaratifs inspiré de WPF/XAML, dictionnaires de ressources et héritage de styles.", "badge-ui", "WPF", """
<div class='doc-section'>
  <h2 class='section-title'>Présentation</h2>
  <p>Le moteur de styles déclaratifs de PureBasic OOP permet de centraliser la charte graphique de votre application dans un fichier XML dédié (ex: <code>styles/Styles.xml</code>). Les styles peuvent être <strong>implicites</strong> (s'appliquant automatiquement à un type de contrôle) ou <strong>nommés</strong> via une clé unique.</p>
</div>

<div class='doc-section'>
  <h2 class='section-title'>Syntaxe XML d'un Style</h2>
  <div class='code-container'>
    <pre><code><span class='kw'>&lt;ResourceDictionary&gt;</span>
  <span class='comment'>&lt;!-- Style avec héritage BasedOn --&gt;</span>
  <span class='kw'>&lt;Style</span> <span class='str'>TargetType="CanvasButton"</span> <span class='str'>Key="PrimaryButton"</span><span class='kw'>&gt;</span>
    <span class='kw'>&lt;Setter</span> <span class='str'>Property="Background"</span> <span class='str'>Value="#4F46E5"</span><span class='kw'>/&gt;</span>
    <span class='kw'>&lt;Setter</span> <span class='str'>Property="TextColor"</span> <span class='str'>Value="#FFFFFF"</span><span class='kw'>/&gt;</span>
    <span class='kw'>&lt;Setter</span> <span class='str'>Property="CornerRadius"</span> <span class='str'>Value="8"</span><span class='kw'>/&gt;</span>
    
    <span class='comment'>&lt;!-- Trigger d'état au survol --&gt;</span>
    <span class='kw'>&lt;Trigger</span> <span class='str'>Property="IsMouseOver"</span> <span class='str'>Value="True"</span><span class='kw'>&gt;</span>
      <span class='kw'>&lt;Setter</span> <span class='str'>Property="Background"</span> <span class='str'>Value="#4338CA"</span><span class='kw'>/&gt;</span>
      <span class='kw'>&lt;Setter</span> <span class='str'>Property="Scale"</span> <span class='str'>Value="1.04"</span> <span class='str'>Easing="Back"</span> <span class='str'>Duration="120"</span><span class='kw'>/&gt;</span>
    <span class='kw'>&lt;/Trigger&gt;</span>
  <span class='kw'>&lt;/Style&gt;</span>
<span class='kw'>&lt;/ResourceDictionary&gt;</span></code></pre>
  </div>
</div>
""", "styles")

save_page("en", "ui/styles.html", "WPF Styles & Resource Dictionaries", "Declarative styling engine inspired by WPF/XAML, resource dictionaries, and style inheritance.", "badge-ui", "WPF", """
<div class='doc-section'>
  <h2 class='section-title'>Overview</h2>
  <p>The PureBasic OOP declarative style system allows you to centralize your design system in dedicated XML files (e.g. <code>styles/Styles.xml</code>). Styles can be <strong>implicit</strong> (automatically targeting all instances of a control type) or <strong>named</strong> with a unique key.</p>
</div>

<div class='doc-section'>
  <h2 class='section-title'>XML Style Syntax</h2>
  <div class='code-container'>
    <pre><code><span class='kw'>&lt;ResourceDictionary&gt;</span>
  <span class='kw'>&lt;Style</span> <span class='str'>TargetType="CanvasButton"</span> <span class='str'>Key="PrimaryButton"</span><span class='kw'>&gt;</span>
    <span class='kw'>&lt;Setter</span> <span class='str'>Property="Background"</span> <span class='str'>Value="#4F46E5"</span><span class='kw'>/&gt;</span>
    <span class='kw'>&lt;Setter</span> <span class='str'>Property="TextColor"</span> <span class='str'>Value="#FFFFFF"</span><span class='kw'>/&gt;</span>
    <span class='kw'>&lt;Setter</span> <span class='str'>Property="CornerRadius"</span> <span class='str'>Value="8"</span><span class='kw'>/&gt;</span>
    
    <span class='kw'>&lt;Trigger</span> <span class='str'>Property="IsMouseOver"</span> <span class='str'>Value="True"</span><span class='kw'>&gt;</span>
      <span class='kw'>&lt;Setter</span> <span class='str'>Property="Background"</span> <span class='str'>Value="#4338CA"</span><span class='kw'>/&gt;</span>
      <span class='kw'>&lt;Setter</span> <span class='str'>Property="Scale"</span> <span class='str'>Value="1.04"</span> <span class='str'>Easing="Back"</span> <span class='str'>Duration="120"</span><span class='kw'>/&gt;</span>
    <span class='kw'>&lt;/Trigger&gt;</span>
  <span class='kw'>&lt;/Style&gt;</span>
<span class='kw'>&lt;/ResourceDictionary&gt;</span></code></pre>
  </div>
</div>
""", "styles")

# ----------------------------------------------------------------------------
# Animations & Triggers
# ----------------------------------------------------------------------------
save_page("fr", "ui/animation.html", "Micro-Animations 60 FPS & Triggers", "Moteur d'animations fluide avec amorti mathématique (Easing) et déclenchement automatique par triggers d'états.", "badge-ui", "60FPS", """
<div class='doc-section'>
  <h2 class='section-title'>Présentation</h2>
  <p><code>UI::AnimationEngine</code> orchestre les micro-interactions fluides en temps réel à 60 images par seconde. Il calcule les interpolations géométriques (Scale, Positions) et chromatiques (Background, BorderColor, TextColor) selon des courbes mathématiques d'amorti (Easing).</p>
</div>

<div class='doc-section'>
  <h2 class='section-title'>Courbes d'Amorti (Easing) Supportées</h2>
  <ul>
    <li><code>Linear</code> : Vitesse constante du début à la fin.</li>
    <li><code>Cubic</code> : Accélération puis décélération progressive.</li>
    <li><code>Back</code> : Léger dépassement élastique avant stabilisation (effet rebond moderne).</li>
  </ul>
</div>
""", "animation")

save_page("en", "ui/animation.html", "60 FPS Micro-Animations & Triggers", "Smooth animation engine powered by mathematical easing curves and automated visual state triggers.", "badge-ui", "60FPS", """
<div class='doc-section'>
  <h2 class='section-title'>Overview</h2>
  <p><code>UI::AnimationEngine</code> drives real-time 60 FPS micro-interactions. It computes geometric (Scale, Position) and chromatic (Background, Border, TextColor) interpolations according to mathematical easing curves.</p>
</div>

<div class='doc-section'>
  <h2 class='section-title'>Supported Easing Curves</h2>
  <ul>
    <li><code>Linear</code> : Constant speed transition.</li>
    <li><code>Cubic</code> : Smooth ease-in and ease-out acceleration curve.</li>
    <li><code>Back</code> : Subtle spring overshoot before settling (modern tactile bounce effect).</li>
  </ul>
</div>
""", "animation")

# ----------------------------------------------------------------------------
# XMLLoader
# ----------------------------------------------------------------------------
save_page("fr", "ui/xmlloader.html", "Chargeur Déclaratif XML", "Création d'interfaces déclaratives XML, chargement automatique des vues et liaison avec le ViewModel.", "badge-ui", "XML", """
<div class='doc-section'>
  <h2 class='section-title'>Présentation</h2>
  <p><code>UI::XMLLoader</code> analyse et instancie automatiquement l'arbre des composants visuels défini dans un fichier XML (format proche de XAML/WPF), en appliquant les styles, les conteneurs de layout et les liaisons MVVM bidirectionnelles.</p>
</div>

<div class='doc-section'>
  <h2 class='section-title'>Exemple de Chargement de Vue</h2>
  <div class='code-container'>
    <pre><code><span class='comment'>; Chargement de la vue XML avec injection automatique du ViewModel</span>
<span class='kw'>Define</span> *view.UI::Window = UI::XMLLoader::LoadView(<span class='str'>"views/MainView.xml"</span>, *myViewModel)
*app\\SetMainWindow(*view)
*app\\Run()</code></pre>
  </div>
</div>
""", "xmlloader")

save_page("en", "ui/xmlloader.html", "XML Declarative Loader", "Declarative XML UI construction, automated view instantiation, and seamless ViewModel data-binding.", "badge-ui", "XML", """
<div class='doc-section'>
  <h2 class='section-title'>Overview</h2>
  <p><code>UI::XMLLoader</code> parses and instantiates the hierarchical visual component tree defined in XML (similar to XAML/WPF), automatically wiring layout panels, styles, and two-way MVVM data-bindings.</p>
</div>

<div class='doc-section'>
  <h2 class='section-title'>View Loading Example</h2>
  <div class='code-container'>
    <pre><code><span class='comment'>; Load declarative XML view with injected ViewModel DataContext</span>
<span class='kw'>Define</span> *view.UI::Window = UI::XMLLoader::LoadView(<span class='str'>"views/MainView.xml"</span>, *myViewModel)
*app\\SetMainWindow(*view)
*app\\Run()</code></pre>
  </div>
</div>
""", "xmlloader")
'''

with open(GEN_SCRIPT, "r", encoding="utf-8") as f:
    code = f.read()

# Insert before the final print statement
last_print = 'print("All HTML documentation files with inheritance hierarchy & MVVM generated successfully!")'
code = code.replace(last_print, NEW_PAGES_CODE + "\n" + last_print)

with open(GEN_SCRIPT, "w", encoding="utf-8") as f:
    f.write(code)

print("Appended 8 new pages to generate_all_html_docs.py successfully!")
