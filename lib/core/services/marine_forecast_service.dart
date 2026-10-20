import 'dart:convert';

import 'package:http/http.dart' as http;

/// Client for Open-Meteo's public weather and marine forecast endpoints.
/// Free public endpoints are intended for non-commercial use; review terms
/// before distributing a commercial version of KipMarine.
class MarineForecastService {
  MarineForecastService({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<Map<String, dynamic>>> searchPlaces(String query) async {
    final uri = Uri.https('geocoding-api.open-meteo.com', '/v1/search', {
      'name': query,
      'count': '8',
      'language': 'fr',
      'format': 'json',
    });
    final response = await _client.get(uri).timeout(const Duration(seconds: 20));
    if (response.statusCode != 200) {
      throw Exception('Recherche de lieu indisponible (${response.statusCode}).');
    }
    final decoded = jsonDecode(response.body);
    final results = decoded is Map<String, dynamic> ? decoded['results'] : null;
    if (results is! List) return [];
    return results.whereType<Map<String, dynamic>>().toList();
  }

  /// Resolves the name of the device's current GPS location.
  ///
  /// BigDataCloud's free client-side endpoint is used only for live GPS
  /// coordinates already supplied by the device, not arbitrary/manual points.
  /// If the lookup is unavailable (for example, while offshore), callers can
  /// keep showing the coordinates without blocking the forecast.
  Future<String?> reverseGeocodeCurrentGps({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final uri = Uri.https(
        'api.bigdatacloud.net',
        '/data/reverse-geocode-client',
        {
          'latitude': '$latitude',
          'longitude': '$longitude',
          'localityLanguage': 'fr',
        },
      );
      final response =
          await _client.get(uri).timeout(const Duration(seconds: 12));
      if (response.statusCode != 200) return null;

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) return null;

      String? textField(String key) {
        final value = decoded[key];
        if (value is! String) return null;
        final cleaned = value.trim();
        return cleaned.isEmpty ? null : cleaned;
      }

      final locality = textField('locality');
      final city = textField('city');
      final subdivision = textField('principalSubdivision');
      final country = textField('countryName');

      final place = locality ?? city;
      final parts = <String>[];
      if (place != null) parts.add(place);
      if (city != null &&
          !parts.any((part) => part.toLowerCase() == city.toLowerCase())) {
        parts.add(city);
      }
      if (subdivision != null &&
          !parts.any(
            (part) => part.toLowerCase() == subdivision.toLowerCase(),
          )) {
        parts.add(subdivision);
      }
      if (country != null &&
          !parts.any((part) => part.toLowerCase() == country.toLowerCase())) {
        parts.add(country);
      }
      if (parts.isEmpty) return null;

      if (place != null) return 'À proximité de ${parts.join(', ')}';
      return 'Zone GPS · ${parts.join(', ')}';
    } catch (_) {
      // Place-name lookup is best effort and must never block marine data.
      return null;
    }
  }

  Future<Map<String, dynamic>> fetchWeather({
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
      'latitude': '$latitude',
      'longitude': '$longitude',
      'current': 'temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,weather_code,wind_speed_10m,wind_direction_10m,wind_gusts_10m',
      'hourly': 'temperature_2m,precipitation_probability,wind_speed_10m,wind_direction_10m,wind_gusts_10m',
      'forecast_days': '3',
      'timezone': 'auto',
    });
    return _getJson(uri);
  }

  Future<Map<String, dynamic>> fetchMarine({
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.https('marine-api.open-meteo.com', '/v1/marine', {
      'latitude': '$latitude',
      'longitude': '$longitude',
      'current': 'wave_height,wave_direction,wave_period,wind_wave_height,swell_wave_height,sea_surface_temperature',
      'hourly': 'wave_height,wave_direction,wave_period,swell_wave_height,sea_level_height_msl',
      'forecast_days': '7',
      'timezone': 'auto',
      'length_unit': 'metric',
    });
    return _getJson(uri);
  }

  Future<Map<String, dynamic>> _getJson(Uri uri) async {
    final response = await _client.get(uri).timeout(const Duration(seconds: 20));
    if (response.statusCode != 200) {
      throw Exception('Service météo indisponible (${response.statusCode}).');
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Réponse météo invalide.');
    }
    return decoded;
  }

  void dispose() => _client.close();
}
