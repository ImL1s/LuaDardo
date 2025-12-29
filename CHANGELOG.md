# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
