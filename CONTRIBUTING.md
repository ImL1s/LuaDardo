# Contributing to LuaDardo Plus

## Branch Strategy

```
upstream (arcticfox1919/LuaDardo)
       │
       ▼
   [main] ◄──── Synced with upstream, used for PRs
       │
       ├── fix/issue-XX ──► PR to upstream
       │                         │
       ▼                         ▼
  [develop] ◄───────────── Merge back
       │
       └── lua_dardo_plus (independent project)
```

### Branch Purposes

| Branch | Purpose |
|--------|---------|
| `main` | Stays synced with upstream `arcticfox1919/LuaDardo`. Used as base for PRs. |
| `develop` | Main development branch for `lua_dardo_plus`. Contains all fixes + renaming. |
| `fix/*` | Feature/fix branches. Created from `main` for upstream PRs. |

## Workflow for New Fixes

### 1. Sync with Upstream

```bash
# Add upstream remote (one-time setup)
git remote add upstream https://github.com/arcticfox1919/LuaDardo.git

# Sync main with upstream
git checkout main
git fetch upstream
git merge upstream/main
git push origin main
```

### 2. Create Fix Branch

```bash
git checkout main
git checkout -b fix/issue-XX
```

### 3. Implement Fix

- Write the fix
- Add tests in `test/bugfix/issues_test.dart`
- Run tests: `dart test`
- Commit with descriptive message

### 4. Open PR to Upstream

```bash
git push -u origin fix/issue-XX
gh pr create --repo arcticfox1919/LuaDardo --title "Fix issue #XX" --body "Description..."
```

### 5. Merge to Develop

```bash
git checkout develop
git merge fix/issue-XX
git push origin develop
```

### 6. Publish New Version

```bash
# Update version in pubspec.yaml
# Update CHANGELOG.md
dart pub publish
```

## Versioning

We follow [Semantic Versioning](https://semver.org/):

- **MAJOR**: Breaking API changes
- **MINOR**: New features, backward compatible
- **PATCH**: Bug fixes, backward compatible

Current version: `0.1.0`

## Testing

All fixes must include tests:

```bash
# Run all tests
dart test

# Run specific test file
dart test test/bugfix/issues_test.dart

# Run with coverage
dart test --coverage=coverage
```

## Code Style

- Follow Dart style guide
- Run `dart format .` before committing
- Run `dart analyze` to check for issues

## Commit Messages

Format:
```
<type>: <description>

[optional body]

🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

Types:
- `fix`: Bug fix
- `feat`: New feature
- `docs`: Documentation
- `test`: Adding tests
- `refactor`: Code refactoring

## Release Checklist

- [ ] All tests pass
- [ ] Version bumped in `pubspec.yaml`
- [ ] CHANGELOG.md updated
- [ ] README.md updated if needed
- [ ] `dart pub publish --dry-run` passes
- [ ] Tagged release: `git tag v0.x.x`
