# -*- coding: utf-8 -*-
# ============================================================================
# PureBasic OOP Complete HTML Documentation Generator
# Generates all HTML documentation files for IDE F1 Help (FR & EN)
# Author: MicrodevWeb
# ============================================================================

import os
import sys

BASE_HTML_DIR = r"c:\PB\PB_PROJECT\PB_OOP_WORKSPACE\PUREBASIC_OOP_WORKSPACE\doc\html"

NAV_ITEMS_FR = [
    ("Introduction", [
        ("index", "Vue d'ensemble", "index.html", None)
    ]),
    ("Mots-clés POO", [
        ("class", "Class / Abstract", "keywords/class.html", "KW"),
        ("method", "Method / Override", "keywords/method.html", "KW"),
        ("properties", "Getter / Setter / Prop", "keywords/properties.html", "KW"),
        ("inheritance", "Extends / Super", "keywords/inheritance.html", "KW"),
        ("encapsulation", "Public / Protected / Private", "keywords/encapsulation.html", "KW"),
        ("lifecycle", "New / Free / Init", "keywords/lifecycle.html", "KW"),
        ("operators", "This / Cast / TypeOf", "keywords/operators.html", "KW")
    ]),
    ("Composants UI", [
        ("application", "Application", "ui/application.html", "UI"),
        ("window", "Window", "ui/window.html", "UI"),
        ("gadget", "Gadget / Component", "ui/gadget.html", "UI"),
        ("button", "Button", "ui/button.html", "UI"),
        ("checkbox", "CheckBox", "ui/checkbox.html", "UI"),
        ("combobox", "ComboBox", "ui/combobox.html", "UI"),
        ("label", "Label", "ui/label.html", "UI"),
        ("listicon", "ListIcon", "ui/listicon.html", "UI"),
        ("progressbar", "ProgressBar", "ui/progressbar.html", "UI"),
        ("slider", "Slider", "ui/slider.html", "UI"),
        ("textbox", "TextBox", "ui/textbox.html", "UI"),
        ("toggleswitch", "ToggleSwitch", "ui/toggleswitch.html", "UI")
    ]),
    ("Layouts Responsifs (WPF)", [
        ("container", "Container", "ui/container.html", "WPF"),
        ("stackpanel", "StackPanel", "ui/stackpanel.html", "WPF"),
        ("dockpanel", "DockPanel", "ui/dockpanel.html", "WPF"),
        ("grid", "Grid", "ui/grid.html", "WPF")
    ])
]

NAV_ITEMS_EN = [
    ("Getting Started", [
        ("index", "Overview", "index.html", None)
    ]),
    ("OOP Keywords", [
        ("class", "Class / Abstract", "keywords/class.html", "KW"),
        ("method", "Method / Override", "keywords/method.html", "KW"),
        ("properties", "Getter / Setter / Prop", "keywords/properties.html", "KW"),
        ("inheritance", "Extends / Super", "keywords/inheritance.html", "KW"),
        ("encapsulation", "Public / Protected / Private", "keywords/encapsulation.html", "KW"),
        ("lifecycle", "New / Free / Init", "keywords/lifecycle.html", "KW"),
        ("operators", "This / Cast / TypeOf", "keywords/operators.html", "KW")
    ]),
    ("UI Components", [
        ("application", "Application", "ui/application.html", "UI"),
        ("window", "Window", "ui/window.html", "UI"),
        ("gadget", "Gadget / Component", "ui/gadget.html", "UI"),
        ("button", "Button", "ui/button.html", "UI"),
        ("checkbox", "CheckBox", "ui/checkbox.html", "UI"),
        ("combobox", "ComboBox", "ui/combobox.html", "UI"),
        ("label", "Label", "ui/label.html", "UI"),
        ("listicon", "ListIcon", "ui/listicon.html", "UI"),
        ("progressbar", "ProgressBar", "ui/progressbar.html", "UI"),
        ("slider", "Slider", "ui/slider.html", "UI"),
        ("textbox", "TextBox", "ui/textbox.html", "UI"),
        ("toggleswitch", "ToggleSwitch", "ui/toggleswitch.html", "UI")
    ]),
    ("Responsive Layouts (WPF)", [
        ("container", "Container", "ui/container.html", "WPF"),
        ("stackpanel", "StackPanel", "ui/stackpanel.html", "WPF"),
        ("dockpanel", "DockPanel", "ui/dockpanel.html", "WPF"),
        ("grid", "Grid", "ui/grid.html", "WPF")
    ])
]

def render_sidebar(lang, current_key, rel_root):
    nav_data = NAV_ITEMS_FR if lang == "fr" else NAV_ITEMS_EN
    s = ["<nav class='doc-sidebar'>"]
    for section_title, items in nav_data:
        s.append("  <div class='nav-section'>")
        s.append(f"    <div class='nav-section-title'>{section_title}</div>")
        s.append("    <ul class='nav-list'>")
        for key, label, link, badge in items:
            active_cls = " active" if key == current_key else ""
            badge_html = f"<span class='badge badge-{badge.lower()}'>{badge}</span>" if badge else ""
            s.append(f"      <li class='nav-item{active_cls}'><a href='{rel_root}{link}'><span>{label}</span>{badge_html}</a></li>")
        s.append("    </ul>")
        s.append("  </div>")
    s.append("</nav>")
    return "\n".join(s)

def render_page(lang, current_key, rel_target, title, lead, badge_type, badge_text, content_html):
    is_fr = (lang == "fr")
    rel_root = "../" if "/" in rel_target else ""
    switch_url = ("../en/" if is_fr else "../fr/") + rel_target
    
    fr_btn_cls = "lang-btn active" if is_fr else "lang-btn"
    en_btn_cls = "lang-btn" if is_fr else "lang-btn active"
    fr_btn_href = "#" if is_fr else ("../fr/" + rel_target)
    en_btn_href = ("../en/" + rel_target) if is_fr else "#"

    breadcrumb_section = "Keywords" if "keywords/" in rel_target else ("Composants UI" if is_fr else "UI Components") if "ui/" in rel_target else ""
    breadcrumb_html = ""
    if rel_target != "index.html":
        breadcrumb_html = f"""
        <span class='breadcrumb-separator'>/</span>
        <span>{breadcrumb_section}</span>
        <span class='breadcrumb-separator'>/</span>
        <span style='color: var(--accent-blue);'>{title}</span>
        """

    badge_html = f"<span class='badge {badge_type}'>{badge_text}</span>" if badge_text else ""
    lead_html = f"<p class='page-lead'>{lead}</p>" if lead else ""

    html = f"""<!DOCTYPE html>
<html lang='{lang}'>
<head>
  <meta charset='UTF-8'>
  <meta name='viewport' content='width=device-width, initial-scale=1.0'>
  <title>{title} - PureBasic OOP Documentation</title>
  <link rel='stylesheet' href='{rel_root}../css/doc_theme.css'>
</head>
<body>
  <header class='doc-header'>
    <a href='{rel_root}index.html' class='brand-container'>
      <img src='{rel_root}../assets/PB_OOP_LOGO.jpeg' alt='Logo' class='brand-logo'>
      <span class='brand-title'>PureBasic OOP</span>
      <span class='brand-version'>v1.2 Native</span>
    </a>
    <div class='header-controls'>
      <div class='search-box'>
        <span class='search-icon'>&#128269;</span>
        <input type='text' class='search-input' id='search-input' placeholder='{"Rechercher..." if is_fr else "Search docs..."}'>
      </div>
      <div class='lang-switch'>
        <a href='{fr_btn_href}' class='{fr_btn_cls}'>FR</a>
        <a href='{en_btn_href}' class='{en_btn_cls}'>EN</a>
      </div>
    </div>
  </header>
  
  <div class='layout-container'>
{render_sidebar(lang, current_key, rel_root)}
    <main class='doc-content'>
      <div class='breadcrumb'>
        <a href='{rel_root}index.html'>{"Accueil" if is_fr else "Home"}</a>
        {breadcrumb_html}
      </div>
      
      <div class='page-header'>
        <div class='title-row'>
          <h1 class='page-title'>{title}</h1>
          {badge_html}
        </div>
        {lead_html}
      </div>
      
      {content_html}
    </main>
  </div>
  
  <footer class='doc-footer'>
    <p>&copy; 2026 PureBasic OOP Project - MicrodevWeb | Dual License GPL v3 / Fantaisie Software</p>
  </footer>
  
  <script>
    document.getElementById('search-input').addEventListener('input', function(e) {{
      let filter = e.target.value.toLowerCase();
      document.querySelectorAll('.nav-item').forEach(function(item) {{
        let text = item.innerText.toLowerCase();
        if (text.includes(filter)) {{
          item.style.display = '';
        }} else {{
          item.style.display = 'none';
        }}
      }});
    }});
  </script>
</body>
</html>
"""
    return html

