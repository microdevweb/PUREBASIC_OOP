; ============================================================================
; PureBasic OOP Documentation Generator
; Generates complete, modern HTML documentation (FR & EN) with syntax highlighting
; Fixed accent and UTF-8 encoding support with BOM and HTML entities
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
    n + "      <li class='nav-item" + Iif(Bool(currentKey="progressbar"), " active", "") + "'><a href='" + relPath + "ui/progressbar.html'><span>ProgressBar</span><span class='badge badge-ui'>UI</span></a></li>" + #CRLF$
    n + "      <li class='nav-item" + Iif(Bool(currentKey="slider"), " active", "") + "'><a href='" + relPath + "ui/slider.html'><span>Slider</span><span class='badge badge-ui'>UI</span></a></li>" + #CRLF$
    n + "      <li class='nav-item" + Iif(Bool(currentKey="textbox"), " active", "") + "'><a href='" + relPath + "ui/textbox.html'><span>TextBox</span><span class='badge badge-ui'>UI</span></a></li>" + #CRLF$
    n + "      <li class='nav-item" + Iif(Bool(currentKey="toggleswitch"), " active", "") + "'><a href='" + relPath + "ui/toggleswitch.html'><span>ToggleSwitch</span><span class='badge badge-ui'>UI</span></a></li>" + #CRLF$
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
    n + "      <li class='nav-item" + Iif(Bool(currentKey="progressbar"), " active", "") + "'><a href='" + relPath + "ui/progressbar.html'><span>ProgressBar</span><span class='badge badge-ui'>UI</span></a></li>" + #CRLF$
    n + "      <li class='nav-item" + Iif(Bool(currentKey="slider"), " active", "") + "'><a href='" + relPath + "ui/slider.html'><span>Slider</span><span class='badge badge-ui'>UI</span></a></li>" + #CRLF$
    n + "      <li class='nav-item" + Iif(Bool(currentKey="textbox"), " active", "") + "'><a href='" + relPath + "ui/textbox.html'><span>TextBox</span><span class='badge badge-ui'>UI</span></a></li>" + #CRLF$
    n + "      <li class='nav-item" + Iif(Bool(currentKey="toggleswitch"), " active", "") + "'><a href='" + relPath + "ui/toggleswitch.html'><span>ToggleSwitch</span><span class='badge badge-ui'>UI</span></a></li>" + #CRLF$
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
  "<p>Le mot-cl&eacute; <code>Extends</code> permet &agrave; une classe d'h&eacute;riter des champs et m&eacute;thodes d'une classe parente. Le mot-cl&eacute; <code>Super::</code> permet d'invoquer l'impl&eacute;mentation parente d'une m&eacute;thode surcharg&eacute;e.</p>" +
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
  "    <span class='kw'>Super</span>::<span class='fn'>Demarrer</span>()" + #CRLF$ +
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
  "  <li><code>Super::</code> : Appel explicite de la m&eacute;thode d'une classe parente.</li>" +
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

SaveHTML(BaseDocDir + "fr\ui\application.html", BuildPage("fr", "application", "ui/application.html", "Classe Application", "Gestionnaire global d'application et boucle d'&eacute;v&eacute;nements GUI.", "badge-ui", "UI Class", fr_application))

; FR UI: Window
Define fr_window.s = "<div class='doc-section'>" +
  "<h2 class='section-title'>Description</h2>" +
  "<p>La classe <code>Window</code> repr&eacute;sente une fen&ecirc;tre graphique syst&egrave;me. Elle permet d'ajouter des gadgets, de configurer les dimensions, le titre, et de g&eacute;rer les &eacute;v&eacute;nements de fermeture ou de redimensionnement.</p>" +
  "</div>" +
  "<div class='doc-section'>" +
  "<h2 class='section-title'>M&eacute;thodes principales</h2>" +
  "<div class='table-wrapper'>" +
  "  <table>" +
  "    <tr><th>M&eacute;thode</th><th>Description</th></tr>" +
  "    <tr><td><code>Init(x, y, width, height, title.s, flags)</code></td><td>Cr&eacute;e et initialise la fen&ecirc;tre.</td></tr>" +
  "    <tr><td><code>AddGadget(*gadget)</code></td><td>Attache un contr&ocirc;le ou gadget enfant &agrave; la fen&ecirc;tre.</td></tr>" +
  "    <tr><td><code>Show() / Hide()</code></td><td>Affiche ou masque la fen&ecirc;tre.</td></tr>" +
  "    <tr><td><code>Close()</code></td><td>Ferme et lib&egrave;re la fen&ecirc;tre.</td></tr>" +
  "  </table>" +
  "</div>" +
  "</div>"

