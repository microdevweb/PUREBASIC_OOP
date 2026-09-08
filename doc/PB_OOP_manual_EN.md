# PureBasic OOP Reference Manual - Version Alpha 1.3

Official documentation for the PureBasic Object-Oriented transpiler, modern GUI framework, and declarative MVVM (Model-View-ViewModel) reactive architecture.

**Author:** MicrodevWeb  
**Version:** Alpha 1.3  
**Compatibility:** PureBasic 6.x (Windows, Linux, macOS)  

---

## Table of Contents

1. [Foundations of Object-Oriented Programming (OOP)](#1-foundations-of-object-oriented-programming-oop)
2. [PureBasic OOP Syntax & Grammar](#2-purebasic-oop-syntax--grammar)
3. [Responsive GUI Framework](#3-responsive-gui-framework)
4. [High-Fidelity Vector Controls (CanvasControl)](#4-high-fidelity-vector-controls-canvascontrol)
5. [WPF Declarative Style System & Dictionaries](#5-wpf-declarative-style-system--dictionaries)
6. [Visual Triggers & 60 FPS Micro-Animations (Easing)](#6-visual-triggers--60-fps-micro-animations-easing)
7. [Declarative XML Views & Automated Loader (XMLLoader)](#7-declarative-xml-views--automated-loader-xmlloader)
8. [Reactive MVVM Architecture (Model-View-ViewModel)](#8-reactive-mvvm-architecture-model-view-viewmodel)
9. [Memory Lifecycle & Leak-Free Disposal](#9-memory-lifecycle--leak-free-disposal)
10. [PureBasic IDE Integration & Project Files (.pbp)](#10-purebasic-ide-integration--project-files-pbp)

---

## 1. Foundations of Object-Oriented Programming (OOP)

Object-Oriented Programming (OOP) structures software applications around **data** and their **associated operations**, encapsulated within self-contained entities called **Objects**.

### 1.1 Classes and Objects
- **Class**: The blueprint defining member fields (attributes) and behaviors (methods).
- **Object (Instance)**: A concrete memory instance allocated via `New ClassName(...)`.

### 1.2 Encapsulation and Access Modifiers
- **`Public`**: Freely accessible from anywhere.
- **`Protected`**: Accessible only within the declaring class and its inheriting subclasses.
- **`Private`**: Strictly accessible only within the declaring class.

### 1.3 Inheritance (`Extends`)
Inheritance allows subclasses to reuse, specialize, and extend parent class capabilities:
```oop
Class Animal {
  Protected name.s
  Public Method Init(n.s) {
    This\name = n
  }
  Public Method Speak() {
    MessageRequester("Animal", This\name + " makes a sound.")
  }
}

Class Dog Extends Animal {
  Public Method Speak() {
    MessageRequester("Dog", This\name + " barks: Woof!")
  }
}
```

### 1.4 Polymorphism & Virtual Method Tables (VTable)
Objects dispatch method calls through automated Virtual Method Tables (*VTable*). Subclasses can be manipulated polymorphically through parent type pointers with late-binding dispatch.

### 1.5 Abstraction
- **`Abstract Class`**: Base template class that cannot be directly instantiated.
- **`Abstract Method`**: Method contract signature that derived subclasses must implement.

---

## 2. PureBasic OOP Syntax & Grammar

The native transpiler transforms object-oriented code into highly optimized procedural PureBasic source code.

### 2.1 Class Declaration
```oop
Namespace MyProject {
  Class User {
    Protected name.s
    Protected email.s

    Public Method Init(n.s, e.s) {
      This\name = n
      This\email = e
    }

    Public Method.s GetName() {
      ProcedureReturn This\name
    }
  }
}
```

### 2.2 Method & Constructor Overloading (`Init`)
Methods and constructors support multiple signature variants:
```oop
Public Method Init() {
  Super\Init()
}
Public Method Init(title.s) {
  Super\Init()
  This\SetTitle(title)
}
Public Method Init(title.s, width.i, height.i) {
  Super\Init(width, height)
  This\SetTitle(title)
}
```

---

## 3. Responsive GUI Framework

The `framework/` library wraps native gadgets and windows into a modular component hierarchy:

### 3.1 Responsive Layout Containers
- **`UI::Layouts::StackPanel`**: Linear layout arranging child components sequentially (horizontal or vertical) with configurable `Spacing`.
- **`UI::Layouts::DockPanel`**: Docking panel anchoring children along borders (`Left`, `Top`, `Right`, `Bottom`) with automatic fill of remaining center space.
- **`UI::Layouts::Grid`**: Matrix layout grid with row and column sizing in pixels (`120`), automatic fit (`Auto`), or proportional star distribution (`*`, `2*`).

---

## 4. High-Fidelity Vector Controls (CanvasControl)

Major addition in **Alpha 1.3**, `UI::CanvasControl` is the 2D vector foundation built over native `CanvasGadget()` with hardware double-buffering:

- **`UI::CanvasButton`**: Modern vector button with predefined palettes (Primary, Secondary, Success, Danger), vector icons, and focus rings.
- **`UI::CanvasTextBox`**: Vector input field with placeholder text, blinking caret, secure password mode, and automatic horizontal scrolling.
- **`UI::CanvasText`**: Crisp typography with geometric measurement and automated ellipsis truncation (`...`).
- **`UI::CanvasTree`**: Interactive vector tree view featuring animated chevrons, checkboxes, and inline per-row action buttons.

---

## 5. WPF Declarative Style System & Dictionaries

Alpha 1.3 brings total separation between UI design and business logic using XML style dictionaries (e.g. `styles/Styles.xml`):

```xml
<ResourceDictionary>
  <Style TargetType="CanvasButton" Key="PrimaryButton">
    <Setter Property="Background" Value="#4F46E5"/>
    <Setter Property="TextColor" Value="#FFFFFF"/>
    <Setter Property="CornerRadius" Value="8"/>
    <Setter Property="FontName" Value="Segoe UI"/>
    <Setter Property="FontSize" Value="10"/>

    <Trigger Property="IsMouseOver" Value="True">
      <Setter Property="Background" Value="#4338CA"/>
      <Setter Property="Scale" Value="1.04" Easing="Back" Duration="120"/>
    </Trigger>

    <Trigger Property="IsPressed" Value="True">
      <Setter Property="Background" Value="#3730A3"/>
      <Setter Property="Scale" Value="0.98" Easing="Cubic" Duration="80"/>
    </Trigger>
  </Style>
</ResourceDictionary>
```

---

## 6. Visual Triggers & 60 FPS Micro-Animations (Easing)

Modern user experience requires fluid transitions. `UI::AnimationEngine` provides mathematical easing without procedural animation code:
- **`Linear`**: Constant speed interpolation.
- **`Cubic`**: Progressive ease-in and ease-out acceleration.
- **`Back`**: Tactile spring overshoot before settling.

---

## 7. Declarative XML Views & Automated Loader (XMLLoader)

Construct user interfaces declaratively in XML (`views/MainView.xml`):
```xml
<Window Title="Dashboard" Width="960" Height="640">
  <DockPanel>
    <StackPanel Dock="Left" Width="220" Background="#18181B" Spacing="8" Padding="16">
      <CanvasButton Style="NavButton" Text="Dashboard" Click="CmdNavHome"/>
      <CanvasButton Style="NavButtonActive" Text="Projects" Click="CmdNavProjects"/>
    </StackPanel>

    <Grid Margin="24">
      <Grid.RowDefinitions>
        <RowDefinition Height="Auto"/>
        <RowDefinition Height="*"/>
      </Grid.RowDefinitions>
      <CanvasText Grid.Row="0" Text="Project Management" FontSize="16" FontBold="True"/>
      <CanvasTextBox Grid.Row="1" Style="FormInput" Text="{Binding ProjectName, Mode=TwoWay}" Placeholder="Project name..."/>
    </Grid>
  </DockPanel>
</Window>
```

Loaded in a single line of code:
```purebasic
Define *view.UI::Window = UI::XMLLoader::LoadView("views/MainView.xml", *myViewModel)
```

---

## 8. Reactive MVVM Architecture (Model-View-ViewModel)

The **MVVM** pattern enforces clean architectural decoupling:
- **Model**: Pure business entity data.
- **View**: Declarative XML user interface.
- **ViewModel**: Extends `MVVM::ViewModelBase`, binds observable properties (`BindString`, `BindInt`), and dispatches commands (`OnCommand`).
- **Two-Way Binding (`Mode=TwoWay`)**: Automatically synchronizes UI input and ViewModel state bidirectionally in real-time.

---

## 9. Memory Lifecycle & Leak-Free Disposal

PureBasic OOP guarantees strict cascading resource cleanup:
- Calling `*view\Free()` recursively disposes of all child panels, gadgets, and canvas controls.
- Calling `*viewModel\Free()` releases all observable property bindings.
- Applications terminate with **zero memory leaks**.

---

## 10. PureBasic IDE Integration & Project Files (.pbp)

Every application includes a clean `.pbp` project file:
- References only user application source files (`main.pb`, views, models, styles).
- Framework classes are automatically included by the native transpiler.
- All comments use simplified ASCII English, eliminating encoding conflicts in the IDE.
