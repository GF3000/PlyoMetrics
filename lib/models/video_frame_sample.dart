class VideoFrameSample {
  final int index;
  final String path;
  final double timestampSeconds;

  const VideoFrameSample({
    required this.index,
    required this.path,
    required this.timestampSeconds,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VideoFrameSample &&
          index == other.index &&
          path == other.path &&
          timestampSeconds == other.timestampSeconds;

  @override
  int get hashCode => Object.hash(index, path, timestampSeconds);
}