SaveHTML(BaseDocDir + "fr\ui\window.html", BuildPage("fr", "window", "ui/window.html", "Classe Window", "Cr&eacute;ation et gestion des fen&ecirc;tres graphiques natives.", "badge-ui", "UI Class", fr_window))

; FR UI: Gadget / Component
Define fr_gadget.s = "<div class='doc-section'>" +
  "<h2 class='section-title'>Description</h2>" +
  "<p>La classe <code>Gadget</code> est la classe abstraite de base pour tous les contr&ocirc;les graphiques UI (boutons, listes, sliders, interrupteurs, etc.).</p>" +
  "<p>Elle fournit le positionnement (x, y, width, height), la visibilit&eacute;, et le syst&egrave;me unifi&eacute; de gestion des &eacute;v&eacute;nements (<code>OnClick</code>, <code>OnChange</code>...).</p>" +
  "</div>"

SaveHTML(BaseDocDir + "fr\ui\gadget.html", BuildPage("fr", "gadget", "ui/gadget.html", "Classe Gadget & Component", "Classe de base abstraite pour tous les contr&ocirc;les UI.", "badge-ui", "UI Class", fr_gadget))

; FR UI: Button
Define fr_button.s = "<div class='doc-section'>" +
  "<h2 class='section-title'>Description</h2>" +
  "<p>La classe <code>Button</code> encapsule un bouton cliquable natif ou personnalis&eacute; avec gestion directe du callback d'&eacute;v&eacute;nement <code>OnClick</code>.</p>" +
  "</div>" +
  "<div class='doc-section'>" +
  "<h2 class='section-title'>Exemple d'utilisation</h2>" +
  "<div class='code-container'>" +
  "  <div class='code-header'><span class='code-title'>Bouton avec callback (.pbo)</span><span class='code-badge'>PBO</span></div>" +
  "  <pre><code><span class='kw'>Protected</span> *btn.<span class='tp'>Button</span> = <span class='kw'>NewObject</span>(<span class='tp'>Button</span>, <span class='num'>10</span>, <span class='num'>10</span>, <span class='num'>120</span>, <span class='num'>35</span>, 'Cliquez-moi')" + #CRLF$ +
  "*win\\<span class='fn'>AddGadget</span>(*btn)" + #CRLF$ +
  "*btn\\<span class='fn'>SetText</span>('Nouveau Texte')</code></pre>" +
  "</div>" +
  "</div>"

SaveHTML(BaseDocDir + "fr\ui\button.html", BuildPage("fr", "button", "ui/button.html", "Classe Button", "Contr&ocirc;le bouton cliquable avec gestion d'&eacute;v&eacute;nements.", "badge-ui", "UI Class", fr_button))

