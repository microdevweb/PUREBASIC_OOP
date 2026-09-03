# -*- coding: utf-8 -*-
# ============================================================================
# PureBasic OOP Complete HTML Documentation Generator
# Generates all HTML documentation files with inheritance hierarchy (FR & EN)
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
    ("Socle UI & Hiérarchie", [
        ("component", "Component (Base UI)", "ui/component.html", "BASE"),
        ("gadget", "Gadget (Natif)", "ui/gadget.html", "BASE"),
        ("customgadget", "CustomGadget (Canvas)", "ui/customgadget.html", "BASE"),
        ("container", "Container (Layout Base)", "ui/container.html", "WPF")
    ]),
    ("Composants UI (Contrôles)", [
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
        ("stackpanel", "StackPanel", "ui/stackpanel.html", "WPF"),
        ("dockpanel", "DockPanel", "ui/dockpanel.html", "WPF"),
        ("grid", "Grid", "ui/grid.html", "WPF")
    ]),
    ("Application & Fenêtres", [
        ("application", "Application", "ui/application.html", "CORE"),
        ("window", "Window", "ui/window.html", "CORE")
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
    ("UI Foundation & Hierarchy", [
        ("component", "Component (Base UI)", "ui/component.html", "BASE"),
        ("gadget", "Gadget (Native Base)", "ui/gadget.html", "BASE"),
        ("customgadget", "CustomGadget (Canvas Base)", "ui/customgadget.html", "BASE"),
        ("container", "Container (Layout Base)", "ui/container.html", "WPF")
    ]),
    ("UI Components (Controls)", [
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
        ("stackpanel", "StackPanel", "ui/stackpanel.html", "WPF"),
        ("dockpanel", "DockPanel", "ui/dockpanel.html", "WPF"),
        ("grid", "Grid", "ui/grid.html", "WPF")
    ]),
    ("Application & Windows", [
        ("application", "Application", "ui/application.html", "CORE"),
        ("window", "Window", "ui/window.html", "CORE")
    ])
]

# Hierarchy metadata for UI classes
HIERARCHY_DATA = {
    "component": {
        "ancestors": [("Core::Object", "../keywords/class.html"), ("UI::Component", "component.html")],
        "derived": [
            ("UI::Gadget", "gadget.html"),
            ("UI::Layouts::Container", "container.html")
        ],
        "inherited": []
    },
    "gadget": {
        "ancestors": [("Core::Object", "../keywords/class.html"), ("UI::Component", "component.html"), ("UI::Gadget", "gadget.html")],
        "derived": [
            ("UI::Button", "button.html"),
            ("UI::CheckBox", "checkbox.html"),
            ("UI::ComboBox", "combobox.html"),
            ("UI::Label", "label.html"),
            ("UI::ListIcon", "listicon.html"),
            ("UI::ProgressBar", "progressbar.html"),
            ("UI::Slider", "slider.html"),
            ("UI::TextBox", "textbox.html"),
            ("UI::CustomGadget", "customgadget.html")
        ],
        "inherited": [
            ("UI::Component", "component.html", [
                "SetPosition(x, y)", "SetSize(w, h)", "SetMargin(l, t, r, b)", "SetMarginAll(m)",
                "SetHorizontalAlignment(align)", "SetVerticalAlignment(align)", "SetVisible(v)", "IsVisible()",
                "SetEnabled(e)", "IsEnabled()", "Arrange(rx, ry, rw, rh)", "GetDesiredWidth()", "GetDesiredHeight()"
            ])
        ]
    },
    "customgadget": {
        "ancestors": [("Core::Object", "../keywords/class.html"), ("UI::Component", "component.html"), ("UI::Gadget", "gadget.html"), ("UI::CustomGadget", "customgadget.html")],
        "derived": [
            ("UI::ToggleSwitch", "toggleswitch.html")
        ],
        "inherited": [
            ("UI::Gadget", "gadget.html", ["GetID()", "GetHandle()", "SetFont(fontID)", "SetColor(type, color)", "FreeGadget()"]),
            ("UI::Component", "component.html", ["SetPosition()", "SetSize()", "SetMargin()", "SetHorizontalAlignment()", "SetVerticalAlignment()", "Arrange()"])
        ]
    },
    "button": {
        "ancestors": [("Core::Object", "../keywords/class.html"), ("UI::Component", "component.html"), ("UI::Gadget", "gadget.html"), ("UI::Button", "button.html")],
        "derived": [],
        "inherited": [
            ("UI::Gadget", "gadget.html", ["GetID()", "GetHandle()", "SetFont(fontID)", "SetColor(type, color)", "FreeGadget()", "SetToolTip(tip)", "SetFocus()"]),
            ("UI::Component", "component.html", ["SetPosition(x, y)", "SetSize(w, h)", "SetMargin(l, t, r, b)", "SetHorizontalAlignment(align)", "SetVerticalAlignment(align)", "SetVisible(v)", "SetEnabled(e)", "Arrange()"])
        ]
    },
    "checkbox": {
        "ancestors": [("Core::Object", "../keywords/class.html"), ("UI::Component", "component.html"), ("UI::Gadget", "gadget.html"), ("UI::CheckBox", "checkbox.html")],
        "derived": [],
        "inherited": [
            ("UI::Gadget", "gadget.html", ["GetID()", "GetHandle()", "SetFont()", "SetColor()", "FreeGadget()", "SetToolTip()", "SetFocus()"]),
            ("UI::Component", "component.html", ["SetPosition()", "SetSize()", "SetMargin()", "SetHorizontalAlignment()", "SetVerticalAlignment()", "SetVisible()", "SetEnabled()", "Arrange()"])
        ]
    },
    "combobox": {
        "ancestors": [("Core::Object", "../keywords/class.html"), ("UI::Component", "component.html"), ("UI::Gadget", "gadget.html"), ("UI::ComboBox", "combobox.html")],
        "derived": [],
        "inherited": [
            ("UI::Gadget", "gadget.html", ["GetID()", "GetHandle()", "SetFont()", "SetColor()", "FreeGadget()", "SetToolTip()", "SetFocus()"]),
            ("UI::Component", "component.html", ["SetPosition()", "SetSize()", "SetMargin()", "SetHorizontalAlignment()", "SetVerticalAlignment()", "SetVisible()", "SetEnabled()", "Arrange()"])
        ]
    },
    "label": {
        "ancestors": [("Core::Object", "../keywords/class.html"), ("UI::Component", "component.html"), ("UI::Gadget", "gadget.html"), ("UI::Label", "label.html")],
        "derived": [],
        "inherited": [
            ("UI::Gadget", "gadget.html", ["GetID()", "GetHandle()", "SetFont()", "SetColor()", "FreeGadget()", "SetToolTip()"]),
            ("UI::Component", "component.html", ["SetPosition()", "SetSize()", "SetMargin()", "SetHorizontalAlignment()", "SetVerticalAlignment()", "SetVisible()", "Arrange()"])
        ]
    },
    "listicon": {
        "ancestors": [("Core::Object", "../keywords/class.html"), ("UI::Component", "component.html"), ("UI::Gadget", "gadget.html"), ("UI::ListIcon", "listicon.html")],
        "derived": [],
        "inherited": [
            ("UI::Gadget", "gadget.html", ["GetID()", "GetHandle()", "SetFont()", "SetColor()", "FreeGadget()", "SetToolTip()", "SetFocus()"]),
            ("UI::Component", "component.html", ["SetPosition()", "SetSize()", "SetMargin()", "SetHorizontalAlignment()", "SetVerticalAlignment()", "SetVisible()", "SetEnabled()", "Arrange()"])
        ]
    },
    "progressbar": {
        "ancestors": [("Core::Object", "../keywords/class.html"), ("UI::Component", "component.html"), ("UI::Gadget", "gadget.html"), ("UI::ProgressBar", "progressbar.html")],
        "derived": [],
        "inherited": [
            ("UI::Gadget", "gadget.html", ["GetID()", "GetHandle()", "FreeGadget()", "SetToolTip()"]),
            ("UI::Component", "component.html", ["SetPosition()", "SetSize()", "SetMargin()", "SetHorizontalAlignment()", "SetVerticalAlignment()", "SetVisible()", "Arrange()"])
        ]
    },
    "slider": {
        "ancestors": [("Core::Object", "../keywords/class.html"), ("UI::Component", "component.html"), ("UI::Gadget", "gadget.html"), ("UI::Slider", "slider.html")],
        "derived": [],
        "inherited": [
            ("UI::Gadget", "gadget.html", ["GetID()", "GetHandle()", "FreeGadget()", "SetToolTip()", "SetFocus()"]),
            ("UI::Component", "component.html", ["SetPosition()", "SetSize()", "SetMargin()", "SetHorizontalAlignment()", "SetVerticalAlignment()", "SetVisible()", "SetEnabled()", "Arrange()"])
        ]
    },
    "textbox": {
        "ancestors": [("Core::Object", "../keywords/class.html"), ("UI::Component", "component.html"), ("UI::Gadget", "gadget.html"), ("UI::TextBox", "textbox.html")],
        "derived": [],
        "inherited": [
            ("UI::Gadget", "gadget.html", ["GetID()", "GetHandle()", "SetFont()", "SetColor()", "FreeGadget()", "SetToolTip()", "SetFocus()"]),
            ("UI::Component", "component.html", ["SetPosition()", "SetSize()", "SetMargin()", "SetHorizontalAlignment()", "SetVerticalAlignment()", "SetVisible()", "SetEnabled()", "Arrange()"])
        ]
    },
    "toggleswitch": {
        "ancestors": [("Core::Object", "../keywords/class.html"), ("UI::Component", "component.html"), ("UI::Gadget", "gadget.html"), ("UI::CustomGadget", "customgadget.html"), ("UI::ToggleSwitch", "toggleswitch.html")],
        "derived": [],
        "inherited": [
            ("UI::CustomGadget", "customgadget.html", ["Redraw()", "OnPaint(w, h)", "OnMouseEnter()", "OnMouseLeave()", "OnMouseDown()", "OnMouseUp()"]),
            ("UI::Gadget", "gadget.html", ["GetID()", "GetHandle()", "FreeGadget()", "SetToolTip()"]),
            ("UI::Component", "component.html", ["SetPosition()", "SetSize()", "SetMargin()", "SetHorizontalAlignment()", "SetVerticalAlignment()", "SetVisible()", "SetEnabled()", "Arrange()"])
        ]
    },
    "container": {
        "ancestors": [("Core::Object", "../keywords/class.html"), ("UI::Component", "component.html"), ("UI::Layouts::Container", "container.html")],
        "derived": [
            ("UI::Layouts::StackPanel", "stackpanel.html"),
            ("UI::Layouts::DockPanel", "dockpanel.html"),
            ("UI::Layouts::Grid", "grid.html")
        ],
        "inherited": [
            ("UI::Component", "component.html", [
                "SetPosition(x, y)", "SetSize(w, h)", "SetMargin(l, t, r, b)", "SetMarginAll(m)",
                "SetHorizontalAlignment(align)", "SetVerticalAlignment(align)", "SetVisible(v)", "SetEnabled(e)",
                "Arrange(rx, ry, rw, rh)", "GetDesiredWidth()", "GetDesiredHeight()"
            ])
        ]
    },
    "stackpanel": {
        "ancestors": [("Core::Object", "../keywords/class.html"), ("UI::Component", "component.html"), ("UI::Layouts::Container", "container.html"), ("UI::Layouts::StackPanel", "stackpanel.html")],
        "derived": [],
        "inherited": [
            ("UI::Layouts::Container", "container.html", [
                "AddChild(*child)", "RemoveChild(*child)", "ClearChildren()", "GetChildCount()", "GetChild(index)",
                "SetPadding(l, t, r, b)", "SetPaddingAll(p)", "GetPaddingLeft()", "GetPaddingTop()"
            ]),
            ("UI::Component", "component.html", [
                "SetPosition(x, y)", "SetSize(w, h)", "SetMargin(l, t, r, b)", "SetHorizontalAlignment(align)", "SetVerticalAlignment(align)",
                "SetVisible(v)", "SetEnabled(e)", "Arrange(rx, ry, rw, rh)"
            ])
        ]
    },
    "dockpanel": {
        "ancestors": [("Core::Object", "../keywords/class.html"), ("UI::Component", "component.html"), ("UI::Layouts::Container", "container.html"), ("UI::Layouts::DockPanel", "dockpanel.html")],
        "derived": [],
        "inherited": [
            ("UI::Layouts::Container", "container.html", [
                "AddChild(*child)", "RemoveChild(*child)", "ClearChildren()", "GetChildCount()", "GetChild(index)",
                "SetPadding(l, t, r, b)", "SetPaddingAll(p)"
            ]),
            ("UI::Component", "component.html", [
                "SetPosition(x, y)", "SetSize(w, h)", "SetMargin(l, t, r, b)", "SetHorizontalAlignment(align)", "SetVerticalAlignment(align)",
                "SetVisible(v)", "SetEnabled(e)", "Arrange(rx, ry, rw, rh)"
            ])
        ]
    },
    "grid": {
        "ancestors": [("Core::Object", "../keywords/class.html"), ("UI::Component", "component.html"), ("UI::Layouts::Container", "container.html"), ("UI::Layouts::Grid", "grid.html")],
        "derived": [],
        "inherited": [
            ("UI::Layouts::Container", "container.html", [
                "AddChild(*child)", "RemoveChild(*child)", "ClearChildren()", "GetChildCount()", "GetChild(index)",
                "SetPadding(l, t, r, b)", "SetPaddingAll(p)"
            ]),
            ("UI::Component", "component.html", [
                "SetPosition(x, y)", "SetSize(w, h)", "SetMargin(l, t, r, b)", "SetHorizontalAlignment(align)", "SetVerticalAlignment(align)",
                "SetVisible(v)", "SetEnabled(e)", "Arrange(rx, ry, rw, rh)"
            ])
        ]
    },
    "window": {
        "ancestors": [("Core::Object", "../keywords/class.html"), ("UI::Window", "window.html")],
        "derived": [],
        "inherited": []
    },
    "application": {
        "ancestors": [("Core::Object", "../keywords/class.html"), ("UI::Application", "application.html")],
        "derived": [],
        "inherited": []
    }
}

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

def render_inheritance_widget(lang, key):
    meta = HIERARCHY_DATA.get(key)
    if not meta:
        return ""
    
    is_fr = (lang == "fr")
    title_hier = "Hiérarchie d'héritage" if is_fr else "Inheritance Hierarchy"
    title_der = "Classes dérivées (héritant de cette classe)" if is_fr else "Derived Classes (inheriting from this class)"
    title_inh = "Méthodes héritées" if is_fr else "Inherited Methods"
    
    out = ["<div class='inheritance-box'>"]
    out.append(f"  <div class='inheritance-header'><span>&#128391;</span> {title_hier}</div>")
    out.append("  <div class='inheritance-chain'>")
    
    ancestors = meta.get("ancestors", [])
    for idx, (name, link) in enumerate(ancestors):
        is_current = (idx == len(ancestors) - 1)
        if is_current:
            out.append(f"    <span class='inheritance-node current'>{name}</span>")
        else:
            out.append(f"    <a href='{link}' class='inheritance-node'>{name}</a>")
            out.append("    <span class='inheritance-arrow'>&rarr;</span>")
    out.append("  </div>")
    
    # Derived classes if any
    derived = meta.get("derived", [])
    if derived:
        out.append("  <div class='derived-classes-box'>")
        out.append(f"    <div class='derived-classes-title'>{title_der} :</div>")
        out.append("    <div class='derived-classes-list'>")
        for dname, dlink in derived:
            out.append(f"      <a href='{dlink}' class='derived-badge'>{dname}</a>")
        out.append("    </div>")
        out.append("  </div>")
        
    # Inherited members summary if any
    inherited = meta.get("inherited", [])
    if inherited:
        for parent_name, parent_link, methods in inherited:
            out.append("  <div class='inherited-members-summary'>")
            out.append(f"    <div class='inherited-members-title'><span>{title_inh} de <a href='{parent_link}' style='color: var(--accent-blue); text-decoration: underline;'>{parent_name}</a></span> <span style='font-size: 0.78rem; font-weight: normal; color: var(--text-muted);'>({len(methods)} méthodes)</span></div>")
            out.append("    <div class='inherited-members-tags'>")
            for m in methods:
                out.append(f"      <a href='{parent_link}' class='inherited-tag'>{m}</a>")
            out.append("    </div>")
            out.append("  </div>")
            
    out.append("</div>")
    return "\n".join(out)

def render_page(lang, current_key, rel_target, title, lead, badge_type, badge_text, content_html):
    is_fr = (lang == "fr")
    rel_root = "../" if "/" in rel_target else ""
    css_path = f"{rel_root}../css/doc_theme.css"
    logo_path = f"{rel_root}../assets/PB_OOP_LOGO.jpeg"
    home_link = f"{rel_root}index.html"
    
    other_lang = "en" if is_fr else "fr"
    other_link = f"{rel_root}../{other_lang}/{rel_target}"
    
    sidebar = render_sidebar(lang, current_key, rel_root)
    inheritance_html = render_inheritance_widget(lang, current_key)
    
    category = "Composants UI" if is_fr else "UI Components"
    if "keywords/" in rel_target:
        category = "Mots-clés POO" if is_fr else "OOP Keywords"
    elif rel_target == "index.html":
        category = "Accueil" if is_fr else "Home"
        
    breadcrumb_middle = f"<span class='breadcrumb-separator'>/</span><span>{category}</span>" if rel_target != "index.html" else ""
    breadcrumb_curr = f"<span class='breadcrumb-separator'>/</span><span style='color: var(--accent-blue);'>{title}</span>" if rel_target != "index.html" else ""
    
    fr_btn_cls = " active" if is_fr else ""
    en_btn_cls = "" if is_fr else " active"
    fr_link = "#" if is_fr else other_link
    en_link = other_link if is_fr else "#"
    
    search_placeholder = "Rechercher..." if is_fr else "Search docs..."
    
    html = f"""<!DOCTYPE html>
<html lang='{lang}'>
<head>
  <meta charset='UTF-8'>
  <meta name='viewport' content='width=device-width, initial-scale=1.0'>
  <title>{title} - PureBasic OOP Documentation</title>
  <link rel='stylesheet' href='{css_path}'>
</head>
<body>
  <header class='doc-header'>
    <a href='{home_link}' class='brand-container'>
      <img src='{logo_path}' alt='Logo' class='brand-logo'>
      <span class='brand-title'>PureBasic OOP</span>
      <span class='brand-version'>v1.2 Native</span>
    </a>
    <div class='header-controls'>
      <div class='search-box'>
        <span class='search-icon'>&#128269;</span>
        <input type='text' class='search-input' id='search-input' placeholder='{search_placeholder}'>
      </div>
      <div class='lang-switch'>
        <a href='{fr_link}' class='lang-btn{fr_btn_cls}'>FR</a>
        <a href='{en_link}' class='lang-btn{en_btn_cls}'>EN</a>
      </div>
    </div>
  </header>
  
  <div class='layout-container'>
{sidebar}
    <main class='doc-content'>
      <div class='breadcrumb'>
        <a href='{home_link}'>{'Accueil' if is_fr else 'Home'}</a>
        {breadcrumb_middle}
        {breadcrumb_curr}
      </div>
      
      <div class='page-header'>
        <div class='title-row'>
          <h1 class='page-title'>{title}</h1>
          <span class='badge {badge_type}'>{badge_text}</span>
        </div>
        <p class='page-lead'>{lead}</p>
      </div>
      
      {inheritance_html}
      
{content_html}
    </main>
  </div>
  
  <footer class='doc-footer'>
    <p>&copy; 2026 PureBasic OOP Project - MicrodevWeb | Dual License GPL v3 / Fantaisie Software</p>
  </footer>
</body>
</html>
"""
    return html

def save_page(lang, rel_target, title, lead, badge_type, badge_text, content_html, key=None):
    if key is None:
        key = os.path.splitext(os.path.basename(rel_target))[0]
    full_path = os.path.join(BASE_HTML_DIR, lang, rel_target.replace("/", os.sep))
    os.makedirs(os.path.dirname(full_path), exist_ok=True)
    html = render_page(lang, key, rel_target, title, lead, badge_type, badge_text, content_html)
    with open(full_path, "w", encoding="utf-8") as f:
        f.write(html)
    print(f"Generated [{lang.upper()}]: {rel_target}")

# ============================================================================
# COMPONENT (NEW)
# ============================================================================
save_page("fr", "ui/component.html", "Classe Component", "Classe abstraite racine de tous les composants graphiques et conteneurs de layout réactifs.", "badge-ui", "Base UI", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>La classe abstraite <code>UI::Component</code> (dans <code>src/ui/Component.pbo</code>) définit le socle commun de l'ensemble des éléments d'interface graphique de PureBasic OOP. Elle fournit le modèle de boîte réactif inspiré de WPF : coordonnées calculées, marges (<code>Margin</code>), alignements horizontaux et verticaux, dimensions désirées, et cycle de disposition en 2 passes (<code>Arrange</code>).</p>
</div>

<div class='doc-section'>
  <h2 class='section-title'>Constantes d'Alignement</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Constante</th><th>Valeur</th><th>Signification</th></tr>
      <tr><td><code>#UI_Align_Left</code></td><td>0</td><td>Alignement à gauche</td></tr>
      <tr><td><code>#UI_Align_Center</code></td><td>1</td><td>Centrage horizontal</td></tr>
      <tr><td><code>#UI_Align_Right</code></td><td>2</td><td>Alignement à droite</td></tr>
      <tr><td><code>#UI_Align_Stretch</code></td><td>3</td><td>Étirer sur toute la largeur disponible (défaut)</td></tr>
      <tr><td><code>#UI_Align_Top</code></td><td>0</td><td>Alignement en haut</td></tr>
      <tr><td><code>#UI_Align_Middle</code></td><td>1</td><td>Centrage vertical</td></tr>
      <tr><td><code>#UI_Align_Bottom</code></td><td>2</td><td>Alignement en bas</td></tr>
      <tr><td><code>#UI_Align_VStretch</code></td><td>3</td><td>Étirer sur toute la hauteur disponible (défaut)</td></tr>
    </table>
  </div>
</div>

<div class='doc-section'>
  <h2 class='section-title'>Méthodes Principales de Component</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Méthode</th><th>Description</th></tr>
      <tr><td><code>SetPosition(x.i, y.i)</code></td><td>Définit manuellement la position X, Y du composant.</td></tr>
      <tr><td><code>SetSize(w.i, h.i)</code></td><td>Définit manuellement la largeur et hauteur du composant.</td></tr>
      <tr><td><code>SetMargin(l.i, t.i, r.i, b.i)</code></td><td>Définit les marges externes (Gauche, Haut, Droite, Bas) en pixels.</td></tr>
      <tr><td><code>SetMarginAll(m.i)</code></td><td>Définit une marge externe identique sur les 4 côtés.</td></tr>
      <tr><td><code>SetHorizontalAlignment(align.i)</code></td><td>Définit l'alignement horizontal (<code>#UI_Align_Left</code>, <code>#UI_Align_Center</code>, etc.).</td></tr>
      <tr><td><code>SetVerticalAlignment(align.i)</code></td><td>Définit l'alignement vertical (<code>#UI_Align_Top</code>, <code>#UI_Align_Middle</code>, etc.).</td></tr>
      <tr><td><code>SetDesiredSize(w.i, h.i)</code></td><td>Définit la taille souhaitée demandée par le composant aux conteneurs de layout.</td></tr>
      <tr><td><code>GetDesiredWidth() / GetDesiredHeight()</code></td><td>Retourne les dimensions souhaitées avec marges.</td></tr>
      <tr><td><code>SetVisible(v.b) / IsVisible()</code></td><td>Active ou désactive la visibilité du composant.</td></tr>
      <tr><td><code>SetEnabled(e.b) / IsEnabled()</code></td><td>Active ou désactive l'interactivité utilisateur.</td></tr>
      <tr><td><code>Arrange(targetX.i, targetY.i, targetW.i, targetH.i)</code></td><td>Exécute le calcul de placement et redimensionne l'élément selon son alignement.</td></tr>
    </table>
  </div>
</div>
""", "component")

save_page("en", "ui/component.html", "Component Class", "Abstract root class for all UI elements, gadgets, and responsive layout panels.", "badge-ui", "Base UI", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>The abstract <code>UI::Component</code> class (located in <code>src/ui/Component.pbo</code>) provides the foundational WPF-style box model for all graphical elements in PureBasic OOP: computed bounds, responsive margins, horizontal/vertical alignments, desired dimensions, and automated 2-pass layout arrangement (<code>Arrange</code>).</p>
</div>

<div class='doc-section'>
  <h2 class='section-title'>Alignment Constants</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Constant</th><th>Value</th><th>Meaning</th></tr>
      <tr><td><code>#UI_Align_Left</code></td><td>0</td><td>Align to left edge</td></tr>
      <tr><td><code>#UI_Align_Center</code></td><td>1</td><td>Center horizontally</td></tr>
      <tr><td><code>#UI_Align_Right</code></td><td>2</td><td>Align to right edge</td></tr>
      <tr><td><code>#UI_Align_Stretch</code></td><td>3</td><td>Stretch across available width (default)</td></tr>
      <tr><td><code>#UI_Align_Top</code></td><td>0</td><td>Align to top edge</td></tr>
      <tr><td><code>#UI_Align_Middle</code></td><td>1</td><td>Center vertically</td></tr>
      <tr><td><code>#UI_Align_Bottom</code></td><td>2</td><td>Align to bottom edge</td></tr>
      <tr><td><code>#UI_Align_VStretch</code></td><td>3</td><td>Stretch across available height (default)</td></tr>
    </table>
  </div>
</div>

<div class='doc-section'>
  <h2 class='section-title'>Component Core Methods</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Method</th><th>Description</th></tr>
      <tr><td><code>SetPosition(x.i, y.i)</code></td><td>Sets manual X, Y coordinates.</td></tr>
      <tr><td><code>SetSize(w.i, h.i)</code></td><td>Sets manual width and height.</td></tr>
      <tr><td><code>SetMargin(l.i, t.i, r.i, b.i)</code></td><td>Sets outer margin on all 4 edges (Left, Top, Right, Bottom).</td></tr>
      <tr><td><code>SetMarginAll(m.i)</code></td><td>Sets uniform outer margin on all 4 edges.</td></tr>
      <tr><td><code>SetHorizontalAlignment(align.i)</code></td><td>Sets horizontal alignment policy (<code>#UI_Align_Left</code>, <code>#UI_Align_Center</code>, etc.).</td></tr>
      <tr><td><code>SetVerticalAlignment(align.i)</code></td><td>Sets vertical alignment policy (<code>#UI_Align_Top</code>, <code>#UI_Align_Middle</code>, etc.).</td></tr>
      <tr><td><code>SetDesiredSize(w.i, h.i)</code></td><td>Sets preferred size requested from layout panels.</td></tr>
      <tr><td><code>GetDesiredWidth() / GetDesiredHeight()</code></td><td>Returns computed desired bounds including margins.</td></tr>
      <tr><td><code>SetVisible(v.b) / IsVisible()</code></td><td>Gets or sets element visibility state.</td></tr>
      <tr><td><code>SetEnabled(e.b) / IsEnabled()</code></td><td>Gets or sets interactive state.</td></tr>
      <tr><td><code>Arrange(targetX.i, targetY.i, targetW.i, targetH.i)</code></td><td>Executes responsive layout calculation and aligns the element.</td></tr>
    </table>
  </div>
</div>
""", "component")

# ============================================================================
# CUSTOMGADGET (NEW)
# ============================================================================
save_page("fr", "ui/customgadget.html", "Classe CustomGadget", "Classe abstraite de base pour les contrôles dessinés sur Canvas 2D Vector.", "badge-ui", "Base UI", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>La classe abstraite <code>UI::CustomGadget</code> (dans <code>src/ui/CustomGadget.pbo</code>) étend <code>UI::Gadget</code> et permet de créer des contrôles graphiques hautement personnalisés entièrement dessinés sur un <code>CanvasGadget</code> avec gestion native du survol (Hover), du clic (Pressed), du focus et du clavier.</p>
</div>

<div class='doc-section'>
  <h2 class='section-title'>Constructeurs Surchargés</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Constructeur</th><th>Description</th></tr>
      <tr><td><code>Init()</code></td><td>Constructeur par défaut (Canvas 100x30 positionné par les layouts).</td></tr>
      <tr><td><code>Init(w.i, h.i)</code></td><td>Constructeur avec dimensions personnalisées.</td></tr>
      <tr><td><code>Init(x.i, y.i, w.i, h.i)</code></td><td>Constructeur avec position absolue et dimensions.</td></tr>
      <tr><td><code>Init(x.i, y.i, w.i, h.i, flags.i)</code></td><td>Constructeur complet avec flags PureBasic CanvasGadget.</td></tr>
    </table>
  </div>
</div>

<div class='doc-section'>
  <h2 class='section-title'>Méthodes Virtuelles à Surcharger</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Méthode</th><th>Description</th></tr>
      <tr><td><code>OnPaint(w.i, h.i)</code></td><td><strong>Méthode abstraite obligatoire</strong> : code de dessin VectorDrawing / 2D Drawing du contrôle.</td></tr>
      <tr><td><code>OnMouseEnter() / OnMouseLeave()</code></td><td>Appelé automatiquement lors de l'entrée ou sortie du curseur de souris.</td></tr>
      <tr><td><code>OnMouseDown(mx.i, my.i, button.i)</code></td><td>Appelé lors de l'appui d'un bouton de la souris.</td></tr>
      <tr><td><code>OnMouseUp(mx.i, my.i, button.i)</code></td><td>Appelé lors du relâchement d'un bouton de la souris.</td></tr>
      <tr><td><code>OnMouseMove(mx.i, my.i)</code></td><td>Appelé lors du déplacement de la souris sur le canvas.</td></tr>
      <tr><td><code>Redraw()</code></td><td>Force le rafraîchissement immédiat du contrôle en appelant <code>OnPaint()</code>.</td></tr>
    </table>
  </div>
</div>
""", "customgadget")

save_page("en", "ui/customgadget.html", "CustomGadget Class", "Abstract base class for custom 2D Vector / Canvas-rendered controls.", "badge-ui", "Base UI", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>The abstract <code>UI::CustomGadget</code> class (in <code>src/ui/CustomGadget.pbo</code>) extends <code>UI::Gadget</code> to build advanced custom widgets rendered on native PureBasic <code>CanvasGadget</code> with built-in state management (Hover, Pressed, Focus, Mouse coordinates).</p>
</div>

<div class='doc-section'>
  <h2 class='section-title'>Overloaded Constructors</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Constructor</th><th>Description</th></tr>
      <tr><td><code>Init()</code></td><td>Default constructor (100x30 canvas arranged by layout panels).</td></tr>
      <tr><td><code>Init(w.i, h.i)</code></td><td>Custom initial dimensions.</td></tr>
      <tr><td><code>Init(x.i, y.i, w.i, h.i)</code></td><td>Absolute coordinates and dimensions.</td></tr>
      <tr><td><code>Init(x.i, y.i, w.i, h.i, flags.i)</code></td><td>Full constructor with PureBasic CanvasGadget flags.</td></tr>
    </table>
  </div>
</div>

<div class='doc-section'>
  <h2 class='section-title'>Virtual Paint & Input Methods</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Method</th><th>Description</th></tr>
      <tr><td><code>OnPaint(w.i, h.i)</code></td><td><strong>Mandatory abstract method</strong>: implement your 2D Drawing / Vector drawing commands here.</td></tr>
      <tr><td><code>OnMouseEnter() / OnMouseLeave()</code></td><td>Triggered automatically on mouse cursor enter/exit events.</td></tr>
      <tr><td><code>OnMouseDown(mx.i, my.i, button.i)</code></td><td>Triggered when mouse button is pressed.</td></tr>
      <tr><td><code>OnMouseUp(mx.i, my.i, button.i)</code></td><td>Triggered when mouse button is released.</td></tr>
      <tr><td><code>OnMouseMove(mx.i, my.i)</code></td><td>Triggered on mouse movement over the canvas.</td></tr>
      <tr><td><code>Redraw()</code></td><td>Forces an immediate canvas repaint cycle.</td></tr>
    </table>
  </div>
</div>
""", "customgadget")

# ============================================================================
# GADGET (UPDATED)
# ============================================================================
save_page("fr", "ui/gadget.html", "Classe Gadget", "Classe de base abstraite pour tous les contrôles natifs PureBasic.", "badge-ui", "Base UI", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>La classe abstraite <code>UI::Gadget</code> (dans <code>src/ui/Gadget.pbo</code>) hérite de <code>UI::Component</code> et encapsule un contrôle graphique natif du système d'exploitation. Elle fait le pont entre le cycle de vie PureBasic (<code>#PB_Any</code>, <code>GadgetID()</code>) et la programmation objet événementielle.</p>
</div>

<div class='doc-section'>
  <h2 class='section-title'>Méthodes Principales de Gadget</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Méthode</th><th>Description</th></tr>
      <tr><td><code>GetID()</code></td><td>Retourne le numéro de gadget PureBasic (#Gadget).</td></tr>
      <tr><td><code>GetHandle()</code></td><td>Retourne le handle OS natif (<code>GadgetID(#Gadget)</code> sous Windows/Linux/Mac).</td></tr>
      <tr><td><code>SetFont(fontID.i)</code></td><td>Applique une police PureBasic au gadget.</td></tr>
      <tr><td><code>SetColor(colorType.i, color.i)</code></td><td>Définit la couleur de fond ou de texte du gadget.</td></tr>
      <tr><td><code>SetToolTip(tip.s)</code></td><td>Définit le texte d'aide au survol.</td></tr>
      <tr><td><code>SetFocus()</code></td><td>Donne le focus clavier actif au gadget.</td></tr>
      <tr><td><code>FreeGadget()</code></td><td>Libère le contrôle natif et supprime son association OOP.</td></tr>
    </table>
  </div>
</div>
""", "gadget")

save_page("en", "ui/gadget.html", "Gadget Class", "Abstract base class for all native PureBasic controls.", "badge-ui", "Base UI", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>The abstract <code>UI::Gadget</code> class (in <code>src/ui/Gadget.pbo</code>) inherits from <code>UI::Component</code> and wraps an OS-native PureBasic control, bridging <code>#PB_Any</code> gadget handles with object-oriented event dispatching.</p>
</div>

<div class='doc-section'>
  <h2 class='section-title'>Gadget Core Methods</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Method</th><th>Description</th></tr>
      <tr><td><code>GetID()</code></td><td>Returns the PureBasic gadget number (#Gadget).</td></tr>
      <tr><td><code>GetHandle()</code></td><td>Returns native OS handle (<code>GadgetID(#Gadget)</code> on Windows/Linux/Mac).</td></tr>
      <tr><td><code>SetFont(fontID.i)</code></td><td>Applies a PureBasic font to the gadget.</td></tr>
      <tr><td><code>SetColor(colorType.i, color.i)</code></td><td>Sets background or foreground text color.</td></tr>
      <tr><td><code>SetToolTip(tip.s)</code></td><td>Sets hover tooltip text.</td></tr>
      <tr><td><code>SetFocus()</code></td><td>Sets active keyboard input focus.</td></tr>
      <tr><td><code>FreeGadget()</code></td><td>Destroys native gadget and cleans up OOP mapping.</td></tr>
    </table>
  </div>
</div>
""", "gadget")

# ============================================================================
# BUTTON (UPDATED)
# ============================================================================
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
      <tr><td><code>Init()</code></td><td>Bouton par défaut sans texte (dimensions gérées par les layouts).</td></tr>
      <tr><td><code>Init(text.s)</code></td><td>Bouton avec texte, dimensions calculées par les layouts.</td></tr>
      <tr><td><code>Init(text.s, w.i, h.i)</code></td><td>Bouton avec texte et dimensions souhaitées.</td></tr>
      <tr><td><code>Init(text.s, x.i, y.i, w.i, h.i)</code></td><td>Bouton avec texte, position absolue et dimensions.</td></tr>
      <tr><td><code>Init(text.s, x.i, y.i, w.i, h.i, flags.i)</code></td><td>Bouton complet avec flags PureBasic ButtonGadget.</td></tr>
    </table>
  </div>
</div>
<div class='doc-section'>
  <h2 class='section-title'>Méthodes Spécifiques</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Méthode</th><th>Description</th></tr>
      <tr><td><code>GetText() / SetText(txt.s)</code></td><td>Obtient ou modifie le texte du bouton.</td></tr>
      <tr><td><code>OnClick()</code></td><td>Méthode virtuelle appelée lors du clic utilisateur.</td></tr>
    </table>
  </div>
</div>
""", "button")

save_page("en", "ui/button.html", "Button Class", "Clickable pushbutton control with overloaded constructors and event handling.", "badge-ui", "UI Class", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>The <code>UI::Button</code> class wraps a native pushbutton with responsive layout arrangement and virtual <code>OnClick()</code> event routing.</p>
</div>
<div class='doc-section'>
  <h2 class='section-title'>Overloaded Constructors</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Constructor</th><th>Description</th></tr>
      <tr><td><code>Init()</code></td><td>Default button without text (bounds managed by layout panels).</td></tr>
      <tr><td><code>Init(text.s)</code></td><td>Button with caption, sized by layout panels.</td></tr>
      <tr><td><code>Init(text.s, w.i, h.i)</code></td><td>Button with caption and preferred dimensions.</td></tr>
      <tr><td><code>Init(text.s, x.i, y.i, w.i, h.i)</code></td><td>Button with caption, absolute coordinates, and dimensions.</td></tr>
      <tr><td><code>Init(text.s, x.i, y.i, w.i, h.i, flags.i)</code></td><td>Full button with PureBasic ButtonGadget flags.</td></tr>
    </table>
  </div>
</div>
<div class='doc-section'>
  <h2 class='section-title'>Specific Methods</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Method</th><th>Description</th></tr>
      <tr><td><code>GetText() / SetText(txt.s)</code></td><td>Gets or sets the button caption.</td></tr>
      <tr><td><code>OnClick()</code></td><td>Virtual method triggered on user click.</td></tr>
    </table>
  </div>
</div>
""", "button")

# ============================================================================
# CHECKBOX
# ============================================================================
save_page("fr", "ui/checkbox.html", "Classe CheckBox", "Case à cocher à deux ou trois états avec multi-constructeurs.", "badge-ui", "UI Class", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>La classe <code>UI::CheckBox</code> encapsule une case à cocher native avec gestion d'état booléen et événement <code>OnToggle()</code>.</p>
</div>
<div class='doc-section'>
  <h2 class='section-title'>Constructeurs Surchargés</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Constructeur</th><th>Description</th></tr>
      <tr><td><code>Init()</code></td><td>Case à cocher par défaut.</td></tr>
      <tr><td><code>Init(text.s)</code></td><td>Case à cocher avec libellé.</td></tr>
      <tr><td><code>Init(text.s, checked.b)</code></td><td>Case à cocher avec libellé et état initial.</td></tr>
      <tr><td><code>Init(text.s, checked.b, w.i, h.i)</code></td><td>Case à cocher avec libellé, état et dimensions souhaitées.</td></tr>
      <tr><td><code>Init(text.s, x.i, y.i, w.i, h.i, checked.b, flags.i)</code></td><td>Case à cocher complète avec coordonnées absolues et flags.</td></tr>
    </table>
  </div>
</div>
<div class='doc-section'>
  <h2 class='section-title'>Méthodes Spécifiques</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Méthode</th><th>Description</th></tr>
      <tr><td><code>IsChecked() / SetChecked(state.b)</code></td><td>Obtient ou définit l'état coché / décoché.</td></tr>
      <tr><td><code>GetText() / SetText(txt.s)</code></td><td>Obtient ou modifie le libellé.</td></tr>
      <tr><td><code>OnToggle()</code></td><td>Méthode virtuelle appelée lors du changement d'état.</td></tr>
    </table>
  </div>
</div>
""", "checkbox")

save_page("en", "ui/checkbox.html", "CheckBox Class", "Two-state or three-state checkbox control with overloaded constructors.", "badge-ui", "UI Class", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>The <code>UI::CheckBox</code> class wraps a native checkbox with boolean state management and virtual <code>OnToggle()</code> event routing.</p>
</div>
<div class='doc-section'>
  <h2 class='section-title'>Overloaded Constructors</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Constructor</th><th>Description</th></tr>
      <tr><td><code>Init()</code></td><td>Default checkbox without caption.</td></tr>
      <tr><td><code>Init(text.s)</code></td><td>Checkbox with caption text.</td></tr>
      <tr><td><code>Init(text.s, checked.b)</code></td><td>Checkbox with caption and initial check state.</td></tr>
      <tr><td><code>Init(text.s, checked.b, w.i, h.i)</code></td><td>Checkbox with caption, state, and preferred dimensions.</td></tr>
      <tr><td><code>Init(text.s, x.i, y.i, w.i, h.i, checked.b, flags.i)</code></td><td>Full checkbox with absolute bounds and flags.</td></tr>
    </table>
  </div>
</div>
<div class='doc-section'>
  <h2 class='section-title'>Specific Methods</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Method</th><th>Description</th></tr>
      <tr><td><code>IsChecked() / SetChecked(state.b)</code></td><td>Gets or sets the checked state.</td></tr>
      <tr><td><code>GetText() / SetText(txt.s)</code></td><td>Gets or sets the caption text.</td></tr>
      <tr><td><code>OnToggle()</code></td><td>Virtual method triggered on state change.</td></tr>
    </table>
  </div>
</div>
""", "checkbox")

# ============================================================================
# COMBOBOX
# ============================================================================
save_page("fr", "ui/combobox.html", "Classe ComboBox", "Liste déroulante avec multi-constructeurs et sélection d'éléments.", "badge-ui", "UI Class", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>La classe <code>UI::ComboBox</code> encapsule une liste déroulante avec ajout d'éléments, sélection d'index et événement <code>OnSelect()</code>.</p>
</div>
<div class='doc-section'>
  <h2 class='section-title'>Constructeurs Surchargés</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Constructeur</th><th>Description</th></tr>
      <tr><td><code>Init()</code></td><td>ComboBox par défaut positionné par les layouts.</td></tr>
      <tr><td><code>Init(w.i, h.i)</code></td><td>ComboBox avec dimensions souhaitées.</td></tr>
      <tr><td><code>Init(x.i, y.i, w.i, h.i)</code></td><td>ComboBox avec coordonnées absolues et dimensions.</td></tr>
      <tr><td><code>Init(x.i, y.i, w.i, h.i, flags.i)</code></td><td>ComboBox complet avec flags PureBasic.</td></tr>
    </table>
  </div>
</div>
<div class='doc-section'>
  <h2 class='section-title'>Méthodes Spécifiques</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Méthode</th><th>Description</th></tr>
      <tr><td><code>AddItem(item.s)</code></td><td>Ajoute un élément à la liste déroulante.</td></tr>
      <tr><td><code>GetSelectedIndex() / SetSelectedIndex(idx.i)</code></td><td>Obtient ou définit l'index de l'élément sélectionné.</td></tr>
      <tr><td><code>GetSelectedText()</code></td><td>Retourne le texte de l'élément sélectionné.</td></tr>
      <tr><td><code>Clear()</code></td><td>Vide l'ensemble des éléments de la liste.</td></tr>
      <tr><td><code>OnSelect()</code></td><td>Méthode virtuelle appelée lors d'un changement de sélection.</td></tr>
    </table>
  </div>
</div>
""", "combobox")

save_page("en", "ui/combobox.html", "ComboBox Class", "Dropdown selection list with overloaded constructors.", "badge-ui", "UI Class", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>The <code>UI::ComboBox</code> class wraps a native dropdown list with item population, index tracking, and virtual <code>OnSelect()</code> event handling.</p>
</div>
<div class='doc-section'>
  <h2 class='section-title'>Overloaded Constructors</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Constructor</th><th>Description</th></tr>
      <tr><td><code>Init()</code></td><td>Default ComboBox arranged by layout panels.</td></tr>
      <tr><td><code>Init(w.i, h.i)</code></td><td>ComboBox with preferred dimensions.</td></tr>
      <tr><td><code>Init(x.i, y.i, w.i, h.i)</code></td><td>ComboBox with absolute bounds.</td></tr>
      <tr><td><code>Init(x.i, y.i, w.i, h.i, flags.i)</code></td><td>Full ComboBox with PureBasic flags.</td></tr>
    </table>
  </div>
</div>
<div class='doc-section'>
  <h2 class='section-title'>Specific Methods</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Method</th><th>Description</th></tr>
      <tr><td><code>AddItem(item.s)</code></td><td>Appends an item to the dropdown list.</td></tr>
      <tr><td><code>GetSelectedIndex() / SetSelectedIndex(idx.i)</code></td><td>Gets or sets current selected index.</td></tr>
      <tr><td><code>GetSelectedText()</code></td><td>Returns text of selected item.</td></tr>
      <tr><td><code>Clear()</code></td><td>Removes all items from list.</td></tr>
      <tr><td><code>OnSelect()</code></td><td>Virtual method triggered on selection change.</td></tr>
    </table>
  </div>
</div>
""", "combobox")

# ============================================================================
# LABEL
# ============================================================================
save_page("fr", "ui/label.html", "Classe Label", "Contrôle d'affichage de texte statique avec multi-constructeurs.", "badge-ui", "UI Class", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>La classe <code>UI::Label</code> encapsule un texte d'affichage statique <code>TextGadget</code> avec options d'alignement.</p>
</div>
<div class='doc-section'>
  <h2 class='section-title'>Constructeurs Surchargés</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Constructeur</th><th>Description</th></tr>
      <tr><td><code>Init()</code></td><td>Label par défaut sans texte.</td></tr>
      <tr><td><code>Init(text.s)</code></td><td>Label avec texte initial.</td></tr>
      <tr><td><code>Init(text.s, w.i, h.i)</code></td><td>Label avec texte et dimensions souhaitées.</td></tr>
      <tr><td><code>Init(text.s, x.i, y.i, w.i, h.i, flags.i)</code></td><td>Label avec coordonnées absolues et flags d'alignement.</td></tr>
    </table>
  </div>
</div>
<div class='doc-section'>
  <h2 class='section-title'>Méthodes Spécifiques</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Méthode</th><th>Description</th></tr>
      <tr><td><code>GetText() / SetText(txt.s)</code></td><td>Obtient ou modifie le texte affiché.</td></tr>
    </table>
  </div>
</div>
""", "label")

save_page("en", "ui/label.html", "Label Class", "Static text label control with overloaded constructors.", "badge-ui", "UI Class", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>The <code>UI::Label</code> class wraps a native <code>TextGadget</code> to display formatted static text.</p>
</div>
<div class='doc-section'>
  <h2 class='section-title'>Overloaded Constructors</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Constructor</th><th>Description</th></tr>
      <tr><td><code>Init()</code></td><td>Default empty label.</td></tr>
      <tr><td><code>Init(text.s)</code></td><td>Label with initial text.</td></tr>
      <tr><td><code>Init(text.s, w.i, h.i)</code></td><td>Label with text and preferred dimensions.</td></tr>
      <tr><td><code>Init(text.s, x.i, y.i, w.i, h.i, flags.i)</code></td><td>Label with absolute coordinates and alignment flags.</td></tr>
    </table>
  </div>
</div>
<div class='doc-section'>
  <h2 class='section-title'>Specific Methods</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Method</th><th>Description</th></tr>
      <tr><td><code>GetText() / SetText(txt.s)</code></td><td>Gets or sets the displayed text.</td></tr>
    </table>
  </div>
</div>
""", "label")

# ============================================================================
# LISTICON
# ============================================================================
save_page("fr", "ui/listicon.html", "Classe ListIcon", "Tableau de données multicolonne avec multi-constructeurs et gestion d'événements.", "badge-ui", "UI Class", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>La classe <code>UI::ListIcon</code> encapsule un tableau multicolonne <code>ListIconGadget</code> pour la présentation de données structurées avec gestion du double-clic et de sélection.</p>
</div>
<div class='doc-section'>
  <h2 class='section-title'>Constructeurs Surchargés</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Constructeur</th><th>Description</th></tr>
      <tr><td><code>Init()</code></td><td>Tableau par défaut (positionné par les layouts).</td></tr>
      <tr><td><code>Init(firstColTitle.s, firstColWidth.i)</code></td><td>Tableau avec première colonne initialisée.</td></tr>
      <tr><td><code>Init(firstColTitle.s, firstColWidth.i, w.i, h.i)</code></td><td>Tableau avec première colonne et dimensions souhaitées.</td></tr>
      <tr><td><code>Init(x.i, y.i, w.i, h.i, firstColTitle.s, firstColWidth.i, flags.i)</code></td><td>Tableau complet avec coordonnées absolues et flags PureBasic.</td></tr>
    </table>
  </div>
</div>
<div class='doc-section'>
  <h2 class='section-title'>Méthodes Spécifiques</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Méthode</th><th>Description</th></tr>
      <tr><td><code>AddColumn(colIndex.i, title.s, width.i)</code></td><td>Ajoute une colonne au tableau.</td></tr>
      <tr><td><code>AddItem(index.i, text.s)</code></td><td>Insère une ligne de données (séparée par Chr(10)).</td></tr>
      <tr><td><code>GetSelectedIndex() / SetSelectedIndex(idx.i)</code></td><td>Obtient ou définit la ligne sélectionnée.</td></tr>
      <tr><td><code>GetItemText(index.i, col.i)</code></td><td>Retourne le texte d'une cellule spécifique.</td></tr>
      <tr><td><code>Clear()</code></td><td>Efface toutes les lignes du tableau.</td></tr>
      <tr><td><code>OnSelect() / OnDoubleClick()</code></td><td>Méthodes virtuelles appelées lors du clic ou double-clic sur une ligne.</td></tr>
    </table>
  </div>
</div>
""", "listicon")

save_page("en", "ui/listicon.html", "ListIcon Class", "Multi-column tabular data grid with overloaded constructors.", "badge-ui", "UI Class", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>The <code>UI::ListIcon</code> class wraps a native multi-column <code>ListIconGadget</code> to display tabular data records with selection and double-click event handling.</p>
</div>
<div class='doc-section'>
  <h2 class='section-title'>Overloaded Constructors</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Constructor</th><th>Description</th></tr>
      <tr><td><code>Init()</code></td><td>Default ListIcon arranged by layout panels.</td></tr>
      <tr><td><code>Init(firstColTitle.s, firstColWidth.i)</code></td><td>ListIcon initialized with first column title and width.</td></tr>
      <tr><td><code>Init(firstColTitle.s, firstColWidth.i, w.i, h.i)</code></td><td>ListIcon with first column and preferred dimensions.</td></tr>
      <tr><td><code>Init(x.i, y.i, w.i, h.i, firstColTitle.s, firstColWidth.i, flags.i)</code></td><td>Full ListIcon with absolute coordinates and flags.</td></tr>
    </table>
  </div>
</div>
<div class='doc-section'>
  <h2 class='section-title'>Specific Methods</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Method</th><th>Description</th></tr>
      <tr><td><code>AddColumn(colIndex.i, title.s, width.i)</code></td><td>Adds a new column header.</td></tr>
      <tr><td><code>AddItem(index.i, text.s)</code></td><td>Inserts a data row (columns separated by Chr(10)).</td></tr>
      <tr><td><code>GetSelectedIndex() / SetSelectedIndex(idx.i)</code></td><td>Gets or sets the selected row index.</td></tr>
      <tr><td><code>GetItemText(index.i, col.i)</code></td><td>Returns text content of a specific cell.</td></tr>
      <tr><td><code>Clear()</code></td><td>Removes all rows.</td></tr>
      <tr><td><code>OnSelect() / OnDoubleClick()</code></td><td>Virtual methods triggered on row selection or double-click.</td></tr>
    </table>
  </div>
</div>
""", "listicon")

# ============================================================================
# PROGRESSBAR
# ============================================================================
save_page("fr", "ui/progressbar.html", "Classe ProgressBar", "Barre de progression visuelle avec multi-constructeurs.", "badge-ui", "UI Class", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>La classe <code>UI::ProgressBar</code> encapsule une barre de progression avec bornes minimum/maximum et valeur courante.</p>
</div>
<div class='doc-section'>
  <h2 class='section-title'>Constructeurs Surchargés</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Constructeur</th><th>Description</th></tr>
      <tr><td><code>Init()</code></td><td>Barre de progression 0-100 par défaut.</td></tr>
      <tr><td><code>Init(min.i, max.i)</code></td><td>Barre avec plage personnalisée.</td></tr>
      <tr><td><code>Init(min.i, max.i, w.i, h.i)</code></td><td>Barre avec plage et dimensions souhaitées.</td></tr>
      <tr><td><code>Init(x.i, y.i, w.i, h.i, min.i, max.i, flags.i)</code></td><td>Barre complète avec coordonnées absolues et flags.</td></tr>
    </table>
  </div>
</div>
<div class='doc-section'>
  <h2 class='section-title'>Méthodes Spécifiques</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Méthode</th><th>Description</th></tr>
      <tr><td><code>GetValue() / SetValue(val.i)</code></td><td>Obtient ou modifie la valeur courante de la progression.</td></tr>
    </table>
  </div>
</div>
""", "progressbar")

save_page("en", "ui/progressbar.html", "ProgressBar Class", "Visual progress bar with overloaded constructors.", "badge-ui", "UI Class", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>The <code>UI::ProgressBar</code> class wraps a native progress bar with configurable minimum, maximum, and current value tracking.</p>
</div>
<div class='doc-section'>
  <h2 class='section-title'>Overloaded Constructors</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Constructor</th><th>Description</th></tr>
      <tr><td><code>Init()</code></td><td>Default 0-100 progress bar.</td></tr>
      <tr><td><code>Init(min.i, max.i)</code></td><td>Progress bar with custom range.</td></tr>
      <tr><td><code>Init(min.i, max.i, w.i, h.i)</code></td><td>Progress bar with custom range and preferred dimensions.</td></tr>
      <tr><td><code>Init(x.i, y.i, w.i, h.i, min.i, max.i, flags.i)</code></td><td>Full progress bar with absolute bounds and flags.</td></tr>
    </table>
  </div>
</div>
<div class='doc-section'>
  <h2 class='section-title'>Specific Methods</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Method</th><th>Description</th></tr>
      <tr><td><code>GetValue() / SetValue(val.i)</code></td><td>Gets or sets current progress value.</td></tr>
    </table>
  </div>
</div>
""", "progressbar")

# ============================================================================
# SLIDER
# ============================================================================
save_page("fr", "ui/slider.html", "Classe Slider", "Curseur de réglage numérique (TrackBar) avec multi-constructeurs.", "badge-ui", "UI Class", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>La classe <code>UI::Slider</code> encapsule un curseur de réglage de valeur (<code>TrackBarGadget</code>) avec événement <code>OnChange()</code>.</p>
</div>
<div class='doc-section'>
  <h2 class='section-title'>Constructeurs Surchargés</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Constructeur</th><th>Description</th></tr>
      <tr><td><code>Init()</code></td><td>Curseur 0-100 par défaut.</td></tr>
      <tr><td><code>Init(min.i, max.i)</code></td><td>Curseur avec plage personnalisée.</td></tr>
      <tr><td><code>Init(min.i, max.i, w.i, h.i)</code></td><td>Curseur avec plage et dimensions souhaitées.</td></tr>
      <tr><td><code>Init(x.i, y.i, w.i, h.i, min.i, max.i, flags.i)</code></td><td>Curseur complet avec coordonnées absolues et flags.</td></tr>
    </table>
  </div>
</div>
<div class='doc-section'>
  <h2 class='section-title'>Méthodes Spécifiques</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Méthode</th><th>Description</th></tr>
      <tr><td><code>GetValue() / SetValue(val.i)</code></td><td>Obtient ou définit la position du curseur.</td></tr>
      <tr><td><code>OnChange()</code></td><td>Méthode virtuelle appelée lors du déplacement du curseur.</td></tr>
    </table>
  </div>
</div>
""", "slider")

save_page("en", "ui/slider.html", "Slider Class", "Trackbar value slider with overloaded constructors.", "badge-ui", "UI Class", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>The <code>UI::Slider</code> class wraps a native <code>TrackBarGadget</code> with range configuration and virtual <code>OnChange()</code> event routing.</p>
</div>
<div class='doc-section'>
  <h2 class='section-title'>Overloaded Constructors</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Constructor</th><th>Description</th></tr>
      <tr><td><code>Init()</code></td><td>Default 0-100 slider.</td></tr>
      <tr><td><code>Init(min.i, max.i)</code></td><td>Slider with custom range.</td></tr>
      <tr><td><code>Init(min.i, max.i, w.i, h.i)</code></td><td>Slider with custom range and preferred dimensions.</td></tr>
      <tr><td><code>Init(x.i, y.i, w.i, h.i, min.i, max.i, flags.i)</code></td><td>Full slider with absolute bounds and flags.</td></tr>
    </table>
  </div>
</div>
<div class='doc-section'>
  <h2 class='section-title'>Specific Methods</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Method</th><th>Description</th></tr>
      <tr><td><code>GetValue() / SetValue(val.i)</code></td><td>Gets or sets current slider position.</td></tr>
      <tr><td><code>OnChange()</code></td><td>Virtual method triggered on slider adjustment.</td></tr>
    </table>
  </div>
</div>
""", "slider")

# ============================================================================
# TEXTBOX
# ============================================================================
save_page("fr", "ui/textbox.html", "Classe TextBox", "Champ de saisie texte simple ou multiligne avec multi-constructeurs.", "badge-ui", "UI Class", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>La classe <code>UI::TextBox</code> encapsule un champ de saisie <code>StringGadget</code> (ou multiligne) avec événement <code>OnChange()</code>.</p>
</div>
<div class='doc-section'>
  <h2 class='section-title'>Constructeurs Surchargés</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Constructeur</th><th>Description</th></tr>
      <tr><td><code>Init()</code></td><td>Champ de texte vide par défaut.</td></tr>
      <tr><td><code>Init(text.s)</code></td><td>Champ de texte avec contenu initial.</td></tr>
      <tr><td><code>Init(text.s, w.i, h.i)</code></td><td>Champ de texte avec contenu et dimensions souhaitées.</td></tr>
      <tr><td><code>Init(text.s, x.i, y.i, w.i, h.i, flags.i)</code></td><td>Champ de texte complet avec coordonnées absolues et flags (ex. mot de passe).</td></tr>
    </table>
  </div>
</div>
<div class='doc-section'>
  <h2 class='section-title'>Méthodes Spécifiques</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Méthode</th><th>Description</th></tr>
      <tr><td><code>GetText() / SetText(txt.s)</code></td><td>Obtient ou modifie le texte saisi.</td></tr>
      <tr><td><code>OnChange()</code></td><td>Méthode virtuelle appelée lors de chaque frappe ou modification du texte.</td></tr>
    </table>
  </div>
</div>
""", "textbox")

save_page("en", "ui/textbox.html", "TextBox Class", "Single-line or multi-line text input control with overloaded constructors.", "badge-ui", "UI Class", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>The <code>UI::TextBox</code> class wraps a native <code>StringGadget</code> text input with virtual <code>OnChange()</code> event routing.</p>
</div>
<div class='doc-section'>
  <h2 class='section-title'>Overloaded Constructors</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Constructor</th><th>Description</th></tr>
      <tr><td><code>Init()</code></td><td>Default empty text box.</td></tr>
      <tr><td><code>Init(text.s)</code></td><td>TextBox with initial string value.</td></tr>
      <tr><td><code>Init(text.s, w.i, h.i)</code></td><td>TextBox with string and preferred dimensions.</td></tr>
      <tr><td><code>Init(text.s, x.i, y.i, w.i, h.i, flags.i)</code></td><td>Full TextBox with absolute coordinates and flags (e.g. password mode).</td></tr>
    </table>
  </div>
</div>
<div class='doc-section'>
  <h2 class='section-title'>Specific Methods</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Method</th><th>Description</th></tr>
      <tr><td><code>GetText() / SetText(txt.s)</code></td><td>Gets or sets the text content.</td></tr>
      <tr><td><code>OnChange()</code></td><td>Virtual method triggered on every keystroke or text modification.</td></tr>
    </table>
  </div>
</div>
""", "textbox")

# ============================================================================
# TOGGLESWITCH
# ============================================================================
save_page("fr", "ui/toggleswitch.html", "Classe ToggleSwitch", "Interrupteur à bascule moderne dessiné en 2D Vector avec multi-constructeurs.", "badge-ui", "Custom Control", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>La classe <code>UI::ToggleSwitch</code> est un contrôle personnalisé qui hérite de <code>UI::CustomGadget</code>. Il propose un interrupteur on/off moderne au style iOS / Fluent avec animations visuelles douces.</p>
</div>
<div class='doc-section'>
  <h2 class='section-title'>Constructeurs Surchargés</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Constructeur</th><th>Description</th></tr>
      <tr><td><code>Init()</code></td><td>Interrupteur décoché par défaut (50x24).</td></tr>
      <tr><td><code>Init(checked.b)</code></td><td>Interrupteur avec état initial (coché / décoché).</td></tr>
      <tr><td><code>Init(w.i, h.i, checked.b)</code></td><td>Interrupteur avec dimensions personnalisées et état initial.</td></tr>
      <tr><td><code>Init(x.i, y.i, w.i, h.i, checked.b)</code></td><td>Interrupteur avec coordonnées absolues, dimensions et état initial.</td></tr>
    </table>
  </div>
</div>
<div class='doc-section'>
  <h2 class='section-title'>Méthodes Spécifiques</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Méthode</th><th>Description</th></tr>
      <tr><td><code>IsChecked() / SetChecked(state.b)</code></td><td>Obtient ou définit l'état actif de l'interrupteur.</td></tr>
      <tr><td><code>OnToggle()</code></td><td>Méthode virtuelle appelée lors du basculement de l'interrupteur.</td></tr>
    </table>
  </div>
</div>
""", "toggleswitch")

save_page("en", "ui/toggleswitch.html", "ToggleSwitch Class", "Modern vector-rendered switch toggle control with overloaded constructors.", "badge-ui", "Custom Control", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>The <code>UI::ToggleSwitch</code> custom control inherits from <code>UI::CustomGadget</code> to deliver a modern iOS / Fluent-style animated toggle switch.</p>
</div>
<div class='doc-section'>
  <h2 class='section-title'>Overloaded Constructors</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Constructor</th><th>Description</th></tr>
      <tr><td><code>Init()</code></td><td>Default unchecked toggle switch (50x24).</td></tr>
      <tr><td><code>Init(checked.b)</code></td><td>Toggle switch with initial boolean state.</td></tr>
      <tr><td><code>Init(w.i, h.i, checked.b)</code></td><td>Custom dimensions and initial state.</td></tr>
      <tr><td><code>Init(x.i, y.i, w.i, h.i, checked.b)</code></td><td>Absolute coordinates, dimensions, and initial state.</td></tr>
    </table>
  </div>
</div>
<div class='doc-section'>
  <h2 class='section-title'>Specific Methods</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Method</th><th>Description</th></tr>
      <tr><td><code>IsChecked() / SetChecked(state.b)</code></td><td>Gets or sets toggle state.</td></tr>
      <tr><td><code>OnToggle()</code></td><td>Virtual method triggered on switch state change.</td></tr>
    </table>
  </div>
</div>
""", "toggleswitch")

# ============================================================================
# CONTAINER
# ============================================================================
save_page("fr", "ui/container.html", "Classe Container", "Classe abstraite de base pour tous les conteneurs de layout réactifs (WPF).", "badge-wpf", "Base Layout", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>La classe abstraite <code>UI::Layouts::Container</code> (dans <code>src/ui/layout/Container.pbo</code>) hérite de <code>UI::Component</code> et forme le socle de tous les panneaux de disposition responsive (<code>StackPanel</code>, <code>DockPanel</code>, <code>Grid</code>). Elle gère la liste dynamique des enfants et le padding interne.</p>
</div>
<div class='doc-section'>
  <h2 class='section-title'>Constructeurs Surchargés</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Constructeur</th><th>Description</th></tr>
      <tr><td><code>Init()</code></td><td>Conteneur par défaut avec alignement Stretch.</td></tr>
      <tr><td><code>Init(w.i, h.i)</code></td><td>Conteneur avec dimensions initiales.</td></tr>
      <tr><td><code>Init(x.i, y.i, w.i, h.i)</code></td><td>Conteneur avec coordonnées absolues et dimensions.</td></tr>
    </table>
  </div>
</div>
<div class='doc-section'>
  <h2 class='section-title'>Méthodes de Gestion des Enfants et Padding</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Méthode</th><th>Description</th></tr>
      <tr><td><code>AddChild(*child.UI::Component)</code></td><td>Ajoute un composant enfant (contrôle ou sous-layout) dans le conteneur.</td></tr>
      <tr><td><code>RemoveChild(*child.UI::Component)</code></td><td>Retire un composant enfant du conteneur.</td></tr>
      <tr><td><code>ClearChildren()</code></td><td>Vide l'ensemble des enfants du conteneur.</td></tr>
      <tr><td><code>GetChildCount()</code></td><td>Retourne le nombre total d'enfants actuels.</td></tr>
      <tr><td><code>SetPadding(l.i, t.i, r.i, b.i)</code></td><td>Définit le padding interne (espace entre les bords et les enfants).</td></tr>
      <tr><td><code>SetPaddingAll(p.i)</code></td><td>Définit un padding interne identique sur les 4 côtés.</td></tr>
    </table>
  </div>
</div>
""", "container")

save_page("en", "ui/container.html", "Container Class", "Abstract base class for all WPF-style responsive layout panels.", "badge-wpf", "Base Layout", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>The abstract <code>UI::Layouts::Container</code> class (in <code>src/ui/layout/Container.pbo</code>) inherits from <code>UI::Component</code> and forms the foundation for all responsive layout panels (<code>StackPanel</code>, <code>DockPanel</code>, <code>Grid</code>), orchestrating child element lists and internal padding.</p>
</div>
<div class='doc-section'>
  <h2 class='section-title'>Overloaded Constructors</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Constructor</th><th>Description</th></tr>
      <tr><td><code>Init()</code></td><td>Default container with Stretch alignment.</td></tr>
      <tr><td><code>Init(w.i, h.i)</code></td><td>Container with initial dimensions.</td></tr>
      <tr><td><code>Init(x.i, y.i, w.i, h.i)</code></td><td>Container with absolute coordinates and dimensions.</td></tr>
    </table>
  </div>
</div>
<div class='doc-section'>
  <h2 class='section-title'>Child & Padding Management Methods</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Method</th><th>Description</th></tr>
      <tr><td><code>AddChild(*child.UI::Component)</code></td><td>Appends a child control or sub-layout panel.</td></tr>
      <tr><td><code>RemoveChild(*child.UI::Component)</code></td><td>Removes a child element.</td></tr>
      <tr><td><code>ClearChildren()</code></td><td>Clears all child elements.</td></tr>
      <tr><td><code>GetChildCount()</code></td><td>Returns total number of children.</td></tr>
      <tr><td><code>SetPadding(l.i, t.i, r.i, b.i)</code></td><td>Sets internal padding on all 4 edges.</td></tr>
      <tr><td><code>SetPaddingAll(p.i)</code></td><td>Sets uniform internal padding on all 4 edges.</td></tr>
    </table>
  </div>
</div>
""", "container")

# ============================================================================
# STACKPANEL
# ============================================================================
save_page("fr", "ui/stackpanel.html", "Classe StackPanel", "Panneau de disposition linéaire vertical ou horizontal avec multi-constructeurs.", "badge-wpf", "WPF Layout", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>La classe <code>UI::Layouts::StackPanel</code> dispose ses composants enfants en ligne continue, soit verticalement (de haut en bas), soit horizontalement (de gauche à droite), avec un espacement (<code>Spacing</code>) configurable entre chaque élément.</p>
</div>
<div class='doc-section'>
  <h2 class='section-title'>Constructeurs Surchargés</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Constructeur</th><th>Description</th></tr>
      <tr><td><code>Init()</code></td><td>StackPanel vertical avec espacement de 5px par défaut.</td></tr>
      <tr><td><code>Init(orientation.i)</code></td><td>StackPanel avec orientation choisie (<code>#UI_Orientation_Vertical</code> ou <code>#UI_Orientation_Horizontal</code>).</td></tr>
      <tr><td><code>Init(orientation.i, spacing.i)</code></td><td>StackPanel avec orientation et espacement personnalisés.</td></tr>
      <tr><td><code>Init(orientation.i, spacing.i, w.i, h.i)</code></td><td>StackPanel complet avec dimensions souhaitées.</td></tr>
    </table>
  </div>
</div>
<div class='doc-section'>
  <h2 class='section-title'>Méthodes Spécifiques</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Méthode</th><th>Description</th></tr>
      <tr><td><code>SetOrientation(orientation.i)</code></td><td>Définit l'orientation (<code>#UI_Orientation_Vertical</code> ou <code>#UI_Orientation_Horizontal</code>).</td></tr>
      <tr><td><code>SetSpacing(spacing.i)</code></td><td>Définit l'espacement en pixels entre chaque enfant consécutif.</td></tr>
    </table>
  </div>
</div>
""", "stackpanel")

save_page("en", "ui/stackpanel.html", "StackPanel Class", "Linear vertical or horizontal layout panel with overloaded constructors.", "badge-wpf", "WPF Layout", """
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
<div class='doc-section'>
  <h2 class='section-title'>Specific Methods</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Method</th><th>Description</th></tr>
      <tr><td><code>SetOrientation(orientation.i)</code></td><td>Sets flow orientation (<code>#UI_Orientation_Vertical</code> or <code>#UI_Orientation_Horizontal</code>).</td></tr>
      <tr><td><code>SetSpacing(spacing.i)</code></td><td>Sets spacing in pixels between consecutive items.</td></tr>
    </table>
  </div>
</div>
""", "stackpanel")

# ============================================================================
# DOCKPANEL
# ============================================================================
save_page("fr", "ui/dockpanel.html", "Classe DockPanel", "Panneau d'amarrage sur les 4 bords avec remplissage central automatique.", "badge-wpf", "WPF Layout", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>La classe <code>UI::Layouts::DockPanel</code> ancre ses composants enfants sur les bords extérieurs (Haut, Bas, Gauche, Droite) et étend automatiquement le dernier enfant pour remplir l'espace central restant.</p>
</div>
<div class='doc-section'>
  <h2 class='section-title'>Constructeurs Surchargés</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Constructeur</th><th>Description</th></tr>
      <tr><td><code>Init()</code></td><td>DockPanel avec <code>LastChildFill = #True</code> par défaut.</td></tr>
      <tr><td><code>Init(lastChildFill.b)</code></td><td>DockPanel avec activation/désactivation du remplissage central.</td></tr>
      <tr><td><code>Init(lastChildFill.b, w.i, h.i)</code></td><td>DockPanel avec remplissage et dimensions souhaitées.</td></tr>
    </table>
  </div>
</div>
<div class='doc-section'>
  <h2 class='section-title'>Méthodes et Constantes d'Amarrage</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Méthode / Constante</th><th>Description</th></tr>
      <tr><td><code>#UI_Dock_Left / #UI_Dock_Top / #UI_Dock_Right / #UI_Dock_Bottom</code></td><td>Constantes d'ancrage sur les 4 côtés.</td></tr>
      <tr><td><code>SetDock(*child.UI::Component, dockSide.i)</code></td><td>Définit le bord d'ancrage pour un composant enfant donné.</td></tr>
      <tr><td><code>SetLastChildFill(fill.b)</code></td><td>Active ou désactive l'étirement automatique du dernier enfant dans l'espace restant.</td></tr>
    </table>
  </div>
</div>
""", "dockpanel")

save_page("en", "ui/dockpanel.html", "DockPanel Class", "Edge-docking layout panel with automatic central space filling.", "badge-wpf", "WPF Layout", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>The <code>UI::Layouts::DockPanel</code> anchors child elements along outer edges (Top, Bottom, Left, Right) and expands the last child to fill remaining central space.</p>
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
<div class='doc-section'>
  <h2 class='section-title'>Docking Methods & Constants</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Method / Constant</th><th>Description</th></tr>
      <tr><td><code>#UI_Dock_Left / #UI_Dock_Top / #UI_Dock_Right / #UI_Dock_Bottom</code></td><td>Docking edge constants.</td></tr>
      <tr><td><code>SetDock(*child.UI::Component, dockSide.i)</code></td><td>Sets docking edge for a specific child element.</td></tr>
      <tr><td><code>SetLastChildFill(fill.b)</code></td><td>Enables or disables auto-expanding the last child into remaining space.</td></tr>
    </table>
  </div>
</div>
""", "dockpanel")

# ============================================================================
# GRID
# ============================================================================
save_page("fr", "ui/grid.html", "Classe Grid", "Grille de disposition bidimensionnelle 2D avec dimensionnement proportionnel Star (*).", "badge-wpf", "WPF Layout", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>La classe <code>UI::Layouts::Grid</code> organise les composants dans une grille 2D flexible de lignes et de colonnes avec dimensionnement fixe en pixels, automatique (<code>"Auto"</code>) ou proportionnel Star (<code>"*"</code>, <code>"2*"</code>).</p>
</div>
<div class='doc-section'>
  <h2 class='section-title'>Constructeurs Surchargés</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Constructeur</th><th>Description</th></tr>
      <tr><td><code>Init()</code></td><td>Grille 2D réactive par défaut.</td></tr>
      <tr><td><code>Init(w.i, h.i)</code></td><td>Grille avec dimensions initiales.</td></tr>
    </table>
  </div>
</div>
<div class='doc-section'>
  <h2 class='section-title'>Méthodes Spécifiques de Grid</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Méthode</th><th>Description</th></tr>
      <tr><td><code>AddRowDefinition(heightDef.s)</code></td><td>Ajoute une ligne (ex. <code>"50"</code>, <code>"Auto"</code>, <code>"*"</code>, <code>"2*"</code>).</td></tr>
      <tr><td><code>AddColumnDefinition(widthDef.s)</code></td><td>Ajoute une colonne (ex. <code>"120"</code>, <code>"Auto"</code>, <code>"*"</code>).</td></tr>
      <tr><td><code>SetRow(*child, rowIndex.i)</code></td><td>Place l'élément enfant sur la ligne spécifiée (0-indexé).</td></tr>
      <tr><td><code>SetColumn(*child, colIndex.i)</code></td><td>Place l'élément enfant sur la colonne spécifiée (0-indexé).</td></tr>
      <tr><td><code>SetRowSpan(*child, span.i) / SetColumnSpan(*child, span.i)</code></td><td>Étend l'élément sur plusieurs lignes ou colonnes.</td></tr>
    </table>
  </div>
</div>
""", "grid")

save_page("en", "ui/grid.html", "Grid Class", "Two-dimensional responsive layout grid with Star (*) proportional sizing.", "badge-wpf", "WPF Layout", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>The <code>UI::Layouts::Grid</code> arranges elements in flexible 2D rows and columns with fixed pixel, <code>"Auto"</code>, and Star (<code>"*"</code>, <code>"2*"</code>) proportional sizing.</p>
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
<div class='doc-section'>
  <h2 class='section-title'>Grid Specific Methods</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Method</th><th>Description</th></tr>
      <tr><td><code>AddRowDefinition(heightDef.s)</code></td><td>Adds row definition (e.g. <code>"50"</code>, <code>"Auto"</code>, <code>"*"</code>, <code>"2*"</code>).</td></tr>
      <tr><td><code>AddColumnDefinition(widthDef.s)</code></td><td>Adds column definition (e.g. <code>"120"</code>, <code>"Auto"</code>, <code>"*"</code>).</td></tr>
      <tr><td><code>SetRow(*child, rowIndex.i)</code></td><td>Places child on specified row index (0-based).</td></tr>
      <tr><td><code>SetColumn(*child, colIndex.i)</code></td><td>Places child on specified column index (0-based).</td></tr>
      <tr><td><code>SetRowSpan(*child, span.i) / SetColumnSpan(*child, span.i)</code></td><td>Spans child across multiple rows or columns.</td></tr>
    </table>
  </div>
</div>
""", "grid")

# ============================================================================
# WINDOW
# ============================================================================
save_page("fr", "ui/window.html", "Classe Window", "Fenêtre native événementielle avec boucle de messages et conteneur de layout principal.", "badge-ui", "Core UI", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>La classe <code>UI::Window</code> encapsule une fenêtre native PureBasic (<code>OpenWindow</code>) avec gestion événementielle complète, redimensionnement automatique du layout principal et routage unifié des événements.</p>
</div>
<div class='doc-section'>
  <h2 class='section-title'>Constructeurs Surchargés</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Constructeur</th><th>Description</th></tr>
      <tr><td><code>Init()</code></td><td>Fenêtre par défaut (800x600, centrée).</td></tr>
      <tr><td><code>Init(title.s, w.i, h.i)</code></td><td>Fenêtre avec titre et dimensions, centrée à l'écran.</td></tr>
      <tr><td><code>Init(title.s, x.i, y.i, w.i, h.i)</code></td><td>Fenêtre avec titre, position et dimensions.</td></tr>
      <tr><td><code>Init(title.s, x.i, y.i, w.i, h.i, flags.i)</code></td><td>Fenêtre complète avec flags PureBasic OpenWindow.</td></tr>
    </table>
  </div>
</div>
<div class='doc-section'>
  <h2 class='section-title'>Méthodes Principales</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Méthode</th><th>Description</th></tr>
      <tr><td><code>SetLayout(*rootLayout.UI::Layouts::Container)</code></td><td>Définit le panneau de disposition racine qui s'adapte automatiquement à la taille de la fenêtre.</td></tr>
      <tr><td><code>AddGadget(*gadget.UI::Gadget)</code></td><td>Ajoute un contrôle graphique à la fenêtre.</td></tr>
      <tr><td><code>Show() / Hide() / Close()</code></td><td>Affiche, masque ou ferme la fenêtre.</td></tr>
      <tr><td><code>GetID() / GetHandle()</code></td><td>Retourne le #Window PureBasic ou le handle OS (HWND/NSWindow).</td></tr>
      <tr><td><code>OnClose() / OnResize()</code></td><td>Méthodes virtuelles appelées lors des événements système de fermeture ou redimensionnement.</td></tr>
    </table>
  </div>
</div>
""", "window")

save_page("en", "ui/window.html", "Window Class", "Native event-driven window with automated root layout resizing and event loop.", "badge-ui", "Core UI", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>The <code>UI::Window</code> class encapsulates a native PureBasic window (<code>OpenWindow</code>) with automated root layout resizing, message dispatching, and unified event routing.</p>
</div>
<div class='doc-section'>
  <h2 class='section-title'>Overloaded Constructors</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Constructor</th><th>Description</th></tr>
      <tr><td><code>Init()</code></td><td>Default window (800x600, centered).</td></tr>
      <tr><td><code>Init(title.s, w.i, h.i)</code></td><td>Window with title and dimensions, screen-centered.</td></tr>
      <tr><td><code>Init(title.s, x.i, y.i, w.i, h.i)</code></td><td>Window with title, position, and dimensions.</td></tr>
      <tr><td><code>Init(title.s, x.i, y.i, w.i, h.i, flags.i)</code></td><td>Full window with PureBasic OpenWindow flags.</td></tr>
    </table>
  </div>
</div>
<div class='doc-section'>
  <h2 class='section-title'>Core Methods</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Method</th><th>Description</th></tr>
      <tr><td><code>SetLayout(*rootLayout.UI::Layouts::Container)</code></td><td>Attaches a root layout panel that automatically resizes with window geometry.</td></tr>
      <tr><td><code>AddGadget(*gadget.UI::Gadget)</code></td><td>Adds a child gadget to the window.</td></tr>
      <tr><td><code>Show() / Hide() / Close()</code></td><td>Shows, hides, or closes the window.</td></tr>
      <tr><td><code>GetID() / GetHandle()</code></td><td>Returns PureBasic #Window number or OS handle (HWND/NSWindow).</td></tr>
      <tr><td><code>OnClose() / OnResize()</code></td><td>Virtual callback methods triggered on window close or resize.</td></tr>
    </table>
  </div>
</div>
""", "window")

# ============================================================================
# APPLICATION
# ============================================================================
save_page("fr", "ui/application.html", "Classe Application", "Chef d'orchestre de l'application PureBasic, de la boucle principale et du dispatch d'événements.", "badge-ui", "Core", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>La classe <code>UI::Application</code> est le singleton de pilotage d'une application PureBasic OOP. Elle gère la boucle principale d'événements (<code>WaitWindowEvent</code>), la détection des gadgets et le routage automatique vers les méthodes virtuelles (<code>OnClick</code>, <code>OnChange</code>, <code>OnClose</code>, etc.).</p>
</div>
<div class='doc-section'>
  <h2 class='section-title'>Constructeurs & Méthodes Statiques</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Méthode</th><th>Description</th></tr>
      <tr><td><code>Init(appName.s = 'PB App')</code></td><td>Initialise l'environnement applicatif et enregistre l'instance globale.</td></tr>
      <tr><td><code>Run()</code></td><td>Lance la boucle principale bloquante d'événements jusqu'à fermeture de toutes les fenêtres.</td></tr>
      <tr><td><code>Exit()</code></td><td>Demande l'arrêt propre de la boucle événementielle et quitte l'application.</td></tr>
      <tr><td><code>AddWindow(*win.UI::Window)</code></td><td>Enregistre une fenêtre dans le cycle de vie de l'application.</td></tr>
    </table>
  </div>
</div>
""", "application")

save_page("en", "ui/application.html", "Application Class", "Application lifecycle orchestrator, event loop, and global dispatcher.", "badge-ui", "Core", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>The <code>UI::Application</code> class is the singleton orchestrator for PureBasic OOP applications. It manages the blocking message loop (<code>WaitWindowEvent</code>) and automatically dispatches events to virtual handler methods.</p>
</div>
<div class='doc-section'>
  <h2 class='section-title'>Constructors & Core Methods</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Method</th><th>Description</th></tr>
      <tr><td><code>Init(appName.s = 'PB App')</code></td><td>Initializes the application environment and sets up global registry.</td></tr>
      <tr><td><code>Run()</code></td><td>Starts the main event dispatch loop until all windows are closed.</td></tr>
      <tr><td><code>Exit()</code></td><td>Requests clean termination of the event loop.</td></tr>
      <tr><td><code>AddWindow(*win.UI::Window)</code></td><td>Registers a window in the application lifecycle.</td></tr>
    </table>
  </div>
</div>
""", "application")

# ============================================================================
# INDEX (OVERVIEW)
# ============================================================================
save_page("fr", "index.html", "Vue d'ensemble", "Documentation officielle du framework PureBasic Orienté Objet.", "badge-ui", "Aperçu", """
<div class='doc-section'>
  <h2 class='section-title'>Bienvenue dans PureBasic OOP</h2>
  <p>PureBasic OOP apporte la puissance de la Programmation Orientée Objet complète à PureBasic grâce à un transpileur optimisé et une bibliothèque UI native moderne.</p>
  <div class='callout callout-tip'>
    <div class='callout-title'>💡 Touche d'aide contextuelle F1</div>
    <p>Dans l'IDE, placez votre curseur sur n'importe quel mot-clé POO (<code>Class</code>, <code>Method</code>, <code>Super</code>, <code>Property</code>...) ou composant UI (<code>Window</code>, <code>Button</code>, <code>StackPanel</code>, <code>ListIcon</code>...) et appuyez sur <strong>F1</strong> pour ouvrir directement sa fiche d'aide détaillée avec son arbre d'héritage !</p>
  </div>
</div>

<div class='doc-section'>
  <h2 class='section-title'>Hiérarchie Globale des Composants UI</h2>
  <div class='inheritance-box'>
    <div class='inheritance-header'>Arbre d'héritage UI</div>
    <div class='table-wrapper'>
      <table>
        <tr><th>Classe de Base</th><th>Spécialisation</th><th>Composants Dérivés</th></tr>
        <tr>
          <td><a href='ui/component.html' class='inheritance-node'>UI::Component</a></td>
          <td><a href='ui/gadget.html' class='inheritance-node'>UI::Gadget</a></td>
          <td><a href='ui/button.html' class='derived-badge'>Button</a> <a href='ui/checkbox.html' class='derived-badge'>CheckBox</a> <a href='ui/combobox.html' class='derived-badge'>ComboBox</a> <a href='ui/label.html' class='derived-badge'>Label</a> <a href='ui/listicon.html' class='derived-badge'>ListIcon</a> <a href='ui/progressbar.html' class='derived-badge'>ProgressBar</a> <a href='ui/slider.html' class='derived-badge'>Slider</a> <a href='ui/textbox.html' class='derived-badge'>TextBox</a></td>
        </tr>
        <tr>
          <td><a href='ui/gadget.html' class='inheritance-node'>UI::Gadget</a></td>
          <td><a href='ui/customgadget.html' class='inheritance-node'>UI::CustomGadget</a></td>
          <td><a href='ui/toggleswitch.html' class='derived-badge'>ToggleSwitch</a></td>
        </tr>
        <tr>
          <td><a href='ui/component.html' class='inheritance-node'>UI::Component</a></td>
          <td><a href='ui/container.html' class='inheritance-node'>UI::Layouts::Container</a></td>
          <td><a href='ui/stackpanel.html' class='derived-badge'>StackPanel</a> <a href='ui/dockpanel.html' class='derived-badge'>DockPanel</a> <a href='ui/grid.html' class='derived-badge'>Grid</a></td>
        </tr>
        <tr>
          <td><a href='keywords/class.html' class='inheritance-node'>Core::Object</a></td>
          <td>-</td>
          <td><a href='ui/window.html' class='derived-badge'>Window</a> <a href='ui/application.html' class='derived-badge'>Application</a></td>
        </tr>
      </table>
    </div>
  </div>
</div>
""", "index")

save_page("en", "index.html", "Overview", "Official documentation for the PureBasic Object-Oriented Framework.", "badge-ui", "Overview", """
<div class='doc-section'>
  <h2 class='section-title'>Welcome to PureBasic OOP</h2>
  <p>PureBasic OOP brings full Object-Oriented Programming capabilities to PureBasic through a high-performance transpiler and modern native GUI library.</p>
  <div class='callout callout-tip'>
    <div class='callout-title'>💡 F1 Contextual Help</div>
    <p>In the IDE, position your cursor over any OOP keyword (<code>Class</code>, <code>Method</code>, <code>Super</code>, <code>Property</code>...) or UI component (<code>Window</code>, <code>Button</code>, <code>StackPanel</code>, <code>ListIcon</code>...) and press <strong>F1</strong> to open its documentation page and interactive inheritance chain!</p>
  </div>
</div>

<div class='doc-section'>
  <h2 class='section-title'>Global UI Component Hierarchy</h2>
  <div class='inheritance-box'>
    <div class='inheritance-header'>UI Inheritance Tree</div>
    <div class='table-wrapper'>
      <table>
        <tr><th>Base Class</th><th>Specialization</th><th>Derived Components</th></tr>
        <tr>
          <td><a href='ui/component.html' class='inheritance-node'>UI::Component</a></td>
          <td><a href='ui/gadget.html' class='inheritance-node'>UI::Gadget</a></td>
          <td><a href='ui/button.html' class='derived-badge'>Button</a> <a href='ui/checkbox.html' class='derived-badge'>CheckBox</a> <a href='ui/combobox.html' class='derived-badge'>ComboBox</a> <a href='ui/label.html' class='derived-badge'>Label</a> <a href='ui/listicon.html' class='derived-badge'>ListIcon</a> <a href='ui/progressbar.html' class='derived-badge'>ProgressBar</a> <a href='ui/slider.html' class='derived-badge'>Slider</a> <a href='ui/textbox.html' class='derived-badge'>TextBox</a></td>
        </tr>
        <tr>
          <td><a href='ui/gadget.html' class='inheritance-node'>UI::Gadget</a></td>
          <td><a href='ui/customgadget.html' class='inheritance-node'>UI::CustomGadget</a></td>
          <td><a href='ui/toggleswitch.html' class='derived-badge'>ToggleSwitch</a></td>
        </tr>
        <tr>
          <td><a href='ui/component.html' class='inheritance-node'>UI::Component</a></td>
          <td><a href='ui/container.html' class='inheritance-node'>UI::Layouts::Container</a></td>
          <td><a href='ui/stackpanel.html' class='derived-badge'>StackPanel</a> <a href='ui/dockpanel.html' class='derived-badge'>DockPanel</a> <a href='ui/grid.html' class='derived-badge'>Grid</a></td>
        </tr>
        <tr>
          <td><a href='keywords/class.html' class='inheritance-node'>Core::Object</a></td>
          <td>-</td>
          <td><a href='ui/window.html' class='derived-badge'>Window</a> <a href='ui/application.html' class='derived-badge'>Application</a></td>
        </tr>
      </table>
    </div>
  </div>
</div>
""", "index")

# ============================================================================
# KEYWORDS (FR & EN)
# ============================================================================
save_page("fr", "keywords/class.html", "Mots-clés Class & Abstract", "Définition de classes concrètes et abstraites en PureBasic OOP.", "badge-kw", "KW", """
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

save_page("en", "keywords/class.html", "Class & Abstract Keywords", "Defining concrete and abstract classes in PureBasic OOP.", "badge-kw", "KW", """
<div class='doc-section'>
  <h2 class='section-title'>Syntax</h2>
  <div class='code-container'>
    <div class='code-header'><span class='code-title'>Class declaration (.pbo)</span><span class='code-badge'>PBO</span></div>
    <pre><code><span class='kw'>Class</span> ClassName [<span class='kw'>Extends</span> ParentClass] {
  <span class='kw'>Public</span> [members / methods]
  <span class='kw'>Protected</span> [members / methods]
  <span class='kw'>Private</span> [members / methods]
}</code></pre>
  </div>
</div>
<div class='doc-section'>
  <h2 class='section-title'>Abstract Classes</h2>
  <p>An <code>Abstract Class</code> cannot be instantiated directly via <code>New</code>. It serves as a base contract for derived child classes.</p>
</div>
""", "class")

save_page("fr", "keywords/method.html", "Mots-clés Method & Override", "Définition de méthodes d'instance, polymorphisme et surcharge.", "badge-kw", "KW", """
<div class='doc-section'>
  <h2 class='section-title'>Syntaxe</h2>
  <div class='code-container'>
    <pre><code><span class='kw'>Public Method</span>.[Type] NomDeMethode(param1.[Type], param2.[Type] = defaut) {
  <span class='comment'>; Corps de la méthode</span>
  <span class='kw'>ProcedureReturn</span> resultat
}</code></pre>
  </div>
</div>
<div class='doc-section'>
  <h2 class='section-title'>Surcharge Polymorphique (Override)</h2>
  <p>Pour redéfinir une méthode héritée d'une classe parente, déclarez-la avec <code>Public Override Method</code> ou simplement <code>Public Method</code>.</p>
</div>
""", "method")

save_page("en", "keywords/method.html", "Method & Override Keywords", "Instance methods, polymorphism, and virtual overrides.", "badge-kw", "KW", """
<div class='doc-section'>
  <h2 class='section-title'>Syntax</h2>
  <div class='code-container'>
    <pre><code><span class='kw'>Public Method</span>.[Type] MethodName(param1.[Type], param2.[Type] = default) {
  <span class='comment'>; Method body</span>
  <span class='kw'>ProcedureReturn</span> result
}</code></pre>
  </div>
</div>
<div class='doc-section'>
  <h2 class='section-title'>Polymorphic Overrides</h2>
  <p>To redefine an inherited method from a parent class, declare it with <code>Public Override Method</code> or standard <code>Public Method</code>.</p>
</div>
""", "method")

save_page("fr", "keywords/inheritance.html", "Mots-clés Extends & Super", "Héritage de classes et appel des méthodes de la classe parente.", "badge-kw", "KW", """
<div class='doc-section'>
  <h2 class='section-title'>Héritage avec Extends</h2>
  <p>Le mot-clé <code>Extends</code> permet à une classe d'hériter de tous les membres et méthodes d'une classe parente.</p>
  <div class='code-container'>
    <pre><code><span class='kw'>Class</span> Button <span class='kw'>Extends</span> UI::Gadget {
  <span class='kw'>Public Method</span> Init(text.s) {
    <span class='kw'>Super</span>::Init()
    <span class='kw'>This</span>\\SetText(text)
  }
}</code></pre>
  </div>
</div>
<div class='doc-section'>
  <h2 class='section-title'>Accès Parent avec Super</h2>
  <p><code>Super::NomDeMethode()</code> appelle l'implémentation de la classe parente directe.</p>
</div>
""", "inheritance")

save_page("en", "keywords/inheritance.html", "Extends & Super Keywords", "Class inheritance and invoking parent implementations.", "badge-kw", "KW", """
<div class='doc-section'>
  <h2 class='section-title'>Inheritance with Extends</h2>
  <p>The <code>Extends</code> keyword allows a child class to inherit all public/protected members from a base class.</p>
  <div class='code-container'>
    <pre><code><span class='kw'>Class</span> Button <span class='kw'>Extends</span> UI::Gadget {
  <span class='kw'>Public Method</span> Init(text.s) {
    <span class='kw'>Super</span>::Init()
    <span class='kw'>This</span>\\SetText(text)
  }
}</code></pre>
  </div>
</div>
<div class='doc-section'>
  <h2 class='section-title'>Parent Invocation with Super</h2>
  <p><code>Super::MethodName()</code> delegates call to the immediate base class implementation.</p>
</div>
""", "inheritance")

save_page("fr", "keywords/properties.html", "Propriétés Getter & Setter", "Encapsulation propre des champs avec syntaxe de propriété.", "badge-kw", "KW", """
<div class='doc-section'>
  <h2 class='section-title'>Syntaxe</h2>
  <div class='code-container'>
    <pre><code><span class='kw'>Property</span> Title.s {
  <span class='kw'>Get</span> { <span class='kw'>ProcedureReturn</span> <span class='kw'>This</span>\\title }
  <span class='kw'>Set</span>(val.s) { <span class='kw'>This</span>\\title = val }
}</code></pre>
  </div>
</div>
""", "properties")

save_page("en", "keywords/properties.html", "Getter & Setter Properties", "Clean member encapsulation using property accessors.", "badge-kw", "KW", """
<div class='doc-section'>
  <h2 class='section-title'>Syntax</h2>
  <div class='code-container'>
    <pre><code><span class='kw'>Property</span> Title.s {
  <span class='kw'>Get</span> { <span class='kw'>ProcedureReturn</span> <span class='kw'>This</span>\\title }
  <span class='kw'>Set</span>(val.s) { <span class='kw'>This</span>\\title = val }
}</code></pre>
  </div>
</div>
""", "properties")

save_page("fr", "keywords/encapsulation.html", "Mots-clés Public, Protected & Private", "Contrôle d'accès et visibilité des membres.", "badge-kw", "KW", """
<div class='doc-section'>
  <h2 class='section-title'>Niveaux de Visibilité</h2>
  <ul>
    <li><code>Public</code> : Accessible depuis l'extérieur et toutes les sous-classes.</li>
    <li><code>Protected</code> : Accessible uniquement à l'intérieur de la classe et des sous-classes qui en héritent.</li>
    <li><code>Private</code> : Accessible strictement au sein de la classe déclarante.</li>
  </ul>
</div>
""", "encapsulation")

save_page("en", "keywords/encapsulation.html", "Public, Protected & Private Keywords", "Member access control and visibility rules.", "badge-kw", "KW", """
<div class='doc-section'>
  <h2 class='section-title'>Visibility Levels</h2>
  <ul>
    <li><code>Public</code> : Accessible everywhere and by all derived classes.</li>
    <li><code>Protected</code> : Accessible only within the class and inheriting subclasses.</li>
    <li><code>Private</code> : Strictly accessible within the declaring class.</li>
  </ul>
</div>
""", "encapsulation")

save_page("fr", "keywords/lifecycle.html", "Mots-clés New, Free & Init", "Cycle de vie des objets, allocation et libération mémoire.", "badge-kw", "KW", """
<div class='doc-section'>
  <h2 class='section-title'>Cycle de vie</h2>
  <div class='code-container'>
    <pre><code><span class='comment'>; Instanciation et initialisation</span>
<span class='kw'>Protected</span> *btn.UI::Button = <span class='kw'>NewObject</span>(UI::Button, <span class='str'>"Valider"</span>)

<span class='comment'>; Destruction</span>
<span class='kw'>FreeObject</span>(*btn)</code></pre>
  </div>
</div>
""", "lifecycle")

save_page("en", "keywords/lifecycle.html", "New, Free & Init Keywords", "Object lifecycle, instantiation, and memory disposal.", "badge-kw", "KW", """
<div class='doc-section'>
  <h2 class='section-title'>Object Lifecycle</h2>
  <div class='code-container'>
    <pre><code><span class='comment'>; Instantiation</span>
<span class='kw'>Protected</span> *btn.UI::Button = <span class='kw'>NewObject</span>(UI::Button, <span class='str'>"Submit"</span>)

<span class='comment'>; Disposal</span>
<span class='kw'>FreeObject</span>(*btn)</code></pre>
  </div>
</div>
""", "lifecycle")

save_page("fr", "keywords/operators.html", "Mots-clés This, Cast & TypeOf", "Opérateurs de contexte, transtypage et réflexion de type.", "badge-kw", "KW", """
<div class='doc-section'>
  <h2 class='section-title'>Opérateurs Spéciaux</h2>
  <ul>
    <li><code>This\\membre</code> : Référence à l'instance courante.</li>
    <li><code>Cast(Type, *instance)</code> : Transtypage sécurisé vers une classe parente ou dérivée.</li>
    <li><code>TypeOf(*instance)</code> : Retourne le nom de classe dynamique de l'objet.</li>
  </ul>
</div>
""", "operators")

save_page("en", "keywords/operators.html", "This, Cast & TypeOf Operators", "Context references, safe casting, and dynamic type reflection.", "badge-kw", "KW", """
<div class='doc-section'>
  <h2 class='section-title'>Special Operators</h2>
  <ul>
    <li><code>This\\member</code> : Reference to the current object instance.</li>
    <li><code>Cast(Type, *instance)</code> : Type-safe casting between hierarchy levels.</li>
    <li><code>TypeOf(*instance)</code> : Returns the runtime class name.</li>
  </ul>
</div>
""", "operators")

print("All HTML documentation files with inheritance hierarchy generated successfully!")

