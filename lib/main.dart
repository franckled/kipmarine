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
    return MaterialApp(
      title: 'KipMarine',
      debugShowCheckedModeBanner: false,
      theme: AppColors.lightTheme,
      darkTheme: AppColors.darkTheme,
      themeMode: themeController.themeMode,
      home: const MainScreen(),
    );
  }
}
