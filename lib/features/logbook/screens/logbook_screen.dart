import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../navigation/providers/navigation_provider.dart';
import '../models/log_entry.dart';
import '../providers/logbook_provider.dart';
import '../services/gpx_service.dart';

class LogbookScreen extends StatelessWidget {
  const LogbookScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final logProvider = context.watch<LogbookProvider>();
    final navProvider = context.watch<NavigationProvider>();
    final activeLog = logProvider.activeLog;

    // Ajoute la position au journal lors des déplacements
    if (logProvider.isRecording && navProvider.currentData != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        logProvider.addPoint(navProvider.currentData!);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('JOURNAL DE BORD', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryDark,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Panneau de contrôle de l'enregistrement actif
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: logProvider.isRecording ? AppColors.okGreen : AppColors.primary,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.fiber_manual_record,
                              color: logProvider.isRecording ? AppColors.alertRed : Colors.white38,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              logProvider.isRecording ? 'ENREGISTREMENT ACTIF' : 'PRÊT À ENREGISTRER',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        if (logProvider.isRecording)
                          Text(
                            '${activeLog?.points.length ?? 0} pts',
                            style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (logProvider.isRecording) ...[
                      Text(
                        activeLog?.title ?? '',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Distance : ${activeLog?.totalDistanceNM.toStringAsFixed(2)} NM | Vit. Moy : ${activeLog?.averageSpeedKnots.toStringAsFixed(1)} kn',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.alertRed),
                          icon: const Icon(Icons.stop, color: Colors.white),
                          label: const Text('ARRÊTER ET SAUVEGARDER', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          onPressed: () => logProvider.stopTrack(),
                        ),
                      ),
                    ] else ...[
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.okGreen),
                          icon: const Icon(Icons.play_arrow, color: Colors.white),
                          label: const Text('DÉMARRER UNE TRACE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          onPressed: () => _showStartDialog(context, logProvider),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Liste des traces enregistrées
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('TRACES ENREGISTRÉES', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              const SizedBox(height: 10),

              Expanded(
                child: logProvider.logs.isEmpty
                    ? const Center(
                        child: Text('Aucune trace enregistrée pour le moment.', style: TextStyle(color: Colors.white54)),
                      )
                    : ListView.builder(
                        itemCount: logProvider.logs.length,
                        itemBuilder: (context, index) {
                          final log = logProvider.logs[index];
                          return Card(
                            color: AppColors.surfaceDark,
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              title: Text(log.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              subtitle: Text(
                                '${log.totalDistanceNM.toStringAsFixed(2)} NM • ${log.points.length} points • ${log.startTime.day}/${log.startTime.month}/${log.startTime.year}',
                                style: const TextStyle(color: Colors.white60, fontSize: 13),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.share, color: AppColors.accent),
                                    onPressed: () => GpxService.exportAndShare(log),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: AppColors.alertRed),
                                    onPressed: () => logProvider.deleteLog(log.id),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showStartDialog(BuildContext context, LogbookProvider provider) {
    final controller = TextEditingController(text: 'Nav ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: const Text('Nouvelle navigation', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Nom de la sortie',
            labelStyle: TextStyle(color: Colors.white70),
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Annuler'),
            onPressed: () => Navigator.pop(ctx),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Démarrer', style: TextStyle(color: Colors.white)),
            onPressed: () {
              provider.startTrack(controller.text);
              Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }
}
