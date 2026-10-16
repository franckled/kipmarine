import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_colors.dart';
import 'features/navigation/providers/navigation_provider.dart';
import 'features/anchor_watch/providers/anchor_watch_provider.dart';
import 'features/home/screens/main_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => AnchorWatchProvider()),
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
        scaffoldBackgroundColor: AppColors.backgroundDark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
        ),
      ),
      home: const MainScreen(),
    );
  }
}
