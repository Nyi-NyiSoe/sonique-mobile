import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sonique/core/theme/app_theme.dart';
import 'package:sonique/core/theme/app_theme_controller.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: ValueListenableBuilder<SoniqueTheme>(
          valueListenable: AppThemeController.instance,
          builder: (context, selectedTheme, _) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
              children: [
                Row(
                  children: [
                    IconButton(
                      tooltip: 'Back',
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(
                          alpha: 0.16,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.settings_outlined,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Settings',
                            style: theme.textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Choose how Sonique looks',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.textTheme.bodySmall?.color
                                  ?.withValues(alpha: 0.68),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Theme',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                ...SoniqueTheme.values.map(
                  (themeOption) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _ThemeOptionTile(
                      themeOption: themeOption,
                      isSelected: selectedTheme == themeOption,
                      onTap:
                          () =>
                              AppThemeController.instance.setTheme(themeOption),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ThemeOptionTile extends StatelessWidget {
  const _ThemeOptionTile({
    required this.themeOption,
    required this.isSelected,
    required this.onTap,
  });

  final SoniqueTheme themeOption;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              _ThemeSwatch(themeOption: themeOption),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      themeOption.label,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      themeOption.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withValues(
                          alpha: 0.66,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: isSelected ? theme.colorScheme.primary : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeSwatch extends StatelessWidget {
  const _ThemeSwatch({required this.themeOption});

  final SoniqueTheme themeOption;

  @override
  Widget build(BuildContext context) {
    final colors = switch (themeOption) {
      SoniqueTheme.studioDark => const [
        Color(0xFF101211),
        Color(0xFF191C1A),
        Color(0xFF35D07F),
      ],
      SoniqueTheme.studioLight => const [
        Color(0xFFF7F8F5),
        Colors.white,
        Color(0xFF159957),
      ],
      SoniqueTheme.midnight => const [
        Color(0xFF090D16),
        Color(0xFF121827),
        Color(0xFF64D2FF),
      ],
    };

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children:
            colors
                .map(
                  (color) => Expanded(
                    child: ColoredBox(color: color, child: const SizedBox()),
                  ),
                )
                .toList(),
      ),
    );
  }
}
