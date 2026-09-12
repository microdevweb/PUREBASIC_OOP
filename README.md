# PureBasic OOP Framework & Transpiler — Version ALPHA 1.4

A modern Object-Oriented Programming (OOP) transpiler and GUI framework for PureBasic, featuring declarative XML layouts, strongly-typed Observable Properties, full vector Canvas controls (`UI::CanvasTable`, `UI::CanvasTree`, etc.), and a complete Model-View-ViewModel (MVVM) reactive architecture.

---

## Key Features

1. **Native PureBasic OOP Transpiler**:
   - Classes, namespaces, method overloading, and single inheritance (`Extends`).
   - Access specifiers (`Public`, `Protected`, `Private`).
   - Abstract classes and abstract methods (`Abstract Class`, `Public Abstract Method`).
   - Polymorphic method resolution via automated Virtual Method Tables (*VTable*).

2. **Vector UI & Modern DataGrid (`src/ui/controls/`)**:
   - **`UI::CanvasTable` (New in Alpha 1.4)**: High-performance vector data table / grid featuring interactive column resizing, sorting, alternating row backgrounds, virtual vertical scrolling, multi-column definitions, and selection events.
   - Vector Canvas Controls: `UI::CanvasButton`, `UI::CanvasTextBox`, `UI::CanvasText`, `UI::CanvasTree`, and `UI::CanvasTable`.
   - Layout managers: `DockPanel`, `StackPanel`, `Grid`.
   - Native controls: `Button`, `TextBox`, `Label`, `CheckBox`, `ProgressBar`, `Slider`, `ComboBox`, `ListIcon`, `ToggleSwitch`.

3. **Declarative XML / XAML Engine**:
   - Define interfaces in external `.xml` files or directly in-memory as strings (`LoadViewFromString`).
   - Declarative `<CanvasTable>` with nested `<Column>` definitions and `<Row>` / `<Cell>` population.
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
Class CounterViewModel Extends MVVM::ViewModelBase {
  Public *Msg.MVVM::StringProperty
  Public *Count.MVVM::IntProperty

  Public Method Init() {
    Super\Init()
    This\*Msg   = This\BindString(#PROP_MSG, "Click count: 0")
    This\*Count = This\BindInt("Count", 0)
  }

  Public Method OnCommand(cmd.s) {
    If cmd = #CMD_BTN
      Protected newCount.i = This\*Count\GetValue() + 1
      This\*Count\SetValue(newCount)
      This\*Msg\SetValue("Click count: " + Str(newCount))
    EndIf
  }
}

; 3. Main Entry Point
EnableExplicit

Protected *app.UI::Application = NewObject(UI::Application)
Protected *vm.CounterViewModel  = NewObject(CounterViewModel)
*vm\Init()

Protected xml.s = "<Window Title='MVVM Demo' Width='400' Height='200'>" +
                  "  <StackPanel Orientation='Vertical' Margin='20' Spacing='10'>" +
                  "    <TextBox Text='{Binding Msg}' Height='28'/>" +
                  "    <Button Text='Click Me' Command='BtnCmd' Height='32'/>" +
                  "  </StackPanel>" +
                  "</Window>"

Protected *win.UI::Window = UI::XMLLoader::LoadAndBindXML(xml, *vm)
If *win
  *win\Show()
  *app\Run()
  *win\Free()
EndIf

*vm\Free()
*app\Free()
```

---

## Compiling & Running

```cmd
compiler\transpiler.exe "examples/03_simple_mvvm/Main.pb" "examples/03_simple_mvvm/Main_transpiled.pb" --base-dir "examples/03_simple_mvvm"
"C:\Program Files\PureBasic\Compilers\pbcompiler.exe" "examples/03_simple_mvvm/Main_transpiled.pb" /CONSOLE /DEBUGGER /EXE "examples/03_simple_mvvm/simple_mvvm.exe" /THREAD /UNICODE /XP /USER /DPIAWARE
```

---

## License
MIT
