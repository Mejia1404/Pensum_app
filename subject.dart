import 'package:flutter/material.dart';

/// Modelo de materia/asignatura
@immutable
class Subject {
  final String code;
  final String name;
  final int credits;
  final int semester;
  final List<String> prerequisites;
  final bool isLab;

  const Subject({
    required this.code,
    required this.name,
    required this.credits,
    required this.semester,
    this.prerequisites = const [],
    this.isLab = false,
  });

  /// Crea una copia de la materia
  Subject copyWith({
    String? code,
    String? name,
    int? credits,
    int? semester,
    List<String>? prerequisites,
    bool? isLab,
  }) {
    return Subject(
      code: code ?? this.code,
      name: name ?? this.name,
      credits: credits ?? this.credits,
      semester: semester ?? this.semester,
      prerequisites: prerequisites ?? this.prerequisites,
      isLab: isLab ?? this.isLab,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Subject && other.code == code;
  }

  @override
  int get hashCode => code.hashCode;
}