def save_page(lang, rel_path, title, lead, badge_type, badge_text, content_html, current_key):
    full_path = os.path.join(BASE_HTML_DIR, lang, rel_path.replace("/", "\\"))
    os.makedirs(os.path.dirname(full_path), exist_ok=True)
    html_str = render_page(lang, current_key, rel_path, title, lead, badge_type, badge_text, content_html)
    with open(full_path, "w", encoding="utf-8") as f:
        f.write(html_str)
    print(f"Generated [{lang}]: {rel_path}")

# ============================================================================
# 1. FRENCH PAGES
# ============================================================================

# FR Index
save_page("fr", "index.html", "Vue d'ensemble", "Documentation officielle du langage PureBasic Orienté Objet.", "badge-info", "Aperçu", """
<div class='doc-section'>
  <h2 class='section-title'>Bienvenue dans PureBasic OOP</h2>
  <p>PureBasic OOP apporte la puissance de la Programmation Orientée Objet complète à PureBasic grâce à un transpileur optimisé et une bibliothèque UI native moderne.</p>
  <div class='callout callout-tip'>
    <div class='callout-title'>💡 Touche d'aide contextuelle F1</div>
    <p>Dans l'IDE, placez votre curseur sur n'importe quel mot-clé POO (<code>Class</code>, <code>Method</code>, <code>Super</code>, <code>Property</code>...) ou composant UI (<code>Window</code>, <code>Button</code>, <code>StackPanel</code>, <code>ListIcon</code>...) et appuyez sur <strong>F1</strong> pour ouvrir directement sa fiche d'aide détaillée !</p>
  </div>
</div>
<div class='doc-section'>
  <h2 class='section-title'>Fonctionnalités Principales</h2>
  <ul>
    <li><strong>Classes & Héritage Simple :</strong> Définition élégante avec <code>Class ... Extends</code>, surcharge de méthodes et appel parent <code>Super::</code>.</li>
    <li><strong>Surcharge de Constructeurs :</strong> Plusieurs constructeurs <code>Init(...)</code> par classe pour s'adapter à tous les usages (layouts automatiques ou fenêtres fixes).</li>
    <li><strong>Système de Layouts Responsifs (Style WPF) :</strong> <code>StackPanel</code>, <code>DockPanel</code>, <code>Grid</code>, <code>Container</code> avec dimensionnement Star (*), marges et alignements fluides.</li>
    <li><strong>Cycle de Vie Sécurisé :</strong> Instanciation par <code>New</code> et libération automatique ou manuelle via <code>Free</code>.</li>
  </ul>
</div>
""", "index")

# FR Keywords: Class
save_page("fr", "keywords/class.html", "Mots-clés Class & Abstract", "Définition de classes concrètes et abstraites en PureBasic OOP.", "badge-keyword", "Keyword", """
<div class='doc-section'>
  <h2 class='section-title'>Syntaxe</h2>
  <div class='code-container'>
    <div class='code-header'><span class='code-title'>Déclaration de classe (.pbo)</span><span class='code-badge'>PBO</span></div>
    <pre><code><span class='kw'>Class</span> NomDeClasse [<span class='kw'>Extends</span> ClasseParente] {
  <span class='kw'>Public</span> [attributs / méthodes]
  <span class='kw'>Protected</span> [attributs / méthodes]
  <span class='kw'>Private</span> [attributs / méthodes]
}</code></pre>
  </div>
</div>
<div class='doc-section'>
  <h2 class='section-title'>Classes Abstraites</h2>
  <p>Une classe déclarée avec <code>Abstract Class</code> ne peut pas être instanciée directement via <code>New</code>. Elle sert de contrat et de socle commun pour des sous-classes concrètes.</p>
</div>
""", "class")

# FR Keywords: Method
save_page("fr", "keywords/method.html", "Mots-clés Method & Override", "Déclaration et surcharge de méthodes virtuelles.", "badge-keyword", "Keyword", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>Les méthodes définissent les comportements associés à une classe. En PureBasic OOP, toutes les méthodes d'instance sont virtuelles et résolues via une table de pointeurs (VTable) hautement optimisée.</p>
</div>
<div class='doc-section'>
  <h2 class='section-title'>Surcharge de Méthodes (Overloading)</h2>
  <p>Une classe peut définir plusieurs méthodes portant le même nom avec des signatures différentes (nombres ou types de paramètres distincts) :</p>
  <div class='code-container'>
    <pre><code><span class='kw'>Public</span> <span class='kw'>Method</span> <span class='fn'>Log</span>(message.s) { ... }
<span class='kw'>Public</span> <span class='kw'>Method</span> <span class='fn'>Log</span>(message.s, niveau.i) { ... }</code></pre>
  </div>
</div>
""", "method")

# FR Keywords: Properties
save_page("fr", "keywords/properties.html", "Getters, Setters & Propriétés", "Encapsulation élégante des données membres.", "badge-keyword", "Keyword", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>Les accesseurs <code>Get</code> et <code>Set</code> permettent de contrôler la lecture et l'écriture des champs internes tout en offrant une interface propre.</p>
</div>
<div class='doc-section'>
  <h2 class='section-title'>Syntaxe</h2>
  <div class='code-container'>
    <pre><code><span class='kw'>Class</span> CompteBancaire {
  <span class='kw'>Private</span> solde.d
  
  <span class='kw'>Public</span> <span class='kw'>Property</span> Solde.d {
    <span class='kw'>Get</span> { <span class='kw'>ProcedureReturn</span> <span class='kw'>This</span>\\solde }
    <span class='kw'>Set</span>(val.d) { <span class='kw'>If</span> val >= <span class='num'>0</span> : <span class='kw'>This</span>\\solde = val : <span class='kw'>EndIf</span> }
  }
}</code></pre>
  </div>
</div>
""", "properties")

