import 'package:flutter/material.dart';

enum LibraryAccentTone { primary, favorite, artist, neutral }

class LibraryAccentColors {
  const LibraryAccentColors({
    required this.background,
    required this.foreground,
    required this.icon,
  });

  final Color background;
  final Color foreground;
  final Color icon;

  static LibraryAccentColors resolve(
    BuildContext context,
    LibraryAccentTone tone,
  ) {
    final scheme = Theme.of(context).colorScheme;

    return switch (tone) {
      LibraryAccentTone.primary => LibraryAccentColors(
        background: scheme.primaryContainer,
        foreground: scheme.onPrimaryContainer,
        icon: scheme.primary,
      ),
      LibraryAccentTone.favorite => LibraryAccentColors(
        background: scheme.errorContainer,
        foreground: scheme.onErrorContainer,
        icon: scheme.error,
      ),
      LibraryAccentTone.artist => LibraryAccentColors(
        background: scheme.tertiaryContainer,
        foreground: scheme.onTertiaryContainer,
        icon: scheme.tertiary,
      ),
      LibraryAccentTone.neutral => LibraryAccentColors(
        background: scheme.surfaceContainerHighest,
        foreground: scheme.onSurfaceVariant,
        icon: scheme.onSurfaceVariant,
      ),
    };
  }
}
