; ============================================================================
; PureBasic OOP - Reference Manual (English)
; Official documentation for the transpiler, GUI framework, and MVVM engine
; Author:      MicrodevWeb
; ============================================================================

# PureBasic OOP Reference Manual (English)

Welcome to the official documentation for the PureBasic Object-Oriented transpiler, responsive GUI framework, and MVVM (Model-View-ViewModel) reactive architecture.

---

## 1. Foundations of Object-Oriented Programming (OOP)

Object-Oriented Programming (OOP) organizes software design around **data** and their **associated operations**, packaged into self-contained units called **Objects**.

### 1.1 Classes and Objects
- **Class**: The blueprint defining data fields (attributes) and behaviors (methods).
- **Object (Instance)**: A concrete entity instantiated in memory via `New ClassName(...)`.

### 1.2 Encapsulation & Visibility
- **`Public`**: Accessible anywhere (inside and outside the object).
- **`Protected`**: Accessible only within the declaring class and its derived subclasses.
- **`Private`**: Accessible strictly inside the declaring class.

### 1.3 Inheritance (`Extends`)
Inheritance allows a child class to inherit fields and methods from a parent class, promoting code reuse:
```oop
Class Dog Extends Animal {
  Public Method Speak() {
    MessageRequester("Dog", "Woof!")
  }
}
```

### 1.4 Polymorphism (Dynamic VTable Dispatch)
Derived objects can be treated uniformly through their base class pointer. Method invocations dynamically dispatch at runtime through the Virtual Method Table (*VTable*).

### 1.5 Abstraction (Abstract Classes & Abstract Methods)
- **`Abstract Class`**: A base class that cannot be directly instantiated.
- **`Public Abstract Method`**: A prototype that concrete subclasses **must** implement.

---

## 2. PureBasic OOP Syntax & Grammar

### 2.1 Class Declaration
```oop
Namespace App::Models {

  Abstract Class Shape {
    Protected name.s
    Protected color.s

    Public Method Init(name_p.s, color_p.s) {
      This\name = name_p
      This\color = color_p
    }

    Public Abstract Method.d CalculateArea()
    
    Public Method DisplayInfo() {
      Debug "Shape: " + This\name + " | Color: " + This\color
    }

    Public Method Free() {
    }
  }

  Class Rectangle Extends Shape {
    Protected width.d
    Protected height.d

    Public Method Init(name_p.s, color_p.s, w.d, h.d) {
      Super::Init(name_p, color_p)
      This\width = w
      This\height = h
    }

    Public Method.d CalculateArea() {
      ProcedureReturn This\width * This\height
    }
  }

}
```

### 2.2 Constructor Overloading (`Init`)
A class can define multiple constructors with different parameter signatures:
```oop
Class Person {
  Protected name.s
  Protected age.i

  Public Method Init() {
    This\name = "Anonymous" : This\age = 0
  }

  Public Method Init(name_p.s) {
    This\name = name_p : This\age = 0
  }

  Public Method Init(name_p.s, age_p.i) {
    This\name = name_p : This\age = age_p
  }
}
```

---

## 3. Responsive GUI Framework (`src/ui/`)

The PureBasic OOP GUI framework provides automatic layout management and standard UI controls without manual coordinate calculations.

### 3.1 UI Controls Constructor Reference

| Component | Common Constructors | Description |
| :--- | :--- | :--- |
| **`UI::Button`** | `Init(text.s)`<br>`Init(text.s, w.i, h.i)` | Standard clickable push button. Auto 120x30 default. |
| **`UI::TextBox`** | `Init()`<br>`Init(defaultText.s)`<br>`Init(defaultText.s, w.i, h.i)` | Single-line editable text input. |
| **`UI::Label`** | `Init(text.s)`<br>`Init(text.s, w.i, h.i)` | Static text label. |
| **`UI::CheckBox`** | `Init(text.s)`<br>`Init(text.s, checked.b)` | Checkbox toggle with boolean state. |
| **`UI::ComboBox`** | `Init()`<br>`Init(w.i, h.i)` | Dropdown selection control. |
| **`UI::ProgressBar`** | `Init()` *(0..100)*<br>`Init(min.i, max.i)` | Visual progress bar indicator. |
| **`UI::Slider`** | `Init()` *(0..100)*<br>`Init(min.i, max.i)` | TrackBar slider control. |
| **`UI::ListIcon`** | `Init(title.s, colWidth.i)` | Multi-column table / data grid. |
| **`UI::ToggleSwitch`** | `Init()`<br>`Init(checked.b)` | Modern vector toggle switch (Canvas). |