# FR Keywords: Inheritance
save_page("fr", "keywords/inheritance.html", "Héritage : Extends & Super", "Dérivation de classes et appel aux implémentations parentes.", "badge-keyword", "Keyword", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>Le mot-clé <code>Extends</code> établit un lien d'héritage simple entre une classe dérivée et sa classe mère. Le mot-clé <code>Super::</code> permet d'invoquer un constructeur ou une méthode de la classe parente.</p>
</div>
<div class='doc-section'>
  <h2 class='section-title'>Constructeurs Parents</h2>
  <p>Depuis la version 1.2, chaque classe enfant définit ses propres constructeurs <code>Init(...)</code> et appelle explicitement le constructeur parent souhaité :</p>
  <div class='code-container'>
    <pre><code><span class='kw'>Class</span> Guerrier <span class='kw'>Extends</span> Personnage {
  <span class='kw'>Public</span> <span class='kw'>Method</span> <span class='fn'>Init</span>(nom.s) {
    <span class='kw'>Super</span>::<span class='fn'>Init</span>(nom, <span class='num'>150</span>) <span class='cm'>; Appelle Personnage::Init(nom, pv)</span>
  }
}</code></pre>
  </div>
</div>
""", "inheritance")

# FR Keywords: Encapsulation
save_page("fr", "keywords/encapsulation.html", "Encapsulation : Public / Protected / Private", "Contrôle des portées et visibilités des membres.", "badge-keyword", "Keyword", """
<div class='doc-section'>
  <h2 class='section-title'>Niveaux de Visibilité</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Modificateur</th><th>Description</th></tr>
      <tr><td><code>Public</code></td><td>Accessible depuis l'extérieur, les instances et les classes dérivées.</td></tr>
      <tr><td><code>Protected</code></td><td>Accessible uniquement au sein de la classe et de ses classes filles.</td></tr>
      <tr><td><code>Private</code></td><td>Accessible exclusivement au sein de la classe déclarante.</td></tr>
    </table>
  </div>
</div>
""", "encapsulation")

# FR Keywords: Lifecycle
save_page("fr", "keywords/lifecycle.html", "Cycle de Vie : New, Free & Init", "Instanciation, initialisation et destruction sécurisée des objets.", "badge-keyword", "Keyword", """
<div class='doc-section'>
  <h2 class='section-title'>Cycle d'un Objet</h2>
  <ol>
    <li><strong>Allocation & Construction :</strong> <code>*obj.MaClasse = New MaClasse(args...)</code> alloue la mémoire et exécute le constructeur <code>Init(...)</code> correspondant.</li>
    <li><strong>Utilisation :</strong> Appel des méthodes via la flèche <code>*obj\\MaMethode()</code>.</li>
    <li><strong>Destruction :</strong> <code>*obj\\Free()</code> exécute le destructeur <code>Free()</code> personnalisé et libère la mémoire.</li>
  </ol>
</div>
""", "lifecycle")

# FR Keywords: Operators
save_page("fr", "keywords/operators.html", "Opérateurs : This, Cast & TypeOf", "Opérateurs de référence d'instance et introspection.", "badge-keyword", "Keyword", """
<div class='doc-section'>
  <h2 class='section-title'>Opérateurs d'Instance</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Opérateur</th><th>Description</th></tr>
      <tr><td><code>This</code></td><td>Pointeur sur l'instance courante de la classe.</td></tr>
      <tr><td><code>Cast(*obj, ClasseCible)</code></td><td>Transtypage explicite sécurisé d'un pointeur d'objet.</td></tr>
      <tr><td><code>TypeOf(*obj)</code></td><td>Renvoie l'identifiant de type ou le nom de la classe de l'objet.</td></tr>
    </table>
  </div>
</div>
""", "operators")

# FR UI: Application
save_page("fr", "ui/application.html", "Classe Application", "Boucle principale d'événements et gestion du cycle de vie de l'application.", "badge-ui", "UI Class", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>La classe <code>UI::Application</code> encapsule la boucle événementielle PureBasic (<code>WaitWindowEvent</code>), la gestion des fenêtres et l'arrêt propre du programme.</p>
</div>
<div class='doc-section'>
  <h2 class='section-title'>M&eacute;thodes Principales</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Méthode</th><th>Description</th></tr>
      <tr><td><code>Run()</code></td><td>Démarre la boucle principale d'événements jusqu'à la fermeture de toutes les fenêtres ou un appel à <code>Exit()</code>.</td></tr>
      <tr><td><code>Exit(exitCode.i = 0)</code></td><td>Arrête proprement l'application et libère les ressources.</td></tr>
      <tr><td><code>AddWindow(*win)</code></td><td>Enregistre une fenêtre dans la boucle événementielle.</td></tr>
    </table>
  </div>
</div>
""", "application")

