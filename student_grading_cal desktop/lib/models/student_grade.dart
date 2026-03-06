/// Represents a student with their assigned grade
class StudentGrade {
  final String id;
  final String name;
  final double marks;
  final String grade;

  StudentGrade({
    required this.id,
    required this.name,
    required this.marks,
    required this.grade,
  });

  /// Create from a Student and assigned grade
  factory StudentGrade.fromStudent(
    String id,
    String name,
    double marks,
    String grade,
  ) {
    return StudentGrade(id: id, name: name, marks: marks, grade: grade);
  }

  /// Convert to a map for Excel export
  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'marks': marks, 'grade': grade};
  }

  @override
  String toString() {
    final marksStr = marks == marks.toInt() ? marks.toInt() : marks;
    return 'StudentGrade(id: $id, name: $name, marks: $marksStr, grade: $grade)';
  }
}
