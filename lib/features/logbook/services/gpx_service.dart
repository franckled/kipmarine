import 'package:share_plus/share_plus.dart';
import '../models/log_entry.dart';

class GpxService {
  /// Génère le contenu XML standard d'un fichier GPX
  static String generateGpxXml(LogEntry log) {
    final buffer = StringBuffer();
    buffer.writeln('<?xml version="1.0" encoding="UTF-8"?>');
    buffer.writeln('<gpx version="1.1" creator="KipMarine" xmlns="http://www.topografix.com/GPX/1/1">');
    buffer.writeln('  <trk>');
    buffer.writeln('    <name>${_escapeXml(log.title)}</name>');
    buffer.writeln('    <trkseg>');

    for (final point in log.points) {
      buffer.writeln('      <trkpt lat="${point.latitude}" lon="${point.longitude}">');
      buffer.writeln('        <time>${point.timestamp.toUtc().toIso8601String()}</time>');
      buffer.writeln('        <speed>${point.speedKnots}</speed>');
      buffer.writeln('      </trkpt>');
    }

    buffer.writeln('    </trkseg>');
    buffer.writeln('  </trk>');
    buffer.writeln('</gpx>');

    return buffer.toString();
  }

  /// Exporte et partage le fichier GPX
  static Future<void> exportAndShare(LogEntry log) async {
    final gpxData = generateGpxXml(log);
    final fileName = '${log.title.replaceAll(RegExp(r'[^\w\s]+'), '_')}.gpx';

    final xFile = XFile.fromData(
      Uint8List.fromList(gpxData.codeUnits),
      mimeType: 'application/gpx+xml',
      name: fileName,
    );

    await Share.shareXFiles([xFile], text: 'Trace de navigation KipMarine : ${log.title}');
  }

  static String _escapeXml(String input) {
    return input
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;');
  }
}
