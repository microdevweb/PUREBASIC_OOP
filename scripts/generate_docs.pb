; ============================================================================
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

Procedure.s BuildPage(lang.s, currentKey.s, pageSubPath.s, title.s, lead.s, badgeType.s, badgeText.s, content.s)
  Protected isFr.i = Bool(lang = "fr")
  Protected relRoot.s = "../"
  If pageSubPath = "index.html" : relRoot = "" : EndIf
  
  Protected otherLang.s = "en"
  Protected otherLangLabel.s = "English"
  If isFr = 0
    otherLang = "fr"
    otherLangLabel = "Français"
  EndIf
  
  Protected switchUrl.s = relRoot + "../" + otherLang + "/" + pageSubPath
  
  Protected h.s = ""
  h + "<!DOCTYPE html>" + #CRLF$
  h + "<html lang='" + lang + "'>" + #CRLF$
  h + "<head>" + #CRLF$
  h + "  <meta charset='UTF-8'>" + #CRLF$
  h + "  <meta name='viewport' content='width=device-width, initial-scale=1.0'>" + #CRLF$
  h + "  <title>" + title + " - PureBasic OOP Documentation</title>" + #CRLF$
  h + "  <link rel='stylesheet' href='" + relRoot + "../css/doc_theme.css'>" + #CRLF$
  h + "</head>" + #CRLF$
  h + "<body>" + #CRLF$
  
  ; Header
  h + "  <header class='doc-header'>" + #CRLF$
  h + "    <a href='" + relRoot + "index.html' class='brand-container'>" + #CRLF$
  h + "      <img src='" + relRoot + "../assets/PB_OOP_LOGO.jpeg' alt='Logo' class='brand-logo'>" + #CRLF$
  h + "      <span class='brand-title'>PureBasic OOP</span>" + #CRLF$
  h + "      <span class='brand-version'>ALPHA 1.0</span>" + #CRLF$
  h + "    </a>" + #CRLF$
  h + "    <div class='header-controls'>" + #CRLF$
  h + "      <div class='search-box'>" + #CRLF$
  h + "        <span class='search-icon'>&#128269;</span>" + #CRLF$
  h + "        <input type='text' class='search-input' id='search-input' placeholder='" + Iif(isFr, "Rechercher...", "Search docs...") + "'>" + #CRLF$
  h + "      </div>" + #CRLF$
  h + "      <div class='lang-switch'>" + #CRLF$
  h + "        <a href='" + Iif(isFr, "#", relRoot + "../fr/" + pageSubPath) + "' class='lang-btn" + Iif(isFr, " active", "") + "'>FR</a>" + #CRLF$
  h + "        <a href='" + Iif(Bool(isFr = 0), "#", relRoot + "../en/" + pageSubPath) + "' class='lang-btn" + Iif(Bool(isFr = 0), " active", "") + "'>EN</a>" + #CRLF$
  h + "      </div>" + #CRLF$
  h + "    </div>" + #CRLF$
  h + "  </header>" + #CRLF$
  
  ; Main layout
  h + "  <div class='layout-container'>" + #CRLF$
  h + GetNav(lang, currentKey, relRoot)
  
  ; Content
  h + "    <main class='doc-content'>" + #CRLF$
  h + "      <div class='breadcrumb'>" + #CRLF$
  h + "        <a href='" + relRoot + "index.html'>" + Iif(isFr, "Accueil", "Home") + "</a>" + #CRLF$
  If pageSubPath <> "index.html"
    Protected sectionName.s = "Keywords"
    If FindString(pageSubPath, "ui/", 1)
      sectionName = "UI Components"
    EndIf
    h + "        <span class='breadcrumb-separator'>/</span>" + #CRLF$
    h + "        <span>" + sectionName + "</span>" + #CRLF$
    h + "        <span class='breadcrumb-separator'>/</span>" + #CRLF$
    h + "        <span style='color: var(--accent-blue);'>" + title + "</span>" + #CRLF$
  EndIf
  h + "      </div>" + #CRLF$
  
  h + "      <div class='page-header'>" + #CRLF$
  h + "        <div class='title-row'>" + #CRLF$
  h + "          <h1 class='page-title'>" + title + "</h1>" + #CRLF$
  If badgeText <> ""
    h + "          <span class='badge " + badgeType + "'>" + badgeText + "</span>" + #CRLF$
  EndIf
  h + "        </div>" + #CRLF$
  If lead <> ""
    h + "        <p class='page-lead'>" + lead + "</p>" + #CRLF$
  EndIf
  h + "      </div>" + #CRLF$
  
  h + content + #CRLF$
  h + "    </main>" + #CRLF$
  h + "  </div>" + #CRLF$
  
  ; Footer
  h + "  <footer class='doc-footer'>" + #CRLF$
  h + "    <p>&copy; 2026 PureBasic OOP Project - MicrodevWeb | Dual License GPL v3 / Fantaisie Software</p>" + #CRLF$
  h + "  </footer>" + #CRLF$
  
  ; Client search script
  h + "  <script>" + #CRLF$
  h + "    document.getElementById('search-input').addEventListener('input', function(e) {" + #CRLF$
  h + "      let filter = e.target.value.toLowerCase();" + #CRLF$
  h + "      document.querySelectorAll('.nav-item').forEach(function(item) {" + #CRLF$
  h + "        let text = item.innerText.toLowerCase();" + #CRLF$
  h + "        if (text.includes(filter)) {" + #CRLF$
  h + "          item.style.display = '';" + #CRLF$
  h + "        } else {" + #CRLF$
  h + "          item.style.display = 'none';" + #CRLF$
  h + "        }" + #CRLF$
  h + "      });" + #CRLF$
  h + "    });" + #CRLF$
  h + "  </script>" + #CRLF$
  h + "</body>" + #CRLF$
  h + "</html>" + #CRLF$
  
  ProcedureReturn h
EndProcedure

OpenConsole("PureBasic OOP Documentation Generator")
PrintN("Starting Doc generation...")

; ============================================================================
; 1. FRENCH PAGES
; ============================================================================

; FR Index
Define fr_index.s = "<div class='doc-section'>" +
  "<h2 class='section-title'>Bienvenue dans PureBasic OOP</h2>" +
  "<p>PureBasic OOP apporte la puissance de la Programmation Orient&eacute;e Objet compl&egrave;te &agrave; PureBasic gr&acirc;ce &agrave; un transpileur optimis&eacute; et une biblioth&egrave;que UI native moderne.</p>" +
  "<div class='callout callout-tip'>" +
  "  <div class='callout-title'>&#128640; Touche d'aide contextuelle F1</div>" +
  "  <p>Dans l'IDE, placez votre curseur sur n'importe quel mot-cl&eacute; POO (<code>Class</code>, <code>Method</code>, <code>Super</code>, <code>Property</code>...) ou classe UI (<code>Window</code>, <code>Button</code>, <code>Application</code>...) et appuyez sur <strong>F1</strong> pour ouvrir directement sa fiche d'aide !</p>" +
  "</div>" +
  "</div>" +
  "<div class='doc-section'>" +
  "<h2 class='section-title'>Cat&eacute;gories de documentation</h2>" +
  "<div class='cards-grid'>" +
  "  <a href='keywords/class.html' class='doc-card'>" +
  "    <div class='doc-card-title'><span>D&eacute;claration de Classes</span><span class='badge badge-keyword'>Class</span></div>" +
  "    <div class='doc-card-desc'>D&eacute;finition des classes concr&egrave;tes et abstraites, h&eacute;ritage et polymorphisme.</div>" +
  "  </a>" +
  "  <a href='keywords/method.html' class='doc-card'>" +
  "    <div class='doc-card-title'><span>M&eacute;thodes & Surcharge</span><span class='badge badge-method'>Method</span></div>" +
  "    <div class='doc-card-desc'>Constructeurs, destructeurs, m&eacute;thodes abstraites et dispatch virtuel via VTable.</div>" +
  "  </a>" +
  "  <a href='keywords/properties.html' class='doc-card'>" +
  "    <div class='doc-card-title'><span>Propri&eacute;t&eacute;s & Accesseurs</span><span class='badge badge-keyword'>Property</span></div>" +
  "    <div class='doc-card-desc'>Getters, Setters et propri&eacute;t&eacute;s encapsul&eacute;es avec auto-g&eacute;n&eacute;ration.</div>" +
  "  </a>" +
  "  <a href='ui/application.html' class='doc-card'>" +
  "    <div class='doc-card-title'><span>Framework UI / GUI</span><span class='badge badge-ui'>UI</span></div>" +
  "    <div class='doc-card-desc'>Classes d'interface : Application, Window, Button, ToggleSwitch, Slider...</div>" +
  "  </a>" +
  "  <a href='ui/container.html' class='doc-card'>" +
  "    <div class='doc-card-title'><span>Layouts Responsifs (WPF)</span><span class='badge badge-ui'>WPF</span></div>" +
  "    <div class='doc-card-desc'>Syst&egrave;me de mise en page automatique : StackPanel, DockPanel, Grid 2D...</div>" +
  "  </a>" +
  "</div>" +
  "</div>"

SaveHTML(BaseDocDir + "fr\index.html", BuildPage("fr", "index", "index.html", "Documentation PureBasic OOP", "Guide de r&eacute;f&eacute;rence complet pour le d&eacute;veloppement Objet et UI sous PureBasic.", "badge-class", "Guide", fr_index))

; FR Keyword: Class
Define fr_class.s = "<div class='doc-section'>" +
  "<h2 class='section-title'>Description</h2>" +
  "<p>Le mot-cl&eacute; <code>Class</code> d&eacute;clare une nouvelle classe d'objets. Une classe regroupe des champs prot&eacute;g&eacute;s/priv&eacute;s et des m&eacute;thodes publiques pour manipuler ses donn&eacute;es.</p>" +
  "<p>Une classe peut &ecirc;tre d&eacute;clar&eacute;e <code>Abstract Class</code> pour servir de mod&egrave;le g&eacute;n&eacute;rique non instanciable directement.</p>" +
  "</div>" +
  "<div class='doc-section'>" +
  "<h2 class='section-title'>Syntaxe</h2>" +
  "<div class='code-container'>" +
  "  <div class='code-header'><span class='code-title'>Exemple : D&eacute;claration de classe (.pbo)</span><span class='code-badge'>PBO</span></div>" +
  "  <pre><code><span class='kw'>Class</span> <span class='tp'>Personne</span>" + #CRLF$ +
  "  <span class='kw'>Protected</span> nom.<span class='tp'>s</span>" + #CRLF$ +
  "  <span class='kw'>Protected</span> age.<span class='tp'>i</span>" + #CRLF$ +
  #CRLF$ +
  "  <span class='kw'>Public</span> <span class='kw'>Method</span> <span class='fn'>Init</span>(nom_p.<span class='tp'>s</span>, age_p.<span class='tp'>i</span>)" + #CRLF$ +
  "    <span class='kw'>This</span>\\nom = nom_p" + #CRLF$ +
  "    <span class='kw'>This</span>\\age = age_p" + #CRLF$ +
  "  <span class='kw'>EndMethod</span>" + #CRLF$ +
  #CRLF$ +
  "  <span class='kw'>Public</span> <span class='kw'>Method</span>.<span class='tp'>s</span> <span class='fn'>GetNom</span>()" + #CRLF$ +
  "    <span class='kw'>ProcedureReturn</span> <span class='kw'>This</span>\\nom" + #CRLF$ +
  "  <span class='kw'>EndMethod</span>" + #CRLF$ +
  "<span class='kw'>EndClass</span></code></pre>" +
  "</div>" +
  "</div>" +
  "<div class='doc-section'>" +
  "<h2 class='section-title'>Mots-cl&eacute;s associ&eacute;s</h2>" +
  "<ul>" +
  "  <li><code>EndClass</code> : Cl&ocirc;ture le bloc de d&eacute;claration de la classe.</li>" +
  "  <li><code>Abstract Class</code> : D&eacute;finit une classe abstraite imposant des contrats aux classes filles.</li>" +
  "  <li><code>Extends</code> : Sp&eacute;cifie la classe parente dont h&eacute;rite la classe courante.</li>" +
  "</ul>" +
  "</div>"

SaveHTML(BaseDocDir + "fr\keywords\class.html", BuildPage("fr", "class", "keywords/class.html", "Class / Abstract Class", "D&eacute;claration de classes, encapsulation et mod&eacute;lisation orient&eacute;e objet.", "badge-keyword", "Mot-cl&eacute;", fr_class))

; FR Keyword: Method
Define fr_method.s = "<div class='doc-section'>" +
  "<h2 class='section-title'>Description</h2>" +
  "<p>Le mot-cl&eacute; <code>Method</code> d&eacute;clare une fonction ou proc&eacute;dure membre attach&eacute;e &agrave; une classe. Les m&eacute;thodes peuvent recevoir des param&egrave;tres, retourner une valeur typ&eacute;e et acc&eacute;der aux champs de l'instance via <code>This</code>.</p>" +
  "</div>" +
  "<div class='doc-section'>" +
  "<h2 class='section-title'>Constructeurs et Destructeurs</h2>" +
  "<ul>" +
  "  <li><code>Public Method Init(...)</code> : Constructeur appel&eacute; automatiquement lors de l'instanciation via <code>New</code>.</li>" +
  "  <li><code>Public Method Free()</code> : Destructeur appel&eacute; lors de la lib&eacute;ration de l'objet via <code>FreeObject</code>.</li>" +
  "  <li><code>Public Abstract Method</code> : Prototype de m&eacute;thode dans une classe abstraite que toute classe fille concr&egrave;te doit obligatoirement impl&eacute;menter.</li>" +
  "</ul>" +
  "</div>" +
  "<div class='doc-section'>" +
  "<h2 class='section-title'>Exemple de Polymorphisme</h2>" +
  "<div class='code-container'>" +
  "  <div class='code-header'><span class='code-title'>Exemple : Surcharge de m&eacute;thode (.pbo)</span><span class='code-badge'>PBO</span></div>" +
  "  <pre><code><span class='kw'>Class</span> <span class='tp'>Chien</span> <span class='kw'>Extends</span> <span class='tp'>Animal</span>" + #CRLF$ +
  "  <span class='kw'>Public</span> <span class='kw'>Method</span> <span class='fn'>Crier</span>()" + #CRLF$ +
  "    <span class='kw'>Super</span>::<span class='fn'>Crier</span>() <span class='cm'>; Appel de la m&eacute;thode parente si d&eacute;sir&eacute;</span>" + #CRLF$ +
  "    <span class='fn'>PrintN</span>('Ouaf Ouaf !')" + #CRLF$ +
  "  <span class='kw'>EndMethod</span>" + #CRLF$ +
  "<span class='kw'>EndClass</span></code></pre>" +
  "</div>" +
  "</div>"

