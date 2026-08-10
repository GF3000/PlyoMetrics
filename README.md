# PlyoMetrics

PlyoMetrics is a Flutter mobile application for coaches and athletes who need practical jump-performance testing without expensive force plates or unreliable pose-estimation shortcuts.

The app uses high-speed video and manual frame selection to calculate clinically relevant metrics such as CMJ height, fatigue/readiness, Reactive Strength Index (RSI), and single-leg asymmetry. This makes the workflow transparent, reproducible, and easy to explain in a portfolio or demo setting.

## Portfolio highlights

- **Manual high-FPS frame analysis** instead of black-box AI pose detection.
- **Sports-science formulas** implemented as testable Dart business logic.
- **Riverpod state management** for multi-athlete testing sessions.
- **Local-first data model** with Isar persistence.
- **Performance history charts** using `fl_chart`.
- **Native Flutter UI** with Material widgets, custom branding, splash/icon assets, and localization.

## Screenshots and demo assets

Add real in-app screenshots or GIFs here before linking the project from a portfolio:

| Dashboard | CMJ frame selection | RSI / Evolution |
| --- | --- | --- |
| `docs/screenshots/dashboard.png` | `docs/screenshots/cmj-frame-selection.png` | `docs/screenshots/evolution.png` |

Suggested demo video sequence:

1. Create a group and athlete.
2. Import a 60+ FPS jump clip.
3. Select takeoff and landing frames.
4. Save a CMJ baseline.
5. Run a fatigue or RSI test.
6. Show the evolution charts.

## Core features

### Athlete and group management

- Create training groups.
- Add athletes with optional weight and height.
- Switch between athletes from the dashboard roster.
- Reorder athletes in the group view.

### CMJ baseline

- Analyze jump videos frame by frame.
- Calculate jump height from flight time.
- Record multiple jumps and exclude outliers from the average.
- Save the athlete baseline for future readiness comparisons.

### Fatigue / readiness test

- Compare the current CMJ result against the athlete baseline.
- Calculate height loss percentage.
- Show fatigue status guidance.
- Detect new personal bests and prompt for baseline refresh.

### RSI drop jump

- Mark first landing, takeoff, and second landing frames.
- Calculate contact time, flight time, jump height, and RSI.
- Track RSI progression over time.

### Asymmetry test

- Record single-leg CMJ jumps for left and right legs.
- Compare average jump height between legs.
- Surface asymmetry percentage and stronger leg.

### Evolution charts

- Visualize CMJ, fatigue, RSI, and asymmetry history.
- Compare athlete values against group-level context where available.

## Metrics and formulas

PlyoMetrics derives metrics from selected frame indexes and video FPS.

### Flight time

```text
flight_time = (landing_frame - takeoff_frame) / fps
```

### Contact time

```text
contact_time = (takeoff_frame - first_landing_frame) / fps
```

### Jump height

```text
height = gravity * flight_time² / 8
```

Where `gravity = 9.81 m/s²`.

### Reactive Strength Index

```text
rsi = jump_height_meters / contact_time_seconds
```

### Fatigue loss

```text
fatigue_loss = (baseline_height - current_height) / baseline_height * 100
```

## Architecture

```text
lib/
  core/          Theme and shared visual constants
  l10n/          English and Spanish localization files
  models/        Isar persisted models
  providers/     Riverpod state and data providers
  screens/       Feature screens and flows
  services/      Persistence, video, and jump metric services
  widgets/       Reusable dialogs and UI controls
test/            Widget and unit tests
```

Important implementation details:

- `lib/services/jump_metrics_service.dart` contains the tested physics and business calculations.
- `lib/services/isar_service.dart` owns local persistence.
- `lib/services/video_service.dart` extracts video metadata and frames with FFmpeg/FFprobe.
- `lib/providers/*_session_provider.dart` manages in-memory multi-athlete testing sessions.

## Tech stack

- Flutter / Dart 3
- Riverpod
- Isar
- `video_player`
- `image_picker`
- `ffmpeg_kit_flutter_new`
- `fl_chart`
- Flutter localization (`gen-l10n`)

## Local setup

```bash
flutter pub get
flutter gen-l10n
flutter analyze
flutter test
```

Run the app:

```bash
flutter run
```

Generate Isar model code after changing persisted models:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Android release notes

The Android release build reads signing values from `android/key.properties` when present:

```properties
storeFile=/absolute/path/to/upload-keystore.jks
storePassword=...
keyAlias=...
keyPassword=...
```

Do not commit `key.properties` or keystore files. Without this file, release builds fall back to the debug signing config so local portfolio demos remain easy to run.

### Android APK releases with GitHub Actions

The Android release workflow builds a signed release APK and publishes it to a GitHub Release.

Configure these repository secrets before running the workflow:

- `ANDROID_KEYSTORE_BASE64`: base64-encoded Android keystore file.
- `ANDROID_KEYSTORE_PASSWORD`: keystore password.
- `ANDROID_KEY_ALIAS`: key alias.
- `ANDROID_KEY_PASSWORD`: key password.

Create a release by pushing a semantic version tag:

```bash
git tag v1.0.0
git push origin v1.0.0
```

You can also run the `Android Release` workflow manually and provide the release tag name. The workflow fails if any signing secret is missing so unsigned or debug-signed APKs are not published.

## Data and privacy

PlyoMetrics is local-first. Athlete profiles and test results are stored on the device using Isar. The app does not require an account or remote backend for the current showcase flow.

Recommended production follow-ups:

- Add explicit export/import.
- Add full data reset.
- Add encrypted backups if cloud sync is introduced.
- Add a short privacy policy for any public distribution.

## Roadmap

- In-app high-speed video recording flow.
- Demo mode with seeded example athletes and tests.
- Export reports as CSV/PDF.
- Stronger onboarding for first-time users.
- More widget tests around navigation and persistence.
- Optional cloud backup/sync.

## Status

This repository is portfolio-ready as a technical showcase once real screenshots and a short demo video are added to the README or portfolio page.
