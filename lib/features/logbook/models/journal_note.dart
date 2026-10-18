class JournalNote {
  final String id;
  final String text;
  final DateTime createdAt;
  final double? latitude;
  final double? longitude;

  const JournalNote({
    required this.id,
    required this.text,
    required this.createdAt,
    this.latitude,
    this.longitude,
  });

  bool get hasPosition => latitude != null && longitude != null;

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'createdAt': createdAt.toIso8601String(),
        'latitude': latitude,
        'longitude': longitude,
      };

  factory JournalNote.fromJson(Map<String, dynamic> json) => JournalNote(
        id: json['id'] as String,
        text: json['text'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
      );
}