SaveHTML(BaseDocDir + "fr\keywords\method.html", BuildPage("fr", "method", "keywords/method.html", "Method / EndMethod", "D&eacute;claration des m&eacute;thodes d'instance, polymorphisme, constructeurs et destructeurs.", "badge-method", "M&eacute;thode", fr_method))

; FR Keyword: Properties
Define fr_properties.s = "<div class='doc-section'>" +
  "<h2 class='section-title'>Description</h2>" +
  "<p>Les accesseurs <code>Getter</code> et <code>Setter</code> (ou <code>Property</code>) permettent d'encapsuler la lecture et l'&eacute;criture des variables membres priv&eacute;es ou prot&eacute;g&eacute;es avec validation automatique.</p>" +
  "</div>" +
  "<div class='doc-section'>" +
  "<h2 class='section-title'>Syntaxe</h2>" +
  "<div class='code-container'>" +
  "  <div class='code-header'><span class='code-title'>Exemple : Getters et Setters (.pbo)</span><span class='code-badge'>PBO</span></div>" +
  "  <pre><code><span class='kw'>Class</span> <span class='tp'>CompteBancaire</span>" + #CRLF$ +
  "  <span class='kw'>Protected</span> solde.<span class='tp'>d</span>" + #CRLF$ +
  #CRLF$ +
  "  <span class='kw'>Public</span> <span class='kw'>Getter</span>.<span class='tp'>d</span> <span class='fn'>Solde</span>()" + #CRLF$ +
  "    <span class='kw'>ProcedureReturn</span> <span class='kw'>This</span>\\solde" + #CRLF$ +
  "  <span class='kw'>EndGetter</span>" + #CRLF$ +
  #CRLF$ +
  "  <span class='kw'>Public</span> <span class='kw'>Setter</span> <span class='fn'>Solde</span>(nouveauSolde.<span class='tp'>d</span>)" + #CRLF$ +
  "    <span class='kw'>If</span> nouveauSolde >= <span class='num'>0</span>" + #CRLF$ +
  "      <span class='kw'>This</span>\\solde = nouveauSolde" + #CRLF$ +
  "    <span class='kw'>EndIf</span>" + #CRLF$ +
  "  <span class='kw'>EndSetter</span>" + #CRLF$ +
  "<span class='kw'>EndClass</span></code></pre>" +
  "</div>" +
  "</div>"

SaveHTML(BaseDocDir + "fr\keywords\properties.html", BuildPage("fr", "properties", "keywords/properties.html", "Getter / Setter / Property", "Encapsulation des donn&eacute;es et accesseurs de propri&eacute;t&eacute;s.", "badge-keyword", "Propri&eacute;t&eacute;", fr_properties))

; FR Keyword: Inheritance
Define fr_inheritance.s = "<div class='doc-section'>" +
  "<h2 class='section-title'>Description</h2>" +
  "<p>Le mot-cl&eacute; <code>Extends</code> permet &agrave; une classe d'h&eacute;riter des champs et m&eacute;thodes d'une classe parente. Le mot-cl&eacute; <code>Super\\</code> permet d'invoquer l'impl&eacute;mentation parente d'une m&eacute;thode surcharg&eacute;e.</p>" +
  "</div>" +
  "<div class='doc-section'>" +
  "<h2 class='section-title'>Exemple d'H&eacute;ritage</h2>" +
  "<div class='code-container'>" +
  "  <div class='code-header'><span class='code-title'>H&eacute;ritage et appel Super (.pbo)</span><span class='code-badge'>PBO</span></div>" +
  "  <pre><code><span class='kw'>Class</span> <span class='tp'>Vehicule</span>" + #CRLF$ +
  "  <span class='kw'>Protected</span> marque.<span class='tp'>s</span>" + #CRLF$ +
  "  <span class='kw'>Public</span> <span class='kw'>Method</span> <span class='fn'>Demarrer</span>()" + #CRLF$ +
  "    <span class='fn'>PrintN</span>('Contact mis.')" + #CRLF$ +
  "  <span class='kw'>EndMethod</span>" + #CRLF$ +
  "<span class='kw'>EndClass</span>" + #CRLF$ +
  #CRLF$ +
  "<span class='kw'>Class</span> <span class='tp'>Voiture</span> <span class='kw'>Extends</span> <span class='tp'>Vehicule</span>" + #CRLF$ +
  "  <span class='kw'>Public</span> <span class='kw'>Method</span> <span class='fn'>Demarrer</span>()" + #CRLF$ +
  "    <span class='kw'>Super</span>\\<span class='fn'>Demarrer</span>()" + #CRLF$ +
  "    <span class='fn'>PrintN</span>('Moteur V8 en route !')" + #CRLF$ +
  "  <span class='kw'>EndMethod</span>" + #CRLF$ +
  "<span class='kw'>EndClass</span></code></pre>" +
  "</div>" +
  "</div>"

SaveHTML(BaseDocDir + "fr\keywords\inheritance.html", BuildPage("fr", "inheritance", "keywords/inheritance.html", "Extends / Super", "H&eacute;ritage de classe et r&eacute;utilisation de code parent.", "badge-keyword", "H&eacute;ritage", fr_inheritance))

; FR Keyword: Encapsulation
Define fr_encapsulation.s = "<div class='doc-section'>" +
  "<h2 class='section-title'>Niveaux de Visibilit&eacute;</h2>" +
  "<div class='table-wrapper'>" +
  "  <table>" +
  "    <tr><th>Visibilit&eacute;</th><th>Port&eacute;e</th><th>Description</th></tr>" +
  "    <tr><td><code>Public</code></td><td>Partout</td><td>Accessible depuis l'int&eacute;rieur et l'ext&eacute;rieur de l'objet (m&eacute;thodes publiques).</td></tr>" +
  "    <tr><td><code>Protected</code></td><td>Classe & Filles</td><td>Accessible uniquement par la classe et ses classes d&eacute;riv&eacute;es (h&eacute;ritage).</td></tr>" +
  "    <tr><td><code>Private</code></td><td>Classe uniquement</td><td>Strictement r&eacute;serv&eacute; &agrave; la classe qui le d&eacute;clare.</td></tr>" +
  "  </table>" +
  "</div>" +
  "</div>"

SaveHTML(BaseDocDir + "fr\keywords\encapsulation.html", BuildPage("fr", "encapsulation", "keywords/encapsulation.html", "Public / Protected / Private", "Contr&ocirc;le d'acc&egrave;s et visibilit&eacute; des membres d'une classe.", "badge-keyword", "Encapsulation", fr_encapsulation))

; FR Keyword: Lifecycle
Define fr_lifecycle.s = "<div class='doc-section'>" +
  "<h2 class='section-title'>Gestion du Cycle de Vie des Objets</h2>" +
  "<p>Dans PureBasic OOP, l'instanciation et la destruction des objets s'effectuent simplement et de fa&ccedil;on s&ucirc;re en m&eacute;moire :</p>" +
  "<ul>" +
  "  <li><code>*obj.MaClasse = NewObject(MaClasse, param1, param2)</code> ou <code>New MaClasse(...)</code> : Alloue l'objet en m&eacute;moire, initialise la VTable et appelle le constructeur <code>Init()</code>.</li>" +
  "  <li><code>FreeObject(*obj)</code> ou <code>*obj\\Free()</code> : Appelle le destructeur <code>Free()</code> et lib&egrave;re la m&eacute;moire allou&eacute;e.</li>" +
  "</ul>" +
  "</div>"

SaveHTML(BaseDocDir + "fr\keywords\lifecycle.html", BuildPage("fr", "lifecycle", "keywords/lifecycle.html", "New / Free / Cycle de vie", "Instanciation, initialisation et lib&eacute;ration m&eacute;moire des objets.", "badge-keyword", "M&eacute;moire", fr_lifecycle))

; FR Keyword: Operators
Define fr_operators.s = "<div class='doc-section'>" +
  "<h2 class='section-title'>Op&eacute;rateurs et R&eacute;f&eacute;rences Sp&eacute;ciales</h2>" +
  "<ul>" +
  "  <li><code>This</code> : Pointeur vers l'instance courante de l'objet au sein de ses m&eacute;thodes.</li>" +
  "  <li><code>Super\\</code> : Appel explicite de la m&eacute;thode d'une classe parente.</li>" +
  "  <li><code>TypeOf(*obj)</code> : Renvoie le nom de la classe d'une instance.</li>" +
  "  <li><code>InstanceOf(*obj, MaClasse)</code> : V&eacute;rifie si un objet h&eacute;rite ou est une instance d'une classe donn&eacute;e.</li>" +
  "</ul>" +
  "</div>"

SaveHTML(BaseDocDir + "fr\keywords\operators.html", BuildPage("fr", "operators", "keywords/operators.html", "This / Cast / TypeOf", "Op&eacute;rateurs de contexte et r&eacute;flexion objet.", "badge-keyword", "Op&eacute;rateur", fr_operators))

; FR UI: Application
Define fr_application.s = "<div class='doc-section'>" +
  "<h2 class='section-title'>Description</h2>" +
  "<p>La classe <code>Application</code> g&egrave;re le cycle de vie principal de l'application graphique, la boucle d'&eacute;v&eacute;nements PureBasic (Event Loop) et l'enregistrement des fen&ecirc;tres.</p>" +
  "</div>" +
  "<div class='doc-section'>" +
  "<h2 class='section-title'>M&eacute;thodes principales</h2>" +
  "<div class='table-wrapper'>" +
  "  <table>" +
  "    <tr><th>M&eacute;thode</th><th>Description</th></tr>" +
  "    <tr><td><code>Init(title.s = '')</code></td><td>Initialise le gestionnaire d'application.</td></tr>" +
  "    <tr><td><code>Run()</code></td><td>Lance la boucle d'&eacute;v&eacute;nements principale et traite les messages fen&ecirc;tres.</td></tr>" +
  "    <tr><td><code>Exit()</code></td><td>Termine proprement l'application et ferme toutes les fen&ecirc;tres actives.</td></tr>" +
  "  </table>" +
  "</div>" +
  "</div>"

