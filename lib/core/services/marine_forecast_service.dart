import 'dart:convert';

import 'package:http/http.dart' as http;

/// Client for Open-Meteo's public weather and marine forecast endpoints.
/// Free public endpoints are intended for non-commercial use; review terms
/// before distributing a commercial version of KipMarine.
class MarineForecastService {
  MarineForecastService({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

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
      throw Exception('Service météo indisponible (\${response.statusCode}).');
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Réponse météo invalide.');
    }
    return decoded;
  }

  void dispose() => _client.close();
}
