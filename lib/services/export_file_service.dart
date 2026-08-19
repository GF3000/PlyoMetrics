import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Writes generated documents to a temporary file and hands them to the
/// platform share sheet. Also handles picking a backup file for import.
///
/// Keeping the plugin usage isolated here lets the serialization services be
/// unit tested without platform channels.
class ExportFileService {
  const ExportFileService();

  /// Persists [content] as `<baseName>_<timestamp>.<extension>` in the
  /// temporary directory and opens the native share sheet.
  Future<void> shareDocument({
    required String content,
    required String baseName,
    required String extension,
    String? subject,
  }) async {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/${fileName(baseName, extension)}');
    await file.writeAsString(content, encoding: utf8, flush: true);
    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path)], subject: subject),
    );
  }

  /// Lets the user pick a JSON backup and returns its contents, or null when
  /// the picker was dismissed.
  Future<String?> pickBackupContent() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      withData: true,
    );
    final files = result?.files;
    if (files == null || files.isEmpty) return null;
    final picked = files.first;
    final bytes = picked.bytes;
    if (bytes != null) return utf8.decode(bytes, allowMalformed: true);
    final path = picked.path;
    if (path == null) return null;
    return File(path).readAsString();
  }

  /// Builds a deterministic, filesystem-safe file name.
  static String fileName(String baseName, String extension, {DateTime? now}) {
    final timestamp = now ?? DateTime.now();
    final stamp =
        '${timestamp.year.toString().padLeft(4, '0')}'
        '${timestamp.month.toString().padLeft(2, '0')}'
        '${timestamp.day.toString().padLeft(2, '0')}_'
        '${timestamp.hour.toString().padLeft(2, '0')}'
        '${timestamp.minute.toString().padLeft(2, '0')}';
    return '${sanitize(baseName)}_$stamp.$extension';
  }

  /// Replaces characters that are invalid in file names.
  static String sanitize(String value) {
    final cleaned = value
        .trim()
        .replaceAll(RegExp(r'[^A-Za-z0-9._-]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
    return cleaned.isEmpty ? 'plyometrics' : cleaned.toLowerCase();
  }
}
