import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sonique/core/theme/app_theme.dart';

class AppThemeController extends ValueNotifier<SoniqueTheme> {
  AppThemeController._() : super(SoniqueTheme.studioDark);

  static final AppThemeController instance = AppThemeController._();

  static const String _storageKey = 'sonique_theme';

  Future<void> load() async {
    final preferences = await SharedPreferences.getInstance();
    final savedTheme = preferences.getString(_storageKey);
    value = SoniqueTheme.values.firstWhere(
      (theme) => theme.name == savedTheme,
      orElse: () => SoniqueTheme.studioDark,
    );
  }

  Future<void> setTheme(SoniqueTheme theme) async {
    value = theme;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_storageKey, theme.name);
  }
}
