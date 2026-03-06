import 'dart:typed_data';
import 'package:excel/excel.dart';
import '../models/student.dart';
import '../models/student_grade.dart';

/// Handles Excel file operations (read and write) - Web and Desktop compatible
class ExcelHandler {
  /// Read students from Excel bytes (Web-compatible)
  /// Expected format: Column A = ID, Column B = Name, Column C = Marks
  static Future<List<Student>> readStudentsFromBytes(Uint8List bytes) async {
    try {
      if (bytes.isEmpty) {
        throw Exception('Excel file is empty');
      }

      final excel = Excel.decodeBytes(bytes);

      if (excel.tables.isEmpty) {
        throw Exception('No sheets found in Excel file');
      }

      final table = excel.tables.keys.first;
      final sheet = excel.tables[table];

      if (sheet == null) {
        throw Exception('No data found in Excel file');
      }

      List<Student> students = [];

      // Skip header row (row 0)
      for (int i = 1; i < sheet.maxRows; i++) {
        try {
          final row = sheet.row(i);

          // Check if row has enough columns and is not empty
          if (row.isEmpty || row.length < 3) continue;

          // Get cell values
          final idCell = row[0];
          final nameCell = row[1];
          final marksCell = row[2];

          // Skip if any cell is null
          if (idCell == null || nameCell == null || marksCell == null) continue;

          // Extract values
          final id = (idCell.value ?? idCell).toString().trim();
          final name = (nameCell.value ?? nameCell).toString().trim();
          final marksStr = (marksCell.value ?? marksCell).toString().trim();

          // Skip empty values
          if (id.isEmpty || name.isEmpty || marksStr.isEmpty) continue;

          // Parse marks
          final marks = double.tryParse(marksStr);
          if (marks == null || marks < 0 || marks > 100) continue;

          students.add(Student(id: id, name: name, marks: marks));
        } catch (e) {
          // Skip problematic rows
          continue;
        }
      }

      if (students.isEmpty) {
        throw Exception('No valid student data found. Check format: Column A=ID, B=Name, C=Marks');
      }

      return students;
    } catch (e) {
      throw Exception('Failed to parse Excel file: $e');
    }
  }

  /// Read students from an Excel file (Desktop-only)
  ///This method is not available on web. Use readStudentsFromBytes() instead.
  static Future<List<Student>> readStudentsFromExcel(String filePath) async {
    throw Exception(
        'Desktop file I/O not available. Use readStudentsFromBytes() instead.');
  }

  /// Encode grades to Excel bytes (Web-compatible)
  static Uint8List? encodeGradesToBytes(
    List<StudentGrade> grades,
  ) {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['Sheet1'];

      // Add headers
      sheet.appendRow(['Student ID', 'Name', 'Marks', 'Grade']);

      // Add student grades
      for (final grade in grades) {
        sheet.appendRow([grade.id, grade.name, grade.marks, grade.grade]);
      }

      final encoded = excel.encode();
      return encoded != null ? Uint8List.fromList(encoded) : null;
    } catch (e) {
      throw Exception('Failed to encode grades to Excel: $e');
    }
  }

  /// Write student grades to a new Excel file (Desktop-only)
  /// This method is not available on web. Use encodeGradesToBytes() instead.
  static Future<void> writeGradesToExcel(
    List<StudentGrade> grades,
    String outputFilePath,
  ) async {
    throw Exception(
        'Desktop file I/O not available. Use encodeGradesToBytes() instead.');
  }

  /// Encode grades with statistics to Excel bytes (Web-compatible)
  static Uint8List? encodeGradesWithStatisticsToBytes(
    List<StudentGrade> grades,
    Map<String, dynamic> statistics,
  ) {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['Sheet1'];

      // Add headers
      sheet.appendRow(['Student ID', 'Name', 'Marks', 'Grade']);

      // Add student grades
      for (final grade in grades) {
        sheet.appendRow([grade.id, grade.name, grade.marks, grade.grade]);
      }

      // Add statistics section
      sheet.appendRow([]); // Empty row
      sheet.appendRow(['Statistics']);
      sheet.appendRow(['Total Students', statistics['totalStudents']]);
      sheet.appendRow(['Average Marks', statistics['averageMarks']]);
      sheet.appendRow(['Highest Marks', statistics['highestMarks']]);
      sheet.appendRow(['Lowest Marks', statistics['lowestMarks']]);

      // Add grade distribution
      sheet.appendRow([]); // Empty row
      sheet.appendRow(['Grade Distribution']);
      final gradeCounts = statistics['gradeCounts'] ?? {};
      for (final entry in (gradeCounts as Map).entries) {
        sheet.appendRow(['Grade ${entry.key}', entry.value]);
      }

      final encoded = excel.encode();
      return encoded != null ? Uint8List.fromList(encoded) : null;
    } catch (e) {
      throw Exception('Failed to encode grades with statistics: $e');
    }
  }

  /// Write grades and statistics to Excel file (Desktop-only)
  ///This method is not available on web. Use encodeGradesWithStatisticsToBytes() instead.
  static Future<void> writeGradesWithStatistics(
    List<StudentGrade> grades,
    Map<String, dynamic> statistics,
    String outputFilePath,
  ) async {
    throw Exception(
        'Desktop file I/O not available. Use encodeGradesWithStatisticsToBytes() instead.');
  }
}
