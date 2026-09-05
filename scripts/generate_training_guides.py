# -*- coding: utf-8 -*-
# ============================================================================
# PureBasic OOP - Training Guide & Reference Generator (FR & EN)
# Produces high-quality print-ready HTML (for PDF export) and Markdown formats
# Author: MicrodevWeb
# ============================================================================

import os

DOC_DIR = r"c:\PB\PB_PROJECT\PB_OOP_WORKSPACE\PUREBASIC_OOP_WORKSPACE\doc"

CSS_PRINT_STYLES = """
@import url('https://fonts.googleapis.com/css2?family=Fira+Code:wght@400;600&family=Inter:wght@300;400;500;600;700;800&display=swap');

:root {
  --primary: #0284c7;
  --primary-dark: #0369a1;
  --primary-light: #e0f2fe;
  --accent: #6366f1;
  --bg-dark: #0f172a;
  --text-main: #1e293b;
  --text-muted: #64748b;
  --bg-card: #f8fafc;
  --border-card: #e2e8f0;
  --code-bg: #1e293b;
  --code-text: #f1f5f9;
}

@page {
  size: A4;
  margin: 18mm 16mm 18mm 16mm;
  @bottom-right {
    content: counter(page);
    font-family: 'Inter', sans-serif;
    font-size: 9pt;
    color: #94a3b8;
  }
}

* {
  box-sizing: border-box;
  margin: 0;
  padding: 0;
}

body {
  font-family: 'Inter', -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
  color: var(--text-main);
  background: #ffffff;
  line-height: 1.6;
  font-size: 10pt;
}

/* Cover Page */
.cover-page {
  page-break-after: always;
  min-height: 240mm;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  padding: 20mm 0 10mm 0;
  border-bottom: 2px solid var(--primary-light);
}

.cover-header {
  display: flex;
  align-items: center;
  gap: 15px;
}

.cover-logo {
  width: 70px;
  height: 70px;
  border-radius: 12px;
  object-fit: cover;
  box-shadow: 0 4px 12px rgba(2, 132, 199, 0.2);
}

.cover-brand {
  font-size: 16pt;
  font-weight: 800;
  color: var(--primary-dark);
  letter-spacing: -0.5px;
}

.cover-badge {
  display: inline-block;
  background: var(--primary-light);
  color: var(--primary-dark);
  font-size: 8.5pt;
  font-weight: 700;
  padding: 3px 10px;
  border-radius: 999px;
  text-transform: uppercase;
  margin-top: 4px;
}

.cover-body {
  margin: 25mm 0;
}

.cover-title {
  font-size: 26pt;
  font-weight: 800;
  line-height: 1.2;
  color: var(--bg-dark);
  margin-bottom: 12px;
  letter-spacing: -0.8px;
}

.cover-subtitle {
  font-size: 13pt;
  font-weight: 500;
  color: var(--primary);
  line-height: 1.4;
  margin-bottom: 20px;
}

.cover-desc {
  font-size: 10pt;
  color: var(--text-muted);
  max-width: 550px;
  line-height: 1.6;
}

.cover-footer {
  display: flex;
  justify-content: space-between;
  align-items: flex-end;
  border-top: 1px solid var(--border-card);
  padding-top: 15px;
}

.cover-author {
  font-size: 9.5pt;
  color: var(--text-main);
  font-weight: 600;
}

.cover-meta {
  font-size: 8.5pt;
  color: var(--text-muted);
  text-align: right;
}

/* Headings */
h1, h2, h3, h4 {
  color: var(--bg-dark);
  font-weight: 700;
  page-break-after: avoid;
}

h1 {
  font-size: 15pt;
  border-bottom: 2px solid var(--primary-light);
  padding-bottom: 6px;
  margin-top: 24px;
  margin-bottom: 12px;
  page-break-before: always;
  display: flex;
  align-items: center;
  gap: 8px;
}

.first-h1 {
  page-break-before: avoid;
  margin-top: 0;
}

h2 {
  font-size: 11.5pt;
  margin-top: 18px;
  margin-bottom: 8px;
  color: var(--primary-dark);
}

h3 {
  font-size: 10pt;
  margin-top: 14px;
  margin-bottom: 6px;
}

p {
  margin-bottom: 10px;
  text-align: justify;
}

ul, ol {
  margin-left: 20px;
  margin-bottom: 12px;
}

li {
  margin-bottom: 4px;
}

/* Callouts & Tips */
.callout {
  background: var(--bg-card);
  border-left: 4px solid var(--primary);
  border-radius: 0 8px 8px 0;
  padding: 12px 16px;
  margin: 14px 0;
  page-break-inside: avoid;
}

.callout-title {
  font-weight: 700;
  font-size: 9.5pt;
  color: var(--primary-dark);
  margin-bottom: 4px;
  display: flex;
  align-items: center;
  gap: 6px;
}

.callout-tip {
  border-left-color: #10b981;
  background: #f0fdf4;
}
.callout-tip .callout-title {
  color: #047857;
}

.callout-warn {
  border-left-color: #f59e0b;
  background: #fffbeb;
}
.callout-warn .callout-title {
  color: #b45309;
}

/* Code blocks */
.code-container {
  background: var(--code-bg);
  border-radius: 8px;
  margin: 12px 0;
  page-break-inside: avoid;
  overflow: hidden;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
}

.code-header {
  background: #0b1120;
  padding: 6px 12px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 8pt;
  color: #94a3b8;
  font-weight: 600;
  border-bottom: 1px solid #334155;
}

.code-badge {
  background: var(--primary);
  color: #ffffff;
  padding: 1px 6px;
  border-radius: 4px;
  font-size: 7pt;
  text-transform: uppercase;
}

pre {
  padding: 12px 14px;
  overflow-x: auto;
  font-family: 'Fira Code', 'Courier New', monospace;
  font-size: 8.5pt;
  line-height: 1.45;
  color: var(--code-text);
}

code {
  font-family: 'Fira Code', 'Courier New', monospace;
  font-size: 9pt;
}

p code, li code, td code {
  background: #f1f5f9;
  color: #0f172a;
  padding: 1px 5px;
  border-radius: 4px;
  font-size: 8.5pt;
  border: 1px solid #e2e8f0;
}

/* Code Syntax Colors */
.kw { color: #38bdf8; font-weight: 600; }
.str { color: #a5d6a7; }
.comment { color: #94a3b8; font-style: italic; }
.num { color: #f59e0b; }
.type { color: #c084fc; font-weight: 600; }

/* Tables */
table {
  width: 100%;
  border-collapse: collapse;
  margin: 12px 0;
  page-break-inside: avoid;
  font-size: 9pt;
}

th, td {
  border: 1px solid var(--border-card);
  padding: 7px 10px;
  text-align: left;
}

th {
  background: var(--bg-card);
  font-weight: 700;
  color: var(--bg-dark);
}

tr:nth-child(even) {
  background: #fcfcfd;
}

/* Diagram box */
.diagram-box {
  background: #f8fafc;
  border: 1px solid #cbd5e1;
  border-radius: 8px;
  padding: 14px;
  margin: 14px 0;
  text-align: left;
  font-family: 'Fira Code', monospace;
  font-size: 8pt;
  line-height: 1.45;
  color: #334155;
  page-break-inside: avoid;
  overflow-x: auto;
}

@media screen {
  body {
    max-width: 900px;
    margin: 30px auto;
    padding: 30px 40px;
    background: #ffffff;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
    border-radius: 12px;
  }
  .print-btn {
    position: fixed;
    top: 20px;
    right: 20px;
    background: var(--primary);
    color: white;
    padding: 10px 18px;
    border-radius: 8px;
    text-decoration: none;
    font-weight: 600;
    font-size: 10pt;
    box-shadow: 0 4px 12px rgba(2, 132, 199, 0.3);
    cursor: pointer;
    border: none;
    z-index: 1000;
  }
}
"""

