import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('JOURNAL DE BORD', style: TextStyle(fontWeight: FontWeight.bold)),
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
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: logProvider.isRecording ? Colors.green : Theme.of(context).dividerColor,
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
                              color: logProvider.isRecording ? Colors.red : Theme.of(context).colorScheme.onSurfaceVariant,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              logProvider.isRecording ? 'ENREGISTREMENT ACTIF' : 'PRÊT À ENREGISTRER',
                              style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        if (logProvider.isRecording)
                          Text(
                            '${activeLog?.points.length ?? 0} pts',
                            style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (logProvider.isRecording) ...[
                      Text(
                        activeLog?.title ?? '',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Distance : ${activeLog?.totalDistanceNM.toStringAsFixed(2)} NM | Vit. Moy : ${activeLog?.averageSpeedKnots.toStringAsFixed(1)} kn',
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
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
                          style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary),
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

              Align(
                alignment: Alignment.centerLeft,
                child: Text('TRACES ENREGISTRÉES', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              const SizedBox(height: 10),

              Expanded(
                child: logProvider.logs.isEmpty
                    ? Center(
                        child: Text('Aucune trace enregistrée pour le moment.', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                      )
                    : ListView.builder(
                        itemCount: logProvider.logs.length,
                        itemBuilder: (context, index) {
                          final log = logProvider.logs[index];
                          return Card(
                            color: Theme.of(context).colorScheme.surface,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(color: Theme.of(context).dividerColor),
                            ),
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              title: Text(log.title, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)),
                              subtitle: Text(
                                '${log.totalDistanceNM.toStringAsFixed(2)} NM • ${log.points.length} points • ${log.startTime.day}/${log.startTime.month}/${log.startTime.year}',
                                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.share, color: Theme.of(context).colorScheme.primary),
                                    onPressed: () => GpxService.exportAndShare(log),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.red),
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
        backgroundColor: Theme.of(ctx).colorScheme.surface,
        title: const Text('Nouvelle navigation'),
        content: TextField(
          controller: controller,
          style: TextStyle(color: Theme.of(ctx).colorScheme.onSurface),
          decoration: const InputDecoration(
            labelText: 'Nom de la sortie',
            labelStyle: TextStyle(color: Theme.of(ctx).colorScheme.onSurfaceVariant),
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Annuler'),
            onPressed: () => Navigator.pop(ctx),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(ctx).colorScheme.primary),
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
