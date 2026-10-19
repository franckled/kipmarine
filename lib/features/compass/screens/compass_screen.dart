import 'dart:async';
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
    const directions = [
      'N', 'NNE', 'NE', 'ENE', 'E', 'ESE', 'SE', 'SSE',
      'S', 'SSW', 'SW', 'WSW', 'W', 'WNW', 'NW', 'NNW',
    ];
    final normalized = (heading % 360 + 360) % 360;
    return directions[((normalized + 11.25) / 22.5).floor() % 16];
  }

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavigationProvider>();
    final gpsData = nav.currentData;

    final double? cog =
        gpsData != null && gpsData.hasValidCourse ? gpsData.heading : null;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Rose des vents',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Icon(
              Icons.explore_outlined,
              color: Theme.of(context).colorScheme.primary,
              size: 26,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                height: 48,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    _modeButton('Rose (Cras)', true),
                    _modeButton('Boussole', false),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                  child: _isCrasMode
                      ? _buildCompass(
                          heading: cog,
                          isCrasMode: true,
                        )
                      : StreamBuilder<CompassEvent>(
                          stream: FlutterCompass.events,
                          builder: (context, snapshot) {
                            final magneticHeading =
                                snapshot.data?.heading;
                            final validHeading =
                                magneticHeading != null &&
                                magneticHeading.isFinite &&
                                magneticHeading >= 0 &&
                                magneticHeading < 360;

                            return _buildCompass(
                              heading:
                                  validHeading ? magneticHeading : null,
                              isCrasMode: false,
                            );
                          },
                        ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(context).dividerColor,
                  ),
                ),
                child: Text(
                  _isCrasMode
                      ? 'Rose CRAS : le Nord reste en haut. '
                          'L’indicateur montre le COG GPS lorsque le bateau '
                          'se déplace suffisamment. Le COG peut être '
                          'indisponible à l’arrêt.'
                      : 'Boussole magnétique : la rose pivote selon le '
                          'cap magnétique mesuré par le téléphone. '
                          'Éloignez le téléphone des sources magnétiques.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Création Franck LE DUFF — 2026\n'
                'Version ${_appVersionLabel()}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _modeButton(String label, bool cras) {
    final selected = _isCrasMode == cras;
    final theme = Theme.of(context);

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _isCrasMode = cras),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected
                ? theme.colorScheme.surface
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 4,
                    ),
                  ]
                : [],
          ),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: selected
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompass({
    required double? heading,
    required bool isCrasMode,
  }) {
    final theme = Theme.of(context);
    final validHeading = heading != null &&
        heading.isFinite &&
        heading >= 0 &&
        heading < 360;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Center(
            child: AspectRatio(
              aspectRatio: 1,
              child: CustomPaint(
                painter: _CompassPainter(
                  heading: validHeading ? heading : null,
                  isCrasMode: isCrasMode,
                  theme: theme,
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          validHeading ? '${heading.round()}°' : '---°',
          style: TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.w900,
            color: theme.colorScheme.onSurface,
          ),
        ),
        Text(
          validHeading
              ? '${_getCardinal(heading)} · '
                  '${isCrasMode ? 'COG GPS' : 'cap magnétique'}'
              : isCrasMode
                  ? 'COG GPS indisponible'
                  : 'Cap magnétique indisponible',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _appVersionLabel() => 'à confirmer';
}

class _CompassPainter extends CustomPainter {
  final double? heading;
  final bool isCrasMode;
  final ThemeData theme;

  _CompassPainter({
    required this.heading,
    required this.isCrasMode,
    required this.theme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;
    final valid = heading != null &&
        heading!.isFinite &&
        heading! >= 0 &&
        heading! < 360;

    final facePaint = Paint()
      ..color = theme.colorScheme.surfaceContainerHighest
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, facePaint);

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = theme.dividerColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    canvas.save();
    if (!isCrasMode && valid) {
      canvas.rotate(-heading! * pi / 180);
    }

    for (int degree = 0; degree < 360; degree += 5) {
      final angle = (degree - 90) * pi / 180;
      final major = degree % 30 == 0;
      final medium = degree % 10 == 0;
      final innerRadius =
          radius - (major ? 22 : medium ? 15 : 9);

      final start = Offset(
        center.dx + innerRadius * cos(angle),
        center.dy + innerRadius * sin(angle),
      );
      final end = Offset(
        center.dx + (radius - 5) * cos(angle),
        center.dy + (radius - 5) * sin(angle),
      );

      canvas.drawLine(
        start,
        end,
        Paint()
          ..color = theme.colorScheme.onSurface
              .withOpacity(major ? 0.9 : 0.4)
          ..strokeWidth = major ? 2 : 1,
      );

      if (major) {
        final label = degree == 0
            ? 'N'
            : degree == 90
                ? 'E'
                : degree == 180
                    ? 'S'
                    : degree == 270
                        ? 'W'
                        : '$degree';

        final textPainter = TextPainter(
          text: TextSpan(
            text: label,
            style: TextStyle(
              color: degree == 0
                  ? Colors.red
                  : theme.colorScheme.onSurface,
              fontSize: degree % 90 == 0 ? 13 : 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        final textRadius = radius - 39;
        textPainter.paint(
          canvas,
          Offset(
            center.dx + textRadius * cos(angle) -
                textPainter.width / 2,
            center.dy + textRadius * sin(angle) -
                textPainter.height / 2,
          ),
        );
      }
    }

    canvas.restore();

    // Triangle Nord fixe dans les deux modes.
    final north = Path()
      ..moveTo(center.dx, center.dy - radius + 2)
      ..lineTo(center.dx - 8, center.dy - radius + 16)
      ..lineTo(center.dx + 8, center.dy - radius + 16)
      ..close();

    canvas.drawPath(
      north,
      Paint()..color = Colors.red,
    );

    // En mode CRAS, l'indicateur pointe vers le COG GPS.
    // En mode boussole, le repère fixe en haut indique le Nord.
    if (isCrasMode && valid) {
      final angle = (heading! - 90) * pi / 180;
      final length = radius - 29;
      final tip = Offset(
        center.dx + length * cos(angle),
        center.dy + length * sin(angle),
      );

      canvas.drawLine(
        center,
        tip,
        Paint()
          ..color = theme.colorScheme.primary
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round,
      );

      final arrow = Path()
        ..moveTo(tip.dx, tip.dy)
        ..lineTo(
          tip.dx - 10 * cos(angle - 0.45),
          tip.dy - 10 * sin(angle - 0.45),
        )
        ..lineTo(
          tip.dx - 10 * cos(angle + 0.45),
          tip.dy - 10 * sin(angle + 0.45),
        )
        ..close();

      canvas.drawPath(
        arrow,
        Paint()..color = theme.colorScheme.primary,
      );
    }

    canvas.drawCircle(
      center,
      6,
      Paint()..color = theme.colorScheme.onSurface,
    );
  }

  @override
  bool shouldRepaint(covariant _CompassPainter oldDelegate) =>
      oldDelegate.heading != heading ||
      oldDelegate.isCrasMode != isCrasMode ||
      oldDelegate.theme.colorScheme != theme.colorScheme;
}
