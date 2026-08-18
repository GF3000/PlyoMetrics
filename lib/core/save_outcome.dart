sealed class SaveResult {
  const SaveResult();
}

final class SaveSucceeded extends SaveResult {
  const SaveSucceeded();
}

final class SaveCancelled extends SaveResult {
  const SaveCancelled();
}

final class SaveFailed extends SaveResult {
  final Object error;
  final StackTrace stackTrace;

  const SaveFailed(this.error, this.stackTrace);
}