; FR UI: Window
Define fr_window.s = "<div class='doc-section'>" +
  "<h2 class='section-title'>Description</h2>" +
  "<p>La classe <code>UI::Window</code> encapsule une fen&ecirc;tre graphique native PureBasic. H&eacute;ritant de <code>Component</code>, elle offre un contr&ocirc;le total sur ses dimensions, sa position, sa visibilit&eacute;, ainsi que des m&eacute;thodes virtuelles pour intercepter les &eacute;v&eacute;nements syst&egrave;me (fermeture, redimensionnement, d&eacute;placement).</p>" +
  "<p>Gr&acirc;ce &agrave; la <strong>surcharge de m&eacute;thodes</strong>, vous disposez de <strong>5 constructeurs diff&eacute;rents</strong> pour instancier une fen&ecirc;tre de mani&egrave;re concise ou d&eacute;taill&eacute;e selon vos besoins.</p>" +
  "</div>" +
  "<div class='doc-section'>" +
  "<h2 class='section-title'>Constructeurs Disponibles (Surcharge Init)</h2>" +
  "<div class='table-wrapper'>" +
  "  <table>" +
  "    <tr><th>Constructeur</th><th>Description & Comportement par d&eacute;faut</th></tr>" +
  "    <tr><td><code>New Window(title.s)</code></td><td><strong>Constructeur Rapide :</strong> Ouvre une fen&ecirc;tre de <strong>800 &times; 600</strong> pixels, automatiquement <strong>centr&eacute;e &agrave; l'&eacute;cran</strong> avec le menu syst&egrave;me et le bouton r&eacute;duire.</td></tr>" +
  "    <tr><td><code>New Window(title.s, w.i, h.i)</code></td><td><strong>Constructeur Dimensions :</strong> Ouvre une fen&ecirc;tre aux dimensions <code>w &times; h</code>, <strong>centr&eacute;e &agrave; l'&eacute;cran</strong> avec les drapeaux par d&eacute;faut.</td></tr>" +
  "    <tr><td><code>New Window(title.s, w.i, h.i, flags.i)</code></td><td><strong>Constructeur avec Flags :</strong> Ouvre une fen&ecirc;tre <code>w &times; h</code> avec les drapeaux PureBasic sp&eacute;cifi&eacute;s (ex: <code>#PB_Window_Tool</code>, <code>#PB_Window_BorderLess</code>...).</td></tr>" +
  "    <tr><td><code>New Window(title.s, x.i, y.i, w.i, h.i)</code></td><td><strong>Constructeur Positionn&eacute; :</strong> Ouvre une fen&ecirc;tre aux coordonn&eacute;es absolues <code>(x, y)</code> et dimensions <code>w &times; h</code>.</td></tr>" +
  "    <tr><td><code>New Window(title.s, x.i, y.i, w.i, h.i, flags.i, parentID.i = 0)</code></td><td><strong>Constructeur Complet :</strong> Permet de configurer tous les param&egrave;tres, y compris la fen&ecirc;tre parente (pour les fen&ecirc;tres modales ou secondaires).</td></tr>" +
  "  </table>" +
  "</div>" +
  "</div>" +
  "<div class='doc-section'>" +
  "<h2 class='section-title'>Accesseurs (Getters & Setters)</h2>" +
  "<p>Toutes les propri&eacute;t&eacute;s de la fen&ecirc;tre sont modifiables et consultables &agrave; tout moment avec synchronisation temps-r&eacute;el vers l'API PureBasic :</p>" +
  "<div class='table-wrapper'>" +
  "  <table>" +
  "    <tr><th>Propri&eacute;t&eacute;</th><th>Setter</th><th>Getter</th><th>Description</th></tr>" +
  "    <tr><td><strong>Titre</strong></td><td><code>SetTitle(t.s)</code></td><td><code>GetTitle()</code></td><td>Modifie ou r&eacute;cup&egrave;re le texte de la barre de titre (<code>SetWindowTitle</code>).</td></tr>" +
  "    <tr><td><strong>Position X</strong></td><td><code>SetX(nx.i)</code></td><td><code>GetX()</code></td><td>Position horizontale &agrave; l'&eacute;cran (<code>WindowX</code> / <code>ResizeWindow</code>).</td></tr>" +
  "    <tr><td><strong>Position Y</strong></td><td><code>SetY(ny.i)</code></td><td><code>GetY()</code></td><td>Position verticale &agrave; l'&eacute;cran (<code>WindowY</code> / <code>ResizeWindow</code>).</td></tr>" +
  "    <tr><td><strong>Largeur</strong></td><td><code>SetWidth(nw.i)</code></td><td><code>GetWidth()</code></td><td>Largeur de la zone cliente en pixels (<code>WindowWidth</code>).</td></tr>" +
  "    <tr><td><strong>Hauteur</strong></td><td><code>SetHeight(nh.i)</code></td><td><code>GetHeight()</code></td><td>Hauteur de la zone cliente en pixels (<code>WindowHeight</code>).</td></tr>" +
  "    <tr><td><strong>Position (X, Y)</strong></td><td><code>SetLocation(x.i, y.i)</code></td><td>&mdash;</td><td>D&eacute;place la fen&ecirc;tre aux coordonn&eacute;es <code>(x, y)</code> sans modifier ses dimensions.</td></tr>" +
  "    <tr><td><strong>Taille (W, H)</strong></td><td><code>SetSize(w.i, h.i)</code></td><td>&mdash;</td><td>Redimensionne la zone cliente &agrave; <code>w &times; h</code>.</td></tr>" +
  "    <tr><td><strong>Zone compl&egrave;te</strong></td><td><code>SetPosition(x, y, w, h)</code></td><td>&mdash;</td><td>Met &agrave; jour position et dimensions en un seul appel.</td></tr>" +
  "    <tr><td><strong>Visibilit&eacute;</strong></td><td><code>SetVisible(v.b)</code></td><td><code>IsVisible()</code>, <code>GetVisible()</code></td><td>Affiche (<code>#True</code>) ou masque (<code>#False</code>) la fen&ecirc;tre (<code>HideWindow</code>).</td></tr>" +
  "    <tr><td><strong>Activation</strong></td><td><code>SetEnabled(e.b)</code></td><td><code>IsEnabled()</code>, <code>GetEnabled()</code></td><td>Active ou d&eacute;sactive les interactions utilisateur (<code>DisableWindow</code>).</td></tr>" +
  "    <tr><td><strong>Drapeaux</strong></td><td><code>SetFlags(flags.i)</code></td><td><code>GetFlags()</code></td><td>Drapeaux de style appliqu&eacute;s &agrave; la cr&eacute;ation.</td></tr>" +
  "    <tr><td><strong>Parent</strong></td><td><code>SetParentID(id.i)</code></td><td><code>GetParentID()</code></td><td>Identifiant de la fen&ecirc;tre parente.</td></tr>" +
  "    <tr><td><strong>Donn&eacute;es / Tag</strong></td><td><code>SetTag(s.s)</code> / <code>SetUserData(v.i)</code></td><td><code>GetTag()</code> / <code>GetUserData()</code></td><td>Informations ou pointeurs personnalis&eacute;s attach&eacute;s au composant.</td></tr>" +
  "    <tr><td><strong>Handle PB</strong></td><td>&mdash;</td><td><code>GetID()</code>, <code>GetHandle()</code></td><td>Num&eacute;ro d'identification natif PureBasic de la fen&ecirc;tre.</td></tr>" +
  "  </table>" +
  "</div>" +
  "</div>" +
  "<div class='doc-section'>" +
  "<h2 class='section-title'>Exemple Complet : Cr&eacute;ation et Manipulation</h2>" +
  "<div class='code-container'>" +
  "  <div class='code-header'><span class='code-title'>Exemple : Utilisation des constructeurs et setters (.pbo)</span><span class='code-badge'>PBO</span></div>" +
  "  <pre><code><span class='kw'>XIncludeFile</span> <span class='str'>'ui/UI.pbo'</span>" + #CRLF$ +
  "<span class='kw'>Using</span> <span class='tp'>UI</span>" + #CRLF$ +
  #CRLF$ +
  "<span class='cm'>; 1. Cr&eacute;ation ultra-rapide (800x600 centr&eacute;e)</span>" + #CRLF$ +
  "<span class='kw'>Define</span> *maFenetre.<span class='tp'>Window</span> = <span class='kw'>New</span> <span class='tp'>Window</span>(<span class='str'>'Mon Application'</span>)" + #CRLF$ +
  #CRLF$ +
  "<span class='cm'>; 2. Personnalisation dynamique avec les setters</span>" + #CRLF$ +
  "*maFenetre\\<span class='fn'>SetTitle</span>(<span class='str'>'Tableau de bord - Session active'</span>)" + #CRLF$ +
  "*maFenetre\\<span class='fn'>SetSize</span>(<span class='num'>1024</span>, <span class='num'>768</span>)" + #CRLF$ +
  #CRLF$ +
  "<span class='cm'>; 3. V&eacute;rification avec les getters</span>" + #CRLF$ +
  "<span class='fn'>Debug</span> <span class='str'>'Largeur actuelle : '</span> + <span class='fn'>Str</span>(*maFenetre\\<span class='fn'>GetWidth</span>())" + #CRLF$ +
  "<span class='fn'>Debug</span> <span class='str'>'Hauteur actuelle : '</span> + <span class='fn'>Str</span>(*maFenetre\\<span class='fn'>GetHeight</span>())" + #CRLF$ +
  #CRLF$ +
  "<span class='cm'>; 4. Fermeture et lib&eacute;ration</span>" + #CRLF$ +
  "*maFenetre\\<span class='fn'>Free</span>()</code></pre>" +
  "</div>" +
  "</div>"

SaveHTML(BaseDocDir + "fr\ui\window.html", BuildPage("fr", "window", "ui/window.html", "Classe Window", "Cr&eacute;ation flexible de fen&ecirc;tres avec constructeurs multiples et accesseurs dynamiques.", "badge-ui", "UI Class", fr_window))

; ============================================================================
; FRENCH UI PAGES
; ============================================================================

; FR UI: Gadget / Component
Define fr_gadget.s = "<div class='doc-section'>" +
  "<h2 class='section-title'>Description</h2>" +
  "<p>La classe abstraite <code>UI::Component</code> et sa sp&eacute;cialisation <code>UI::Gadget</code> constituent le socle de tous les contr&ocirc;les graphiques et panneaux de mise en page responsive.</p>" +
  "<p>Elles fournissent la gestion automatique des coordonn&eacute;es (<code>x</code>, <code>y</code>, <code>width</code>, <code>height</code>), des dimensions minimales / maximales, des marges (<code>Margin</code>), des alignements (<code>HorizontalAlignment</code>, <code>VerticalAlignment</code>), de la visibilit&eacute;, de l'&eacute;tat activ&eacute;/d&eacute;sactiv&eacute;, et du routage unifi&eacute; des &eacute;v&eacute;nements.</p>" +
  "</div>" +
  "<div class='doc-section'>" +
  "<h2 class='section-title'>M&eacute;thodes Principales</h2>" +
  "<div class='table-wrapper'>" +
  "  <table>" +
  "    <tr><th>M&eacute;thode</th><th>Description</th></tr>" +
  "    <tr><td><code>SetMargin(l.i, t.i, r.i, b.i)</code> / <code>SetMarginAll(m.i)</code></td><td>D&eacute;finit les marges externes autour du contr&ocirc;le.</td></tr>" +
  "    <tr><td><code>SetHorizontalAlignment(align.i)</code></td><td>Alignement horizontal (<code>#UI_Align_Left</code>, <code>#UI_Align_Center</code>, <code>#UI_Align_Right</code>, <code>#UI_Align_Stretch</code>).</td></tr>" +
  "    <tr><td><code>SetVerticalAlignment(align.i)</code></td><td>Alignement vertical (<code>#UI_Align_Top</code>, <code>#UI_Align_Middle</code>, <code>#UI_Align_Bottom</code>, <code>#UI_Align_VStretch</code>).</td></tr>" +
  "    <tr><td><code>SetVisible(v.b)</code> / <code>IsVisible()</code></td><td>Contr&ocirc;le la visibilit&eacute; du composant.</td></tr>" +
  "    <tr><td><code>SetEnabled(e.b)</code> / <code>IsEnabled()</code></td><td>Active ou d&eacute;sactive l'interaction utilisateur.</td></tr>" +
  "    <tr><td><code>SetToolTip(tip.s)</code></td><td>D&eacute;finit l'infobulle d'aide au survol.</td></tr>" +
  "    <tr><td><code>SetFocus()</code></td><td>Donne le focus clavier au gadget.</td></tr>" +
  "  </table>" +
  "</div>" +
  "</div>"

SaveHTML(BaseDocDir + "fr\ui\gadget.html", BuildPage("fr", "gadget", "ui/gadget.html", "Classe Gadget & Component", "Classe de base abstraite pour tous les contr&ocirc;les UI et layouts.", "badge-ui", "UI Class", fr_gadget))

; FR UI: Button
Define fr_button.s = "<div class='doc-section'>" +
  "<h2 class='section-title'>Description</h2>" +
  "<p>La classe <code>UI::Button</code> encapsule un bouton poussoir cliquable PureBasic avec gestion directe de l'&eacute;v&eacute;nement virtuel <code>OnClick()</code> et prise en charge des layouts r&eacute;actifs.</p>" +
  "</div>" +
  "<div class='doc-section'>" +
  "<h2 class='section-title'>Constructeurs Surcharg&eacute;s</h2>" +
  "<div class='table-wrapper'>" +
  "  <table>" +
  "    <tr><th>Constructeur</th><th>Description</th></tr>" +
  "    <tr><td><code>Init(text.s)</code></td><td>Cr&eacute;e un bouton avec texte (taille par d&eacute;faut 120&times;30 pour les layouts automatiques).</td></tr>" +
  "    <tr><td><code>Init(text.s, w.i, h.i)</code></td><td>Cr&eacute;e un bouton avec texte et dimensions sp&eacute;cifi&eacute;es.</td></tr>" +
  "    <tr><td><code>Init(x.i, y.i, w.i, h.i, text.s)</code></td><td>Positionnement absolu avec coordonn&eacute;es, dimensions et texte.</td></tr>" +
  "    <tr><td><code>Init(x.i, y.i, w.i, h.i, text.s, flags.i)</code></td><td>Cr&eacute;ation compl&egrave;te avec flags PureBasic (ex: <code>#PB_Button_Default</code>, <code>#PB_Button_Toggle</code>).</td></tr>" +
  "  </table>" +
  "</div>" +
  "</div>" +
  "<div class='doc-section'>" +
  "<h2 class='section-title'>Exemple d'utilisation</h2>" +
  "<div class='code-container'>" +
  "  <div class='code-header'><span class='code-title'>Bouton standard & personnalis&eacute; (.pbo)</span><span class='code-badge'>PBO</span></div>" +
  "  <pre><code><span class='kw'>Using</span> <span class='tp'>UI</span>" + #CRLF$ +
  #CRLF$ +
  "<span class='cm'>; 1. Cr&eacute;ation simple pour un layout</span>" + #CRLF$ +
  "<span class='kw'>Define</span> *btnValider.<span class='tp'>Button</span> = <span class='kw'>New</span> <span class='tp'>Button</span>(<span class='str'>'Valider'</span>)" + #CRLF$ +
  "*stackPanel\\<span class='fn'>AddChild</span>(*btnValider)" + #CRLF$ +
  #CRLF$ +
  "<span class='cm'>; 2. Bouton personnalis&eacute; avec logique de clic</span>" + #CRLF$ +
  "<span class='kw'>Class</span> MonBouton <span class='kw'>Extends</span> <span class='tp'>Button</span> {" + #CRLF$ +
  "  <span class='kw'>Public</span> <span class='kw'>Method</span> <span class='fn'>OnClick</span>() {" + #CRLF$ +
  "    <span class='fn'>MessageRequester</span>(<span class='str'>'Info'</span>, <span class='str'>'Clic sur '</span> + <span class='kw'>This</span>\\<span class='fn'>GetText</span>())" + #CRLF$ +
  "  }" + #CRLF$ +
  "}"</code></pre>" +
  "</div>" +
  "</div>"

SaveHTML(BaseDocDir + "fr\ui\button.html", BuildPage("fr", "button", "ui/button.html", "Classe Button", "Contr&ocirc;le bouton poussoir cliquable avec multi-constructeurs et gestion d'&eacute;v&eacute;nements.", "badge-ui", "UI Class", fr_button))

