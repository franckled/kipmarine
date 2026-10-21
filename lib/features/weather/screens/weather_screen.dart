import 'package:flutter/material.dart';
import 'package:kipmarine/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../core/services/marine_forecast_service.dart';
import '../../navigation/providers/navigation_provider.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});
  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final MarineForecastService _service = MarineForecastService();
  final TextEditingController _placeController = TextEditingController();
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lonController = TextEditingController();
  Map<String, dynamic>? _weather, _marine;
  List<Map<String, dynamic>> _places = [];
  Object? _error;
  bool _loading = false, _searching = false, _manual = false, _gpsAutoLoaded = false;
  double? _latitude, _longitude;
  String _locationLabel = AppLocalizations.of(context).weatherLoadGps;

  @override
  void dispose() {
    _service.dispose(); _placeController.dispose(); _latController.dispose(); _lonController.dispose();
    super.dispose();
  }

  Future<void> _searchPlaces() async {
    final query = _placeController.text.trim();
    if (query.length < 2) return;
    setState(() { _searching = true; _error = null; });
    try {
      final places = await _service.searchPlaces(query);
      if (!mounted) return;
      setState(() { _places = places; _searching = false; });
      if (places.isEmpty) setState(() => _error = AppLocalizations.of(context).weatherNoResults);
    } catch (e) { if (mounted) setState(() { _error = e; _searching = false; }); }
  }

  Future<void> _load(
    double lat,
    double lon,
    String label, {
    bool resolveGpsPlace = false,
  }) async {
    if (lat < -90 || lat > 90 || lon < -180 || lon > 180) {
      setState(() => _error =
          AppLocalizations.of(context).weatherInvalidCoordinates);
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _weather = null;
      _marine = null;
      _latitude = lat;
      _longitude = lon;
      _locationLabel = resolveGpsPlace ? AppLocalizations.of(context).weatherGpsSearching : label;
      _places = [];
    });

    try {
      final values = await Future.wait<Object?>([
        _service.fetchWeather(latitude: lat, longitude: lon),
        _service.fetchMarine(latitude: lat, longitude: lon),
        resolveGpsPlace
            ? _service.reverseGeocodeCurrentGps(latitude: lat, longitude: lon)
            : Future<String?>.value(null),
      ]);
      if (!mounted) return;

      final resolvedLabel = resolveGpsPlace
          ? (values[2] as String? ?? AppLocalizations.of(context).weatherGpsUnavailable)
          : label;
      setState(() {
        _weather = values[0] as Map<String, dynamic>;
        _marine = values[1] as Map<String, dynamic>;
        _locationLabel = resolvedLabel;
        _loading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e;
          _loading = false;
          if (resolveGpsPlace) _locationLabel = AppLocalizations.of(context).weatherGpsNameUnavailable;
        });
      }
    }
  }

  String _value(Map<String, dynamic>? data, String group, String key, {String suffix = ''}) {
    final groupData = data?[group];
    final value = groupData is Map ? groupData[key] : null;
    return value is num ? value.toStringAsFixed(1) + suffix : '—';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final gps = context.watch<NavigationProvider>().currentData;
    if (gps != null && _latitude == null && !_gpsAutoLoaded) {
      _gpsAutoLoaded = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _latitude == null) _load(gps.latitude, gps.longitude, AppLocalizations.of(context).weatherLoadGps, resolveGpsPlace: true);
      });
    }
    return Scaffold(
      appBar: AppBar(title: Text(l10n.weatherScreenTitle, style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [IconButton(tooltip: l10n.weatherUseGps, onPressed: gps == null ? null : () => _load(gps.latitude, gps.longitude, AppLocalizations.of(context).weatherLoadGps, resolveGpsPlace: true), icon: const Icon(Icons.my_location_rounded))]),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(gradient: LinearGradient(colors: [colors.primary, Color.lerp(colors.primary, colors.surface, .35)!]), borderRadius: BorderRadius.circular(24)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.waves_rounded, color: Colors.white, size: 34), const SizedBox(height: 10),
            const Text(l10n.weatherWorld, style: TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.w900)),
            const SizedBox(height: 6), Text(_locationLabel, style: const TextStyle(color: Colors.white)),
            if (_latitude != null && _longitude != null) Text(_latitude!.toStringAsFixed(4) + '°, ' + _longitude!.toStringAsFixed(4) + '°', style: const TextStyle(color: Colors.white70)),
          ])),
        const SizedBox(height: 16),
        TextField(controller: _placeController, textInputAction: TextInputAction.search, onSubmitted: (_) => _searchPlaces(), decoration: InputDecoration(labelText: l10n.weatherSearchLabel, hintText: l10n.weatherSearchHint, prefixIcon: const Icon(Icons.search), suffixIcon: IconButton(onPressed: _searchPlaces, icon: const Icon(Icons.arrow_forward_rounded)), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)))),
        if (_searching) const LinearProgressIndicator(),
        if (_places.isNotEmpty) ...[const SizedBox(height: 8), ..._places.map((place) {
          final name = (place['name'] ?? l10n.weatherNoPlace).toString();
          final admin = [place['admin1'], place['country']].where((v) => v != null && v.toString().isNotEmpty).join(', ');
          final lat = (place['latitude'] as num?)?.toDouble(); final lon = (place['longitude'] as num?)?.toDouble();
          return ListTile(leading: const Icon(Icons.location_on_outlined), title: Text(name), subtitle: Text(admin), onTap: lat == null || lon == null ? null : () => _load(lat, lon, admin.isEmpty ? name : name + ', ' + admin));
        })],
        const SizedBox(height: 8),
        OutlinedButton.icon(onPressed: () => setState(() => _manual = !_manual), icon: const Icon(Icons.pin_drop_outlined), label: Text(_manual ? l10n.weatherHideCoordinates : l10n.weatherEnterCoordinates)) ,
        if (_manual) ...[
          const SizedBox(height: 8), Row(children: [Expanded(child: TextField(controller: _latController, keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true), decoration: const InputDecoration(labelText: l10n.weatherLatitude, hintText: '41.918')),), const SizedBox(width: 10), Expanded(child: TextField(controller: _lonController, keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true), decoration: const InputDecoration(labelText: l10n.weatherLongitude, hintText: '8.738')))]),
          const SizedBox(height: 8), FilledButton(onPressed: () { final lat = double.tryParse(_latController.text.trim().replaceAll(',', '.')); final lon = double.tryParse(_lonController.text.trim().replaceAll(',', '.')); if (lat == null || lon == null) { setState(() => _error = l10n.weatherInvalidInput); return; } _load(lat, lon, l10n.weatherSelectedCoordinates); }, child: const Text(l10n.weatherShowArea)),
        ],
        if (_latitude == null && gps != null) Padding(padding: const EdgeInsets.only(top: 8), child: OutlinedButton.icon(onPressed: () => _load(gps.latitude, gps.longitude, AppLocalizations.of(context).weatherLoadGps, resolveGpsPlace: true), icon: const Icon(Icons.my_location), label: const Text(l10n.weatherLoadGps))),
        const SizedBox(height: 12),
        if (_loading) const Padding(padding: EdgeInsets.all(28), child: Center(child: CircularProgressIndicator())),
        if (_error != null) _Notice(text: _error.toString(), isError: true),
        if (!_loading && _weather != null && _marine != null) ...[
          const SizedBox(height: 10), Text(l10n.weatherSection, style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)), const SizedBox(height: 10),
          GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.45, children: [
            _MetricCard(icon: Icons.thermostat, label: l10n.weatherTemperature, value: _value(_weather, 'current', 'temperature_2m', suffix: ' °C')),
            _MetricCard(icon: Icons.air, label: l10n.weatherWind, value: _value(_weather, 'current', 'wind_speed_10m', suffix: ' km/h')),
            _MetricCard(icon: Icons.speed, label: l10n.weatherGusts, value: _value(_weather, 'current', 'wind_gusts_10m', suffix: ' km/h')),
            _MetricCard(icon: Icons.water, label: l10n.weatherWaveHeight, value: _value(_marine, 'current', 'wave_height', suffix: ' m')),
            _MetricCard(icon: Icons.explore, label: l10n.weatherWaveDirection, value: _value(_marine, 'current', 'wave_direction', suffix: '°')),
            _MetricCard(icon: Icons.waves, label: l10n.weatherWavePeriod, value: _value(_marine, 'current', 'wave_period', suffix: ' s')),
            _MetricCard(icon: Icons.water_drop, label: l10n.weatherSeaTemperature, value: _value(_marine, 'current', 'sea_surface_temperature', suffix: ' °C')),
            _MetricCard(icon: Icons.cloud, label: l10n.weatherHumidity, value: _value(_weather, 'current', 'relative_humidity_2m', suffix: ' %')),
          ]), const SizedBox(height: 16),
          _Notice(text: l10n.weatherDisclaimer),
          const SizedBox(height: 6), Text(l10n.weatherAttribution, textAlign: TextAlign.center, style: TextStyle(fontSize: 11)),
        ],
      ]),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.icon, required this.label, required this.value});
  final IconData icon; final String label; final String value;
  @override Widget build(BuildContext context) { final colors = Theme.of(context).colorScheme; return Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: Theme.of(context).dividerColor)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Icon(icon, color: colors.primary, size: 22), Text(value, style: TextStyle(color: colors.onSurface, fontSize: 20, fontWeight: FontWeight.w900)), Text(label, style: TextStyle(color: colors.onSurfaceVariant, fontSize: 11))])); }
}
class _Notice extends StatelessWidget {
  const _Notice({required this.text, this.isError = false}); final String text; final bool isError;
  @override Widget build(BuildContext context) { final colors = Theme.of(context).colorScheme; return Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: (isError ? colors.errorContainer : colors.primaryContainer).withValues(alpha: .45), borderRadius: BorderRadius.circular(14)), child: Text(text, style: TextStyle(color: isError ? colors.onErrorContainer : colors.onSurface, height: 1.45))); }
}