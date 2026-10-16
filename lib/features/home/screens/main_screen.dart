import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../navigation/screens/navigation_dashboard_screen.dart';
import '../../anchor_watch/screens/anchor_watch_screen.dart';
import '../../map/screens/marine_map_screen.dart';
import '../../logbook/screens/logbook_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    NavigationDashboardScreen(),
    AnchorWatchScreen(),
    MarineMapScreen(),
    LogbookScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: AppColors.primaryDark,
          indicatorColor: AppColors.primary,
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(
                color: AppColors.accent,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              );
            }
            return const TextStyle(
              color: Colors.white60,
              fontSize: 12,
            );
          }),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.speed_outlined, color: Colors.white60),
              selectedIcon: Icon(Icons.speed, color: AppColors.accent),
              label: 'Navigation',
            ),
            NavigationDestination(
              icon: Icon(Icons.anchor_outlined, color: Colors.white60),
              selectedIcon: Icon(Icons.anchor, color: AppColors.accent),
              label: 'Mouillage',
            ),
            NavigationDestination(
              icon: Icon(Icons.map_outlined, color: Colors.white60),
              selectedIcon: Icon(Icons.map, color: AppColors.accent),
              label: 'Carte',
            ),
            NavigationDestination(
              icon: Icon(Icons.book_outlined, color: Colors.white60),
              selectedIcon: Icon(Icons.book, color: AppColors.accent),
              label: 'Journal',
            ),
          ],
        ),
      ),
    );
  }
}