; FR UI: TextBox
Define fr_textbox.s = "<div class='doc-section'>" +
  "<h2 class='section-title'>Description</h2>" +
  "<p>La classe <code>UI::TextBox</code> encapsule un champ de saisie texte (<code>StringGadget</code>) avec acc&egrave;s direct au texte, validation et &eacute;v&eacute;nement <code>OnChange()</code>.</p>" +
  "</div>" +
  "<div class='doc-section'>" +
  "<h2 class='section-title'>Constructeurs Surcharg&eacute;s</h2>" +
  "<div class='table-wrapper'>" +
  "  <table>" +
  "    <tr><th>Constructeur</th><th>Description</th></tr>" +
  "    <tr><td><code>Init()</code></td><td>Champ vide (150&times;25 par d&eacute;faut).</td></tr>" +
  "    <tr><td><code>Init(defaultText.s)</code></td><td>Champ initialis&eacute; avec le texte par d&eacute;faut.</td></tr>" +
  "    <tr><td><code>Init(defaultText.s, w.i, h.i)</code></td><td>Champ avec texte et dimensions souhait&eacute;es.</td></tr>" +
  "    <tr><td><code>Init(x.i, y.i, w.i, h.i, defaultText.s)</code></td><td>Positionnement absolu, dimensions et texte.</td></tr>" +
  "    <tr><td><code>Init(x.i, y.i, w.i, h.i, defaultText.s, flags.i)</code></td><td>Complet avec flags PureBasic (ex: <code>#PB_String_Password</code>, <code>#PB_String_Numeric</code>, <code>#PB_String_ReadOnly</code>).</td></tr>" +
  "  </table>" +
  "</div>" +
  "</div>" +
  "<div class='doc-section'>" +
  "<h2 class='section-title'>M&eacute;thodes Principales</h2>" +
  "<div class='table-wrapper'>" +
  "  <table>" +
  "    <tr><th>M&eacute;thode</th><th>Description</th></tr>" +
  "    <tr><td><code>GetText()</code> / <code>SetText(str.s)</code></td><td>Lecture et modification du contenu textuel.</td></tr>" +
  "    <tr><td><code>SetReadOnly(state.b)</code> / <code>IsReadOnly()</code></td><td>Verrouille le champ en lecture seule.</td></tr>" +
  "    <tr><td><code>OnChange()</code></td><td>M&eacute;thode virtuelle d&eacute;clench&eacute;e &agrave; chaque frappe au clavier.</td></tr>" +
  "  </table>" +
  "</div>" +
  "</div>"

SaveHTML(BaseDocDir + "fr\ui\textbox.html", BuildPage("fr", "textbox", "ui/textbox.html", "Classe TextBox", "Champ de saisie texte avec multi-constructeurs et &eacute;v&eacute;nement OnChange.", "badge-ui", "UI Class", fr_textbox))

; FR UI: Label
Define fr_label.s = "<div class='doc-section'>" +
  "<h2 class='section-title'>Description</h2>" +
  "<p>La classe <code>UI::Label</code> encapsule un texte statique d'interface (<code>TextGadget</code>) avec styles et alignements.</p>" +
  "</div>" +
  "<div class='doc-section'>" +
  "<h2 class='section-title'>Constructeurs Surcharg&eacute;s</h2>" +
  "<div class='table-wrapper'>" +
  "  <table>" +
  "    <tr><th>Constructeur</th><th>Description</th></tr>" +
  "    <tr><td><code>Init(text.s)</code></td><td>Texte statique (dimensions automatiques pour layout).</td></tr>" +
  "    <tr><td><code>Init(text.s, w.i, h.i)</code></td><td>Texte et dimensions personnalis&eacute;es.</td></tr>" +
  "    <tr><td><code>Init(x.i, y.i, w.i, h.i, text.s)</code></td><td>Positionnement absolu, dimensions et texte.</td></tr>" +
  "    <tr><td><code>Init(x.i, y.i, w.i, h.i, text.s, flags.i)</code></td><td>Complet avec flags d'alignement (<code>#PB_Text_Center</code>, <code>#PB_Text_Right</code>, <code>#PB_Text_Border</code>).</td></tr>" +
  "  </table>" +
  "</div>" +
  "</div>"

SaveHTML(BaseDocDir + "fr\ui\label.html", BuildPage("fr", "label", "ui/label.html", "Classe Label", "Libell&eacute; texte statique avec multi-constructeurs et alignements.", "badge-ui", "UI Class", fr_label))

; FR UI: CheckBox
Define fr_checkbox.s = "<div class='doc-section'>" +
  "<h2 class='section-title'>Description</h2>" +
  "<p>La classe <code>UI::CheckBox</code> encapsule une case &agrave; cocher bool&eacute;enne avec &eacute;tats actif/inactif et callback <code>OnClick()</code>.</p>" +
  "</div>" +
  "<div class='doc-section'>" +
  "<h2 class='section-title'>Constructeurs Surcharg&eacute;s</h2>" +
  "<div class='table-wrapper'>" +
  "  <table>" +
  "    <tr><th>Constructeur</th><th>Description</th></tr>" +
  "    <tr><td><code>Init(text.s)</code></td><td>Case &agrave; cocher d&eacute;coch&eacute;e par d&eacute;faut (150&times;25).</td></tr>" +
  "    <tr><td><code>Init(text.s, checked.b)</code></td><td>Case avec texte et &eacute;tat initial sp&eacute;cifi&eacute;.</td></tr>" +
  "    <tr><td><code>Init(text.s, w.i, h.i, checked.b)</code></td><td>Case avec texte, dimensions et &eacute;tat initial.</td></tr>" +
  "    <tr><td><code>Init(x.i, y.i, w.i, h.i, text.s, flags.i)</code></td><td>Complet avec position absolue et flags.</td></tr>" +
  "  </table>" +
  "</div>" +
  "</div>" +
  "<div class='doc-section'>" +
  "<h2 class='section-title'>M&eacute;thodes Principales</h2>" +
  "<div class='table-wrapper'>" +
  "  <table>" +
  "    <tr><th>M&eacute;thode</th><th>Description</th></tr>" +
  "    <tr><td><code>IsChecked()</code></td><td>Renvoie <code>#True</code> si coch&eacute;e, <code>#False</code> sinon.</td></tr>" +
  "    <tr><td><code>SetChecked(state.b)</code></td><td>Modifie l'&eacute;tat de la case &agrave; cocher.</td></tr>" +
  "  </table>" +
  "</div>" +
  "</div>"

SaveHTML(BaseDocDir + "fr\ui\checkbox.html", BuildPage("fr", "checkbox", "ui/checkbox.html", "Classe CheckBox", "Case &agrave; cocher bool&eacute;enne avec multi-constructeurs et gestion d'&eacute;tat.", "badge-ui", "UI Class", fr_checkbox))

; FR UI: ComboBox
Define fr_combobox.s = "<div class='doc-section'>" +
  "<h2 class='section-title'>Description</h2>" +
  "<p>La classe <code>UI::ComboBox</code> encapsule une liste d&eacute;roulante s&eacute;lectionnable avec &eacute;v&eacute;nement <code>OnChange()</code>.</p>" +
  "</div>" +
  "<div class='doc-section'>" +
  "<h2 class='section-title'>Constructeurs Surcharg&eacute;s</h2>" +
  "<div class='table-wrapper'>" +
  "  <table>" +
  "    <tr><th>Constructeur</th><th>Description</th></tr>" +
  "    <tr><td><code>Init()</code></td><td>Liste d&eacute;roulante par d&eacute;faut (150&times;25).</td></tr>" +
  "    <tr><td><code>Init(w.i, h.i)</code></td><td>Dimensions personnalis&eacute;es.</td></tr>" +
  "    <tr><td><code>Init(x.i, y.i, w.i, h.i)</code></td><td>Position absolue et dimensions.</td></tr>" +
  "    <tr><td><code>Init(x.i, y.i, w.i, h.i, flags.i)</code></td><td>Complet avec flags PureBasic (ex: <code>#PB_ComboBox_Editable</code>, <code>#PB_ComboBox_LowerCase</code>).</td></tr>" +
  "  </table>" +
  "</div>" +
  "</div>" +
  "<div class='doc-section'>" +
  "<h2 class='section-title'>M&eacute;thodes Principales</h2>" +
  "<div class='table-wrapper'>" +
  "  <table>" +
  "    <tr><th>M&eacute;thode</th><th>Description</th></tr>" +
  "    <tr><td><code>AddItem(text.s)</code></td><td>Ajoute un &eacute;l&eacute;ment &agrave; la fin de la liste.</td></tr>" +
  "    <tr><td><code>GetSelectedIndex()</code> / <code>SetSelectedIndex(idx.i)</code></td><td>Index de l'&eacute;l&eacute;ment actif (0 &agrave; N-1, ou -1 si aucun).</td></tr>" +
  "    <tr><td><code>GetSelectedItem()</code></td><td>Renvoie le texte de l'&eacute;l&eacute;ment actuellement s&eacute;lectionn&eacute;.</td></tr>" +
  "    <tr><td><code>Clear()</code></td><td>Vide tous les &eacute;l&eacute;ments de la liste.</td></tr>" +
  "  </table>" +
  "</div>" +
  "</div>"

SaveHTML(BaseDocDir + "fr\ui\combobox.html", BuildPage("fr", "combobox", "ui/combobox.html", "Classe ComboBox", "Liste d&eacute;roulante s&eacute;lectionnable avec multi-constructeurs.", "badge-ui", "UI Class", fr_combobox))

; FR UI: ListIcon
Define fr_listicon.s = "<div class='doc-section'>" +
  "<h2 class='section-title'>Description</h2>" +
  "<p>La classe <code>UI::ListIcon</code> encapsule une table / grille de donn&eacute;es multi-colonnes (<code>ListIconGadget</code>) avec s&eacute;lection de ligne et gestion d'&eacute;v&eacute;nements.</p>" +
  "</div>" +
  "<div class='doc-section'>" +
  "<h2 class='section-title'>Constructeurs Surcharg&eacute;s</h2>" +
  "<div class='table-wrapper'>" +
  "  <table>" +
  "    <tr><th>Constructeur</th><th>Description</th></tr>" +
  "    <tr><td><code>Init(title.s, colWidth.i)</code></td><td>Cr&eacute;e la table avec sa premi&egrave;re colonne (pleine ligne s&eacute;lectionnable par d&eacute;faut).</td></tr>" +
  "    <tr><td><code>Init(title.s, colWidth.i, flags.i)</code></td><td>Cr&eacute;ation avec flags personnalis&eacute;s (<code>#PB_ListIcon_GridLines</code>, <code>#PB_ListIcon_CheckBoxes</code>, etc.).</td></tr>" +
  "    <tr><td><code>Init(x.i, y.i, w.i, h.i, title.s, colWidth.i)</code></td><td>Positionnement absolu et dimensions.</td></tr>" +
  "    <tr><td><code>Init(x.i, y.i, w.i, h.i, title.s, colWidth.i, flags.i)</code></td><td>Complet avec position, dimensions, titre de colonne et flags.</td></tr>" +
  "  </table>" +
  "</div>" +
  "</div>" +
  "<div class='doc-section'>" +
  "<h2 class='section-title'>M&eacute;thodes Principales</h2>" +
  "<div class='table-wrapper'>" +
  "  <table>" +
  "    <tr><th>M&eacute;thode</th><th>Description</th></tr>" +
  "    <tr><td><code>AddColumn(colIdx.i, title.s, width.i)</code></td><td>Ajoute une nouvelle colonne &agrave; la table.</td></tr>" +
  "    <tr><td><code>AddItem(text.s, icon.i = 0, itemIdx.i = -1)</code></td><td>Ins&egrave;re une nouvelle ligne (champs s&eacute;par&eacute;s par <code>Chr(10)</code>).</td></tr>" +
  "    <tr><td><code>GetSelectedIndex()</code> / <code>SetSelectedIndex(idx.i)</code></td><td>Index de la ligne active (-1 si aucune).</td></tr>" +
  "    <tr><td><code>GetItemText(itemIdx.i, colIdx.i = 0)</code></td><td>R&eacute;cup&egrave;re le texte d'une cellule sp&eacute;cifique.</td></tr>" +
  "    <tr><td><code>SetItemText(itemIdx.i, colIdx.i, text.s)</code></td><td>Modifie le texte d'une cellule sp&eacute;cifique.</td></tr>" +
  "    <tr><td><code>GetItemCount()</code></td><td>Nombre total de lignes dans la table.</td></tr>" +
  "    <tr><td><code>Clear()</code></td><td>Supprime toutes les lignes.</td></tr>" +
  "    <tr><td><code>RemoveItem(idx.i)</code></td><td>Supprime une ligne sp&eacute;cifique.</td></tr>" +
  "  </table>" +
  "</div>" +
  "</div>"

SaveHTML(BaseDocDir + "fr\ui\listicon.html", BuildPage("fr", "listicon", "ui/listicon.html", "Classe ListIcon", "Table et grille de donn&eacute;es multi-colonnes avec multi-constructeurs.", "badge-ui", "UI Class", fr_listicon))

