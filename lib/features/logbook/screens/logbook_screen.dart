import 'package:flutter/material.dart';
import 'package:kipmarine/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../navigation/providers/navigation_provider.dart';
import '../providers/logbook_provider.dart';
import '../services/gpx_service.dart';

class LogbookScreen extends StatelessWidget {
  const LogbookScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final logProvider = context.watch<LogbookProvider>();
    final navProvider = context.watch<NavigationProvider>();
    final activeLog = logProvider.activeLog;
    final colors = Theme.of(context).colorScheme;
    final gps = navProvider.currentData;

    if (logProvider.isRecording && gps != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) logProvider.addPoint(gps);
      });
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.logbookScreenTitle, style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colors.primary.withValues(alpha: 0.14),
                    colors.tertiary.withValues(alpha: 0.08),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: logProvider.isRecording
                      ? Colors.green.withValues(alpha: 0.65)
                      : colors.outlineVariant,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        logProvider.isRecording ? Icons.radio_button_checked : Icons.sailing,
                        color: logProvider.isRecording ? Colors.green : colors.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          logProvider.isRecording ? l10n.logbookRecording : l10n.logbookYourJournal,
                          style: TextStyle(
                            color: colors.onSurface,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      if (logProvider.isRecording)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${activeLog?.points.length ?? 0} pts',
                            style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    logProvider.isRecording
                        ? (activeLog?.title ?? l10n.logbookNavigationInProgress)
                        : l10n.logbookIntro,
                    style: TextStyle(fontSize: 15, color: colors.onSurface),
                  ),
                  if (logProvider.isRecording) ...[
                    const SizedBox(height: 8),
                    Text(
                      '${l10n.logbookDistanceAverage(activeLog?.totalDistanceNM.toStringAsFixed(2) ?? '0', activeLog?.averageSpeedKnots.toStringAsFixed(1) ?? '0')}',
                      style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
                    ),
                  ],
                  const SizedBox(height: 16),
                  if (logProvider.isRecording)
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.alertRed,
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.stop),
                        label: const Text('ARRÊTER ET SAUVEGARDER LA TRACE'),
                        onPressed: () => logProvider.stopTrack(),
                      ),
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.primary,
                          foregroundColor: colors.onPrimary,
                        ),
                        icon: const Icon(Icons.play_arrow),
                        label: const Text(l10n.logbookStartTrack),
                        onPressed: () => _showStartDialog(context, logProvider),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 52,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: colors.tertiary,
                  foregroundColor: colors.onTertiary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.add_comment_outlined),
                label: const Text(l10n.logbookAddEntry, style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () => _showJournalEntryDialog(context, logProvider, gps),
              ),
            ),
            const SizedBox(height: 24),
            _sectionTitle(context, l10n.logbookNotesTitle, Icons.edit_note),
            const SizedBox(height: 10),
            if (logProvider.notes.isEmpty)
              _emptyState(
                context,
                icon: Icons.menu_book_outlined,
                message: l10n.logbookEmptyNotes,
              )
            else
              ...logProvider.notes.map((note) {
                final hasPosition = note.latitude != null && note.longitude != null;
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  elevation: 0,
                  color: colors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: colors.outlineVariant),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 4, 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: colors.tertiary.withValues(alpha: 0.13),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.notes, color: colors.tertiary),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                note.text,
                                style: TextStyle(color: colors.onSurface, fontSize: 15),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _formatDateTime(note.timestamp),
                                style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    hasPosition ? Icons.location_on_outlined : Icons.location_off_outlined,
                                    size: 14,
                                    color: colors.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      hasPosition
                                          ? '${note.latitude!.toStringAsFixed(5)}, ${note.longitude!.toStringAsFixed(5)}'
                                          : l10n.logbookGpsUnavailable,
                                      style: TextStyle(color: colors.onSurfaceVariant, fontSize: 11),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: l10n.logbookDeleteNoteTooltip,
                          icon: Icon(Icons.delete_outline, color: colors.error),
                          onPressed: () => _confirmDeleteNote(context, logProvider, note.id),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            const SizedBox(height: 14),
            _sectionTitle(context, l10n.logbookTracksTitle, Icons.route),
            const SizedBox(height: 10),
            if (logProvider.logs.isEmpty)
              _emptyState(
                context,
                icon: Icons.route_outlined,
                message: l10n.logbookEmptyTracks,
              )
            else
              ...logProvider.logs.map((log) => Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    elevation: 0,
                    color: colors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: colors.outlineVariant),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: colors.primary.withValues(alpha: 0.12),
                        child: Icon(Icons.route, color: colors.primary),
                      ),
                      title: Text(
                        log.title,
                        style: TextStyle(color: colors.onSurface, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${log.totalDistanceNM.toStringAsFixed(2)} NM • ${log.points.length} points\n${_formatDateTime(log.startTime)}',
                        style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
                      ),
                      isThreeLine: true,
                      trailing: Wrap(
                        spacing: 0,
                        children: [
                          IconButton(
                            tooltip: l10n.logbookExportGpx,
                            icon: Icon(Icons.ios_share, color: colors.primary),
                            onPressed: () => GpxService.exportAndShare(log),
                          ),
                          IconButton(
                            tooltip: l10n.logbookDeleteTrack,
                            icon: Icon(Icons.delete_outline, color: colors.error),
                            onPressed: () => _confirmDeleteTrack(context, logProvider, log.id),
                          ),
                        ],
                      ),
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  static Widget _sectionTitle(BuildContext context, String title, IconData icon) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, color: colors.primary, size: 21),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: colors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 15,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }

  static Widget _emptyState(BuildContext context, {required IconData icon, required String message}) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, size: 28, color: colors.onSurfaceVariant),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
          ),
        ],
      ),
    );
  }

  static Future<void> _showJournalEntryDialog(
    BuildContext context,
    LogbookProvider provider,
    dynamic gps,
  ) async {
    final controller = TextEditingController();
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.logbookNewEntry),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: controller,
              autofocus: true,
              minLines: 3,
              maxLines: 6,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: l10n.logbookEntryHint,
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  gps != null ? Icons.location_on_outlined : Icons.location_off_outlined,
                  color: gps != null ? colors.primary : colors.onSurfaceVariant,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    gps != null ? l10n.logbookGpsAttached : l10n.logbookNoGpsSaved,
                    style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.logbookCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.logbookSave),
          ),
        ],
      ),
    );

    if (saved == true && controller.text.trim().isNotEmpty) {
      provider.addJournalNote(controller.text, position: gps);
    }
    controller.dispose();
  }

  static Future<void> _showStartDialog(BuildContext context, LogbookProvider provider) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController(
      text: 'Navigation ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
    );
    final colors = Theme.of(context).colorScheme;
    final start = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.logbookNewNavigation),
        content: TextField(
          controller: controller,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: l10n.logbookTripName,
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: colors.primary, foregroundColor: colors.onPrimary),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.logbookStart),
          ),
        ],
      ),
    );
    if (start == true) provider.startTrack(controller.text);
    controller.dispose();
  }

  static Future<void> _confirmDeleteNote(
    BuildContext context,
    LogbookProvider provider,
    String id,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Supprimer cette note ?'),
        content: const Text('Cette action est définitive.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Annuler')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Supprimer')),
        ],
      ),
    );
    if (confirmed == true) await provider.deleteJournalNote(id);
  }

  static Future<void> _confirmDeleteTrack(
    BuildContext context,
    LogbookProvider provider,
    String id,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Supprimer cette trace ?'),
        content: const Text('La trace GPS et ses points seront supprimés.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Annuler')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Supprimer')),
        ],
      ),
    );
    if (confirmed == true) await provider.deleteLog(id);
  }

  static String _formatDateTime(DateTime value) {
    String two(int number) => number.toString().padLeft(2, '0');
    return '${two(value.day)}/${two(value.month)}/${value.year} à ${two(value.hour)}:${two(value.minute)}';
  }
}
