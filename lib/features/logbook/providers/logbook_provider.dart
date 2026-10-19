import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../navigation/models/navigation_data.dart';
import '../models/log_entry.dart';

class JournalNote {
  final String id;
  final String text;
  final DateTime timestamp;
  final double? latitude;
  final double? longitude;

  const JournalNote({
    required this.id,
    required this.text,
    required this.timestamp,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'timestamp': timestamp.toIso8601String(),
        'latitude': latitude,
        'longitude': longitude,
      };

  factory JournalNote.fromJson(Map<String, dynamic> json) => JournalNote(
        id: json['id'] as String,
        text: json['text'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
      );
}

class LogbookProvider extends ChangeNotifier {
  static const String _storageKey = 'kipmarine_logbook_entries';
  static const String _notesStorageKey = 'kipmarine_journal_notes';

  List<LogEntry> _logs = [];
  List<JournalNote> _notes = [];
  LogEntry? _activeLog;

  List<LogEntry> get logs => List.unmodifiable(_logs);
  List<JournalNote> get notes => List.unmodifiable(_notes);
  LogEntry? get activeLog => _activeLog;
  bool get isRecording => _activeLog != null;

  LogbookProvider() {
    _loadFromStorage();
    _loadNotesFromStorage();
  }

  void addJournalNote(String text, {NavigationData? position}) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    _notes.insert(
      0,
      JournalNote(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        text: trimmed,
        timestamp: DateTime.now(),
        latitude: position?.latitude,
        longitude: position?.longitude,
      ),
    );
    notifyListeners();
    _saveNotesToStorage();
  }

  Future<void> deleteJournalNote(String id) async {
    _notes.removeWhere((note) => note.id == id);
    await _saveNotesToStorage();
    notifyListeners();
  }

  void startTrack(String title) {
    if (isRecording) return;
    _activeLog = LogEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title.trim().isEmpty
          ? 'Navigation ${DateTime.now().day}/${DateTime.now().month}'
          : title.trim(),
      startTime: DateTime.now(),
      points: [],
    );
    notifyListeners();
  }

  void addPoint(NavigationData data) {
    if (_activeLog == null) return;
    final lastPoint = _activeLog!.points.isEmpty ? null : _activeLog!.points.last;
    // Évite de répéter plusieurs fois le même relevé GPS lors des reconstructions UI.
    if (lastPoint != null && lastPoint.timestamp == data.timestamp) return;

    _activeLog!.points.add(TrackPoint(
      latitude: data.latitude,
      longitude: data.longitude,
      speedKnots: data.speedInKnots,
      heading: data.heading,
      timestamp: data.timestamp,
    ));
    notifyListeners();
  }

  Future<void> stopTrack() async {
    if (_activeLog == null) return;
    _activeLog!.endTime = DateTime.now();
    _logs.insert(0, _activeLog!);
    _activeLog = null;
    await _saveToStorage();
    notifyListeners();
  }

  Future<void> deleteLog(String id) async {
    _logs.removeWhere((log) => log.id == id);
    await _saveToStorage();
    notifyListeners();
  }

  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode(_logs.map((log) => log.toJson()).toList()),
    );
  }

  Future<void> _saveNotesToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _notesStorageKey,
      jsonEncode(_notes.map((note) => note.toJson()).toList()),
    );
  }

  Future<void> _loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    if (jsonString == null) return;
    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      _logs = jsonList
          .map((item) => LogEntry.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
      notifyListeners();
    } catch (_) {
      // Les anciennes traces restent intactes si une entrée est illisible.
    }
  }

  Future<void> _loadNotesFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_notesStorageKey);
    if (jsonString == null) return;
    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      _notes = jsonList
          .map((item) => JournalNote.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
      notifyListeners();
    } catch (_) {
      // Ignore une liste de notes illisible sans toucher aux traces GPX.
    }
  }
}
