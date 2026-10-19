import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/theme_controller.dart';
import '../../../core/constants/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final controller = context.watch<ThemeController>();
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Personnaliser KipMarine')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? const [Color(0xFF0B4A58), Color(0xFF073042)]
                    : const [Color(0xFF12AFCB), Color(0xFF073B55)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(26),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -14,
                  top: -18,
                  child: Icon(
                    Icons.waves_rounded,
                    size: 116,
                    color: Colors.white.withValues(alpha: 0.10),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.palette_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Votre KipMarine,\nvotre ambiance.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        height: 1.12,
                        letterSpacing: -0.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Text(
                      'Choisissez l’apparence qui vous accompagne en mer.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.82),
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 26),
          Text(
            'APPARENCE',
            style: theme.textTheme.labelLarge?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Le changement est appliqué immédiatement.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          _ThemeChoice(
            icon: Icons.brightness_auto_rounded,
            title: 'Automatique',
            subtitle: 'Suit les réglages de votre téléphone',
            selected: controller.themeMode == ThemeMode.system,
            onTap: () => controller.setThemeMode(ThemeMode.system),
            accent: AppColors.primaryTeal,
          ),
          const SizedBox(height: 10),
          _ThemeChoice(
            icon: Icons.light_mode_rounded,
            title: 'Clair · lagon',
            subtitle: 'Fond lumineux, turquoise et bleu profond',
            selected: controller.themeMode == ThemeMode.light,
            onTap: () => controller.setThemeMode(ThemeMode.light),
            accent: AppColors.primaryTeal,
          ),
          const SizedBox(height: 10),
          _ThemeChoice(
            icon: Icons.dark_mode_rounded,
            title: 'Sombre · Méditerranée',
            subtitle: 'Bleu nuit, mer profonde et accent turquoise',
            selected: controller.themeMode == ThemeMode.dark,
            onTap: () => controller.setThemeMode(ThemeMode.dark),
            accent: AppColors.darkAccent,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.mobOrange.withValues(alpha: 0.13),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.color_lens_outlined,
                    color: AppColors.mobOrange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Une identité, deux ambiances',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'La palette KipMarine conserve ses repères : '
                        'turquoise lagon, bleu marin et touches corail '
                        'pour les actions importantes.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeChoice extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;
  final Color accent;

  const _ThemeChoice({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Material(
      color: selected
          ? accent.withValues(alpha: 0.10)
          : colors.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? accent : theme.dividerColor,
              width: selected ? 1.7 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: selected ? 0.16 : 0.10),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: accent),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? accent : Colors.transparent,
                  border: Border.all(
                    color: selected ? accent : colors.outline,
                    width: selected ? 1 : 1.5,
                  ),
                ),
                child: selected
                    ? const Icon(
                        Icons.check_rounded,
                        size: 16,
                        color: Colors.white,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
