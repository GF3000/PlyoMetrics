import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../core/localized_number_parser.dart';
import '../core/theme.dart';
import '../models/athlete.dart';
import '../models/athlete_group.dart';
import '../services/isar_service.dart';

/// Dialog to create a new Athlete within a given [group].
/// Returns the newly created [Athlete] via Navigator.pop, or null if cancelled.
class AddAthleteDialog extends StatefulWidget {
  final AthleteGroup group;

  const AddAthleteDialog({super.key, required this.group});

  @override
  State<AddAthleteDialog> createState() => _AddAthleteDialogState();
}

class _AddAthleteDialogState extends State<AddAthleteDialog> {
  final _nameController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  bool _saving = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    final l = AppLocalizations.of(context)!;
    final name = _nameController.text.trim();
    final weightStr = _weightController.text.trim();
    final heightStr = _heightController.text.trim();
    if (name.isEmpty) {
      setState(() => _errorMessage = l.requiredField);
      return;
    }

    double? weight;
    if (weightStr.isNotEmpty) {
      weight = parseLocalizedPositiveDouble(weightStr, l.localeName);
      if (weight == null) {
        setState(() => _errorMessage = l.positiveNumberRequired);
        return;
      }
    }

    double? height;
    if (heightStr.isNotEmpty) {
      height = parseLocalizedPositiveDouble(heightStr, l.localeName);
      if (height == null) {
        setState(() => _errorMessage = l.positiveNumberRequired);
        return;
      }
    }

    setState(() {
      _saving = true;
      _errorMessage = null;
    });
    try {
      final athlete = await IsarService.instance.addAthlete(
        name: name,
        weightKg: weight,
        heightCm: height,
        group: widget.group,
      );
      if (mounted) Navigator.of(context).pop(athlete);
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
      title: Text(
        l.addAthleteTitle,
        style: const TextStyle(color: Colors.white),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_errorMessage != null) ...[
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.redAccent),
              ),
              const SizedBox(height: 12),
            ],
            _buildField(_nameController, l.name, TextInputType.text),
            const SizedBox(height: 12),
            _buildField(_weightController, l.weightKg, TextInputType.number),
            const SizedBox(height: 12),
            _buildField(_heightController, l.heightLabel, TextInputType.number),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: Text(l.cancel),
        ),
        FilledButton(
          onPressed: _saving ? null : _add,
          child: _saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l.add),
        ),
      ],
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label,
    TextInputType type,
  ) {
    return TextField(
      controller: controller,
      keyboardType: type,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
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
    );
  }
}
