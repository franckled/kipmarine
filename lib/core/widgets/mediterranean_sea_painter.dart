import 'package:flutter/material.dart';

/// A lightweight, offline illustration used across KipMarine.
/// It deliberately contains no labels or navigation data.
class MediterraneanSeaPainter extends CustomPainter {
  const MediterraneanSeaPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final sky = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF70C7E5), Color(0xFFFFD3A0), Color(0xFF0B789B)],
        stops: [0, .53, .54],
      ).createShader(rect);
    canvas.drawRect(rect, sky);

    final sun = Paint()..color = const Color(0xFFFFE7B1).withValues(alpha: .88);
    canvas.drawCircle(Offset(size.width * .78, size.height * .22), size.height * .095, sun);

    final distant = Path()
      ..moveTo(0, size.height * .53)
      ..lineTo(size.width * .12, size.height * .43)
      ..lineTo(size.width * .23, size.height * .48)
      ..lineTo(size.width * .38, size.height * .32)
      ..lineTo(size.width * .49, size.height * .45)
      ..lineTo(size.width * .64, size.height * .27)
      ..lineTo(size.width * .77, size.height * .44)
      ..lineTo(size.width * .91, size.height * .34)
      ..lineTo(size.width, size.height * .42)
      ..lineTo(size.width, size.height * .62)
      ..lineTo(0, size.height * .62)
      ..close();
    canvas.drawPath(distant, Paint()..color = const Color(0xFF446B7A));

    final coast = Path()
      ..moveTo(0, size.height * .57)
      ..lineTo(size.width * .12, size.height * .51)
      ..lineTo(size.width * .22, size.height * .57)
      ..lineTo(size.width * .33, size.height * .47)
      ..lineTo(size.width * .43, size.height * .58)
      ..lineTo(size.width * .57, size.height * .49)
      ..lineTo(size.width * .70, size.height * .60)
      ..lineTo(size.width * .83, size.height * .48)
      ..lineTo(size.width, size.height * .55)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(coast, Paint()..color = const Color(0xFF087E9A));

    final shallows = Path()
      ..moveTo(0, size.height * .76)
      ..quadraticBezierTo(size.width * .28, size.height * .66, size.width * .52, size.height * .78)
      ..quadraticBezierTo(size.width * .78, size.height * .91, size.width, size.height * .73)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(shallows, Paint()..color = const Color(0xFF18B9C3).withValues(alpha: .72));

    final glint = Paint()
      ..color = Colors.white.withValues(alpha: .36)
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 9; i++) {
      final y = size.height * (.68 + i * .032);
      canvas.drawLine(Offset(size.width * (.08 + (i % 3) * .12), y),
          Offset(size.width * (.22 + (i % 3) * .12), y), glint);
      canvas.drawLine(Offset(size.width * (.68 + (i % 2) * .08), y + 3),
          Offset(size.width * (.81 + (i % 2) * .08), y + 3), glint);
    }

    _drawSailboat(canvas, Offset(size.width * .69, size.height * .67), size.height * .25);
    _drawSailboat(canvas, Offset(size.width * .37, size.height * .78), size.height * .15);
  }

  void _drawSailboat(Canvas canvas, Offset center, double height) {
    final mast = Paint()..color = const Color(0xFF073042)..strokeWidth = 1.7;
    canvas.drawLine(Offset(center.dx, center.dy - height), Offset(center.dx, center.dy + height * .38), mast);
    final sail = Paint()..color = const Color(0xFFF7FBF9);
    final left = Path()
      ..moveTo(center.dx - height * .05, center.dy - height * .87)
      ..lineTo(center.dx - height * .52, center.dy + height * .25)
      ..lineTo(center.dx - height * .05, center.dy + height * .25)
      ..close();
    final right = Path()
      ..moveTo(center.dx + height * .04, center.dy - height * .68)
      ..lineTo(center.dx + height * .43, center.dy + height * .25)
      ..lineTo(center.dx + height * .04, center.dy + height * .25)
      ..close();
    canvas.drawPath(left, sail);
    canvas.drawPath(right, Paint()..color = const Color(0xFFD9F4F5));
    final hull = Path()
      ..moveTo(center.dx - height * .56, center.dy + height * .34)
      ..lineTo(center.dx + height * .56, center.dy + height * .34)
      ..lineTo(center.dx + height * .35, center.dy + height * .48)
      ..lineTo(center.dx - height * .38, center.dy + height * .48)
      ..close();
    canvas.drawPath(hull, Paint()..color = const Color(0xFF073042));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
