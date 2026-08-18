import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../core/theme.dart';
import '../models/athlete_group.dart';
import '../services/isar_service.dart';

/// Dialog to create a new AthleteGroup.
/// Returns the newly created [AthleteGroup] via Navigator.pop, or null if cancelled.
class AddGroupDialog extends StatefulWidget {
  const AddGroupDialog({super.key});

  @override
  State<AddGroupDialog> createState() => _AddGroupDialogState();
}

class _AddGroupDialogState extends State<AddGroupDialog> {
  final _nameController = TextEditingController();
  bool _saving = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final l = AppLocalizations.of(context)!;
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _errorMessage = l.requiredField);
      return;
    }

    setState(() {
      _saving = true;
      _errorMessage = null;
    });
    try {
      final group = await IsarService.instance.addGroup(name);
      if (mounted) Navigator.of(context).pop(group);
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
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
      title: Text(l.newGroup, style: const TextStyle(color: Colors.white)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_errorMessage != null) ...[
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.redAccent),
            ),
            const SizedBox(height: 12),
          ],
          TextField(
            controller: _nameController,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: l.groupName,
              labelStyle: const TextStyle(color: AppColors.textSecondary),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: AppColors.borderLight),
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: AppColors.brand),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onSubmitted: (_) => _create(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: Text(l.cancel),
        ),
        FilledButton(
          onPressed: _saving ? null : _create,
          child: _saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l.create),
        ),
      ],
    );
  }
}
