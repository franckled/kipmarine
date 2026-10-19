import 'dart:convert';
import '../../../core/constants/marine_units.dart';

class TrackPoint {
  final double latitude;
  final double longitude;
  final double speedKnots;

  /// Cap GPS sur le fond, null si indisponible.
  final double? heading;

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
        latitude: (json['lat'] as num).toDouble(),
        longitude: (json['lon'] as num).toDouble(),
        speedKnots: (json['speed'] as num).toDouble(),
        heading: json['heading'] == null
            ? null
            : (json['heading'] as num).toDouble(),
        timestamp: DateTime.parse(json['time'] as String),
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

  /// Distance totale parcourue en milles nautiques.
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

  /// Vitesse moyenne en nœuds.
  double get averageSpeedKnots {
    if (points.isEmpty) return 0.0;

    final totalSpeed =
        points.fold<double>(0.0, (sum, point) => sum + point.speedKnots);

    return totalSpeed / points.length;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime?.toIso8601String(),
        'points': points.map((point) => point.toJson()).toList(),
        'note': note,
      };

  factory LogEntry.fromJson(Map<String, dynamic> json) => LogEntry(
        id: json['id'] as String,
        title: json['title'] as String,
        startTime: DateTime.parse(json['startTime'] as String),
        endTime: json['endTime'] != null
            ? DateTime.parse(json['endTime'] as String)
            : null,
        points: (json['points'] as List)
            .map((point) =>
                TrackPoint.fromJson(Map<String, dynamic>.from(point as Map)))
            .toList(),
        note: json['note'] as String? ?? '',
      );
}
