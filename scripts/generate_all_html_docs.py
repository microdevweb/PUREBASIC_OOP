# -*- coding: utf-8 -*-
# ============================================================================
# PureBasic OOP Complete HTML Documentation Generator
# Generates all HTML documentation files with inheritance hierarchy & MVVM (FR & EN)
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
        ("datepicker", "DatePicker", "ui/datepicker.html", "UI"),
        ("editor", "Editor", "ui/editor.html", "UI"),
        ("groupbox", "GroupBox", "ui/groupbox.html", "UI"),
        ("label", "Label", "ui/label.html", "UI"),
        ("listicon", "ListIcon", "ui/listicon.html", "UI"),
        ("listview", "ListView", "ui/listview.html", "UI"),
        ("progressbar", "ProgressBar", "ui/progressbar.html", "UI"),
        ("radiobutton", "RadioButton", "ui/radiobutton.html", "UI"),
        ("slider", "Slider", "ui/slider.html", "UI"),
        ("spinbox", "SpinBox", "ui/spinbox.html", "UI"),
        ("tabcontrol", "TabControl", "ui/tabcontrol.html", "UI"),
        ("textbox", "TextBox", "ui/textbox.html", "UI"),
        ("toggleswitch", "ToggleSwitch", "ui/toggleswitch.html", "UI"),
        ("treeview", "TreeView", "ui/treeview.html", "UI")
    ]),
    ("Layouts Responsifs (WPF)", [
        ("stackpanel", "StackPanel", "ui/stackpanel.html", "WPF"),
        ("dockpanel", "DockPanel", "ui/dockpanel.html", "WPF"),
        ("grid", "Grid", "ui/grid.html", "WPF")
    ]),
    ("Architecture MVVM & DataBinding", [
        ("mvvm", "Architecture MVVM & Bindings", "ui/mvvm.html", "MVVM")
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
        ("datepicker", "DatePicker", "ui/datepicker.html", "UI"),
        ("editor", "Editor", "ui/editor.html", "UI"),
        ("groupbox", "GroupBox", "ui/groupbox.html", "UI"),
        ("label", "Label", "ui/label.html", "UI"),
        ("listicon", "ListIcon", "ui/listicon.html", "UI"),
        ("listview", "ListView", "ui/listview.html", "UI"),
        ("progressbar", "ProgressBar", "ui/progressbar.html", "UI"),
        ("radiobutton", "RadioButton", "ui/radiobutton.html", "UI"),
        ("slider", "Slider", "ui/slider.html", "UI"),
        ("spinbox", "SpinBox", "ui/spinbox.html", "UI"),
        ("tabcontrol", "TabControl", "ui/tabcontrol.html", "UI"),
        ("textbox", "TextBox", "ui/textbox.html", "UI"),
        ("toggleswitch", "ToggleSwitch", "ui/toggleswitch.html", "UI"),
        ("treeview", "TreeView", "ui/treeview.html", "UI")
    ]),
    ("Responsive Layouts (WPF)", [
        ("stackpanel", "StackPanel", "ui/stackpanel.html", "WPF"),
        ("dockpanel", "DockPanel", "ui/dockpanel.html", "WPF"),
        ("grid", "Grid", "ui/grid.html", "WPF")
    ]),
    ("MVVM Architecture & DataBinding", [
        ("mvvm", "MVVM Architecture & Bindings", "ui/mvvm.html", "MVVM")
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
            ("UI::DatePicker", "datepicker.html"),
            ("UI::Editor", "editor.html"),
            ("UI::GroupBox", "groupbox.html"),
            ("UI::Label", "label.html"),
            ("UI::ListIcon", "listicon.html"),
            ("UI::ListView", "listview.html"),
            ("UI::ProgressBar", "progressbar.html"),
            ("UI::RadioButton", "radiobutton.html"),
            ("UI::Slider", "slider.html"),
            ("UI::SpinBox", "spinbox.html"),
            ("UI::TabControl", "tabcontrol.html"),
            ("UI::TextBox", "textbox.html"),
            ("UI::TreeView", "treeview.html"),
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
    "datepicker": {
        "ancestors": [("Core::Object", "../keywords/class.html"), ("UI::Component", "component.html"), ("UI::Gadget", "gadget.html"), ("UI::DatePicker", "datepicker.html")],
        "derived": [],
        "inherited": [
            ("UI::Gadget", "gadget.html", ["GetID()", "GetHandle()", "SetFont()", "SetColor()", "FreeGadget()", "SetToolTip()", "SetFocus()"]),
            ("UI::Component", "component.html", ["SetPosition()", "SetSize()", "SetMargin()", "SetHorizontalAlignment()", "SetVerticalAlignment()", "SetVisible()", "SetEnabled()", "Arrange()"])
        ]
    },
    "editor": {
        "ancestors": [("Core::Object", "../keywords/class.html"), ("UI::Component", "component.html"), ("UI::Gadget", "gadget.html"), ("UI::Editor", "editor.html")],
        "derived": [],
        "inherited": [
            ("UI::Gadget", "gadget.html", ["GetID()", "GetHandle()", "SetFont()", "SetColor()", "FreeGadget()", "SetToolTip()", "SetFocus()"]),
            ("UI::Component", "component.html", ["SetPosition()", "SetSize()", "SetMargin()", "SetHorizontalAlignment()", "SetVerticalAlignment()", "SetVisible()", "SetEnabled()", "Arrange()"])
        ]
    },
    "groupbox": {
        "ancestors": [("Core::Object", "../keywords/class.html"), ("UI::Component", "component.html"), ("UI::Gadget", "gadget.html"), ("UI::GroupBox", "groupbox.html")],
        "derived": [],
        "inherited": [
            ("UI::Gadget", "gadget.html", ["GetID()", "GetHandle()", "SetFont()", "SetColor()", "FreeGadget()", "SetToolTip()"]),
            ("UI::Component", "component.html", ["SetPosition()", "SetSize()", "SetMargin()", "SetHorizontalAlignment()", "SetVerticalAlignment()", "SetVisible()", "Arrange()"])
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
    "listview": {
        "ancestors": [("Core::Object", "../keywords/class.html"), ("UI::Component", "component.html"), ("UI::Gadget", "gadget.html"), ("UI::ListView", "listview.html")],
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
    "radiobutton": {
        "ancestors": [("Core::Object", "../keywords/class.html"), ("UI::Component", "component.html"), ("UI::Gadget", "gadget.html"), ("UI::RadioButton", "radiobutton.html")],
        "derived": [],
        "inherited": [
            ("UI::Gadget", "gadget.html", ["GetID()", "GetHandle()", "SetFont()", "SetColor()", "FreeGadget()", "SetToolTip()", "SetFocus()"]),
            ("UI::Component", "component.html", ["SetPosition()", "SetSize()", "SetMargin()", "SetHorizontalAlignment()", "SetVerticalAlignment()", "SetVisible()", "SetEnabled()", "Arrange()"])
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
    "spinbox": {
        "ancestors": [("Core::Object", "../keywords/class.html"), ("UI::Component", "component.html"), ("UI::Gadget", "gadget.html"), ("UI::SpinBox", "spinbox.html")],
        "derived": [],
        "inherited": [
            ("UI::Gadget", "gadget.html", ["GetID()", "GetHandle()", "SetFont()", "SetColor()", "FreeGadget()", "SetToolTip()", "SetFocus()"]),
            ("UI::Component", "component.html", ["SetPosition()", "SetSize()", "SetMargin()", "SetHorizontalAlignment()", "SetVerticalAlignment()", "SetVisible()", "SetEnabled()", "Arrange()"])
        ]
    },
    "tabcontrol": {
        "ancestors": [("Core::Object", "../keywords/class.html"), ("UI::Component", "component.html"), ("UI::Gadget", "gadget.html"), ("UI::TabControl", "tabcontrol.html")],
        "derived": [],
        "inherited": [
            ("UI::Gadget", "gadget.html", ["GetID()", "GetHandle()", "SetFont()", "SetColor()", "FreeGadget()", "SetToolTip()", "SetFocus()"]),
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
    "treeview": {
        "ancestors": [("Core::Object", "../keywords/class.html"), ("UI::Component", "component.html"), ("UI::Gadget", "gadget.html"), ("UI::TreeView", "treeview.html")],
        "derived": [],
        "inherited": [
            ("UI::Gadget", "gadget.html", ["GetID()", "GetHandle()", "SetFont()", "SetColor()", "FreeGadget()", "SetToolTip()", "SetFocus()"]),
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
    },
    "mvvm": {
        "ancestors": [("Core::Object", "../keywords/class.html"), ("MVVM::ObservableObject", "mvvm.html"), ("MVVM::ViewModelBase", "mvvm.html")],
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
    inheritance_html = render_inheritance_widget(lang, current_key) if current_key != "index" else ""
    
    category = "Composants UI" if is_fr else "UI Components"
    if "keywords/" in rel_target:
        category = "Mots-clés POO" if is_fr else "OOP Keywords"
    elif current_key == "mvvm":
        category = "Architecture MVVM" if is_fr else "MVVM Architecture"
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
# INDEX
# ============================================================================
save_page("fr", "index.html", "Vue d'ensemble", "Documentation officielle du framework PureBasic Orienté Objet.", "badge-ui", "Aperçu", """
<div class='doc-section'>
  <h2 class='section-title'>Bienvenue dans PureBasic OOP</h2>
  <p>PureBasic OOP apporte la puissance de la Programmation Orientée Objet complète à PureBasic grâce à un transpileur optimisé, une bibliothèque UI native moderne (layouts WPF, 18 gadgets encapsulés) et une architecture MVVM déclarative avec DataBinding bidirectionnel.</p>
  <div class='callout callout-tip'>
    <div class='callout-title'>💡 Touche d'aide contextuelle F1</div>
    <p>Dans l'IDE, placez votre curseur sur n'importe quel mot-clé POO (<code>Class</code>, <code>Method</code>, <code>Super</code>, <code>Property</code>...), composant UI (<code>Window</code>, <code>Button</code>, <code>Editor</code>, <code>ListView</code>, <code>TreeView</code>, <code>StackPanel</code>...) ou classe MVVM (<code>ObservableObject</code>, <code>ViewModelBase</code>, <code>StringProperty</code>...) et appuyez sur <strong>F1</strong> pour ouvrir directement sa fiche d'aide détaillée avec son arbre d'héritage !</p>
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
          <td>
            <a href='ui/button.html' class='derived-badge'>Button</a>
            <a href='ui/checkbox.html' class='derived-badge'>CheckBox</a>
            <a href='ui/combobox.html' class='derived-badge'>ComboBox</a>
            <a href='ui/datepicker.html' class='derived-badge'>DatePicker</a>
            <a href='ui/editor.html' class='derived-badge'>Editor</a>
            <a href='ui/groupbox.html' class='derived-badge'>GroupBox</a>
            <a href='ui/label.html' class='derived-badge'>Label</a>
            <a href='ui/listicon.html' class='derived-badge'>ListIcon</a>
            <a href='ui/listview.html' class='derived-badge'>ListView</a>
            <a href='ui/progressbar.html' class='derived-badge'>ProgressBar</a>
            <a href='ui/radiobutton.html' class='derived-badge'>RadioButton</a>
            <a href='ui/slider.html' class='derived-badge'>Slider</a>
            <a href='ui/spinbox.html' class='derived-badge'>SpinBox</a>
            <a href='ui/tabcontrol.html' class='derived-badge'>TabControl</a>
            <a href='ui/textbox.html' class='derived-badge'>TextBox</a>
            <a href='ui/treeview.html' class='derived-badge'>TreeView</a>
          </td>
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
          <td>Architecture MVVM</td>
          <td><a href='ui/mvvm.html' class='derived-badge'>ObservableObject</a> <a href='ui/mvvm.html' class='derived-badge'>ViewModelBase</a> <a href='ui/mvvm.html' class='derived-badge'>BindingEngine</a></td>
        </tr>
        <tr>
          <td><a href='keywords/class.html' class='inheritance-node'>Core::Object</a></td>
          <td>Socle Core</td>
          <td><a href='ui/window.html' class='derived-badge'>Window</a> <a href='ui/application.html' class='derived-badge'>Application</a></td>
        </tr>
      </table>
    </div>
  </div>
</div>
""", "index")

save_page("en", "index.html", "Overview", "Official documentation for the PureBasic Object-Oriented framework.", "badge-ui", "Overview", """
<div class='doc-section'>
  <h2 class='section-title'>Welcome to PureBasic OOP</h2>
  <p>PureBasic OOP brings full Object-Oriented Programming to PureBasic through a high-performance transpiler, a modern native UI library (WPF-style responsive layouts, 18 encapsulated gadgets), and a declarative MVVM architecture with two-way DataBinding.</p>
  <div class='callout callout-tip'>
    <div class='callout-title'>💡 Contextual Help Key F1</div>
    <p>In the IDE, place your cursor on any OOP keyword (<code>Class</code>, <code>Method</code>, <code>Super</code>, <code>Property</code>...), UI control (<code>Window</code>, <code>Button</code>, <code>Editor</code>, <code>ListView</code>, <code>TreeView</code>, <code>StackPanel</code>...), or MVVM class (<code>ObservableObject</code>, <code>ViewModelBase</code>, <code>StringProperty</code>...) and press <strong>F1</strong> to open its detailed reference page with full inheritance hierarchy!</p>
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
          <td>
            <a href='ui/button.html' class='derived-badge'>Button</a>
            <a href='ui/checkbox.html' class='derived-badge'>CheckBox</a>
            <a href='ui/combobox.html' class='derived-badge'>ComboBox</a>
            <a href='ui/datepicker.html' class='derived-badge'>DatePicker</a>
            <a href='ui/editor.html' class='derived-badge'>Editor</a>
            <a href='ui/groupbox.html' class='derived-badge'>GroupBox</a>
            <a href='ui/label.html' class='derived-badge'>Label</a>
            <a href='ui/listicon.html' class='derived-badge'>ListIcon</a>
            <a href='ui/listview.html' class='derived-badge'>ListView</a>
            <a href='ui/progressbar.html' class='derived-badge'>ProgressBar</a>
            <a href='ui/radiobutton.html' class='derived-badge'>RadioButton</a>
            <a href='ui/slider.html' class='derived-badge'>Slider</a>
            <a href='ui/spinbox.html' class='derived-badge'>SpinBox</a>
            <a href='ui/tabcontrol.html' class='derived-badge'>TabControl</a>
            <a href='ui/textbox.html' class='derived-badge'>TextBox</a>
            <a href='ui/treeview.html' class='derived-badge'>TreeView</a>
          </td>
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
          <td>MVVM Architecture</td>
          <td><a href='ui/mvvm.html' class='derived-badge'>ObservableObject</a> <a href='ui/mvvm.html' class='derived-badge'>ViewModelBase</a> <a href='ui/mvvm.html' class='derived-badge'>BindingEngine</a></td>
        </tr>
        <tr>
          <td><a href='keywords/class.html' class='inheritance-node'>Core::Object</a></td>
          <td>Core Base</td>
          <td><a href='ui/window.html' class='derived-badge'>Window</a> <a href='ui/application.html' class='derived-badge'>Application</a></td>
        </tr>
      </table>
    </div>
  </div>
</div>
""", "index")

# ============================================================================
# COMPONENT
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
      <tr><td><code>#UI_Align_Stretch</code></td><td>3</td><td>Stretch across entire available width (default)</td></tr>
      <tr><td><code>#UI_Align_Top</code></td><td>0</td><td>Align to top edge</td></tr>
      <tr><td><code>#UI_Align_Middle</code></td><td>1</td><td>Center vertically</td></tr>
      <tr><td><code>#UI_Align_Bottom</code></td><td>2</td><td>Align to bottom edge</td></tr>
      <tr><td><code>#UI_Align_VStretch</code></td><td>3</td><td>Stretch across entire available height (default)</td></tr>
    </table>
  </div>
</div>

<div class='doc-section'>
  <h2 class='section-title'>Core Component Methods</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Method</th><th>Description</th></tr>
      <tr><td><code>SetPosition(x.i, y.i)</code></td><td>Manually sets the X, Y position of the component.</td></tr>
      <tr><td><code>SetSize(w.i, h.i)</code></td><td>Manually sets width and height.</td></tr>
      <tr><td><code>SetMargin(l.i, t.i, r.i, b.i)</code></td><td>Sets external margins (Left, Top, Right, Bottom) in pixels.</td></tr>
      <tr><td><code>SetMarginAll(m.i)</code></td><td>Sets identical margin on all 4 sides.</td></tr>
      <tr><td><code>SetHorizontalAlignment(align.i)</code></td><td>Sets horizontal alignment (<code>#UI_Align_Left</code>, <code>#UI_Align_Center</code>, etc.).</td></tr>
      <tr><td><code>SetVerticalAlignment(align.i)</code></td><td>Sets vertical alignment (<code>#UI_Align_Top</code>, <code>#UI_Align_Middle</code>, etc.).</td></tr>
      <tr><td><code>SetDesiredSize(w.i, h.i)</code></td><td>Sets preferred size requested by component to layout panels.</td></tr>
      <tr><td><code>GetDesiredWidth() / GetDesiredHeight()</code></td><td>Returns desired dimensions including margins.</td></tr>
      <tr><td><code>SetVisible(v.b) / IsVisible()</code></td><td>Toggles element visibility.</td></tr>
      <tr><td><code>SetEnabled(e.b) / IsEnabled()</code></td><td>Toggles user interactivity.</td></tr>
      <tr><td><code>Arrange(targetX.i, targetY.i, targetW.i, targetH.i)</code></td><td>Calculates final bounding box and positions/resizes gadget.</td></tr>
    </table>
  </div>
</div>
""", "component")

# ============================================================================
# GADGET
# ============================================================================
save_page("fr", "ui/gadget.html", "Classe Gadget", "Classe de base encapsulant un gadget natif PureBasic avec routage d'événements.", "badge-ui", "Base Native", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>La classe <code>UI::Gadget</code> (héritant de <code>UI::Component</code>) est la racine de tous les contrôles natifs du système d'exploitation créés par PureBasic. Elle encapsule l'identifiant interne PureBasic (<code>#PB_Any</code>), le Handle natif de l'OS (HWND sur Windows), la gestion des polices, couleurs et l'événement virtuel <code>OnEvent(eventType.i)</code>.</p>
</div>

<div class='doc-section'>
  <h2 class='section-title'>Méthodes Principales de Gadget</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Méthode</th><th>Description</th></tr>
      <tr><td><code>GetID()</code></td><td>Retourne l'identifiant PB interne du gadget.</td></tr>
      <tr><td><code>GetHandle()</code></td><td>Retourne le Handle natif du système d'exploitation (HWND).</td></tr>
      <tr><td><code>SetFont(fontID.i)</code></td><td>Applique une police typographique au contrôle.</td></tr>
      <tr><td><code>SetColor(colorType.i, color.i)</code></td><td>Définit la couleur du texte ou de fond (ex: <code>#PB_Gadget_FrontColor</code>).</td></tr>
      <tr><td><code>SetToolTip(tip.s)</code></td><td>Définit le texte de l'infobulle d'aide au survol.</td></tr>
      <tr><td><code>SetFocus()</code></td><td>Donne le focus clavier à ce contrôle.</td></tr>
      <tr><td><code>OnEvent(eventType.i)</code></td><td>Méthode virtuelle appelée automatiquement lors de la réception d'un événement PB sur ce gadget.</td></tr>
      <tr><td><code>FreeGadget()</code></td><td>Détruit le gadget natif proprement.</td></tr>
    </table>
  </div>
</div>
""", "gadget")

save_page("en", "ui/gadget.html", "Gadget Class", "Base class encapsulating native PureBasic OS gadgets with automated event dispatching.", "badge-ui", "Native Base", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>The <code>UI::Gadget</code> class (inheriting from <code>UI::Component</code>) is the parent of all native operating system controls created by PureBasic. It encapsulates the internal PB ID (<code>#PB_Any</code>), the native OS Handle (HWND on Windows), font/color management, tooltips, and virtual event handling via <code>OnEvent(eventType.i)</code>.</p>
</div>

<div class='doc-section'>
  <h2 class='section-title'>Core Gadget Methods</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Method</th><th>Description</th></tr>
      <tr><td><code>GetID()</code></td><td>Returns the internal PureBasic gadget ID.</td></tr>
      <tr><td><code>GetHandle()</code></td><td>Returns the native OS window handle (HWND).</td></tr>
      <tr><td><code>SetFont(fontID.i)</code></td><td>Applies a custom font to the control.</td></tr>
      <tr><td><code>SetColor(colorType.i, color.i)</code></td><td>Sets text or background color (e.g. <code>#PB_Gadget_FrontColor</code>).</td></tr>
      <tr><td><code>SetToolTip(tip.s)</code></td><td>Sets tooltip text shown on mouse hover.</td></tr>
      <tr><td><code>SetFocus()</code></td><td>Grants keyboard focus to this control.</td></tr>
      <tr><td><code>OnEvent(eventType.i)</code></td><td>Virtual method triggered automatically upon receiving PB events for this gadget.</td></tr>
      <tr><td><code>FreeGadget()</code></td><td>Disposes the native OS gadget safely.</td></tr>
    </table>
  </div>
</div>
""", "gadget")

# ============================================================================
# BUTTON
# ============================================================================
save_page("fr", "ui/button.html", "Classe Button", "Contrôle bouton poussoir cliquable avec multi-constructeurs et événement OnClick().", "badge-ui", "UI Class", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>La classe <code>UI::Button</code> encapsule un bouton poussoir PureBasic (<code>ButtonGadget</code>). Elle permet d'intercepter directement les clics via la méthode virtuelle <code>OnClick()</code> ou via les Bindings MVVM.</p>
</div>

<div class='doc-section'>
  <h2 class='section-title'>Constructeurs</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Constructeur</th><th>Description</th></tr>
      <tr><td><code>Init()</code></td><td>Bouton par défaut sans texte (taille gérée par le layout).</td></tr>
      <tr><td><code>Init(text.s)</code></td><td>Bouton avec libellé textuel initial.</td></tr>
      <tr><td><code>Init(x.i, y.i, w.i, h.i, text.s)</code></td><td>Bouton avec coordonnées et dimensions absolues.</td></tr>
    </table>
  </div>
</div>

<div class='doc-section'>
  <h2 class='section-title'>Méthodes Spécifiques</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Méthode</th><th>Description</th></tr>
      <tr><td><code>GetText()</code></td><td>Retourne le libellé textuel du bouton.</td></tr>
      <tr><td><code>SetText(text.s)</code></td><td>Modifie le texte affiché sur le bouton.</td></tr>
      <tr><td><code>OnClick()</code></td><td>Méthode virtuelle exécutée lors d'un clic utilisateur.</td></tr>
    </table>
  </div>
</div>
""", "button")

save_page("en", "ui/button.html", "Button Class", "Clickable push-button control with multi-constructors and virtual OnClick() event.", "badge-ui", "UI Class", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>The <code>UI::Button</code> class wraps PureBasic's <code>ButtonGadget</code>. It enables direct click handling via the virtual <code>OnClick()</code> method or declarative MVVM Command binding.</p>
</div>

<div class='doc-section'>
  <h2 class='section-title'>Constructors</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Constructor</th><th>Description</th></tr>
      <tr><td><code>Init()</code></td><td>Default button without text (bounds handled by responsive layout).</td></tr>
      <tr><td><code>Init(text.s)</code></td><td>Button initialized with caption text.</td></tr>
      <tr><td><code>Init(x.i, y.i, w.i, h.i, text.s)</code></td><td>Button with explicit absolute position and dimensions.</td></tr>
    </table>
  </div>
</div>

<div class='doc-section'>
  <h2 class='section-title'>Specific Methods</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Method</th><th>Description</th></tr>
      <tr><td><code>GetText()</code></td><td>Returns current button caption text.</td></tr>
      <tr><td><code>SetText(text.s)</code></td><td>Updates the button caption text.</td></tr>
      <tr><td><code>OnClick()</code></td><td>Virtual method invoked on user click.</td></tr>
    </table>
  </div>
</div>
""", "button")

# ============================================================================
# CHECKBOX
# ============================================================================
save_page("fr", "ui/checkbox.html", "Classe CheckBox", "Case à cocher avec état binaire ou trois états.", "badge-ui", "UI Class", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>La classe <code>UI::CheckBox</code> encapsule une case à cocher PureBasic (<code>CheckBoxGadget</code>). Elle gère les états cochés/décochés et notifie les changements d'état via <code>OnClick()</code>.</p>
</div>

<div class='doc-section'>
  <h2 class='section-title'>Constructeurs & Méthodes</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Signature</th><th>Description</th></tr>
      <tr><td><code>Init(text.s, state.b = #False)</code></td><td>Initialise la case à cocher avec son libellé et son état initial.</td></tr>
      <tr><td><code>IsChecked()</code></td><td>Retourne <code>#True</code> si la case est cochée, <code>#False</code> sinon.</td></tr>
      <tr><td><code>SetChecked(state.b)</code></td><td>Active ou désactive la coche de la case.</td></tr>
      <tr><td><code>GetText() / SetText(text.s)</code></td><td>Lit ou modifie le texte de la case.</td></tr>
    </table>
  </div>
</div>
""", "checkbox")

save_page("en", "ui/checkbox.html", "CheckBox Class", "Checkable toggle box with boolean checked state.", "badge-ui", "UI Class", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>The <code>UI::CheckBox</code> class wraps PureBasic's <code>CheckBoxGadget</code>. It provides convenient boolean state checking and updates with event dispatching.</p>
</div>

<div class='doc-section'>
  <h2 class='section-title'>Constructors & Methods</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Signature</th><th>Description</th></tr>
      <tr><td><code>Init(text.s, state.b = #False)</code></td><td>Initializes checkbox with caption and initial boolean state.</td></tr>
      <tr><td><code>IsChecked()</code></td><td>Returns <code>#True</code> if checked, <code>#False</code> otherwise.</td></tr>
      <tr><td><code>SetChecked(state.b)</code></td><td>Sets checked state.</td></tr>
      <tr><td><code>GetText() / SetText(text.s)</code></td><td>Gets or sets caption text.</td></tr>
    </table>
  </div>
</div>
""", "checkbox")

# ============================================================================
# COMBOBOX
# ============================================================================
save_page("fr", "ui/combobox.html", "Classe ComboBox", "Liste déroulante de sélection d'éléments avec support d'événements.", "badge-ui", "UI Class", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>La classe <code>UI::ComboBox</code> encapsule une liste déroulante PureBasic (<code>ComboBoxGadget</code>). Elle permet d'ajouter des éléments, de gérer la sélection et d'intercepter les changements via <code>OnChange()</code>.</p>
</div>

<div class='doc-section'>
  <h2 class='section-title'>Méthodes Spécifiques</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Méthode</th><th>Description</th></tr>
      <tr><td><code>AddItem(text.s)</code></td><td>Ajoute un élément à la fin de la liste déroulante.</td></tr>
      <tr><td><code>Clear()</code></td><td>Vide tous les éléments de la liste.</td></tr>
      <tr><td><code>GetSelectedIndex()</code></td><td>Retourne l'index de l'élément sélectionné (ou -1).</td></tr>
      <tr><td><code>SetSelectedIndex(index.i)</code></td><td>Sélectionne l'élément à l'index spécifié.</td></tr>
      <tr><td><code>GetItemText(index.i)</code></td><td>Retourne le texte de l'élément à l'index donné.</td></tr>
      <tr><td><code>OnChange()</code></td><td>Méthode virtuelle appelée lorsque l'utilisateur sélectionne un nouvel élément.</td></tr>
    </table>
  </div>
</div>
""", "combobox")

save_page("en", "ui/combobox.html", "ComboBox Class", "Drop-down selection list with item management and change events.", "badge-ui", "UI Class", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>The <code>UI::ComboBox</code> class wraps PureBasic's <code>ComboBoxGadget</code>. It provides item addition, selection queries, and change event handling via <code>OnChange()</code>.</p>
</div>

<div class='doc-section'>
  <h2 class='section-title'>Specific Methods</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Method</th><th>Description</th></tr>
      <tr><td><code>AddItem(text.s)</code></td><td>Appends an item to the dropdown list.</td></tr>
      <tr><td><code>Clear()</code></td><td>Clears all items in the list.</td></tr>
      <tr><td><code>GetSelectedIndex()</code></td><td>Returns current selected index (or -1).</td></tr>
      <tr><td><code>SetSelectedIndex(index.i)</code></td><td>Selects item at specified index.</td></tr>
      <tr><td><code>GetItemText(index.i)</code></td><td>Returns text of item at specified index.</td></tr>
      <tr><td><code>OnChange()</code></td><td>Virtual method triggered when user changes selection.</td></tr>
    </table>
  </div>
</div>
""", "combobox")

# ============================================================================
# DATEPICKER (NEW)
# ============================================================================
save_page("fr", "ui/datepicker.html", "Classe DatePicker", "Sélecteur de date et calendrier natif avec formatage personnalisable.", "badge-ui", "UI Class", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>La classe <code>UI::DatePicker</code> (dans <code>src/ui/controls/DatePicker.pbi</code>) encapsule le contrôle <code>DateGadget</code> de PureBasic. Elle permet à l'utilisateur de choisir une date via un calendrier déroulant interactif avec masque de format personnalisable.</p>
</div>

<div class='doc-section'>
  <h2 class='section-title'>Constructeurs</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Constructeur</th><th>Description</th></tr>
      <tr><td><code>Init(mask.s = "%dd/%mm/%yyyy")</code></td><td>Initialise le DatePicker avec le format de date spécifié (par défaut jour/mois/année).</td></tr>
      <tr><td><code>Init(x.i, y.i, w.i, h.i, mask.s = "%dd/%mm/%yyyy")</code></td><td>Initialise avec position et dimensions absolues.</td></tr>
    </table>
  </div>
</div>

<div class='doc-section'>
  <h2 class='section-title'>Méthodes Spécifiques</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Méthode</th><th>Description</th></tr>
      <tr><td><code>GetDate()</code></td><td>Retourne la date sélectionnée sous forme de timestamp PureBasic (entier).</td></tr>
      <tr><td><code>SetDate(date.i)</code></td><td>Définit la date sélectionnée via un timestamp PureBasic.</td></tr>
      <tr><td><code>GetDateString(mask.s = "")</code></td><td>Formate et retourne la date sous forme de chaîne de caractères selon le masque.</td></tr>
      <tr><td><code>SetMask(mask.s)</code></td><td>Modifie le masque de format d'affichage de la date.</td></tr>
      <tr><td><code>OnChange()</code></td><td>Méthode virtuelle appelée lors de la modification de la date sélectionnée.</td></tr>
    </table>
  </div>
</div>
""", "datepicker")

save_page("en", "ui/datepicker.html", "DatePicker Class", "Native date picker and calendar dropdown with customizable mask format.", "badge-ui", "UI Class", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>The <code>UI::DatePicker</code> class (in <code>src/ui/controls/DatePicker.pbi</code>) wraps PureBasic's <code>DateGadget</code>. It provides an interactive date selection box with calendar dropdown and formatting mask support.</p>
</div>

<div class='doc-section'>
  <h2 class='section-title'>Constructors</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Constructor</th><th>Description</th></tr>
      <tr><td><code>Init(mask.s = "%dd/%mm/%yyyy")</code></td><td>Initializes DatePicker with date format mask.</td></tr>
      <tr><td><code>Init(x.i, y.i, w.i, h.i, mask.s = "%dd/%mm/%yyyy")</code></td><td>Initializes with absolute bounds and mask.</td></tr>
    </table>
  </div>
</div>

<div class='doc-section'>
  <h2 class='section-title'>Specific Methods</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Method</th><th>Description</th></tr>
      <tr><td><code>GetDate()</code></td><td>Returns selected date as a PureBasic timestamp integer.</td></tr>
      <tr><td><code>SetDate(date.i)</code></td><td>Sets selected date using a timestamp integer.</td></tr>
      <tr><td><code>GetDateString(mask.s = "")</code></td><td>Returns formatted date string using specified or default mask.</td></tr>
      <tr><td><code>SetMask(mask.s)</code></td><td>Changes display formatting mask.</td></tr>
      <tr><td><code>OnChange()</code></td><td>Virtual method triggered when user changes selected date.</td></tr>
    </table>
  </div>
</div>
""", "datepicker")

# ============================================================================
# EDITOR (NEW)
# ============================================================================
save_page("fr", "ui/editor.html", "Classe Editor", "Zone d'édition multiligne de texte riche ou brut avec gestion d'événements.", "badge-ui", "UI Class", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>La classe <code>UI::Editor</code> (dans <code>src/ui/controls/Editor.pbi</code>) encapsule le contrôle natif <code>EditorGadget</code> de PureBasic. Elle fournit une zone d'édition multiligne pour la saisie de texte long, de code ou de logs avec mode lecture seule et retour à la ligne.</p>
</div>

<div class='doc-section'>
  <h2 class='section-title'>Constructeurs</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Constructeur</th><th>Description</th></tr>
      <tr><td><code>Init()</code></td><td>Initialise un éditeur multiligne vierge (adapté aux layouts réactifs).</td></tr>
      <tr><td><code>Init(x.i, y.i, w.i, h.i)</code></td><td>Initialise avec coordonnées et dimensions absolues.</td></tr>
    </table>
  </div>
</div>

<div class='doc-section'>
  <h2 class='section-title'>Méthodes Spécifiques</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Méthode</th><th>Description</th></tr>
      <tr><td><code>GetText()</code></td><td>Retourne l'intégralité du texte contenu dans l'éditeur.</td></tr>
      <tr><td><code>SetText(text.s)</code></td><td>Remplace le contenu complet de l'éditeur par la chaîne spécifiée.</td></tr>
      <tr><td><code>AddLine(text.s)</code></td><td>Ajoute une ligne de texte à la suite du contenu existant.</td></tr>
      <tr><td><code>Clear()</code></td><td>Efface tout le contenu de l'éditeur.</td></tr>
      <tr><td><code>SetReadOnly(readonly.b)</code></td><td>Bascule l'éditeur en mode lecture seule (ou modifiable).</td></tr>
      <tr><td><code>IsReadOnly()</code></td><td>Retourne <code>#True</code> si le contrôle est en lecture seule.</td></tr>
      <tr><td><code>SetWordWrap(wrap.b)</code></td><td>Active ou désactive le retour automatique à la ligne.</td></tr>
      <tr><td><code>OnChange()</code></td><td>Méthode virtuelle appelée lorsque le contenu texte est modifié.</td></tr>
    </table>
  </div>
</div>
""", "editor")

save_page("en", "ui/editor.html", "Editor Class", "Multiline text editor control for rich/plain text input and log viewers.", "badge-ui", "UI Class", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>The <code>UI::Editor</code> class (located in <code>src/ui/controls/Editor.pbi</code>) wraps PureBasic's <code>EditorGadget</code>. It provides a full multiline text editing area suitable for code editors, logs, and long text inputs with read-only and word-wrapping support.</p>
</div>

<div class='doc-section'>
  <h2 class='section-title'>Constructors</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Constructor</th><th>Description</th></tr>
      <tr><td><code>Init()</code></td><td>Initializes an empty multiline editor (responsive layout ready).</td></tr>
      <tr><td><code>Init(x.i, y.i, w.i, h.i)</code></td><td>Initializes with absolute position and size.</td></tr>
    </table>
  </div>
</div>

<div class='doc-section'>
  <h2 class='section-title'>Specific Methods</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Method</th><th>Description</th></tr>
      <tr><td><code>GetText()</code></td><td>Returns the full text content of the editor.</td></tr>
      <tr><td><code>SetText(text.s)</code></td><td>Replaces editor content with specified string.</td></tr>
      <tr><td><code>AddLine(text.s)</code></td><td>Appends a new line of text to the editor.</td></tr>
      <tr><td><code>Clear()</code></td><td>Clears all text in the editor.</td></tr>
      <tr><td><code>SetReadOnly(readonly.b)</code></td><td>Sets read-only mode on or off.</td></tr>
      <tr><td><code>IsReadOnly()</code></td><td>Returns <code>#True</code> if editor is read-only.</td></tr>
      <tr><td><code>SetWordWrap(wrap.b)</code></td><td>Enables or disables automatic word wrapping.</td></tr>
      <tr><td><code>OnChange()</code></td><td>Virtual method invoked when text content changes.</td></tr>
    </table>
  </div>
</div>
""", "editor")

# ============================================================================
# GROUPBOX (NEW)
# ============================================================================
save_page("fr", "ui/groupbox.html", "Classe GroupBox", "Cadre de regroupement visuel avec titre pour organiser les formulaires.", "badge-ui", "UI Class", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>La classe <code>UI::GroupBox</code> (dans <code>src/ui/controls/GroupBox.pbi</code>) encapsule le contrôle <code>FrameGadget</code> de PureBasic. Elle dessine un cadre décoratif avec un titre permettant de regrouper visuellement des contrôles connexes.</p>
</div>

<div class='doc-section'>
  <h2 class='section-title'>Constructeurs & Méthodes</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Signature</th><th>Description</th></tr>
      <tr><td><code>Init(text.s)</code></td><td>Initialise un cadre avec titre textuel.</td></tr>
      <tr><td><code>Init(x.i, y.i, w.i, h.i, text.s)</code></td><td>Initialise avec position, dimensions et titre absolus.</td></tr>
      <tr><td><code>GetText()</code></td><td>Retourne le titre du cadre.</td></tr>
      <tr><td><code>SetText(text.s)</code></td><td>Modifie le titre du cadre.</td></tr>
    </table>
  </div>
</div>
""", "groupbox")

save_page("en", "ui/groupbox.html", "GroupBox Class", "Visual grouping frame with title banner for organizing UI forms.", "badge-ui", "UI Class", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>The <code>UI::GroupBox</code> class (in <code>src/ui/controls/GroupBox.pbi</code>) encapsulates PureBasic's <code>FrameGadget</code>. It provides a visual framed border with a title caption to organize related controls.</p>
</div>

<div class='doc-section'>
  <h2 class='section-title'>Constructors & Methods</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Signature</th><th>Description</th></tr>
      <tr><td><code>Init(text.s)</code></td><td>Initializes group box frame with title.</td></tr>
      <tr><td><code>Init(x.i, y.i, w.i, h.i, text.s)</code></td><td>Initializes with absolute bounds and title.</td></tr>
      <tr><td><code>GetText()</code></td><td>Returns current frame title.</td></tr>
      <tr><td><code>SetText(text.s)</code></td><td>Updates frame title.</td></tr>
    </table>
  </div>
</div>
""", "groupbox")

# ============================================================================
# LABEL
# ============================================================================
save_page("fr", "ui/label.html", "Classe Label", "Contrôle d'affichage de texte statique ou informatif.", "badge-ui", "UI Class", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>La classe <code>UI::Label</code> encapsule le <code>TextGadget</code> de PureBasic. Elle affiche des libellés de formulaires, des titres ou des messages d'information.</p>
</div>

<div class='doc-section'>
  <h2 class='section-title'>Constructeurs & Méthodes</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Signature</th><th>Description</th></tr>
      <tr><td><code>Init(text.s)</code></td><td>Initialise un libellé avec son texte.</td></tr>
      <tr><td><code>Init(x.i, y.i, w.i, h.i, text.s)</code></td><td>Initialise avec coordonnées et dimensions absolues.</td></tr>
      <tr><td><code>GetText() / SetText(text.s)</code></td><td>Lit ou met à jour le texte du label.</td></tr>
    </table>
  </div>
</div>
""", "label")

save_page("en", "ui/label.html", "Label Class", "Static text display control for form labels and titles.", "badge-ui", "UI Class", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>The <code>UI::Label</code> class wraps PureBasic's <code>TextGadget</code>. It renders static text captions and informative messages.</p>
</div>

<div class='doc-section'>
  <h2 class='section-title'>Constructors & Methods</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Signature</th><th>Description</th></tr>
      <tr><td><code>Init(text.s)</code></td><td>Initializes label with caption text.</td></tr>
      <tr><td><code>Init(x.i, y.i, w.i, h.i, text.s)</code></td><td>Initializes with absolute position and size.</td></tr>
      <tr><td><code>GetText() / SetText(text.s)</code></td><td>Gets or sets label text.</td></tr>
    </table>
  </div>
</div>
""", "label")

# ============================================================================
# LISTICON
# ============================================================================
save_page("fr", "ui/listicon.html", "Classe ListIcon", "Tableau de données multicolonne avec icônes, cases à cocher et tri.", "badge-ui", "UI Class", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>La classe <code>UI::ListIcon</code> encapsule <code>ListIconGadget</code> de PureBasic. Elle permet d'afficher des données tabulaires multicolonnes avec tri, sélection de lignes et icônes.</p>
</div>

<div class='doc-section'>
  <h2 class='section-title'>Méthodes Spécifiques</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Méthode</th><th>Description</th></tr>
      <tr><td><code>AddColumn(col.i, title.s, width.i)</code></td><td>Ajoute ou configure une colonne dans le tableau.</td></tr>
      <tr><td><code>AddItem(text.s)</code></td><td>Ajoute une ligne complète (colonnes séparées par <code>#LF$</code>).</td></tr>
      <tr><td><code>GetSelectedIndex()</code></td><td>Retourne l'index de la ligne actuellement sélectionnée.</td></tr>
      <tr><td><code>SetSelectedIndex(index.i)</code></td><td>Sélectionne la ligne à l'index donné.</td></tr>
      <tr><td><code>Clear()</code></td><td>Efface toutes les lignes de la table.</td></tr>
      <tr><td><code>OnChange()</code></td><td>Événement virtuel déclenché lors d'un changement de sélection.</td></tr>
    </table>
  </div>
</div>
""", "listicon")

save_page("en", "ui/listicon.html", "ListIcon Class", "Multi-column data grid view with icons, columns, and row selection.", "badge-ui", "UI Class", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>The <code>UI::ListIcon</code> class encapsulates PureBasic's <code>ListIconGadget</code>. It provides a high-performance tabular multi-column grid view with row selection and column sizing.</p>
</div>

<div class='doc-section'>
  <h2 class='section-title'>Specific Methods</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Method</th><th>Description</th></tr>
      <tr><td><code>AddColumn(col.i, title.s, width.i)</code></td><td>Adds or configures a column header and width.</td></tr>
      <tr><td><code>AddItem(text.s)</code></td><td>Appends a row of items separated by <code>#LF$</code>.</td></tr>
      <tr><td><code>GetSelectedIndex()</code></td><td>Returns currently selected row index.</td></tr>
      <tr><td><code>SetSelectedIndex(index.i)</code></td><td>Selects row at specified index.</td></tr>
      <tr><td><code>Clear()</code></td><td>Removes all rows from the table.</td></tr>
      <tr><td><code>OnChange()</code></td><td>Virtual event triggered when selected row changes.</td></tr>
    </table>
  </div>
</div>
""", "listicon")

# ============================================================================
# LISTVIEW (NEW)
# ============================================================================
save_page("fr", "ui/listview.html", "Classe ListView", "Liste verticale d'éléments textuels avec sélection simple et événements.", "badge-ui", "UI Class", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>La classe <code>UI::ListView</code> (dans <code>src/ui/controls/ListView.pbi</code>) encapsule le contrôle <code>ListViewGadget</code> de PureBasic. Elle fournit une liste simple et efficace d'éléments textuels défilables avec détection de changement de sélection.</p>
</div>

<div class='doc-section'>
  <h2 class='section-title'>Constructeurs</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Constructeur</th><th>Description</th></tr>
      <tr><td><code>Init()</code></td><td>Initialise une liste vide (adaptée aux conteneurs de layout réactifs).</td></tr>
      <tr><td><code>Init(x.i, y.i, w.i, h.i)</code></td><td>Initialise avec coordonnées et dimensions absolues.</td></tr>
    </table>
  </div>
</div>

<div class='doc-section'>
  <h2 class='section-title'>Méthodes Spécifiques</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Méthode</th><th>Description</th></tr>
      <tr><td><code>AddItem(text.s)</code></td><td>Ajoute un élément à la fin de la liste.</td></tr>
      <tr><td><code>InsertItem(index.i, text.s)</code></td><td>Insère un élément à la position spécifiée.</td></tr>
      <tr><td><code>RemoveItem(index.i)</code></td><td>Supprime l'élément à l'index donné.</td></tr>
      <tr><td><code>Clear()</code></td><td>Vide l'intégralité des éléments de la liste.</td></tr>
      <tr><td><code>GetItemCount()</code></td><td>Retourne le nombre total d'éléments dans la liste.</td></tr>
      <tr><td><code>GetItemText(index.i)</code></td><td>Retourne le texte de l'élément à l'index donné.</td></tr>
      <tr><td><code>SetItemText(index.i, text.s)</code></td><td>Modifie le texte de l'élément à l'index spécifié.</td></tr>
      <tr><td><code>GetSelectedIndex()</code></td><td>Retourne l'index de l'élément actuellement sélectionné (ou -1).</td></tr>
      <tr><td><code>SetSelectedIndex(index.i)</code></td><td>Sélectionne l'élément à l'index donné.</td></tr>
      <tr><td><code>OnChange()</code></td><td>Méthode virtuelle appelée lorsque la sélection de l'utilisateur change.</td></tr>
    </table>
  </div>
</div>
""", "listview")

save_page("en", "ui/listview.html", "ListView Class", "Vertical listbox control for displaying and selecting items.", "badge-ui", "UI Class", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>The <code>UI::ListView</code> class (located in <code>src/ui/controls/ListView.pbi</code>) wraps PureBasic's <code>ListViewGadget</code>. It provides a simple scrollable list of text items with selection tracking and event dispatching.</p>
</div>

<div class='doc-section'>
  <h2 class='section-title'>Constructors</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Constructor</th><th>Description</th></tr>
      <tr><td><code>Init()</code></td><td>Initializes an empty listview (responsive layout ready).</td></tr>
      <tr><td><code>Init(x.i, y.i, w.i, h.i)</code></td><td>Initializes with explicit bounds.</td></tr>
    </table>
  </div>
</div>

<div class='doc-section'>
  <h2 class='section-title'>Specific Methods</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Method</th><th>Description</th></tr>
      <tr><td><code>AddItem(text.s)</code></td><td>Appends an item to the end of the list.</td></tr>
      <tr><td><code>InsertItem(index.i, text.s)</code></td><td>Inserts an item at specified position.</td></tr>
      <tr><td><code>RemoveItem(index.i)</code></td><td>Removes item at specified index.</td></tr>
      <tr><td><code>Clear()</code></td><td>Clears all items in the list.</td></tr>
      <tr><td><code>GetItemCount()</code></td><td>Returns total number of items.</td></tr>
      <tr><td><code>GetItemText(index.i)</code></td><td>Returns text of item at index.</td></tr>
      <tr><td><code>SetItemText(index.i, text.s)</code></td><td>Updates text of item at index.</td></tr>
      <tr><td><code>GetSelectedIndex()</code></td><td>Returns selected item index (or -1).</td></tr>
      <tr><td><code>SetSelectedIndex(index.i)</code></td><td>Selects item at specified index.</td></tr>
      <tr><td><code>OnChange()</code></td><td>Virtual method triggered on user selection change.</td></tr>
    </table>
  </div>
</div>
""", "listview")

# ============================================================================
# PROGRESSBAR
# ============================================================================
save_page("fr", "ui/progressbar.html", "Classe ProgressBar", "Barre de progression visuelle pour le suivi d'opérations et de tâches.", "badge-ui", "UI Class", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>La classe <code>UI::ProgressBar</code> encapsule le <code>ProgressBarGadget</code> de PureBasic. Elle permet d'afficher visuellement l'avancement d'un traitement en pourcentage ou valeur absolue.</p>
</div>

<div class='doc-section'>
  <h2 class='section-title'>Constructeurs & Méthodes</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Signature</th><th>Description</th></tr>
      <tr><td><code>Init(min.i = 0, max.i = 100)</code></td><td>Initialise la barre avec ses bornes minimale et maximale.</td></tr>
      <tr><td><code>GetValue() / SetValue(val.i)</code></td><td>Lit ou met à jour la valeur courante de progression.</td></tr>
      <tr><td><code>GetMinimum() / GetMaximum()</code></td><td>Retourne les limites de la barre.</td></tr>
    </table>
  </div>
</div>
""", "progressbar")

save_page("en", "ui/progressbar.html", "ProgressBar Class", "Visual progress indicator bar for operation and task tracking.", "badge-ui", "UI Class", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>The <code>UI::ProgressBar</code> class wraps PureBasic's <code>ProgressBarGadget</code>. It provides visual feedback for progress states between min and max bounds.</p>
</div>

<div class='doc-section'>
  <h2 class='section-title'>Constructors & Methods</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Signature</th><th>Description</th></tr>
      <tr><td><code>Init(min.i = 0, max.i = 100)</code></td><td>Initializes progress bar with range.</td></tr>
      <tr><td><code>GetValue() / SetValue(val.i)</code></td><td>Gets or sets current progress value.</td></tr>
      <tr><td><code>GetMinimum() / GetMaximum()</code></td><td>Queries progress range boundaries.</td></tr>
    </table>
  </div>
</div>
""", "progressbar")

# ============================================================================
# RADIOBUTTON (NEW)
# ============================================================================
save_page("fr", "ui/radiobutton.html", "Classe RadioButton", "Bouton d'option radio pour choix exclusif au sein d'un groupe.", "badge-ui", "UI Class", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>La classe <code>UI::RadioButton</code> (dans <code>src/ui/controls/RadioButton.pbi</code>) encapsule le contrôle <code>OptionGadget</code> de PureBasic. Elle permet de proposer à l'utilisateur un choix exclusif parmi un groupe d'options.</p>
</div>

<div class='doc-section'>
  <h2 class='section-title'>Constructeurs</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Constructeur</th><th>Description</th></tr>
      <tr><td><code>Init(text.s, group.i = 0)</code></td><td>Initialise un bouton radio avec son texte et son groupe optionnel (taille gérée par layout).</td></tr>
      <tr><td><code>Init(x.i, y.i, w.i, h.i, text.s, group.i = 0)</code></td><td>Initialise avec coordonnées, dimensions, texte et groupe absolus.</td></tr>
    </table>
  </div>
</div>

<div class='doc-section'>
  <h2 class='section-title'>Méthodes Spécifiques</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Méthode</th><th>Description</th></tr>
      <tr><td><code>IsChecked()</code></td><td>Retourne <code>#True</code> si le bouton radio est actuellement sélectionné.</td></tr>
      <tr><td><code>SetChecked(state.b)</code></td><td>Sélectionne (ou désélectionne) le bouton radio.</td></tr>
      <tr><td><code>GetText() / SetText(text.s)</code></td><td>Lit ou modifie le libellé textuel du bouton radio.</td></tr>
      <tr><td><code>GetGroup() / SetGroup(group.i)</code></td><td>Gère l'identifiant logique de groupe d'exclusivité.</td></tr>
      <tr><td><code>OnClick()</code></td><td>Méthode virtuelle appelée lorsque l'utilisateur clique sur l'option.</td></tr>
    </table>
  </div>
</div>
""", "radiobutton")

save_page("en", "ui/radiobutton.html", "RadioButton Class", "Radio option button for mutually exclusive choices in a group.", "badge-ui", "UI Class", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>The <code>UI::RadioButton</code> class (located in <code>src/ui/controls/RadioButton.pbi</code>) encapsulates PureBasic's <code>OptionGadget</code>. It provides mutually exclusive option selection within grouped controls.</p>
</div>

<div class='doc-section'>
  <h2 class='section-title'>Constructors</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Constructor</th><th>Description</th></tr>
      <tr><td><code>Init(text.s, group.i = 0)</code></td><td>Initializes radio button with text and optional group identifier.</td></tr>
      <tr><td><code>Init(x.i, y.i, w.i, h.i, text.s, group.i = 0)</code></td><td>Initializes with absolute bounds, caption, and group ID.</td></tr>
    </table>
  </div>
</div>

<div class='doc-section'>
  <h2 class='section-title'>Specific Methods</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Method</th><th>Description</th></tr>
      <tr><td><code>IsChecked()</code></td><td>Returns <code>#True</code> if radio option is currently active.</td></tr>
      <tr><td><code>SetChecked(state.b)</code></td><td>Sets radio option selected state.</td></tr>
      <tr><td><code>GetText() / SetText(text.s)</code></td><td>Gets or sets caption text.</td></tr>
      <tr><td><code>GetGroup() / SetGroup(group.i)</code></td><td>Gets or sets mutual exclusivity group index.</td></tr>
      <tr><td><code>OnClick()</code></td><td>Virtual method triggered on user selection.</td></tr>
    </table>
  </div>
</div>
""", "radiobutton")

# ============================================================================
# SLIDER
# ============================================================================
save_page("fr", "ui/slider.html", "Classe Slider", "Curseur de réglage numérique interactif (TrackBar).", "badge-ui", "UI Class", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>La classe <code>UI::Slider</code> encapsule le <code>TrackBarGadget</code> de PureBasic. Elle permet de sélectionner une valeur numérique continue entre deux bornes en déplaçant un curseur.</p>
</div>

<div class='doc-section'>
  <h2 class='section-title'>Constructeurs & Méthodes</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Signature</th><th>Description</th></tr>
      <tr><td><code>Init(min.i = 0, max.i = 100, val.i = 0)</code></td><td>Initialise le curseur avec ses bornes et sa valeur initiale.</td></tr>
      <tr><td><code>GetValue() / SetValue(val.i)</code></td><td>Lit ou met à jour la position courante du curseur.</td></tr>
      <tr><td><code>GetMinimum() / GetMaximum()</code></td><td>Retourne les valeurs minimale et maximale.</td></tr>
      <tr><td><code>OnChange()</code></td><td>Méthode virtuelle appelée lors du déplacement du curseur.</td></tr>
    </table>
  </div>
</div>
""", "slider")

save_page("en", "ui/slider.html", "Slider Class", "Interactive trackbar slider control for numerical range adjustment.", "badge-ui", "UI Class", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>The <code>UI::Slider</code> class wraps PureBasic's <code>TrackBarGadget</code>. It provides smooth numerical value selection across customizable bounds.</p>
</div>

<div class='doc-section'>
  <h2 class='section-title'>Constructors & Methods</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Signature</th><th>Description</th></tr>
      <tr><td><code>Init(min.i = 0, max.i = 100, val.i = 0)</code></td><td>Initializes trackbar with range boundaries and initial position.</td></tr>
      <tr><td><code>GetValue() / SetValue(val.i)</code></td><td>Gets or sets current slider position.</td></tr>
      <tr><td><code>GetMinimum() / GetMaximum()</code></td><td>Queries minimum and maximum slider values.</td></tr>
      <tr><td><code>OnChange()</code></td><td>Virtual method triggered when slider moves.</td></tr>
    </table>
  </div>
</div>
""", "slider")

# ============================================================================
# SPINBOX (NEW)
# ============================================================================
save_page("fr", "ui/spinbox.html", "Classe SpinBox", "Boîte de saisie numérique avec boutons d'incrémentation/décrémentation.", "badge-ui", "UI Class", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>La classe <code>UI::SpinBox</code> (dans <code>src/ui/controls/SpinBox.pbi</code>) encapsule le contrôle <code>SpinGadget</code> de PureBasic. Elle combine un champ de saisie textuel et deux boutons fléchés pour ajuster une valeur numérique avec précision.</p>
</div>

<div class='doc-section'>
  <h2 class='section-title'>Constructeurs</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Constructeur</th><th>Description</th></tr>
      <tr><td><code>Init(min.i = 0, max.i = 100)</code></td><td>Initialise la SpinBox avec les bornes minimale et maximale.</td></tr>
      <tr><td><code>Init(x.i, y.i, w.i, h.i, min.i = 0, max.i = 100)</code></td><td>Initialise avec coordonnées, dimensions et bornes absolues.</td></tr>
    </table>
  </div>
</div>

<div class='doc-section'>
  <h2 class='section-title'>Méthodes Spécifiques</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Méthode</th><th>Description</th></tr>
      <tr><td><code>GetValue()</code></td><td>Retourne la valeur entière courante de la SpinBox.</td></tr>
      <tr><td><code>SetValue(val.i)</code></td><td>Définit la valeur de la SpinBox et met à jour son affichage.</td></tr>
      <tr><td><code>GetMinimum() / SetMinimum(min.i)</code></td><td>Lit ou modifie la borne minimale.</td></tr>
      <tr><td><code>GetMaximum() / SetMaximum(max.i)</code></td><td>Lit ou modifie la borne maximale.</td></tr>
      <tr><td><code>OnChange()</code></td><td>Méthode virtuelle appelée lors du changement de valeur.</td></tr>
    </table>
  </div>
</div>
""", "spinbox")

save_page("en", "ui/spinbox.html", "SpinBox Class", "Numerical input box with integrated up/down increment buttons.", "badge-ui", "UI Class", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>The <code>UI::SpinBox</code> class (located in <code>src/ui/controls/SpinBox.pbi</code>) wraps PureBasic's <code>SpinGadget</code>. It combines a direct numerical text entry field with stepper buttons.</p>
</div>

<div class='doc-section'>
  <h2 class='section-title'>Constructors</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Constructor</th><th>Description</th></tr>
      <tr><td><code>Init(min.i = 0, max.i = 100)</code></td><td>Initializes SpinBox with min and max value limits.</td></tr>
      <tr><td><code>Init(x.i, y.i, w.i, h.i, min.i = 0, max.i = 100)</code></td><td>Initializes with absolute bounds and limits.</td></tr>
    </table>
  </div>
</div>

<div class='doc-section'>
  <h2 class='section-title'>Specific Methods</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Method</th><th>Description</th></tr>
      <tr><td><code>GetValue()</code></td><td>Returns current integer value.</td></tr>
      <tr><td><code>SetValue(val.i)</code></td><td>Sets integer value and refreshes text display.</td></tr>
      <tr><td><code>GetMinimum() / SetMinimum(min.i)</code></td><td>Gets or sets minimum boundary.</td></tr>
      <tr><td><code>GetMaximum() / SetMaximum(max.i)</code></td><td>Gets or sets maximum boundary.</td></tr>
      <tr><td><code>OnChange()</code></td><td>Virtual method invoked upon value modification.</td></tr>
    </table>
  </div>
</div>
""", "spinbox")

# ============================================================================
# TABCONTROL (NEW)
# ============================================================================
save_page("fr", "ui/tabcontrol.html", "Classe TabControl", "Conteneur à onglets multiples pour interfaces modulaires.", "badge-ui", "UI Class", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>La classe <code>UI::TabControl</code> (dans <code>src/ui/controls/TabControl.pbi</code>) encapsule le contrôle <code>PanelGadget</code> de PureBasic. Elle permet de structurer les interfaces complexes en sous-panneaux accessibles par onglets avec icônes optionnelles.</p>
</div>

<div class='doc-section'>
  <h2 class='section-title'>Constructeurs</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Constructeur</th><th>Description</th></tr>
      <tr><td><code>Init()</code></td><td>Initialise un conteneur à onglets vide (adapté aux layouts réactifs).</td></tr>
      <tr><td><code>Init(x.i, y.i, w.i, h.i)</code></td><td>Initialise avec coordonnées et dimensions absolues.</td></tr>
    </table>
  </div>
</div>

<div class='doc-section'>
  <h2 class='section-title'>Méthodes Spécifiques</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Méthode</th><th>Description</th></tr>
      <tr><td><code>AddTab(title.s)</code></td><td>Ajoute un nouvel onglet avec son titre.</td></tr>
      <tr><td><code>AddTabWithIcon(title.s, imageID.i)</code></td><td>Ajoute un nouvel onglet avec un titre et une icône image.</td></tr>
      <tr><td><code>InsertTab(index.i, title.s)</code></td><td>Insère un onglet à la position spécifiée.</td></tr>
      <tr><td><code>RemoveTab(index.i)</code></td><td>Supprime l'onglet à l'index donné.</td></tr>
      <tr><td><code>Clear()</code></td><td>Supprime tous les onglets du panneau.</td></tr>
      <tr><td><code>GetTabCount()</code></td><td>Retourne le nombre total d'onglets.</td></tr>
      <tr><td><code>GetTabTitle(index.i)</code></td><td>Retourne le titre de l'onglet à l'index spécifié.</td></tr>
      <tr><td><code>SetTabTitle(index.i, title.s)</code></td><td>Modifie le titre de l'onglet à l'index spécifié.</td></tr>
      <tr><td><code>GetSelectedIndex()</code></td><td>Retourne l'index de l'onglet actif.</td></tr>
      <tr><td><code>SetSelectedIndex(index.i)</code></td><td>Active l'onglet à l'index spécifié.</td></tr>
      <tr><td><code>OnChange()</code></td><td>Méthode virtuelle déclenchée lorsque l'utilisateur bascule d'onglet.</td></tr>
    </table>
  </div>
</div>
""", "tabcontrol")

save_page("en", "ui/tabcontrol.html", "TabControl Class", "Multi-tab panel container for modular page and view navigation.", "badge-ui", "UI Class", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>The <code>UI::TabControl</code> class (located in <code>src/ui/controls/TabControl.pbi</code>) wraps PureBasic's <code>PanelGadget</code>. It organizes complex user interfaces into switchable tabbed panels with optional icons.</p>
</div>

<div class='doc-section'>
  <h2 class='section-title'>Constructors</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Constructor</th><th>Description</th></tr>
      <tr><td><code>Init()</code></td><td>Initializes an empty tab control (responsive layout ready).</td></tr>
      <tr><td><code>Init(x.i, y.i, w.i, h.i)</code></td><td>Initializes with absolute bounds.</td></tr>
    </table>
  </div>
</div>

<div class='doc-section'>
  <h2 class='section-title'>Specific Methods</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Method</th><th>Description</th></tr>
      <tr><td><code>AddTab(title.s)</code></td><td>Appends a new tab with title.</td></tr>
      <tr><td><code>AddTabWithIcon(title.s, imageID.i)</code></td><td>Appends a new tab with title and icon image ID.</td></tr>
      <tr><td><code>InsertTab(index.i, title.s)</code></td><td>Inserts a tab at specified index.</td></tr>
      <tr><td><code>RemoveTab(index.i)</code></td><td>Removes tab at specified index.</td></tr>
      <tr><td><code>Clear()</code></td><td>Removes all tabs.</td></tr>
      <tr><td><code>GetTabCount()</code></td><td>Returns total number of tabs.</td></tr>
      <tr><td><code>GetTabTitle(index.i)</code></td><td>Gets tab title at specified index.</td></tr>
      <tr><td><code>SetTabTitle(index.i, title.s)</code></td><td>Updates tab title at specified index.</td></tr>
      <tr><td><code>GetSelectedIndex()</code></td><td>Returns active tab index.</td></tr>
      <tr><td><code>SetSelectedIndex(index.i)</code></td><td>Switches to tab at specified index.</td></tr>
      <tr><td><code>OnChange()</code></td><td>Virtual method triggered when active tab changes.</td></tr>
    </table>
  </div>
</div>
""", "tabcontrol")

# ============================================================================
# TEXTBOX
# ============================================================================
save_page("fr", "ui/textbox.html", "Classe TextBox", "Champ de saisie textuelle monoligne avec placeholder et mode mot de passe.", "badge-ui", "UI Class", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>La classe <code>UI::TextBox</code> encapsule le <code>StringGadget</code> de PureBasic. Elle prend en charge le DataBinding bidirectionnel MVVM (mise à jour automatique du ViewModel lors de la saisie).</p>
</div>

<div class='doc-section'>
  <h2 class='section-title'>Constructeurs & Méthodes</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Signature</th><th>Description</th></tr>
      <tr><td><code>Init(text.s = "")</code></td><td>Initialise le champ texte avec contenu initial optionnel.</td></tr>
      <tr><td><code>Init(x.i, y.i, w.i, h.i, text.s = "")</code></td><td>Initialise avec position et taille absolues.</td></tr>
      <tr><td><code>GetText() / SetText(text.s)</code></td><td>Lit ou met à jour le texte saisi.</td></tr>
      <tr><td><code>SetReadOnly(ro.b) / IsReadOnly()</code></td><td>Active ou désactive la protection en écriture.</td></tr>
      <tr><td><code>OnChange()</code></td><td>Méthode virtuelle appelée à chaque frappe de touche.</td></tr>
    </table>
  </div>
</div>
""", "textbox")

save_page("en", "ui/textbox.html", "TextBox Class", "Single-line text input field with placeholder and two-way MVVM DataBinding.", "badge-ui", "UI Class", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>The <code>UI::TextBox</code> class wraps PureBasic's <code>StringGadget</code>. It fully supports TwoWay DataBinding (updating ViewModel properties on user keystrokes).</p>
</div>

<div class='doc-section'>
  <h2 class='section-title'>Constructors & Methods</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Signature</th><th>Description</th></tr>
      <tr><td><code>Init(text.s = "")</code></td><td>Initializes text box with optional initial value.</td></tr>
      <tr><td><code>Init(x.i, y.i, w.i, h.i, text.s = "")</code></td><td>Initializes with absolute bounds.</td></tr>
      <tr><td><code>GetText() / SetText(text.s)</code></td><td>Gets or sets input text.</td></tr>
      <tr><td><code>SetReadOnly(ro.b) / IsReadOnly()</code></td><td>Toggles read-only lock.</td></tr>
      <tr><td><code>OnChange()</code></td><td>Virtual method triggered on every text modification.</td></tr>
    </table>
  </div>
</div>
""", "textbox")

# ============================================================================
# TOGGLESWITCH
# ============================================================================
save_page("fr", "ui/toggleswitch.html", "Classe ToggleSwitch", "Interrupteur à bascule moderne dessiné sur Canvas avec animations fluides.", "badge-ui", "Custom UI", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>La classe <code>UI::ToggleSwitch</code> (héritant de <code>UI::CustomGadget</code>) est un composant personnalisé rendu par dessin vectoriel sur un <code>CanvasGadget</code>. Elle offre un design d'interrupteur moderne avec bascule animée.</p>
</div>

<div class='doc-section'>
  <h2 class='section-title'>Méthodes Principales</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Méthode</th><th>Description</th></tr>
      <tr><td><code>Init(state.b = #False)</code></td><td>Initialise l'interrupteur avec son état actif/inactif initial.</td></tr>
      <tr><td><code>IsChecked()</code></td><td>Retourne <code>#True</code> si l'interrupteur est sur ON.</td></tr>
      <tr><td><code>SetChecked(state.b)</code></td><td>Active (ON) ou désactive (OFF) l'interrupteur et redessine le contrôle.</td></tr>
      <tr><td><code>OnToggled(state.b)</code></td><td>Événement virtuel déclenché lors du changement d'état.</td></tr>
    </table>
  </div>
</div>
""", "toggleswitch")

save_page("en", "ui/toggleswitch.html", "ToggleSwitch Class", "Modern custom canvas-rendered animated on/off toggle switch.", "badge-ui", "Custom UI", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>The <code>UI::ToggleSwitch</code> class (inheriting from <code>UI::CustomGadget</code>) is a custom vector-drawn control rendered on a <code>CanvasGadget</code> with smooth visual feedback.</p>
</div>

<div class='doc-section'>
  <h2 class='section-title'>Core Methods</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Method</th><th>Description</th></tr>
      <tr><td><code>Init(state.b = #False)</code></td><td>Initializes toggle switch with initial ON/OFF state.</td></tr>
      <tr><td><code>IsChecked()</code></td><td>Returns <code>#True</code> if active (ON).</td></tr>
      <tr><td><code>SetChecked(state.b)</code></td><td>Sets active state and triggers canvas repaint.</td></tr>
      <tr><td><code>OnToggled(state.b)</code></td><td>Virtual event fired when toggle state changes.</td></tr>
    </table>
  </div>
</div>
""", "toggleswitch")

# ============================================================================
# TREEVIEW (NEW)
# ============================================================================
save_page("fr", "ui/treeview.html", "Classe TreeView", "Arborescence hiérarchique avec sous-niveaux, expansion et sélection.", "badge-ui", "UI Class", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>La classe <code>UI::TreeView</code> (dans <code>src/ui/controls/TreeView.pbi</code>) encapsule le contrôle <code>TreeGadget</code> de PureBasic. Elle permet d'afficher des structures hiérarchiques de données (dossiers, nœuds, catégories) avec gestion des sous-niveaux d'indentation.</p>
</div>

<div class='doc-section'>
  <h2 class='section-title'>Constructeurs</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Constructeur</th><th>Description</th></tr>
      <tr><td><code>Init()</code></td><td>Initialise une arborescence vide (adaptée aux layouts réactifs).</td></tr>
      <tr><td><code>Init(x.i, y.i, w.i, h.i)</code></td><td>Initialise avec coordonnées et dimensions absolues.</td></tr>
    </table>
  </div>
</div>

<div class='doc-section'>
  <h2 class='section-title'>Méthodes Spécifiques</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Méthode</th><th>Description</th></tr>
      <tr><td><code>AddItem(text.s, sublevel.i = 0)</code></td><td>Ajoute un élément à l'arbre au sous-niveau d'indentation spécifié.</td></tr>
      <tr><td><code>InsertItem(index.i, text.s, sublevel.i = 0)</code></td><td>Insère un élément à la position spécifiée avec son sous-niveau.</td></tr>
      <tr><td><code>RemoveItem(index.i)</code></td><td>Supprime l'élément à l'index donné.</td></tr>
      <tr><td><code>Clear()</code></td><td>Vide l'intégralité de l'arborescence.</td></tr>
      <tr><td><code>GetItemCount()</code></td><td>Retourne le nombre total d'éléments dans l'arbre.</td></tr>
      <tr><td><code>GetItemText(index.i)</code></td><td>Retourne le libellé du nœud à l'index donné.</td></tr>
      <tr><td><code>SetItemText(index.i, text.s)</code></td><td>Modifie le libellé du nœud à l'index spécifié.</td></tr>
      <tr><td><code>GetSelectedIndex()</code></td><td>Retourne l'index du nœud actuellement sélectionné (ou -1).</td></tr>
      <tr><td><code>SetSelectedIndex(index.i)</code></td><td>Sélectionne le nœud à l'index spécifié.</td></tr>
      <tr><td><code>ExpandItem(index.i)</code></td><td>Déploie le nœud parent pour afficher ses enfants.</td></tr>
      <tr><td><code>CollapseItem(index.i)</code></td><td>Replie le nœud parent pour masquer ses enfants.</td></tr>
      <tr><td><code>OnChange()</code></td><td>Méthode virtuelle appelée lors d'un changement de sélection dans l'arbre.</td></tr>
    </table>
  </div>
</div>
""", "treeview")

save_page("en", "ui/treeview.html", "TreeView Class", "Hierarchical tree view with expandable nodes, sublevels, and selection.", "badge-ui", "UI Class", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>The <code>UI::TreeView</code> class (located in <code>src/ui/controls/TreeView.pbi</code>) wraps PureBasic's <code>TreeGadget</code>. It provides structured hierarchical data navigation (folders, taxonomies, node trees) with indentation levels and collapse/expand controls.</p>
</div>

<div class='doc-section'>
  <h2 class='section-title'>Constructors</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Constructor</th><th>Description</th></tr>
      <tr><td><code>Init()</code></td><td>Initializes an empty tree view (responsive layout ready).</td></tr>
      <tr><td><code>Init(x.i, y.i, w.i, h.i)</code></td><td>Initializes with absolute bounds.</td></tr>
    </table>
  </div>
</div>

<div class='doc-section'>
  <h2 class='section-title'>Specific Methods</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Method</th><th>Description</th></tr>
      <tr><td><code>AddItem(text.s, sublevel.i = 0)</code></td><td>Appends an item at the specified indentation sublevel.</td></tr>
      <tr><td><code>InsertItem(index.i, text.s, sublevel.i = 0)</code></td><td>Inserts an item at specified index and sublevel.</td></tr>
      <tr><td><code>RemoveItem(index.i)</code></td><td>Removes item at specified index.</td></tr>
      <tr><td><code>Clear()</code></td><td>Clears all nodes in the tree.</td></tr>
      <tr><td><code>GetItemCount()</code></td><td>Returns total number of items in tree.</td></tr>
      <tr><td><code>GetItemText(index.i)</code></td><td>Returns node text at index.</td></tr>
      <tr><td><code>SetItemText(index.i, text.s)</code></td><td>Updates node text at index.</td></tr>
      <tr><td><code>GetSelectedIndex()</code></td><td>Returns selected node index (or -1).</td></tr>
      <tr><td><code>SetSelectedIndex(index.i)</code></td><td>Selects node at specified index.</td></tr>
      <tr><td><code>ExpandItem(index.i)</code></td><td>Expands parent node to show children.</td></tr>
      <tr><td><code>CollapseItem(index.i)</code></td><td>Collapses parent node to hide children.</td></tr>
      <tr><td><code>OnChange()</code></td><td>Virtual method triggered on user selection change.</td></tr>
    </table>
  </div>
</div>
""", "treeview")

# ============================================================================
# CONTAINER & LAYOUTS
# ============================================================================
save_page("fr", "ui/container.html", "Classe Container", "Classe abstraite racine des conteneurs de disposition réactifs (WPF-style).", "badge-wpf", "WPF Layout", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>La classe abstraite <code>UI::Layouts::Container</code> (héritant de <code>UI::Component</code>) est la base de tous les panneaux de disposition automatique réactive. Elle gère la liste dynamique des composants enfants (<code>Children</code>), les marges intérieures (<code>Padding</code>) et le calcul en cascade de la disposition.</p>
</div>

<div class='doc-section'>
  <h2 class='section-title'>Méthodes Principales de Container</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Méthode</th><th>Description</th></tr>
      <tr><td><code>AddChild(*child.UI::Component)</code></td><td>Ajoute un composant enfant au conteneur.</td></tr>
      <tr><td><code>RemoveChild(*child.UI::Component)</code></td><td>Retire un composant du conteneur.</td></tr>
      <tr><td><code>ClearChildren()</code></td><td>Supprime tous les composants enfants.</td></tr>
      <tr><td><code>GetChildCount()</code></td><td>Retourne le nombre d'enfants gérés.</td></tr>
      <tr><td><code>GetChild(index.i)</code></td><td>Retourne le pointeur vers l'enfant à l'index donné.</td></tr>
      <tr><td><code>SetPadding(l.i, t.i, r.i, b.i)</code></td><td>Définit les marges intérieures du conteneur en pixels.</td></tr>
      <tr><td><code>SetPaddingAll(p.i)</code></td><td>Définit une marge intérieure identique sur les 4 côtés.</td></tr>
    </table>
  </div>
</div>
""", "container")

save_page("en", "ui/container.html", "Container Class", "Abstract base class for responsive WPF-style layout panels.", "badge-wpf", "WPF Layout", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>The abstract <code>UI::Layouts::Container</code> class (inheriting from <code>UI::Component</code>) is the foundation of all responsive layout panels. It manages child component collections, internal padding, and recursive arrangement calculations.</p>
</div>

<div class='doc-section'>
  <h2 class='section-title'>Core Container Methods</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Method</th><th>Description</th></tr>
      <tr><td><code>AddChild(*child.UI::Component)</code></td><td>Adds a child component to the layout panel.</td></tr>
      <tr><td><code>RemoveChild(*child.UI::Component)</code></td><td>Removes a child component.</td></tr>
      <tr><td><code>ClearChildren()</code></td><td>Clears all children in panel.</td></tr>
      <tr><td><code>GetChildCount()</code></td><td>Returns number of managed children.</td></tr>
      <tr><td><code>GetChild(index.i)</code></td><td>Returns pointer to child at index.</td></tr>
      <tr><td><code>SetPadding(l.i, t.i, r.i, b.i)</code></td><td>Sets internal panel padding in pixels.</td></tr>
      <tr><td><code>SetPaddingAll(p.i)</code></td><td>Sets uniform padding on all 4 sides.</td></tr>
    </table>
  </div>
</div>
""", "container")

save_page("fr", "ui/stackpanel.html", "Classe StackPanel", "Conteneur de disposition linéaire horizontale ou verticale.", "badge-wpf", "WPF Layout", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>La classe <code>UI::Layouts::StackPanel</code> empile automatiquement ses éléments enfants de manière séquentielle, soit verticalement (par défaut), soit horizontalement (<code>#UI_Orientation_Horizontal</code>), en respectant les marges et alignements de chaque enfant.</p>
</div>

<div class='doc-section'>
  <h2 class='section-title'>Méthodes Spécifiques</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Méthode</th><th>Description</th></tr>
      <tr><td><code>Init(orientation.i = #UI_Orientation_Vertical, spacing.i = 0)</code></td><td>Initialise le panneau avec son orientation et son espacement inter-éléments.</td></tr>
      <tr><td><code>SetOrientation(orientation.i)</code></td><td>Modifie l'orientation (<code>#UI_Orientation_Vertical</code> ou <code>#UI_Orientation_Horizontal</code>).</td></tr>
      <tr><td><code>SetSpacing(spacing.i)</code></td><td>Définit l'espacement automatique en pixels entre chaque enfant.</td></tr>
    </table>
  </div>
</div>
""", "stackpanel")

save_page("en", "ui/stackpanel.html", "StackPanel Class", "Sequential linear horizontal or vertical layout container.", "badge-wpf", "WPF Layout", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>The <code>UI::Layouts::StackPanel</code> class stacks its child elements sequentially either vertically (default) or horizontally (<code>#UI_Orientation_Horizontal</code>), respecting each child's margins and alignments.</p>
</div>

<div class='doc-section'>
  <h2 class='section-title'>Specific Methods</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Method</th><th>Description</th></tr>
      <tr><td><code>Init(orientation.i = #UI_Orientation_Vertical, spacing.i = 0)</code></td><td>Initializes stack panel with orientation and spacing.</td></tr>
      <tr><td><code>SetOrientation(orientation.i)</code></td><td>Changes orientation (<code>#UI_Orientation_Vertical</code> or <code>#UI_Orientation_Horizontal</code>).</td></tr>
      <tr><td><code>SetSpacing(spacing.i)</code></td><td>Sets pixel spacing between consecutive children.</td></tr>
    </table>
  </div>
</div>
""", "stackpanel")

save_page("fr", "ui/dockpanel.html", "Classe DockPanel", "Conteneur d'ancrage en bordure (Haut, Bas, Gauche, Droite, Remplissage).", "badge-wpf", "WPF Layout", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>La classe <code>UI::Layouts::DockPanel</code> ancre ses composants enfants sur les bords de la zone disponible (<code>#UI_Dock_Top</code>, <code>#UI_Dock_Bottom</code>, <code>#UI_Dock_Left</code>, <code>#UI_Dock_Right</code>). Le dernier élément remplit automatiquement l'espace restant central par défaut.</p>
</div>

<div class='doc-section'>
  <h2 class='section-title'>Méthodes Spécifiques</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Méthode</th><th>Description</th></tr>
      <tr><td><code>SetDock(*child.UI::Component, dockPosition.i)</code></td><td>Définit la position d'ancrage pour un composant enfant.</td></tr>
      <tr><td><code>SetLastChildFill(fill.b)</code></td><td>Active ou désactive le remplissage automatique par le dernier enfant.</td></tr>
    </table>
  </div>
</div>
""", "dockpanel")

save_page("en", "ui/dockpanel.html", "DockPanel Class", "Perimeter edge docking container (Top, Bottom, Left, Right, Fill).", "badge-wpf", "WPF Layout", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>The <code>UI::Layouts::DockPanel</code> class docks child components against perimeter edges (<code>#UI_Dock_Top</code>, <code>#UI_Dock_Bottom</code>, <code>#UI_Dock_Left</code>, <code>#UI_Dock_Right</code>). The last child automatically fills remaining center space by default.</p>
</div>

<div class='doc-section'>
  <h2 class='section-title'>Specific Methods</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Method</th><th>Description</th></tr>
      <tr><td><code>SetDock(*child.UI::Component, dockPosition.i)</code></td><td>Sets docking edge position for specified child.</td></tr>
      <tr><td><code>SetLastChildFill(fill.b)</code></td><td>Toggles whether the last added child fills remaining center area.</td></tr>
    </table>
  </div>
</div>
""", "dockpanel")

save_page("fr", "ui/grid.html", "Classe Grid", "Grille de disposition matricielle en lignes et colonnes proportionnelles (*, px, auto).", "badge-wpf", "WPF Layout", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>La classe <code>UI::Layouts::Grid</code> fournit un système de grille matricielle puissant inspiré de WPF/XAML, permettant de positionner des composants dans des cellules définies par des lignes et colonnes avec dimensions fixes (pixels) ou proportionnelles (étoiles <code>*</code>).</p>
</div>

<div class='doc-section'>
  <h2 class='section-title'>Méthodes Spécifiques</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Méthode</th><th>Description</th></tr>
      <tr><td><code>AddRow(height.i, unitType.i = #UI_Unit_Star)</code></td><td>Ajoute une définition de ligne (hauteur en pixels ou ratio d'étoiles).</td></tr>
      <tr><td><code>AddColumn(width.i, unitType.i = #UI_Unit_Star)</code></td><td>Ajoute une définition de colonne (largeur en pixels ou ratio d'étoiles).</td></tr>
      <tr><td><code>SetCell(*child.UI::Component, row.i, col.i, rowSpan.i = 1, colSpan.i = 1)</code></td><td>Place un composant dans une cellule avec fusion de lignes/colonnes optionnelle.</td></tr>
    </table>
  </div>
</div>
""", "grid")

save_page("en", "ui/grid.html", "Grid Class", "Matrix grid layout panel with proportional star (*), pixel, and auto sizing.", "badge-wpf", "WPF Layout", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>The <code>UI::Layouts::Grid</code> class delivers a flexible matrix grid layout system inspired by WPF/XAML, allowing precise child placement across rows and columns with fixed pixel or weighted star (<code>*</code>) sizing.</p>
</div>

<div class='doc-section'>
  <h2 class='section-title'>Specific Methods</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Method</th><th>Description</th></tr>
      <tr><td><code>AddRow(height.i, unitType.i = #UI_Unit_Star)</code></td><td>Adds a row definition (pixel height or weighted star ratio).</td></tr>
      <tr><td><code>AddColumn(width.i, unitType.i = #UI_Unit_Star)</code></td><td>Adds a column definition (pixel width or weighted star ratio).</td></tr>
      <tr><td><code>SetCell(*child.UI::Component, row.i, col.i, rowSpan.i = 1, colSpan.i = 1)</code></td><td>Assigns a component to a cell with optional row/column spanning.</td></tr>
    </table>
  </div>
</div>
""", "grid")

# ============================================================================
# MVVM (NEW DEDICATED SECTION)
# ============================================================================
save_page("fr", "ui/mvvm.html", "Architecture MVVM & DataBinding", "Pattern Model-View-ViewModel complet avec propriétés observables et liaison bidirectionnelle.", "badge-wpf", "MVVM Core", """
<div class='doc-section'>
  <h2 class='section-title'>Présentation de l'Architecture MVVM</h2>
  <p>PureBasic OOP intègre un sous-système <strong>MVVM (Model-View-ViewModel)</strong> complet inspiré de WPF et .NET MAUI. Il permet de séparer totalement la logique métier (ViewModel) de l'interface utilisateur (View) grâce à un moteur de <strong>DataBinding réactif</strong>.</p>
  <ul>
    <li><strong>Model</strong> : Données et logique métier pure de l'application.</li>
    <li><strong>ViewModel</strong> : État réactif exposé sous forme de propriétés typées (<code>StringProperty</code>, <code>IntProperty</code>...) héritant de <code>ViewModelBase</code>.</li>
    <li><strong>View</strong> : Définition déclarative de l'interface (en XML ou en code POO) avec liaisons <code>{Binding NomPropriete, Mode=TwoWay}</code>.</li>
    <li><strong>BindingEngine</strong> : Synchronisation automatique bidirectionnelle entre les contrôles graphiques et le ViewModel.</li>
  </ul>
</div>

<div class='doc-section'>
  <h2 class='section-title'>Classes de Propriétés Typées</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Classe</th><th>Type PureBasic</th><th>Méthodes Clés</th></tr>
      <tr><td><code>StringProperty</code></td><td><code>.s</code> (Chaîne)</td><td><code>GetValue()</code>, <code>SetValue(val.s)</code>, <code>GetStringValue()</code></td></tr>
      <tr><td><code>IntProperty</code></td><td><code>.i</code> (Entier)</td><td><code>GetValue()</code>, <code>SetValue(val.i)</code>, <code>GetStringValue()</code> (avec conversion automatique en texte)</td></tr>
      <tr><td><code>BoolProperty</code></td><td><code>.b</code> (Booléen)</td><td><code>GetValue()</code>, <code>SetValue(val.b)</code>, <code>GetStringValue()</code></td></tr>
      <tr><td><code>DoubleProperty</code></td><td><code>.d</code> (Flottant)</td><td><code>GetValue()</code>, <code>SetValue(val.d)</code>, <code>GetStringValue()</code></td></tr>
    </table>
  </div>
</div>

<div class='doc-section'>
  <h2 class='section-title'>Exemple Complet en 4 Fichiers</h2>
  
  <div class='code-container'>
    <div class='code-header'><span class='code-title'>1. Constantes Partagées (AppConstants.pbi)</span><span class='code-badge'>PBI</span></div>
    <pre><code>#PROP_CLICK_MESSAGE = "ClickMessage"
#PROP_CLICK_COUNT   = "ClickCount"
#CMD_INCREMENT      = "IncrementCommand"</code></pre>
  </div>

  <div class='code-container'>
    <div class='code-header'><span class='code-title'>2. Le ViewModel (MainViewModel.pbo)</span><span class='code-badge'>PBO</span></div>
    <pre><code>Class MainViewModel Extends MVVM::ViewModelBase {
  Public *ClickMessage.MVVM::StringProperty
  Public *ClickCount.MVVM::IntProperty
  
  Public Method Init() {
    Super::Init()
    This\\*ClickMessage = This\\RegisterString(#PROP_CLICK_MESSAGE, "Bienvenue !")
    This\\*ClickCount   = This\\RegisterInt(#PROP_CLICK_COUNT, 0)
  }
  
  Public Method OnCommand(cmdName.s) {
    If cmdName = #CMD_INCREMENT
      Protected count.i = This\\*ClickCount\\GetValue() + 1
      This\\*ClickCount\\SetValue(count)
      This\\*ClickMessage\\SetValue("Clic n° " + Str(count) + " enregistré !")
    EndIf
  }
}</code></pre>
  </div>

  <div class='code-container'>
    <div class='code-header'><span class='code-title'>3. La Vue Déclarative (MainView.xml)</span><span class='code-badge'>XML</span></div>
    <pre><code>&lt;Window Title="Démo MVVM" Width="420" Height="220"&gt;
  &lt;StackPanel Margin="20" Spacing="12"&gt;
    &lt;Label Text="{Binding ClickMessage}" /&gt;
    &lt;Label Text="{Binding ClickCount}" /&gt;
    &lt;Button Text="Incrémenter" Command="IncrementCommand" /&gt;
  &lt;/StackPanel&gt;
&lt;/Window&gt;</code></pre>
  </div>

  <div class='code-container'>
    <div class='code-header'><span class='code-title'>4. Le Point d'Entrée (main.pb)</span><span class='code-badge'>PB</span></div>
    <pre><code>IncludeFile "src/ui/UI.pbi"
IncludeFile "AppConstants.pbi"
IncludeFile "MainViewModel.pbo"

Protected *app.UI::Application = NewObject(UI::Application)
Protected *vm.MainViewModel    = NewObject(MainViewModel)
Protected *win.UI::Window      = UI::XMLLoader::LoadAndBindXML(xmlString$, *vm)

*win\\Show()
*app\\Run()</code></pre>
  </div>
</div>
""", "mvvm")

save_page("en", "ui/mvvm.html", "MVVM Architecture & DataBinding", "Complete Model-View-ViewModel architecture with observable properties and two-way binding.", "badge-wpf", "MVVM Core", """
<div class='doc-section'>
  <h2 class='section-title'>MVVM Architecture Overview</h2>
  <p>PureBasic OOP incorporates a comprehensive <strong>MVVM (Model-View-ViewModel)</strong> subsystem inspired by modern WPF and .NET MAUI standards. It decouples core business logic from graphical user interfaces using reactive <strong>DataBinding</strong>.</p>
  <ul>
    <li><strong>Model</strong> : Application state, domain rules, and data structures.</li>
    <li><strong>ViewModel</strong> : Exposes typed observable properties (<code>StringProperty</code>, <code>IntProperty</code>...) inheriting from <code>ViewModelBase</code>.</li>
    <li><strong>View</strong> : Declarative layout definition (via XML or OOP code) with <code>{Binding PropertyName, Mode=TwoWay}</code> markup expressions.</li>
    <li><strong>BindingEngine</strong> : Automatically synchronizes UI controls and ViewModel properties bidirectionally.</li>
  </ul>
</div>

<div class='doc-section'>
  <h2 class='section-title'>Typed Observable Property Classes</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Class</th><th>PureBasic Type</th><th>Key Methods</th></tr>
      <tr><td><code>StringProperty</code></td><td><code>.s</code> (String)</td><td><code>GetValue()</code>, <code>SetValue(val.s)</code>, <code>GetStringValue()</code></td></tr>
      <tr><td><code>IntProperty</code></td><td><code>.i</code> (Integer)</td><td><code>GetValue()</code>, <code>SetValue(val.i)</code>, <code>GetStringValue()</code> (with automated formatting)</td></tr>
      <tr><td><code>BoolProperty</code></td><td><code>.b</code> (Boolean)</td><td><code>GetValue()</code>, <code>SetValue(val.b)</code>, <code>GetStringValue()</code></td></tr>
      <tr><td><code>DoubleProperty</code></td><td><code>.d</code> (Float)</td><td><code>GetValue()</code>, <code>SetValue(val.d)</code>, <code>GetStringValue()</code></td></tr>
    </table>
  </div>
</div>

<div class='doc-section'>
  <h2 class='section-title'>Complete 4-File Quick Start Tutorial</h2>
  
  <div class='code-container'>
    <div class='code-header'><span class='code-title'>1. Shared Constants (AppConstants.pbi)</span><span class='code-badge'>PBI</span></div>
    <pre><code>#PROP_CLICK_MESSAGE = "ClickMessage"
#PROP_CLICK_COUNT   = "ClickCount"
#CMD_INCREMENT      = "IncrementCommand"</code></pre>
  </div>

  <div class='code-container'>
    <div class='code-header'><span class='code-title'>2. The ViewModel (MainViewModel.pbo)</span><span class='code-badge'>PBO</span></div>
    <pre><code>Class MainViewModel Extends MVVM::ViewModelBase {
  Public *ClickMessage.MVVM::StringProperty
  Public *ClickCount.MVVM::IntProperty
  
  Public Method Init() {
    Super::Init()
    This\\*ClickMessage = This\\RegisterString(#PROP_CLICK_MESSAGE, "Welcome!")
    This\\*ClickCount   = This\\RegisterInt(#PROP_CLICK_COUNT, 0)
  }
  
  Public Method OnCommand(cmdName.s) {
    If cmdName = #CMD_INCREMENT
      Protected count.i = This\\*ClickCount\\GetValue() + 1
      This\\*ClickCount\\SetValue(count)
      This\\*ClickMessage\\SetValue("Click #" + Str(count) + " recorded!")
    EndIf
  }
}</code></pre>
  </div>

  <div class='code-container'>
    <div class='code-header'><span class='code-title'>3. The Declarative View (MainView.xml)</span><span class='code-badge'>XML</span></div>
    <pre><code>&lt;Window Title="MVVM Demo" Width="420" Height="220"&gt;
  &lt;StackPanel Margin="20" Spacing="12"&gt;
    &lt;Label Text="{Binding ClickMessage}" /&gt;
    &lt;Label Text="{Binding ClickCount}" /&gt;
    &lt;Button Text="Increment" Command="IncrementCommand" /&gt;
  &lt;/StackPanel&gt;
&lt;/Window&gt;</code></pre>
  </div>

  <div class='code-container'>
    <div class='code-header'><span class='code-title'>4. Main Entry Point (main.pb)</span><span class='code-badge'>PB</span></div>
    <pre><code>IncludeFile "src/ui/UI.pbi"
IncludeFile "AppConstants.pbi"
IncludeFile "MainViewModel.pbo"

Protected *app.UI::Application = NewObject(UI::Application)
Protected *vm.MainViewModel    = NewObject(MainViewModel)
Protected *win.UI::Window      = UI::XMLLoader::LoadAndBindXML(xmlString$, *vm)

*win\\Show()
*app\\Run()</code></pre>
  </div>
</div>
""", "mvvm")

# ============================================================================
# WINDOW & APPLICATION
# ============================================================================
save_page("fr", "ui/window.html", "Classe Window", "Encapsulation d'une fenêtre principale ou de dialogue avec gestion du cycle de vie.", "badge-core", "Core UI", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>La classe <code>UI::Window</code> encapsule les fenêtres PureBasic (<code>OpenWindow</code>). Elle gère le redimensionnement automatique des layouts enfants, les barres d'outils, menus et la fermeture propre.</p>
</div>

<div class='doc-section'>
  <h2 class='section-title'>Méthodes Spécifiques</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Méthode</th><th>Description</th></tr>
      <tr><td><code>Init(title.s, w.i = 800, h.i = 600, flags.i = #PB_Window_SystemMenu | #PB_Window_SizeGadget)</code></td><td>Crée la fenêtre.</td></tr>
      <tr><td><code>SetContent(*rootComponent.UI::Component)</code></td><td>Assigne le panneau de layout racine qui sera redimensionné avec la fenêtre.</td></tr>
      <tr><td><code>Show() / Hide()</code></td><td>Affiche ou masque la fenêtre.</td></tr>
      <tr><td><code>Close()</code></td><td>Ferme et détruit la fenêtre.</td></tr>
    </table>
  </div>
</div>
""", "window")

save_page("en", "ui/window.html", "Window Class", "Main and dialogue window encapsulation with layout auto-arrangement.", "badge-core", "Core UI", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>The <code>UI::Window</code> class encapsulates PureBasic OS windows (<code>OpenWindow</code>). It handles automated responsive layout resizing, menus, toolbars, and clean event disposal.</p>
</div>

<div class='doc-section'>
  <h2 class='section-title'>Specific Methods</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Method</th><th>Description</th></tr>
      <tr><td><code>Init(title.s, w.i = 800, h.i = 600, flags.i = #PB_Window_SystemMenu | #PB_Window_SizeGadget)</code></td><td>Creates window.</td></tr>
      <tr><td><code>SetContent(*rootComponent.UI::Component)</code></td><td>Sets root layout container which auto-resizes with window bounds.</td></tr>
      <tr><td><code>Show() / Hide()</code></td><td>Shows or hides window.</td></tr>
      <tr><td><code>Close()</code></td><td>Closes and disposes window.</td></tr>
    </table>
  </div>
</div>
""", "window")

save_page("fr", "ui/application.html", "Classe Application", "Boucle d'événements globale, routage et gestionnaire d'application.", "badge-core", "Core UI", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>La classe <code>UI::Application</code> est le singleton applicatif gérant la boucle d'événements centrale (<code>WaitWindowEvent</code>) et le routage automatique vers les gadgets et fenêtres POO.</p>
</div>

<div class='doc-section'>
  <h2 class='section-title'>Méthodes Spécifiques</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Méthode</th><th>Description</th></tr>
      <tr><td><code>Run()</code></td><td>Démarre la boucle d'événements jusqu'à la fermeture de toutes les fenêtres.</td></tr>
      <tr><td><code>Exit()</code></td><td>Termine proprement l'exécution de l'application.</td></tr>
    </table>
  </div>
</div>
""", "application")

save_page("en", "ui/application.html", "Application Class", "Global application loop, dispatching, and lifecycle manager.", "badge-core", "Core UI", """
<div class='doc-section'>
  <h2 class='section-title'>Description</h2>
  <p>The <code>UI::Application</code> class acts as the core application engine managing the master event loop (<code>WaitWindowEvent</code>) and automated OOP event dispatching.</p>
</div>

<div class='doc-section'>
  <h2 class='section-title'>Specific Methods</h2>
  <div class='table-wrapper'>
    <table>
      <tr><th>Method</th><th>Description</th></tr>
      <tr><td><code>Run()</code></td><td>Runs the main event loop until all windows are closed.</td></tr>
      <tr><td><code>Exit()</code></td><td>Terminates application execution cleanly.</td></tr>
    </table>
  </div>
</div>
""", "application")

# ============================================================================
# KEYWORDS (RETAINED & POLISHED)
# ============================================================================
save_page("fr", "keywords/class.html", "Mots-clés Class & Abstract", "Déclaration de classes concrètes et abstraites en PureBasic OOP.", "badge-kw", "KW", """
<div class='doc-section'>
  <h2 class='section-title'>Syntaxe</h2>
  <div class='code-container'>
    <div class='code-header'><span class='code-title'>Déclaration de classe (.pbo)</span><span class='code-badge'>PBO</span></div>
    <pre><code><span class='kw'>Class</span> NomDeClasse [<span class='kw'>Extends</span> ClasseParente] {
  <span class='kw'>Public</span> [membres / méthodes]
  <span class='kw'>Protected</span> [membres / méthodes]
  <span class='kw'>Private</span> [membres / méthodes]
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

print("All HTML documentation files with inheritance hierarchy & MVVM generated successfully!")
