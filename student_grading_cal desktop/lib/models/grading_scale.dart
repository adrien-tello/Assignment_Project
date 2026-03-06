/// Represents a grade range with minimum and maximum marks
class GradeRange {
  final String grade;
  final double minMarks;
  final double maxMarks;

  GradeRange({
    required this.grade,
    required this.minMarks,
    required this.maxMarks,
  });

  /// Check if marks fall within this grade range
  bool isInRange(double marks) {
    return marks >= minMarks && marks <= maxMarks;
  }
}

/// Defines the grading scale and rules
class GradingScale {
  final List<GradeRange> ranges;

  /// Default grading scale (A, B, C, D, F)
  static GradingScale defaultScale() {
    return GradingScale(
      ranges: [
        GradeRange(grade: 'A', minMarks: 90, maxMarks: 100),
        GradeRange(grade: 'B', minMarks: 80, maxMarks: 89),
        GradeRange(grade: 'C', minMarks: 70, maxMarks: 79),
        GradeRange(grade: 'D', minMarks: 60, maxMarks: 69),
        GradeRange(grade: 'F', minMarks: 0, maxMarks: 59),
      ],
    );
  }

  GradingScale({required this.ranges});

  /// Get grade for given marks
  String getGrade(double marks) {
    final sorted = getSortedRanges(); // Sort from highest to lowest
    for (var range in sorted) {
      if (marks >= range.minMarks) {
        return range.grade;
      }
    }
    return 'F'; // Default to F if no range matches
  }

  /// Get all grade ranges sorted by marks (highest first)
  List<GradeRange> getSortedRanges() {
    final sortedRanges = List<GradeRange>.from(ranges);
    sortedRanges.sort((a, b) => b.minMarks.compareTo(a.minMarks));
    return sortedRanges;
  }
}