; FR UI: Other controls
SaveHTML(BaseDocDir + "fr\ui\checkbox.html", BuildPage("fr", "checkbox", "ui/checkbox.html", "Classe CheckBox", "Case &agrave; cocher avec &eacute;tat s&eacute;lectionn&eacute;/d&eacute;s&eacute;lectionn&eacute;.", "badge-ui", "UI Class", "<p>Encapsule une case &agrave; cocher native avec m&eacute;thodes <code>SetState(state)</code> et <code>GetState()</code>.</p>"))
SaveHTML(BaseDocDir + "fr\ui\combobox.html", BuildPage("fr", "combobox", "ui/combobox.html", "Classe ComboBox", "Liste d&eacute;roulante s&eacute;lectionnable.", "badge-ui", "UI Class", "<p>Gestion de liste d'&eacute;l&eacute;ments avec <code>AddItem(text.s)</code>, <code>GetSelected()</code> et <code>SetSelected(index)</code>.</p>"))
SaveHTML(BaseDocDir + "fr\ui\label.html", BuildPage("fr", "label", "ui/label.html", "Classe Label", "Texte statique et libell&eacute; d'interface.", "badge-ui", "UI Class", "<p>Affiche un libell&eacute; textuel avec alignement et styles personnalisables.</p>"))
SaveHTML(BaseDocDir + "fr\ui\progressbar.html", BuildPage("fr", "progressbar", "ui/progressbar.html", "Classe ProgressBar", "Barre de progression visuelle.", "badge-ui", "UI Class", "<p>Indicateur d'avancement avec <code>SetProgress(value)</code> et <code>SetRange(min, max)</code>.</p>"))
SaveHTML(BaseDocDir + "fr\ui\slider.html", BuildPage("fr", "slider", "ui/slider.html", "Classe Slider", "Curseur de r&eacute;glage lin&eacute;aire.", "badge-ui", "UI Class", "<p>Curseur interactif horizontal/vertical avec notification de changement de valeur.</p>"))
SaveHTML(BaseDocDir + "fr\ui\textbox.html", BuildPage("fr", "textbox", "ui/textbox.html", "Classe TextBox", "Champ de saisie texte simple ou multiligne.", "badge-ui", "UI Class", "<p>Contr&ocirc;le de saisie avec accesseurs <code>GetText()</code>, <code>SetText(str)</code> et validation.</p>"))
SaveHTML(BaseDocDir + "fr\ui\toggleswitch.html", BuildPage("fr", "toggleswitch", "ui/toggleswitch.html", "Classe ToggleSwitch", "Interrupteur &agrave; bascule moderne (Style iOS/Material).", "badge-ui", "UI Class", "<p>Composant vectoriel moderne CustomGadget pour &eacute;tats On/Off avec animation fluide.</p>"))


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
  "    <div class='doc-card-title'><span>UI / GUI Framework</span><span class='badge badge-ui'>UI</span></div>" +
  "    <div class='doc-card-desc'>Native controls: Application, Window, Button, ToggleSwitch, Slider...</div>" +
  "  </a>" +
  "</div>" +
  "</div>"

SaveHTML(BaseDocDir + "en\index.html", BuildPage("en", "index", "index.html", "PureBasic OOP Documentation", "Comprehensive reference guide for Object-Oriented and UI development in PureBasic.", "badge-class", "Guide", en_index))

; EN Keyword: Class
Define en_class.s = "<div class='doc-section'>" +
  "<h2 class='section-title'>Description</h2>" +
  "<p>The <code>Class</code> keyword declares a new object class. A class encapsulates fields (protected/private) and public methods to interact with its state.</p>" +
  "<p>Use <code>Abstract Class</code> to declare an abstract base class that cannot be instantiated directly.</p>" +
  "</div>" +
  "<div class='doc-section'>" +
  "<h2 class='section-title'>Syntax</h2>" +
  "<div class='code-container'>" +
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
  "</div>" +
  "<div class='doc-section'>" +
  "<h2 class='section-title'>Constructors & Destructors</h2>" +
  "<ul>" +
  "  <li><code>Public Method Init(...)</code>: Constructor invoked automatically when instantiated with <code>New</code>.</li>" +
  "  <li><code>Public Method Free()</code>: Destructor called upon object disposal with <code>FreeObject</code>.</li>" +
  "  <li><code>Public Abstract Method</code>: Method signature in an abstract class that must be implemented by concrete subclasses.</li>" +
  "</ul>" +
  "</div>"

SaveHTML(BaseDocDir + "en\keywords\method.html", BuildPage("en", "method", "keywords/method.html", "Method / EndMethod", "Instance methods, polymorphism, constructors, and destructors.", "badge-method", "Method", en_method))

