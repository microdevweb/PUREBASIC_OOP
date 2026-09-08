# -*- coding: utf-8 -*-
"""
Script to update scripts/generate_all_html_docs.py with Alpha 1.3 features:
- WPF Declarative Styles & Resource Dictionaries (ui/styles.html)
- 60 FPS Micro-Animations, Triggers & Mathematical Easing (ui/animation.html)
- Declarative XML Views & XMLLoader (ui/xmlloader.html)
- Vector Canvas Controls: CanvasControl, CanvasButton, CanvasTextBox, CanvasText, CanvasTree
- Alpha 1.3 branding and full UTF-8 meta tags
- Flawless French accentuation and English translations
"""

import os

GEN_SCRIPT = r"c:\PB\PB_PROJECT\PB_OOP_WORKSPACE\PUREBASIC_OOP_WORKSPACE\scripts\generate_all_html_docs.py"

with open(GEN_SCRIPT, "r", encoding="utf-8") as f:
    code = f.read()

# 1. Update NAV_ITEMS_FR
nav_fr_old = '''    ("Socle UI & Hiérarchie", [
        ("component", "Component (Base UI)", "ui/component.html", "BASE"),
        ("gadget", "Gadget (Natif)", "ui/gadget.html", "BASE"),
        ("customgadget", "CustomGadget (Canvas)", "ui/customgadget.html", "BASE"),
        ("container", "Container (Layout Base)", "ui/container.html", "WPF")
    ]),'''

nav_fr_new = '''    ("Socle UI & Hiérarchie", [
        ("component", "Component (Base UI)", "ui/component.html", "BASE"),
        ("gadget", "Gadget (Natif)", "ui/gadget.html", "BASE"),
        ("customgadget", "CustomGadget (Canvas)", "ui/customgadget.html", "BASE"),
        ("canvascontrol", "CanvasControl (Vecteur)", "ui/canvascontrol.html", "CANVAS"),
        ("container", "Container (Layout Base)", "ui/container.html", "WPF")
    ]),
    ("Contrôles Vectoriels (Canvas)", [
        ("canvasbutton", "CanvasButton", "ui/canvasbutton.html", "CANVAS"),
        ("canvastextbox", "CanvasTextBox", "ui/canvastextbox.html", "CANVAS"),
        ("canvastext", "CanvasText", "ui/canvastext.html", "CANVAS"),
        ("canvastree", "CanvasTree", "ui/canvastree.html", "CANVAS")
    ]),
    ("Styles & Animations WPF", [
        ("styles", "Styles & Dictionnaires", "ui/styles.html", "WPF"),
        ("animation", "Animations & Triggers", "ui/animation.html", "60FPS"),
        ("xmlloader", "Vues Déclaratives XML", "ui/xmlloader.html", "XML")
    ]),'''

code = code.replace(nav_fr_old, nav_fr_new)

# 2. Update NAV_ITEMS_EN
nav_en_old = '''    ("UI Foundation & Hierarchy", [
        ("component", "Component (Base UI)", "ui/component.html", "BASE"),
        ("gadget", "Gadget (Native Base)", "ui/gadget.html", "BASE"),
        ("customgadget", "CustomGadget (Canvas Base)", "ui/customgadget.html", "BASE"),
        ("container", "Container (Layout Base)", "ui/container.html", "WPF")
    ]),'''

nav_en_new = '''    ("UI Foundation & Hierarchy", [
        ("component", "Component (Base UI)", "ui/component.html", "BASE"),
        ("gadget", "Gadget (Native Base)", "ui/gadget.html", "BASE"),
        ("customgadget", "CustomGadget (Canvas Base)", "ui/customgadget.html", "BASE"),
        ("canvascontrol", "CanvasControl (Vector Base)", "ui/canvascontrol.html", "CANVAS"),
        ("container", "Container (Layout Base)", "ui/container.html", "WPF")
    ]),
    ("Vector Controls (Canvas)", [
        ("canvasbutton", "CanvasButton", "ui/canvasbutton.html", "CANVAS"),
        ("canvastextbox", "CanvasTextBox", "ui/canvastextbox.html", "CANVAS"),
        ("canvastext", "CanvasText", "ui/canvastext.html", "CANVAS"),
        ("canvastree", "CanvasTree", "ui/canvastree.html", "CANVAS")
    ]),
    ("WPF Declarative Styles & Animations", [
        ("styles", "Styles & Dictionaries", "ui/styles.html", "WPF"),
        ("animation", "Animations & Triggers", "ui/animation.html", "60FPS"),
        ("xmlloader", "XML Declarative Views", "ui/xmlloader.html", "XML")
    ]),'''

code = code.replace(nav_en_old, nav_en_new)

