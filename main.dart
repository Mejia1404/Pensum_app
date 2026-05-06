import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dynamic_color/dynamic_color.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/theme_notifier.dart';
import 'data/pensum_data.dart';
import 'data/pensum_library.dart';
import 'services/notification_service.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/pensum_selection_screen.dart';
import 'features/main/screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Inicializar formato de fechas en español
    await initializeDateFormatting('es_ES', null);
  } catch (e) {
    debugPrint('Error inicializando date formatting: $e');
  }

  try {
    // Inicializar servicio de notificaciones
    NotificationService().init();
  } catch (e) {
    debugPrint('Error inicializando notificaciones: $e');
  }

  // Pre-cargar SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // Inicializar con el pensum guardado o el por defecto
  final selectedPensumId =
      prefs.getString('selectedPensumId') ?? PensumLibrary.systemsId;
  PensumData.initialize(selectedPensumId);

  runApp(const PensumApp());
}

class PensumApp extends StatefulWidget {
  const PensumApp({super.key});

  @override
  State<PensumApp> createState() => _PensumAppState();
}

class _PensumAppState extends State<PensumApp> {
  final ThemeNotifier _themeNotifier = ThemeNotifier();

  @override
  void initState() {
    super.initState();
    _themeNotifier.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    _themeNotifier.removeListener(_onThemeChanged);
    _themeNotifier.dispose();
    super.dispose();
  }

  void _onThemeChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        return MaterialApp(
          title: 'Mi Pensum',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.getLightTheme(lightDynamic),
          darkTheme: AppTheme.getDarkTheme(darkDynamic),
          themeMode: _themeNotifier.themeMode,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('es', 'ES'), Locale('en', 'US')],
          home: AuthWrapper(themeNotifier: _themeNotifier),
        );
      },
    );
  }
}

class AuthWrapper extends StatefulWidget {
  final ThemeNotifier themeNotifier;

  const AuthWrapper({super.key, required this.themeNotifier});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  String? _userName;
  String? _selectedPensumId;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final prefs = await SharedPreferences.getInstance();

    if (mounted) {
      setState(() {
        _userName = prefs.getString('userName');
        _selectedPensumId = prefs.getString('selectedPensumId');
        _isLoading = false;
      });
    }
  }

  void _onLoginSuccess() {
    _checkAuth();
  }

  void _onSelectionComplete() {
    _checkAuth();
  }

  void _onLogout() {
    setState(() {
      _userName = null;
      _selectedPensumId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return ListenableBuilder(
        listenable: widget.themeNotifier,
        builder: (context, _) {
          final isDark = widget.themeNotifier.isDarkMode(context);
          return Scaffold(
            backgroundColor:
                isDark ? AppColors.darkBackground : AppColors.lightBackground,
            body: const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        },
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (child, animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: _userName == null
          ? LoginScreen(
              key: const ValueKey('login'),
              themeNotifier: widget.themeNotifier,
              onLoginSuccess: _onLoginSuccess,
            )
          : (_selectedPensumId == null
              ? PensumSelectionScreen(
                  key: const ValueKey('selection'),
                  themeNotifier: widget.themeNotifier,
                  onSelectionComplete: _onSelectionComplete,
                )
              : MainScreen(
                  key: const ValueKey('main'),
                  themeNotifier: widget.themeNotifier,
                  onLogout: _onLogout,
                )),
    );
  }
}
