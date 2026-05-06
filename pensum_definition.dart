import 'subject.dart';

/// Definición de un pensum universitario
class PensumDefinition {
  final String id;
  final String name;
  final String university;
  final String faculty;
  final String school;
  final String degree;
  final List<Subject> subjects;

  const PensumDefinition({
    required this.id,
    required this.name,
    required this.university,
    required this.faculty,
    required this.school,
    required this.degree,
    required this.subjects,
  });
}
