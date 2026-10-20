import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:kipmarine/core/services/marine_forecast_service.dart';

void main() {
  group('MarineForecastService.reverseGeocodeCurrentGps', () {
    test('returns a readable locality, region and country', () async {
      final service = MarineForecastService(
        client: MockClient((request) async {
          expect(request.url.host, 'api.bigdatacloud.net');
          expect(request.url.path, '/data/reverse-geocode-client');
          expect(request.url.queryParameters['localityLanguage'], 'fr');
          return http.Response(
            jsonEncode({
              'locality': 'Saint-Florent',
              'city': 'Saint-Florent',
              'principalSubdivision': 'Corse',
              'countryName': 'France',
            }),
            200,
          );
        }),
      );

      expect(
        await service.reverseGeocodeCurrentGps(
          latitude: 42.681,
          longitude: 9.303,
        ),
        'À proximité de Saint-Florent, Corse, France',
      );
      service.dispose();
    });

    test('returns null when no named place can be resolved', () async {
      final service = MarineForecastService(
        client: MockClient(
          (_) async => http.Response(jsonEncode({'countryName': ''}), 200),
        ),
      );

      expect(
        await service.reverseGeocodeCurrentGps(
          latitude: 0,
          longitude: 0,
        ),
        isNull,
      );
      service.dispose();
    });

    test('does not fail the screen when the place lookup is unavailable',
        () async {
      final service = MarineForecastService(
        client: MockClient((_) async => http.Response('unavailable', 503)),
      );

      expect(
        await service.reverseGeocodeCurrentGps(
          latitude: 42.681,
          longitude: 9.303,
        ),
        isNull,
      );
      service.dispose();
    });
  });
}