def generate_french():
    html_content = f"""<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Guide de Formation : Débuter avec PureBasic OOP & MVVM</title>
  <style>
{CSS_PRINT_STYLES}
  </style>
</head>
<body>
  <button class="print-btn" onclick="window.print()">🖨️ Imprimer / Exporter en PDF</button>

  <!-- COVER PAGE -->
  <div class="cover-page">
    <div class="cover-header">
      <img src="html/assets/PB_OOP_LOGO.jpeg" alt="Logo" class="cover-logo">
      <div>
        <div class="cover-brand">PureBasic OOP Framework</div>
        <span class="cover-badge">Guide de Formation Officiel</span>
      </div>
    </div>
    
    <div class="cover-body">
      <h1 class="cover-title" style="page-break-before: avoid; border: none; padding: 0;">Débuter avec la POO<br>& le Pattern MVVM</h1>
      <div class="cover-subtitle">Concevoir sa première application réactive moderne pas à pas</div>
      <p class="cover-desc">
        Un guide pratique complet destiné aux développeurs PureBasic souhaitant structurer leurs applications avec l'architecture MVVM, les Layouts réactifs WPF, l'organisation standardisée des dossiers et le DataBinding bidirectionnel.
      </p>
    </div>
    
    <div class="cover-footer">
      <div class="cover-author">
        Auteur : <strong>MicrodevWeb</strong><br>
        Framework : PureBasic OOP v1.2 / v2.0
      </div>
      <div class="cover-meta">
        Support de formation pas à pas<br>
        PureBasic 6.x Windows / Linux / macOS
      </div>
    </div>
  </div>

  <!-- MODULE 1 -->
  <h1 class="first-h1"><span>📦</span> Module 1 : Pourquoi la POO & le MVVM en PureBasic ?</h1>
  
  <p>Depuis toujours, PureBasic excelle par sa rapidité d'exécution, sa légèreté et sa simplicité procédurale. Cependant, dès qu'une interface graphique grandit, le code traditionnel fait face à des limites bien connues :</p>
  <ul>
    <li><strong>Le syndrome du code « Spaghetti »</strong> : Des boucles d'événements <code>WaitWindowEvent()</code> géantes contenant des dizaines de <code>Select EventGadget()</code> imbriqués.</li>
    <li><strong>Le couplage fort</strong> : La logique de calcul est mélangée avec les appels <code>SetGadgetText()</code> et <code>GetGadgetText()</code>.</li>
    <li><strong>Le redimensionnement complexe</strong> : Le calcul manuel des coordonnées en pixels de chaque bouton lors des événements <code>#PB_Event_SizeWindow</code>.</li>
  </ul>

  <div class="callout callout-tip">
    <div class="callout-title">💡 La solution PureBasic OOP</div>
    <p>Ce framework apporte les standards modernes du développement d'entreprise : <strong>classes réutilisables (.pbo)</strong>, <strong>modèle de boîte WPF (StackPanel, Grid)</strong> et <strong>MVVM (Model-View-ViewModel)</strong> avec mise à jour automatique sans aucun code de rafraîchissement manuel.</p>
  </div>

  <h2>1.2. Ce que nous allons construire ensemble</h2>
  <p>Dans ce guide pratique, nous allons concevoir une application complète : <strong>« Mini Gestionnaire de Tâches & Compteur Réactif »</strong>.</p>
  <p>L'application permettra de saisir un titre, de cliquer sur un bouton pour l'ajouter, et verra son compteur et son message d'état se mettre à jour instantanément grâce au <em>DataBinding</em>.</p>

  <!-- MODULE 2 : ORGANISATION DES DOSSIERS & INCLUDES -->
  <h1><span>📁</span> Module 2 : Organisation des Dossiers & Stratégie des Includes</h1>
  
  <p>Une architecture MVVM professionnelle repose sur une séparation claire des responsabilités dans l'arborescence de votre projet. Voici la structure recommandée :</p>

  <div class="diagram-box">
MonProjetMVVM/
│
├── src/                          &lt;-- Framework PureBasic OOP (ou chemin partagé)
│   ├── core/                    &lt;-- Object, List, Vector, Memory, Exceptions
│   └── ui/
│       ├── UI.pbi               &lt;-- POINT D'ENTRÉE MASTER (Core + UI + MVVM + XMLLoader)
│       ├── Component.pbo        &lt;-- Socle WPF (Alignements, Marges, Arrange)
│       ├── Gadget.pbo           &lt;-- Encapsulation des 18 gadgets natifs
│       ├── controls/            &lt;-- Editor, ListView, TreeView, DatePicker...
│       ├── layouts/             &lt;-- StackPanel, DockPanel, Grid
│       ├── mvvm/
│       │   ├── MVVM.pbi         &lt;-- POINT D'ENTRÉE MVVM AUTONOME (sans contrôles graphiques)
│       │   ├── ObservableObject.pbi
│       │   ├── ViewModelBase.pbi
│       │   ├── Property.pbi
│       │   └── BindingEngine.pbi
│       └── XMLLoader.pbi        &lt;-- Parseur et chargeur de vues XML
│
├── constants/
│   └── AppConstants.pbi         &lt;-- Noms des propriétés et commandes partagées
│
├── models/
│   └── TaskModel.pbi            &lt;-- Structures de données et logique métier pure
│
├── viewmodels/
│   └── TaskViewModel.pbo        &lt;-- Classe ViewModel héritant de MVVM::ViewModelBase
│
├── views/
│   └── MainView.xml             &lt;-- Définition déclarative de l'interface
│
└── main.pb                      &lt;-- Point d'entrée principal exécutable
  </div>

  <h2>2.1. Les deux options d'inclusion du Framework</h2>
  <p>Selon vos besoins, vous disposez de deux points d'entrée simples et sécurisés avec <code>XIncludeFile</code> :</p>
  <ul>
    <li><strong><code>XIncludeFile "src/ui/UI.pbi"</code> (Recommandé pour les applications graphiques)</strong> : Inclut tout le framework en une seule ligne (Noyau Core, 18 Contrôles UI, Layouts réactifs WPF, Sous-système MVVM et Moteur XMLLoader).</li>
    <li><strong><code>XIncludeFile "src/ui/mvvm/MVVM.pbi"</code> (Pour modules ou tests headless)</strong> : Inclut uniquement le moteur MVVM (ObservableObject, ViewModelBase, Propriétés typées, RelayCommand, BindingEngine) sans charger les gadgets graphiques.</li>
  </ul>

  <h2>2.2. L'ordre d'inclusion obligatoire dans votre <code>main.pb</code></h2>
  <p>Pour garantir que le compilateur et le transpileur résolvent tous les types sans avertissement, respectez toujours cet ordre avec <code>XIncludeFile</code> :</p>

  <div class="code-container">
    <div class="code-header">
      <span class="code-title">Ordre standard des Includes</span>
      <span class="code-badge">Bonne Pratique</span>
    </div>
    <pre><code><span class="kw">EnableExplicit</span>

<span class="comment">; 1. TOUJOURS EN PREMIER : Le framework UI & MVVM (ou src/ui/mvvm/MVVM.pbi)</span>
<span class="kw">XIncludeFile</span> <span class="str">"src/ui/UI.pbi"</span>

<span class="comment">; 2. EN SECOND : Les constantes partagées de Bindings et de Commandes</span>
<span class="kw">XIncludeFile</span> <span class="str">"constants/AppConstants.pbi"</span>

<span class="comment">; 3. EN TROISIÈME : Les Modèles de données (si existants)</span>
<span class="comment">; XIncludeFile "models/TaskModel.pbi"</span>

<span class="comment">; 4. EN QUATRIÈME : Les classes ViewModels (.pbo transpilées)</span>
<span class="kw">XIncludeFile</span> <span class="str">"viewmodels/TaskViewModel.pbo"</span></code></pre>
  </div>

  <!-- MODULE 3 -->
  <h1><span>🧩</span> Module 3 : Comprendre le Pattern MVVM en 5 Minutes</h1>
  
  <p>Le pattern <strong>MVVM</strong> sépare clairement votre programme en trois responsabilités distinctes :</p>

  <div class="diagram-box">
┌─────────────────────────┐         ┌─────────────────────────┐
│       VUE (View)        │         │   VIEWMODEL (Moteur)    │
│  MainView.xml ou UI POO │ ◄─────► │  Propriétés Observables │
│   TextBox, Button, List │ Binding │  StringProperty, Int... │
└─────────────────────────┘         └────────────┬────────────┘
                                                 │ Métier
                                    ┌────────────▼────────────┐
                                    │      MODÈLE (Data)      │
                                    │    Structures / BDD     │
                                    └─────────────────────────┘
  </div>

  <ul>
    <li><strong>Model (Modèle)</strong> : Représente la donnée brute (fichiers, structures, base de données).</li>
    <li><strong>ViewModel (Modèle de Vue)</strong> : C'est le « cerveau ». Il hérite de <code>MVVM::ViewModelBase</code> et expose des <strong>Propriétés Observables</strong> (<code>StringProperty</code>, <code>IntProperty</code>). Dès qu'une valeur change, il notifie les abonnés.</li>
    <li><strong>View (Vue)</strong> : C'est l'interface visuelle déclarée en XML ou construite avec les classes UI. Elle se lie aux propriétés via la syntaxe <code>{{Binding NomPropriete}}</code>.</li>
    <li><strong>BindingEngine (Moteur de Liaison)</strong> : Il assure la liaison bidirectionnelle (<em>TwoWay</em>). Lorsque l'utilisateur tape du texte, le ViewModel est mis à jour. Lorsque le ViewModel modifie une variable, le contrôle graphique change tout seul !</li>
  </ul>

  <!-- MODULE 4 -->
  <h1><span>1️⃣</span> Module 4 : Étape 1 — Les Constantes Partagées</h1>
  
  <p>Pour éviter toute faute de frappe entre le fichier XML et le code du ViewModel, nous plaçons les constantes dans <code>constants/AppConstants.pbi</code> :</p>

  <div class="code-container">
    <div class="code-header">
      <span class="code-title">constants/AppConstants.pbi</span>
      <span class="code-badge">Constantes Partagées</span>
    </div>
    <pre><code><span class="comment">; ============================================================================</span>
<span class="comment">; AppConstants.pbi - Identifiants déclaratifs pour les Bindings & Commandes</span>
<span class="comment">; ============================================================================</span>

<span class="comment">; Noms des Propriétés Observables (Bindées à l'UI)</span>
<span class="kw">#PROP_TASK_TITLE</span>  = <span class="str">"TaskTitle"</span>
<span class="kw">#PROP_TASK_COUNT</span>  = <span class="str">"TaskCount"</span>
<span class="kw">#PROP_STATUS_MSG</span>  = <span class="str">"StatusMessage"</span>

<span class="comment">; Noms des Commandes (Déclenchées par les Boutons)</span>
<span class="kw">#CMD_ADD_TASK</span>     = <span class="str">"AddTaskCommand"</span>
<span class="kw">#CMD_CLEAR_ALL</span>    = <span class="str">"ClearAllCommand"</span></code></pre>
  </div>

  <!-- MODULE 5 -->
  <h1><span>2️⃣</span> Module 5 : Étape 2 — Créer le ViewModel Réactif</h1>
  
  <p>Le ViewModel encapsule l'état et réagit aux actions. Il n'a <strong>aucune dépendance</strong> envers les fenêtres ou les gadgets PureBasic (pas de <code>SetGadgetText</code>).</p>

  <div class="code-container">
    <div class="code-header">
      <span class="code-title">viewmodels/TaskViewModel.pbo</span>
      <span class="code-badge">Classe POO (.pbo)</span>
    </div>
    <pre><code><span class="comment">; ============================================================================</span>
<span class="comment">; TaskViewModel.pbo - ViewModel de gestion des tâches</span>
<span class="comment">; ============================================================================</span>
<span class="kw">XIncludeFile</span> <span class="str">"../src/ui/UI.pbi"</span>        <span class="comment">; ou "../src/ui/mvvm/MVVM.pbi"</span>
<span class="kw">XIncludeFile</span> <span class="str">"../constants/AppConstants.pbi"</span>

<span class="kw">Class</span> TaskViewModel <span class="kw">Extends</span> MVVM::ViewModelBase {{
  <span class="kw">Public</span> *TaskTitle.MVVM::StringProperty
  <span class="kw">Public</span> *TaskCount.MVVM::IntProperty
  <span class="kw">Public</span> *StatusMessage.MVVM::StringProperty

  <span class="comment">; --- Constructeur : Initialisation et enregistrement des propriétés ---</span>
  <span class="kw">Public Method</span> Init() {{
    <span class="kw">Super</span>\\Init()
    
    <span class="comment">; Enregistrement des propriétés observables dans le registre MVVM</span>
    <span class="kw">This</span>\\*TaskTitle     = <span class="kw">This</span>\\BindString(<span class="kw">#PROP_TASK_TITLE</span>, <span class="str">""</span>)
    <span class="kw">This</span>\\*TaskCount     = <span class="kw">This</span>\\BindInt(<span class="kw">#PROP_TASK_COUNT</span>, <span class="num">0</span>)
    <span class="kw">This</span>\\*StatusMessage = <span class="kw">This</span>\\BindString(<span class="kw">#PROP_STATUS_MSG</span>, <span class="str">"Prêt - Aucune tâche enregistrée."</span>)
  }}

  <span class="comment">; --- Gestionnaire des Commandes UI ---</span>
  <span class="kw">Public Override Method</span> OnCommand(cmdName.s) {{
    <span class="kw">Select</span> cmdName
      <span class="kw">Case</span> <span class="kw">#CMD_ADD_TASK</span>
        <span class="kw">Protected</span> title.s = Trim(<span class="kw">This</span>\\*TaskTitle\\GetValue())
        
        <span class="kw">If</span> title &lt;&gt; <span class="str">""</span>
          <span class="kw">Protected</span> currentCount.i = <span class="kw">This</span>\\*TaskCount\\GetValue() + <span class="num">1</span>
          
          <span class="comment">; Mise à jour des propriétés -> Notification automatique de la Vue !</span>
          <span class="kw">This</span>\\*TaskCount\\SetValue(currentCount)
          <span class="kw">This</span>\\*StatusMessage\\SetValue(<span class="str">"Tâche ajoutée : "</span> + title)
          <span class="kw">This</span>\\*TaskTitle\\SetValue(<span class="str">""</span>) <span class="comment">; Vide automatiquement le champ de saisie</span>
        <span class="kw">Else</span>
          <span class="kw">This</span>\\*StatusMessage\\SetValue(<span class="str">"Veuillez saisir un texte pour la tâche !"</span>)
        <span class="kw">EndIf</span>

      <span class="kw">Case</span> <span class="kw">#CMD_CLEAR_ALL</span>
        <span class="kw">This</span>\\*TaskCount\\SetValue(<span class="num">0</span>)
        <span class="kw">This</span>\\*TaskTitle\\SetValue(<span class="str">""</span>)
        <span class="kw">This</span>\\*StatusMessage\\SetValue(<span class="str">"Toutes les tâches ont été effacées."</span>)
    <span class="kw">EndSelect</span>
  }}
}}</code></pre>
  </div>

  <!-- MODULE 6 -->
  <h1><span>3️⃣</span> Module 6 : Étape 3 — Concevoir la Vue en XML</h1>
  
  <p>Grâce au moteur <code>XMLLoader</code>, l'interface graphique est décrite dans <code>views/MainView.xml</code> :</p>

  <div class="code-container">
    <div class="code-header">
      <span class="code-title">views/MainView.xml</span>
      <span class="code-badge">Vue Déclarative XML</span>
    </div>
    <pre><code><span class="str">&lt;Window Title="Mon Gestionnaire Réactif PureBasic OOP" Width="480" Height="300"&gt;</span>
  <span class="comment">&lt;!-- StackPanel vertical avec marge globale et espacement automatique --&gt;</span>
  <span class="kw">&lt;StackPanel</span> Margin=<span class="str">"20"</span> Spacing=<span class="str">"12"</span><span class="kw">&gt;</span>
    
    <span class="comment">&lt;!-- Titre statique --&gt;</span>
    <span class="kw">&lt;Label</span> Text=<span class="str">"Ajouter une nouvelle tâche :"</span> <span class="kw">/&gt;</span>

    <span class="comment">&lt;!-- Saisie liée bidirectionnellement à la propriété TaskTitle --&gt;</span>
    <span class="kw">&lt;TextBox</span> Text=<span class="str">"{{Binding TaskTitle, Mode=TwoWay}}"</span> <span class="kw">/&gt;</span>

    <span class="comment">&lt;!-- Panneau horizontal pour les boutons d'action --&gt;</span>
    <span class="kw">&lt;StackPanel</span> Orientation=<span class="str">"Horizontal"</span> Spacing=<span class="str">"10"</span><span class="kw">&gt;</span>
      <span class="kw">&lt;Button</span> Text=<span class="str">"➕ Ajouter la tâche"</span> Command=<span class="str">"AddTaskCommand"</span> <span class="kw">/&gt;</span>
      <span class="kw">&lt;Button</span> Text=<span class="str">"🗑️ Tout effacer"</span> Command=<span class="str">"ClearAllCommand"</span> <span class="kw">/&gt;</span>
    <span class="kw">&lt;/StackPanel&gt;</span>

    <span class="comment">&lt;!-- Séparateur visuel / Cadre avec compteur et statut lié --&gt;</span>
    <span class="kw">&lt;GroupBox</span> Text=<span class="str">"Tableau de bord"</span><span class="kw">&gt;</span>
      <span class="kw">&lt;StackPanel</span> Margin=<span class="str">"12"</span> Spacing=<span class="str">"6"</span><span class="kw">&gt;</span>
        <span class="kw">&lt;Label</span> Text=<span class="str">"{{Binding StatusMessage}}"</span> <span class="kw">/&gt;</span>
        <span class="kw">&lt;Label</span> Text=<span class="str">"Nombre total de tâches : {{Binding TaskCount}}"</span> <span class="kw">/&gt;</span>
      <span class="kw">&lt;/StackPanel&gt;</span>
    <span class="kw">&lt;/GroupBox&gt;</span>

  <span class="kw">&lt;/StackPanel&gt;</span>
<span class="str">&lt;/Window&gt;</span></code></pre>
  </div>

  <!-- MODULE 7 -->
  <h1><span>4️⃣</span> Module 7 : Étape 4 — Le Point d'Entrée Principal</h1>
  
  <p>L'assemblage final dans <code>main.pb</code> ne nécessite que <strong>quelques lignes de code</strong> :</p>

  <div class="code-container">
    <div class="code-header">
      <span class="code-title">main.pb</span>
      <span class="code-badge">Point d'Entrée PureBasic</span>
    </div>
    <pre><code><span class="comment">; ============================================================================</span>
<span class="comment">; main.pb - Lancement de l'application PureBasic OOP / MVVM</span>
<span class="comment">; ============================================================================</span>
<span class="kw">EnableExplicit</span>

<span class="kw">XIncludeFile</span> <span class="str">"src/ui/UI.pbi"</span>
<span class="kw">XIncludeFile</span> <span class="str">"constants/AppConstants.pbi"</span>
<span class="kw">XIncludeFile</span> <span class="str">"viewmodels/TaskViewModel.pbo"</span>

<span class="comment">; 1. Création de l'application centrale</span>
<span class="kw">Protected</span> *app.UI::Application = <span class="kw">NewObject</span>(UI::Application)

<span class="comment">; 2. Instanciation du ViewModel</span>
<span class="kw">Protected</span> *vm.TaskViewModel = <span class="kw">NewObject</span>(TaskViewModel)

<span class="comment">; 3. Chargement de la vue XML et liaison automatique (DataBinding)</span>
<span class="kw">Protected</span> xmlContent.s = <span class="str">""</span>
<span class="kw">If</span> ReadFile(<span class="num">0</span>, <span class="str">"views/MainView.xml"</span>)
  xmlContent = ReadString(<span class="num">0</span>, <span class="kw">#PB_File_IgnoreEOL</span> | <span class="kw">#PB_UTF8</span>)
  CloseFile(<span class="num">0</span>)
<span class="kw">EndIf</span>

<span class="kw">Protected</span> *window.UI::Window = UI::XMLLoader::LoadAndBindXML(xmlContent, *vm)

<span class="kw">If</span> *window
  <span class="comment">; 4. Affichage et boucle d'exécution</span>
  *window\\Show()
  *app\\Run()
<span class="kw">EndIf</span></code></pre>
  </div>

  <div class="callout callout-tip">
    <div class="callout-title">🎉 Résultat Immédiat !</div>
    <p>Lorsque vous lancez <code>main.pb</code> :
      <ul>
        <li>Tapez du texte dans le <code>TextBox</code> -&gt; la propriété <code>TaskTitle</code> du ViewModel est synchronisée en temps réel.</li>
        <li>Cliquez sur « Ajouter » -&gt; <code>OnCommand()</code> est appelée, le compteur passe à 1, le message d'état change, et le <code>TextBox</code> se vide tout seul !</li>
      </ul>
    </p>
  </div>

  <!-- MODULE 8 -->
  <h1><span>📚</span> Module 8 : Tableau Récapitulatif & Aide F1</h1>

  <h2>8.1. Les 18 Contrôles UI Disponibles</h2>
  <table>
    <tr><th>Contrôle OOP</th><th>Gadget PureBasic</th><th>Usage Type</th></tr>
    <tr><td><code>UI::Button</code></td><td><code>ButtonGadget</code></td><td>Boutons poussoirs avec commandes MVVM</td></tr>
    <tr><td><code>UI::TextBox</code></td><td><code>StringGadget</code></td><td>Saisie de texte avec TwoWay Binding</td></tr>
    <tr><td><code>UI::Editor</code></td><td><code>EditorGadget</code></td><td>Édition multiligne de code ou texte riche</td></tr>
    <tr><td><code>UI::CheckBox</code></td><td><code>CheckBoxGadget</code></td><td>Coche booléenne</td></tr>
    <tr><td><code>UI::RadioButton</code></td><td><code>OptionGadget</code></td><td>Choix exclusif parmi un groupe</td></tr>
    <tr><td><code>UI::ComboBox</code></td><td><code>ComboBoxGadget</code></td><td>Menu déroulant de sélection</td></tr>
    <tr><td><code>UI::ListView</code></td><td><code>ListViewGadget</code></td><td>Liste verticale d'éléments</td></tr>
    <tr><td><code>UI::ListIcon</code></td><td><code>ListIconGadget</code></td><td>Tableau multicolonne avec icônes</td></tr>
    <tr><td><code>UI::TreeView</code></td><td><code>TreeGadget</code></td><td>Arborescence hiérarchique avec sous-niveaux</td></tr>
    <tr><td><code>UI::DatePicker</code></td><td><code>DateGadget</code></td><td>Sélecteur de date et calendrier</td></tr>
    <tr><td><code>UI::SpinBox</code></td><td><code>SpinGadget</code></td><td>Saisie numérique avec flèches +/-</td></tr>
    <tr><td><code>UI::Slider</code></td><td><code>TrackBarGadget</code></td><td>Curseur de réglage numérique continu</td></tr>
    <tr><td><code>UI::ProgressBar</code></td><td><code>ProgressBarGadget</code></td><td>Indicateur de progression de tâche</td></tr>
    <tr><td><code>UI::GroupBox</code></td><td><code>FrameGadget</code></td><td>Cadre visuel de regroupement</td></tr>
    <tr><td><code>UI::Label</code></td><td><code>TextGadget</code></td><td>Texte statique ou informatif</td></tr>
    <tr><td><code>UI::ToggleSwitch</code></td><td><code>CanvasGadget</code></td><td>Interrupteur animé ON/OFF moderne</td></tr>
    <tr><td><code>UI::TabControl</code></td><td><code>PanelGadget</code></td><td>Conteneur à onglets modulaires</td></tr>
  </table>

  <h2>8.2. Touche d'Aide F1 dans l'IDE</h2>
  <p>Dans l'IDE PureBasic, placez à tout moment votre curseur sur un mot-clé (<code>Class</code>, <code>Method</code>, <code>Super</code>, <code>Property</code>...) ou un composant UI (<code>Button</code>, <code>Editor</code>, <code>Grid</code>, <code>ObservableObject</code>...) et appuyez sur <strong>F1</strong> pour ouvrir directement sa fiche d'aide avec son arbre d'héritage et ses exemples.</p>

  <div class="callout callout-warn">
    <div class="callout-title">🚀 À Vous de Jouer !</div>
    <p>Vous possédez désormais toutes les bases pour structurer des logiciels professionnels, maintenables et évolutifs en PureBasic grâce à la POO et au MVVM. Bon développement !</p>
  </div>

</body>
</html>
"""
    file_path = os.path.join(DOC_DIR, "formation_debuter_pb_oop_mvvm_FR.html")
    with open(file_path, "w", encoding="utf-8") as f:
        f.write(html_content)
    print(f"Generated: {file_path}")

