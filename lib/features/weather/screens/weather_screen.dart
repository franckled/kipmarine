import 'package:flutter/material.dart';
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
  bool _loading = false, _searching = false, _manual = false;
  double? _latitude, _longitude;
  String _locationLabel = 'Position GPS';

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
      if (places.isEmpty) setState(() => _error = 'Aucun lieu trouvé. Essaie un nom de ville ou de port plus précis.');
    } catch (e) { if (mounted) setState(() { _error = e; _searching = false; }); }
  }

  Future<void> _load(double lat, double lon, String label) async {
    if (lat < -90 || lat > 90 || lon < -180 || lon > 180) {
      setState(() => _error = 'Coordonnées invalides : latitude −90 à 90°, longitude −180 à 180°.'); return;
    }
    setState(() { _loading = true; _error = null; _latitude = lat; _longitude = lon; _locationLabel = label; _places = []; });
    try {
      final values = await Future.wait([
        _service.fetchWeather(latitude: lat, longitude: lon),
        _service.fetchMarine(latitude: lat, longitude: lon),
      ]);
      if (!mounted) return;
      setState(() { _weather = values[0]; _marine = values[1]; _loading = false; });
    } catch (e) { if (mounted) setState(() { _error = e; _loading = false; }); }
  }

  String _value(Map<String, dynamic>? data, String group, String key, {String suffix = ''}) {
    final groupData = data?[group];
    final value = groupData is Map ? groupData[key] : null;
    return value is num ? value.toStringAsFixed(1) + suffix : '—';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final gps = context.watch<NavigationProvider>().currentData;
    return Scaffold(
      appBar: AppBar(title: const Text('Météo marine', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [IconButton(tooltip: 'Utiliser ma position GPS', onPressed: gps == null ? null : () => _load(gps.latitude, gps.longitude, 'Position GPS'), icon: const Icon(Icons.my_location_rounded))]),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(gradient: LinearGradient(colors: [colors.primary, Color.lerp(colors.primary, colors.surface, .35)!]), borderRadius: BorderRadius.circular(24)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.waves_rounded, color: Colors.white, size: 34), const SizedBox(height: 10),
            const Text('Météo partout dans le monde', style: TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.w900)),
            const SizedBox(height: 6), Text(_locationLabel, style: const TextStyle(color: Colors.white)),
            if (_latitude != null && _longitude != null) Text(_latitude!.toStringAsFixed(4) + '°, ' + _longitude!.toStringAsFixed(4) + '°', style: const TextStyle(color: Colors.white70)),
          ])),
        const SizedBox(height: 16),
        TextField(controller: _placeController, textInputAction: TextInputAction.search, onSubmitted: (_) => _searchPlaces(), decoration: InputDecoration(labelText: 'Ville, port ou lieu', hintText: 'Ex. Ajaccio, Lisbonne, Sydney', prefixIcon: const Icon(Icons.search), suffixIcon: IconButton(onPressed: _searchPlaces, icon: const Icon(Icons.arrow_forward_rounded)), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)))),
        if (_searching) const LinearProgressIndicator(),
        if (_places.isNotEmpty) ...[const SizedBox(height: 8), ..._places.map((place) {
          final name = (place['name'] ?? 'Lieu').toString();
          final admin = [place['admin1'], place['country']].where((v) => v != null && v.toString().isNotEmpty).join(', ');
          final lat = (place['latitude'] as num?)?.toDouble(); final lon = (place['longitude'] as num?)?.toDouble();
          return ListTile(leading: const Icon(Icons.location_on_outlined), title: Text(name), subtitle: Text(admin), onTap: lat == null || lon == null ? null : () => _load(lat, lon, admin.isEmpty ? name : name + ', ' + admin));
        })],
        const SizedBox(height: 8),
        OutlinedButton.icon(onPressed: () => setState(() => _manual = !_manual), icon: const Icon(Icons.pin_drop_outlined), label: Text(_manual ? 'Masquer les coordonnées' : 'Saisir des coordonnées GPS')) ,
        if (_manual) ...[
          const SizedBox(height: 8), Row(children: [Expanded(child: TextField(controller: _latController, keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true), decoration: const InputDecoration(labelText: 'Latitude', hintText: '41.918')),), const SizedBox(width: 10), Expanded(child: TextField(controller: _lonController, keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true), decoration: const InputDecoration(labelText: 'Longitude', hintText: '8.738')))]),
          const SizedBox(height: 8), FilledButton(onPressed: () { final lat = double.tryParse(_latController.text.trim().replaceAll(',', '.')); final lon = double.tryParse(_lonController.text.trim().replaceAll(',', '.')); if (lat == null || lon == null) { setState(() => _error = 'Saisis une latitude et une longitude valides.'); return; } _load(lat, lon, 'Coordonnées choisies'); }, child: const Text('Afficher cette zone')),
        ],
        if (_latitude == null && gps != null) Padding(padding: const EdgeInsets.only(top: 8), child: OutlinedButton.icon(onPressed: () => _load(gps.latitude, gps.longitude, 'Position GPS'), icon: const Icon(Icons.my_location), label: const Text('Charger ma position actuelle'))),
        const SizedBox(height: 12),
        if (_loading) const Padding(padding: EdgeInsets.all(28), child: Center(child: CircularProgressIndicator())),
        if (_error != null) _Notice(text: _error.toString(), isError: true),
        if (!_loading && _weather != null && _marine != null) ...[
          const SizedBox(height: 10), Text('MÉTÉO', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)), const SizedBox(height: 10),
          GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.45, children: [
            _MetricCard(icon: Icons.thermostat, label: 'Température', value: _value(_weather, 'current', 'temperature_2m', suffix: ' °C')),
            _MetricCard(icon: Icons.air, label: 'Vent', value: _value(_weather, 'current', 'wind_speed_10m', suffix: ' km/h')),
            _MetricCard(icon: Icons.speed, label: 'Rafales', value: _value(_weather, 'current', 'wind_gusts_10m', suffix: ' km/h')),
            _MetricCard(icon: Icons.water, label: 'Hauteur des vagues', value: _value(_marine, 'current', 'wave_height', suffix: ' m')),
            _MetricCard(icon: Icons.explore, label: 'Direction des vagues', value: _value(_marine, 'current', 'wave_direction', suffix: '°')),
            _MetricCard(icon: Icons.waves, label: 'Période des vagues', value: _value(_marine, 'current', 'wave_period', suffix: ' s')),
            _MetricCard(icon: Icons.water_drop, label: 'Température de mer', value: _value(_marine, 'current', 'sea_surface_temperature', suffix: ' °C')),
            _MetricCard(icon: Icons.cloud, label: 'Humidité', value: _value(_weather, 'current', 'relative_humidity_2m', suffix: ' %')),
          ]), const SizedBox(height: 16),
          const _Notice(text: 'Données Open-Meteo : les prévisions sont issues de modèles et peuvent être imprécises près des côtes. Elles ne remplacent pas les bulletins officiels ni les instruments de bord.'),
          const SizedBox(height: 6), const Text('Données météo : Open-Meteo · open-meteo.com', textAlign: TextAlign.center, style: TextStyle(fontSize: 11)),
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