# Repository Guidelines

## Project Structure & Module Organization
Source lives under `App/Sources` for the SwiftUI root flow, with localized assets and Firebase configs in `App/Resources`. Shared business logic is split into Tuist modules inside `Modules/` (`CoreKit`, `FeatureExpansion`, `UIComponents`) to keep dependencies explicit. Tests reside in `Tests/Unit` and `Tests/UITests`, while Tuist manifests and shared helpers are under `Tuist/` and `Project.swift`. Keep any new feature-specific assets or strings within the module that owns them to avoid leaking dependencies.

## Build, Test, and Development Commands
Run the following from the repo root:
```
tuist install          # Align Swift packages declared in Tuist/Package.swift
tuist generate         # Regenerate PKMCollection.xcworkspace and schemes
tuist build PKMCollection --platform iOS
tuist test PKMCollectionTests --platform iOS
tuist test PKMCollectionUITests --platform iOS
```
Use `make graph` or `tuist graph` (see `Makefile`) if you need a module dependency visualization before introducing new targets.

## Coding Style & Naming Conventions
Follow standard Swift style: four-space indentation, mark structs/classes as `final` when no subclassing is intended, and keep files scoped to a single type. Favor protocol-first APIs and dependency injection for stores/repositories. Name modules `Feature{Name}` and folders in PascalCase (e.g., `OwnedCards`). Assets and localized strings should reuse the naming patterns already present in `App/Resources` (e.g., `pkm_<context>`). If SwiftLint is configured locally, run it before committing and fix all warnings.

## Testing Guidelines
Tests rely on XCTest. Name test targets `{ModuleName}Tests` and methods `test_whenCondition_expectOutcome`. Place fixtures in `Tests/Shared` or close to the unit under test. Aim for regression coverage on repositories, stores, and SwiftUI view models whenever behavior changes; UI regressions should get at least one UITest path covering the new flow. Execute `tuist test` (unit + UI) before every PR and document any skipped cases.

## Commit & Pull Request Guidelines
Recent history shows the `<type>: <summary>` convention (`feature:`, `build:`, etc.). Mirror that style, keep summaries in the imperative mood, and squash noisy commits before opening the PR. Every PR should: describe the change, link the relevant issue (e.g., `Closes #42`), list manual verification steps or screenshots, and mention new Tuist targets or resources so reviewers can regenerate locally.

## Security & Configuration Tips
Never commit secrets. Store `GoogleService-Info.plist` placeholders under `App/Resources/` and rely on environment-specific values outside Git when shipping. Review `SECURITY.md` for reporting instructions and prefer `Tuist/Config.swift` for environment-specific toggles instead of hard-coding keys inside modules.