; FR UI: ProgressBar
Define fr_progressbar.s = "<div class='doc-section'>" +
  "<h2 class='section-title'>Description</h2>" +
  "<p>La classe <code>UI::ProgressBar</code> fournit une barre de progression visuelle pour le suivi des traitements.</p>" +
  "</div>" +
  "<div class='doc-section'>" +
  "<h2 class='section-title'>Constructeurs Surcharg&eacute;s</h2>" +
  "<div class='table-wrapper'>" +
  "  <table>" +
  "    <tr><th>Constructeur</th><th>Description</th></tr>" +
  "    <tr><td><code>Init()</code></td><td>Plage par d&eacute;faut 0..100 (200&times;25).</td></tr>" +
  "    <tr><td><code>Init(min.i, max.i)</code></td><td>Plage minimale et maximale sp&eacute;cifi&eacute;es.</td></tr>" +
  "    <tr><td><code>Init(min.i, max.i, w.i, h.i)</code></td><td>Plage et dimensions souhait&eacute;es.</td></tr>" +
  "    <tr><td><code>Init(x.i, y.i, w.i, h.i, min.i, max.i, flags.i)</code></td><td>Complet avec position absolue, plage et flags (<code>#PB_ProgressBar_Smooth</code>, <code>#PB_ProgressBar_Vertical</code>).</td></tr>" +
  "  </table>" +
  "</div>" +
  "</div>" +
  "<div class='doc-section'>" +
  "<h2 class='section-title'>M&eacute;thodes Principales</h2>" +
  "<div class='table-wrapper'>" +
  "  <table>" +
  "    <tr><th>M&eacute;thode</th><th>Description</th></tr>" +
  "    <tr><td><code>GetValue()</code></td><td>Renvoie la valeur actuelle de progression.</td></tr>" +
  "    <tr><td><code>SetValue(v.i)</code></td><td>Met &agrave; jour la valeur de progression.</td></tr>" +
  "  </table>" +
  "</div>" +
  "</div>"

SaveHTML(BaseDocDir + "fr\ui\progressbar.html", BuildPage("fr", "progressbar", "ui/progressbar.html", "Classe ProgressBar", "Indicateur visuel d'avancement avec multi-constructeurs.", "badge-ui", "UI Class", fr_progressbar))

; FR UI: Slider
Define fr_slider.s = "<div class='doc-section'>" +
  "<h2 class='section-title'>Description</h2>" +
  "<p>La classe <code>UI::Slider</code> encapsule un curseur de r&eacute;glage lin&eacute;aire (<code>TrackBarGadget</code>).</p>" +
  "</div>" +
  "<div class='doc-section'>" +
  "<h2 class='section-title'>Constructeurs Surcharg&eacute;s</h2>" +
  "<div class='table-wrapper'>" +
  "  <table>" +
  "    <tr><th>Constructeur</th><th>Description</th></tr>" +
  "    <tr><td><code>Init()</code></td><td>Plage par d&eacute;faut 0..100 (200&times;25).</td></tr>" +
  "    <tr><td><code>Init(min.i, max.i)</code></td><td>Plage minimale et maximale sp&eacute;cifi&eacute;es.</td></tr>" +
  "    <tr><td><code>Init(min.i, max.i, w.i, h.i)</code></td><td>Plage et dimensions souhait&eacute;es.</td></tr>" +
  "    <tr><td><code>Init(x.i, y.i, w.i, h.i, min.i, max.i, flags.i)</code></td><td>Complet avec position absolue, plage et flags (<code>#PB_TrackBar_Ticks</code>, <code>#PB_TrackBar_Vertical</code>).</td></tr>" +
  "  </table>" +
  "</div>" +
  "</div>" +
  "<div class='doc-section'>" +
  "<h2 class='section-title'>M&eacute;thodes Principales</h2>" +
  "<div class='table-wrapper'>" +
  "  <table>" +
  "    <tr><th>M&eacute;thode</th><th>Description</th></tr>" +
  "    <tr><td><code>GetValue()</code></td><td>Renvoie la position actuelle du curseur.</td></tr>" +
  "    <tr><td><code>SetValue(v.i)</code></td><td>Modifie la position du curseur.</td></tr>" +
  "  </table>" +
  "</div>" +
  "</div>"

SaveHTML(BaseDocDir + "fr\ui\slider.html", BuildPage("fr", "slider", "ui/slider.html", "Classe Slider", "Curseur de r&eacute;glage lin&eacute;aire avec multi-constructeurs.", "badge-ui", "UI Class", fr_slider))

; FR UI: ToggleSwitch
Define fr_toggleswitch.s = "<div class='doc-section'>" +
  "<h2 class='section-title'>Description</h2>" +
  "<p>La classe <code>UI::Controls::ToggleSwitch</code> est un contr&ocirc;le moderne vectoriel (<code>CustomGadget</code> sur Canvas) repr&eacute;sentant un interrupteur style iOS / Material.</p>" +
  "</div>" +
  "<div class='doc-section'>" +
  "<h2 class='section-title'>Constructeurs Surcharg&eacute;s</h2>" +
  "<div class='table-wrapper'>" +
  "  <table>" +
  "    <tr><th>Constructeur</th><th>Description</th></tr>" +
  "    <tr><td><code>Init()</code></td><td>Interrupteur d&eacute;sactiv&eacute; par d&eacute;faut (50&times;26).</td></tr>" +
  "    <tr><td><code>Init(checked.b)</code></td><td>&Eacute;tat initial activ&eacute; / d&eacute;sactiv&eacute;.</td></tr>" +
  "    <tr><td><code>Init(w.i, h.i, checked.b)</code></td><td>Dimensions et &eacute;tat initial.</td></tr>" +
  "    <tr><td><code>Init(x.i, y.i, w.i, h.i, checked.b)</code></td><td>Position absolue, dimensions et &eacute;tat initial.</td></tr>" +
  "  </table>" +
  "</div>" +
  "</div>" +
  "<div class='doc-section'>" +
  "<h2 class='section-title'>M&eacute;thodes Principales</h2>" +
  "<div class='table-wrapper'>" +
  "  <table>" +
  "    <tr><th>M&eacute;thode</th><th>Description</th></tr>" +
  "    <tr><td><code>IsChecked()</code></td><td>Renvoie <code>#True</code> si activ&eacute;, <code>#False</code> sinon.</td></tr>" +
  "    <tr><td><code>SetChecked(state.b)</code></td><td>Modifie l'&eacute;tat et redessine le composant.</td></tr>" +
  "    <tr><td><code>OnChange()</code></td><td>Callback virtuel d&eacute;clench&eacute; lors du basculement.</td></tr>" +
  "  </table>" +
  "</div>" +
  "</div>"

SaveHTML(BaseDocDir + "fr\ui\toggleswitch.html", BuildPage("fr", "toggleswitch", "ui/toggleswitch.html", "Classe ToggleSwitch", "Interrupteur vectoriel moderne (Style iOS) avec multi-constructeurs.", "badge-ui", "UI Class", fr_toggleswitch))

; FR UI: Layouts Container
Define fr_container.s = "<div class='doc-section'>" +
  "<h2 class='section-title'>Description</h2>" +
  "<p>La classe <code>UI::Layouts::Container</code> est la classe abstraite fondatrice de tout le syst&egrave;me de disposition responsive de PureBasic OOP. Inspir&eacute;e du mod&egrave;le WPF / XAML de .NET, elle permet de cr&eacute;er des interfaces graphiques modernes qui s'adaptent automatiquement &agrave; toutes les r&eacute;solutions d'&eacute;cran et aux redimensionnements de fen&ecirc;tres.</p>" +
  "<p>Elle impl&eacute;mente le cycle de mise en page automatique (<code>Arrange</code>) et g&egrave;re les marges int&eacute;rieures (<code>Padding</code>) ainsi que la collection de composants enfants.</p>" +
  "</div>" +
  "<div class='doc-section'>" +
  "<h2 class='section-title'>Constructeurs Surcharg&eacute;s</h2>" +
  "<div class='table-wrapper'>" +
  "  <table>" +
  "    <tr><th>Constructeur</th><th>Description</th></tr>" +
  "    <tr><td><code>Init()</code></td><td>Conteneur par d&eacute;faut (stretch horizontal et vertical).</td></tr>" +
  "    <tr><td><code>Init(w.i, h.i)</code></td><td>Conteneur avec dimensions initiales.</td></tr>" +
  "    <tr><td><code>Init(x.i, y.i, w.i, h.i)</code></td><td>Conteneur avec position absolue et dimensions.</td></tr>" +
  "  </table>" +
  "</div>" +
  "</div>" +
  "<div class='doc-section'>" +
  "<h2 class='section-title'>M&eacute;thodes de Container</h2>" +
  "<div class='table-wrapper'>" +
  "  <table>" +
  "    <tr><th>M&eacute;thode</th><th>Description</th></tr>" +
  "    <tr><td><code>AddChild(*child)</code></td><td>Ajoute un composant enfant &agrave; la disposition.</td></tr>" +
  "    <tr><td><code>RemoveChild(*child)</code></td><td>Retire un composant enfant.</td></tr>" +
  "    <tr><td><code>ClearChildren()</code></td><td>Supprime tous les composants enfants.</td></tr>" +
  "    <tr><td><code>SetPadding(l, t, r, b)</code></td><td>D&eacute;finit les marges internes en pixels.</td></tr>" +
  "    <tr><td><code>SetPaddingAll(p)</code></td><td>D&eacute;finit une marge interne uniforme.</td></tr>" +
  "    <tr><td><code>Arrange(x, y, w, h)</code></td><td>Recalcule le positionnement de tous les enfants.</td></tr>" +
  "  </table>" +
  "</div>" +
  "</div>"

SaveHTML(BaseDocDir + "fr\ui\container.html", BuildPage("fr", "container", "ui/container.html", "Classe Container", "Classe de base abstraite pour tous les panneaux de disposition responsive WPF.", "badge-ui", "Layout", fr_container))

; FR UI: StackPanel
Define fr_stackpanel.s = "<div class='doc-section'>" +
  "<h2 class='section-title'>Description</h2>" +
  "<p>La classe <code>UI::Layouts::StackPanel</code> dispose ses composants enfants sur une seule ligne s&eacute;quentielle, orient&eacute;e soit verticalement (de haut en bas), soit horizontalement (de gauche &agrave; droite).</p>" +
  "<p>Un espacement constant (<code>Spacing</code>) peut &ecirc;tre configur&eacute; entre chaque &eacute;l&eacute;ment cons&eacute;cutif.</p>" +
  "</div>" +
  "<div class='doc-section'>" +
  "<h2 class='section-title'>Constructeurs Surcharg&eacute;s</h2>" +
  "<div class='table-wrapper'>" +
  "  <table>" +
  "    <tr><th>Constructeur</th><th>Description</th></tr>" +
  "    <tr><td><code>Init()</code></td><td>StackPanel vertical avec espacement de 5 pixels par d&eacute;faut.</td></tr>" +
  "    <tr><td><code>Init(orientation.i)</code></td><td>StackPanel avec orientation choisie (<code>#UI_Orientation_Vertical</code> ou <code>#UI_Orientation_Horizontal</code>).</td></tr>" +
  "    <tr><td><code>Init(orientation.i, spacing.i)</code></td><td>Orientation et espacement personnalis&eacute;s.</td></tr>" +
  "    <tr><td><code>Init(orientation.i, spacing.i, w.i, h.i)</code></td><td>Orientation, espacement et dimensions sp&eacute;cifi&eacute;es.</td></tr>" +
  "  </table>" +
  "</div>" +
  "</div>" +
  "<div class='doc-section'>" +
  "<h2 class='section-title'>Exemple d'utilisation</h2>" +
  "<div class='code-container'>" +
  "  <div class='code-header'><span class='code-title'>StackPanel vertical (.pbo)</span><span class='code-badge'>PBO</span></div>" +
  "  <pre><code><span class='kw'>Define</span> *panel.<span class='tp'>StackPanel</span> = <span class='kw'>New</span> <span class='tp'>StackPanel</span>(#UI_Orientation_Vertical, <span class='num'>10</span>)" + #CRLF$ +
  "*panel\\<span class='fn'>SetPaddingAll</span>(<span class='num'>15</span>)" + #CRLF$ +
  "*panel\\<span class='fn'>AddChild</span>(<span class='kw'>New</span> <span class='tp'>Button</span>(<span class='str'>'Premier Bouton'</span>))" + #CRLF$ +
  "*panel\\<span class='fn'>AddChild</span>(<span class='kw'>New</span> <span class='tp'>Button</span>(<span class='str'>'Deuxi&egrave;me Bouton'</span>))" + #CRLF$ +
  "*win\\<span class='fn'>SetRootComponent</span>(*panel)</code></pre>" +
  "</div>" +
  "</div>"

SaveHTML(BaseDocDir + "fr\ui\stackpanel.html", BuildPage("fr", "stackpanel", "ui/stackpanel.html", "Classe StackPanel", "Disposition lin&eacute;aire automatique verticale ou horizontale avec multi-constructeurs.", "badge-ui", "Layout", fr_stackpanel))

; FR UI: DockPanel
Define fr_dockpanel.s = "<div class='doc-section'>" +
  "<h2 class='section-title'>Description</h2>" +
  "<p>La classe <code>UI::Layouts::DockPanel</code> ancre ses composants enfants le long de ses 4 bordures ext&eacute;rieures (Haut, Bas, Gauche, Droite) et attribue automatiquement tout l'espace r&eacute;siduel au centre &agrave; son dernier enfant (propri&eacute;t&eacute; <code>LastChildFill</code>).</p>" +
  "</div>" +
  "<div class='doc-section'>" +
  "<h2 class='section-title'>Constructeurs Surcharg&eacute;s</h2>" +
  "<div class='table-wrapper'>" +
  "  <table>" +
  "    <tr><th>Constructeur</th><th>Description</th></tr>" +
  "    <tr><td><code>Init()</code></td><td>DockPanel avec <code>LastChildFill = #True</code> par d&eacute;faut.</td></tr>" +
  "    <tr><td><code>Init(lastChildFill.b)</code></td><td>Activation ou non du remplissage central automatique pour le dernier enfant.</td></tr>" +
  "    <tr><td><code>Init(lastChildFill.b, w.i, h.i)</code></td><td>Remplissage central et dimensions sp&eacute;cifi&eacute;es.</td></tr>" +
  "  </table>" +
  "</div>" +
  "</div>" +
  "<div class='doc-section'>" +
  "<h2 class='section-title'>Constantes d'Ancrage</h2>" +
  "<div class='table-wrapper'>" +
  "  <table>" +
  "    <tr><th>Constante</th><th>Description</th></tr>" +
  "    <tr><td><code>#UI_Dock_Top</code></td><td>Ancre le composant en haut en occupant toute la largeur.</td></tr>" +
  "    <tr><td><code>#UI_Dock_Bottom</code></td><td>Ancre le composant en bas en occupant toute la largeur.</td></tr>" +
  "    <tr><td><code>#UI_Dock_Left</code></td><td>Ancre le composant &agrave; gauche sur la hauteur r&eacute;siduelle.</td></tr>" +
  "    <tr><td><code>#UI_Dock_Right</code></td><td>Ancre le composant &agrave; droite sur la hauteur r&eacute;siduelle.</td></tr>" +
  "    <tr><td><code>#UI_Dock_Fill</code></td><td>Occupe la totalit&eacute; de l'espace central disponible.</td></tr>" +
  "  </table>" +
  "</div>" +
  "</div>"

