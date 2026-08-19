import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/backup_service.dart';
import '../services/csv_export_service.dart';
import '../services/export_file_service.dart';
import 'management_providers.dart';

/// JSON backup export/import service.
final backupServiceProvider = Provider<BackupService>((ref) {
  return BackupService(ref.watch(isarServiceProvider));
});

/// CSV document builder.
final csvExportServiceProvider = Provider<CsvExportService>((ref) {
  return const CsvExportService();
});

/// Temporary file writing + native share sheet.
final exportFileServiceProvider = Provider<ExportFileService>((ref) {
  return const ExportFileService();
});

/// Status of the currently running import/export operation.
enum DataTransferStatus { idle, running }

/// Tracks whether a data transfer operation is in flight so the UI can disable
/// its entry points and show progress.
class DataTransferNotifier extends Notifier<DataTransferStatus> {
  @override
  DataTransferStatus build() => DataTransferStatus.idle;

  bool get isRunning => state == DataTransferStatus.running;

  /// Runs [action] guarding against concurrent executions. Returns null when
  /// another operation is already running.
  Future<T?> run<T>(Future<T> Function() action) async {
    if (state == DataTransferStatus.running) return null;
    state = DataTransferStatus.running;
    try {
      return await action();
    } finally {
      state = DataTransferStatus.idle;
    }
  }
}

final dataTransferProvider =
    NotifierProvider<DataTransferNotifier, DataTransferStatus>(
      DataTransferNotifier.new,
    );
