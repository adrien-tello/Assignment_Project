import 'package:flutter/material.dart';
import '../models/student_grade.dart';
import '../service/excel_handler.dart';
import '../utils/download_util.dart';
import '../config/app_theme.dart';
import '../service/google_sheets_service.dart';

class ResultsScreen extends StatelessWidget {
  final List<StudentGrade> grades;
  final String outputFilePath;

  const ResultsScreen({
    super.key,
    required this.grades,
    required this.outputFilePath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Results'),
      ),
      body: Column(
        children: [
          _buildStatsHeader(context),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: grades.length,
              itemBuilder: (context, index) => _buildGradeCard(grades[index]),
            ),
          ),
          _buildBottomActions(context),
        ],
      ),
    );
  }

  Widget _buildStatsHeader(BuildContext context) {
    final avg = grades.fold(0.0, (sum, g) => sum + g.marks) / grades.length;
    final gradeDistribution = <String, int>{};
    for (var g in grades) {
      gradeDistribution[g.grade] = (gradeDistribution[g.grade] ?? 0) + 1;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.primaryColor.withOpacity(0.7)],
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(context, 'Students', grades.length.toString(), Icons.people),
              _buildStatItem(context, 'Average', avg.toStringAsFixed(1), Icons.trending_up),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: gradeDistribution.entries.map((e) => Chip(
              avatar: CircleAvatar(
                backgroundColor: _getGradeColor(e.key),
                child: Text(e.key, style: const TextStyle(color: Colors.white, fontSize: 10)),
              ),
              label: Text('${e.value}', style: const TextStyle(fontSize: 12)),
              backgroundColor: Colors.white,
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 32),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.white70)),
      ],
    );
  }

  Widget _buildGradeCard(StudentGrade grade) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getGradeColor(grade.grade),
          child: Text(grade.grade, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        title: Text(grade.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('ID: ${grade.id}'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getGradeColor(grade.grade).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text('${grade.marks}', style: TextStyle(fontWeight: FontWeight.bold, color: _getGradeColor(grade.grade))),
        ),
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: const Offset(0, -2))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back'),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _downloadGradesExcel(context),
                  icon: const Icon(Icons.download),
                  label: const Text('Download Excel'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.secondaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _exportToGoogleSheets(context),
              icon: const Icon(Icons.cloud_upload),
              label: const Text('Export to Google Sheets'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F9D58), // Google Sheets Green
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getGradeColor(String grade) {
    switch (grade) {
      case 'A': return Colors.green;
      case 'B': return Colors.blue;
      case 'C': return Colors.orange;
      case 'D': return Colors.deepOrange;
      case 'F': return Colors.red;
      default: return Colors.grey;
    }
  }

  Future<void> _downloadGradesExcel(BuildContext context) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preparing download...')),
      );

      final excelBytes = ExcelHandler.encodeGradesToBytes(grades);
      if (excelBytes == null) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to generate Excel file')),
        );
        return;
      }

      final now = DateTime.now();
      final fileName = 'grades_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}.xlsx';

      final filePath = await DownloadUtil.downloadGradesExcel(excelBytes, fileName);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Saved to: $filePath'),
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'OK',
            onPressed: () {},
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _exportToGoogleSheets(BuildContext context) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connecting to Google Sheets...')),
      );

      final service = GoogleSheetsService();
      await service.signIn();

      final now = DateTime.now();
      final fileName = 'Grades_${now.year}-${now.month}-${now.day}_${now.hour}${now.minute}';
      
      await service.exportGradesToNewSheet(grades, fileName);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Export Successful! Check your Google Drive.')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Export failed: $e')));
    }
  }
}
