# PlyoMetrics - Project Context & Guidelines

## 1. Project Overview
PlyoMetrics is a professional-grade mobile application built with Flutter, designed for sports coaches and athletes to measure jump performance metrics with clinical precision. 
Instead of relying on error-prone AI pose detection, the app uses high-speed video recording (60/120+ FPS) and allows the user to manually select the exact takeoff and landing frames to calculate flight time and contact time.

## 2. Core Features & Workflows
* **Athlete Management:** Group-based management. Dropdown for selecting groups (e.g., U18, First Team) and a horizontal scrollable slider for athletes.
* **CMJ (Countermovement Jump) Baseline:** Requires at least 2 jumps. Calculates the average height, removes outliers, and saves the baseline.
* **Fatigue Test (Readiness):** Compares a daily CMJ against the established baseline. Outputs a Height Loss % to assess neuromuscular fatigue. If the daily jump exceeds the baseline max, prompts the user to redo the baseline.
* **RSI (Reactive Strength Index) Drop Jump:** Measures contact time and flight time from a drop jump to calculate the RSI score.
* **Evolution & Charts:** Visualizes historical data for CMJ, Fatigue, and RSI using line charts.

## 3. Physics & Math Formulas (Core Logic)
The app calculates metrics based on frames and video FPS (Frames Per Second).
* **Flight Time ($t_v$):** $t_v = \frac{\text{Landing Frame} - \text{Takeoff Frame}}{\text{FPS}}$
* **Contact Time ($t_c$):** $t_c = \frac{\text{Takeoff Frame} - \text{Landing Frame 1}}{\text{FPS}}$
* **Jump Height ($h$):** $h = \frac{g \cdot t_v^2}{8}$ (where $g = 9.81$)
* **RSI:** $RSI = \frac{h}{t_c}$

## 4. Technical Architecture & Tech Stack
* **Framework:** Flutter (Mobile strictly vertical orientation).
* **UI Design Origin:** Google Stitch (HTML/CSS references). All web semantics must be translated strictly to native Flutter widgets (Material 3). No webviews.
* **State Management:** `flutter_riverpod`.
* **Data Persistence:** `shared_preferences` (or local SQLite/Hive if the data grows).
* **Key Packages:** `camera`, `video_player` (for precise frame-by-frame scrubbing), `fl_chart`.
* **Folder Structure:** Feature-first architecture inside `/lib` (e.g., `/features/athlete`, `/features/jumps`, `/core`, `/ui_kits`).

## 5. Strict Development Rules for Claude
1. **Language Constraint:** ALL generated code, variable names, UI strings, dialogs, and code comments MUST be in English. Make strings localizable where possible.
2. **Native Widgets Only:** When reading `.html` reference files, never use HTML-rendering packages. Map CSS flexbox to Flutter `Row`/`Column`/`Expanded`. Map CSS colors to Dart `Color(0xFF...)`.
3. **Null Safety & Modern Dart:** Always use sound null safety, `final` variables where appropriate, and modern Dart 3 features (records, pattern matching if useful).
4. **State Management:** Do not use `setState` for global or complex state. Always default to Riverpod `Notifier` or `StateNotifier`.
5. **Video Processing constraints:** Do not implement automated AI pose detection for contact times. The architecture relies on building a robust video player UI that allows manual frame-by-frame advancing and timestamp extraction.