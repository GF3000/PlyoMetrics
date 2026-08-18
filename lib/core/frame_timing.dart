double? parseFrameRate(String? value) {
  if (value == null || value.isEmpty) return null;
  final parts = value.split('/');
  final numerator = double.tryParse(parts.first);
  final denominator = parts.length == 2 ? double.tryParse(parts[1]) : 1.0;
  if (numerator == null ||
      denominator == null ||
      numerator <= 0 ||
      denominator <= 0) {
    return null;
  }
  final fps = numerator / denominator;
  return fps.isFinite && fps > 0 ? fps : null;
}

List<double> alignFrameTimestamps({
  required int frameCount,
  required List<double> probedTimestamps,
  required double startTimeSeconds,
  required double fallbackFps,
}) {
  final sorted = [...probedTimestamps]..sort();
  final aligned = <double>[];
  for (final timestamp in sorted) {
    if (timestamp + 0.000001 < startTimeSeconds) continue;
    if (aligned.isEmpty || timestamp > aligned.last) {
      aligned.add(timestamp);
    }
  }

  if (aligned.length >= frameCount) {
    return aligned.take(frameCount).toList();
  }
  return List<double>.generate(
    frameCount,
    (index) => startTimeSeconds + (index / fallbackFps),
  );
}
