import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_colors.dart';
import 'core/theme/theme_controller.dart';
import 'features/navigation/providers/navigation_provider.dart';
import 'features/anchor_watch/providers/anchor_watch_provider.dart';
import 'features/logbook/providers/logbook_provider.dart';
import 'features/mob/providers/mob_provider.dart';
import 'features/home/screens/main_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeController()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => AnchorWatchProvider()),
        ChangeNotifierProvider(create: (_) => LogbookProvider()),
        ChangeNotifierProvider(create: (_) => MobProvider()),
      ],
      child: const KipMarineApp(),
    ),
  );
}

class KipMarineApp extends StatelessWidget {
  const KipMarineApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();
    return _AnchorWatchCoordinator(
      child: MaterialApp(
        title: 'KipMarine',
        debugShowCheckedModeBanner: false,
        theme: AppColors.lightTheme,
        darkTheme: AppColors.darkTheme,
        themeMode: themeController.themeMode,
        home: const MainScreen(),
      ),
    );
  }
}

/// Keeps anchor-watch calculations connected to GPS for the lifetime of the
/// app, rather than only while the anchor-watch screen is visible.
class _AnchorWatchCoordinator extends StatefulWidget {
  final Widget child;

  const _AnchorWatchCoordinator({required this.child});

  @override
  State<_AnchorWatchCoordinator> createState() =>
      _AnchorWatchCoordinatorState();
}

class _AnchorWatchCoordinatorState extends State<_AnchorWatchCoordinator> {
  NavigationProvider? _navigationProvider;
  DateTime? _lastProcessedTimestamp;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = context.read<NavigationProvider>();
    if (identical(provider, _navigationProvider)) return;

    _navigationProvider?.removeListener(_onNavigationChanged);
    _navigationProvider = provider;
    provider.addListener(_onNavigationChanged);
    _onNavigationChanged();
  }

  void _onNavigationChanged() {
    final data = _navigationProvider?.currentData;
    if (data == null || data.timestamp == _lastProcessedTimestamp) return;

    _lastProcessedTimestamp = data.timestamp;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AnchorWatchProvider>().updatePosition(data);
    });
  }

  @override
  void dispose() {
    _navigationProvider?.removeListener(_onNavigationChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
