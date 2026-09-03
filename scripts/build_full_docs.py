# ============================================================================
# PureBasic OOP Documentation Builder
# Author: MicrodevWeb
# ============================================================================

import os
import subprocess

pb_content = r'''; ============================================================================
; PureBasic OOP Documentation Generator
; Generates complete, modern HTML documentation (FR & EN) with syntax highlighting
; Fixed accent and UTF-8 encoding support with BOM and HTML entities
; Author:      MicrodevWeb
; ============================================================================

EnableExplicit

Global BaseDocDir.s = "c:\PB\PB_PROJECT\PB_OOP_WORKSPACE\PUREBASIC_OOP_WORKSPACE\doc\html\"

Procedure.s Iif(cond.i, trueVal.s, falseVal.s)
  If cond
    ProcedureReturn trueVal
  Else
    ProcedureReturn falseVal
  EndIf
EndProcedure

Procedure SaveHTML(filePath.s, content.s)
  Protected file = CreateFile(#PB_Any, filePath)
  If file
    WriteStringFormat(file, #PB_UTF8)
    WriteString(file, content, #PB_UTF8)
    CloseFile(file)
    PrintN("[DOC-GEN] Generated: " + filePath)
  Else
    PrintN("[DOC-GEN] ERROR creating: " + filePath)
  EndIf
EndProcedure

Procedure.s GetNav(lang.s, currentKey.s, relPath.s)
  Protected n.s = ""
  Protected isFr.i = Bool(lang = "fr")
  
  n + "<nav class='doc-sidebar'>" + #CRLF$
  n + "  <div class='nav-section'>" + #CRLF$
  If isFr
    n + "    <div class='nav-section-title'>Introduction</div>" + #CRLF$
    n + "    <ul class='nav-list'>" + #CRLF$
    n + "      <li class='nav-item" + Iif(Bool(currentKey="index"), " active", "") + "'><a href='" + relPath + "index.html'><span>Vue d'ensemble</span></a></li>" + #CRLF$
    n + "    </ul>" + #CRLF$
    n + "  </div>" + #CRLF$
    n + "  <div class='nav-section'>" + #CRLF$
    n + "    <div class='nav-section-title'>Mots-cl&eacute;s POO</div>" + #CRLF$
    n + "    <ul class='nav-list'>" + #CRLF$
    n + "      <li class='nav-item" + Iif(Bool(currentKey="class"), " active", "") + "'><a href='" + relPath + "keywords/class.html'><span>Class / Abstract</span><span class='badge badge-keyword'>KW</span></a></li>" + #CRLF$
    n + "      <li class='nav-item" + Iif(Bool(currentKey="method"), " active", "") + "'><a href='" + relPath + "keywords/method.html'><span>Method / Override</span><span class='badge badge-keyword'>KW</span></a></li>" + #CRLF$
    n + "      <li class='nav-item" + Iif(Bool(currentKey="properties"), " active", "") + "'><a href='" + relPath + "keywords/properties.html'><span>Getter / Setter / Prop</span><span class='badge badge-keyword'>KW</span></a></li>" + #CRLF$
    n + "      <li class='nav-item" + Iif(Bool(currentKey="inheritance"), " active", "") + "'><a href='" + relPath + "keywords/inheritance.html'><span>Extends / Super</span><span class='badge badge-keyword'>KW</span></a></li>" + #CRLF$
    n + "      <li class='nav-item" + Iif(Bool(currentKey="encapsulation"), " active", "") + "'><a href='" + relPath + "keywords/encapsulation.html'><span>Public / Protected / Private</span><span class='badge badge-keyword'>KW</span></a></li>" + #CRLF$
    n + "      <li class='nav-item" + Iif(Bool(currentKey="lifecycle"), " active", "") + "'><a href='" + relPath + "keywords/lifecycle.html'><span>New / Free / Init</span><span class='badge badge-keyword'>KW</span></a></li>" + #CRLF$
    n + "      <li class='nav-item" + Iif(Bool(currentKey="operators"), " active", "") + "'><a href='" + relPath + "keywords/operators.html'><span>This / Cast / TypeOf</span><span class='badge badge-keyword'>KW</span></a></li>" + #CRLF$
    n + "    </ul>" + #CRLF$
    n + "  </div>" + #CRLF$
    n + "  <div class='nav-section'>" + #CRLF$
    n + "    <div class='nav-section-title'>Composants UI</div>" + #CRLF$
    n + "    <ul class='nav-list'>" + #CRLF$
    n + "      <li class='nav-item" + Iif(Bool(currentKey="application"), " active", "") + "'><a href='" + relPath + "ui/application.html'><span>Application</span><span class='badge badge-ui'>UI</span></a></li>" + #CRLF$
    n + "      <li class='nav-item" + Iif(Bool(currentKey="window"), " active", "") + "'><a href='" + relPath + "ui/window.html'><span>Window</span><span class='badge badge-ui'>UI</span></a></li>" + #CRLF$
    n + "      <li class='nav-item" + Iif(Bool(currentKey="gadget"), " active", "") + "'><a href='" + relPath + "ui/gadget.html'><span>Gadget / Component</span><span class='badge badge-ui'>UI</span></a></li>" + #CRLF$
    n + "      <li class='nav-item" + Iif(Bool(currentKey="button"), " active", "") + "'><a href='" + relPath + "ui/button.html'><span>Button</span><span class='badge badge-ui'>UI</span></a></li>" + #CRLF$
    n + "      <li class='nav-item" + Iif(Bool(currentKey="checkbox"), " active", "") + "'><a href='" + relPath + "ui/checkbox.html'><span>CheckBox</span><span class='badge badge-ui'>UI</span></a></li>" + #CRLF$
    n + "      <li class='nav-item" + Iif(Bool(currentKey="combobox"), " active", "") + "'><a href='" + relPath + "ui/combobox.html'><span>ComboBox</span><span class='badge badge-ui'>UI</span></a></li>" + #CRLF$
    n + "      <li class='nav-item" + Iif(Bool(currentKey="label"), " active", "") + "'><a href='" + relPath + "ui/label.html'><span>Label</span><span class='badge badge-ui'>UI</span></a></li>" + #CRLF$
    n + "      <li class='nav-item" + Iif(Bool(currentKey="listicon"), " active", "") + "'><a href='" + relPath + "ui/listicon.html'><span>ListIcon</span><span class='badge badge-ui'>UI</span></a></li>" + #CRLF$
    n + "      <li class='nav-item" + Iif(Bool(currentKey="progressbar"), " active", "") + "'><a href='" + relPath + "ui/progressbar.html'><span>ProgressBar</span><span class='badge badge-ui'>UI</span></a></li>" + #CRLF$
    n + "      <li class='nav-item" + Iif(Bool(currentKey="slider"), " active", "") + "'><a href='" + relPath + "ui/slider.html'><span>Slider</span><span class='badge badge-ui'>UI</span></a></li>" + #CRLF$
    n + "      <li class='nav-item" + Iif(Bool(currentKey="textbox"), " active", "") + "'><a href='" + relPath + "ui/textbox.html'><span>TextBox</span><span class='badge badge-ui'>UI</span></a></li>" + #CRLF$
    n + "      <li class='nav-item" + Iif(Bool(currentKey="toggleswitch"), " active", "") + "'><a href='" + relPath + "ui/toggleswitch.html'><span>ToggleSwitch</span><span class='badge badge-ui'>UI</span></a></li>" + #CRLF$
    n + "    </ul>" + #CRLF$
    n + "  </div>" + #CRLF$
    n + "  <div class='nav-section'>" + #CRLF$
    n + "    <div class='nav-section-title'>Layouts Responsifs (WPF)</div>" + #CRLF$
    n + "    <ul class='nav-list'>" + #CRLF$
    n + "      <li class='nav-item" + Iif(Bool(currentKey="container"), " active", "") + "'><a href='" + relPath + "ui/container.html'><span>Container</span><span class='badge badge-ui'>WPF</span></a></li>" + #CRLF$
    n + "      <li class='nav-item" + Iif(Bool(currentKey="stackpanel"), " active", "") + "'><a href='" + relPath + "ui/stackpanel.html'><span>StackPanel</span><span class='badge badge-ui'>WPF</span></a></li>" + #CRLF$
    n + "      <li class='nav-item" + Iif(Bool(currentKey="dockpanel"), " active", "") + "'><a href='" + relPath + "ui/dockpanel.html'><span>DockPanel</span><span class='badge badge-ui'>WPF</span></a></li>" + #CRLF$
    n + "      <li class='nav-item" + Iif(Bool(currentKey="grid"), " active", "") + "'><a href='" + relPath + "ui/grid.html'><span>Grid</span><span class='badge badge-ui'>WPF</span></a></li>" + #CRLF$
    n + "    </ul>" + #CRLF$
    n + "  </div>" + #CRLF$
  Else
    n + "    <div class='nav-section-title'>Getting Started</div>" + #CRLF$
    n + "    <ul class='nav-list'>" + #CRLF$
    n + "      <li class='nav-item" + Iif(Bool(currentKey="index"), " active", "") + "'><a href='" + relPath + "index.html'><span>Overview</span></a></li>" + #CRLF$
    n + "    </ul>" + #CRLF$
    n + "  </div>" + #CRLF$
    n + "  <div class='nav-section'>" + #CRLF$
    n + "    <div class='nav-section-title'>OOP Keywords</div>" + #CRLF$
    n + "    <ul class='nav-list'>" + #CRLF$
    n + "      <li class='nav-item" + Iif(Bool(currentKey="class"), " active", "") + "'><a href='" + relPath + "keywords/class.html'><span>Class / Abstract</span><span class='badge badge-keyword'>KW</span></a></li>" + #CRLF$
    n + "      <li class='nav-item" + Iif(Bool(currentKey="method"), " active", "") + "'><a href='" + relPath + "keywords/method.html'><span>Method / Override</span><span class='badge badge-keyword'>KW</span></a></li>" + #CRLF$
    n + "      <li class='nav-item" + Iif(Bool(currentKey="properties"), " active", "") + "'><a href='" + relPath + "keywords/properties.html'><span>Getter / Setter / Prop</span><span class='badge badge-keyword'>KW</span></a></li>" + #CRLF$
    n + "      <li class='nav-item" + Iif(Bool(currentKey="inheritance"), " active", "") + "'><a href='" + relPath + "keywords/inheritance.html'><span>Extends / Super</span><span class='badge badge-keyword'>KW</span></a></li>" + #CRLF$
    n + "      <li class='nav-item" + Iif(Bool(currentKey="encapsulation"), " active", "") + "'><a href='" + relPath + "keywords/encapsulation.html'><span>Public / Protected / Private</span><span class='badge badge-keyword'>KW</span></a></li>" + #CRLF$
    n + "      <li class='nav-item" + Iif(Bool(currentKey="lifecycle"), " active", "") + "'><a href='" + relPath + "keywords/lifecycle.html'><span>New / Free / Init</span><span class='badge badge-keyword'>KW</span></a></li>" + #CRLF$
    n + "      <li class='nav-item" + Iif(Bool(currentKey="operators"), " active", "") + "'><a href='" + relPath + "keywords/operators.html'><span>This / Cast / TypeOf</span><span class='badge badge-keyword'>KW</span></a></li>" + #CRLF$
    n + "    </ul>" + #CRLF$
    n + "  </div>" + #CRLF$
    n + "  <div class='nav-section'>" + #CRLF$
    n + "    <div class='nav-section-title'>UI Components</div>" + #CRLF$
    n + "    <ul class='nav-list'>" + #CRLF$
    n + "      <li class='nav-item" + Iif(Bool(currentKey="application"), " active", "") + "'><a href='" + relPath + "ui/application.html'><span>Application</span><span class='badge badge-ui'>UI</span></a></li>" + #CRLF$
    n + "      <li class='nav-item" + Iif(Bool(currentKey="window"), " active", "") + "'><a href='" + relPath + "ui/window.html'><span>Window</span><span class='badge badge-ui'>UI</span></a></li>" + #CRLF$
    n + "      <li class='nav-item" + Iif(Bool(currentKey="gadget"), " active", "") + "'><a href='" + relPath + "ui/gadget.html'><span>Gadget / Component</span><span class='badge badge-ui'>UI</span></a></li>" + #CRLF$
    n + "      <li class='nav-item" + Iif(Bool(currentKey="button"), " active", "") + "'><a href='" + relPath + "ui/button.html'><span>Button</span><span class='badge badge-ui'>UI</span></a></li>" + #CRLF$
    n + "      <li class='nav-item" + Iif(Bool(currentKey="checkbox"), " active", "") + "'><a href='" + relPath + "ui/checkbox.html'><span>CheckBox</span><span class='badge badge-ui'>UI</span></a></li>" + #CRLF$
    n + "      <li class='nav-item" + Iif(Bool(currentKey="combobox"), " active", "") + "'><a href='" + relPath + "ui/combobox.html'><span>ComboBox</span><span class='badge badge-ui'>UI</span></a></li>" + #CRLF$
    n + "      <li class='nav-item" + Iif(Bool(currentKey="label"), " active", "") + "'><a href='" + relPath + "ui/label.html'><span>Label</span><span class='badge badge-ui'>UI</span></a></li>" + #CRLF$
    n + "      <li class='nav-item" + Iif(Bool(currentKey="listicon"), " active", "") + "'><a href='" + relPath + "ui/listicon.html'><span>ListIcon</span><span class='badge badge-ui'>UI</span></a></li>" + #CRLF$
    n + "      <li class='nav-item" + Iif(Bool(currentKey="progressbar"), " active", "") + "'><a href='" + relPath + "ui/progressbar.html'><span>ProgressBar</span><span class='badge badge-ui'>UI</span></a></li>" + #CRLF$
    n + "      <li class='nav-item" + Iif(Bool(currentKey="slider"), " active", "") + "'><a href='" + relPath + "ui/slider.html'><span>Slider</span><span class='badge badge-ui'>UI</span></a></li>" + #CRLF$
    n + "      <li class='nav-item" + Iif(Bool(currentKey="textbox"), " active", "") + "'><a href='" + relPath + "ui/textbox.html'><span>TextBox</span><span class='badge badge-ui'>UI</span></a></li>" + #CRLF$
    n + "      <li class='nav-item" + Iif(Bool(currentKey="toggleswitch"), " active", "") + "'><a href='" + relPath + "ui/toggleswitch.html'><span>ToggleSwitch</span><span class='badge badge-ui'>UI</span></a></li>" + #CRLF$
    n + "    </ul>" + #CRLF$
    n + "  </div>" + #CRLF$
    n + "  <div class='nav-section'>" + #CRLF$
    n + "    <div class='nav-section-title'>Responsive Layouts (WPF)</div>" + #CRLF$
    n + "    <ul class='nav-list'>" + #CRLF$
    n + "      <li class='nav-item" + Iif(Bool(currentKey="container"), " active", "") + "'><a href='" + relPath + "ui/container.html'><span>Container</span><span class='badge badge-ui'>WPF</span></a></li>" + #CRLF$
    n + "      <li class='nav-item" + Iif(Bool(currentKey="stackpanel"), " active", "") + "'><a href='" + relPath + "ui/stackpanel.html'><span>StackPanel</span><span class='badge badge-ui'>WPF</span></a></li>" + #CRLF$
    n + "      <li class='nav-item" + Iif(Bool(currentKey="dockpanel"), " active", "") + "'><a href='" + relPath + "ui/dockpanel.html'><span>DockPanel</span><span class='badge badge-ui'>WPF</span></a></li>" + #CRLF$
    n + "      <li class='nav-item" + Iif(Bool(currentKey="grid"), " active", "") + "'><a href='" + relPath + "ui/grid.html'><span>Grid</span><span class='badge badge-ui'>WPF</span></a></li>" + #CRLF$
    n + "    </ul>" + #CRLF$
    n + "  </div>" + #CRLF$
  EndIf
  n + "</nav>" + #CRLF$
  
  ProcedureReturn n
EndProcedure

Procedure.s BuildPage(lang.s, currentKey.s, relTarget.s, title.s, subtitle.s, badgeClass.s, badgeText.s, contentHtml.s)
  Protected isFr.i = Bool(lang = "fr")
  Protected relRoot.s = "../"
  If FindString(relTarget, "/", 1) = 0
    relRoot = ""
  EndIf
  
  Protected langSwitchPath.s = ""
  If isFr
    langSwitchPath = "../en/" + relTarget
  Else
    langSwitchPath = "../fr/" + relTarget
  EndIf

  Protected html.s = ""
  html + "<!DOCTYPE html>" + #CRLF$
  html + "<html lang='" + lang + "'>" + #CRLF$
  html + "<head>" + #CRLF$
  html + "  <meta charset='utf-8'>" + #CRLF$
  html + "  <meta name='viewport' content='width=device-width, initial-scale=1.0'>" + #CRLF$
  html + "  <title>" + title + " - PureBasic OOP Documentation</title>" + #CRLF$
  html + "  <link rel='stylesheet' href='" + relRoot + "css/style.css'>" + #CRLF$
  html + "</head>" + #CRLF$
  html + "<body>" + #CRLF$
  html + "  <header class='doc-header'>" + #CRLF$
  html + "    <div class='header-left'>" + #CRLF$
  html + "      <div class='logo-container'>" + #CRLF$
  html + "        <span class='logo-text'>PureBasic <span class='logo-oop'>OOP</span></span>" + #CRLF$
  html + "        <span class='version-tag'>v1.2 Native</span>" + #CRLF$
  html + "      </div>" + #CRLF$
  html + "    </div>" + #CRLF$
  html + "    <div class='header-right'>" + #CRLF$
  html + "      <div class='lang-switch'>" + #CRLF$
  If isFr
    html + "        <a href='" + relTarget + "' class='lang-btn active'>FR</a>" + #CRLF$
    html + "        <a href='" + langSwitchPath + "' class='lang-btn'>EN</a>" + #CRLF$
  Else
    html + "        <a href='" + langSwitchPath + "' class='lang-btn'>FR</a>" + #CRLF$
    html + "        <a href='" + relTarget + "' class='lang-btn active'>EN</a>" + #CRLF$
  EndIf
  html + "      </div>" + #CRLF$
  html + "    </div>" + #CRLF$
  html + "  </header>" + #CRLF$
  html + "  <div class='doc-container'>" + #CRLF$
  html + GetNav(lang, currentKey, relRoot)
  html + "    <main class='doc-content'>" + #CRLF$
  html + "      <div class='breadcrumb'>" + #CRLF$
  If isFr
    html + "        <a href='" + relRoot + "index.html'>Accueil</a> / " + #CRLF$
    If FindString(relTarget, "keywords/", 1)
      html + "        <a href='#'>Mots-cl&eacute;s</a> / " + #CRLF$
    ElseIf FindString(relTarget, "ui/", 1)
      html + "        <a href='#'>Composants UI</a> / " + #CRLF$
    EndIf
    html + "        <span style='color: var(--accent-blue);'>" + title + "</span>" + #CRLF$
  Else
    html + "        <a href='" + relRoot + "index.html'>Home</a> / " + #CRLF$
    If FindString(relTarget, "keywords/", 1)
      html + "        <a href='#'>Keywords</a> / " + #CRLF$
    ElseIf FindString(relTarget, "ui/", 1)
      html + "        <a href='#'>UI Components</a> / " + #CRLF$
    EndIf
    html + "        <span style='color: var(--accent-blue);'>" + title + "</span>" + #CRLF$
  EndIf
  html + "      </div>" + #CRLF$
  html + "      <div class='page-header'>" + #CRLF$
  html + "        <div class='page-header-top'>" + #CRLF$
  html + "          <h1 class='page-title'>" + title + "</h1>" + #CRLF$
  html + "          <span class='badge " + badgeClass + "'>" + badgeText + "</span>" + #CRLF$
  html + "        </div>" + #CRLF$
  html + "        <p class='page-subtitle'>" + subtitle + "</p>" + #CRLF$
  html + "      </div>" + #CRLF$
  html + contentHtml + #CRLF$
  html + "    </main>" + #CRLF$
  html + "  </div>" + #CRLF$
  html + "</body>" + #CRLF$
  html + "</html>" + #CRLF$
  
  ProcedureReturn html
EndProcedure
'''

print("Writing full doc generator script...")

# Add page definitions in PureBasic
with open(r"c:\PB\PB_PROJECT\PB_OOP_WORKSPACE\PUREBASIC_OOP_WORKSPACE\scripts\generate_all_docs.pb", "w", encoding="utf-8") as f:
    f.write(pb_content)

print("Saved generate_all_docs.pb")
