import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../core/theme.dart';
import '../l10n/app_localizations.dart';
import '../models/athlete.dart';
import '../models/athlete_group.dart';
import '../providers/data_transfer_providers.dart';
import '../providers/management_providers.dart';
import '../services/backup_service.dart';

/// Entry points for the import/export flows, shared by the dashboard header,
/// the athlete history screen and the group overview screen.
class DataTransferActions {
  const DataTransferActions._();

  /// Full JSON backup of every group (or a subset chosen by the user).
  static Future<void> exportBackup(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context)!;
    final service = ref.read(isarServiceProvider);
    final groups = await service.getAllGroups();
    if (!context.mounted) return;
    if (groups.isEmpty) {
      _notify(context, l.nothingToExport);
      return;
    }

    final selection = await showDialog<Set<int>>(
      context: context,
      builder: (_) => _GroupSelectionDialog(groups: groups),
    );
    if (selection == null || selection.isEmpty || !context.mounted) return;

    final exportAll = selection.length == groups.length;
    await _guard(context, ref, l.exportFailed, () async {
      final json = await ref
          .read(backupServiceProvider)
          .exportToJson(groupIds: exportAll ? null : selection);
      await ref
          .read(exportFileServiceProvider)
          .shareDocument(
            content: json,
            baseName: 'plyometrics_backup',
            extension: 'json',
            subject: l.exportData,
          );
    });
  }

  /// Restores a previously exported JSON backup.
  static Future<void> importBackup(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context)!;
    final notifier = ref.read(dataTransferProvider.notifier);
    if (notifier.isRunning) return;

    String? content;
    try {
      content = await ref.read(exportFileServiceProvider).pickBackupContent();
    } catch (_) {
      if (context.mounted) _notify(context, l.importFailed);
      return;
    }
    if (content == null || !context.mounted) return;

    final BackupData data;
    try {
      data = ref.read(backupServiceProvider).parse(content);
    } on BackupFormatException catch (error) {
      if (context.mounted) _notify(context, _formatErrorMessage(l, error));
      return;
    } catch (_) {
      if (context.mounted) _notify(context, l.importFailedMalformed);
      return;
    }

    if (data.athleteCount == 0 && data.groupCount == 0) {
      _notify(context, l.importFailedInvalid);
      return;
    }

    final merge = await showDialog<bool>(
      context: context,
      builder: (_) => _ImportConfirmationDialog(data: data),
    );
    if (merge == null || !context.mounted) return;

    await _guard(context, ref, l.importFailed, () async {
      final result = await ref
          .read(backupServiceProvider)
          .import(data, mergeIntoExistingGroups: merge);

      ref.invalidate(groupsProvider);
      ref.invalidate(groupAthletesProvider);
      ref.invalidate(athleteJumpHistoryProvider);
      ref.invalidate(groupOverviewProvider);

      if (context.mounted) {
        _notify(
          context,
          l.importCompleted(
            result.groupsCreated + result.groupsMerged,
            result.athletesImported,
            result.jumpTestsImported,
          ),
        );
      }
    });
  }

  /// CSV with every jump of a single athlete.
  static Future<void> exportAthleteJumps(
    BuildContext context,
    WidgetRef ref,
    Athlete athlete,
  ) async {
    final l = AppLocalizations.of(context)!;
    await _guard(context, ref, l.exportFailed, () async {
      final tests = await ref
          .read(isarServiceProvider)
          .getAllJumpTestsForAthletes([athlete.id]);
      if (tests.isEmpty) {
        if (context.mounted) _notify(context, l.nothingToExport);
        return;
      }
      final csv = ref
          .read(csvExportServiceProvider)
          .athleteJumps(athlete, tests);
      await ref
          .read(exportFileServiceProvider)
          .shareDocument(
            content: csv,
            baseName: 'plyometrics_${athlete.name}_jumps',
            extension: 'csv',
            subject: l.exportJumps,
          );
    });
  }

  /// Bottom sheet offering the two group level CSV exports.
  static Future<void> showGroupExportSheet(
    BuildContext context,
    WidgetRef ref,
    AthleteGroup group,
  ) {
    final l = AppLocalizations.of(context)!;
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                group.name,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.emoji_events_outlined, color: AppColors.brand),
              title: Text(
                l.exportGroupMarks,
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                l.exportGroupMarksSubtitle,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              onTap: () {
                Navigator.pop(sheetContext);
                exportGroup(context, ref, group, marksOnly: true);
              },
            ),
            ListTile(
              leading: const Icon(Icons.list_alt, color: AppColors.brand),
              title: Text(
                l.exportAllJumps,
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                l.exportAllJumpsSubtitle,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              onTap: () {
                Navigator.pop(sheetContext);
                exportGroup(context, ref, group, marksOnly: false);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  /// CSV export for a whole group: aggregated marks or every jump.
  static Future<void> exportGroup(
    BuildContext context,
    WidgetRef ref,
    AthleteGroup group, {
    required bool marksOnly,
  }) async {
    final l = AppLocalizations.of(context)!;
    await _guard(context, ref, l.exportFailed, () async {
      final service = ref.read(isarServiceProvider);
      final athletes = await service.getAthletesForGroup(group);
      if (athletes.isEmpty) {
        if (context.mounted) _notify(context, l.nothingToExport);
        return;
      }
      final tests = await service.getAllJumpTestsForAthletes(
        athletes.map((athlete) => athlete.id),
      );
      if (!marksOnly && tests.isEmpty) {
        if (context.mounted) _notify(context, l.nothingToExport);
        return;
      }

      final csvService = ref.read(csvExportServiceProvider);
      final csv = marksOnly
          ? csvService.groupMarks(
              groupName: group.name,
              athletes: athletes,
              tests: tests,
            )
          : csvService.groupJumps(
              groupName: group.name,
              athletes: athletes,
              tests: tests,
            );

      await ref
          .read(exportFileServiceProvider)
          .shareDocument(
            content: csv,
            baseName:
                'plyometrics_${group.name}_${marksOnly ? 'marks' : 'jumps'}',
            extension: 'csv',
            subject: marksOnly ? l.exportGroupMarks : l.exportAllJumps,
          );
    });
  }

  // ── Helpers ──

  static Future<void> _guard(
    BuildContext context,
    WidgetRef ref,
    String errorMessage,
    Future<void> Function() action,
  ) async {
    try {
      await ref.read(dataTransferProvider.notifier).run(action);
    } catch (_) {
      if (context.mounted) _notify(context, errorMessage);
    }
  }

  static void _notify(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  static String _formatErrorMessage(
    AppLocalizations l,
    BackupFormatException error,
  ) {
    return switch (error.reason) {
      BackupFormatError.malformed => l.importFailedMalformed,
      BackupFormatError.unsupportedVersion => l.importFailedVersion,
      BackupFormatError.invalidContent => l.importFailedInvalid,
    };
  }
}

class _GroupSelectionDialog extends StatefulWidget {
  const _GroupSelectionDialog({required this.groups});

  final List<AthleteGroup> groups;

  @override
  State<_GroupSelectionDialog> createState() => _GroupSelectionDialogState();
}

class _GroupSelectionDialogState extends State<_GroupSelectionDialog> {
  late final Set<int> _selected = widget.groups.map((g) => g.id).toSet();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final allSelected = _selected.length == widget.groups.length;

    return AlertDialog(
      backgroundColor: AppColors.card,
      title: Text(
        l.exportData,
        style: const TextStyle(color: Colors.white),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.selectGroupsToExport,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            CheckboxListTile(
              value: allSelected,
              onChanged: (value) => setState(() {
                _selected
                  ..clear()
                  ..addAll(
                    value == true
                        ? widget.groups.map((group) => group.id)
                        : const <int>[],
                  );
              }),
              title: Text(
                l.selectAll,
                style: const TextStyle(color: Colors.white),
              ),
              activeColor: AppColors.brand,
              contentPadding: EdgeInsets.zero,
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: widget.groups
                    .map(
                      (group) => CheckboxListTile(
                        value: _selected.contains(group.id),
                        onChanged: (value) => setState(() {
                          if (value == true) {
                            _selected.add(group.id);
                          } else {
                            _selected.remove(group.id);
                          }
                        }),
                        title: Text(
                          group.name,
                          style: const TextStyle(color: Colors.white),
                          overflow: TextOverflow.ellipsis,
                        ),
                        activeColor: AppColors.brand,
                        contentPadding: EdgeInsets.zero,
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l.cancel),
        ),
        TextButton(
          onPressed: _selected.isEmpty
              ? null
              : () => Navigator.of(context).pop(_selected),
          child: Text(l.export),
        ),
      ],
    );
  }
}

class _ImportConfirmationDialog extends StatefulWidget {
  const _ImportConfirmationDialog({required this.data});

  final BackupData data;

  @override
  State<_ImportConfirmationDialog> createState() =>
      _ImportConfirmationDialogState();
}

class _ImportConfirmationDialogState extends State<_ImportConfirmationDialog> {
  bool _merge = true;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final exportedAt = widget.data.exportedAt;

    return AlertDialog(
      backgroundColor: AppColors.card,
      title: Text(
        l.importBackupTitle,
        style: const TextStyle(color: Colors.white),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.backupContentSummary(
              widget.data.groupCount,
              widget.data.athleteCount,
              widget.data.jumpTestCount,
            ),
            style: const TextStyle(color: Colors.white),
          ),
          if (exportedAt != null) ...[
            const SizedBox(height: 4),
            Text(
              l.backupCreatedOn(
                DateFormat('MMM dd, yyyy', l.localeName).format(exportedAt),
              ),
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            l.duplicateGroupStrategy,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          _strategyOption(
            label: l.mergeIntoExistingGroup,
            selected: _merge,
            onTap: () => setState(() => _merge = true),
          ),
          _strategyOption(
            label: l.createSeparateGroup,
            selected: !_merge,
            onTap: () => setState(() => _merge = false),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_merge),
          child: Text(l.import),
        ),
      ],
    );
  }

  Widget _strategyOption({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      leading: Icon(
        selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
        color: selected ? AppColors.brand : AppColors.textSecondary,
      ),
      title: Text(label, style: const TextStyle(color: Colors.white)),
    );
  }
}