def generate_english():
    html_content = f"""<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Training Guide : Getting Started with PureBasic OOP & MVVM</title>
  <style>
{CSS_PRINT_STYLES}
  </style>
</head>
<body>
  <button class="print-btn" onclick="window.print()">🖨️ Print / Export to PDF</button>

  <!-- COVER PAGE -->
  <div class="cover-page">
    <div class="cover-header">
      <img src="html/assets/PB_OOP_LOGO.jpeg" alt="Logo" class="cover-logo">
      <div>
        <div class="cover-brand">PureBasic OOP Framework</div>
        <span class="cover-badge">Official Training Guide</span>
      </div>
    </div>
    
    <div class="cover-body">
      <h1 class="cover-title" style="page-break-before: avoid; border: none; padding: 0;">Getting Started with OOP<br>& the MVVM Pattern</h1>
      <div class="cover-subtitle">Step-by-step creation of your first modern reactive application</div>
      <p class="cover-desc">
        A comprehensive hands-on tutorial for PureBasic developers structuring applications with MVVM architecture, WPF-style responsive layouts, standardized directory layout, and two-way DataBinding.
      </p>
    </div>
    
    <div class="cover-footer">
      <div class="cover-author">
        Author: <strong>MicrodevWeb</strong><br>
        Framework: PureBasic OOP v1.2 / v2.0
      </div>
      <div class="cover-meta">
        Step-by-step training manual<br>
        PureBasic 6.x Windows / Linux / macOS
      </div>
    </div>
  </div>

  <!-- MODULE 1 -->
  <h1 class="first-h1"><span>📦</span> Module 1: Why OOP & MVVM in PureBasic?</h1>
  
  <p>PureBasic has always excelled at raw execution speed, compact binary footprints, and straightforward procedural syntax. However, as graphical applications grow in complexity, procedural code often runs into familiar hurdles:</p>
  <ul>
    <li><strong>Spaghetti Event Loops</strong>: Massive <code>WaitWindowEvent()</code> loops containing dozens of nested <code>Select EventGadget()</code> blocks.</li>
    <li><strong>Tight Coupling</strong>: Business calculation logic gets intertwined with <code>SetGadgetText()</code> and <code>GetGadgetText()</code> calls.</li>
    <li><strong>Tedious Coordinate Math</strong>: Manual calculation of pixel coordinates and sizes during <code>#PB_Event_SizeWindow</code> events.</li>
  </ul>

  <div class="callout callout-tip">
    <div class="callout-title">💡 The PureBasic OOP Solution</div>
    <p>This framework brings enterprise software design standards: <strong>reusable classes (.pbo)</strong>, <strong>WPF-style responsive box models (StackPanel, Grid)</strong>, and <strong>MVVM (Model-View-ViewModel)</strong> with automatic two-way data synchronization without manual boilerplate.</p>
  </div>

  <h2>1.2. What We Will Build Together</h2>
  <p>Throughout this tutorial, we will construct a clean, practical application: <strong>"Mini Reactive Task Manager & Counter"</strong>.</p>
  <p>The app lets users type task descriptions, click an Add button, and see live counter metrics and status feedback update automatically via <em>DataBinding</em>.</p>

  <!-- MODULE 2 : DIRECTORY LAYOUT & INCLUDES -->
  <h1><span>📁</span> Module 2: Project Directory Layout & Include Strategy</h1>
  
  <p>A professional MVVM architecture relies on a clean separation of concerns in your project tree. Here is the recommended directory structure:</p>

  <div class="diagram-box">
MyMVVMProject/
│
├── src/                          &lt;-- PureBasic OOP Framework (or shared path)
│   ├── core/                    &lt;-- Object, List, Vector, Memory, Exceptions
│   └── ui/
│       ├── UI.pbi               &lt;-- MASTER ENTRY POINT (Core + UI + MVVM + XMLLoader)
│       ├── Component.pbo        &lt;-- WPF Base (Alignments, Margins, Arrange)
│       ├── Gadget.pbo           &lt;-- Encapsulation of all 18 native gadgets
│       ├── controls/            &lt;-- Editor, ListView, TreeView, DatePicker...
│       ├── layouts/             &lt;-- StackPanel, DockPanel, Grid
│       ├── mvvm/
│       │   ├── MVVM.pbi         &lt;-- STANDALONE MVVM ENTRY POINT (Headless / Models)
│       │   ├── ObservableObject.pbi
│       │   ├── ViewModelBase.pbi
│       │   ├── Property.pbi
│       │   └── BindingEngine.pbi
│       └── XMLLoader.pbi        &lt;-- XML View Parser and Binder
│
├── constants/
│   └── AppConstants.pbi         &lt;-- Shared Property & Command Identifiers
│
├── models/
│   └── TaskModel.pbi            &lt;-- Data structures & pure business logic
│
├── viewmodels/
│   └── TaskViewModel.pbo        &lt;-- ViewModel class inheriting MVVM::ViewModelBase
│
├── views/
│   └── MainView.xml             &lt;-- Declarative XML User Interface
│
└── main.pb                      &lt;-- Main Application Entry Point
  </div>

  <h2>2.1. Two Framework Inclusion Strategies</h2>
  <p>Depending on your architecture needs, you have two safe entry points using <code>XIncludeFile</code>:</p>
  <ul>
    <li><strong><code>XIncludeFile "src/ui/UI.pbi"</code> (Recommended for GUI apps)</strong>: Includes the entire framework in a single line (Core OOP, 18 UI Controls, WPF responsive layouts, complete MVVM subsystem, and XMLLoader engine).</li>
    <li><strong><code>XIncludeFile "src/ui/mvvm/MVVM.pbi"</code> (For Headless / Testing / Non-GUI models)</strong>: Includes only the MVVM subsystem (ObservableObject, ViewModelBase, typed properties, RelayCommand, BindingEngine) without loading GUI controls.</li>
  </ul>

  <h2>2.2. Standard Include Order in <code>main.pb</code></h2>
  <p>To ensure compiler and transpiler resolve all types and identifiers cleanly, always follow this order with <code>XIncludeFile</code>:</p>

  <div class="code-container">
    <div class="code-header">
      <span class="code-title">Standard Include Order</span>
      <span class="code-badge">Best Practice</span>
    </div>
    <pre><code><span class="kw">EnableExplicit</span>

<span class="comment">; 1. ALWAYS FIRST: UI & MVVM Framework Engine (or src/ui/mvvm/MVVM.pbi)</span>
<span class="kw">XIncludeFile</span> <span class="str">"src/ui/UI.pbi"</span>

<span class="comment">; 2. SECOND: Shared Property and Command Constants</span>
<span class="kw">XIncludeFile</span> <span class="str">"constants/AppConstants.pbi"</span>

<span class="comment">; 3. THIRD: Data Models (if any)</span>
<span class="comment">; XIncludeFile "models/TaskModel.pbi"</span>

<span class="comment">; 4. FOURTH: ViewModel Classes (.pbo transpiled)</span>
<span class="kw">XIncludeFile</span> <span class="str">"viewmodels/TaskViewModel.pbo"</span></code></pre>
  </div>

  <!-- MODULE 3 -->
  <h1><span>🧩</span> Module 3: Understanding MVVM in 5 Minutes</h1>
  
  <p>The <strong>MVVM</strong> architecture neatly divides your application into three distinct responsibilities:</p>

  <div class="diagram-box">
┌─────────────────────────┐         ┌─────────────────────────┐
│       VIEW (UI)         │         │   VIEWMODEL (Engine)    │
│  MainView.xml or OOP UI │ ◄─────► │  Observable Properties  │
│   TextBox, Button, List │ Binding │  StringProperty, Int... │
└─────────────────────────┘         └────────────┬────────────┘
                                                 │ Logic
                                    ┌────────────▼────────────┐
                                    │       MODEL (Data)      │
                                    │    Structures / DB      │
                                    └─────────────────────────┘
  </div>

  <ul>
    <li><strong>Model</strong>: Raw business entities, database records, and file storage.</li>
    <li><strong>ViewModel</strong>: The reactive brain. Inherits from <code>MVVM::ViewModelBase</code> and manages <strong>Observable Properties</strong> (<code>StringProperty</code>, <code>IntProperty</code>). It automatically notifies listeners when values change.</li>
    <li><strong>View</strong>: Declarative user interface written in XML or constructed using OOP controls. Controls bind to ViewModel properties using <code>{{Binding PropertyName}}</code>.</li>
    <li><strong>BindingEngine</strong>: The synchronizer. Handles two-way binding (<em>TwoWay</em>): user keystrokes update the ViewModel, and ViewModel modifications automatically refresh the UI!</li>
  </ul>

  <!-- MODULE 4 -->
  <h1><span>1️⃣</span> Module 4: Step 1 — Shared Constants</h1>
  
  <p>To eliminate typos between XML templates and ViewModel code, we place constants in <code>constants/AppConstants.pbi</code>:</p>

  <div class="code-container">
    <div class="code-header">
      <span class="code-title">constants/AppConstants.pbi</span>
      <span class="code-badge">Shared Constants</span>
    </div>
    <pre><code><span class="comment">; ============================================================================</span>
<span class="comment">; AppConstants.pbi - Declarative Identifiers for Bindings & Commands</span>
<span class="comment">; ============================================================================</span>

<span class="comment">; Observable Property Names (Bound to UI)</span>
<span class="kw">#PROP_TASK_TITLE</span>  = <span class="str">"TaskTitle"</span>
<span class="kw">#PROP_TASK_COUNT</span>  = <span class="str">"TaskCount"</span>
<span class="kw">#PROP_STATUS_MSG</span>  = <span class="str">"StatusMessage"</span>

<span class="comment">; Command Names (Triggered by Buttons)</span>
<span class="kw">#CMD_ADD_TASK</span>     = <span class="str">"AddTaskCommand"</span>
<span class="kw">#CMD_CLEAR_ALL</span>    = <span class="str">"ClearAllCommand"</span></code></pre>
  </div>

  <!-- MODULE 5 -->
  <h1><span>2️⃣</span> Module 5: Step 2 — Building the Reactive ViewModel</h1>
  
  <p>The ViewModel manages state and processes user commands. It has <strong>zero coupling</strong> to UI gadget IDs or window handles.</p>

  <div class="code-container">
    <div class="code-header">
      <span class="code-title">viewmodels/TaskViewModel.pbo</span>
      <span class="code-badge">OOP Class (.pbo)</span>
    </div>
    <pre><code><span class="comment">; ============================================================================</span>
<span class="comment">; TaskViewModel.pbo - Reactive Task Manager ViewModel</span>
<span class="comment">; ============================================================================</span>
<span class="kw">XIncludeFile</span> <span class="str">"../src/ui/UI.pbi"</span>        <span class="comment">; or "../src/ui/mvvm/MVVM.pbi"</span>
<span class="kw">XIncludeFile</span> <span class="str">"../constants/AppConstants.pbi"</span>

<span class="kw">Class</span> TaskViewModel <span class="kw">Extends</span> MVVM::ViewModelBase {{
  <span class="kw">Public</span> *TaskTitle.MVVM::StringProperty
  <span class="kw">Public</span> *TaskCount.MVVM::IntProperty
  <span class="kw">Public</span> *StatusMessage.MVVM::StringProperty

  <span class="comment">; --- Constructor: Register observable properties ---</span>
  <span class="kw">Public Method</span> Init() {{
    <span class="kw">Super</span>\\Init()
    
    <span class="comment">; Register properties in the MVVM property registry</span>
    <span class="kw">This</span>\\*TaskTitle     = <span class="kw">This</span>\\BindString(<span class="kw">#PROP_TASK_TITLE</span>, <span class="str">""</span>)
    <span class="kw">This</span>\\*TaskCount     = <span class="kw">This</span>\\BindInt(<span class="kw">#PROP_TASK_COUNT</span>, <span class="num">0</span>)
    <span class="kw">This</span>\\*StatusMessage = <span class="kw">This</span>\\BindString(<span class="kw">#PROP_STATUS_MSG</span>, <span class="str">"Ready - No tasks registered."</span>)
  }}

  <span class="comment">; --- UI Command Dispatcher ---</span>
  <span class="kw">Public Override Method</span> OnCommand(cmdName.s) {{
    <span class="kw">Select</span> cmdName
      <span class="kw">Case</span> <span class="kw">#CMD_ADD_TASK</span>
        <span class="kw">Protected</span> title.s = Trim(<span class="kw">This</span>\\*TaskTitle\\GetValue())
        
        <span class="kw">If</span> title &lt;&gt; <span class="str">""</span>
          <span class="kw">Protected</span> currentCount.i = <span class="kw">This</span>\\*TaskCount\\GetValue() + <span class="num">1</span>
          
          <span class="comment">; Update properties -> UI automatically refreshes!</span>
          <span class="kw">This</span>\\*TaskCount\\SetValue(currentCount)
          <span class="kw">This</span>\\*StatusMessage\\SetValue(<span class="str">"Task added: "</span> + title)
          <span class="kw">This</span>\\*TaskTitle\\SetValue(<span class="str">""</span>) <span class="comment">; Automatically clears input box</span>
        <span class="kw">Else</span>
          <span class="kw">This</span>\\*StatusMessage\\SetValue(<span class="str">"Please enter a task title first!"</span>)
        <span class="kw">EndIf</span>

      <span class="kw">Case</span> <span class="kw">#CMD_CLEAR_ALL</span>
        <span class="kw">This</span>\\*TaskCount\\SetValue(<span class="num">0</span>)
        <span class="kw">This</span>\\*TaskTitle\\SetValue(<span class="str">""</span>)
        <span class="kw">This</span>\\*StatusMessage\\SetValue(<span class="str">"All tasks have been cleared."</span>)
    <span class="kw">EndSelect</span>
  }}
}}</code></pre>
  </div>

  <!-- MODULE 6 -->
  <h1><span>3️⃣</span> Module 6: Step 3 — Designing the XML View</h1>
  
  <p>Using <code>XMLLoader</code>, the user interface is defined in <code>views/MainView.xml</code>:</p>

  <div class="code-container">
    <div class="code-header">
      <span class="code-title">views/MainView.xml</span>
      <span class="code-badge">Declarative XML View</span>
    </div>
    <pre><code><span class="str">&lt;Window Title="PureBasic OOP Task Manager" Width="480" Height="300"&gt;</span>
  <span class="comment">&lt;!-- Vertical StackPanel with outer margin and child spacing --&gt;</span>
  <span class="kw">&lt;StackPanel</span> Margin=<span class="str">"20"</span> Spacing=<span class="str">"12"</span><span class="kw">&gt;</span>
    
    <span class="comment">&lt;!-- Static Label --&gt;</span>
    <span class="kw">&lt;Label</span> Text=<span class="str">"Add a new task:"</span> <span class="kw">/&gt;</span>

    <span class="comment">&lt;!-- Input box bound two-way to TaskTitle --&gt;</span>
    <span class="kw">&lt;TextBox</span> Text=<span class="str">"{{Binding TaskTitle, Mode=TwoWay}}"</span> <span class="kw">/&gt;</span>

    <span class="comment">&lt;!-- Horizontal button action panel --&gt;</span>
    <span class="kw">&lt;StackPanel</span> Orientation=<span class="str">"Horizontal"</span> Spacing=<span class="str">"10"</span><span class="kw">&gt;</span>
      <span class="kw">&lt;Button</span> Text=<span class="str">"➕ Add Task"</span> Command=<span class="str">"AddTaskCommand"</span> <span class="kw">/&gt;</span>
      <span class="kw">&lt;Button</span> Text=<span class="str">"🗑️ Clear All"</span> Command=<span class="str">"ClearAllCommand"</span> <span class="kw">/&gt;</span>
    <span class="kw">&lt;/StackPanel&gt;</span>

    <span class="comment">&lt;!-- Group Box dashboard with bound labels --&gt;</span>
    <span class="kw">&lt;GroupBox</span> Text=<span class="str">"Task Dashboard"</span><span class="kw">&gt;</span>
      <span class="kw">&lt;StackPanel</span> Margin=<span class="str">"12"</span> Spacing=<span class="str">"6"</span><span class="kw">&gt;</span>
        <span class="kw">&lt;Label</span> Text=<span class="str">"{{Binding StatusMessage}}"</span> <span class="kw">/&gt;</span>
        <span class="kw">&lt;Label</span> Text=<span class="str">"Total Tasks Count: {{Binding TaskCount}}"</span> <span class="kw">/&gt;</span>
      <span class="kw">&lt;/StackPanel&gt;</span>
    <span class="kw">&lt;/GroupBox&gt;</span>

  <span class="kw">&lt;/StackPanel&gt;</span>
<span class="str">&lt;/Window&gt;</span></code></pre>
  </div>

  <!-- MODULE 7 -->
  <h1><span>4️⃣</span> Module 7: Step 4 — Main Entry Point</h1>
  
  <p>Bootstrapping the app in <code>main.pb</code> takes only a few lines:</p>

  <div class="code-container">
    <div class="code-header">
      <span class="code-title">main.pb</span>
      <span class="code-badge">Main Entry Point</span>
    </div>
    <pre><code><span class="comment">; ============================================================================</span>
<span class="comment">; main.pb - Launching PureBasic OOP / MVVM Application</span>
<span class="comment">; ============================================================================</span>
<span class="kw">EnableExplicit</span>

<span class="kw">XIncludeFile</span> <span class="str">"src/ui/UI.pbi"</span>
<span class="kw">XIncludeFile</span> <span class="str">"constants/AppConstants.pbi"</span>
<span class="kw">XIncludeFile</span> <span class="str">"viewmodels/TaskViewModel.pbo"</span>

<span class="comment">; 1. Create Core Application</span>
<span class="kw">Protected</span> *app.UI::Application = <span class="kw">NewObject</span>(UI::Application)

<span class="comment">; 2. Instantiate ViewModel</span>
<span class="kw">Protected</span> *vm.TaskViewModel = <span class="kw">NewObject</span>(TaskViewModel)

<span class="comment">; 3. Load XML View and bind to ViewModel</span>
<span class="kw">Protected</span> xmlContent.s = <span class="str">""</span>
<span class="kw">If</span> ReadFile(<span class="num">0</span>, <span class="str">"views/MainView.xml"</span>)
  xmlContent = ReadString(<span class="num">0</span>, <span class="kw">#PB_File_IgnoreEOL</span> | <span class="kw">#PB_UTF8</span>)
  CloseFile(<span class="num">0</span>)
<span class="kw">EndIf</span>

<span class="kw">Protected</span> *window.UI::Window = UI::XMLLoader::LoadAndBindXML(xmlContent, *vm)

<span class="kw">If</span> *window
  <span class="comment">; 4. Show Window and Run Event Loop</span>
  *window\\Show()
  *app\\Run()
<span class="kw">EndIf</span></code></pre>
  </div>

  <div class="callout callout-tip">
    <div class="callout-title">🎉 Live Reactive Behavior!</div>
    <p>When running <code>main.pb</code>:
      <ul>
        <li>Typing into the <code>TextBox</code> immediately updates the ViewModel's <code>TaskTitle</code>.</li>
        <li>Clicking "Add Task" invokes <code>OnCommand()</code>, increments the counter, updates the status message, and clears the input box automatically!</li>
      </ul>
    </p>
  </div>

  <!-- MODULE 8 -->
  <h1><span>📚</span> Module 8: UI Controls Reference & F1 Help</h1>

  <h2>8.1. 18 Encapsulated UI Controls</h2>
  <table>
    <tr><th>OOP Control</th><th>Native PB Gadget</th><th>Primary Use Case</th></tr>
    <tr><td><code>UI::Button</code></td><td><code>ButtonGadget</code></td><td>Clickable action buttons with MVVM commands</td></tr>
    <tr><td><code>UI::TextBox</code></td><td><code>StringGadget</code></td><td>Single-line text input with two-way binding</td></tr>
    <tr><td><code>UI::Editor</code></td><td><code>EditorGadget</code></td><td>Multiline plain or formatted text editor</td></tr>
    <tr><td><code>UI::CheckBox</code></td><td><code>CheckBoxGadget</code></td><td>Boolean checked state toggle</td></tr>
    <tr><td><code>UI::RadioButton</code></td><td><code>OptionGadget</code></td><td>Mutually exclusive choice in a group</td></tr>
    <tr><td><code>UI::ComboBox</code></td><td><code>ComboBoxGadget</code></td><td>Dropdown selection menu</td></tr>
    <tr><td><code>UI::ListView</code></td><td><code>ListViewGadget</code></td><td>Vertical list of string items</td></tr>
    <tr><td><code>UI::ListIcon</code></td><td><code>ListIconGadget</code></td><td>Multi-column grid with icons and row selection</td></tr>
    <tr><td><code>UI::TreeView</code></td><td><code>TreeGadget</code></td><td>Hierarchical tree view with expandable nodes</td></tr>
    <tr><td><code>UI::DatePicker</code></td><td><code>DateGadget</code></td><td>Date picker and calendar dropdown</td></tr>
    <tr><td><code>UI::SpinBox</code></td><td><code>SpinGadget</code></td><td>Numeric entry field with up/down stepper buttons</td></tr>
    <tr><td><code>UI::Slider</code></td><td><code>TrackBarGadget</code></td><td>Continuous numerical range slider</td></tr>
    <tr><td><code>UI::ProgressBar</code></td><td><code>ProgressBarGadget</code></td><td>Task execution progress bar</td></tr>
    <tr><td><code>UI::GroupBox</code></td><td><code>FrameGadget</code></td><td>Visual titled container frame</td></tr>
    <tr><td><code>UI::Label</code></td><td><code>TextGadget</code></td><td>Static or bound informative text</td></tr>
    <tr><td><code>UI::ToggleSwitch</code></td><td><code>CanvasGadget</code></td><td>Animated modern ON/OFF switch</td></tr>
    <tr><td><code>UI::TabControl</code></td><td><code>PanelGadget</code></td><td>Tabbed multi-view container</td></tr>
  </table>

  <h2>8.2. F1 Contextual Help in the IDE</h2>
  <p>In the PureBasic IDE, place your cursor on any OOP keyword (<code>Class</code>, <code>Method</code>, <code>Super</code>, <code>Property</code>...) or UI component (<code>Button</code>, <code>Editor</code>, <code>Grid</code>, <code>ObservableObject</code>...) and press <strong>F1</strong> to open its documentation page with full inheritance trees and examples.</p>

  <div class="callout callout-warn">
    <div class="callout-title">🚀 Ready for Production!</div>
    <p>You now possess all foundational knowledge required to design robust, enterprise-grade, maintainable PureBasic applications with OOP and MVVM. Happy coding!</p>
  </div>

</body>
</html>
"""
    file_path = os.path.join(DOC_DIR, "training_getting_started_pb_oop_mvvm_EN.html")
    with open(file_path, "w", encoding="utf-8") as f:
        f.write(html_content)
    print(f"Generated: {file_path}")

