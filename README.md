# plyometrics

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Continuous delivery

Every push to `main` runs code generation, analysis, tests, and an Android APK
build. If all steps pass, GitHub Actions creates a pre-release with an
installable APK attached.

The workflow keeps the major and minor version from `pubspec.yaml` and uses the
GitHub Actions run number as the patch and Android build number. For example,
run 42 with `version: 1.0.0+1` produces version `1.0.42`.

These automated builds use Android debug signing so the workflow does not need
repository secrets. A production Play Store release still requires a private
release keystore and an AAB build.
