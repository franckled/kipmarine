import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../navigation/models/navigation_data.dart';
import '../models/log_entry.dart';
import '../models/journal_note.dart';

class LogbookProvider extends ChangeNotifier {
  static const String _storageKey = 'kipmarine_logbook_entries';
  static const String _journalNotesStorageKey = 'kipmarine_journal_notes';

  List<LogEntry> _logs = [];
  LogEntry? _activeLog;
  List<JournalNote> _journalNotes = [];
  bool _notesLoaded = false;

  List<LogEntry> get logs => List.unmodifiable(_logs);
  LogEntry? get activeLog => _activeLog;
  bool get isRecording => _activeLog != null;
  List<JournalNote> get journalNotes => List.unmodifiable(_journalNotes);
  bool get areNotesLoaded => _notesLoaded;

  LogbookProvider() {
    _loadFromStorage();
    _loadJournalNotes();
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
    if (_activeLog == null) {
      return;
    }
    if (_activeLog!.points.isNotEmpty &&
        _activeLog!.points.last.timestamp.isAtSameMomentAs(data.timestamp)) {
      return;
    }

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


  /// Ajoute une note narrative avec l'heure de saisie et la dernière position GPS connue.
  Future<void> addJournalNote({
    required String text,
    required DateTime createdAt,
    double? latitude,
    double? longitude,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    _journalNotes.insert(0, JournalNote(
      id: '${createdAt.microsecondsSinceEpoch}',
      text: trimmed,
      createdAt: createdAt,
      latitude: latitude,
      longitude: longitude,
    ));
    await _saveJournalNotes();
    notifyListeners();
  }

  Future<void> deleteJournalNote(String id) async {
    _journalNotes.removeWhere((note) => note.id == id);
    await _saveJournalNotes();
    notifyListeners();
  }

  Future<void> _saveJournalNotes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_journalNotesStorageKey,
        jsonEncode(_journalNotes.map((note) => note.toJson()).toList()));
  }

  Future<void> _loadJournalNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_journalNotesStorageKey);
    if (jsonString != null) {
      try {
        final decoded = jsonDecode(jsonString) as List<dynamic>;
        _journalNotes = decoded
            .map((item) => JournalNote.fromJson(item as Map<String, dynamic>))
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      } catch (_) {
        _journalNotes = [];
      }
    }
    _notesLoaded = true;
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
