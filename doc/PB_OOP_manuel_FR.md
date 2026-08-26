# Manuel de Référence PureBasic OOP (Français)

Bienvenue dans la documentation officielle du transpileur et de la couche Orientée Objet pour PureBasic.

---

## 1. Introduction

PureBasic OOP apporte une syntaxe Orientée Objet de haut niveau tout en conservant la vitesse, la légèreté et la puissance de compilation native de PureBasic.

### Caractéristiques Principales :
- **Classes & Méthodes** : Déclaration propre via `Class` et `Method`.
- **Encapsulation** : Gestion de la visibilité des attributs et méthodes (`Public`, `Protected`, `Private`).
- **Constructeurs et Destructeurs** : Instanciation automatique (`New_*`) et libération explicite mémoire (`Free()`).
- **Polymorphisme VTable** : Mappage transparent sous forme d'`Interface` et de table de fonctions virtuelles PureBasic (`DataSection`).

---

## 2. Syntaxe & Grammaire Objet

### Déclaration d'une Classe
```oop
Class Chien
  Private nom.s
  Private age.i
  
  Public Method Init(nom_p.s, age_p.i)
  Public Method Aboyer()
  Public Method Free()
EndClass
```

### Implémentation des Méthodes
Chaque méthode accède à ses attributs internes via la référence d'instance `This`.

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

## 3. Plomberie PureBasic Générée

Le compilateur/transpileur transforme la classe OOP en code PureBasic compilable :

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

## 4. Guide d'Exécution & Compilation

Pour compiler un fichier PureBasic généré sous forme d'exécutable console :

```cmd
"C:\Program Files\PureBasic\Compilers\pbcompiler.exe" "src/test_chien_generated.pb" /CONSOLE /EXE "src/test_chien.exe"
```