SaveHTML(BaseDocDir + "fr\ui\dockpanel.html", BuildPage("fr", "dockpanel", "ui/dockpanel.html", "Classe DockPanel", "Disposition par ancrage sur les bords et remplissage central.", "badge-ui", "Layout", fr_dockpanel))

; FR UI: Grid
Define fr_grid.s = "<div class='doc-section'>" +
  "<h2 class='section-title'>Description</h2>" +
  "<p>La classe <code>UI::Layouts::Grid</code> d&eacute;finit une grille 2D flexible en lignes et colonnes, avec dimensionnement en pixels, <code>'Auto'</code> ou proportionnel Star (<code>'*'</code>, <code>'2*'</code>).</p>" +
  "</div>" +
  "<div class='doc-section'>" +
  "<h2 class='section-title'>Constructeurs Surcharg&eacute;s</h2>" +
  "<div class='table-wrapper'>" +
  "  <table>" +
  "    <tr><th>Constructeur</th><th>Description</th></tr>" +
  "    <tr><td><code>Init()</code></td><td>Grille 2D r&eacute;active par d&eacute;faut.</td></tr>" +
  "    <tr><td><code>Init(w.i, h.i)</code></td><td>Grille 2D avec dimensions initiales.</td></tr>" +
  "  </table>" +
  "</div>" +
  "</div>" +
  "<div class='doc-section'>" +
  "<h2 class='section-title'>Exemple d'utilisation</h2>" +
  "<div class='code-container'>" +
  "  <div class='code-header'><span class='code-title'>Grille avec Star Sizing (.pbo)</span><span class='code-badge'>PBO</span></div>" +
  "  <pre><code><span class='kw'>Define</span> *grid.<span class='tp'>Grid</span> = <span class='kw'>New</span> <span class='tp'>Grid</span>()" + #CRLF$ +
  "*grid\\<span class='fn'>AddColumn</span>(<span class='str'>'200'</span>)  <span class='cm'>; Colonne 0: 200px fixe</span>" + #CRLF$ +
  "*grid\\<span class='fn'>AddColumn</span>(<span class='str'>'3*'</span>)   <span class='cm'>; Colonne 1: 75% largeur restante</span>" + #CRLF$ +
  "*grid\\<span class='fn'>AddColumn</span>(<span class='str'>'1*'</span>)   <span class='cm'>; Colonne 2: 25% largeur restante</span>" + #CRLF$ +
  "*grid\\<span class='fn'>AddRow</span>(<span class='str'>'50'</span>)      <span class='cm'>; Ligne 0: 50px en-t&ecirc;te</span>" + #CRLF$ +
  "*grid\\<span class='fn'>AddRow</span>(<span class='str'>'*'</span>)       <span class='cm'>; Ligne 1: Contenu fluide</span>" + #CRLF$ +
  #CRLF$ +
  "*grid\\<span class='fn'>SetCell</span>(*sidebar, <span class='num'>0</span>, <span class='num'>0</span>, <span class='num'>2</span>, <span class='num'>1</span>) <span class='cm'>; RowSpan=2</span>" + #CRLF$ +
  "*grid\\<span class='fn'>SetCell</span>(*mainView, <span class='num'>1</span>, <span class='num'>1</span>)" + #CRLF$ +
  "*win\\<span class='fn'>SetRootComponent</span>(*grid)</code></pre>" +
  "</div>" +
  "</div>"

SaveHTML(BaseDocDir + "fr\ui\grid.html", BuildPage("fr", "grid", "ui/grid.html", "Classe Grid", "Grille responsive 2D avec dimensionnement en pixels, Auto et Star (*).", "badge-ui", "Layout", fr_grid))
; ============================================================================
; 2. ENGLISH PAGES
; ============================================================================

; EN Index
Define en_index.s = "<div class='doc-section'>" +
  "<h2 class='section-title'>Welcome to PureBasic OOP</h2>" +
  "<p>PureBasic OOP brings full Object-Oriented Programming capabilities to PureBasic through an optimized transpiler and a native modern UI framework.</p>" +
  "<div class='callout callout-tip'>" +
  "  <div class='callout-title'>&#128640; Contextual F1 Help Key</div>" +
  "  <p>Inside the IDE, place your cursor on any OOP keyword (<code>Class</code>, <code>Method</code>, <code>Super</code>, <code>Property</code>...) or UI class (<code>Window</code>, <code>Button</code>, <code>Application</code>...) and press <strong>F1</strong> to instantly open its dedicated help page!</p>" +
  "</div>" +
  "</div>" +
  "<div class='doc-section'>" +
  "<h2 class='section-title'>Documentation Categories</h2>" +
  "<div class='cards-grid'>" +
  "  <a href='keywords/class.html' class='doc-card'>" +
  "    <div class='doc-card-title'><span>Class Declaration</span><span class='badge badge-keyword'>Class</span></div>" +
  "    <div class='doc-card-desc'>Concrete & abstract classes, inheritance, and dynamic polymorphism.</div>" +
  "  </a>" +
  "  <a href='keywords/method.html' class='doc-card'>" +
  "    <div class='doc-card-title'><span>Methods & Overriding</span><span class='badge badge-method'>Method</span></div>" +
  "    <div class='doc-card-desc'>Constructors, destructors, abstract methods, and VTable virtual dispatch.</div>" +
  "  </a>" +
  "  <a href='keywords/properties.html' class='doc-card'>" +
  "    <div class='doc-card-title'><span>Properties & Accessors</span><span class='badge badge-keyword'>Property</span></div>" +
  "    <div class='doc-card-desc'>Getters, Setters, and encapsulated property access.</div>" +
  "  </a>" +
  "  <a href='ui/application.html' class='doc-card'>" +
  "    <div class='doc-card-title'><span>UI Framework</span><span class='badge badge-ui'>UI</span></div>" +
  "    <div class='doc-card-desc'>Interface components: Application, Window, Button, ToggleSwitch, Slider...</div>" +
  "  </a>" +
  "  <a href='ui/container.html' class='doc-card'>" +
  "    <div class='doc-card-title'><span>Responsive Layouts (WPF)</span><span class='badge badge-ui'>WPF</span></div>" +
  "    <div class='doc-card-desc'>Adaptive layout containers: StackPanel, DockPanel, 2D Grid with star sizing...</div>" +
  "  </a>" +
  "</div>" +
  "</div>"

SaveHTML(BaseDocDir + "en\index.html", BuildPage("en", "index", "index.html", "PureBasic OOP Documentation", "Complete reference guide for Object-Oriented Programming and UI in PureBasic.", "badge-class", "Guide", en_index))

; EN Keyword: Class
Define en_class.s = "<div class='doc-section'>" +
  "<h2 class='section-title'>Description</h2>" +
  "  <div class='code-header'><span class='code-title'>Class declaration example (.pbo)</span><span class='code-badge'>PBO</span></div>" +
  "  <pre><code><span class='kw'>Class</span> <span class='tp'>Person</span>" + #CRLF$ +
  "  <span class='kw'>Protected</span> name.<span class='tp'>s</span>" + #CRLF$ +
  "  <span class='kw'>Protected</span> age.<span class='tp'>i</span>" + #CRLF$ +
  #CRLF$ +
  "  <span class='kw'>Public</span> <span class='kw'>Method</span> <span class='fn'>Init</span>(name_p.<span class='tp'>s</span>, age_p.<span class='tp'>i</span>)" + #CRLF$ +
  "    <span class='kw'>This</span>\\name = name_p" + #CRLF$ +
  "    <span class='kw'>This</span>\\age = age_p" + #CRLF$ +
  "  <span class='kw'>EndMethod</span>" + #CRLF$ +
  #CRLF$ +
  "  <span class='kw'>Public</span> <span class='kw'>Method</span>.<span class='tp'>s</span> <span class='fn'>GetName</span>()" + #CRLF$ +
  "    <span class='kw'>ProcedureReturn</span> <span class='kw'>This</span>\\name" + #CRLF$ +
  "  <span class='kw'>EndMethod</span>" + #CRLF$ +
  "<span class='kw'>EndClass</span></code></pre>" +
  "</div>" +
  "</div>"

SaveHTML(BaseDocDir + "en\keywords\class.html", BuildPage("en", "class", "keywords/class.html", "Class / Abstract Class", "Class declaration, encapsulation, and object modeling.", "badge-keyword", "Keyword", en_class))

; EN Keyword: Method
Define en_method.s = "<div class='doc-section'>" +
  "<h2 class='section-title'>Description</h2>" +
  "<p>The <code>Method</code> keyword declares a member function or procedure attached to a class. Methods can take parameters, return typed values, and access fields through <code>This</code>.</p>" +
  "<p>PureBasic OOP also supports <strong>Method Overloading</strong> and <strong>Multiple Constructors</strong> with different parameter types and arity.</p>" +
  "</div>" +
  "<div class='doc-section'>" +
  "<h2 class='section-title'>Constructors & Destructors</h2>" +
  "<ul>" +
  "  <li><code>Public Method Init(...)</code>: Constructor invoked automatically when instantiated with <code>New</code>. Multiple overloaded constructors are supported.</li>" +
  "  <li><code>Public Method Free()</code>: Destructor called upon object disposal with <code>FreeObject</code>.</li>" +
  "  <li><code>Public Abstract Method</code>: Method signature in an abstract class that must be implemented by concrete subclasses.</li>" +
  "</ul>" +
  "</div>"

SaveHTML(BaseDocDir + "en\keywords\method.html", BuildPage("en", "method", "keywords/method.html", "Method / EndMethod", "Instance methods, polymorphism, constructors, and destructors.", "badge-method", "Method", en_method))

; EN Keyword: Properties & others
SaveHTML(BaseDocDir + "en\keywords\properties.html", BuildPage("en", "properties", "keywords/properties.html", "Getter / Setter / Property", "Data encapsulation and property accessors.", "badge-keyword", "Property", "<p>Encapsulate private or protected field read/write access with <code>Getter</code> and <code>Setter</code> methods.</p>"))
SaveHTML(BaseDocDir + "en\keywords\inheritance.html", BuildPage("en", "inheritance", "keywords/inheritance.html", "Extends / Super", "Class inheritance and parent method invocation.", "badge-keyword", "Inheritance", "<p>Use <code>Extends</code> for single inheritance and <code>Super\\Method()</code> to call overridden base class implementations.</p>"))
SaveHTML(BaseDocDir + "en\keywords\encapsulation.html", BuildPage("en", "encapsulation", "keywords/encapsulation.html", "Public / Protected / Private", "Access control and member visibility.", "badge-keyword", "Access Control", "<p>Configure visibility using <code>Public</code>, <code>Protected</code>, or <code>Private</code> scopes.</p>"))
SaveHTML(BaseDocDir + "en\keywords\lifecycle.html", BuildPage("en", "lifecycle", "keywords/lifecycle.html", "New / Free / Lifecycle", "Object instantiation, initialization, and memory disposal.", "badge-keyword", "Lifecycle", "<p>Create instances using <code>NewObject(ClassName, ...)</code> and dispose of them with <code>FreeObject(*instance)</code>.</p>"))
SaveHTML(BaseDocDir + "en\keywords\operators.html", BuildPage("en", "operators", "keywords/operators.html", "This / Cast / TypeOf", "Context operators and object introspection.", "badge-keyword", "Operator", "<p>Use <code>This</code> for self-reference, <code>TypeOf(*obj)</code> for class reflection, and <code>InstanceOf</code> for type checking.</p>"))

; EN UI Components
SaveHTML(BaseDocDir + "en\ui\application.html", BuildPage("en", "application", "ui/application.html", "Application Class", "Global application manager and GUI event loop.", "badge-ui", "UI Class", "<p>Manages the application lifecycle and message dispatch with <code>Run()</code> and <code>Exit()</code>.</p>"))

