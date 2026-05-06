import 'package:flutter/material.dart';
import '../../core/utils/datetime_utils.dart';

/// Modelo de tarea
class Task {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final TimeOfDay dueTime;
  bool isCompleted;
  final String category;
  bool enableNotification;
  late int _notificationId;

  Task({
    required this.id,
    required this.title,
    this.description = '',
    required this.dueDate,
    required this.dueTime,
    this.isCompleted = false,
    this.category = 'General',
    this.enableNotification = true,
  }) {
    _notificationId = _generateNotificationId(id);
  }

  /// Combina fecha y hora en un DateTime completo
  DateTime get dueDateTime =>
      DateTimeUtils.combineDateAndTime(dueDate, dueTime);

  /// Obtiene la hora en la que se debe disparar la notificación (1 hora antes)
  DateTime get notificationDateTime =>
      DateTimeUtils.getNotificationTime(dueDateTime);

  /// Genera un ID único y estable para la notificación
  int _generateNotificationId(String taskId) {
    return taskId.codeUnits.fold<int>(0, (prev, value) {
      return ((prev * 31) + value) & 0x7fffffff;
    });
  }

  /// Retorna el ID de notificación
  int get notificationId => _notificationId;

  /// Verifica si es válido programar una notificación
  bool get canScheduleNotification =>
      !isCompleted &&
      enableNotification &&
      DateTimeUtils.isValidForScheduling(notificationDateTime);

  /// Serializa la tarea a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'dueHour': dueTime.hour,
      'dueMinute': dueTime.minute,
      'isCompleted': isCompleted,
      'category': category,
      'enableNotification': enableNotification,
    };
  }

  /// Deserializa una tarea desde JSON
  factory Task.fromJson(Map<String, dynamic> json) {
    final dueDateStr = json['dueDate'] as String?;
    final dueDate =
        dueDateStr != null ? DateTime.parse(dueDateStr) : DateTime.now();

    final dueHour = json['dueHour'] as int? ?? 9;
    final dueMinute = json['dueMinute'] as int? ?? 0;

    return Task(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title'] ?? 'Tarea sin título',
      description: json['description'] ?? '',
      dueDate: dueDate,
      dueTime: TimeOfDay(hour: dueHour, minute: dueMinute),
      isCompleted: json['isCompleted'] ?? false,
      category: json['category'] ?? 'General',
      enableNotification: json['enableNotification'] ?? true,
    );
  }

  /// Crea una copia modificable de la tarea
  Task copyWith({
    String? title,
    String? description,
    DateTime? dueDate,
    TimeOfDay? dueTime,
    bool? isCompleted,
    String? category,
    bool? enableNotification,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      dueTime: dueTime ?? this.dueTime,
      isCompleted: isCompleted ?? this.isCompleted,
      category: category ?? this.category,
      enableNotification: enableNotification ?? this.enableNotification,
    );
  }
}