def generate_markdown_french():
    md_content = r"""# Guide de Formation : Débuter avec la POO & le Pattern MVVM en PureBasic

*Concevoir sa première application réactive moderne pas à pas*  
**Auteur :** MicrodevWeb  
**Framework :** PureBasic OOP v1.2 / v2.0  
**Compatibilité :** PureBasic 6.x (Windows, Linux, macOS)  

---

## 📦 Module 1 : Pourquoi la POO & le MVVM en PureBasic ?

Depuis toujours, PureBasic excelle par sa rapidité d'exécution, sa légèreté et sa simplicité procédurale. Cependant, dès qu'une interface graphique grandit, le code traditionnel fait face à des limites bien connues :

- **Le syndrome du code « Spaghetti »** : Des boucles d'événements `WaitWindowEvent()` géantes contenant des dizaines de `Select EventGadget()` imbriqués.
- **Le couplage fort** : La logique de calcul est mélangée avec les appels `SetGadgetText()` et `GetGadgetText()`.
- **Le redimensionnement complexe** : Le calcul manuel des coordonnées en pixels de chaque bouton lors des événements `#PB_Event_SizeWindow`.

> **💡 La solution PureBasic OOP**  
> Ce framework apporte les standards modernes du développement d'entreprise : **classes réutilisables (.pbo)**, **modèle de boîte WPF (StackPanel, Grid)** et **MVVM (Model-View-ViewModel)** avec mise à jour automatique sans aucun code de rafraîchissement manuel.

### 1.2. Ce que nous allons construire ensemble
Dans ce guide pratique, nous allons concevoir une application complète : **« Mini Gestionnaire de Tâches & Compteur Réactif »**.

L'application permettra de saisir un titre, de cliquer sur un bouton pour l'ajouter, et verra son compteur et son message d'état se mettre à jour instantanément grâce au *DataBinding*.

---

## 📁 Module 2 : Organisation des Dossiers & Stratégie des Includes

Une architecture MVVM professionnelle repose sur une séparation claire des responsabilités dans l'arborescence de votre projet. Voici la structure recommandée :

```text
MonProjetMVVM/
│
├── src/                          <-- Framework PureBasic OOP (ou chemin partagé)
│   ├── core/                    <-- Object, List, Vector, Memory, Exceptions
│   └── ui/
│       ├── UI.pbi               <-- POINT D'ENTRÉE MASTER (Core + UI + MVVM + XMLLoader)
│       ├── Component.pbo        <-- Socle WPF (Alignements, Marges, Arrange)
│       ├── Gadget.pbo           <-- Encapsulation des 18 gadgets natifs
│       ├── controls/            <-- Editor, ListView, TreeView, DatePicker...
│       ├── layouts/             <-- StackPanel, DockPanel, Grid
│       ├── mvvm/
│       │   ├── MVVM.pbi         <-- POINT D'ENTRÉE MVVM AUTONOME (sans contrôles graphiques)
│       │   ├── ObservableObject.pbi
│       │   ├── ViewModelBase.pbi
│       │   ├── Property.pbi
│       │   └── BindingEngine.pbi
│       └── XMLLoader.pbi        <-- Parseur et chargeur de vues XML
│
├── constants/
│   └── AppConstants.pbi         <-- Noms des propriétés et commandes partagées
│
├── models/
│   └── TaskModel.pbi            <-- Structures de données et logique métier pure
│
├── viewmodels/
│   └── TaskViewModel.pbo        <-- Classe ViewModel héritant de MVVM::ViewModelBase
│
├── views/
│   └── MainView.xml             <-- Définition déclarative de l'interface
│
└── main.pb                      <-- Point d'entrée principal exécutable
```

### 2.1. Les deux options d'inclusion du Framework
Selon vos besoins, vous disposez de deux points d'entrée simples et sécurisés avec `XIncludeFile` :
- **`XIncludeFile "src/ui/UI.pbi"` (Recommandé pour les applications graphiques)** : Inclut tout le framework en une seule ligne (Noyau Core, 18 Contrôles UI, Layouts réactifs WPF, Sous-système MVVM et Moteur XMLLoader).
- **`XIncludeFile "src/ui/mvvm/MVVM.pbi"` (Pour modules ou tests headless)** : Inclut uniquement le moteur MVVM (ObservableObject, ViewModelBase, Propriétés typées, RelayCommand, BindingEngine) sans charger les gadgets graphiques.

### 2.2. L'ordre d'inclusion obligatoire dans votre `main.pb`
Pour garantir que le compilateur et le transpileur résolvent tous les types sans avertissement, respectez toujours cet ordre avec `XIncludeFile` :

```purebasic
EnableExplicit

; 1. TOUJOURS EN PREMIER : Le framework UI & MVVM (ou src/ui/mvvm/MVVM.pbi)
XIncludeFile "src/ui/UI.pbi"

; 2. EN SECOND : Les constantes partagées de Bindings et de Commandes
XIncludeFile "constants/AppConstants.pbi"

; 3. EN TROISIÈME : Les Modèles de données (si existants)
; XIncludeFile "models/TaskModel.pbi"

; 4. EN QUATRIÈME : Les classes ViewModels (.pbo transpilées)
XIncludeFile "viewmodels/TaskViewModel.pbo"
```

---

## 🧩 Module 3 : Comprendre le Pattern MVVM en 5 Minutes

Le pattern **MVVM** sépare clairement votre programme en trois responsabilités distinctes :

```text
┌─────────────────────────┐         ┌─────────────────────────┐
│       VUE (View)        │         │   VIEWMODEL (Moteur)    │
│  MainView.xml ou UI POO │ ◄─────► │  Propriétés Observables │
│   TextBox, Button, List │ Binding │  StringProperty, Int... │
└─────────────────────────┘         └────────────┬────────────┘
                                                 │ Métier
                                    ┌────────────▼────────────┐
                                    │      MODÈLE (Data)      │
                                    │    Structures / BDD     │
                                    └─────────────────────────┘
```

- **Model (Modèle)** : Représente la donnée brute (fichiers, structures, base de données).
- **ViewModel (Modèle de Vue)** : C'est le « cerveau ». Il hérite de `MVVM::ViewModelBase` et expose des **Propriétés Observables** (`StringProperty`, `IntProperty`). Dès qu'une valeur change, il notifie les abonnés.
- **View (Vue)** : C'est l'interface visuelle déclarée en XML ou construite avec les classes UI. Elle se lie aux propriétés via la syntaxe `{Binding NomPropriete}`.
- **BindingEngine (Moteur de Liaison)** : Il assure la liaison bidirectionnelle (*TwoWay*). Lorsque l'utilisateur tape du texte, le ViewModel est mis à jour. Lorsque le ViewModel modifie une variable, le contrôle graphique change tout seul !

---

## 1️⃣ Module 4 : Étape 1 — Les Constantes Partagées

Pour éviter toute faute de frappe entre le fichier XML et le code du ViewModel, nous plaçons les constantes dans `constants/AppConstants.pbi` :

```purebasic
; ============================================================================
; AppConstants.pbi - Identifiants déclaratifs pour les Bindings & Commandes
; ============================================================================

; Noms des Propriétés Observables (Bindées à l'UI)
#PROP_TASK_TITLE  = "TaskTitle"
#PROP_TASK_COUNT  = "TaskCount"
#PROP_STATUS_MSG  = "StatusMessage"

; Noms des Commandes (Déclenchées par les Boutons)
#CMD_ADD_TASK     = "AddTaskCommand"
#CMD_CLEAR_ALL    = "ClearAllCommand"
```

---

## 2️⃣ Module 5 : Étape 2 — Créer le ViewModel Réactif

Le ViewModel encapsule l'état et réagit aux actions. Il n'a **aucune dépendance** envers les fenêtres ou les gadgets PureBasic (pas de `SetGadgetText`).

```purebasic
; ============================================================================
; TaskViewModel.pbo - ViewModel de gestion des tâches
; ============================================================================
XIncludeFile "../src/ui/UI.pbi"        ; ou "../src/ui/mvvm/MVVM.pbi"
XIncludeFile "../constants/AppConstants.pbi"

Class TaskViewModel Extends MVVM::ViewModelBase {
  Public *TaskTitle.MVVM::StringProperty
  Public *TaskCount.MVVM::IntProperty
  Public *StatusMessage.MVVM::StringProperty

  ; --- Constructeur : Initialisation et enregistrement des propriétés ---
  Public Method Init() {
    Super\Init()
    
    ; Enregistrement des propriétés observables dans le registre MVVM
    This\*TaskTitle     = This\BindString(#PROP_TASK_TITLE, "")
    This\*TaskCount     = This\BindInt(#PROP_TASK_COUNT, 0)
    This\*StatusMessage = This\BindString(#PROP_STATUS_MSG, "Prêt - Aucune tâche enregistrée.")
  }

  ; --- Gestionnaire des Commandes UI ---
  Public Override Method OnCommand(cmdName.s) {
    Select cmdName
      Case #CMD_ADD_TASK
        Protected title.s = Trim(This\*TaskTitle\GetValue())
        
        If title <> ""
          Protected currentCount.i = This\*TaskCount\GetValue() + 1
          
          ; Mise à jour des propriétés -> Notification automatique de la Vue !
          This\*TaskCount\SetValue(currentCount)
          This\*StatusMessage\SetValue("Tâche ajoutée : " + title)
          This\*TaskTitle\SetValue("") ; Vide automatiquement le champ de saisie
        Else
          This\*StatusMessage\SetValue("Veuillez saisir un texte pour la tâche !")
        EndIf

      Case #CMD_CLEAR_ALL
        This\*TaskCount\SetValue(0)
        This\*TaskTitle\SetValue("")
        This\*StatusMessage\SetValue("Toutes les tâches ont été effacées.")
    EndSelect
  }
}
```

---

## 3️⃣ Module 6 : Étape 3 — Concevoir la Vue en XML

Grâce au moteur `XMLLoader`, l'interface graphique est décrite dans `views/MainView.xml` :

```xml
<Window Title="Mon Gestionnaire Réactif PureBasic OOP" Width="480" Height="300">
  <!-- StackPanel vertical avec marge globale et espacement automatique -->
  <StackPanel Margin="20" Spacing="12">
    
    <!-- Titre statique -->
    <Label Text="Ajouter une nouvelle tâche :" />

    <!-- Saisie liée bidirectionnellement à la propriété TaskTitle -->
    <TextBox Text="{Binding TaskTitle, Mode=TwoWay}" />

    <!-- Panneau horizontal pour les boutons d'action -->
    <StackPanel Orientation="Horizontal" Spacing="10">
      <Button Text="➕ Ajouter la tâche" Command="AddTaskCommand" />
      <Button Text="🗑️ Tout effacer" Command="ClearAllCommand" />
    </StackPanel>

    <!-- Séparateur visuel / Cadre avec compteur et statut lié -->
    <GroupBox Text="Tableau de bord">
      <StackPanel Margin="12" Spacing="6">
        <Label Text="{Binding StatusMessage}" />
        <Label Text="Nombre total de tâches : {Binding TaskCount}" />
      </StackPanel>
    </GroupBox>

  </StackPanel>
</Window>
```

---

## 4️⃣ Module 7 : Étape 4 — Le Point d'Entrée Principal

L'assemblage final dans `main.pb` ne nécessite que **quelques lignes de code** :

```purebasic
; ============================================================================
; main.pb - Lancement de l'application PureBasic OOP / MVVM
; ============================================================================
EnableExplicit

XIncludeFile "src/ui/UI.pbi"
XIncludeFile "constants/AppConstants.pbi"
XIncludeFile "viewmodels/TaskViewModel.pbo"

; 1. Création de l'application centrale
Protected *app.UI::Application = NewObject(UI::Application)

; 2. Instanciation du ViewModel
Protected *vm.TaskViewModel = NewObject(TaskViewModel)

; 3. Chargement de la vue XML et liaison automatique (DataBinding)
Protected xmlContent.s = ""
If ReadFile(0, "views/MainView.xml")
  xmlContent = ReadString(0, #PB_File_IgnoreEOL | #PB_UTF8)
  CloseFile(0)
EndIf

Protected *window.UI::Window = UI::XMLLoader::LoadAndBindXML(xmlContent, *vm)

If *window
  ; 4. Affichage et boucle d'exécution
  *window\Show()
  *app\Run()
EndIf
```

> **🎉 Résultat Immédiat !**  
> Lorsque vous lancez `main.pb` :  
> - Tapez du texte dans le `TextBox` -> la propriété `TaskTitle` du ViewModel est synchronisée en temps réel.  
> - Cliquez sur « Ajouter » -> `OnCommand()` est appelée, le compteur passe à 1, le message d'état change, et le `TextBox` se vide tout seul !  

---

## 📚 Module 8 : Tableau Récapitulatif & Aide F1

### 8.1. Les 18 Contrôles UI Disponibles

| Contrôle OOP | Gadget PureBasic | Usage Type |
| :--- | :--- | :--- |
| `UI::Button` | `ButtonGadget` | Boutons poussoirs avec commandes MVVM |
| `UI::TextBox` | `StringGadget` | Saisie de texte avec TwoWay Binding |
| `UI::Editor` | `EditorGadget` | Édition multiligne de code ou texte riche |
| `UI::CheckBox` | `CheckBoxGadget` | Coche booléenne |
| `UI::RadioButton` | `OptionGadget` | Choix exclusif parmi un groupe |
| `UI::ComboBox` | `ComboBoxGadget` | Menu déroulant de sélection |
| `UI::ListView` | `ListViewGadget` | Liste verticale d'éléments |
| `UI::ListIcon` | `ListIconGadget` | Tableau multicolonne avec icônes |
| `UI::TreeView` | `TreeGadget` | Arborescence hiérarchique avec sous-niveaux |
| `UI::DatePicker` | `DateGadget` | Sélecteur de date et calendrier |
| `UI::SpinBox` | `SpinGadget` | Saisie numérique avec flèches +/- |
| `UI::Slider` | `TrackBarGadget` | Curseur de réglage numérique continu |
| `UI::ProgressBar` | `ProgressBarGadget` | Indicateur de progression de tâche |
| `UI::GroupBox` | `FrameGadget` | Cadre visuel de regroupement |
| `UI::Label` | `TextGadget` | Texte statique ou informatif |
| `UI::ToggleSwitch` | `CanvasGadget` | Interrupteur animé ON/OFF moderne |
| `UI::TabControl` | `PanelGadget` | Conteneur à onglets modulaires |

### 8.2. Touche d'Aide F1 dans l'IDE
Dans l'IDE PureBasic, placez à tout moment votre curseur sur un mot-clé (`Class`, `Method`, `Super`, `Property`...) ou un composant UI (`Button`, `Editor`, `Grid`, `ObservableObject`...) et appuyez sur **F1** pour ouvrir directement sa fiche d'aide avec son arbre d'héritage et ses exemples.
"""
    file_path = os.path.join(DOC_DIR, "formation_debuter_pb_oop_mvvm_FR.md")
    with open(file_path, "w", encoding="utf-8") as f:
        f.write(md_content)
    print(f"Generated: {file_path}")

