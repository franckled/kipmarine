import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../navigation/providers/navigation_provider.dart';

class CompassScreen extends StatefulWidget {
  const CompassScreen({super.key});

  @override
  State<CompassScreen> createState() => _CompassScreenState();
}

class _CompassScreenState extends State<CompassScreen> {
  bool _isCrasMode = true;

  String _getCardinal(double heading) {
    const points = ['N', 'NNE', 'NE', 'ENE', 'E', 'ESE', 'SE', 'SSE', 'S', 'SSW', 'SW', 'WSW', 'W', 'WNW', 'NW', 'NNW'];
    return points[((heading % 360 + 11.25) % 360 / 22.5).floor()];
  }

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavigationProvider>();
    final gpsData = nav.currentData;
    final cog = gpsData != null && gpsData.hasValidCourse ? gpsData.heading : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Rose des vents', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: const [Padding(padding: EdgeInsets.only(right: 16), child: Icon(Icons.explore_outlined, color: AppColors.primaryTeal, size: 26))],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                height: 48,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: AppColors.iconBgCyan.withOpacity(0.5), borderRadius: BorderRadius.circular(14)),
                child: Row(children: [
                  _modeButton('Rose (Cras)', true),
                  _modeButton('Boussole', false),
                ]),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppColors.surfaceWhite, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.cardBorder)),
                  child: _isCrasMode
                      ? _buildRose(cog)
                      : StreamBuilder<CompassEvent>(
                          stream: FlutterCompass.events,
                          builder: (context, snapshot) {
                            final magneticHeading = snapshot.data?.heading;
                            return _buildRose(magneticHeading);
                          },
                        ),
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppColors.surfaceWhite, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.cardBorder)),
                child: Text(
                  _isCrasMode
                      ? 'Rose Cras : le Nord reste en haut et le trait indique le COG GPS. Le COG nécessite un déplacement suffisant ; à l’arrêt, aucune valeur n’est inventée.'
                      : 'Boussole magnétique : la rose tourne selon le cap mesuré par le capteur magnétique du téléphone. Les interférences métalliques ou électroniques peuvent fausser la mesure.',
                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted, height: 1.4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _modeButton(String label, bool cras) => Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _isCrasMode = cras),
          child: Container(
            decoration: BoxDecoration(
              color: _isCrasMode == cras ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              boxShadow: _isCrasMode == cras ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)] : [],
            ),
            alignment: Alignment.center,
            child: Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: _isCrasMode == cras ? AppColors.textDark : AppColors.textMuted)),
          ),
        ),
      );

  Widget _buildRose(double? heading) {
    final hasHeading = heading != null && heading.isFinite && heading >= 0 && heading < 360;
    final shownHeading = hasHeading ? heading : null;
    final title = _isCrasMode ? 'COG · CAP SUR LE FOND' : 'CAP MAGNÉTIQUE';
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(title, style: const TextStyle(fontSize: 11, letterSpacing: 1, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
        const SizedBox(height: 12),
        Expanded(
          child: Center(
            child: AspectRatio(
              aspectRatio: 1,
              child: CustomPaint(
                painter: _CompassPainter(heading: shownHeading, isCrasMode: _isCrasMode),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(shownHeading == null ? '---°' : '${shownHeading.round()}°', style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: AppColors.textDark)),
        Text(
          shownHeading == null
              ? (_isCrasMode ? 'Déplacez-vous pour obtenir un COG GPS' : 'Capteur magnétique indisponible')
              : '${_getCardinal(shownHeading)} · ${_isCrasMode ? 'COG GPS' : 'cap magnétique'}',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _CompassPainter extends CustomPainter {
  final double? heading;
  final bool isCrasMode;
  const _CompassPainter({required this.heading, required this.isCrasMode});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;
    final validHeading = heading != null && heading!.isFinite && heading! >= 0 && heading! < 360;

    canvas.save();
    if (!isCrasMode && validHeading) {
      canvas.translate(center.dx, center.dy);
      canvas.rotate(-heading! * pi / 180);
      canvas.translate(-center.dx, -center.dy);
    }

    canvas.drawCircle(center, radius - 2, Paint()..color = const Color(0xFFEAF6F8));
    canvas.drawCircle(center, radius - 2, Paint()..color = const Color(0xFFB2DDE2)..style = PaintingStyle.stroke..strokeWidth = 1.5);

    for (var degree = 0; degree < 360; degree += 5) {
      final major = degree % 30 == 0;
      final medium = degree % 10 == 0;
      final inner = radius - (major ? 25 : medium ? 17 : 10);
      final outer = radius - 5;
      final angle = (degree - 90) * pi / 180;
      final start = Offset(center.dx + inner * cos(angle), center.dy + inner * sin(angle));
      final end = Offset(center.dx + outer * cos(angle), center.dy + outer * sin(angle));
      final tickPaint = Paint()
        ..color = major ? AppColors.textDark : const Color(0xFF6C9BA2)
        ..strokeWidth = major ? 2.0 : 1.0;
      canvas.drawLine(start, end, tickPaint);
      if (major) {
        final label = switch (degree) { 0 => 'N', 90 => 'E', 180 => 'S', 270 => 'W', _ => '$degree' };
        final tp = TextPainter(text: TextSpan(text: label, style: TextStyle(fontSize: degree % 90 == 0 ? 13 : 9, fontWeight: FontWeight.bold, color: AppColors.textDark)), textDirection: TextDirection.ltr)..layout();
        final labelRadius = radius - 43;
        tp.paint(canvas, Offset(center.dx + labelRadius * cos(angle) - tp.width / 2, center.dy + labelRadius * sin(angle) - tp.height / 2));
      }
    }

    if (isCrasMode && validHeading) {
      final angle = (heading! - 90) * pi / 180;
      final end = Offset(center.dx + (radius - 34) * cos(angle), center.dy + (radius - 34) * sin(angle));
      canvas.drawLine(center, end, Paint()..color = AppColors.mobOrange..strokeWidth = 3.5..strokeCap = StrokeCap.round);
    }
    canvas.drawCircle(center, 5, Paint()..color = AppColors.textDark);
    canvas.restore();

    // Index fixe en haut de la boussole, utilisé en mode magnétique.
    if (!isCrasMode) {
      final path = Path()..moveTo(center.dx, center.dy - radius + 2)..lineTo(center.dx - 7, center.dy - radius + 16)..lineTo(center.dx + 7, center.dy - radius + 16)..close();
      canvas.drawPath(path, Paint()..color = AppColors.mobOrange);
    }
  }

  @override
  bool shouldRepaint(covariant _CompassPainter oldDelegate) => oldDelegate.heading != heading || oldDelegate.isCrasMode != isCrasMode;
}
