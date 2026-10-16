import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_colors.dart';
import 'features/navigation/providers/navigation_provider.dart';
import 'features/navigation/screens/navigation_dashboard_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
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
      home: const NavigationDashboardScreen(),
    );
  }
}
