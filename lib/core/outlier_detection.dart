import 'dart:math';

typedef MeasurementSample = ({double value, double uncertainty});

List<bool> detectOutliers(List<MeasurementSample> samples) {
  if (samples.length < 3) {
    return List<bool>.filled(samples.length, false);
  }

  final values = samples.map((sample) => sample.value).toList()..sort();
  final median = _median(values);
  final deviations = values.map((value) => (value - median).abs()).toList()
    ..sort();
  final medianAbsoluteDeviation = _median(deviations);
  final robustSpread = 3 * 1.4826 * medianAbsoluteDeviation;

  return samples.map((sample) {
    final threshold = max(
      max(median.abs() * 0.10, sample.uncertainty * 2),
      robustSpread,
    );
    return (sample.value - median).abs() > threshold;
  }).toList();
}

double _median(List<double> sortedValues) {
  final middle = sortedValues.length ~/ 2;
  if (sortedValues.length.isOdd) {
    return sortedValues[middle];
  }
  return (sortedValues[middle - 1] + sortedValues[middle]) / 2;
}