# FR UI: Window
save_page("fr", "ui/window.html", "Classe Window", "Création flexible de fenêtres avec constructeurs multiples et accesseurs dynamiques.", "badge-ui", "UI Class", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>La classe <code>UI::Window</code> encapsule une fenêtre graphique native PureBasic avec support complet du responsive design, fermeture propre sans erreur et multiples constructeurs.</p>
</div>
<div class='doc-section'>
  <h2 class='section-title'>Constructeurs Surchargés</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Constructeur</th><th>Description</th></tr>
      <tr><td><code>Init(title.s)</code></td><td>Crée une fenêtre centrée 800&times;600 avec contrôles minimiser, maximiser et redimensionner.</td></tr>
      <tr><td><code>Init(title.s, w.i, h.i)</code></td><td>Fenêtre centrée avec largeur et hauteur personnalisées.</td></tr>
      <tr><td><code>Init(title.s, w.i, h.i, flags.i)</code></td><td>Fenêtre avec dimensions et flags PureBasic (ex: <code>#PB_Window_Tool</code>, <code>#PB_Window_BorderLess</code>).</td></tr>
      <tr><td><code>Init(title.s, x.i, y.i, w.i, h.i)</code></td><td>Position absolue et dimensions spécifiées.</td></tr>
      <tr><td><code>Init(title.s, x.i, y.i, w.i, h.i, flags.i)</code></td><td>Position absolue, dimensions et flags.</td></tr>
      <tr><td><code>Init(title.s, x.i, y.i, w.i, h.i, flags.i, parent.i)</code></td><td>Fenêtre complète avec identifiant de fenêtre parente.</td></tr>
    </table>
  </div>
</div>
<div class='doc-section'>
  <h2 class='section-title'>M&eacute;thodes Principales</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Méthode</th><th>Description</th></tr>
      <tr><td><code>SetRootComponent(*comp)</code></td><td>Définit le layout racine (ex: <code>StackPanel</code>, <code>DockPanel</code>, <code>Grid</code>) qui se redimensionnera automatiquement.</td></tr>
      <tr><td><code>SetTitle(t.s)</code> / <code>GetTitle()</code></td><td>Modifie ou récupère le titre de la fenêtre.</td></tr>
      <tr><td><code>SetSize(w.i, h.i)</code></td><td>Redimensionne dynamiquement la fenêtre.</td></tr>
      <tr><td><code>OnClose()</code></td><td>Méthode virtuelle appelée à la fermeture de la fenêtre.</td></tr>
      <tr><td><code>OnResize()</code></td><td>Méthode virtuelle appelée lors du redimensionnement.</td></tr>
    </table>
  </div>
</div>
""", "window")

# FR UI: Gadget / Component
save_page("fr", "ui/gadget.html", "Classe Gadget & Component", "Classe de base abstraite pour tous les contrôles UI et layouts.", "badge-ui", "UI Class", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>La classe abstraite <code>UI::Component</code> et sa spécialisation <code>UI::Gadget</code> constituent le socle de tous les contrôles graphiques et panneaux de mise en page responsive.</p>
  <p>Elles fournissent la gestion automatique des coordonnées (<code>x</code>, <code>y</code>, <code>width</code>, <code>height</code>), des dimensions minimales / maximales, des marges (<code>Margin</code>), des alignements (<code>HorizontalAlignment</code>, <code>VerticalAlignment</code>), de la visibilité, de l'état activé/désactivé, et du routage unifié des événements.</p>
</div>
<div class='doc-section'>
  <h2 class='section-title'>M&eacute;thodes Principales</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Méthode</th><th>Description</th></tr>
      <tr><td><code>SetMargin(l.i, t.i, r.i, b.i)</code> / <code>SetMarginAll(m.i)</code></td><td>Définit les marges externes autour du contrôle.</td></tr>
      <tr><td><code>SetHorizontalAlignment(align.i)</code></td><td>Alignement horizontal (<code>#UI_Align_Left</code>, <code>#UI_Align_Center</code>, <code>#UI_Align_Right</code>, <code>#UI_Align_Stretch</code>).</td></tr>
      <tr><td><code>SetVerticalAlignment(align.i)</code></td><td>Alignement vertical (<code>#UI_Align_Top</code>, <code>#UI_Align_Middle</code>, <code>#UI_Align_Bottom</code>, <code>#UI_Align_VStretch</code>).</td></tr>
      <tr><td><code>SetVisible(v.b)</code> / <code>IsVisible()</code></td><td>Contrôle la visibilité du composant.</td></tr>
      <tr><td><code>SetEnabled(e.b)</code> / <code>IsEnabled()</code></td><td>Active ou désactive l'interaction utilisateur.</td></tr>
      <tr><td><code>SetToolTip(tip.s)</code></td><td>Définit l'infobulle d'aide au survol.</td></tr>
      <tr><td><code>SetFocus()</code></td><td>Donne le focus clavier au gadget.</td></tr>
    </table>
  </div>
</div>
""", "gadget")

# FR UI: Button
save_page("fr", "ui/button.html", "Classe Button", "Contrôle bouton poussoir cliquable avec multi-constructeurs et gestion d'événements.", "badge-ui", "UI Class", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>La classe <code>UI::Button</code> encapsule un bouton poussoir cliquable PureBasic avec gestion directe de l'événement virtuel <code>OnClick()</code> et prise en charge des layouts réactifs.</p>
</div>
<div class='doc-section'>
  <h2 class='section-title'>Constructeurs Surchargés</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Constructeur</th><th>Description</th></tr>
      <tr><td><code>Init(text.s)</code></td><td>Crée un bouton avec texte (taille par défaut 120&times;30 pour les layouts automatiques).</td></tr>
      <tr><td><code>Init(text.s, w.i, h.i)</code></td><td>Crée un bouton avec texte et dimensions spécifiées.</td></tr>
      <tr><td><code>Init(x.i, y.i, w.i, h.i, text.s)</code></td><td>Positionnement absolu avec coordonnées, dimensions et texte.</td></tr>
      <tr><td><code>Init(x.i, y.i, w.i, h.i, text.s, flags.i)</code></td><td>Création complète avec flags PureBasic (ex: <code>#PB_Button_Default</code>, <code>#PB_Button_Toggle</code>).</td></tr>
    </table>
  </div>
</div>
<div class='doc-section'>
  <h2 class='section-title'>Exemple d'utilisation</h2>
  <div class='code-container'>
    <div class='code-header'><span class='code-title'>Bouton standard & personnalisé (.pbo)</span><span class='code-badge'>PBO</span></div>
    <pre><code><span class='kw'>Using</span> <span class='tp'>UI</span>

<span class='cm'>; 1. Création simple pour un layout</span>
<span class='kw'>Define</span> *btnValider.<span class='tp'>Button</span> = <span class='kw'>New</span> <span class='tp'>Button</span>(<span class='str'>"Valider"</span>)
*stackPanel\\<span class='fn'>AddChild</span>(*btnValider)

<span class='cm'>; 2. Bouton personnalisé avec logique de clic</span>
<span class='kw'>Class</span> MonBouton <span class='kw'>Extends</span> <span class='tp'>Button</span> {
  <span class='kw'>Public</span> <span class='kw'>Method</span> <span class='fn'>OnClick</span>() {
    <span class='fn'>MessageRequester</span>(<span class='str'>"Info"</span>, <span class='str'>"Clic sur "</span> + <span class='kw'>This</span>\\<span class='fn'>GetText</span>())
  }
}</code></pre>
  </div>
</div>
""", "button")

# FR UI: TextBox
save_page("fr", "ui/textbox.html", "Classe TextBox", "Champ de saisie texte avec multi-constructeurs et événement OnChange.", "badge-ui", "UI Class", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>La classe <code>UI::TextBox</code> encapsule un champ de saisie texte (<code>StringGadget</code>) avec accès direct au texte, validation et événement <code>OnChange()</code>.</p>
</div>
<div class='doc-section'>
  <h2 class='section-title'>Constructeurs Surchargés</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Constructeur</th><th>Description</th></tr>
      <tr><td><code>Init()</code></td><td>Champ vide (150&times;25 par défaut).</td></tr>
      <tr><td><code>Init(defaultText.s)</code></td><td>Champ initialisé avec le texte par défaut.</td></tr>
      <tr><td><code>Init(defaultText.s, w.i, h.i)</code></td><td>Champ avec texte et dimensions souhaitées.</td></tr>
      <tr><td><code>Init(x.i, y.i, w.i, h.i, defaultText.s)</code></td><td>Positionnement absolu, dimensions et texte.</td></tr>
      <tr><td><code>Init(x.i, y.i, w.i, h.i, defaultText.s, flags.i)</code></td><td>Complet avec flags PureBasic (ex: <code>#PB_String_Password</code>, <code>#PB_String_Numeric</code>, <code>#PB_String_ReadOnly</code>).</td></tr>
    </table>
  </div>
</div>
<div class='doc-section'>
  <h2 class='section-title'>M&eacute;thodes Principales</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Méthode</th><th>Description</th></tr>
      <tr><td><code>GetText()</code> / <code>SetText(str.s)</code></td><td>Lecture et modification du contenu textuel.</td></tr>
      <tr><td><code>SetReadOnly(state.b)</code> / <code>IsReadOnly()</code></td><td>Verrouille le champ en lecture seule.</td></tr>
      <tr><td><code>OnChange()</code></td><td>Méthode virtuelle déclenchée à chaque frappe au clavier.</td></tr>
    </table>
  </div>
</div>
""", "textbox")

# FR UI: Label
save_page("fr", "ui/label.html", "Classe Label", "Libellé texte statique avec multi-constructeurs et alignements.", "badge-ui", "UI Class", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>La classe <code>UI::Label</code> encapsule un texte statique d'interface (<code>TextGadget</code>) avec styles et alignements.</p>
</div>
<div class='doc-section'>
  <h2 class='section-title'>Constructeurs Surchargés</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Constructeur</th><th>Description</th></tr>
      <tr><td><code>Init(text.s)</code></td><td>Texte statique (dimensions automatiques pour layout).</td></tr>
      <tr><td><code>Init(text.s, w.i, h.i)</code></td><td>Texte et dimensions personnalisées.</td></tr>
      <tr><td><code>Init(x.i, y.i, w.i, h.i, text.s)</code></td><td>Positionnement absolu, dimensions et texte.</td></tr>
      <tr><td><code>Init(x.i, y.i, w.i, h.i, text.s, flags.i)</code></td><td>Complet avec flags d'alignement (<code>#PB_Text_Center</code>, <code>#PB_Text_Right</code>, <code>#PB_Text_Border</code>).</td></tr>
    </table>
  </div>
</div>
""", "label")

# FR UI: CheckBox
save_page("fr", "ui/checkbox.html", "Classe CheckBox", "Case à cocher booléenne avec multi-constructeurs et gestion d'état.", "badge-ui", "UI Class", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>La classe <code>UI::CheckBox</code> encapsule une case à cocher booléenne avec états actif/inactif et callback <code>OnClick()</code>.</p>
</div>
<div class='doc-section'>
  <h2 class='section-title'>Constructeurs Surchargés</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Constructeur</th><th>Description</th></tr>
      <tr><td><code>Init(text.s)</code></td><td>Case à cocher décochée par défaut (150&times;25).</td></tr>
      <tr><td><code>Init(text.s, checked.b)</code></td><td>Case avec texte et état initial spécifié.</td></tr>
      <tr><td><code>Init(text.s, w.i, h.i, checked.b)</code></td><td>Case avec texte, dimensions et état initial.</td></tr>
      <tr><td><code>Init(x.i, y.i, w.i, h.i, text.s, flags.i)</code></td><td>Complet avec position absolue et flags.</td></tr>
    </table>
  </div>
</div>
<div class='doc-section'>
  <h2 class='section-title'>M&eacute;thodes Principales</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Méthode</th><th>Description</th></tr>
      <tr><td><code>IsChecked()</code></td><td>Renvoie <code>#True</code> si cochée, <code>#False</code> sinon.</td></tr>
      <tr><td><code>SetChecked(state.b)</code></td><td>Modifie l'état de la case à cocher.</td></tr>
    </table>
  </div>
</div>
""", "checkbox")

# FR UI: ComboBox
save_page("fr", "ui/combobox.html", "Classe ComboBox", "Liste déroulante sélectionnable avec multi-constructeurs.", "badge-ui", "UI Class", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>La classe <code>UI::ComboBox</code> encapsule une liste déroulante sélectionnable avec événement <code>OnChange()</code>.</p>
</div>
<div class='doc-section'>
  <h2 class='section-title'>Constructeurs Surchargés</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Constructeur</th><th>Description</th></tr>
      <tr><td><code>Init()</code></td><td>Liste déroulante par défaut (150&times;25).</td></tr>
      <tr><td><code>Init(w.i, h.i)</code></td><td>Dimensions personnalisées.</td></tr>
      <tr><td><code>Init(x.i, y.i, w.i, h.i)</code></td><td>Position absolue et dimensions.</td></tr>
      <tr><td><code>Init(x.i, y.i, w.i, h.i, flags.i)</code></td><td>Complet avec flags PureBasic (ex: <code>#PB_ComboBox_Editable</code>, <code>#PB_ComboBox_LowerCase</code>).</td></tr>
    </table>
  </div>
</div>
<div class='doc-section'>
  <h2 class='section-title'>M&eacute;thodes Principales</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Méthode</th><th>Description</th></tr>
      <tr><td><code>AddItem(text.s)</code></td><td>Ajoute un élément à la fin de la liste.</td></tr>
      <tr><td><code>GetSelectedIndex()</code> / <code>SetSelectedIndex(idx.i)</code></td><td>Index de l'élément actif (0 à N-1, ou -1 si aucun).</td></tr>
      <tr><td><code>GetSelectedItem()</code></td><td>Renvoie le texte de l'élément actuellement sélectionné.</td></tr>
      <tr><td><code>Clear()</code></td><td>Vide tous les éléments de la liste.</td></tr>
    </table>
  </div>
</div>
""", "combobox")

# FR UI: ListIcon
save_page("fr", "ui/listicon.html", "Classe ListIcon", "Table et grille de données multi-colonnes avec multi-constructeurs.", "badge-ui", "UI Class", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>La classe <code>UI::ListIcon</code> encapsule une table / grille de données multi-colonnes (<code>ListIconGadget</code>) avec sélection de ligne et gestion d'événements.</p>
</div>
<div class='doc-section'>
  <h2 class='section-title'>Constructeurs Surchargés</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Constructeur</th><th>Description</th></tr>
      <tr><td><code>Init(title.s, colWidth.i)</code></td><td>Crée la table avec sa première colonne (pleine ligne sélectionnable par défaut).</td></tr>
      <tr><td><code>Init(title.s, colWidth.i, flags.i)</code></td><td>Création avec flags personnalisés (<code>#PB_ListIcon_GridLines</code>, <code>#PB_ListIcon_CheckBoxes</code>, etc.).</td></tr>
      <tr><td><code>Init(x.i, y.i, w.i, h.i, title.s, colWidth.i)</code></td><td>Positionnement absolu et dimensions.</td></tr>
      <tr><td><code>Init(x.i, y.i, w.i, h.i, title.s, colWidth.i, flags.i)</code></td><td>Complet avec position, dimensions, titre de colonne et flags.</td></tr>
    </table>
  </div>
</div>
<div class='doc-section'>
  <h2 class='section-title'>M&eacute;thodes Principales</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Méthode</th><th>Description</th></tr>
      <tr><td><code>AddColumn(colIdx.i, title.s, width.i)</code></td><td>Ajoute une nouvelle colonne à la table.</td></tr>
      <tr><td><code>AddItem(text.s, icon.i = 0, itemIdx.i = -1)</code></td><td>Insère une nouvelle ligne (champs séparés par <code>Chr(10)</code>).</td></tr>
      <tr><td><code>GetSelectedIndex()</code> / <code>SetSelectedIndex(idx.i)</code></td><td>Index de la ligne active (-1 si aucune).</td></tr>
      <tr><td><code>GetItemText(itemIdx.i, colIdx.i = 0)</code></td><td>Récupère le texte d'une cellule spécifique.</td></tr>
      <tr><td><code>SetItemText(itemIdx.i, colIdx.i, text.s)</code></td><td>Modifie le texte d'une cellule spécifique.</td></tr>
      <tr><td><code>GetItemCount()</code></td><td>Nombre total de lignes dans la table.</td></tr>
      <tr><td><code>Clear()</code></td><td>Supprime toutes les lignes.</td></tr>
      <tr><td><code>RemoveItem(idx.i)</code></td><td>Supprime une ligne spécifique.</td></tr>
    </table>
  </div>
</div>
""", "listicon")

# FR UI: ProgressBar
save_page("fr", "ui/progressbar.html", "Classe ProgressBar", "Indicateur visuel d'avancement avec multi-constructeurs.", "badge-ui", "UI Class", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>La classe <code>UI::ProgressBar</code> fournit une barre de progression visuelle pour le suivi des traitements.</p>
</div>
<div class='doc-section'>
  <h2 class='section-title'>Constructeurs Surchargés</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Constructeur</th><th>Description</th></tr>
      <tr><td><code>Init()</code></td><td>Plage par défaut 0..100 (200&times;25).</td></tr>
      <tr><td><code>Init(min.i, max.i)</code></td><td>Plage minimale et maximale spécifiées.</td></tr>
      <tr><td><code>Init(min.i, max.i, w.i, h.i)</code></td><td>Plage et dimensions souhaitées.</td></tr>
      <tr><td><code>Init(x.i, y.i, w.i, h.i, min.i, max.i, flags.i)</code></td><td>Complet avec position absolue, plage et flags (<code>#PB_ProgressBar_Smooth</code>, <code>#PB_ProgressBar_Vertical</code>).</td></tr>
    </table>
  </div>
</div>
<div class='doc-section'>
  <h2 class='section-title'>M&eacute;thodes Principales</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Méthode</th><th>Description</th></tr>
      <tr><td><code>GetValue()</code></td><td>Renvoie la valeur actuelle de progression.</td></tr>
      <tr><td><code>SetValue(v.i)</code></td><td>Met à jour la valeur de progression.</td></tr>
    </table>
  </div>
</div>
""", "progressbar")

# FR UI: Slider
save_page("fr", "ui/slider.html", "Classe Slider", "Curseur de réglage linéaire avec multi-constructeurs.", "badge-ui", "UI Class", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>La classe <code>UI::Slider</code> encapsule un curseur de réglage linéaire (<code>TrackBarGadget</code>).</p>
</div>
<div class='doc-section'>
  <h2 class='section-title'>Constructeurs Surchargés</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Constructeur</th><th>Description</th></tr>
      <tr><td><code>Init()</code></td><td>Plage par défaut 0..100 (200&times;25).</td></tr>
      <tr><td><code>Init(min.i, max.i)</code></td><td>Plage minimale et maximale spécifiées.</td></tr>
      <tr><td><code>Init(min.i, max.i, w.i, h.i)</code></td><td>Plage et dimensions souhaitées.</td></tr>
      <tr><td><code>Init(x.i, y.i, w.i, h.i, min.i, max.i, flags.i)</code></td><td>Complet avec position absolue, plage et flags (<code>#PB_TrackBar_Ticks</code>, <code>#PB_TrackBar_Vertical</code>).</td></tr>
    </table>
  </div>
</div>
<div class='doc-section'>
  <h2 class='section-title'>M&eacute;thodes Principales</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Méthode</th><th>Description</th></tr>
      <tr><td><code>GetValue()</code></td><td>Renvoie la position actuelle du curseur.</td></tr>
      <tr><td><code>SetValue(v.i)</code></td><td>Modifie la position du curseur.</td></tr>
    </table>
  </div>
</div>
""", "slider")

# FR UI: ToggleSwitch
save_page("fr", "ui/toggleswitch.html", "Classe ToggleSwitch", "Interrupteur vectoriel moderne (Style iOS) avec multi-constructeurs.", "badge-ui", "UI Class", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>La classe <code>UI::Controls::ToggleSwitch</code> est un contrôle moderne vectoriel (<code>CustomGadget</code> sur Canvas) représentant un interrupteur style iOS / Material.</p>
</div>
<div class='doc-section'>
  <h2 class='section-title'>Constructeurs Surchargés</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Constructeur</th><th>Description</th></tr>
      <tr><td><code>Init()</code></td><td>Interrupteur désactivé par défaut (50&times;26).</td></tr>
      <tr><td><code>Init(checked.b)</code></td><td>État initial activé / désactivé.</td></tr>
      <tr><td><code>Init(w.i, h.i, checked.b)</code></td><td>Dimensions et état initial.</td></tr>
      <tr><td><code>Init(x.i, y.i, w.i, h.i, checked.b)</code></td><td>Position absolue, dimensions et état initial.</td></tr>
    </table>
  </div>
</div>
<div class='doc-section'>
  <h2 class='section-title'>M&eacute;thodes Principales</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Méthode</th><th>Description</th></tr>
      <tr><td><code>IsChecked()</code></td><td>Renvoie <code>#True</code> si activé, <code>#False</code> sinon.</td></tr>
      <tr><td><code>SetChecked(state.b)</code></td><td>Modifie l'état et redessine le composant.</td></tr>
      <tr><td><code>OnChange()</code></td><td>Callback virtuel déclenché lors du basculement.</td></tr>
    </table>
  </div>
</div>
""", "toggleswitch")

# FR UI: Container
save_page("fr", "ui/container.html", "Classe Container", "Classe de base abstraite pour tous les panneaux de disposition responsive WPF.", "badge-ui", "Layout", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>La classe <code>UI::Layouts::Container</code> est la classe abstraite fondatrice de tout le système de disposition responsive de PureBasic OOP. Inspirée du modèle WPF / XAML de .NET, elle permet de créer des interfaces graphiques modernes qui s'adaptent automatiquement à toutes les résolutions d'écran et aux redimensionnements de fenêtres.</p>
  <p>Elle implémente le cycle de mise en page automatique (<code>Arrange</code>) et gère les marges intérieures (<code>Padding</code>) ainsi que la collection de composants enfants.</p>
</div>
<div class='doc-section'>
  <h2 class='section-title'>Constructeurs Surchargés</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Constructeur</th><th>Description</th></tr>
      <tr><td><code>Init()</code></td><td>Conteneur par défaut (stretch horizontal et vertical).</td></tr>
      <tr><td><code>Init(w.i, h.i)</code></td><td>Conteneur avec dimensions initiales.</td></tr>
      <tr><td><code>Init(x.i, y.i, w.i, h.i)</code></td><td>Conteneur avec position absolue et dimensions.</td></tr>
    </table>
  </div>
</div>
<div class='doc-section'>
  <h2 class='section-title'>M&eacute;thodes de Container</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Méthode</th><th>Description</th></tr>
      <tr><td><code>AddChild(*child)</code></td><td>Ajoute un composant enfant à la disposition.</td></tr>
      <tr><td><code>RemoveChild(*child)</code></td><td>Retire un composant enfant.</td></tr>
      <tr><td><code>ClearChildren()</code></td><td>Supprime tous les composants enfants.</td></tr>
      <tr><td><code>SetPadding(l, t, r, b)</code></td><td>Définit les marges internes en pixels.</td></tr>
      <tr><td><code>SetPaddingAll(p)</code></td><td>Définit une marge interne uniforme.</td></tr>
      <tr><td><code>Arrange(x, y, w, h)</code></td><td>Recalcule le positionnement de tous les enfants.</td></tr>
    </table>
  </div>
</div>
""", "container")

# FR UI: StackPanel
save_page("fr", "ui/stackpanel.html", "Classe StackPanel", "Disposition linéaire automatique verticale ou horizontale avec multi-constructeurs.", "badge-ui", "Layout", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>La classe <code>UI::Layouts::StackPanel</code> dispose ses composants enfants sur une seule ligne séquentielle, orientée soit verticalement (de haut en bas), soit horizontalement (de gauche à droite).</p>
  <p>Un espacement constant (<code>Spacing</code>) peut être configuré entre chaque élément consécutif.</p>
</div>
<div class='doc-section'>
  <h2 class='section-title'>Constructeurs Surchargés</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Constructeur</th><th>Description</th></tr>
      <tr><td><code>Init()</code></td><td>StackPanel vertical avec espacement de 5 pixels par défaut.</td></tr>
      <tr><td><code>Init(orientation.i)</code></td><td>StackPanel avec orientation choisie (<code>#UI_Orientation_Vertical</code> ou <code>#UI_Orientation_Horizontal</code>).</td></tr>
      <tr><td><code>Init(orientation.i, spacing.i)</code></td><td>Orientation et espacement personnalisés.</td></tr>
      <tr><td><code>Init(orientation.i, spacing.i, w.i, h.i)</code></td><td>Orientation, espacement et dimensions spécifiées.</td></tr>
    </table>
  </div>
</div>
<div class='doc-section'>
  <h2 class='section-title'>Exemple d'utilisation</h2>
  <div class='code-container'>
    <div class='code-header'><span class='code-title'>StackPanel vertical (.pbo)</span><span class='code-badge'>PBO</span></div>
    <pre><code><span class='kw'>Define</span> *panel.<span class='tp'>StackPanel</span> = <span class='kw'>New</span> <span class='tp'>StackPanel</span>(#UI_Orientation_Vertical, <span class='num'>10</span>)
*panel\\<span class='fn'>SetPaddingAll</span>(<span class='num'>15</span>)
*panel\\<span class='fn'>AddChild</span>(<span class='kw'>New</span> <span class='tp'>Button</span>(<span class='str'>"Premier Bouton"</span>))
*panel\\<span class='fn'>AddChild</span>(<span class='kw'>New</span> <span class='tp'>Button</span>(<span class='str'>"Deuxième Bouton"</span>))
*win\\<span class='fn'>SetRootComponent</span>(*panel)</code></pre>
  </div>
</div>
""", "stackpanel")

# FR UI: DockPanel
save_page("fr", "ui/dockpanel.html", "Classe DockPanel", "Disposition par ancrage sur les bords et remplissage central.", "badge-ui", "Layout", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>La classe <code>UI::Layouts::DockPanel</code> ancre ses composants enfants le long de ses 4 bordures extérieures (Haut, Bas, Gauche, Droite) et attribue automatiquement tout l'espace résiduel au centre à son dernier enfant (propriété <code>LastChildFill</code>).</p>
</div>
<div class='doc-section'>
  <h2 class='section-title'>Constructeurs Surchargés</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Constructeur</th><th>Description</th></tr>
      <tr><td><code>Init()</code></td><td>DockPanel avec <code>LastChildFill = #True</code> par défaut.</td></tr>
      <tr><td><code>Init(lastChildFill.b)</code></td><td>Activation ou non du remplissage central automatique pour le dernier enfant.</td></tr>
      <tr><td><code>Init(lastChildFill.b, w.i, h.i)</code></td><td>Remplissage central et dimensions spécifiées.</td></tr>
    </table>
  </div>
</div>
<div class='doc-section'>
  <h2 class='section-title'>Constantes d'Ancrage</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Constante</th><th>Description</th></tr>
      <tr><td><code>#UI_Dock_Top</code></td><td>Ancre le composant en haut en occupant toute la largeur.</td></tr>
      <tr><td><code>#UI_Dock_Bottom</code></td><td>Ancre le composant en bas en occupant toute la largeur.</td></tr>
      <tr><td><code>#UI_Dock_Left</code></td><td>Ancre le composant à gauche sur la hauteur résiduelle.</td></tr>
      <tr><td><code>#UI_Dock_Right</code></td><td>Ancre le composant à droite sur la hauteur résiduelle.</td></tr>
      <tr><td><code>#UI_Dock_Fill</code></td><td>Occupe la totalité de l'espace central disponible.</td></tr>
    </table>
  </div>
</div>
""", "dockpanel")

# FR UI: Grid
save_page("fr", "ui/grid.html", "Classe Grid", "Grille responsive 2D avec dimensionnement en pixels, Auto et Star (*).", "badge-ui", "Layout", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>La classe <code>UI::Layouts::Grid</code> définit une grille 2D flexible en lignes et colonnes, avec dimensionnement en pixels, <code>"Auto"</code> ou proportionnel Star (<code>"*"</code>, <code>"2*"</code>).</p>
</div>
<div class='doc-section'>
  <h2 class='section-title'>Constructeurs Surchargés</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Constructeur</th><th>Description</th></tr>
      <tr><td><code>Init()</code></td><td>Grille 2D réactive par défaut.</td></tr>
      <tr><td><code>Init(w.i, h.i)</code></td><td>Grille 2D avec dimensions initiales.</td></tr>
    </table>
  </div>
</div>
<div class='doc-section'>
  <h2 class='section-title'>Exemple d'utilisation</h2>
  <div class='code-container'>
    <div class='code-header'><span class='code-title'>Grille avec Star Sizing (.pbo)</span><span class='code-badge'>PBO</span></div>
    <pre><code><span class='kw'>Define</span> *grid.<span class='tp'>Grid</span> = <span class='kw'>New</span> <span class='tp'>Grid</span>()
*grid\\<span class='fn'>AddColumn</span>(<span class='str'>"200"</span>)  <span class='cm'>; Colonne 0: 200px fixe</span>
*grid\\<span class='fn'>AddColumn</span>(<span class='str'>"3*"</span>)   <span class='cm'>; Colonne 1: 75% largeur restante</span>
*grid\\<span class='fn'>AddColumn</span>(<span class='str'>"1*"</span>)   <span class='cm'>; Colonne 2: 25% largeur restante</span>
*grid\\<span class='fn'>AddRow</span>(<span class='str'>"50"</span>)      <span class='cm'>; Ligne 0: 50px en-tête</span>
*grid\\<span class='fn'>AddRow</span>(<span class='str'>"*"</span>)       <span class='cm'>; Ligne 1: Contenu fluide</span>

*grid\\<span class='fn'>SetCell</span>(*sidebar, <span class='num'>0</span>, <span class='num'>0</span>, <span class='num'>2</span>, <span class='num'>1</span>) <span class='cm'>; RowSpan=2</span>
*grid\\<span class='fn'>SetCell</span>(*mainView, <span class='num'>1</span>, <span class='num'>1</span>)
*win\\<span class='fn'>SetRootComponent</span>(*grid)</code></pre>
  </div>
</div>
""", "grid")

# ============================================================================
# 2. ENGLISH PAGES
# ============================================================================

# EN Index
save_page("en", "index.html", "Overview", "Official documentation for the PureBasic Object-Oriented Programming language.", "badge-info", "Overview", """
<div class='doc-section'>
  <h2 class='section-title'>Welcome to PureBasic OOP</h2>
  <p>PureBasic OOP brings complete Object-Oriented Programming capabilities to PureBasic through a high-performance transpiler and a native modern UI library.</p>
  <div class='callout callout-tip'>
    <div class='callout-title'>💡 Contextual Help with F1</div>
    <p>Inside the IDE, place your cursor over any OOP keyword (<code>Class</code>, <code>Method</code>, <code>Super</code>, <code>Property</code>...) or UI component (<code>Window</code>, <code>Button</code>, <code>StackPanel</code>, <code>ListIcon</code>...) and press <strong>F1</strong> to open its help page directly!</p>
  </div>
</div>
""", "index")

# EN Keywords
save_page("en", "keywords/class.html", "Class & Abstract Keywords", "Concrete and abstract class declarations in PureBasic OOP.", "badge-keyword", "Keyword", "<p>Classes are declared using <code>Class ... Extends</code> blocks.</p>", "class")
save_page("en", "keywords/method.html", "Method & Override Keywords", "Virtual method declarations and method overloading.", "badge-keyword", "Keyword", "<p>Instance methods are virtual and resolved through fast VTables.</p>", "method")
save_page("en", "keywords/properties.html", "Getters, Setters & Properties", "Clean member encapsulation and property accessors.", "badge-keyword", "Keyword", "<p>Property blocks define <code>Get</code> and <code>Set</code> accessors.</p>", "properties")
save_page("en", "keywords/inheritance.html", "Inheritance: Extends & Super", "Class derivation and calling parent constructors/methods.", "badge-keyword", "Keyword", "<p>Single inheritance using <code>Extends</code> and <code>Super::</code>.</p>", "inheritance")
save_page("en", "keywords/encapsulation.html", "Encapsulation: Public / Protected / Private", "Member visibility and scope controls.", "badge-keyword", "Keyword", "<p>Member access levels control visibility.</p>", "encapsulation")
save_page("en", "keywords/lifecycle.html", "Lifecycle: New, Free & Init", "Object instantiation, constructors, and memory disposal.", "badge-keyword", "Keyword", "<p>Objects are created with <code>New</code> and destroyed with <code>Free</code>.</p>", "lifecycle")
save_page("en", "keywords/operators.html", "Operators: This, Cast & TypeOf", "Self-reference and type casting operators.", "badge-keyword", "Keyword", "<p>Special operators for instance reference and introspection.</p>", "operators")

# EN UI Controls
save_page("en", "ui/application.html", "Application Class", "Main message loop and application lifecycle management.", "badge-ui", "UI Class", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>The <code>UI::Application</code> class encapsulates the native PureBasic event loop (<code>WaitWindowEvent</code>) and application lifecycle.</p>
</div>
""", "application")

save_page("en", "ui/window.html", "Window Class", "Flexible GUI window management with multi-constructors and dynamic setters.", "badge-ui", "UI Class", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>The <code>UI::Window</code> class encapsulates a top-level native GUI window with multi-constructors, automated resizing, and clean disposal.</p>
</div>
<div class='doc-section'>
  <h2 class='section-title'>Overloaded Constructors</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Constructor</th><th>Description</th></tr>
      <tr><td><code>Init(title.s)</code></td><td>Centered 800&times;600 window with minimize, maximize, and resize controls.</td></tr>
      <tr><td><code>Init(title.s, w.i, h.i)</code></td><td>Centered resizable window with custom width and height.</td></tr>
      <tr><td><code>Init(title.s, w.i, h.i, flags.i)</code></td><td>Window with custom dimensions and PureBasic flags.</td></tr>
      <tr><td><code>Init(title.s, x.i, y.i, w.i, h.i)</code></td><td>Window with absolute coordinates and dimensions.</td></tr>
      <tr><td><code>Init(title.s, x.i, y.i, w.i, h.i, flags.i)</code></td><td>Window with absolute coordinates, dimensions, and flags.</td></tr>
      <tr><td><code>Init(title.s, x.i, y.i, w.i, h.i, flags.i, parent.i)</code></td><td>Full window initialization with parent window ID.</td></tr>
    </table>
  </div>
</div>
""", "window")

save_page("en", "ui/gadget.html", "Gadget & Component Classes", "Abstract base class for all UI controls and layout panels.", "badge-ui", "UI Class", "<p>Unified base control handling coordinates, alignment, and event routing.</p>", "gadget")

save_page("en", "ui/button.html", "Button Class", "Clickable push button with multi-constructors and event dispatch.", "badge-ui", "UI Class", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>The <code>UI::Button</code> class encapsulates a clickable push button with multi-constructors and <code>OnClick()</code> virtual handler.</p>
</div>
<div class='doc-section'>
  <h2 class='section-title'>Overloaded Constructors</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Constructor</th><th>Description</th></tr>
      <tr><td><code>Init(text.s)</code></td><td>Button with text (auto 120&times;30 default for layout containers).</td></tr>
      <tr><td><code>Init(text.s, w.i, h.i)</code></td><td>Button with text and custom dimensions.</td></tr>
      <tr><td><code>Init(x.i, y.i, w.i, h.i, text.s)</code></td><td>Absolute position, dimensions, and text.</td></tr>
      <tr><td><code>Init(x.i, y.i, w.i, h.i, text.s, flags.i)</code></td><td>Full constructor with PureBasic flags.</td></tr>
    </table>
  </div>
</div>
""", "button")

save_page("en", "ui/textbox.html", "TextBox Class", "Text input field with multi-constructors and change events.", "badge-ui", "UI Class", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>The <code>UI::TextBox</code> class encapsulates a single-line editable text input (<code>StringGadget</code>) with <code>OnChange()</code> notification.</p>
</div>
<div class='doc-section'>
  <h2 class='section-title'>Overloaded Constructors</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Constructor</th><th>Description</th></tr>
      <tr><td><code>Init()</code></td><td>Empty text box (150&times;25 default).</td></tr>
      <tr><td><code>Init(defaultText.s)</code></td><td>Text box with default text.</td></tr>
      <tr><td><code>Init(defaultText.s, w.i, h.i)</code></td><td>Text box with default text and custom dimensions.</td></tr>
      <tr><td><code>Init(x.i, y.i, w.i, h.i, defaultText.s)</code></td><td>Absolute coordinates, dimensions, and default text.</td></tr>
      <tr><td><code>Init(x.i, y.i, w.i, h.i, defaultText.s, flags.i)</code></td><td>Full constructor with flags (Password, Numeric, ReadOnly).</td></tr>
    </table>
  </div>
</div>
""", "textbox")

save_page("en", "ui/label.html", "Label Class", "Static text label with multi-constructors and alignment options.", "badge-ui", "UI Class", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>The <code>UI::Label</code> class displays static text with customizable alignments and styles.</p>
</div>
<div class='doc-section'>
  <h2 class='section-title'>Overloaded Constructors</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Constructor</th><th>Description</th></tr>
      <tr><td><code>Init(text.s)</code></td><td>Static text label (auto-sized for layouts).</td></tr>
      <tr><td><code>Init(text.s, w.i, h.i)</code></td><td>Label with text and custom dimensions.</td></tr>
      <tr><td><code>Init(x.i, y.i, w.i, h.i, text.s)</code></td><td>Absolute position, dimensions, and text.</td></tr>
      <tr><td><code>Init(x.i, y.i, w.i, h.i, text.s, flags.i)</code></td><td>Full constructor with alignment flags.</td></tr>
    </table>
  </div>
</div>
""", "label")

save_page("en", "ui/checkbox.html", "CheckBox Class", "Toggle checkbox with multi-constructors and state accessors.", "badge-ui", "UI Class", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>The <code>UI::CheckBox</code> class encapsulates a boolean toggle checkbox with checked state management.</p>
</div>
<div class='doc-section'>
  <h2 class='section-title'>Overloaded Constructors</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Constructor</th><th>Description</th></tr>
      <tr><td><code>Init(text.s)</code></td><td>Unchecked checkbox (150&times;25 default).</td></tr>
      <tr><td><code>Init(text.s, checked.b)</code></td><td>Checkbox with text and initial state.</td></tr>
      <tr><td><code>Init(text.s, w.i, h.i, checked.b)</code></td><td>Checkbox with text, dimensions, and initial state.</td></tr>
      <tr><td><code>Init(x.i, y.i, w.i, h.i, text.s, flags.i)</code></td><td>Full constructor with position and flags.</td></tr>
    </table>
  </div>
</div>
""", "checkbox")

save_page("en", "ui/combobox.html", "ComboBox Class", "Drop-down selection box with multi-constructors.", "badge-ui", "UI Class", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>The <code>UI::ComboBox</code> class provides a drop-down list selection box with item management.</p>
</div>
<div class='doc-section'>
  <h2 class='section-title'>Overloaded Constructors</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Constructor</th><th>Description</th></tr>
      <tr><td><code>Init()</code></td><td>Drop-down selection box (150&times;25 default).</td></tr>
      <tr><td><code>Init(w.i, h.i)</code></td><td>ComboBox with custom dimensions.</td></tr>
      <tr><td><code>Init(x.i, y.i, w.i, h.i)</code></td><td>Absolute coordinates and dimensions.</td></tr>
      <tr><td><code>Init(x.i, y.i, w.i, h.i, flags.i)</code></td><td>Full constructor with flags (<code>#PB_ComboBox_Editable</code>, etc.).</td></tr>
    </table>
  </div>
</div>
""", "combobox")

save_page("en", "ui/listicon.html", "ListIcon Class", "Multi-column data grid table with multi-constructors.", "badge-ui", "UI Class", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>The <code>UI::ListIcon</code> class encapsulates a multi-column data grid table (<code>ListIconGadget</code>) with selection and row manipulation.</p>
</div>
<div class='doc-section'>
  <h2 class='section-title'>Overloaded Constructors</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Constructor</th><th>Description</th></tr>
      <tr><td><code>Init(title.s, colWidth.i)</code></td><td>Initializes table with its primary column (full row select by default).</td></tr>
      <tr><td><code>Init(title.s, colWidth.i, flags.i)</code></td><td>Table with custom flags (<code>#PB_ListIcon_GridLines</code>, <code>#PB_ListIcon_CheckBoxes</code>, etc.).</td></tr>
      <tr><td><code>Init(x.i, y.i, w.i, h.i, title.s, colWidth.i)</code></td><td>Absolute position and dimensions.</td></tr>
      <tr><td><code>Init(x.i, y.i, w.i, h.i, title.s, colWidth.i, flags.i)</code></td><td>Full constructor with position, dimensions, title, and flags.</td></tr>
    </table>
  </div>
</div>
""", "listicon")

save_page("en", "ui/progressbar.html", "ProgressBar Class", "Visual progress indicator with multi-constructors.", "badge-ui", "UI Class", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>The <code>UI::ProgressBar</code> class provides a visual progress indicator.</p>
</div>
<div class='doc-section'>
  <h2 class='section-title'>Overloaded Constructors</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Constructor</th><th>Description</th></tr>
      <tr><td><code>Init()</code></td><td>Default range 0..100 (200&times;25).</td></tr>
      <tr><td><code>Init(min.i, max.i)</code></td><td>Custom min and max range.</td></tr>
      <tr><td><code>Init(min.i, max.i, w.i, h.i)</code></td><td>Custom range and dimensions.</td></tr>
      <tr><td><code>Init(x.i, y.i, w.i, h.i, min.i, max.i, flags.i)</code></td><td>Full constructor with position, range, and flags.</td></tr>
    </table>
  </div>
</div>
""", "progressbar")

save_page("en", "ui/slider.html", "Slider Class", "Interactive trackbar slider with multi-constructors.", "badge-ui", "UI Class", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>The <code>UI::Slider</code> class encapsulates a linear TrackBar adjustment slider.</p>
</div>
<div class='doc-section'>
  <h2 class='section-title'>Overloaded Constructors</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Constructor</th><th>Description</th></tr>
      <tr><td><code>Init()</code></td><td>Default range 0..100 (200&times;25).</td></tr>
      <tr><td><code>Init(min.i, max.i)</code></td><td>Custom min and max range.</td></tr>
      <tr><td><code>Init(min.i, max.i, w.i, h.i)</code></td><td>Custom range and dimensions.</td></tr>
      <tr><td><code>Init(x.i, y.i, w.i, h.i, min.i, max.i, flags.i)</code></td><td>Full constructor with position, range, and flags.</td></tr>
    </table>
  </div>
</div>
""", "slider")

save_page("en", "ui/toggleswitch.html", "ToggleSwitch Class", "Modern vector-rendered iOS-style toggle switch.", "badge-ui", "UI Class", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>The <code>UI::Controls::ToggleSwitch</code> is a modern vector-rendered CustomGadget on Canvas implementing an iOS / Material style toggle switch.</p>
</div>
<div class='doc-section'>
  <h2 class='section-title'>Overloaded Constructors</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Constructor</th><th>Description</th></tr>
      <tr><td><code>Init()</code></td><td>Default unchecked switch (50&times;26).</td></tr>
      <tr><td><code>Init(checked.b)</code></td><td>Initial on/off state.</td></tr>
      <tr><td><code>Init(w.i, h.i, checked.b)</code></td><td>Custom dimensions and initial state.</td></tr>
      <tr><td><code>Init(x.i, y.i, w.i, h.i, checked.b)</code></td><td>Absolute coordinates, dimensions, and initial state.</td></tr>
    </table>
  </div>
</div>
""", "toggleswitch")

save_page("en", "ui/container.html", "Container Class", "Abstract base class for all WPF-style responsive layout panels.", "badge-ui", "Layout", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>The <code>UI::Layouts::Container</code> class is the abstract foundation for all responsive layout panels. Inspired by WPF / .NET, it coordinates child components and executes automatic two-pass layout cycles (<code>Arrange</code>).</p>
</div>
<div class='doc-section'>
  <h2 class='section-title'>Overloaded Constructors</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Constructor</th><th>Description</th></tr>
      <tr><td><code>Init()</code></td><td>Default container (stretch alignment).</td></tr>
      <tr><td><code>Init(w.i, h.i)</code></td><td>Container with initial dimensions.</td></tr>
      <tr><td><code>Init(x.i, y.i, w.i, h.i)</code></td><td>Container with absolute coordinates and dimensions.</td></tr>
    </table>
  </div>
</div>
""", "container")

save_page("en", "ui/stackpanel.html", "StackPanel Class", "Linear vertical or horizontal layout panel with multi-constructors.", "badge-ui", "Layout", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>The <code>UI::Layouts::StackPanel</code> arranges child elements into a single linear flow (vertical or horizontal) with configurable spacing between items.</p>
</div>
<div class='doc-section'>
  <h2 class='section-title'>Overloaded Constructors</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Constructor</th><th>Description</th></tr>
      <tr><td><code>Init()</code></td><td>Vertical StackPanel with 5px spacing by default.</td></tr>
      <tr><td><code>Init(orientation.i)</code></td><td>StackPanel with chosen orientation (<code>#UI_Orientation_Vertical</code> or <code>#UI_Orientation_Horizontal</code>).</td></tr>
      <tr><td><code>Init(orientation.i, spacing.i)</code></td><td>Custom orientation and spacing.</td></tr>
      <tr><td><code>Init(orientation.i, spacing.i, w.i, h.i)</code></td><td>Custom orientation, spacing, and dimensions.</td></tr>
    </table>
  </div>
</div>
""", "stackpanel")

save_page("en", "ui/dockpanel.html", "DockPanel Class", "Edge-docking layout panel with central space filling.", "badge-ui", "Layout", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>The <code>UI::Layouts::DockPanel</code> positions child elements along its 4 outer edges (Top, Bottom, Left, Right) and expands the last child to fill central space.</p>
</div>
<div class='doc-section'>
  <h2 class='section-title'>Overloaded Constructors</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Constructor</th><th>Description</th></tr>
      <tr><td><code>Init()</code></td><td>DockPanel with <code>LastChildFill = #True</code> by default.</td></tr>
      <tr><td><code>Init(lastChildFill.b)</code></td><td>Custom LastChildFill toggle.</td></tr>
      <tr><td><code>Init(lastChildFill.b, w.i, h.i)</code></td><td>Custom LastChildFill and initial dimensions.</td></tr>
    </table>
  </div>
</div>
""", "dockpanel")

save_page("en", "ui/grid.html", "Grid Class", "Two-dimensional responsive layout grid with Star proportional sizing.", "badge-ui", "Layout", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>The <code>UI::Layouts::Grid</code> defines a flexible 2D grid of rows and columns with fixed, <code>"Auto"</code>, and Star (<code>"*"</code>, <code>"2*"</code>) proportional sizing.</p>
</div>
<div class='doc-section'>
  <h2 class='section-title'>Overloaded Constructors</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Constructor</th><th>Description</th></tr>
      <tr><td><code>Init()</code></td><td>Default 2D responsive grid.</td></tr>
      <tr><td><code>Init(w.i, h.i)</code></td><td>Grid with initial dimensions.</td></tr>
    </table>
  </div>
</div>
""", "grid")

print("All HTML documentation files generated successfully!")
