# PureBasic OOP Reference Manual (English)

Welcome to the official documentation for the PureBasic Object-Oriented transpiler and language layer.

---

## 1. Foundations of Object-Oriented Programming (OOP)

Object-Oriented Programming (OOP) is a programming paradigm organized around **data** and their **associated operations**, packaged into self-contained units called **Objects**.

It is built on 5 fundamental pillars:

### 1.1 Classes and Objects
- **Class**: The blueprint defining the structure (fields/attributes) and behavior (methods).
- **Object (Instance)**: A concrete entity instantiated in memory based on a class (e.g., class `Dog` instantiates the object `Buddy`).

### 1.2 Encapsulation
Encapsulation bundles data and the functions that manipulate them, restricting unauthorized external access:
- **`Public`**: Accessible anywhere (both inside and outside the object).
- **`Protected`**: Accessible only within the declaring class and its derived (child) subclasses.
- **`Private`**: Accessible strictly inside the declaring class.

### 1.3 Inheritance (`Extends`)
Inheritance enables a derived (child) class to reuse and extend fields and methods from a base (parent) class, promoting code reuse and clear hierarchies.

### 1.4 Polymorphism (Dynamic VTable Dispatch)
Polymorphism allows manipulating various derived objects uniformly via a reference to their common base class. Method calls dynamically resolve at runtime to the real object's implementation through the Virtual Method Table (*VTable*).

### 1.5 Abstraction (Abstract Classes & Abstract Methods)
Abstraction defines a generalized contract without supplying all implementation details:
- **Abstract Class** (`Abstract Class`): An incomplete class serving as a blueprint/contract. It **cannot be instantiated directly**.
- **Abstract Method** (`Abstract Method`): A method prototype without a body. Any concrete child class **must** implement this method.
- **Concrete / Default Method**: An abstract class can also provide methods with default implementation, which child classes can inherit as-is, override completely, or override partially using `Super::`.

---

## 2. PureBasic OOP Syntax & Grammar (.pbo)

### 2.1 Declaring Abstract and Concrete Classes

```oop
; ----------------------------------------------------------------------------
; 1. ABSTRACT CLASS (Base contract / blueprint)
; ----------------------------------------------------------------------------
Abstract Class Shape
  Protected name.s
  Protected color.s

  ; Constructor
  Public Method Init(name_p.s, color_p.s)

  ; Abstract Methods (Contract: mandatory in concrete child classes)
  Public Abstract Method.d CalculateArea()
  Public Abstract Method.d CalculatePerimeter()
  Public Abstract Method Draw()

  ; Concrete Method with default implementation in abstract class
  Public Method DisplayInfo()
  
  ; Destructor
  Public Method Free()
EndClass

; ----------------------------------------------------------------------------
; 2. CONCRETE CLASS (Inherits from Abstract Class)
; ----------------------------------------------------------------------------
Class Rectangle Extends Shape
  Protected width.d
  Protected height.d

  Public Method Init(name_p.s, color_p.s, w.d, h.d)
  
  ; Mandatory implementations of abstract methods
  Public Method.d CalculateArea()
  Public Method.d CalculatePerimeter()
  Public Method Draw()
  
  ; Overriding the default method
  Public Method DisplayInfo()
  
  Public Method Free()
EndClass
```

---

### 2.2 Method Implementation, `This`, and `Super::`

Methods access instance attributes and internal methods using `This`.
To invoke a parent class's behavior (partial override), use `Super::`.

```oop
; --- Abstract Class Implementation ---

Method Shape::Init(name_p.s, color_p.s)
  This\name = name_p
  This\color = color_p
EndMethod

Method Shape::DisplayInfo()
  PrintN("[Shape: " + This\name + " | Color: " + This\color + "]")
EndMethod

Method Shape::Free()
  FreeStructure(This)
EndMethod

; --- Concrete Subclass Rectangle Implementation ---

Method Rectangle::Init(name_p.s, color_p.s, w.d, h.d)
  Super::Init(name_p, color_p) ; Initialize inherited base attributes
  This\width = w
  This\height = h
EndMethod

Method.d Rectangle::CalculateArea()
  ProcedureReturn This\width * This\height
EndMethod

Method.d Rectangle::CalculatePerimeter()
  ProcedureReturn 2 * (This\width + This\height)
EndMethod

Method Rectangle::Draw()
  PrintN("   ==> [DRAW] Rectangle " + StrD(This\width, 2) + "x" + StrD(This\height, 2) + " (" + This\color + ")")
EndMethod

; Partial Override: invoke Super::DisplayInfo() then add details
Method Rectangle::DisplayInfo()
  Super::DisplayInfo()
  PrintN("       Dimensions : " + StrD(This\width, 2) + " x " + StrD(This\height, 2) + " | Area=" + StrD(This\CalculateArea(), 2))
EndMethod

Method Rectangle::Free()
  Super::Free()
EndMethod
```

