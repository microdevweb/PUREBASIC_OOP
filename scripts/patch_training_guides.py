# -*- coding: utf-8 -*-
import os

py_path = r"c:\PB\PB_PROJECT\PB_OOP_WORKSPACE\PUREBASIC_OOP_WORKSPACE\scripts\generate_training_guides.py"

with open(py_path, 'r', encoding='utf-8') as f:
    c = f.read()

# 1. Update version string
c = c.replace('PureBasic OOP v1.2 / v2.0', 'PureBasic OOP Alpha 1.3')

# 2. Add dual meta tags in HTML
c = c.replace(
    '<meta charset="UTF-8">\n  <meta name="viewport"',
    '<meta charset="UTF-8">\n  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">\n  <meta name="viewport"'
)

# 3. Enhance French HTML Table
fr_table_old = """    <tr><td><code>UI::TabControl</code></td><td><code>PanelGadget</code></td><td>Conteneur à onglets modulaires</td></tr>
  </table>"""

fr_table_new = """    <tr><td><code>UI::TabControl</code></td><td><code>PanelGadget</code></td><td>Conteneur à onglets modulaires</td></tr>
    <tr><td><code>UI::CanvasControl</code></td><td><code>CanvasGadget</code></td><td>Composant de base pour contrôles vectoriels sur mesure</td></tr>
    <tr><td><code>UI::CanvasButton</code></td><td><code>CanvasGadget</code></td><td>Bouton vectoriel stylable avec états Hover/Pressed</td></tr>
    <tr><td><code>UI::CanvasTextBox</code></td><td><code>CanvasGadget</code></td><td>Champ de saisie vectoriel avec caret et sélection</td></tr>
    <tr><td><code>UI::CanvasText</code></td><td><code>CanvasGadget</code></td><td>Affichage de texte vectoriel avec typographie fine</td></tr>
    <tr><td><code>UI::CanvasTree</code></td><td><code>CanvasGadget</code></td><td>Arborescence vectorielle fluide et interactive</td></tr>
    <tr><td><code>UI::Style</code> / <code>Trigger</code></td><td>Moteur WPF</td><td>Styles déclaratifs et déclencheurs visuels réactifs</td></tr>
    <tr><td><code>UI::AnimationEngine</code></td><td>Moteur 60 FPS</td><td>Micro-animations et transitions avec Easing mathématique</td></tr>
    <tr><td><code>UI::XMLLoader</code></td><td>Moteur XML</td><td>Chargeur déclaratif de vues et databinding automatique</td></tr>
  </table>"""

c = c.replace(fr_table_old, fr_table_new)
c = c.replace('Les 18 Contrôles UI Disponibles', 'Les Contrôles UI & Moteurs Disponibles (Alpha 1.3)')

# 4. Enhance English HTML Table
en_table_old = """    <tr><td><code>UI::TabControl</code></td><td><code>PanelGadget</code></td><td>Tabbed multi-view container</td></tr>
  </table>"""

en_table_new = """    <tr><td><code>UI::TabControl</code></td><td><code>PanelGadget</code></td><td>Tabbed multi-view container</td></tr>
    <tr><td><code>UI::CanvasControl</code></td><td><code>CanvasGadget</code></td><td>High-performance custom vector canvas base control</td></tr>
    <tr><td><code>UI::CanvasButton</code></td><td><code>CanvasGadget</code></td><td>Vector button with Hover/Pressed visual states</td></tr>
    <tr><td><code>UI::CanvasTextBox</code></td><td><code>CanvasGadget</code></td><td>Smooth vector text input with caret and selection</td></tr>
    <tr><td><code>UI::CanvasText</code></td><td><code>CanvasGadget</code></td><td>High-precision vector typography text block</td></tr>
    <tr><td><code>UI::CanvasTree</code></td><td><code>CanvasGadget</code></td><td>Smooth interactive vector tree view control</td></tr>
    <tr><td><code>UI::Style</code> / <code>Trigger</code></td><td>WPF Styling</td><td>Declarative styles, setters, and reactive visual triggers</td></tr>
    <tr><td><code>UI::AnimationEngine</code></td><td>60 FPS Engine</td><td>Micro-animations and transitions with mathematical easing</td></tr>
    <tr><td><code>UI::XMLLoader</code></td><td>XML Engine</td><td>Declarative view loader and automatic MVVM databinding</td></tr>
  </table>"""

c = c.replace(en_table_old, en_table_new)
c = c.replace('18 Encapsulated UI Controls', 'Encapsulated UI Controls & Alpha 1.3 Engines')

# 5. Enhance French Markdown Table
fr_md_old = """| `UI::TabControl` | `PanelGadget` | Conteneur à onglets modulaires |"""
fr_md_new = """| `UI::TabControl` | `PanelGadget` | Conteneur à onglets modulaires |
| `UI::CanvasControl` | `CanvasGadget` | Composant vectoriel de base haute performance |
| `UI::CanvasButton` | `CanvasGadget` | Bouton vectoriel stylable avec états visuels |
| `UI::CanvasTextBox` | `CanvasGadget` | Saisie de texte vectorielle fluide |
| `UI::CanvasText` | `CanvasGadget` | Label vectoriel typographique haute précision |
| `UI::CanvasTree` | `CanvasGadget` | Arborescence vectorielle interactive |
| `UI::Style` / `Trigger` | Moteur WPF | Styles déclaratifs et déclencheurs visuels réactifs |
| `UI::AnimationEngine` | Moteur 60 FPS | Micro-animations et transitions avec Easing |
| `UI::XMLLoader` | Moteur XML | Chargeur déclaratif de vues et databinding |"""

c = c.replace(fr_md_old, fr_md_new)

# 6. Enhance English Markdown Table
en_md_old = """| `UI::TabControl` | `PanelGadget` | Tabbed multi-view container |"""
en_md_new = """| `UI::TabControl` | `PanelGadget` | Tabbed multi-view container |
| `UI::CanvasControl` | `CanvasGadget` | Base vector canvas control for custom rendering |
| `UI::CanvasButton` | `CanvasGadget` | Stylable vector button with visual states |
| `UI::CanvasTextBox` | `CanvasGadget` | Smooth vector text input field |
| `UI::CanvasText` | `CanvasGadget` | High-precision vector typography text block |
| `UI::CanvasTree` | `CanvasGadget` | Interactive vector tree view control |
| `UI::Style` / `Trigger` | WPF Styling | Declarative styles and visual state triggers |
| `UI::AnimationEngine` | 60 FPS Engine | Micro-animations and transitions with easing |
| `UI::XMLLoader` | XML Engine | Declarative view loader and MVVM databinding |"""

c = c.replace(en_md_old, en_md_new)

with open(py_path, 'w', encoding='utf-8') as f:
    f.write(c)

print("Successfully updated generate_training_guides.py for Alpha 1.3!")