; EN Keyword: Properties & others
SaveHTML(BaseDocDir + "en\keywords\properties.html", BuildPage("en", "properties", "keywords/properties.html", "Getter / Setter / Property", "Data encapsulation and property accessors.", "badge-keyword", "Property", "<p>Encapsulate private or protected field read/write access with <code>Getter</code> and <code>Setter</code> methods.</p>"))
SaveHTML(BaseDocDir + "en\keywords\inheritance.html", BuildPage("en", "inheritance", "keywords/inheritance.html", "Extends / Super", "Class inheritance and parent method invocation.", "badge-keyword", "Inheritance", "<p>Use <code>Extends</code> for single inheritance and <code>Super::Method()</code> to call overridden base class implementations.</p>"))
SaveHTML(BaseDocDir + "en\keywords\encapsulation.html", BuildPage("en", "encapsulation", "keywords/encapsulation.html", "Public / Protected / Private", "Access control and member visibility.", "badge-keyword", "Access Control", "<p>Configure visibility using <code>Public</code>, <code>Protected</code>, or <code>Private</code> scopes.</p>"))
SaveHTML(BaseDocDir + "en\keywords\lifecycle.html", BuildPage("en", "lifecycle", "keywords/lifecycle.html", "New / Free / Lifecycle", "Object instantiation, initialization, and memory disposal.", "badge-keyword", "Lifecycle", "<p>Create instances using <code>NewObject(ClassName, ...)</code> and dispose of them with <code>FreeObject(*instance)</code>.</p>"))
SaveHTML(BaseDocDir + "en\keywords\operators.html", BuildPage("en", "operators", "keywords/operators.html", "This / Cast / TypeOf", "Context operators and object introspection.", "badge-keyword", "Operator", "<p>Use <code>This</code> for self-reference, <code>TypeOf(*obj)</code> for class reflection, and <code>InstanceOf</code> for type checking.</p>"))

; EN UI Components
SaveHTML(BaseDocDir + "en\ui\application.html", BuildPage("en", "application", "ui/application.html", "Application Class", "Global application manager and GUI event loop.", "badge-ui", "UI Class", "<p>Manages the application lifecycle and message dispatch with <code>Run()</code> and <code>Exit()</code>.</p>"))
SaveHTML(BaseDocDir + "en\ui\window.html", BuildPage("en", "window", "ui/window.html", "Window Class", "Native GUI window management.", "badge-ui", "UI Class", "<p>Create and control native GUI windows, add gadgets, and handle resize/close events.</p>"))
SaveHTML(BaseDocDir + "en\ui\gadget.html", BuildPage("en", "gadget", "ui/gadget.html", "Gadget & Component Classes", "Abstract base class for all UI controls.", "badge-ui", "UI Class", "<p>Unified base control handling coordinates (x, y, w, h), visibility, and event routing.</p>"))
SaveHTML(BaseDocDir + "en\ui\button.html", BuildPage("en", "button", "ui/button.html", "Button Class", "Clickable button control with event handling.", "badge-ui", "UI Class", "<p>Standard push button with text, dimensions, and <code>OnClick</code> callbacks.</p>"))
SaveHTML(BaseDocDir + "en\ui\checkbox.html", BuildPage("en", "checkbox", "ui/checkbox.html", "CheckBox Class", "Checkable toggle box.", "badge-ui", "UI Class", "<p>Toggle checkable box with <code>SetState()</code> and <code>GetState()</code>.</p>"))
SaveHTML(BaseDocDir + "en\ui\combobox.html", BuildPage("en", "combobox", "ui/combobox.html", "ComboBox Class", "Drop-down selection list.", "badge-ui", "UI Class", "<p>Dropdown selection component with item management.</p>"))
SaveHTML(BaseDocDir + "en\ui\label.html", BuildPage("en", "label", "ui/label.html", "Label Class", "Static text display.", "badge-ui", "UI Class", "<p>Static text display with customizable typography.</p>"))
SaveHTML(BaseDocDir + "en\ui\progressbar.html", BuildPage("en", "progressbar", "ui/progressbar.html", "ProgressBar Class", "Visual progress indicator.", "badge-ui", "UI Class", "<p>Linear progress bar with progress tracking.</p>"))
SaveHTML(BaseDocDir + "en\ui\slider.html", BuildPage("en", "slider", "ui/slider.html", "Slider Class", "Interactive trackbar slider.", "badge-ui", "UI Class", "<p>Interactive trackbar for numerical value adjustment.</p>"))
SaveHTML(BaseDocDir + "en\ui\textbox.html", BuildPage("en", "textbox", "ui/textbox.html", "TextBox Class", "Text input field.", "badge-ui", "UI Class", "<p>Single-line or multi-line text input control.</p>"))
SaveHTML(BaseDocDir + "en\ui\toggleswitch.html", BuildPage("en", "toggleswitch", "ui/toggleswitch.html", "ToggleSwitch Class", "Modern toggle switch (iOS/Material style).", "badge-ui", "UI Class", "<p>Vector-rendered CustomGadget for On/Off toggle states with smooth animations.</p>"))

PrintN("Doc generation finished successfully with UTF-8 BOM & HTML entities!")
End 0
