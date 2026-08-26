# PureBasic OOP Transpiler & VS Code Extension

A modern Object-Oriented Programming (OOP) extension and transpiler for PureBasic (`.pbo` to `.pb`), complete with Visual Studio Code language support and Language Server Protocol (LSP) integration.

## Features
- **OOP Syntax for PureBasic**: Declare classes, methods, single inheritance (`Extends`), method overrides, and access control (`Public`, `Protected`, `Private`).
- **High Performance Transpilation**: Converts OOP constructs to native PureBasic `Interface`, `Structure` with `*VTable`, and procedures with explicit `*This` instance pointers.
- **VS Code Extension**: Syntax highlighting, auto-completion, and real-time LSP diagnostics.

## Project Structure
- `src/` : Source files and `.pbo` examples.
- `compiler/` : Transpiler implementation in PureBasic.

## Getting Started
To compile `.pb` generated output using the PureBasic compiler:
```cmd
"C:\Program Files\PureBasic\Compilers\pbcompiler.exe" "src/your_file_generated.pb" /CONSOLE /EXE "src/your_file.exe"
```

## License
MIT