### 3.2 Responsive Layout Panels

| Layout Panel | Constructors | Behavior |
| :--- | :--- | :--- |
| **`UI::StackPanel`** | `Init()`<br>`Init(orientation.i, spacing.i)` | Linear layout arranging children horizontally or vertically. |
| **`UI::DockPanel`** | `Init(lastChildFill.b = #True)` | Edge docking (`#UI_Dock_Top`, `#UI_Dock_Bottom`, `#UI_Dock_Left`, `#UI_Dock_Right`, `#UI_Dock_Fill`). |
| **`UI::Grid`** | `Init()` | 2D flexible grid supporting fixed pixels, Auto, and Star (`*`, `2*`) sizing. |
| **`UI::Window`** | `Init(title.s, w.i, h.i)` | Top-level window with automated resize handling. |

---

## 4. Declarative XML / XAML UI Engine

Layouts can be defined declaratively in XML files or directly in-memory as strings.

### 4.1 Loading Methods
- **From File**: `This\LoadView(filePath.s, *dataContext = 0)`
- **From String (In-Memory)**: `This\LoadViewFromString(xmlString.s, *dataContext = 0)`

### 4.2 XML Syntax Reference
```xml
<Window Title="Application" Width="600" Height="400">
  <DockPanel LastChildFill="true">
    <StackPanel Dock="Top" Orientation="Horizontal" Margin="10,5" Spacing="8">
      <Button Text="Refresh" Click="RefreshCmd" Width="90" Height="30"/>
    </StackPanel>
    <StackPanel Dock="Fill" Orientation="Vertical" Margin="15" Spacing="10">
      <Label Text="User Details:" Height="20"/>
      <TextBox Text="{Binding UserName}" Height="28"/>
      <Label Text="{Binding StatusMessage}" Height="20"/>
    </StackPanel>
  </DockPanel>
</Window>
```

---

## 5. Modern MVVM Architectural Pattern

The **MVVM (Model-View-ViewModel)** pattern provides clean separation of concerns and reactive data-binding:
- **Model**: Business entities and data storage.
- **ViewModel**: Manages state and logic. **Never references UI gadgets or windows directly**.
- **View**: Visual presentation observing the ViewModel via `DataContext` and DataBinding expressions.

### 5.1 Strongly-Typed Observable Properties (`src/ui/mvvm/Property.pbi`)

| Property Class | Accessors | Notification |
| :--- | :--- | :--- |
| **`StringProperty`** | `Get()`, `Set(val.s)`, `ToString()` | Automatic on `Set()` |
| **`IntProperty`** | `Get()`, `Set(val.i)`, `Increment()`, `Decrement()`, `GetString()`, `ToString()` | Automatic on `Set()`, `Increment()`, `Decrement()` |
| **`BoolProperty`** | `Get()`, `Set(val.b)`, `Toggle()`, `GetString()`, `ToString()` | Automatic on `Set()`, `Toggle()` |
| **`DoubleProperty`** | `Get()`, `Set(val.d)`, `GetString()`, `ToString(decimals.i)` | Automatic on `Set()` |

### 5.2 ViewModel Creation Helpers
Within any class extending `UI::MVVM::ViewModelBase`:
- `This\BindString(name.s, defaultVal.s = "")`
- `This\BindInt(name.s, defaultVal.i = 0)`
- `This\BindBool(name.s, defaultVal.b = #False)`
- `This\BindDouble(name.s, defaultVal.d = 0.0)`

