import 'package:flutter/material.dart';
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

  Future<void> _delete() async {
    setState(() => _deleting = true);
    try {
      await IsarService.instance.deleteAthlete(widget.athlete);
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      setState(() => _deleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.card,
      title:
          const Text('Delete Athlete', style: TextStyle(color: Colors.white)),
      content: Text(
        'Are you sure you want to delete ${widget.athlete.name}?',
        style: const TextStyle(color: AppColors.textSecondary),
      ),
      actions: [
        TextButton(
          onPressed: _deleting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _deleting ? null : _delete,
          style: FilledButton.styleFrom(backgroundColor: Colors.red),
          child: _deleting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : const Text('Delete'),
        ),
      ],
    );
  }
}