; EN UI: Window
Define en_window.s = "<div class='doc-section'>" +
  "<h2 class='section-title'>Description</h2>" +
  "<p>The <code>UI::Window</code> class encapsulates a native PureBasic GUI window. Inheriting from <code>Component</code>, it provides comprehensive control over window coordinates, visibility, title, and virtual event handlers (close, resize, move).</p>" +
  "<p>Through <strong>Method Overloading</strong>, <strong>5 distinct constructors</strong> are available to instantiate windows quickly or with fine-grained configuration.</p>" +
  "</div>" +
  "<div class='doc-section'>" +
  "<h2 class='section-title'>Available Constructors (Overloaded Init)</h2>" +
  "<div class='table-wrapper'>" +
  "  <table>" +
  "    <tr><th>Constructor</th><th>Description & Default Behavior</th></tr>" +
  "    <tr><td><code>New Window(title.s)</code></td><td><strong>Quick Constructor:</strong> Creates an <strong>800 &times; 600</strong> window, <strong>centered on screen</strong> with standard system menu and minimize button.</td></tr>" +
  "    <tr><td><code>New Window(title.s, w.i, h.i)</code></td><td><strong>Sized Constructor:</strong> Creates a window of size <code>w &times; h</code>, <strong>centered on screen</strong>.</td></tr>" +
  "    <tr><td><code>New Window(title.s, w.i, h.i, flags.i)</code></td><td><strong>Custom Flags Constructor:</strong> Creates a centered <code>w &times; h</code> window with custom PureBasic window flags.</td></tr>" +
  "    <tr><td><code>New Window(title.s, x.i, y.i, w.i, h.i)</code></td><td><strong>Positioned Constructor:</strong> Creates a window positioned at absolute screen coordinates <code>(x, y)</code> with dimensions <code>w &times; h</code>.</td></tr>" +
  "    <tr><td><code>New Window(title.s, x.i, y.i, w.i, h.i, flags.i, parentID.i = 0)</code></td><td><strong>Full Constructor:</strong> Allows full control over all parameters including parent window ID for modal/child windows.</td></tr>" +
  "  </table>" +
  "</div>" +
  "</div>" +
  "<div class='doc-section'>" +
  "<h2 class='section-title'>Properties, Getters & Setters</h2>" +
  "<div class='table-wrapper'>" +
  "  <table>" +
  "    <tr><th>Property</th><th>Setter</th><th>Getter</th><th>Description</th></tr>" +
  "    <tr><td><strong>Title</strong></td><td><code>SetTitle(t.s)</code></td><td><code>GetTitle()</code></td><td>Updates or retrieves window title bar caption (<code>SetWindowTitle</code>).</td></tr>" +
  "    <tr><td><strong>X Position</strong></td><td><code>SetX(nx.i)</code></td><td><code>GetX()</code></td><td>Horizontal screen position in pixels (<code>WindowX</code> / <code>ResizeWindow</code>).</td></tr>" +
  "    <tr><td><strong>Y Position</strong></td><td><code>SetY(ny.i)</code></td><td><code>GetY()</code></td><td>Vertical screen position in pixels (<code>WindowY</code> / <code>ResizeWindow</code>).</td></tr>" +
  "    <tr><td><strong>Width</strong></td><td><code>SetWidth(nw.i)</code></td><td><code>GetWidth()</code></td><td>Client area width in pixels (<code>WindowWidth</code>).</td></tr>" +
  "    <tr><td><strong>Height</strong></td><td><code>SetHeight(nh.i)</code></td><td><code>GetHeight()</code></td><td>Client area height in pixels (<code>WindowHeight</code>).</td></tr>" +
  "    <tr><td><strong>Location (X, Y)</strong></td><td><code>SetLocation(x.i, y.i)</code></td><td>—</td><td>Moves the window to <code>(x, y)</code> without changing its size.</td></tr>" +
  "    <tr><td><strong>Size (W, H)</strong></td><td><code>SetSize(w.i, h.i)</code></td><td>—</td><td>Resizes client area to <code>w &times; h</code>.</td></tr>" +
  "    <tr><td><strong>Full Bounds</strong></td><td><code>SetPosition(x, y, w, h)</code></td><td>—</td><td>Updates position and dimensions in a single call.</td></tr>" +
  "    <tr><td><strong>Visibility</strong></td><td><code>SetVisible(v.b)</code></td><td><code>IsVisible()</code>, <code>GetVisible()</code></td><td>Shows (<code>#True</code>) or hides (<code>#False</code>) the window (<code>HideWindow</code>).</td></tr>" +
  "    <tr><td><strong>Enabled</strong></td><td><code>SetEnabled(e.b)</code></td><td><code>IsEnabled()</code>, <code>GetEnabled()</code></td><td>Enables or disables user interaction (<code>DisableWindow</code>).</td></tr>" +
  "    <tr><td><strong>Flags</strong></td><td><code>SetFlags(flags.i)</code></td><td><code>GetFlags()</code></td><td>PureBasic window creation flags.</td></tr>" +
  "    <tr><td><strong>Parent ID</strong></td><td><code>SetParentID(id.i)</code></td><td><code>GetParentID()</code></td><td>Parent window identifier.</td></tr>" +
  "    <tr><td><strong>Custom Tag / Data</strong></td><td><code>SetTag(s.s)</code> / <code>SetUserData(v.i)</code></td><td><code>GetTag()</code> / <code>GetUserData()</code></td><td>Custom metadata or user data pointer.</td></tr>" +
  "    <tr><td><strong>Native Handle</strong></td><td>—</td><td><code>GetID()</code>, <code>GetHandle()</code></td><td>Native PureBasic window ID integer.</td></tr>" +
  "  </table>" +
  "</div>" +
  "</div>" +
  "<div class='doc-section'>" +
  "<h2 class='section-title'>Complete Code Example</h2>" +
  "<div class='code-container'>" +
  "  <div class='code-header'><span class='code-title'>Example: Window creation and dynamic setters (.pbo)</span><span class='code-badge'>PBO</span></div>" +
  "  <pre><code><span class='kw'>XIncludeFile</span> <span class='str'>'ui/UI.pbo'</span>" + #CRLF$ +
  "<span class='kw'>Using</span> <span class='tp'>UI</span>" + #CRLF$ +
  #CRLF$ +
  "<span class='cm'>; 1. Fast instantiation (800x600 centered)</span>" + #CRLF$ +
  "<span class='kw'>Define</span> *myWin.<span class='tp'>Window</span> = <span class='kw'>New</span> <span class='tp'>Window</span>(<span class='str'>'My Application'</span>)" + #CRLF$ +
  #CRLF$ +
  "<span class='cm'>; 2. Dynamic customization using setters</span>" + #CRLF$ +
  "*myWin\\<span class='fn'>SetTitle</span>(<span class='str'>'Dashboard - Active Session'</span>)" + #CRLF$ +
  "*myWin\\<span class='fn'>SetSize</span>(<span class='num'>1024</span>, <span class='num'>768</span>)" + #CRLF$ +
  #CRLF$ +
  "<span class='cm'>; 3. Inspection via getters</span>" + #CRLF$ +
  "<span class='fn'>Debug</span> <span class='str'>'Current Width : '</span> + <span class='fn'>Str</span>(*myWin\\<span class='fn'>GetWidth</span>())" + #CRLF$ +
  "<span class='fn'>Debug</span> <span class='str'>'Current Height: '</span> + <span class='fn'>Str</span>(*myWin\\<span class='fn'>GetHeight</span>())" + #CRLF$ +
  #CRLF$ +
  "<span class='cm'>; 4. Cleanup and disposal</span>" + #CRLF$ +
  "*myWin\\<span class='fn'>Free</span>()</code></pre>" +
  "</div>" +
  "</div>"


; ============================================================================
; ENGLISH UI PAGES
; ============================================================================

; EN UI: Window
Define en_window.s = "<div class='doc-section'>" +
  "<h2 class='section-title'>Description</h2>" +
  "<p>The <code>UI::Window</code> class encapsulates a top-level native GUI window with multi-constructors, synchronized getters/setters, automated DPI-aware resizing, and virtual event lifecycle hooks (<code>OnClose()</code>, <code>OnResize()</code>...).</p>" +
  "</div>" +
  "<div class='doc-section'>" +
  "<h2 class='section-title'>Overloaded Constructors</h2>" +
  "<div class='table-wrapper'>" +
  "  <table>" +
  "    <tr><th>Constructor</th><th>Description</th></tr>" +
  "    <tr><td><code>Init(title.s)</code></td><td>Centered 800&times;600 window with minimize, maximize, and resize controls.</td></tr>" +
  "    <tr><td><code>Init(title.s, w.i, h.i)</code></td><td>Centered resizable window with custom width and height.</td></tr>" +
  "    <tr><td><code>Init(title.s, w.i, h.i, flags.i)</code></td><td>Window with custom dimensions and PureBasic flags.</td></tr>" +
  "    <tr><td><code>Init(title.s, x.i, y.i, w.i, h.i)</code></td><td>Window with absolute coordinates and dimensions.</td></tr>" +
  "    <tr><td><code>Init(title.s, x.i, y.i, w.i, h.i, flags.i)</code></td><td>Window with absolute coordinates, dimensions, and flags.</td></tr>" +
  "    <tr><td><code>Init(title.s, x.i, y.i, w.i, h.i, flags.i, parent.i)</code></td><td>Full window initialization with parent window ID.</td></tr>" +
  "  </table>" +
  "</div>" +
  "</div>"

SaveHTML(BaseDocDir + "en\ui\window.html", BuildPage("en", "window", "ui/window.html", "Window Class", "Flexible GUI window management with multi-constructors and dynamic setters.", "badge-ui", "UI Class", en_window))

; EN UI: Gadget / Component
Define en_gadget.s = "<div class='doc-section'>" +
  "<h2 class='section-title'>Description</h2>" +
  "<p>The abstract <code>UI::Component</code> and <code>UI::Gadget</code> classes form the foundation for all GUI controls and responsive layout panels.</p>" +
  "<p>They provide unified coordinate bounds (x, y, w, h), alignment constraints, margins, visibility, and event routing.</p>" +
  "</div>"

SaveHTML(BaseDocDir + "en\ui\gadget.html", BuildPage("en", "gadget", "ui/gadget.html", "Gadget & Component Classes", "Abstract base class for all UI controls and layout panels.", "badge-ui", "UI Class", en_gadget))

; EN UI: Button
Define en_button.s = "<div class='doc-section'>" +
  "<h2 class='section-title'>Description</h2>" +
  "<p>The <code>UI::Button</code> class encapsulates a clickable push button with multi-constructors and <code>OnClick()</code> virtual handler.</p>" +
  "</div>" +
  "<div class='doc-section'>" +
  "<h2 class='section-title'>Overloaded Constructors</h2>" +
  "<div class='table-wrapper'>" +
  "  <table>" +
  "    <tr><th>Constructor</th><th>Description</th></tr>" +
  "    <tr><td><code>Init(text.s)</code></td><td>Button with text (auto 120&times;30 default for layout containers).</td></tr>" +
  "    <tr><td><code>Init(text.s, w.i, h.i)</code></td><td>Button with text and custom dimensions.</td></tr>" +
  "    <tr><td><code>Init(x.i, y.i, w.i, h.i, text.s)</code></td><td>Absolute position, dimensions, and text.</td></tr>" +
  "    <tr><td><code>Init(x.i, y.i, w.i, h.i, text.s, flags.i)</code></td><td>Full constructor with PureBasic flags.</td></tr>" +
  "  </table>" +
  "</div>" +
  "</div>"

SaveHTML(BaseDocDir + "en\ui\button.html", BuildPage("en", "button", "ui/button.html", "Button Class", "Clickable push button with multi-constructors and event dispatch.", "badge-ui", "UI Class", en_button))

; EN UI: TextBox
Define en_textbox.s = "<div class='doc-section'>" +
  "<h2 class='section-title'>Description</h2>" +
  "<p>The <code>UI::TextBox</code> class encapsulates a single-line editable text input (<code>StringGadget</code>) with <code>OnChange()</code> notification.</p>" +
  "</div>" +
  "<div class='doc-section'>" +
  "<h2 class='section-title'>Overloaded Constructors</h2>" +
  "<div class='table-wrapper'>" +
  "  <table>" +
  "    <tr><th>Constructor</th><th>Description</th></tr>" +
  "    <tr><td><code>Init()</code></td><td>Empty text box (150&times;25 default).</td></tr>" +
  "    <tr><td><code>Init(defaultText.s)</code></td><td>Text box with default text.</td></tr>" +
  "    <tr><td><code>Init(defaultText.s, w.i, h.i)</code></td><td>Text box with default text and custom dimensions.</td></tr>" +
  "    <tr><td><code>Init(x.i, y.i, w.i, h.i, defaultText.s)</code></td><td>Absolute coordinates, dimensions, and default text.</td></tr>" +
  "    <tr><td><code>Init(x.i, y.i, w.i, h.i, defaultText.s, flags.i)</code></td><td>Full constructor with flags (Password, Numeric, ReadOnly).</td></tr>" +
  "  </table>" +
  "</div>" +
  "</div>"

SaveHTML(BaseDocDir + "en\ui\textbox.html", BuildPage("en", "textbox", "ui/textbox.html", "TextBox Class", "Text input field with multi-constructors and change events.", "badge-ui", "UI Class", en_textbox))

; EN UI: Label
Define en_label.s = "<div class='doc-section'>" +
  "<h2 class='section-title'>Description</h2>" +
  "<p>The <code>UI::Label</code> class displays static text with customizable alignments and styles.</p>" +
  "</div>" +
  "<div class='doc-section'>" +
  "<h2 class='section-title'>Overloaded Constructors</h2>" +
  "<div class='table-wrapper'>" +
  "  <table>" +
  "    <tr><th>Constructor</th><th>Description</th></tr>" +
  "    <tr><td><code>Init(text.s)</code></td><td>Static text label (auto-sized for layouts).</td></tr>" +
  "    <tr><td><code>Init(text.s, w.i, h.i)</code></td><td>Label with text and custom dimensions.</td></tr>" +
  "    <tr><td><code>Init(x.i, y.i, w.i, h.i, text.s)</code></td><td>Absolute position, dimensions, and text.</td></tr>" +
  "    <tr><td><code>Init(x.i, y.i, w.i, h.i, text.s, flags.i)</code></td><td>Full constructor with alignment flags (<code>#PB_Text_Center</code>, <code>#PB_Text_Right</code>).</td></tr>" +
  "  </table>" +
  "</div>" +
  "</div>"

SaveHTML(BaseDocDir + "en\ui\label.html", BuildPage("en", "label", "ui/label.html", "Label Class", "Static text label with multi-constructors and alignment options.", "badge-ui", "UI Class", en_label))

