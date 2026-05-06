import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'task.dart';

/// Servicio singleton para gestionar notificaciones locales multiplataforma
///
/// Características principales:
/// - Soporte completo para Android, iOS y Windows
/// - Notificaciones programadas 1 hora antes del vencimiento
/// - Manejo robusto de zonas horarias con fallback
/// - Solicitud de permisos automática (Android 13+, iOS)
/// - Persistencia post-reinicio del dispositivo
/// - Cancelación automática de notificaciones editadas/eliminadas
/// - Para Windows: simulación de notificaciones programadas con Timer
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // Mapear para guardar timers de notificaciones programadas (para Windows)
  final Map<int, Timer> _scheduledTimers = {};

  // ============================================================================
  // INICIALIZACIÓN PRINCIPAL
  // ============================================================================

  /// Inicializa el servicio de notificaciones (debe llamarse una sola vez en main())
  Future<void> init() async {
    if (_isInitialized) {
      debugPrint('⚠️ NotificationService ya fue inicializado');
      return;
    }

    try {
      debugPrint(
          '🔄 Inicializando NotificationService en ${_getPlatformName()}...');

      // Paso 1: Inicializar zona horaria
      await _initializeTimeZone();

      // Paso 2: Configura las opciones iniciales según la plataforma
      final initSettings = _getInitializationSettings();

      // Paso 3: Inicializar el plugin
      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _handleNotificationTap,
      );

      // Paso 4: Configuración específica de plataforma
      await _platformSpecificSetup();

      // Paso 5: Solicitar permisos
      await _requestPermissions();

      _isInitialized = true;
      debugPrint('✅ NotificationService inicializado correctamente');
    } catch (e) {
      debugPrint('❌ Error inicializando NotificationService: $e');
      _isInitialized = false;
    }
  }

  /// Inicializa la zona horaria de forma robusta con múltiples fallbacks
  Future<void> _initializeTimeZone() async {
    try {
      debugPrint('🌍 Inicializando zonas horarias...');

      // Cargar base de datos de zonas horarias
      tz_data.initializeTimeZones();

      // Obtener zona horaria local
      String timeZoneName = 'UTC'; // fallback por defecto

      try {
        // Intentar obtener la zona horaria automáticamente
        final result = await FlutterTimezone.getLocalTimezone();
        // result es TimezoneInfo, convertir explícitamente a String
        timeZoneName = (result as dynamic).toString();
        debugPrint('✓ Zona horaria detectada: $timeZoneName');
      } catch (e) {
        debugPrint('⚠️ No se pudo obtener zona horaria automáticamente: $e');

        // Fallback manual según SO
        if (Platform.isAndroid || Platform.isIOS) {
          timeZoneName =
              'America/Santo_Domingo'; // Fallback para República Dominicana
        } else if (Platform.isWindows) {
          timeZoneName = 'UTC'; // Windows puede requerir UTC
        }

        debugPrint('⚠️ Usando fallback: $timeZoneName');
      }

      // Intentar establecer la zona horaria
      try {
        tz.setLocalLocation(tz.getLocation(timeZoneName));
        debugPrint('✓ Zona horaria configurada: ${tz.local.name}');
      } catch (e) {
        debugPrint(
            '⚠️ No se pudo establecer zona "$timeZoneName", usando UTC: $e');
        try {
          tz.setLocalLocation(tz.getLocation('UTC'));
        } catch (e) {
          debugPrint('❌ Error crítico con UTC: $e');
          // Crear una zona UTC genérica como último recurso
          tz.setLocalLocation(tz.UTC);
        }
      }

      debugPrint('✅ Zona horaria final: ${tz.local.name}');
    } catch (e) {
      debugPrint('❌ Error fatal en inicialización de timezone: $e');
      tz.setLocalLocation(tz.UTC);
    }
  }

  /// Obtiene las opciones de inicialización según la plataforma
  InitializationSettings _getInitializationSettings() {
    // Configuración Android
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Configuración iOS
    final iosSettings = DarwinInitializationSettings(
      onDidReceiveLocalNotification:
          (int id, String? title, String? body, String? payload) {
        debugPrint('📱 Notificación iOS recibida (foreground): $title');
      },
    );

    // Retornar según plataforma
    if (Platform.isAndroid) {
      return InitializationSettings(android: androidSettings);
    } else if (Platform.isIOS) {
      return InitializationSettings(iOS: iosSettings);
    } else if (Platform.isWindows) {
      // Windows también puede usar Android settings como fallback
      return InitializationSettings(android: androidSettings);
    } else {
      return InitializationSettings(android: androidSettings);
    }
  }

  /// Configuración específica de cada plataforma
  Future<void> _platformSpecificSetup() async {
    if (Platform.isAndroid) {
      await _setupAndroid();
    } else if (Platform.isIOS) {
      await _setupiOS();
    } else if (Platform.isWindows) {
      debugPrint('💻 Setup de Windows completado');
    }
  }

  /// Configuración específica para Android
  Future<void> _setupAndroid() async {
    final androidImpl =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImpl == null) {
      debugPrint('⚠️ No se pudo obtener implementación Android');
      return;
    }

    try {
      // Crear canal de notificaciones
      const channel = AndroidNotificationChannel(
        'task_reminders',
        'Recordatorios de Tareas',
        description:
            'Notificaciones de tareas próximas a vencer (1 hora antes)',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        enableLights: true,
      );

      await androidImpl.createNotificationChannel(channel);
      debugPrint('✅ Canal de notificaciones Android creado');
    } catch (e) {
      debugPrint('⚠️ Error en setup de Android: $e');
    }
  }

  /// Configuración específica para iOS
  Future<void> _setupiOS() async {
    try {
      // iOS maneja notificaciones de forma más sencilla
      debugPrint('✅ Setup de iOS completado');
    } catch (e) {
      debugPrint('⚠️ Error en setup de iOS: $e');
    }
  }

  /// Solicita permisos para notificaciones según plataforma
  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      await _requestAndroidPermissions();
    } else if (Platform.isIOS) {
      await _requestiOSPermissions();
    }
    // Windows no requiere permisos de notificaciones
  }

  /// Solicita permisos en Android 13+
  Future<void> _requestAndroidPermissions() async {
    final androidImpl =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImpl == null) return;

    try {
      try {
        final hasNotificationPerm =
            await androidImpl.requestNotificationsPermission();
        debugPrint(
            '📱 Permiso de notificaciones: ${hasNotificationPerm ?? false}');
      } catch (e) {
        debugPrint('⚠️ No se pudo solicitar permiso de notificaciones: $e');
      }

      try {
        final hasExactAlarmPerm =
            await androidImpl.requestExactAlarmsPermission();
        debugPrint(
            '📱 Permiso de alarmas exactas: ${hasExactAlarmPerm ?? false}');
      } catch (e) {
        debugPrint('⚠️ No se pudo solicitar permiso de alarmas exactas: $e');
      }
    } catch (e) {
      debugPrint('⚠️ Error solicitando permisos Android: $e');
    }
  }

  /// Solicita permisos en iOS
  Future<void> _requestiOSPermissions() async {
    try {
      final iosImpl =
          _notificationsPlugin.resolvePlatformSpecificImplementation();

      if (iosImpl == null) return;

      // Intenta llamar a requestPermissions si existe
      try {
        // Usar dynamic para evitar problemas de tipo
        dynamic plugin = iosImpl;
        final granted = await plugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        debugPrint('🍎 Permisos iOS solicitados: $granted');
      } catch (_) {
        // El método podría no estar disponible en algunas plataformas
        debugPrint('🍎 requestPermissions no disponible');
      }
    } catch (e) {
      debugPrint('⚠️ Error solicitando permisos iOS: $e');
    }
  }

  // ============================================================================
  // MANEJO DE NOTIFICACIONES
  // ============================================================================

  /// Maneja la acción al hacer tap en una notificación
  void _handleNotificationTap(NotificationResponse response) {
    debugPrint('📱 Notificación tocada: ${response.payload}');
    // TODO: Aquí puedes navegar a detalles de la tarea si es necesario
  }

  /// Muestra una notificación inmediata
  Future<bool> showNotification({
    required String title,
    required String body,
    required String payload,
    int? id,
  }) async {
    if (!_isInitialized) {
      debugPrint('⚠️ NotificationService no inicializado');
      return false;
    }

    try {
      const androidDetails = AndroidNotificationDetails(
        'task_reminders',
        'Recordatorios de Tareas',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
      );

      const details = NotificationDetails(android: androidDetails);

      await _notificationsPlugin.show(
        id ?? 0,
        title,
        body,
        details,
        payload: payload,
      );

      debugPrint('✅ Notificación mostrada: $title');
      return true;
    } catch (e) {
      debugPrint('❌ Error mostrando notificación: $e');
      return false;
    }
  }

  /// Programa una notificación para una tarea
  /// Se dispara 1 hora antes de la fecha/hora de vencimiento
  Future<bool> scheduleTaskNotification(Task task) async {
    if (!_isInitialized) {
      debugPrint('⚠️ NotificationService no inicializado');
      return false;
    }

    // Validar si puede programarse
    if (!task.enableNotification) {
      debugPrint('⚠️ Notificación desactivada para: ${task.title}');
      return false;
    }

    try {
      final notificationTime = task.notificationDateTime;

      // Validar que la hora sea futura
      if (notificationTime.isBefore(DateTime.now())) {
        debugPrint('⚠️ La hora de notificación está en el pasado');
        return false;
      }

      // Cancelar notificación existente
      await cancelNotification(task.id);

      final notifId = _generateNotificationId(task.id);

      // Ejecutar según plataforma
      if (Platform.isAndroid || Platform.isIOS) {
        return await _scheduleAndroidiOS(task, notificationTime, notifId);
      } else if (Platform.isWindows) {
        return await _scheduleWindows(task, notificationTime, notifId);
      }

      return false;
    } catch (e) {
      debugPrint('❌ Error programando notificación: $e');
      return false;
    }
  }

  /// Programa notificación en Android/iOS usando zonedSchedule
  Future<bool> _scheduleAndroidiOS(
    Task task,
    DateTime notificationTime,
    int notifId,
  ) async {
    try {
      final tzDateTime = tz.TZDateTime.from(notificationTime, tz.local);

      final androidDetails = AndroidNotificationDetails(
        'task_reminders',
        'Recordatorios de Tareas',
        channelDescription:
            'Notificaciones de tareas próximas a vencer (1 hora antes)',
        importance: Importance.max,
        playSound: true,
        enableLights: true,
        color: Color(0xFF6C5CE7),
      );

      const iosDetails = DarwinNotificationDetails(
        sound: null,
        presentSound: true,
        badgeNumber: 1,
      );

      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationsPlugin.zonedSchedule(
        notifId,
        'Tarea próxima a vencer',
        'Falta 1 hora para entregar: ${task.title}',
        tzDateTime,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      debugPrint(
          '✅ Notificación programada (Android/iOS) para ${task.title} a $notificationTime');
      return true;
    } catch (e) {
      debugPrint('❌ Error en _scheduleAndroidiOS: $e');
      return false;
    }
  }

  /// Programa notificación en Windows usando Timer (zonedSchedule no soportado)
  Future<bool> _scheduleWindows(
    Task task,
    DateTime notificationTime,
    int notifId,
  ) async {
    try {
      // Cancelar timer anterior si existe
      _scheduledTimers[notifId]?.cancel();

      final now = DateTime.now();
      final duration = notificationTime.difference(now);

      if (duration.isNegative) {
        debugPrint('⚠️ Hora de notificación en el pasado para Windows');
        return false;
      }

      // Crear timer que ejecutará en el tiempo indicado
      final timer = Timer(duration, () async {
        debugPrint('⏰ Timer de Windows disparado para: ${task.title}');
        await showNotification(
          id: notifId,
          title: 'Tarea próxima a vencer',
          body: 'Falta 1 hora para entregar: ${task.title}',
          payload: task.id,
        );
        _scheduledTimers.remove(notifId);
      });

      _scheduledTimers[notifId] = timer;

      debugPrint(
          '✅ Notificación programada (Windows) para ${task.title} en ${duration.inMinutes} minutos');
      return true;
    } catch (e) {
      debugPrint('❌ Error programando notificación en Windows: $e');
      return false;
    }
  }

  /// Cancela la notificación de una tarea
  Future<bool> cancelNotification(String taskId) async {
    if (!_isInitialized) return false;

    try {
      final notifId = _generateNotificationId(taskId);

      // Cancelar mediante plugin
      await _notificationsPlugin.cancel(notifId);

      // Cancelar timer de Windows si existe
      _scheduledTimers[notifId]?.cancel();
      _scheduledTimers.remove(notifId);

      debugPrint('✅ Notificación cancelada para: $taskId');
      return true;
    } catch (e) {
      debugPrint('❌ Error cancelando notificación: $e');
      return false;
    }
  }

  /// Cancela todas las notificaciones
  Future<void> cancelAllNotifications() async {
    if (!_isInitialized) return;

    try {
      // Cancelar todas mediante plugin
      await _notificationsPlugin.cancelAll();

      // Cancelar todos los timers de Windows
      for (final timer in _scheduledTimers.values) {
        timer.cancel();
      }
      _scheduledTimers.clear();

      debugPrint('✅ Todas las notificaciones canceladas');
    } catch (e) {
      debugPrint('❌ Error cancelando todas las notificaciones: $e');
    }
  }

  /// Actualiza (cancela y reprograma) notificaciones para una tarea editada
  Future<bool> updateTaskNotification(Task oldTask, Task newTask) async {
    await cancelNotification(oldTask.id);
    return await scheduleTaskNotification(newTask);
  }

  // ============================================================================
  // UTILIDADES
  // ============================================================================

  /// Genera un ID único para notificación basado en el ID de tarea
  /// Convierte el UUID string a un hash int válido
  int _generateNotificationId(String taskId) {
    return taskId.codeUnits.fold<int>(0, (prev, value) {
      return ((prev * 31) + value) & 0x7fffffff;
    });
  }

  /// Obtiene el nombre de la plataforma actual
  String _getPlatformName() {
    if (Platform.isAndroid) return 'Android';
    if (Platform.isIOS) return 'iOS';
    if (Platform.isWindows) return 'Windows';
    if (Platform.isLinux) return 'Linux';
    if (Platform.isMacOS) return 'macOS';
    return 'Desconocido';
  }

  /// Obtiene información de la zona horaria local
  String getLocalTimeZoneInfo() {
    return 'Zona horaria: ${tz.local.name}';
  }

  /// Obtiene el offset de la zona horaria local en horas
  int getLocalTimeZoneOffset() {
    final now = tz.TZDateTime.now(tz.local);
    return now.timeZoneOffset.inHours;
  }

  /// Convierte un DateTime a TZDateTime
  tz.TZDateTime toTZDateTime(DateTime dateTime) {
    return tz.TZDateTime.from(dateTime, tz.local);
  }
}
