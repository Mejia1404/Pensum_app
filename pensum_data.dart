import 'models/subject.dart';
import 'pensum_library.dart';

/// Datos pre-calculados del pensum actual
class PensumData {
  PensumData._();

  static List<Subject> subjects = [];
  static int totalCredits = 0;
  static int totalSubjects = 0;
  static Map<int, List<Subject>> subjectsBySemester = {};
  static String currentPensumId = PensumLibrary.systemsId;
  static String currentPensumName = '';
  static String currentUniversity = '';
  static String currentDegree = '';

  /// Inicializa los datos del pensum seleccionado
  static void initialize(String pensumId) {
    final pensum = PensumLibrary.availablePensums.firstWhere(
      (p) => p.id == pensumId,
      orElse: () => PensumLibrary.availablePensums.first,
    );

    currentPensumId = pensum.id;
    currentPensumName = pensum.name;
    currentUniversity = pensum.university;
    currentDegree = pensum.degree;
    subjects = pensum.subjects;
    totalSubjects = subjects.length;

    totalCredits = subjects.fold(0, (sum, s) => sum + s.credits);

    subjectsBySemester = {};
    final maxSemester = subjects.isEmpty
        ? 0
        : subjects.map((s) => s.semester).reduce((a, b) => a > b ? a : b);

    for (var i = 1; i <= maxSemester; i++) {
      subjectsBySemester[i] = subjects.where((s) => s.semester == i).toList();
    }
  }
}
