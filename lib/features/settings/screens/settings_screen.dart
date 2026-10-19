import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/theme_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = context.watch<ThemeController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Personnaliser KipMarine'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'APPARENCE',
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choisissez l’ambiance qui vous accompagne en mer.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 18),
          _ThemeChoice(
            icon: Icons.brightness_auto_rounded,
            title: 'Automatique',
            subtitle: 'Suit les réglages de votre téléphone',
            value: ThemeMode.system,
            selected: controller.themeMode == ThemeMode.system,
            onTap: () => controller.setThemeMode(ThemeMode.system),
          ),
          const SizedBox(height: 10),
          _ThemeChoice(
            icon: Icons.light_mode_rounded,
            title: 'Clair · lagon',
            subtitle: 'Fond lumineux, turquoise et bleu profond',
            value: ThemeMode.light,
            selected: controller.themeMode == ThemeMode.light,
            onTap: () => controller.setThemeMode(ThemeMode.light),
          ),
          const SizedBox(height: 10),
          _ThemeChoice(
            icon: Icons.dark_mode_rounded,
            title: 'Sombre · Méditerranée',
            subtitle: 'Bleu nuit, mer profonde et accent turquoise',
            value: ThemeMode.dark,
            selected: controller.themeMode == ThemeMode.dark,
            onTap: () => controller.setThemeMode(ThemeMode.dark),
          ),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.palette_outlined, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'La palette reste cohérente dans les deux thèmes : '
                    'turquoise lagon, bleu marin et touches corail pour '
                    'les actions importantes.',
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
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
  final ThemeMode value;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeChoice({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Material(
      color: selected
          ? colors.primary.withValues(alpha: 0.10)
          : colors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? colors.primary : theme.dividerColor,
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: colors.primary),
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
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                color: selected ? colors.primary : colors.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
