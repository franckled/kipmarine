import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../navigation/providers/navigation_provider.dart';
import '../providers/logbook_provider.dart';
import '../services/gpx_service.dart';

class LogbookScreen extends StatelessWidget {
  const LogbookScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final logProvider = context.watch<LogbookProvider>();
    final navProvider = context.watch<NavigationProvider>();
    final activeLog = logProvider.activeLog;

    if (logProvider.isRecording && navProvider.currentData != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        logProvider.addPoint(navProvider.currentData!);
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: logProvider.isRecording ? AppColors.okGreen : AppColors.cardBorder,
                    width: 1.5,
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
                              color: logProvider.isRecording ? AppColors.alertRed : AppColors.textMuted,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              logProvider.isRecording ? 'ENREGISTREMENT ACTIF' : 'PRÊT À ENREGISTRER',
                              style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        if (logProvider.isRecording)
                          Text(
                            '${activeLog?.points.length ?? 0} pts',
                            style: const TextStyle(color: AppColors.primaryTeal, fontWeight: FontWeight.bold),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (logProvider.isRecording) ...[
                      Text(
                        activeLog?.title ?? '',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Distance : ${activeLog?.totalDistanceNM.toStringAsFixed(2)} NM | Vit. Moy : ${activeLog?.averageSpeedKnots.toStringAsFixed(1)} kn',
                        style: const TextStyle(color: AppColors.textMuted),
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
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryTeal),
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

              const Align(
                alignment: Alignment.centerLeft,
                child: Text('TRACES ENREGISTRÉES', style: TextStyle(color: AppColors.primaryTeal, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              const SizedBox(height: 10),

              Expanded(
                child: logProvider.logs.isEmpty
                    ? const Center(
                        child: Text('Aucune trace enregistrée pour le moment.', style: TextStyle(color: AppColors.textMuted)),
                      )
                    : ListView.builder(
                        itemCount: logProvider.logs.length,
                        itemBuilder: (context, index) {
                          final log = logProvider.logs[index];
                          return Card(
                            color: AppColors.surfaceWhite,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: const BorderSide(color: AppColors.cardBorder),
                            ),
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              title: Text(log.title, style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
                              subtitle: Text(
                                '${log.totalDistanceNM.toStringAsFixed(2)} NM • ${log.points.length} points • ${log.startTime.day}/${log.startTime.month}/${log.startTime.year}',
                                style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.share, color: AppColors.primaryTeal),
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
        backgroundColor: AppColors.surfaceWhite,
        title: const Text('Nouvelle navigation', style: TextStyle(color: AppColors.textDark)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: AppColors.textDark),
          decoration: const InputDecoration(
            labelText: 'Nom de la sortie',
            labelStyle: TextStyle(color: AppColors.textMuted),
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Annuler'),
            onPressed: () => Navigator.pop(ctx),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryTeal),
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