### 5.3 Command Dispatching
Buttons with `Click="CommandName"` or `Command="CommandName"` trigger the virtual `OnCommand(cmd.s, *param = 0)` method in the ViewModel:
```purebasic
Public Method.b OnCommand(cmd.s, *param = 0) {
  Select cmd
    Case "MyAction"
      This\*MyProperty\Set("Updated!")
      ProcedureReturn #True
  EndSelect
  ProcedureReturn #False
}
```

---

## 6. Complete MVVM Step-by-Step Example

### File 1: `SimpleConstants.pbi` (Shared Contract)
```purebasic
#PROP_MESSAGE = "Message"
#PROP_COUNT   = "Count"
#CMD_CLICK    = "ClickCmd"
#CMD_RESET    = "ResetCmd"
```

### File 2: `SimpleViewModel.pbi` (State & Logic)
```purebasic
XIncludeFile "ui/UI.pbi"
XIncludeFile "SimpleConstants.pbi"

Namespace Demo {

  Class SimpleViewModel Extends UI::MVVM::ViewModelBase {
    Public *Message.UI::MVVM::StringProperty
    Public *Count.UI::MVVM::IntProperty

    Public Method Init() {
      Super::Init()
      This\*Message = This\BindString(#PROP_MESSAGE, "Click the button below")
      This\*Count   = This\BindInt(#PROP_COUNT, 0)
    }

    Public Method.b OnCommand(cmd.s, *param = 0) {
      Select cmd
        Case #CMD_CLICK
          This\*Count\Increment()
          This\*Message\Set("Total Clicks: " + This\*Count\GetString())
          ProcedureReturn #True

        Case #CMD_RESET
          This\*Count\Set(0)
          This\*Message\Set("Reset to 0")
          ProcedureReturn #True
      EndSelect
      ProcedureReturn #False
    }
  }

}
```

### File 3: `SimpleView.pbi` (Declarative View)
```purebasic
XIncludeFile "ui/UI.pbi"
XIncludeFile "SimpleConstants.pbi"
XIncludeFile "SimpleViewModel.pbi"

Namespace Demo {

  Class SimpleView Extends UI::Window {

    Public Method Init(*vm.Demo::SimpleViewModel) {
      Super::Init()

      Protected xml.s
      xml + "<Window Title='MVVM Example' Width='450' Height='250'>"
      xml + "  <StackPanel Orientation='Vertical' Margin='20' Spacing='12'>"
      xml + "    <Label Text='PureBasic OOP MVVM Demo' Height='24'/>"
      xml + "    <TextBox Text='{Binding " + #PROP_MESSAGE + "}' Height='28'/>"
      xml + "    <StackPanel Orientation='Horizontal' Spacing='10' Height='34'>"
      xml + "      <Button Text='Click Me' Click='" + #CMD_CLICK + "' Width='110' Height='32'/>"
      xml + "      <Button Text='Reset'    Click='" + #CMD_RESET + "' Width='90'  Height='32'/>"
      xml + "    </StackPanel>"
      xml + "  </StackPanel>"
      xml + "</Window>"

      This\LoadViewFromString(xml, *vm)
    }
  }

}
```

### File 4: `Main.pb` (Application Entry Point)
```purebasic
XIncludeFile "SimpleView.pbi"

Define *app.UI::Application = New UI::Application("PureBasic OOP MVVM")
Define *vm.Demo::SimpleViewModel = New Demo::SimpleViewModel()
Define *view.Demo::SimpleView = New Demo::SimpleView(*vm)

*app\SetMainWindow(*view)
*app\Run()
```

---

## 7. Compilation & Build Guide

### Step 1: Transpile `.pbo` / `.pb` using Native Transpiler
```cmd
compiler\transpiler.exe "src/examples/simple_mvvm/Main.pb" "src/examples/simple_mvvm/Main_transpiled.pb" --base-dir "src/examples/simple_mvvm"
```

### Step 2: Compile with PureBasic Compiler
```cmd
"C:\Program Files\PureBasic\Compilers\pbcompiler.exe" "src/examples/simple_mvvm/Main_transpiled.pb" /CONSOLE /DEBUGGER /EXE "src/examples/simple_mvvm/simple_mvvm.exe" /THREAD /UNICODE /XP /USER /DPIAWARE
```
