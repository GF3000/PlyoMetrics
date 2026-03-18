import 'package:flutter/material.dart';
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

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    setState(() => _saving = true);
    try {
      final group = await IsarService.instance.addGroup(name);
      if (mounted) Navigator.of(context).pop(group);
    } catch (_) {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.card,
      title: const Text('New Group', style: TextStyle(color: Colors.white)),
      content: TextField(
        controller: _nameController,
        autofocus: true,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: 'Group Name',
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
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _create,
          child: _saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Create'),
        ),
      ],
    );
  }
}
