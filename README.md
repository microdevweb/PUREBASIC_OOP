# PureBasic OOP Framework & Transpiler

A modern Object-Oriented Programming (OOP) transpiler and GUI framework for PureBasic, featuring declarative XML layouts, strongly-typed Observable Properties, and a complete Model-View-ViewModel (MVVM) reactive architecture.

---

## Key Features

1. **Native PureBasic OOP Transpiler**:
   - Classes, namespaces, method overloading, and single inheritance (`Extends`).
   - Access specifiers (`Public`, `Protected`, `Private`).
   - Abstract classes and abstract methods (`Abstract Class`, `Public Abstract Method`).
   - Polymorphic method resolution via automated Virtual Method Tables (*VTable*).

2. **Responsive GUI Framework (`src/ui/`)**:
   - Automated layout managers: `DockPanel`, `StackPanel`, `Grid`.
   - Complete set of standard controls: `Button`, `TextBox`, `Label`, `CheckBox`, `ProgressBar`, `Slider`, `ComboBox`, `ListIcon`, `ToggleSwitch`.
   - Automated responsive window sizing and layout arrangement.

3. **Declarative XML / XAML Engine**:
   - Define interfaces in external `.xml` files or directly in-memory as strings (`LoadViewFromString`).
   - DataBinding syntax: `{Binding PropertyName}`.
   - Command triggers: `Click="CommandName"`.

4. **Modern MVVM Architecture (`src/ui/mvvm/`)**:
   - Clean separation of concerns (ViewModel is completely decoupled from UI gadgets).
   - Strongly-typed observable properties: `StringProperty`, `IntProperty`, `BoolProperty`, `DoubleProperty`.
   - Automatic UI notifications on `.Set()`, `.Increment()`, `.Toggle()`.
   - Zero-boilerplate command handling via `OnCommand()`.

---

## Documentation

Comprehensive guides and manuals are available in the `doc/` folder:
- **English Reference Manual**: [doc/PB_OOP_manual_EN.md](doc/PB_OOP_manual_EN.md)
- **French Reference Manual**: [doc/PB_OOP_manuel_FR.md](doc/PB_OOP_manuel_FR.md)
- **IDE & GUI Roadmap**: [doc/ROADMAP_IDE_AND_GUI.md](doc/ROADMAP_IDE_AND_GUI.md)

---

## Quick Example: Minimal Reactive MVVM Application

```purebasic
; 1. Shared Contract Constants
#PROP_MSG = "Msg"
#CMD_BTN  = "BtnCmd"

; 2. ViewModel
Class CounterViewModel Extends UI::MVVM::ViewModelBase {
  Public *Msg.UI::MVVM::StringProperty
  Public *Count.UI::MVVM::IntProperty

  Public Method Init() {
    Super::Init()
    This\*Msg   = This\BindString(#PROP_MSG, "Click count: 0")
    This\*Count = This\BindInt("Count", 0)
  }

  Public Method.b OnCommand(cmd.s, *param = 0) {
    If cmd = #CMD_BTN
      This\*Count\Increment()
      This\*Msg\Set("Click count: " + This\*Count\GetString())
      ProcedureReturn #True
    EndIf
    ProcedureReturn #False
  }
}

; 3. View (Inline XML)
Class CounterView Extends UI::Window {
  Public Method Init(*vm.CounterViewModel) {
    Super::Init()
    Protected xml.s
    xml + "<Window Title='MVVM Demo' Width='400' Height='200'>"
    xml + "  <StackPanel Orientation='Vertical' Margin='20' Spacing='10'>"
    xml + "    <TextBox Text='{Binding " + #PROP_MSG + "}' Height='28'/>"
    xml + "    <Button Text='Click Me' Click='" + #CMD_BTN + "' Height='32'/>"
    xml + "  </StackPanel>"
    xml + "</Window>"
    This\LoadViewFromString(xml, *vm)
  }
}

; 4. Main Entry Point
Define *app.UI::Application = New UI::Application("PureBasic OOP")
Define *vm.CounterViewModel  = New CounterViewModel()
Define *view.CounterView     = New CounterView(*vm)
*app\SetMainWindow(*view)
*app\Run()
```

---

## Compiling & Running

```cmd
compiler\transpiler.exe "src/examples/simple_mvvm/Main.pb" "src/examples/simple_mvvm/Main_transpiled.pb" --base-dir "src/examples/simple_mvvm"
"C:\Program Files\PureBasic\Compilers\pbcompiler.exe" "src/examples/simple_mvvm/Main_transpiled.pb" /CONSOLE /DEBUGGER /EXE "src/examples/simple_mvvm/simple_mvvm.exe" /THREAD /UNICODE /XP /USER /DPIAWARE
```

---

## License
MIT
