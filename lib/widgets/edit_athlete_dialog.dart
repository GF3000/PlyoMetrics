import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../core/localized_number_parser.dart';
import '../core/theme.dart';
import '../models/athlete.dart';
import '../services/isar_service.dart';

/// Dialog to edit an existing [Athlete]'s name, weight, and height.
/// Returns the updated [Athlete] via Navigator.pop, or null if cancelled.
class EditAthleteDialog extends StatefulWidget {
  final Athlete athlete;

  const EditAthleteDialog({super.key, required this.athlete});

  @override
  State<EditAthleteDialog> createState() => _EditAthleteDialogState();
}

class _EditAthleteDialogState extends State<EditAthleteDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _weightController;
  late final TextEditingController _heightController;
  bool _saving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.athlete.name);
    _weightController = TextEditingController(
      text: widget.athlete.weightKg?.toString() ?? '',
    );
    _heightController = TextEditingController(
      text: widget.athlete.heightCm?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
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
      final updated = await IsarService.instance.updateAthlete(
        widget.athlete,
        name: name,
        weightKg: weight,
        heightCm: height,
        clearWeight: weightStr.isEmpty,
        clearHeight: heightStr.isEmpty,
      );
      if (mounted) Navigator.of(context).pop(updated);
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
      title: Text(l.editAthlete, style: const TextStyle(color: Colors.white)),
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
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l.save),
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