def generate_markdown_english():
    md_content = r"""# Training Guide: Getting Started with OOP & the MVVM Pattern in PureBasic

*Step-by-step creation of your first modern reactive application*  
**Author:** MicrodevWeb  
**Framework:** PureBasic OOP v1.2 / v2.0  
**Compatibility:** PureBasic 6.x (Windows, Linux, macOS)  

---

## 📦 Module 1: Why OOP & MVVM in PureBasic?

PureBasic has always excelled at raw execution speed, compact binary footprints, and straightforward procedural syntax. However, as graphical applications grow in complexity, procedural code often runs into familiar hurdles:

- **Spaghetti Event Loops**: Massive `WaitWindowEvent()` loops containing dozens of nested `Select EventGadget()` blocks.
- **Tight Coupling**: Business calculation logic gets intertwined with `SetGadgetText()` and `GetGadgetText()` calls.
- **Tedious Coordinate Math**: Manual calculation of pixel coordinates and sizes during `#PB_Event_SizeWindow` events.

> **💡 The PureBasic OOP Solution**  
> This framework brings enterprise software design standards: **reusable classes (.pbo)**, **WPF-style responsive box models (StackPanel, Grid)**, and **MVVM (Model-View-ViewModel)** with automatic two-way data synchronization without manual boilerplate.

### 1.2. What We Will Build Together
Throughout this tutorial, we will construct a clean, practical application: **"Mini Reactive Task Manager & Counter"**.

The app lets users type task descriptions, click an Add button, and see live counter metrics and status feedback update automatically via *DataBinding*.

---

## 📁 Module 2: Project Directory Layout & Include Strategy

A professional MVVM architecture relies on a clean separation of concerns in your project tree. Here is the recommended directory structure:

```text
MyMVVMProject/
│
├── src/                          <-- PureBasic OOP Framework (or shared path)
│   ├── core/                    <-- Object, List, Vector, Memory, Exceptions
│   └── ui/
│       ├── UI.pbi               <-- MASTER ENTRY POINT (Core + UI + MVVM + XMLLoader)
│       ├── Component.pbo        <-- WPF Base (Alignments, Margins, Arrange)
│       ├── Gadget.pbo           <-- Encapsulation of all 18 native gadgets
│       ├── controls/            <-- Editor, ListView, TreeView, DatePicker...
│       ├── layouts/             <-- StackPanel, DockPanel, Grid
│       ├── mvvm/
│       │   ├── MVVM.pbi         <-- STANDALONE MVVM ENTRY POINT (Headless / Models)
│       │   ├── ObservableObject.pbi
│       │   ├── ViewModelBase.pbi
│       │   ├── Property.pbi
│       │   └── BindingEngine.pbi
│       └── XMLLoader.pbi        <-- XML View Parser and Binder
│
├── constants/
│   └── AppConstants.pbi         <-- Shared Property & Command Identifiers
│
├── models/
│   └── TaskModel.pbi            <-- Data structures & pure business logic
│
├── viewmodels/
│   └── TaskViewModel.pbo        <-- ViewModel class inheriting MVVM::ViewModelBase
│
├── views/
│   └── MainView.xml             <-- Declarative XML User Interface
│
└── main.pb                      <-- Main Application Entry Point
```

### 2.1. Two Framework Inclusion Strategies
Depending on your architecture needs, you have two safe entry points using `XIncludeFile`:
- **`XIncludeFile "src/ui/UI.pbi"` (Recommended for GUI apps)**: Includes the entire framework in a single line (Core OOP, 18 UI Controls, WPF responsive layouts, complete MVVM subsystem, and XMLLoader engine).
- **`XIncludeFile "src/ui/mvvm/MVVM.pbi"` (For Headless / Testing / Non-GUI models)**: Includes only the MVVM subsystem (ObservableObject, ViewModelBase, typed properties, RelayCommand, BindingEngine) without loading GUI controls.

### 2.2. Standard Include Order in `main.pb`
To ensure compiler and transpiler resolve all types and identifiers cleanly, always follow this order with `XIncludeFile`:

```purebasic
EnableExplicit

; 1. ALWAYS FIRST: UI & MVVM Framework Engine (or src/ui/mvvm/MVVM.pbi)
XIncludeFile "src/ui/UI.pbi"

; 2. SECOND: Shared Property and Command Constants
XIncludeFile "constants/AppConstants.pbi"

; 3. THIRD: Data Models (if any)
; XIncludeFile "models/TaskModel.pbi"

; 4. FOURTH: ViewModel Classes (.pbo transpiled)
XIncludeFile "viewmodels/TaskViewModel.pbo"
```

---

## 🧩 Module 3: Understanding MVVM in 5 Minutes

The **MVVM** architecture neatly divides your application into three distinct responsibilities:

```text
┌─────────────────────────┐         ┌─────────────────────────┐
│       VIEW (UI)         │         │   VIEWMODEL (Engine)    │
│  MainView.xml or OOP UI │ ◄─────► │  Observable Properties  │
│   TextBox, Button, List │ Binding │  StringProperty, Int... │
└─────────────────────────┘         └────────────┬────────────┘
                                                 │ Logic
                                    ┌────────────▼────────────┐
                                    │       MODEL (Data)      │
                                    │    Structures / DB      │
                                    └─────────────────────────┘
```

- **Model**: Raw business entities, database records, and file storage.
- **ViewModel**: The reactive brain. Inherits from `MVVM::ViewModelBase` and manages **Observable Properties** (`StringProperty`, `IntProperty`). It automatically notifies listeners when values change.
- **View**: Declarative user interface written in XML or constructed using OOP controls. Controls bind to ViewModel properties using `{Binding PropertyName}`.
- **BindingEngine**: The synchronizer. Handles two-way binding (*TwoWay*): user keystrokes update the ViewModel, and ViewModel modifications automatically refresh the UI!

---

## 1️⃣ Module 4: Step 1 — Shared Constants

To eliminate typos between XML templates and ViewModel code, we place constants in `constants/AppConstants.pbi`:

```purebasic
; ============================================================================
; AppConstants.pbi - Declarative Identifiers for Bindings & Commands
; ============================================================================

; Observable Property Names (Bound to UI)
#PROP_TASK_TITLE  = "TaskTitle"
#PROP_TASK_COUNT  = "TaskCount"
#PROP_STATUS_MSG  = "StatusMessage"

; Command Names (Triggered by Buttons)
#CMD_ADD_TASK     = "AddTaskCommand"
#CMD_CLEAR_ALL    = "ClearAllCommand"
```

---

## 2️⃣ Module 5: Step 2 — Building the Reactive ViewModel

The ViewModel manages state and processes user commands. It has **zero coupling** to UI gadget IDs or window handles.

```purebasic
; ============================================================================
; TaskViewModel.pbo - Reactive Task Manager ViewModel
; ============================================================================
XIncludeFile "../src/ui/UI.pbi"        ; or "../src/ui/mvvm/MVVM.pbi"
XIncludeFile "../constants/AppConstants.pbi"

Class TaskViewModel Extends MVVM::ViewModelBase {
  Public *TaskTitle.MVVM::StringProperty
  Public *TaskCount.MVVM::IntProperty
  Public *StatusMessage.MVVM::StringProperty

  ; --- Constructor: Register observable properties ---
  Public Method Init() {
    Super\Init()
    
    ; Register properties in the MVVM property registry
    This\*TaskTitle     = This\BindString(#PROP_TASK_TITLE, "")
    This\*TaskCount     = This\BindInt(#PROP_TASK_COUNT, 0)
    This\*StatusMessage = This\BindString(#PROP_STATUS_MSG, "Ready - No tasks registered.")
  }

  ; --- UI Command Dispatcher ---
  Public Override Method OnCommand(cmdName.s) {
    Select cmdName
      Case #CMD_ADD_TASK
        Protected title.s = Trim(This\*TaskTitle\GetValue())
        
        If title <> ""
          Protected currentCount.i = This\*TaskCount\GetValue() + 1
          
          ; Update properties -> UI automatically refreshes!
          This\*TaskCount\SetValue(currentCount)
          This\*StatusMessage\SetValue("Task added: " + title)
          This\*TaskTitle\SetValue("") ; Automatically clears input box
        Else
          This\*StatusMessage\SetValue("Please enter a task title first!")
        EndIf

      Case #CMD_CLEAR_ALL
        This\*TaskCount\SetValue(0)
        This\*TaskTitle\SetValue("")
        This\*StatusMessage\SetValue("All tasks have been cleared.")
    EndSelect
  }
}
```

---

## 3️⃣ Module 6: Step 3 — Designing the XML View

Using `XMLLoader`, the user interface is defined in `views/MainView.xml`:

```xml
<Window Title="PureBasic OOP Task Manager" Width="480" Height="300">
  <!-- Vertical StackPanel with outer margin and child spacing -->
  <StackPanel Margin="20" Spacing="12">
    
    <!-- Static Label -->
    <Label Text="Add a new task:" />

    <!-- Input box bound two-way to TaskTitle -->
    <TextBox Text="{Binding TaskTitle, Mode=TwoWay}" />

    <!-- Horizontal button action panel -->
    <StackPanel Orientation="Horizontal" Spacing="10">
      <Button Text="➕ Add Task" Command="AddTaskCommand" />
      <Button Text="🗑️ Clear All" Command="ClearAllCommand" />
    </StackPanel>

    <!-- Group Box dashboard with bound labels -->
    <GroupBox Text="Task Dashboard">
      <StackPanel Margin="12" Spacing="6">
        <Label Text="{Binding StatusMessage}" />
        <Label Text="Total Tasks Count: {Binding TaskCount}" />
      </StackPanel>
    </GroupBox>

  </StackPanel>
</Window>
```

---

## 4️⃣ Module 7: Step 4 — Main Entry Point

Bootstrapping the app in `main.pb` takes only a few lines:

```purebasic
; ============================================================================
; main.pb - Launching PureBasic OOP / MVVM Application
; ============================================================================
EnableExplicit

XIncludeFile "src/ui/UI.pbi"
XIncludeFile "constants/AppConstants.pbi"
XIncludeFile "viewmodels/TaskViewModel.pbo"

; 1. Create Core Application
Protected *app.UI::Application = NewObject(UI::Application)

; 2. Instantiate ViewModel
Protected *vm.TaskViewModel = NewObject(TaskViewModel)

; 3. Load XML View and bind to ViewModel
Protected xmlContent.s = ""
If ReadFile(0, "views/MainView.xml")
  xmlContent = ReadString(0, #PB_File_IgnoreEOL | #PB_UTF8)
  CloseFile(0)
EndIf

Protected *window.UI::Window = UI::XMLLoader::LoadAndBindXML(xmlContent, *vm)

If *window
  ; 4. Show Window and Run Event Loop
  *window\Show()
  *app\Run()
EndIf
```

> **🎉 Live Reactive Behavior!**  
> When running `main.pb`:  
> - Typing into the `TextBox` immediately updates the ViewModel's `TaskTitle`.  
> - Clicking "Add Task" invokes `OnCommand()`, increments the counter, updates the status message, and clears the input box automatically!  

---

## 📚 Module 8: UI Controls Reference & F1 Help

### 8.1. 18 Encapsulated UI Controls

| OOP Control | Native PB Gadget | Primary Use Case |
| :--- | :--- | :--- |
| `UI::Button` | `ButtonGadget` | Clickable action buttons with MVVM commands |
| `UI::TextBox` | `StringGadget` | Single-line text input with two-way binding |
| `UI::Editor` | `EditorGadget` | Multiline plain or formatted text editor |
| `UI::CheckBox` | `CheckBoxGadget` | Boolean checked state toggle |
| `UI::RadioButton` | `OptionGadget` | Mutually exclusive choice in a group |
| `UI::ComboBox` | `ComboBoxGadget` | Dropdown selection menu |
| `UI::ListView` | `ListViewGadget` | Vertical list of string items |
| `UI::ListIcon` | `ListIconGadget` | Multi-column grid with icons and row selection |
| `UI::TreeView` | `TreeGadget` | Hierarchical tree view with expandable nodes |
| `UI::DatePicker` | `DateGadget` | Date picker and calendar dropdown |
| `UI::SpinBox` | `SpinGadget` | Numeric entry field with up/down stepper buttons |
| `UI::Slider` | `TrackBarGadget` | Continuous numerical range slider |
| `UI::ProgressBar` | `ProgressBarGadget` | Task execution progress bar |
| `UI::GroupBox` | `FrameGadget` | Visual titled container frame |
| `UI::Label` | `TextGadget` | Static or bound informative text |
| `UI::ToggleSwitch` | `CanvasGadget` | Animated modern ON/OFF switch |
| `UI::TabControl` | `PanelGadget` | Tabbed multi-view container |

### 8.2. F1 Contextual Help in the IDE
In the PureBasic IDE, place your cursor on any OOP keyword (`Class`, `Method`, `Super`, `Property`...) or UI component (`Button`, `Editor`, `Grid`, `ObservableObject`...) and press **F1** to open its documentation page with full inheritance trees and examples.
"""
    file_path = os.path.join(DOC_DIR, "training_getting_started_pb_oop_mvvm_EN.md")
    with open(file_path, "w", encoding="utf-8") as f:
        f.write(md_content)
    print(f"Generated: {file_path}")

if __name__ == "__main__":
    generate_french()
    generate_english()
    generate_markdown_french()
    generate_markdown_english()
    print("All Training guides & references generated successfully in doc/ directory!")
