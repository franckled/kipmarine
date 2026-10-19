import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/constants/app_colors.dart';

class TidesScreen extends StatefulWidget {
  const TidesScreen({super.key});

  @override
  State<TidesScreen> createState() => _TidesScreenState();
}

class _TidesScreenState extends State<TidesScreen> {
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  String? _locationMessage;
  bool _isGettingPosition = false;

  @override
  void dispose() {
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<void> _useCurrentPosition() async {
    setState(() {
      _isGettingPosition = true;
      _locationMessage = null;
    });
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception('Autorisation de localisation refusée.');
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      if (!mounted) return;
      setState(() {
        _latitudeController.text = position.latitude.toStringAsFixed(5);
        _longitudeController.text = position.longitude.toStringAsFixed(5);
        _locationMessage = 'Coordonnées GPS obtenues. Vérifiez-les avant consultation.';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _locationMessage = 'Position GPS indisponible : $error';
      });
    } finally {
      if (mounted) setState(() => _isGettingPosition = false);
    }
  }

  bool get _hasValidCoordinates {
    final latitude = double.tryParse(_latitudeController.text.trim());
    final longitude = double.tryParse(_longitudeController.text.trim());
    return latitude != null &&
        longitude != null &&
        latitude.isFinite &&
        longitude.isFinite &&
        latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180;
  }

  Future<void> _openOfficialTides() async {
    final uri = Uri.parse('https://maree.shom.fr/');
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible d’ouvrir le site officiel du SHOM.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Marées & courants', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: const [Padding(padding: EdgeInsets.only(right: 16), child: Icon(Icons.waves, color: AppColors.primaryTeal, size: 24))],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'POSITION DU SECTEUR',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textMuted, letterSpacing: 0.6),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _latitudeController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                    decoration: const InputDecoration(
                      labelText: 'Latitude',
                      hintText: '42.6810',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _longitudeController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                    decoration: const InputDecoration(
                      labelText: 'Longitude',
                      hintText: '9.3000',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: _isGettingPosition ? null : _useCurrentPosition,
              icon: _isGettingPosition
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.my_location),
              label: Text(_isGettingPosition ? 'Localisation…' : 'Utiliser ma position GPS'),
            ),
            if (_locationMessage != null) ...[
              const SizedBox(height: 8),
              Text(_locationMessage!, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
            ],
            if (_latitudeController.text.isNotEmpty || _longitudeController.text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  _hasValidCoordinates
                      ? 'Coordonnées saisies valides'
                      : 'Coordonnées invalides : latitude −90 à 90, longitude −180 à 180.',
                  style: TextStyle(
                    color: _hasValidCoordinates ? AppColors.primaryTeal : Colors.redAccent,
                    fontSize: 12,
                  ),
                ),
              ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: AppColors.surfaceWhite, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.cardBorder)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Row(children: [Icon(Icons.info_outline, color: AppColors.primaryTeal), SizedBox(width: 8), Expanded(child: Text('Prédictions officielles', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)))]),
                const SizedBox(height: 12),
                Text(
                  _hasValidCoordinates
                      ? 'Secteur : ${_latitudeController.text}, ${_longitudeController.text}'
                      : 'Aucune position sélectionnée',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Aucune hauteur ni heure de marée fictive n’est affichée. Les coordonnées peuvent désigner un secteur partout dans le monde, mais cet écran ne calcule pas encore les marées. Pour les zones couvertes par le service officiel français, ouvrez le SHOM et vérifiez le lieu directement sur son site.',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13, height: 1.45),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryTeal, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
                    onPressed: _hasValidCoordinates ? _openOfficialTides : null,
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Consulter le SHOM', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.iconBgCyan, borderRadius: BorderRadius.circular(14)),
              child: const Text(
                'Important : la saisie de coordonnées ne garantit pas que le SHOM fournisse des prédictions pour ce secteur. Les prévisions intégrées nécessitent une source autorisée et une validation locale. Ne vous fiez pas à une estimation non vérifiée pour la sécurité de la navigation.',
                style: TextStyle(color: AppColors.textDark, fontSize: 12, height: 1.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
