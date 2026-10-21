import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kipmarine/l10n/generated/app_localizations.dart';
import '../../anchor_watch/providers/anchor_watch_provider.dart';
import '../../anchor_watch/screens/anchor_watch_screen.dart';
import '../../navigation/screens/navigation_dashboard_screen.dart';
import '../../weather/screens/weather_screen.dart';
import '../../checklists/screens/checklist_screen.dart';
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
    LogbookScreen(),
    WeatherScreen(),
    ChecklistScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final anchorProvider = context.watch<AnchorWatchProvider>();
    final anchorConfig = anchorProvider.config;
    final anchorActive = anchorConfig?.isActive ?? false;
    final anchorAlarm = anchorProvider.isAlarmTriggered;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          IndexedStack(index: _currentIndex, children: _screens),

          // Persistent status on the app shell: the anchor alarm is not hidden
          // just because the user navigates away from the dashboard.
          if (anchorActive)
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 16,
              right: 16,
              child: SafeArea(
                bottom: false,
                child: Material(
                  color: anchorAlarm ? const Color(0xFFB42318) : colors.surface,
                  elevation: 5,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const AnchorWatchScreen(),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      child: Row(
                        children: [
                          Icon(
                            anchorAlarm ? Icons.warning_amber_rounded : Icons.anchor_rounded,
                            color: anchorAlarm ? Colors.white : colors.primary,
                            size: 25,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              anchorAlarm
                                  ? 'ALERTE MOUILLAGE — DÉRIVE DÉTECTÉE'
                                  : 'SURVEILLANCE DU MOUILLAGE ACTIVE',
                              style: TextStyle(
                                color: anchorAlarm ? Colors.white : colors.onSurface,
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: anchorAlarm ? Colors.white : colors.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // Floating navigation bar.
          Positioned(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).padding.bottom + 10,
            child: Container(
              height: 68,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: colors.surface.withValues(alpha: 0.97),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Theme.of(context).dividerColor, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: Theme.of(context).brightness == Brightness.dark ? 0.22 : 0.09,
                    ),
                    blurRadius: 22,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavItem(
                    icon: Icons.home_rounded,
                    label: l10n.navHome,
                    isSelected: _currentIndex == 0,
                    onTap: () => setState(() => _currentIndex = 0),
                  ),
                  _NavItem(
                    icon: Icons.menu_book_rounded,
                    label: l10n.navLogbook,
                    isSelected: _currentIndex == 1,
                    onTap: () => setState(() => _currentIndex = 1),
                  ),
                  _NavItem(
                    icon: Icons.air_rounded,
                    label: l10n.navWeather,
                    isSelected: _currentIndex == 2,
                    onTap: () => setState(() => _currentIndex = 2),
                  ),
                  _NavItem(
                    icon: Icons.verified_user_rounded,
                    label: l10n.navSafety,
                    isSelected: _currentIndex == 3,
                    onTap: () => setState(() => _currentIndex = 3),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? colors.primary.withValues(alpha: 0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? colors.primary : colors.onSurfaceVariant,
                size: 20,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? colors.primary : colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
