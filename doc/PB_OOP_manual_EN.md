# PureBasic OOP Reference Manual (English)

Welcome to the official documentation for the PureBasic Object-Oriented Programming transpiler and framework.

---

## 1. Introduction

PureBasic OOP brings high-level Object-Oriented syntax while retaining the native speed, lightness, and power of the PureBasic compiler.

### Key Features:
- **Classes & Methods**: Clean declarations using `Class` and `Method`.
- **Encapsulation**: Access control for fields and methods (`Public`, `Protected`, `Private`).
- **Constructors & Destructors**: Automatic instantiation (`New_*`) and explicit memory deallocation (`Free()`).
- **VTable Polymorphism**: Transparent mapping to PureBasic `Interface` and virtual function tables (`DataSection`).

---

## 2. Syntax & Object Grammar

### Class Declaration
```oop
Class Chien
  Private nom.s
  Private age.i
  
  Public Method Init(nom_p.s, age_p.i)
  Public Method Aboyer()
  Public Method Free()
EndClass
```

### Method Implementation
Each method accesses instance data using the `This` reference pointer.

```oop
Method Chien::Init(nom_p.s, age_p.i)
  This\nom = nom_p
  This\age = age_p
EndMethod

Method Chien::Aboyer()
  PrintN(This\nom + " dit : Wouaf ! Wouaf ! (Age : " + Str(This\age) + " ans)")
EndMethod
```

---

## 3. Generated PureBasic Code Plumbing

The transpiler converts OOP constructs into native, compilable PureBasic code:

```purebasic
Interface Chien_vt
  Aboyer()
  Free()
EndInterface

Structure Chien_Inst
  *VTable.Chien_vt
  nom.s
  age.i
EndStructure

Procedure Chien_Aboyer(*This.Chien_Inst)
  OpenConsole()
  PrintN(*This\nom + " dit : Wouaf ! Wouaf ! (Age : " + Str(*This\age) + " ans)")
EndProcedure

Procedure Chien_Free(*This.Chien_Inst)
  FreeStructure(*This)
EndProcedure

DataSection
  Chien_VTable_Data:
    Data.i @Chien_Aboyer()
    Data.i @Chien_Free()
EndDataSection

Procedure.i New_Chien(nom.s, age.i)
  Protected *obj.Chien_Inst = AllocateStructure(Chien_Inst)
  If *obj
    *obj\VTable = ?Chien_VTable_Data
    *obj\nom = nom
    *obj\age = age
  EndIf
  ProcedureReturn *obj
EndProcedure
```

---

## 4. Compilation Guide

To compile a generated PureBasic source file into a console executable:

```cmd
"C:\Program Files\PureBasic\Compilers\pbcompiler.exe" "src/test_chien_generated.pb" /CONSOLE /EXE "src/test_chien.exe"
```
