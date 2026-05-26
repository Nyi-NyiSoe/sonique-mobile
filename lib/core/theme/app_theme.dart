import 'package:flutter/material.dart';

enum SoniqueTheme {
  studioDark,
  studioLight,
  midnight,
}

extension SoniqueThemeDetails on SoniqueTheme {
  String get label {
    return switch (this) {
      SoniqueTheme.studioDark => 'Studio Dark',
      SoniqueTheme.studioLight => 'Studio Light',
      SoniqueTheme.midnight => 'Midnight',
    };
  }

  String get description {
    return switch (this) {
      SoniqueTheme.studioDark => 'Dark, neutral, and focused',
      SoniqueTheme.studioLight => 'Bright with soft surfaces',
      SoniqueTheme.midnight => 'Deep contrast with cool accents',
    };
  }

  Color get accent {
    return switch (this) {
      SoniqueTheme.studioDark => const Color(0xFF35D07F),
      SoniqueTheme.studioLight => const Color(0xFF159957),
      SoniqueTheme.midnight => const Color(0xFF64D2FF),
    };
  }
}

class AppTheme {
  ThemeData themeFor(SoniqueTheme theme) {
    return switch (theme) {
      SoniqueTheme.studioDark => _buildTheme(
        brightness: Brightness.dark,
        seed: const Color(0xFF35D07F),
        background: const Color(0xFF101211),
        surface: const Color(0xFF191C1A),
        text: Colors.white,
      ),
      SoniqueTheme.studioLight => _buildTheme(
        brightness: Brightness.light,
        seed: const Color(0xFF159957),
        background: const Color(0xFFF7F8F5),
        surface: Colors.white,
        text: const Color(0xFF151A17),
      ),
      SoniqueTheme.midnight => _buildTheme(
        brightness: Brightness.dark,
        seed: const Color(0xFF64D2FF),
        background: const Color(0xFF090D16),
        surface: const Color(0xFF121827),
        text: const Color(0xFFF3F7FF),
      ),
    };
  }

  ThemeData get darkTheme => themeFor(SoniqueTheme.studioDark);
  ThemeData get lightTheme => themeFor(SoniqueTheme.studioLight);

  ThemeData _buildTheme({
    required Brightness brightness,
    required Color seed,
    required Color background,
    required Color surface,
    required Color text,
  }) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
    ).copyWith(
      primary: seed,
      surface: surface,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      cardColor: surface,
      hintColor: text.withValues(alpha: 0.56),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: text,
        elevation: 0,
        centerTitle: false,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: seed.withValues(alpha: 0.18),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 12,
            fontWeight:
                states.contains(WidgetState.selected)
                    ? FontWeight.w700
                    : FontWeight.w500,
          ),
        ),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: text,
        ),
        displayMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: text,
        ),
        displaySmall: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: text,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: text,
        ),
        bodyMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: text,
        ),
        bodySmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: text,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: text,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: text,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w400,
          color: text,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: text,
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: text,
        ),
        titleSmall: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: text,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: seed,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: seed,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: seed, width: 2),
        ),
      ),
    );
  }
}
