# Repository Guidelines

## Project Structure & Module Organization
- `lib/` is the public package surface; `lib/lua.dart` is the main entry point for consumers.
- `lib/src/` holds implementation details: compiler (`compiler/`), VM runtime (`vm/`), state and API layers (`state/`, `api/`), numeric helpers (`number/`), binary chunk parsing (`binchunk/`), and standard libraries (`stdlib/`).
- `test/` contains Dart tests plus Lua fixtures; see `test/stdlib/` and `test/module/`.
- `example/` contains runnable demos (for example, `example/example.dart`).
- `pubspec.yaml` defines SDK constraints and dependencies; `CHANGELOG.md` tracks releases.

## Build, Test, and Development Commands
- `dart pub get` installs dependencies for the package.
- `dart run example/example.dart` runs the sample program using the Lua VM.
- `dart test` runs the full test suite under `test/`.
- `dart test test/stdlib` runs only the standard library tests.
- `dart analyze` runs static analysis with the default Dart analyzer settings.

## Coding Style & Naming Conventions
- Use standard Dart formatting (`dart format .`) with 2-space indentation.
- Follow Dart naming conventions: `UpperCamelCase` for types, `lowerCamelCase` for variables/functions, and `snake_case.dart` for filenames (e.g., `lua_state.dart`).
- Keep public APIs in `lib/` small and documented; prefer internal helpers under `lib/src/`.

## Testing Guidelines
- Tests use `package:test` (see `pubspec.yaml`).
- Name test files `*_test.dart` and keep fixtures in `test/module/*.lua` when validating module loading or Lua interop.
- Add focused unit tests per subsystem (for example, `test/stdlib/string_test.dart` for string library behavior).

## Commit & Pull Request Guidelines
- Commit history favors short, imperative summaries without a strict prefix (examples: “release v0.0.5”, “Fix issues10 and normalize the code”, “Update README.md”).
- PRs should include a concise summary, rationale, and test results (e.g., `dart test`). Link related issues and add tests for behavior changes.

## Security & Configuration Tips
- Do not commit secrets or local logs. Keep environment-specific files out of the repo unless required for tests or reproducibility.
