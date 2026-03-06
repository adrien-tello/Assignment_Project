/// Represents a single student with their information and marks
class Student {
  final String id;
  final String name;
  final double marks;

  Student({required this.id, required this.name, required this.marks});

  /// Get information about the student
  @override
  String toString() {
    return 'Student(id: $id, name: $name, marks: $marks)';
  }
}