---

### 2.3 Usage and Polymorphism

```oop
OpenConsole()

; 1. Concrete Instantiations
Define *rect.Rectangle = New Rectangle("MyRectangle", "Blue", 10.0, 5.0)
Define *circle.Circle = New Circle("MyCircle", "Red", 4.0)

; Note: Direct instantiation of an abstract class is strictly forbidden:
; Define *err.Shape = New Shape(...) ; -> Transpilation error!

; 2. Dynamic Polymorphism using a List of Abstract Class type
NewList *shapes.Shape()

AddElement(*shapes()) : *shapes() = *rect
AddElement(*shapes()) : *shapes() = *circle
AddElement(*shapes()) : *shapes() = New Rectangle("BigRectangle", "Green", 20.0, 15.0)

; 3. Polymorphic loop: dynamically dispatches to the concrete class methods
ForEach *shapes()
  *shapes()\DisplayInfo()
  *shapes()\Draw()
  PrintN("   Area = " + StrD(*shapes()\CalculateArea(), 2))
  PrintN("")
Next

; 4. Polymorphic memory cleanup
ForEach *shapes()
  *shapes()\Free()
Next
ClearList(*shapes())

CloseConsole()
```

---

## 3. Namespaces & Multi-File Projects

### 3.1 Namespace Declaration & Nesting
Namespaces logically group classes and avoid naming collisions across large projects:

```oop
Namespace Game::Graphics
  Class Renderer
    Protected width.i, height.i
    Public Method Init(w.i, h.i)
    Public Method Render()
  EndClass
EndNamespace
```

### 3.2 Usage, `Using` Directive & Aliases
Classes inside namespaces can be accessed via full qualification, `Using` imports, or aliases:

```oop
; 1. Fully Qualified Name
Define *r1.Game::Graphics::Renderer = New Game::Graphics::Renderer(1920, 1080)

; 2. Using Directive
Using Game::Graphics
Define *r2.Renderer = New Renderer(1280, 720)

; 3. Namespace Alias
Namespace GFX = Game::Graphics
Define *r3.GFX::Renderer = New GFX::Renderer(800, 600)
```

### 3.3 Multi-File Projects (One File Per Class)
The transpiler natively and recursively processes `IncludeFile` and `XIncludeFile`:

**File `entities/Animal.pbo`:**
```oop
Namespace Game::Entities
Abstract Class Animal
  Protected name.s
  Public Method Init(name_p.s)
  Public Abstract Method Speak()
EndClass
EndNamespace
```

**File `entities/Dog.pbo`:**
```oop
Namespace Game::Entities
Class Dog Extends Animal
  Public Method Speak()
    PrintN(This\name + " barks!")
  EndMethod
EndClass
EndNamespace
```

**Main Entry File `main.pbo`:**
```oop
XIncludeFile "entities/Animal.pbo"
XIncludeFile "entities/Dog.pbo"

Using Game::Entities

OpenConsole()
Define *d.Dog = New Dog("Rex")
*d\Speak()
CloseConsole()
```

---

## 4. Generated Native PureBasic Plumbing

The transpiler converts high-level `.pbo` code into fast, native PureBasic `.pb` code:
1. **Interfaces (`_vt`)**: VTable prototypes definition with fully mangled names (e.g. `Game_Graphics_Renderer_vt`).
2. **Instance Structures (`_Inst`)**: Memory structures holding the `*VTable` pointer at offset 0 followed by fields.
3. **Safe Internal Dispatch (`*This_vt`)**: Internal calls (`This\Method()`) resolve cleanly through the polymorphic interface pointer `*This_vt`.
4. **VTable DataSections**: Emitted for concrete classes only.
5. **Constructors (`New_<Class>`)**: Generated only for concrete classes.
6. **Semantic Validations & Source Mapping**:
   - Forbids instantiating abstract classes.
   - Enforces that concrete subclasses implement all inherited abstract methods.
   - `.pb.map` file maps all compiler errors/warnings back to original `.pbo` files and lines.

---

## 5. Compilation & Execution Guide

### Transpile `.pbo` source to `.pb`:
```cmd
"compiler/transpiler.exe" "src/my_file.pbo" "src/my_file_generated.pb"
```

### Syntax check via CLI:
```cmd
"compiler/transpiler.exe" --check "src/my_file.pbo"
```

### Compile the generated PureBasic code:
```cmd
"C:\Program Files\PureBasic\Compilers\pbcompiler.exe" "src/my_file_generated.pb" /CONSOLE /EXE "src/my_file.exe"
```

