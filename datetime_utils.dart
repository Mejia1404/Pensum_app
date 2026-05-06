import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;

/// Utilidades para manejo de fecha/hora con soporte de zonas horarias
class DateTimeUtils {
  DateTimeUtils._();

  /// Convierte un DateTime local a TZDateTime con la zona horaria local
  static tz.TZDateTime toTZDateTime(DateTime dateTime) {
    return tz.TZDateTime.from(dateTime, tz.local);
  }

  /// Obtiene el DateTime 1 hora antes del especificado
  static DateTime getNotificationTime(DateTime dueDateTime) {
    return dueDateTime.subtract(const Duration(hours: 1));
  }

  /// Verifica si una fecha es válida para programar notificación
  static bool isValidForScheduling(DateTime scheduledTime) {
    return scheduledTime.isAfter(DateTime.now());
  }

  /// Combina una fecha y TimeOfDay en un DateTime
  static DateTime combineDateAndTime(DateTime date, TimeOfDay time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  /// Extrae TimeOfDay de un DateTime
  static TimeOfDay timeOfDayFromDateTime(DateTime dateTime) {
    return TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
  }

  /// Formatea un DateTime para mostrar en la UI
  static String formatDateTime(DateTime dateTime) {
    final date = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    final time =
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    return '$date $time';
  }

  /// Obtiene el nombre de la zona horaria actual
  static String getLocalTimeZoneName() {
    return tz.local.name;
  }

  /// Valida que una fecha no sea en el pasado
  static bool isDateInFuture(DateTime date) {
    final now = DateTime.now();
    return date.year > now.year ||
        (date.year == now.year && date.month > now.month) ||
        (date.year == now.year &&
            date.month == now.month &&
            date.day >= now.day);
  }

  /// Formatea una fecha relativa (Hoy, Mañana, etc.)
  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Hoy';
    } else if (dateOnly == tomorrow) {
      return 'Mañana';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
