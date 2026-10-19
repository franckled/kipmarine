import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_colors.dart';
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
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProxyProvider<NavigationProvider, AnchorWatchProvider>(
          create: (_) => AnchorWatchProvider(),
          update: (_, navigation, anchorWatch) {
            final provider = anchorWatch ?? AnchorWatchProvider();
            provider.bindNavigationProvider(navigation);
            return provider;
          },
        ),
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
    return MaterialApp(
      title: 'KipMarine',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryTeal,
          brightness: Brightness.light,
        ),
      ),
      home: const MainScreen(),
    );
  }
}
