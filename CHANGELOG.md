# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.3.0] - 2024-12-29

### Added
- **Web Platform Support** (#28): Full web compatibility via platform abstraction layer
  - Conditional imports for `dart:io` (native) and web stub
  - `PlatformServices` singleton for cross-platform file/process operations
  - Customizable `printCallback` for output redirection
  - Web-safe `os` library (time functions work, file operations throw `UnsupportedError`)
- **Async Dart Function Support** (#9): Call async Dart functions from Lua
  - `DartFunctionAsync` type: `Future<int> Function(LuaState ls)`
  - `registerAsync(name, func)` - Register async function as global
  - `pushDartFunctionAsync(func)` - Push async function onto stack
  - `pushDartClosureAsync(func, nUpvals)` - Push async closure with upvalues
  - `callAsync(nArgs, nResults)` - Call function asynchronously
  - `pCallAsync(nArgs, nResults, errFunc)` - Protected async call
  - `doStringAsync(code)` - Execute Lua string asynchronously
  - `doFileAsync(path)` - Execute Lua file asynchronously
- `luaUpvalueIndex(i)` helper function for accessing upvalues in closures
- 93 new tests (136 total, up from 43)

### Fixed
- **`math.min` bug**: Was returning maximum value instead of minimum (comparison logic inverted)
- **`math.modf` bug**: Was returning only fractional part (return count was 1 instead of 2)

### Changed
- Replaced deprecated `pedantic` with `lints: ^4.0.0` in dev_dependencies
- Updated `test` to `^1.25.0`

## [0.2.0] - 2024-12-29

### Added
- **Coroutine Support**: Full implementation of Lua coroutine library
  - `coroutine.create(f)` - Create a new coroutine
  - `coroutine.resume(co, ...)` - Start or resume a coroutine
  - `coroutine.yield(...)` - Suspend coroutine execution
  - `coroutine.status(co)` - Get coroutine status (running/suspended/dead)
  - `coroutine.running()` - Get the currently running coroutine
  - `coroutine.wrap(f)` - Create a wrapped coroutine function
- New API interfaces: `LuaCoroutineLib`, `LuaDebug`
- Thread type support in `LuaValue.typeOf()` and `LuaValue.typeName()`
- `ThreadStatus.luaDead` for completed coroutines
- 10 new coroutine tests

### Fixed
- **Issue #13**: `string.gsub` now works correctly
  - Fixed infinite loop when using unlimited replacement (n=-1)
  - Fixed off-by-one error in string slicing
  - Fixed original string modification during iteration

## [0.1.0] - 2024-12-29

### Added
- Forked from [arcticfox1919/LuaDardo](https://github.com/arcticfox1919/LuaDardo) v0.0.5
- Comprehensive test suite for bug fixes (21 tests)
- Per-instance metatable support for `Userdata` class
- Source location information in error messages (`[source:line]` format)
- `CONTRIBUTING.md` with branch strategy and workflow documentation

### Fixed
- **Issue #24**: `math.random` now correctly includes upper bound and supports negative ranges
  - `math.random(1, 10)` can now return 10
  - `math.random(-10, 10)` works correctly
- **Issue #33**: Error messages now include source file and line number information
- **Issue #34**: `return` without value no longer causes runtime error
  - `return` and `return;` correctly return nil
- **Issue #36**: Userdata metatables are now per-instance instead of shared globally

### Changed
- Renamed package from `lua_dardo` to `lua_dardo_plus`
- Updated SDK constraint to `>=2.17.0 <4.0.0`
- Improved README with migration guide and feature documentation

---

## Previous Releases (Original LuaDardo)

## 0.0.5
* Fix issues [#10](https://github.com/arcticfox1919/LuaDardo/issues/10)
* Fix warning

## 0.0.4
* Upgrade null safety

## 0.0.3
* Fix the bug of the table constructor
* Add auxiliary API for reference(`ref`/`unRef`)

## 0.0.2
* Add Lua userdata support
* Fix lexical analysis BUG

## 0.0.1
* A full lua virtual machine
* Support some standard libraries, e.g. String, Math, etc.
* Experimental nature only, not yet fully tested
