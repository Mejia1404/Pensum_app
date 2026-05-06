import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Notificador para cambios de tema en tiempo real
class ThemeNotifier extends ChangeNotifier {
  static const String _themeModeKey = 'themeMode';
  static SharedPreferences? _prefs;

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  ThemeNotifier() {
    _loadTheme();
  }

  /// Determina si está en modo oscuro considerando el tema del sistema
  bool isDarkMode(BuildContext context) {
    if (_themeMode == ThemeMode.system) {
      return MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  /// Carga el tema guardado desde SharedPreferences
  Future<void> _loadTheme() async {
    _prefs ??= await SharedPreferences.getInstance();
    final savedMode = _prefs!.getString(_themeModeKey);

    if (savedMode != null) {
      switch (savedMode) {
        case 'light':
          _themeMode = ThemeMode.light;
          break;
        case 'dark':
          _themeMode = ThemeMode.dark;
          break;
        default:
          _themeMode = ThemeMode.system;
      }
    }
    notifyListeners();
  }

  /// Establece el modo de tema y lo guarda
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    _prefs ??= await SharedPreferences.getInstance();

    String modeString;
    switch (mode) {
      case ThemeMode.light:
        modeString = 'light';
        break;
      case ThemeMode.dark:
        modeString = 'dark';
        break;
      default:
        modeString = 'system';
    }

    await _prefs!.setString(_themeModeKey, modeString);
    notifyListeners();
  }

  /// Cicla entre: system -> light -> dark -> system
  Future<void> toggleTheme() async {
    ThemeMode nextMode;
    switch (_themeMode) {
      case ThemeMode.system:
        nextMode = ThemeMode.light;
        break;
      case ThemeMode.light:
        nextMode = ThemeMode.dark;
        break;
      case ThemeMode.dark:
        nextMode = ThemeMode.system;
        break;
    }
    await setThemeMode(nextMode);
  }
}
