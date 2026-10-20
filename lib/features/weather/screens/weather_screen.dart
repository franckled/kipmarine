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
  Map<String, dynamic>? _weather;
  Map<String, dynamic>? _marine;
  Object? _error;
  bool _loading = false;
  String? _lastCoordinates;

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  Future<void> _load(double lat, double lon) async {
    final key = '\${lat.toStringAsFixed(3)},\${lon.toStringAsFixed(3)}';
    if (_loading || (_lastCoordinates == key && _weather != null && _marine != null)) return;
    setState(() {
      _loading = true;
      _error = null;
      _lastCoordinates = key;
    });
    try {
      final values = await Future.wait([
        _service.fetchWeather(latitude: lat, longitude: lon),
        _service.fetchMarine(latitude: lat, longitude: lon),
      ]);
      if (!mounted) return;
      setState(() {
        _weather = values[0];
        _marine = values[1];
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error;
        _loading = false;
      });
    }
  }

  String _value(Map<String, dynamic>? data, String group, String key, {String suffix = ''}) {
    final value = data?[group] is Map ? data![group][key] : null;
    if (value is num) return '\${value.toStringAsFixed(1)}$suffix';
    return '—';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final position = context.watch<NavigationProvider>().currentData;
    if (position != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _load(position.latitude, position.longitude);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Météo marine', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            tooltip: 'Actualiser',
            onPressed: position == null ? null : () {
              _lastCoordinates = null;
              _load(position.latitude, position.longitude);
            },
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colors.primary, Color.lerp(colors.primary, colors.surface, 0.35)!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.waves_rounded, color: Colors.white, size: 34),
                const SizedBox(height: 12),
                const Text('Conditions locales', style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w900)),
                const SizedBox(height: 6),
                Text(
                  position == null
                      ? 'En attente de la position GPS'
                      : '\${position.latitude.toStringAsFixed(4)}°, \${position.longitude.toStringAsFixed(4)}°',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ]),
            ),
            const SizedBox(height: 16),
            if (position == null)
              const _Notice(text: 'Active la localisation pour obtenir les conditions de la zone où tu te trouves. La sélection manuelle d’un lieu sera ajoutée dans une prochaine étape.')
            else if (_loading)
              const Padding(padding: EdgeInsets.all(28), child: Center(child: CircularProgressIndicator()))
            else if (_error != null)
              _Notice(text: 'Impossible de récupérer les prévisions : \$_error', isError: true)
            else if (_weather == null || _marine == null)
              const _Notice(text: 'Les prévisions ne sont pas encore chargées.')
            else ...[
              Text('MÉTÉO', style: TextStyle(color: colors.primary, fontWeight: FontWeight.w900, letterSpacing: 1)),
              const SizedBox(height: 10),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.45,
                children: [
                  _MetricCard(icon: Icons.thermostat, label: 'Température', value: _value(_weather, 'current', 'temperature_2m', suffix: ' °C')),
                  _MetricCard(icon: Icons.air, label: 'Vent', value: _value(_weather, 'current', 'wind_speed_10m', suffix: ' km/h')),
                  _MetricCard(icon: Icons.speed, label: 'Rafales', value: _value(_weather, 'current', 'wind_gusts_10m', suffix: ' km/h')),
                  _MetricCard(icon: Icons.water, label: 'Hauteur des vagues', value: _value(_marine, 'current', 'wave_height', suffix: ' m')),
                  _MetricCard(icon: Icons.explore, label: 'Direction des vagues', value: _value(_marine, 'current', 'wave_direction', suffix: '°')),
                  _MetricCard(icon: Icons.waves, label: 'Période des vagues', value: _value(_marine, 'current', 'wave_period', suffix: ' s')),
                  _MetricCard(icon: Icons.water_drop, label: 'Température de mer', value: _value(_marine, 'current', 'sea_surface_temperature', suffix: ' °C')),
                  _MetricCard(icon: Icons.cloud, label: 'Humidité', value: _value(_weather, 'current', 'relative_humidity_2m', suffix: ' %')),
                ],
              ),
              const SizedBox(height: 16),
              const _Notice(text: 'Données Open-Meteo. Les prévisions sont des modèles et peuvent être imprécises près des côtes. Elles ne remplacent pas les bulletins officiels ni les instruments de bord.'),
              const SizedBox(height: 6),
              const Text('Météo par Open-Meteo · open-meteo.com', textAlign: TextAlign.center, style: TextStyle(fontSize: 11)),
            ],
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Icon(icon, color: colors.primary, size: 22),
        Text(value, style: TextStyle(color: colors.onSurface, fontSize: 20, fontWeight: FontWeight.w900)),
        Text(label, style: TextStyle(color: colors.onSurfaceVariant, fontSize: 11)),
      ]),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.text, this.isError = false});
  final String text;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: (isError ? colors.errorContainer : colors.primaryContainer).withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(text, style: TextStyle(color: isError ? colors.onErrorContainer : colors.onSurface, height: 1.45)),
    );
  }
}
