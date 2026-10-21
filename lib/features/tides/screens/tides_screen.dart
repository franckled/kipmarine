import 'package:flutter/material.dart';
import 'package:kipmarine/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../core/services/marine_forecast_service.dart';
import '../../navigation/providers/navigation_provider.dart';

class TidesScreen extends StatefulWidget { const TidesScreen({super.key}); @override State<TidesScreen> createState() => _TidesScreenState(); }
class _TidesScreenState extends State<TidesScreen> {
  final _service = MarineForecastService();
  final _search = TextEditingController();
  List<Map<String, dynamic>> _places = [];
  Map<String, dynamic>? _marine;
  Object? _error;
  bool _loading = false, _searching = false, _initialised = false, _gpsAutoLoaded = false;
  double? _lat, _lon;
  String _place = 'GPS';
  @override void dispose() { _service.dispose(); _search.dispose(); super.dispose(); }
  @override void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialised) { _initialised = true; final gps = context.read<NavigationProvider>().currentData; if (gps != null) { _lat = gps.latitude; _lon = gps.longitude; _load(gps.latitude, gps.longitude, AppLocalizations.of(context).tidesGpsPosition, resolveGpsPlace: true); } }
  }
  Future<void> _searchPlaces() async {
    if (_search.text.trim().length < 2) return;
    setState(() { _searching = true; _error = null; });
    try { final results = await _service.searchPlaces(_search.text.trim()); if (!mounted) return; setState(() { _places = results; _searching = false; }); if (results.isEmpty) setState(() => _error = AppLocalizations.of(context).tidesNoResults); }
    catch (e) { if (mounted) setState(() { _error = e; _searching = false; }); }
  }
  Future<void> _load(
    double lat,
    double lon,
    String label, {
    bool resolveGpsPlace = false,
  }) async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _loading = true;
      _error = null;
      _marine = null;
      _lat = lat;
      _lon = lon;
      _place = resolveGpsPlace ? l10n.tidesGpsSearching : label;
      _places = [];
    });
    try {
      final values = await Future.wait<Object?>([
        _service.fetchMarine(latitude: lat, longitude: lon),
        resolveGpsPlace
            ? _service.reverseGeocodeCurrentGps(latitude: lat, longitude: lon)
            : Future<String?>.value(null),
      ]);
      if (!mounted) return;
      final resolvedLabel = resolveGpsPlace
          ? (values[1] as String? ?? l10n.tidesGpsUnavailable)
          : label;
      setState(() {
        _marine = values[0] as Map<String, dynamic>;
        _place = resolvedLabel;
        _loading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e;
          _loading = false;
          if (resolveGpsPlace) _place = l10n.tidesGpsNameUnavailable;
        });
      }
    }
  }
  List<_SeaPoint> _seaPoints() {
    final hourly = _marine?['hourly']; if (hourly is! Map) return [];
    final times = hourly['time']; final levels = hourly['sea_level_height_msl'];
    if (times is! List || levels is! List) return [];
    final result = <_SeaPoint>[];
    for (var i = 0; i < times.length && i < levels.length; i++) {
      final level = levels[i]; final time = DateTime.tryParse(times[i].toString());
      if (level is num && time != null) result.add(_SeaPoint(time, level.toDouble()));
    }
    return result;
  }
  List<_SeaPoint> _turningPoints(List<_SeaPoint> points) {
    final result = <_SeaPoint>[];
    for (var i = 1; i < points.length - 1; i++) {
      final before = points[i - 1].level, current = points[i].level, after = points[i + 1].level;
      if ((current >= before && current > after) || (current <= before && current < after)) result.add(points[i]);
    }
    return result;
  }
  String _time(DateTime value) => value.toLocal().hour.toString().padLeft(2, '0') + ':' + value.toLocal().minute.toString().padLeft(2, '0');
  @override Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    String translated(String key) => switch (key) { 'tidesChooseArea' => l10n.tidesChooseArea, 'tidesSearchLabel' => l10n.tidesSearchLabel, 'tidesSearchHint' => l10n.tidesSearchHint, 'tidesNoPlace' => l10n.tidesNoPlace, 'tidesNoResults' => l10n.tidesNoResults, 'tidesGpsPosition' => l10n.tidesGpsPosition, 'tidesGpsSearching' => l10n.tidesGpsSearching, 'tidesGpsUnavailable' => l10n.tidesGpsUnavailable, 'tidesGpsNameUnavailable' => l10n.tidesGpsNameUnavailable, 'tidesUseGps' => l10n.tidesUseGps, 'tidesModelledLevel' => l10n.tidesModelledLevel, 'tidesChoosePlacePrompt' => l10n.tidesChoosePlacePrompt, 'tidesNoSeries' => l10n.tidesNoSeries, 'tidesModelLevelLegend' => l10n.tidesModelLevelLegend, 'tidesModelLocalMax' => l10n.tidesModelLocalMax, 'tidesModelLocalMin' => l10n.tidesModelLocalMin, 'tidesExtremaTitle' => l10n.tidesExtremaTitle, 'tidesLocalMax' => l10n.tidesLocalMax, 'tidesLocalMin' => l10n.tidesLocalMin, 'tidesImportantLimit' => l10n.tidesImportantLimit, 'tidesAttribution' => l10n.tidesAttribution, _ => key };
    final theme = Theme.of(context); final colors = theme.colorScheme;
    final gps = context.watch<NavigationProvider>().currentData;
    if (gps != null && _lat == null && !_gpsAutoLoaded) {
      _gpsAutoLoaded = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _lat == null) _load(gps.latitude, gps.longitude, l10n.tidesGpsPosition, resolveGpsPlace: true);
      });
    }
    final points = _seaPoints(); final extrema = _turningPoints(points);
    return Scaffold(appBar: AppBar(title: Text(l10n.tidesScreenTitle, style: TextStyle(fontWeight: FontWeight.bold)), actions: [IconButton(tooltip: l10n.tidesUseGps, onPressed: gps == null ? null : () => _load(gps.latitude, gps.longitude, l10n.tidesGpsPosition, resolveGpsPlace: true), icon: const Icon(Icons.my_location_rounded))]),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Text(l10n.tidesChooseArea, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colors.onSurfaceVariant, letterSpacing: 1)), const SizedBox(height: 10),
        TextField(controller: _search, textInputAction: TextInputAction.search, onSubmitted: (_) => _searchPlaces(), decoration: InputDecoration(labelText: l10n.tidesSearchLabel, hintText: l10n.tidesSearchHint, prefixIcon: const Icon(Icons.search), suffixIcon: IconButton(onPressed: _searchPlaces, icon: const Icon(Icons.arrow_forward_rounded)), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)))),
        if (_searching) const LinearProgressIndicator(),
        if (_places.isNotEmpty) ..._places.map((p) { final name = (p['name'] ?? l10n.tidesNoPlace).toString(); final admin = [p['admin1'], p['country']].where((v) => v != null && v.toString().isNotEmpty).join(', '); final lat = (p['latitude'] as num?)?.toDouble(); final lon = (p['longitude'] as num?)?.toDouble(); return ListTile(leading: const Icon(Icons.location_on_outlined), title: Text(name), subtitle: Text(admin), onTap: lat == null || lon == null ? null : () => _load(lat, lon, admin.isEmpty ? name : name + ', ' + admin)); }),
        if (gps != null) Align(alignment: Alignment.centerLeft, child: TextButton.icon(onPressed: () => _load(gps.latitude, gps.longitude, l10n.tidesGpsPosition, resolveGpsPlace: true), icon: const Icon(Icons.my_location), label: const Text(l10n.tidesUseGps))),
        const SizedBox(height: 10),
        Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: theme.dividerColor)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Icon(Icons.waves_rounded, color: colors.primary, size: 28), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(l10n.tidesModelledLevel, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)), Text(_place, style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12)), if (_lat != null && _lon != null) Text('${_lat!.toStringAsFixed(4)}°, ${_lon!.toStringAsFixed(4)}°', style: TextStyle(color: colors.onSurfaceVariant, fontSize: 11))]))]),
          const SizedBox(height: 18),
          if (_loading) const Center(child: Padding(padding: EdgeInsets.all(28), child: CircularProgressIndicator()))
          else if (_error != null) Text(l10n.tidesError(_error.toString()), style: TextStyle(color: colors.error))
          else if (points.length < 3) Text(_lat == null ? l10n.tidesChoosePlacePrompt : l10n.tidesNoSeries, style: TextStyle(color: colors.onSurfaceVariant))
          else ...[
            SizedBox(height: 230, width: double.infinity, child: CustomPaint(painter: _SeaLevelPainter(points: points, extrema: extrema, lineColor: colors.primary, gridColor: theme.dividerColor, textColor: colors.onSurfaceVariant))),
            const SizedBox(height: 10),
            Wrap(spacing: 12, runSpacing: 8, children: [
              _Legend(color: colors.primary, text: l10n.tidesModelLevelLegend),
              _Legend(color: colors.tertiary, text: l10n.tidesModelLocalMax),
              _Legend(color: colors.secondary, text: l10n.tidesModelLocalMin),
            ]),
            const SizedBox(height: 12),
            Text(l10n.tidesExtremaTitle, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            ...extrema.take(8).map((p) { final isHigh = _isMaximum(points, p); return ListTile(dense: true, contentPadding: EdgeInsets.zero, leading: Icon(isHigh ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded, color: isHigh ? colors.tertiary : colors.secondary), title: Text((isHigh ? l10n.tidesLocalMax : l10n.tidesLocalMin) + ' · ' + _time(p.time)), trailing: Text(p.level.toStringAsFixed(2) + ' m')); }),
          ],
        ])),
        const SizedBox(height: 16),
        Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: colors.errorContainer.withValues(alpha: .45), borderRadius: BorderRadius.circular(14)), child: Text(l10n.tidesImportantLimit, style: TextStyle(color: colors.onErrorContainer, height: 1.45, fontSize: 12))),
        const SizedBox(height: 8), const Text(l10n.tidesAttribution, textAlign: TextAlign.center, style: TextStyle(fontSize: 11)),
      ]));
  }
  bool _isMaximum(List<_SeaPoint> points, _SeaPoint point) { final i = points.indexOf(point); return i > 0 && i < points.length - 1 && points[i].level >= points[i - 1].level && points[i].level > points[i + 1].level; }
}
class _SeaPoint { const _SeaPoint(this.time, this.level); final DateTime time; final double level; }
class _Legend extends StatelessWidget { const _Legend({required this.color, required this.text}); final Color color; final String text; @override Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [Container(width: 9, height: 9, decoration: BoxDecoration(color: color, shape: BoxShape.circle)), const SizedBox(width: 5), Text(text, style: const TextStyle(fontSize: 10))]); }
class _SeaLevelPainter extends CustomPainter {
  const _SeaLevelPainter({required this.points, required this.extrema, required this.lineColor, required this.gridColor, required this.textColor});
  final List<_SeaPoint> points, extrema; final Color lineColor, gridColor, textColor;
  @override void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    const left = 36.0, right = 10.0, top = 16.0, bottom = 28.0;
    final plot = Rect.fromLTRB(left, top, size.width - right, size.height - bottom);
    final minY = points.map((p) => p.level).reduce((a,b) => a < b ? a : b); final maxY = points.map((p) => p.level).reduce((a,b) => a > b ? a : b); final range = (maxY - minY).abs() < .01 ? 1.0 : maxY - minY;
    double x(int i) => plot.left + plot.width * i / (points.length - 1); double y(double v) => plot.bottom - (v - minY) / range * plot.height;
    final grid = Paint()..color = gridColor..strokeWidth = 1; final line = Paint()..color = lineColor..strokeWidth = 2.5..style = PaintingStyle.stroke..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round;
    final fill = Paint()..color = lineColor.withValues(alpha: .10)..style = PaintingStyle.fill;
    for (var i = 0; i < 4; i++) { final gy = plot.top + plot.height * i / 3; canvas.drawLine(Offset(plot.left, gy), Offset(plot.right, gy), grid); final value = (maxY - range * i / 3).toStringAsFixed(2); _drawText(canvas, value, Offset(0, gy - 6), textColor, 9); }
    final path = Path()..moveTo(x(0), y(points[0].level)); for (var i = 1; i < points.length; i++) path.lineTo(x(i), y(points[i].level));
    final area = Path.from(path)..lineTo(x(points.length - 1), plot.bottom)..lineTo(x(0), plot.bottom)..close(); canvas.drawPath(area, fill); canvas.drawPath(path, line);
    for (final p in extrema.take(6)) { final i = points.indexOf(p); if (i < 0) continue; final high = i > 0 && i < points.length - 1 && p.level >= points[i-1].level && p.level > points[i+1].level; final c = Paint()..color = high ? Colors.deepOrange : Colors.teal; canvas.drawCircle(Offset(x(i), y(p.level)), 4, c); _drawText(canvas, (high ? 'Max ' : 'Min ') + p.time.hour.toString().padLeft(2,'0') + ':' + p.time.minute.toString().padLeft(2,'0'), Offset((x(i)-22).clamp(plot.left, plot.right-48).toDouble(), (y(p.level)-18).clamp(0, size.height-12).toDouble()), textColor, 9); }
    _drawText(canvas, points.first.time.day.toString() + '/' + points.first.time.month.toString(), Offset(plot.left, plot.bottom + 8), textColor, 9); _drawText(canvas, points.last.time.day.toString() + '/' + points.last.time.month.toString(), Offset(plot.right - 35, plot.bottom + 8), textColor, 9);
  }
  void _drawText(Canvas canvas, String text, Offset offset, Color color, double size) { final p = TextPainter(text: TextSpan(text: text, style: TextStyle(color: color, fontSize: size)), textDirection: TextDirection.ltr)..layout(); p.paint(canvas, offset); }
  @override bool shouldRepaint(covariant _SeaLevelPainter old) => old.points != points || old.extrema != extrema || old.lineColor != lineColor || old.gridColor != gridColor;
}