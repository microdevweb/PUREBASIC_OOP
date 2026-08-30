# PureBasic OOP Transpiler & VS Code Extension

A modern Object-Oriented Programming (OOP) extension and transpiler for PureBasic (`.pbo` to `.pb`), complete with Visual Studio Code language support and Language Server Protocol (LSP) integration.

## Features
- **OOP Syntax for PureBasic**: Declare classes, methods, single inheritance (`Extends`), method overrides, and access control (`Public`, `Protected`, `Private`).
- **High Performance Transpilation**: Converts OOP constructs to native PureBasic `Interface`, `Structure` with `*VTable`, and procedures with explicit `*This` instance pointers.
- **VS Code Extension**: Syntax highlighting, auto-completion, and real-time LSP diagnostics.

## Project Structure
- `src/` : Source files and `.pbo` examples.
- `compiler/` : Transpiler implementation in PureBasic.
- `doc/` : Reference manuals (FR / EN) and [ROADMAP_IDE_AND_GUI.md](doc/ROADMAP_IDE_AND_GUI.md).

## Future Roadmap & Vision
See [doc/ROADMAP_IDE_AND_GUI.md](doc/ROADMAP_IDE_AND_GUI.md) for the roadmap covering:
1. **Native PureBasic OOP GUI Framework** (`UIWindow`, `UIButton`, `UITextBox`, etc.)
2. **Dedicated Native Scintilla IDE** (`pbo_ide.pb`) with syntax highlighting, live transpilation, and autocompletion.

## Getting Started
To compile `.pb` generated output using the PureBasic compiler:
```cmd
"C:\Program Files\PureBasic\Compilers\pbcompiler.exe" "src/your_file_generated.pb" /CONSOLE /EXE "src/your_file.exe"
```

## License
MIT
