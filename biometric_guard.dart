import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

class BiometricGuard extends StatefulWidget {
  final Widget child;

  const BiometricGuard({super.key, required this.child});

  @override
  State<BiometricGuard> createState() => _BiometricGuardState();
}

class _BiometricGuardState extends State<BiometricGuard>
    with WidgetsBindingObserver {
  final LocalAuthentication auth = LocalAuthentication();
  bool _isLocked = true;
  bool _isTransitioning = false;
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isLocked && !_isAuthenticating) {
        _authenticate();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      // Pantalla del color del fondo del tema momentánea mientras va a segundo plano por seguridad
      setState(() {
        _isTransitioning = true;
      });
    } else if (state == AppLifecycleState.paused) {
      // Bloqueo inmediato al ir a segundo plano
      setState(() {
        _isLocked = true;
        _isTransitioning = false;
      });
    } else if (state == AppLifecycleState.resumed) {
      setState(() {
        _isTransitioning = false;
      });
      if (_isLocked && !_isAuthenticating) {
        _authenticate();
      }
    }
  }

  Future<void> _authenticate() async {
    if (_isAuthenticating) return;

    setState(() {
      _isAuthenticating = true;
    });

    try {
      final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await auth.isDeviceSupported();

      if (!canAuthenticate) {
        // Si el dispositivo no soporta autenticación, lo desbloqueamos.
        // Podrías implementar una alternativa como un PIN manual aquí.
        setState(() {
          _isLocked = false;
        });
        return;
      }

      final bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Por favor, autentícate para acceder a la aplicación',
        persistAcrossBackgrounding: true,
        biometricOnly: false,
      );

      if (didAuthenticate) {
        setState(() {
          _isLocked = false;
        });
      }
    } catch (e) {
      debugPrint("Error de autenticación biométrica: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isAuthenticating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Pantalla momentánea de transición (Color de fondo del tema actual)
    if (_isTransitioning) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const SizedBox.shrink(),
      );
    }

    // Pantalla de bloqueo (Fondo oscuro)
    if (_isLocked) {
      return Scaffold(
        backgroundColor: const Color(0xFF121212), // Fondo oscuro
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.lock_outline,
                size: 80,
                color: Colors.white70,
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _authenticate,
                icon: const Icon(Icons.fingerprint),
                label: const Text('Desbloquear'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Retornamos el widget original si no está bloqueado
    return widget.child;
  }
}
