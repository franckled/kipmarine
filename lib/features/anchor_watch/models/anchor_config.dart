class AnchorConfig {
  final double anchorLatitude;
  final double anchorLongitude;
  final double radiusMeters; // Rayon d'évitement toléré (ex: 35 m)
  final bool isActive;
  final double currentDistance; // Distance actuelle à l'ancre en mètres
  final bool isAlarmTriggered;  // Vrai si le bateau est hors du cercle

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
}
