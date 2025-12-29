# LuaDardo Project Context

## Overview
LuaDardo is a Lua 5.3 virtual machine implemented in pure Dart. It enables the execution of Lua scripts within Dart applications and provides a bridge for interoperability between Dart and Lua, closely following the standard Lua C API.

## Key Technologies
*   **Language:** Dart (SDK >=2.12.0 <3.0.0)
*   **Lua Version:** 5.3
*   **Dependencies:** `sprintf`

## Project Structure
*   `lib/`: Source code for the Lua VM and standard libraries.
    *   `lib/lua.dart`: Main entry point exporting the public API.
    *   `lib/src/api/`: Core Lua API definitions (State, VM, Types).
    *   `lib/src/compiler/`: Lua compiler (Lexer, Parser, CodeGen).
    *   `lib/src/vm/`: Virtual Machine instructions and execution logic.
    *   `lib/src/stdlib/`: Implementation of Lua standard libraries (Base, Math, OS, String, Table, etc.).
*   `example/`: Usage examples.
*   `test/`: Unit tests for the VM and standard libraries.

## Build and Run
This is a pure Dart package.

### Setup
```bash
dart pub get
```

### Running Examples
```bash
dart example/example.dart
```

### Running Tests
```bash
dart test
```

## Development Conventions
*   **Code Style:** Follows standard Dart conventions.
*   **API Design:** The Dart API is designed to mirror the Lua C API (e.g., `lua_State`, `lua_gettop`, `lua_push...`), making it familiar to developers with Lua C API experience.
*   **Testing:** Uses the `test` package. Tests are located in the `test/` directory.

## Common Tasks
*   **Initialize Lua State:**
    ```dart
    import 'package:lua_dardo/lua.dart';
    LuaState state = LuaState.newState();
    state.openLibs(); // Load standard libraries
    ```
*   **Run Lua Code:**
    ```dart
    state.loadString("print('Hello Lua')");
    state.call(0, 0);
    ```
*   **Dart -> Lua Interop:** Use the stack to push arguments and call Lua functions (`state.getGlobal`, `state.push...`, `state.pCall`).
*   **Lua -> Dart Interop:** Register Dart functions as `LuaCFunction` using `state.pushDartFunction` and `state.setGlobal`.