; EN UI: CheckBox
Define en_checkbox.s = "<div class='doc-section'>" +
  "<h2 class='section-title'>Description</h2>" +
  "<p>The <code>UI::CheckBox</code> class encapsulates a boolean toggle checkbox with checked state management.</p>" +
  "</div>" +
  "<div class='doc-section'>" +
  "<h2 class='section-title'>Overloaded Constructors</h2>" +
  "<div class='table-wrapper'>" +
  "  <table>" +
  "    <tr><th>Constructor</th><th>Description</th></tr>" +
  "    <tr><td><code>Init(text.s)</code></td><td>Unchecked checkbox (150&times;25 default).</td></tr>" +
  "    <tr><td><code>Init(text.s, checked.b)</code></td><td>Checkbox with text and initial state.</td></tr>" +
  "    <tr><td><code>Init(text.s, w.i, h.i, checked.b)</code></td><td>Checkbox with text, dimensions, and initial state.</td></tr>" +
  "    <tr><td><code>Init(x.i, y.i, w.i, h.i, text.s, flags.i)</code></td><td>Full constructor with position and flags.</td></tr>" +
  "  </table>" +
  "</div>" +
  "</div>"

SaveHTML(BaseDocDir + "en\ui\checkbox.html", BuildPage("en", "checkbox", "ui/checkbox.html", "CheckBox Class", "Toggle checkbox with multi-constructors and state accessors.", "badge-ui", "UI Class", en_checkbox))

; EN UI: ComboBox
Define en_combobox.s = "<div class='doc-section'>" +
  "<h2 class='section-title'>Description</h2>" +
  "<p>The <code>UI::ComboBox</code> class provides a drop-down list selection box with item management.</p>" +
  "</div>" +
  "<div class='doc-section'>" +
  "<h2 class='section-title'>Overloaded Constructors</h2>" +
  "<div class='table-wrapper'>" +
  "  <table>" +
  "    <tr><th>Constructor</th><th>Description</th></tr>" +
  "    <tr><td><code>Init()</code></td><td>Drop-down selection box (150&times;25 default).</td></tr>" +
  "    <tr><td><code>Init(w.i, h.i)</code></td><td>ComboBox with custom dimensions.</td></tr>" +
  "    <tr><td><code>Init(x.i, y.i, w.i, h.i)</code></td><td>Absolute coordinates and dimensions.</td></tr>" +
  "    <tr><td><code>Init(x.i, y.i, w.i, h.i, flags.i)</code></td><td>Full constructor with flags (<code>#PB_ComboBox_Editable</code>, etc.).</td></tr>" +
  "  </table>" +
  "</div>" +
  "</div>"

SaveHTML(BaseDocDir + "en\ui\combobox.html", BuildPage("en", "combobox", "ui/combobox.html", "ComboBox Class", "Drop-down selection box with multi-constructors.", "badge-ui", "UI Class", en_combobox))

; EN UI: ListIcon
Define en_listicon.s = "<div class='doc-section'>" +
  "<h2 class='section-title'>Description</h2>" +
  "<p>The <code>UI::ListIcon</code> class encapsulates a multi-column data grid table (<code>ListIconGadget</code>) with selection and row manipulation.</p>" +
  "</div>" +
  "<div class='doc-section'>" +
  "<h2 class='section-title'>Overloaded Constructors</h2>" +
  "<div class='table-wrapper'>" +
  "  <table>" +
  "    <tr><th>Constructor</th><th>Description</th></tr>" +
  "    <tr><td><code>Init(title.s, colWidth.i)</code></td><td>Initializes table with its primary column (full row select by default).</td></tr>" +
  "    <tr><td><code>Init(title.s, colWidth.i, flags.i)</code></td><td>Table with custom flags (<code>#PB_ListIcon_GridLines</code>, <code>#PB_ListIcon_CheckBoxes</code>, etc.).</td></tr>" +
  "    <tr><td><code>Init(x.i, y.i, w.i, h.i, title.s, colWidth.i)</code></td><td>Absolute position and dimensions.</td></tr>" +
  "    <tr><td><code>Init(x.i, y.i, w.i, h.i, title.s, colWidth.i, flags.i)</code></td><td>Full constructor with position, dimensions, title, and flags.</td></tr>" +
  "  </table>" +
  "</div>" +
  "</div>"

SaveHTML(BaseDocDir + "en\ui\listicon.html", BuildPage("en", "listicon", "ui/listicon.html", "ListIcon Class", "Multi-column data grid table with multi-constructors.", "badge-ui", "UI Class", en_listicon))

; EN UI: ProgressBar
Define en_progressbar.s = "<div class='doc-section'>" +
  "<h2 class='section-title'>Description</h2>" +
  "<p>The <code>UI::ProgressBar</code> class provides a visual progress indicator.</p>" +
  "</div>" +
  "<div class='doc-section'>" +
  "<h2 class='section-title'>Overloaded Constructors</h2>" +
  "<div class='table-wrapper'>" +
  "  <table>" +
  "    <tr><th>Constructor</th><th>Description</th></tr>" +
  "    <tr><td><code>Init()</code></td><td>Default range 0..100 (200&times;25).</td></tr>" +
  "    <tr><td><code>Init(min.i, max.i)</code></td><td>Custom min and max range.</td></tr>" +
  "    <tr><td><code>Init(min.i, max.i, w.i, h.i)</code></td><td>Custom range and dimensions.</td></tr>" +
  "    <tr><td><code>Init(x.i, y.i, w.i, h.i, min.i, max.i, flags.i)</code></td><td>Full constructor with position, range, and flags.</td></tr>" +
  "  </table>" +
  "</div>" +
  "</div>"

SaveHTML(BaseDocDir + "en\ui\progressbar.html", BuildPage("en", "progressbar", "ui/progressbar.html", "ProgressBar Class", "Visual progress indicator with multi-constructors.", "badge-ui", "UI Class", en_progressbar))

; EN UI: Slider
Define en_slider.s = "<div class='doc-section'>" +
  "<h2 class='section-title'>Description</h2>" +
  "<p>The <code>UI::Slider</code> class encapsulates a linear TrackBar adjustment slider.</p>" +
  "</div>" +
  "<div class='doc-section'>" +
  "<h2 class='section-title'>Overloaded Constructors</h2>" +
  "<div class='table-wrapper'>" +
  "  <table>" +
  "    <tr><th>Constructor</th><th>Description</th></tr>" +
  "    <tr><td><code>Init()</code></td><td>Default range 0..100 (200&times;25).</td></tr>" +
  "    <tr><td><code>Init(min.i, max.i)</code></td><td>Custom min and max range.</td></tr>" +
  "    <tr><td><code>Init(min.i, max.i, w.i, h.i)</code></td><td>Custom range and dimensions.</td></tr>" +
  "    <tr><td><code>Init(x.i, y.i, w.i, h.i, min.i, max.i, flags.i)</code></td><td>Full constructor with position, range, and flags.</td></tr>" +
  "  </table>" +
  "</div>" +
  "</div>"

SaveHTML(BaseDocDir + "en\ui\slider.html", BuildPage("en", "slider", "ui/slider.html", "Slider Class", "Interactive trackbar slider with multi-constructors.", "badge-ui", "UI Class", en_slider))

; EN UI: ToggleSwitch
Define en_toggleswitch.s = "<div class='doc-section'>" +
  "<h2 class='section-title'>Description</h2>" +
  "<p>The <code>UI::Controls::ToggleSwitch</code> is a modern vector-rendered CustomGadget on Canvas implementing an iOS / Material style toggle switch.</p>" +
  "</div>" +
  "<div class='doc-section'>" +
  "<h2 class='section-title'>Overloaded Constructors</h2>" +
  "<div class='table-wrapper'>" +
  "  <table>" +
  "    <tr><th>Constructor</th><th>Description</th></tr>" +
  "    <tr><td><code>Init()</code></td><td>Default unchecked switch (50&times;26).</td></tr>" +
  "    <tr><td><code>Init(checked.b)</code></td><td>Initial on/off state.</td></tr>" +
  "    <tr><td><code>Init(w.i, h.i, checked.b)</code></td><td>Custom dimensions and initial state.</td></tr>" +
  "    <tr><td><code>Init(x.i, y.i, w.i, h.i, checked.b)</code></td><td>Absolute coordinates, dimensions, and initial state.</td></tr>" +
  "  </table>" +
  "</div>" +
  "</div>"

SaveHTML(BaseDocDir + "en\ui\toggleswitch.html", BuildPage("en", "toggleswitch", "ui/toggleswitch.html", "ToggleSwitch Class", "Modern vector-rendered iOS-style toggle switch.", "badge-ui", "UI Class", en_toggleswitch))

; EN UI: Container
Define en_container.s = "<div class='doc-section'>" +
  "<h2 class='section-title'>Description</h2>" +
  "<p>The <code>UI::Layouts::Container</code> class is the abstract foundation for all responsive layout panels. Inspired by WPF / .NET, it coordinates child components and executes automatic two-pass layout cycles (<code>Arrange</code>).</p>" +
  "</div>" +
  "<div class='doc-section'>" +
  "<h2 class='section-title'>Overloaded Constructors</h2>" +
  "<div class='table-wrapper'>" +
  "  <table>" +
  "    <tr><th>Constructor</th><th>Description</th></tr>" +
  "    <tr><td><code>Init()</code></td><td>Default container (stretch alignment).</td></tr>" +
  "    <tr><td><code>Init(w.i, h.i)</code></td><td>Container with initial dimensions.</td></tr>" +
  "    <tr><td><code>Init(x.i, y.i, w.i, h.i)</code></td><td>Container with absolute coordinates and dimensions.</td></tr>" +
  "  </table>" +
  "</div>" +
  "</div>"

SaveHTML(BaseDocDir + "en\ui\container.html", BuildPage("en", "container", "ui/container.html", "Container Class", "Abstract base class for all WPF-style responsive layout panels.", "badge-ui", "Layout", en_container))

; EN UI: StackPanel
Define en_stackpanel.s = "<div class='doc-section'>" +
  "<h2 class='section-title'>Description</h2>" +
  "<p>The <code>UI::Layouts::StackPanel</code> arranges child elements into a single linear flow (vertical or horizontal) with configurable spacing between items.</p>" +
  "</div>" +
  "<div class='doc-section'>" +
  "<h2 class='section-title'>Overloaded Constructors</h2>" +
  "<div class='table-wrapper'>" +
  "  <table>" +
  "    <tr><th>Constructor</th><th>Description</th></tr>" +
  "    <tr><td><code>Init()</code></td><td>Vertical StackPanel with 5px spacing by default.</td></tr>" +
  "    <tr><td><code>Init(orientation.i)</code></td><td>StackPanel with chosen orientation (<code>#UI_Orientation_Vertical</code> or <code>#UI_Orientation_Horizontal</code>).</td></tr>" +
  "    <tr><td><code>Init(orientation.i, spacing.i)</code></td><td>Custom orientation and spacing.</td></tr>" +
  "    <tr><td><code>Init(orientation.i, spacing.i, w.i, h.i)</code></td><td>Custom orientation, spacing, and dimensions.</td></tr>" +
  "  </table>" +
  "</div>" +
  "</div>"

SaveHTML(BaseDocDir + "en\ui\stackpanel.html", BuildPage("en", "stackpanel", "ui/stackpanel.html", "StackPanel Class", "Linear vertical or horizontal layout panel with multi-constructors.", "badge-ui", "Layout", en_stackpanel))

; EN UI: DockPanel
Define en_dockpanel.s = "<div class='doc-section'>" +
  "<h2 class='section-title'>Description</h2>" +
  "<p>The <code>UI::Layouts::DockPanel</code> positions child elements along its 4 outer edges (Top, Bottom, Left, Right) and expands the last child to fill central space.</p>" +
  "</div>" +
  "<div class='doc-section'>" +
  "<h2 class='section-title'>Overloaded Constructors</h2>" +
  "<div class='table-wrapper'>" +
  "  <table>" +
  "    <tr><th>Constructor</th><th>Description</th></tr>" +
  "    <tr><td><code>Init()</code></td><td>DockPanel with <code>LastChildFill = #True</code> by default.</td></tr>" +
  "    <tr><td><code>Init(lastChildFill.b)</code></td><td>Custom LastChildFill toggle.</td></tr>" +
  "    <tr><td><code>Init(lastChildFill.b, w.i, h.i)</code></td><td>Custom LastChildFill and initial dimensions.</td></tr>" +
  "  </table>" +
  "</div>" +
  "</div>"

SaveHTML(BaseDocDir + "en\ui\dockpanel.html", BuildPage("en", "dockpanel", "ui/dockpanel.html", "DockPanel Class", "Edge-docking layout panel with central space filling.", "badge-ui", "Layout", en_dockpanel))

; EN UI: Grid
Define en_grid.s = "<div class='doc-section'>" +
  "<h2 class='section-title'>Description</h2>" +
  "<p>The <code>UI::Layouts::Grid</code> defines a flexible 2D grid of rows and columns with fixed, <code>'Auto'</code>, and Star (<code>'*'</code>, <code>'2*'</code>) proportional sizing.</p>" +
  "</div>" +
  "<div class='doc-section'>" +
  "<h2 class='section-title'>Overloaded Constructors</h2>" +
  "<div class='table-wrapper'>" +
  "  <table>" +
  "    <tr><th>Constructor</th><th>Description</th></tr>" +
  "    <tr><td><code>Init()</code></td><td>Default 2D responsive grid.</td></tr>" +
  "    <tr><td><code>Init(w.i, h.i)</code></td><td>Grid with initial dimensions.</td></tr>" +
  "  </table>" +
  "</div>" +
  "</div>"

SaveHTML(BaseDocDir + "en\ui\grid.html", BuildPage("en", "grid", "ui/grid.html", "Grid Class", "Two-dimensional responsive layout grid with Star proportional sizing.", "badge-ui", "Layout", en_grid))

PrintN("Doc generation finished successfully with UTF-8 BOM & HTML entities!")
End 0
