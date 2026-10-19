import 'package:flutter/material.dart';

/// Offline decorative illustration for KipMarine's Mediterranean visual theme.
/// It is purely illustrative: it never displays or implies navigational data.
class MediterraneanSeaPainter extends CustomPainter {
  const MediterraneanSeaPainter();

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final bounds = Offset.zero & size;
    final w = size.width;
    final h = size.height;
    final horizon = h * .53;

    // Warm sky with a soft late-afternoon glow.
    canvas.drawRect(
      bounds,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF75C7E8),
            Color(0xFFB8DDED),
            Color(0xFFFFD3A6),
          ],
          stops: [0, .48, 1],
        ).createShader(bounds),
    );

    _drawCloud(canvas, Offset(w * .19, h * .19), w * .20, h * .065);
    _drawCloud(canvas, Offset(w * .47, h * .11), w * .16, h * .045);
    _drawCloud(canvas, Offset(w * .83, h * .28), w * .23, h * .055);

    // Sun halo, kept subtle so the overlaid GPS text stays legible.
    canvas.drawCircle(
      Offset(w * .78, h * .28),
      h * .15,
      Paint()..color = const Color(0xFFFFE9BF).withValues(alpha: .12),
    );
    canvas.drawCircle(
      Offset(w * .78, h * .28),
      h * .085,
      Paint()..color = const Color(0xFFFFE8B5).withValues(alpha: .76),
    );

    // Distant Corsican-style mountain silhouettes.
    final farMountains = Path()
      ..moveTo(0, horizon + h * .01)
      ..lineTo(w * .08, h * .43)
      ..lineTo(w * .16, h * .40)
      ..lineTo(w * .24, h * .45)
      ..lineTo(w * .37, h * .30)
      ..lineTo(w * .46, h * .39)
      ..lineTo(w * .58, h * .35)
      ..lineTo(w * .69, h * .22)
      ..lineTo(w * .80, h * .39)
      ..lineTo(w * .89, h * .31)
      ..lineTo(w, h * .40)
      ..lineTo(w, horizon + h * .06)
      ..close();
    canvas.drawPath(
      farMountains,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF6F8A94), Color(0xFF557C8A)],
        ).createShader(Rect.fromLTWH(0, h * .22, w, h * .40)),
    );

    // Sunlit coastal headland, in two overlapping planes for depth.
    final headland = Path()
      ..moveTo(0, h * .54)
      ..lineTo(w * .08, h * .50)
      ..lineTo(w * .17, h * .52)
      ..lineTo(w * .25, h * .47)
      ..lineTo(w * .34, h * .54)
      ..lineTo(w * .43, h * .49)
      ..lineTo(w * .51, h * .55)
      ..lineTo(w * .65, h * .50)
      ..lineTo(w * .76, h * .55)
      ..lineTo(w * .85, h * .47)
      ..lineTo(w, h * .52)
      ..lineTo(w, h * .62)
      ..lineTo(0, h * .62)
      ..close();
    canvas.drawPath(
      headland,
      Paint()..color = const Color(0xFF315D65).withValues(alpha: .94),
    );

    // The sea begins at an irregular, natural horizon.
    final sea = Path()
      ..moveTo(0, horizon)
      ..quadraticBezierTo(w * .22, h * .51, w * .43, h * .535)
      ..quadraticBezierTo(w * .72, h * .56, w, h * .525)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(
      sea,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF39B6CF),
            Color(0xFF087FA4),
            Color(0xFF03445F),
          ],
          stops: [0, .45, 1],
        ).createShader(Rect.fromLTWH(0, horizon, w, h - horizon)),
    );

    // Turquoise shallows and long, fine sunlit reflections.
    final shallows = Path()
      ..moveTo(0, h * .78)
      ..quadraticBezierTo(w * .25, h * .66, w * .49, h * .79)
      ..quadraticBezierTo(w * .76, h * .91, w, h * .72)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(
      shallows,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF21C4C8), Color(0xFF087B99)],
        ).createShader(Rect.fromLTWH(0, h * .65, w, h * .35)),
    );

    for (var i = 0; i < 12; i++) {
      final y = h * (.63 + i * .028);
      final startX = w * (.04 + (i % 4) * .11);
      final lineWidth = w * (.08 + (i % 3) * .035);
      final glint = Paint()
        ..color = Colors.white.withValues(alpha: i % 3 == 0 ? .32 : .18)
        ..strokeWidth = i % 3 == 0 ? 1.5 : .8
        ..strokeCap = StrokeCap.round;
      final wave = Path()
        ..moveTo(startX, y)
        ..quadraticBezierTo(startX + lineWidth * .48, y - h * .009,
            startX + lineWidth, y + h * .002);
      canvas.drawPath(wave, glint);
    }

    // Rocks in the near foreground frame the water without obscuring it.
    final rocks = Path()
      ..moveTo(w * .70, h)
      ..lineTo(w * .76, h * .91)
      ..lineTo(w * .81, h * .88)
      ..lineTo(w * .85, h * .92)
      ..lineTo(w * .90, h * .84)
      ..lineTo(w * .96, h * .89)
      ..lineTo(w, h * .86)
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(
      rocks,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFC39B78), Color(0xFF72594C)],
        ).createShader(Rect.fromLTWH(w * .70, h * .84, w * .30, h * .16)),
    );
    final rockEdge = Paint()
      ..color = const Color(0xFFFFD1A0).withValues(alpha: .68)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    final rockLine = Path()
      ..moveTo(w * .80, h * .94)
      ..lineTo(w * .84, h * .90)
      ..lineTo(w * .89, h * .94)
      ..moveTo(w * .92, h * .96)
      ..lineTo(w * .96, h * .92);
    canvas.drawPath(rockLine, rockEdge);

    _drawSailboat(canvas, Offset(w * .68, h * .66), h * .22);
    _drawSailboat(canvas, Offset(w * .35, h * .77), h * .14);
  }

  void _drawCloud(Canvas canvas, Offset center, double width, double height) {
    final cloudPaint = Paint()
      ..color = Colors.white.withValues(alpha: .34)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawOval(
      Rect.fromCenter(center: center, width: width, height: height),
      cloudPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx - width * .20, center.dy + height * .08),
        width: width * .40,
        height: height * .80,
      ),
      cloudPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx + width * .20, center.dy - height * .05),
        width: width * .48,
        height: height,
      ),
      cloudPaint,
    );
  }

  void _drawSailboat(Canvas canvas, Offset center, double height) {
    final mast = Paint()
      ..color = const Color(0xFF073042).withValues(alpha: .90)
      ..strokeWidth = 1.4;
    canvas.drawLine(
      Offset(center.dx, center.dy - height),
      Offset(center.dx, center.dy + height * .38),
      mast,
    );

    final sails = Paint()..color = const Color(0xFFFFFCF5);
    final mainsail = Path()
      ..moveTo(center.dx - height * .04, center.dy - height * .88)
      ..lineTo(center.dx - height * .49, center.dy + height * .23)
      ..lineTo(center.dx - height * .04, center.dy + height * .23)
      ..close();
    final jib = Path()
      ..moveTo(center.dx + height * .04, center.dy - height * .69)
      ..lineTo(center.dx + height * .39, center.dy + height * .23)
      ..lineTo(center.dx + height * .04, center.dy + height * .23)
      ..close();
    canvas.drawPath(mainsail, sails);
    canvas.drawPath(jib, Paint()..color = const Color(0xFFD9F5F3));

    final hull = Path()
      ..moveTo(center.dx - height * .54, center.dy + height * .31)
      ..quadraticBezierTo(
        center.dx,
        center.dy + height * .40,
        center.dx + height * .54,
        center.dy + height * .31,
      )
      ..lineTo(center.dx + height * .36, center.dy + height * .46)
      ..lineTo(center.dx - height * .36, center.dy + height * .46)
      ..close();
    canvas.drawPath(
      hull,
      Paint()..color = const Color(0xFF073042).withValues(alpha: .96),
    );

    final wake = Paint()
      ..color = Colors.white.withValues(alpha: .36)
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(center.dx - height * .72, center.dy + height * .48),
      Offset(center.dx - height * .44, center.dy + height * .48),
      wake,
    );
    canvas.drawLine(
      Offset(center.dx + height * .50, center.dy + height * .48),
      Offset(center.dx + height * .78, center.dy + height * .48),
      wake,
    );
  }

  @override
  bool shouldRepaint(covariant MediterraneanSeaPainter oldDelegate) => false;
}
