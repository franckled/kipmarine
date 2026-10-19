import '../../../core/constants/marine_units.dart';

class TrackPoint {
  final double latitude;
  final double longitude;
  final double speedKnots;
  final double heading;
  final DateTime timestamp;

  TrackPoint({
    required this.latitude,
    required this.longitude,
    required this.speedKnots,
    required this.heading,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'lat': latitude,
        'lon': longitude,
        'speed': speedKnots,
        'heading': heading,
        'time': timestamp.toIso8601String(),
      };

  factory TrackPoint.fromJson(Map<String, dynamic> json) => TrackPoint(
        latitude: json['lat'],
        longitude: json['lon'],
        speedKnots: json['speed'],
        heading: json['heading'],
        timestamp: DateTime.parse(json['time']),
      );
}

class LogEntry {
  final String id;
  final String title;
  final DateTime startTime;
  DateTime? endTime;
  final List<TrackPoint> points;
  String note;

  LogEntry({
    required this.id,
    required this.title,
    required this.startTime,
    this.endTime,
    required this.points,
    this.note = '',
  });

  /// Calcule la distance totale parcourue en Milles Nautiques (NM)
  double get totalDistanceNM {
    if (points.length < 2) return 0.0;
    double meters = 0.0;
    for (int i = 0; i < points.length - 1; i++) {
      meters += MarineUnits.haversineDistance(
        points[i].latitude,
        points[i].longitude,
        points[i + 1].latitude,
        points[i + 1].longitude,
      );
    }
    return MarineUnits.metersToNauticalMiles(meters);
  }

  /// Calcule la vitesse moyenne en Nœuds
  double get averageSpeedKnots {
    if (points.isEmpty) return 0.0;
    final totalSpeed = points.fold(0.0, (sum, p) => sum + p.speedKnots);
    return totalSpeed / points.length;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime?.toIso8601String(),
        'points': points.map((p) => p.toJson()).toList(),
        'note': note,
      };

  factory LogEntry.fromJson(Map<String, dynamic> json) => LogEntry(
        id: json['id'],
        title: json['title'],
        startTime: DateTime.parse(json['startTime']),
        endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
        points: (json['points'] as List).map((p) => TrackPoint.fromJson(p)).toList(),
        note: json['note'] ?? '',
      );
}
