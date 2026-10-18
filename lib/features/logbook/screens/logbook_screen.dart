import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/location_service.dart';
import '../../navigation/providers/navigation_provider.dart';
import '../providers/logbook_provider.dart';
import '../services/gpx_service.dart';

class LogbookScreen extends StatefulWidget {
  const LogbookScreen({super.key});

  @override
  State<LogbookScreen> createState() => _LogbookScreenState();
}

class _LogbookScreenState extends State<LogbookScreen> {
  final TextEditingController _noteController = TextEditingController();
  bool _savingNote = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logProvider = context.watch<LogbookProvider>();
    final navProvider = context.watch<NavigationProvider>();
    final activeLog = logProvider.activeLog;

    // Le point de trace est ajouté ici, mais le provider déduplique le même
    // timestamp afin qu'une reconstruction de l'écran ne crée pas de doublons.
    if (logProvider.isRecording && navProvider.currentData != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && logProvider.isRecording) {
          logProvider.addPoint(navProvider.currentData!);
        }
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('JOURNAL DE BORD', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          children: [
            _sectionTitle('NOUVELLE ENTRÉE'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: _cardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _noteController,
                    minLines: 3,
                    maxLines: 6,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: 'Ex. : Départ du port, vent de secteur nord-est, mer belle…',
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryTeal, foregroundColor: Colors.white),
                      onPressed: _savingNote ? null : () => _saveNote(logProvider, navProvider),
                      icon: _savingNote
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.add_comment_outlined),
                      label: Text(_savingNote ? 'ENREGISTREMENT…' : 'Ajouter une entrée', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('La date et l’heure sont enregistrées automatiquement. La position GPS est ajoutée si elle est disponible.', style: TextStyle(fontSize: 12, color: AppColors.textMuted, height: 1.35)),
                ],
              ),
            ),
            const SizedBox(height: 22),
            _sectionTitle('MES ENTRÉES'),
            const SizedBox(height: 10),
            if (logProvider.journalNotes.isEmpty)
              _emptyCard('Aucune entrée pour le moment. Écris une première note pendant ta navigation.')
            else
              ...logProvider.journalNotes.map((note) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: _cardDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          const Icon(Icons.schedule, size: 16, color: AppColors.primaryTeal),
                          const SizedBox(width: 6),
                          Expanded(child: Text(_formatDate(note.createdAt), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textMuted))),
                          IconButton(
                            tooltip: 'Supprimer l’entrée',
                            visualDensity: VisualDensity.compact,
                            icon: const Icon(Icons.delete_outline, color: AppColors.alertRed, size: 20),
                            onPressed: () => _confirmDeleteNote(logProvider, note.id),
                          ),
                        ]),
                        Text(note.text, style: const TextStyle(fontSize: 15, height: 1.4, color: AppColors.textDark)),
                        const SizedBox(height: 8),
                        Row(children: [
                          Icon(Icons.location_on_outlined, size: 16, color: note.hasPosition ? AppColors.primaryTeal : AppColors.textMuted),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              note.hasPosition
                                  ? '${note.latitude!.toStringAsFixed(5)}, ${note.longitude!.toStringAsFixed(5)}'
                                  : 'Position GPS indisponible à l’enregistrement',
                              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                            ),
                          ),
                          if (note.hasPosition)
                            IconButton(
                              tooltip: 'Copier les coordonnées',
                              visualDensity: VisualDensity.compact,
                              icon: const Icon(Icons.copy, size: 16, color: AppColors.primaryTeal),
                              onPressed: () => _copyCoordinates(note.latitude!, note.longitude!),
                            ),
                        ]),
                      ],
                    ),
                  )),
            const SizedBox(height: 24),
            _sectionTitle('TRACES GPS'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: _cardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(children: [
                    Icon(Icons.fiber_manual_record, color: logProvider.isRecording ? AppColors.alertRed : AppColors.textMuted, size: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text(logProvider.isRecording ? 'ENREGISTREMENT ACTIF' : 'PRÊT À ENREGISTRER', style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 13))),
                    if (logProvider.isRecording) Text('${activeLog?.points.length ?? 0} pts', style: const TextStyle(color: AppColors.primaryTeal, fontWeight: FontWeight.bold)),
                  ]),
                  if (logProvider.isRecording) ...[
                    const SizedBox(height: 10),
                    Text(activeLog?.title ?? '', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                    Text('Distance : ${activeLog?.totalDistanceNM.toStringAsFixed(2)} NM | Vit. moy. : ${activeLog?.averageSpeedKnots.toStringAsFixed(1)} kn', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.alertRed, foregroundColor: Colors.white),
                      icon: const Icon(Icons.stop),
                      label: const Text('ARRÊTER ET SAUVEGARDER'),
                      onPressed: () => logProvider.stopTrack(),
                    ),
                  ] else
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryTeal, foregroundColor: Colors.white),
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('DÉMARRER UNE TRACE GPS'),
                      onPressed: () => _showStartDialog(context, logProvider),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            if (logProvider.logs.isEmpty)
              _emptyCard('Aucune trace GPS enregistrée.')
            else
              ...logProvider.logs.map((log) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: _cardDecoration(),
                    child: ListTile(
                      title: Text(log.title, style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
                      subtitle: Text('${log.totalDistanceNM.toStringAsFixed(2)} NM • ${log.points.length} points • ${_formatDate(log.startTime)}', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                      trailing: Wrap(spacing: 0, children: [
                        IconButton(icon: const Icon(Icons.share, color: AppColors.primaryTeal), onPressed: () => GpxService.exportAndShare(log)),
                        IconButton(icon: const Icon(Icons.delete_outline, color: AppColors.alertRed), onPressed: () => logProvider.deleteLog(log.id)),
                      ]),
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  Future<void> _saveNote(LogbookProvider provider, NavigationProvider navProvider) async {
    final text = _noteController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Écris une note avant de l’ajouter.')));
      return;
    }
    setState(() => _savingNote = true);
    double? latitude;
    double? longitude;
    final current = navProvider.currentData;
    if (current != null && DateTime.now().difference(current.timestamp).inSeconds.abs() < 120) {
      latitude = current.latitude;
      longitude = current.longitude;
    } else {
      final fresh = await LocationService().getCurrentPosition();
      latitude = fresh?.latitude;
      longitude = fresh?.longitude;
    }
    await provider.addJournalNote(text: text, createdAt: DateTime.now(), latitude: latitude, longitude: longitude);
    if (!mounted) return;
    _noteController.clear();
    setState(() => _savingNote = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(latitude == null ? 'Entrée enregistrée, sans position GPS.' : 'Entrée enregistrée avec la position GPS.')));
  }

  Future<void> _confirmDeleteNote(LogbookProvider provider, String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer cette entrée ?'),
        content: const Text('Cette action est définitive.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Supprimer')),
        ],
      ),
    );
    if (confirm == true) await provider.deleteJournalNote(id);
  }

  Future<void> _copyCoordinates(double latitude, double longitude) async {
    await Clipboard.setData(ClipboardData(text: '$latitude, $longitude'));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Coordonnées copiées.')));
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    String two(int value) => value.toString().padLeft(2, '0');
    return '${two(local.day)}/${two(local.month)}/${local.year} à ${two(local.hour)}:${two(local.minute)}';
  }

  Widget _sectionTitle(String title) => Align(
        alignment: Alignment.centerLeft,
        child: Text(title, style: const TextStyle(color: AppColors.primaryTeal, fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 0.5)),
      );

  Widget _emptyCard(String message) => Container(
        padding: const EdgeInsets.all(16),
        decoration: _cardDecoration(),
        child: Text(message, style: const TextStyle(color: AppColors.textMuted, fontSize: 13, height: 1.35)),
      );

  BoxDecoration _cardDecoration() => BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      );

  void _showStartDialog(BuildContext context, LogbookProvider provider) {
    final controller = TextEditingController(text: 'Nav ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceWhite,
        title: const Text('Nouvelle trace GPS', style: TextStyle(color: AppColors.textDark)),
        content: TextField(controller: controller, decoration: const InputDecoration(labelText: 'Nom de la sortie')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryTeal),
            onPressed: () { provider.startTrack(controller.text); Navigator.pop(ctx); },
            child: const Text('Démarrer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
