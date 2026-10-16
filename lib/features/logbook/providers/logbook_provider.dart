import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../navigation/models/navigation_data.dart';
import '../models/log_entry.dart';

class LogbookProvider extends ChangeNotifier {
  static const String _storageKey = 'kipmarine_logbook_entries';

  List<LogEntry> _logs = [];
  LogEntry? _activeLog;

  List<LogEntry> get logs => List.unmodifiable(_logs);
  LogEntry? get activeLog => _activeLog;
  bool get isRecording => _activeLog != null;

  LogbookProvider() {
    _loadFromStorage();
  }

  /// Démarre un nouvel enregistrement de navigation
  void startTrack(String title) {
    if (isRecording) return;

    _activeLog = LogEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title.isEmpty ? 'Navigation ${DateTime.now().day}/${DateTime.now().month}' : title,
      startTime: DateTime.now(),
      points: [],
    );

    notifyListeners();
  }

  /// Enregistre un point GPS dans la trace active
  void addPoint(NavigationData data) {
    if (_activeLog == null) return;

    _activeLog!.points.add(TrackPoint(
      latitude: data.latitude,
      longitude: data.longitude,
      speedKnots: data.speedInKnots,
      heading: data.heading,
      timestamp: data.timestamp,
    ));

    notifyListeners();
  }

  /// Clôture la trace active et la sauvegarde
  Future<void> stopTrack() async {
    if (_activeLog == null) return;

    _activeLog!.endTime = DateTime.now();
    _logs.insert(0, _activeLog!);
    _activeLog = null;

    await _saveToStorage();
    notifyListeners();
  }

  /// Supprime un enregistrement
  Future<void> deleteLog(String id) async {
    _logs.removeWhere((log) => log.id == id);
    await _saveToStorage();
    notifyListeners();
  }

  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _logs.map((log) => log.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(jsonList));
  }

  Future<void> _loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    if (jsonString != null) {
      try {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        _logs = jsonList.map((j) => LogEntry.fromJson(j)).toList();
        notifyListeners();
      } catch (_) {}
    }
  }
}