# 3. Update HIERARCHY_DATA to include CanvasControl and vector controls
hierarchy_insert = '''    "canvascontrol": {
        "ancestors": [("Core::Object", "../keywords/class.html"), ("UI::Component", "component.html"), ("UI::Gadget", "gadget.html"), ("UI::CanvasControl", "canvascontrol.html")],
        "derived": [
            ("UI::CanvasButton", "canvasbutton.html"),
            ("UI::CanvasTextBox", "canvastextbox.html"),
            ("UI::CanvasText", "canvastext.html"),
            ("UI::CanvasTree", "canvastree.html")
        ],
        "inherited": [
            ("UI::Gadget", "gadget.html", ["GetID()", "GetHandle()", "FreeGadget()", "SetToolTip()", "SetFocus()"]),
            ("UI::Component", "component.html", ["SetPosition(x, y)", "SetSize(w, h)", "SetMargin(l, t, r, b)", "SetHorizontalAlignment(align)", "SetVerticalAlignment(align)", "SetVisible(v)", "SetEnabled(e)", "Arrange(rx, ry, rw, rh)"])
        ]
    },
    "canvasbutton": {
        "ancestors": [("Core::Object", "../keywords/class.html"), ("UI::Component", "component.html"), ("UI::Gadget", "gadget.html"), ("UI::CanvasControl", "canvascontrol.html"), ("UI::CanvasButton", "canvasbutton.html")],
        "derived": [],
        "inherited": [
            ("UI::CanvasControl", "canvascontrol.html", ["ApplyStyle(*style)", "SetCornerRadius(r)", "SetBorderColor(c)", "SetScale(s)", "SetVisualState(s)"]),
            ("UI::Gadget", "gadget.html", ["GetID()", "GetHandle()", "FreeGadget()"]),
            ("UI::Component", "component.html", ["SetPosition()", "SetSize()", "SetMargin()", "Arrange()"])
        ]
    },
    "canvastextbox": {
        "ancestors": [("Core::Object", "../keywords/class.html"), ("UI::Component", "component.html"), ("UI::Gadget", "gadget.html"), ("UI::CanvasControl", "canvascontrol.html"), ("UI::CanvasTextBox", "canvastextbox.html")],
        "derived": [],
        "inherited": [
            ("UI::CanvasControl", "canvascontrol.html", ["ApplyStyle(*style)", "SetCornerRadius(r)", "SetBorderColor(c)", "SetScale(s)"]),
            ("UI::Gadget", "gadget.html", ["GetID()", "GetHandle()", "FreeGadget()"]),
            ("UI::Component", "component.html", ["SetPosition()", "SetSize()", "SetMargin()", "Arrange()"])
        ]
    },
    "canvastext": {
        "ancestors": [("Core::Object", "../keywords/class.html"), ("UI::Component", "component.html"), ("UI::Gadget", "gadget.html"), ("UI::CanvasControl", "canvascontrol.html"), ("UI::CanvasText", "canvastext.html")],
        "derived": [],
        "inherited": [
            ("UI::CanvasControl", "canvascontrol.html", ["ApplyStyle(*style)", "SetScale(s)"]),
            ("UI::Gadget", "gadget.html", ["GetID()", "GetHandle()", "FreeGadget()"]),
            ("UI::Component", "component.html", ["SetPosition()", "SetSize()", "SetMargin()", "Arrange()"])
        ]
    },
    "canvastree": {
        "ancestors": [("Core::Object", "../keywords/class.html"), ("UI::Component", "component.html"), ("UI::Gadget", "gadget.html"), ("UI::CanvasControl", "canvascontrol.html"), ("UI::CanvasTree", "canvastree.html")],
        "derived": [],
        "inherited": [
            ("UI::CanvasControl", "canvascontrol.html", ["ApplyStyle(*style)", "SetCornerRadius(r)"]),
            ("UI::Gadget", "gadget.html", ["GetID()", "GetHandle()", "FreeGadget()"]),
            ("UI::Component", "component.html", ["SetPosition()", "SetSize()", "SetMargin()", "Arrange()"])
        ]
    },
    "styles": {
        "ancestors": [("Core::Object", "../keywords/class.html"), ("UI::Style", "styles.html")],
        "derived": [],
        "inherited": []
    },
    "animation": {
        "ancestors": [("Core::Object", "../keywords/class.html"), ("UI::AnimationEngine", "animation.html")],
        "derived": [],
        "inherited": []
    },
    "xmlloader": {
        "ancestors": [("Core::Object", "../keywords/class.html"), ("UI::XMLLoader", "xmlloader.html")],
        "derived": [],
        "inherited": []
    },
'''

code = code.replace('"component": {', hierarchy_insert + '    "component": {')

# 4. In render_page, add double meta tags for charset
meta_old = """<head>
  <meta charset='UTF-8'>
  <meta name='viewport' content='width=device-width, initial-scale=1.0'>"""

meta_new = """<head>
  <meta charset='UTF-8'>
  <meta http-equiv='Content-Type' content='text/html; charset=UTF-8'>
  <meta name='viewport' content='width=device-width, initial-scale=1.0'>"""

code = code.replace(meta_old, meta_new)

# Update brand subtitle to Alpha 1.3
code = code.replace("v1.2", "Alpha 1.3")
code = code.replace("Alpha 1.2", "Alpha 1.3")

with open(GEN_SCRIPT, "w", encoding="utf-8") as f:
    f.write(code)

print("Updated generate_all_html_docs.py structure!")
