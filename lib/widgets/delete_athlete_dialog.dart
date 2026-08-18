import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../core/theme.dart';
import '../models/athlete.dart';
import '../services/isar_service.dart';

/// Confirmation dialog to delete an [Athlete].
/// Returns `true` via Navigator.pop if the athlete was deleted, `null` otherwise.
class DeleteAthleteDialog extends StatefulWidget {
  final Athlete athlete;

  const DeleteAthleteDialog({super.key, required this.athlete});

  @override
  State<DeleteAthleteDialog> createState() => _DeleteAthleteDialogState();
}

class _DeleteAthleteDialogState extends State<DeleteAthleteDialog> {
  bool _deleting = false;
  String? _errorMessage;

  Future<void> _delete() async {
    final l = AppLocalizations.of(context)!;
    setState(() => _deleting = true);
    try {
      await IsarService.instance.deleteAthlete(widget.athlete);
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (mounted) {
        setState(() {
          _deleting = false;
          _errorMessage = l.operationFailed;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return AlertDialog(
      backgroundColor: AppColors.card,
      title: Text(l.deleteAthlete, style: const TextStyle(color: Colors.white)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l.confirmDeleteAthlete(widget.athlete.name),
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.redAccent),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _deleting ? null : () => Navigator.of(context).pop(),
          child: Text(l.cancel),
        ),
        FilledButton(
          onPressed: _deleting ? null : _delete,
          style: FilledButton.styleFrom(backgroundColor: Colors.red),
          child: _deleting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(l.delete),
        ),
      ],
    );
  }
}
