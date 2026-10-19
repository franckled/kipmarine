class AnchorConfig {
  final double anchorLatitude;
  final double anchorLongitude;
  final double radiusMeters;
  final bool isActive;
  final double currentDistance;
  final bool isAlarmTriggered;

  AnchorConfig({
    required this.anchorLatitude,
    required this.anchorLongitude,
    required this.radiusMeters,
    this.isActive = false,
    this.currentDistance = 0.0,
    this.isAlarmTriggered = false,
  });

  AnchorConfig copyWith({
    double? anchorLatitude,
    double? anchorLongitude,
    double? radiusMeters,
    bool? isActive,
    double? currentDistance,
    bool? isAlarmTriggered,
  }) {
    return AnchorConfig(
      anchorLatitude: anchorLatitude ?? this.anchorLatitude,
      anchorLongitude: anchorLongitude ?? this.anchorLongitude,
      radiusMeters: radiusMeters ?? this.radiusMeters,
      isActive: isActive ?? this.isActive,
      currentDistance: currentDistance ?? this.currentDistance,
      isAlarmTriggered: isAlarmTriggered ?? this.isAlarmTriggered,
    );
  }

  Map<String, dynamic> toJson() => {
        'anchorLatitude': anchorLatitude,
        'anchorLongitude': anchorLongitude,
        'radiusMeters': radiusMeters,
        'isActive': isActive,
        'currentDistance': currentDistance,
        'isAlarmTriggered': isAlarmTriggered,
      };

  factory AnchorConfig.fromJson(Map<String, dynamic> json) => AnchorConfig(
        anchorLatitude: (json['anchorLatitude'] as num).toDouble(),
        anchorLongitude: (json['anchorLongitude'] as num).toDouble(),
        radiusMeters: (json['radiusMeters'] as num).toDouble(),
        isActive: json['isActive'] as bool? ?? false,
        currentDistance: (json['currentDistance'] as num?)?.toDouble() ?? 0,
        isAlarmTriggered: json['isAlarmTriggered'] as bool? ?? false,
      );
}
