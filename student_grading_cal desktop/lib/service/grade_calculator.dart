import '../models/student.dart';
import '../models/student_grade.dart';
import '../models/grading_scale.dart';

/// Handles grade calculation logic
class GradeCalculator {
  final GradingScale gradingScale;

  GradeCalculator({GradingScale? gradingScale})
      : gradingScale = gradingScale ?? GradingScale.defaultScale();

  /// Calculate grade for a single student
  StudentGrade calculateGrade(Student student) {
    final grade = gradingScale.getGrade(student.marks);
    return StudentGrade(
      id: student.id,
      name: student.name,
      marks: student.marks,
      grade: grade,
    );
  }

  /// Calculate grades for multiple students
  List<StudentGrade> calculateGrades(List<Student> students) {
    return students.map((student) => calculateGrade(student)).toList();
  }

  /// Get statistics about the grades
  GradeStatistics getStatistics(List<StudentGrade> grades) {
    if (grades.isEmpty) {
      return GradeStatistics(
        totalStudents: 0,
        averageMarks: 0,
        highestMarks: 0,
        lowestMarks: 0,
        gradeCounts: {},
      );
    }

    double totalMarks = 0;
    double highest = grades.first.marks;
    double lowest = grades.first.marks;
    Map<String, int> gradeCounts = {};

    for (final grade in grades) {
      totalMarks += grade.marks;
      highest = highest > grade.marks ? highest : grade.marks;
      lowest = lowest < grade.marks ? lowest : grade.marks;
      gradeCounts[grade.grade] = (gradeCounts[grade.grade] ?? 0) + 1;
    }

    return GradeStatistics(
      totalStudents: grades.length,
      averageMarks: totalMarks / grades.length,
      highestMarks: highest,
      lowestMarks: lowest,
      gradeCounts: gradeCounts,
    );
  }
}

/// Statistics of grade distribution
class GradeStatistics {
  final int totalStudents;
  final double averageMarks;
  final double highestMarks;
  final double lowestMarks;
  final Map<String, int> gradeCounts;

  GradeStatistics({
    required this.totalStudents,
    required this.averageMarks,
    required this.highestMarks,
    required this.lowestMarks,
    required this.gradeCounts,
  });

  @override
  String toString() {
    return 'GradeStatistics(students: $totalStudents, average: ${averageMarks.toStringAsFixed(2)}, highest: $highestMarks, lowest: $lowestMarks)';
  }
}
