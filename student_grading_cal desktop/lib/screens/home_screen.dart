import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import '../models/student.dart';
import '../service/excel_handler.dart';
import '../service/grade_calculator.dart';
import '../service/google_sheets_service.dart';
import '../utils/file_util.dart';
import '../config/app_theme.dart';
import 'results_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  String? selectedFilePath;
  Uint8List? selectedFileBytes;
  String? selectedFileName;
  bool isProcessing = false;
  String statusMessage = '';
  late AnimationController _animationController;

  List<Student>? _googleSheetStudents;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grade Calculator'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildHeaderCard(),
              const SizedBox(height: 24),
              _buildUploadCard(),
              const SizedBox(height: 20),
              _buildInfoCard(),
              const SizedBox(height: 24),
              if (statusMessage.isNotEmpty) _buildStatusMessage(),
              const SizedBox(height: 16),
              _buildCalculateButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.primaryColor.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.calculate, size: 40, color: Colors.white),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Automated Grading',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Fast & Accurate',
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                selectedFilePath != null ? Icons.check_circle : Icons.upload_file,
                size: 60,
                color: selectedFilePath != null ? AppTheme.secondaryColor : AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              selectedFilePath != null ? 'File Selected' : 'Upload Excel File',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            if (selectedFileName != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  selectedFileName!,
                  style: TextStyle(color: AppTheme.secondaryColor, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isProcessing ? null : _selectFile,
                    icon: const Icon(Icons.folder_open),
                    label: const Text('Excel File'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isProcessing ? null : _importFromGoogleSheet,
                    icon: const Icon(Icons.table_chart),
                    label: const Text('Google Sheet'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.secondaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'File Format',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Column A', 'Student ID'),
            _buildInfoRow('Column B', 'Student Name'),
            _buildInfoRow('Column C', 'Marks (0-100)'),
            const Divider(height: 24),
            const Text(
              'Grading Scale',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildGradeChip('A', '90-100', Colors.green),
                _buildGradeChip('B', '80-89', Colors.blue),
                _buildGradeChip('C', '70-79', Colors.orange),
                _buildGradeChip('D', '60-69', Colors.deepOrange),
                _buildGradeChip('F', '0-59', Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 80,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 12),
          Text(value, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildGradeChip(String grade, String range, Color color) {
    return Chip(
      avatar: CircleAvatar(backgroundColor: color, child: Text(grade, style: const TextStyle(color: Colors.white, fontSize: 12))),
      label: Text(range, style: const TextStyle(fontSize: 12)),
      backgroundColor: color.withOpacity(0.1),
    );
  }

  Widget _buildStatusMessage() {
    final isError = statusMessage.contains('Error');
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isError ? Colors.red.shade50 : Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isError ? Colors.red : Colors.green),
      ),
      child: Row(
        children: [
          Icon(isError ? Icons.error_outline : Icons.check_circle_outline, color: isError ? Colors.red : Colors.green),
          const SizedBox(width: 12),
          Expanded(child: Text(statusMessage, style: TextStyle(color: isError ? Colors.red : Colors.green))),
        ],
      ),
    );
  }

  Widget _buildCalculateButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isProcessing || (selectedFilePath == null && _googleSheetStudents == null) ? null : _processGrades,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.secondaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: isProcessing
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                  SizedBox(width: 12),
                  Text('Processing...', style: TextStyle(fontSize: 16)),
                ],
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_arrow),
                  SizedBox(width: 8),
                  Text('Calculate Grades', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
      ),
    );
  }

  Future<void> _selectFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.single;
        
        if (file.bytes == null || file.bytes!.isEmpty) {
          setState(() {
            statusMessage = 'Error: Could not read file data';
          });
          return;
        }

        setState(() {
          selectedFileName = file.name;
          selectedFileBytes = file.bytes!;
          selectedFilePath = 'file_selected';
          statusMessage = 'File selected: ${file.name}';
          _googleSheetStudents = null;
        });
      }
    } catch (e) {
      setState(() {
        statusMessage = 'Error selecting file: $e';
      });
    }
  }

  Future<void> _importFromGoogleSheet() async {
    TextEditingController urlController = TextEditingController();
    final url = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import from Google Sheets'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter the Google Sheet Link or ID:'),
            const SizedBox(height: 8),
            TextField(
              controller: urlController,
              decoration: const InputDecoration(
                hintText: 'https://docs.google.com/spreadsheets/d/...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, urlController.text),
            child: const Text('Import'),
          ),
        ],
      ),
    );

    if (url != null && url.isNotEmpty) {
      setState(() { isProcessing = true; statusMessage = 'Connecting to Google Sheets...'; });
      try {
        final sheetsService = GoogleSheetsService();
        final students = await sheetsService.readStudentsFromSheet(url);
        setState(() {
          _googleSheetStudents = students;
          selectedFileName = 'Google Sheet (${students.length} students)';
          selectedFilePath = 'google_sheet';
          statusMessage = 'Google Sheet imported: ${students.length} students';
          isProcessing = false;
        });
      } catch (e) {
        setState(() { statusMessage = 'Error: $e'; isProcessing = false; });
      }
    }
  }

  Future<void> _processGrades() async {
    if (selectedFilePath == null && selectedFileBytes == null && _googleSheetStudents == null) return;

    setState(() {
      isProcessing = true;
      statusMessage = 'Processing...';
    });

    try {
      List<Student> students = [];

      // Case 1: Google Sheets Data
      if (_googleSheetStudents != null) {
        students = _googleSheetStudents!;
      }
      // Case 2: Excel file bytes (works for both web and mobile)
      else if (selectedFileBytes != null && selectedFileBytes!.isNotEmpty) {
        students = await ExcelHandler.readStudentsFromBytes(selectedFileBytes!);
      } else {
        throw Exception('No valid file data available');
      }

      if (students.isEmpty) {
        setState(() {
          statusMessage =
              'No student data found in the Excel file. Check the file format.';
          isProcessing = false;
        });
        return;
      }

      // Calculate grades
      final calculator = GradeCalculator();
      final grades = calculator.calculateGrades(students);
      final statistics = calculator.getStatistics(grades);

      // Prepare statistics map
      final statisticsMap = {
        'totalStudents': statistics.totalStudents,
        'averageMarks': statistics.averageMarks,
        'highestMarks': statistics.highestMarks,
        'lowestMarks': statistics.lowestMarks,
        'gradeCounts': statistics.gradeCounts,
      };

      String outputFilePath = '';

      // Desktop: Save file to disk
      if (!kIsWeb && selectedFilePath != null && selectedFilePath != 'web_file') {
        try {
          final inputFileName = FileUtil.getFileNameWithoutExtension(
            selectedFilePath!,
          );
          // File I/O removed for web compatibility
          final int lastSep = selectedFilePath!.lastIndexOf('/') >
                  selectedFilePath!.lastIndexOf('\\')
              ? selectedFilePath!.lastIndexOf('/')
              : selectedFilePath!.lastIndexOf('\\');
          final String parentPath =
              lastSep > 0 ? selectedFilePath!.substring(0, lastSep) : '';
          final pathSeparator = selectedFilePath!.contains('\\') ? '\\' : '/';
          outputFilePath =
              '$parentPath$pathSeparator${inputFileName}_grades.xlsx';

          await ExcelHandler.writeGradesWithStatistics(
            grades,
            statisticsMap,
            outputFilePath,
          );
        } catch (e) {
          // Continue even if save fails
        }
      } else {
        // Web: Use placeholder path
        outputFilePath = '${selectedFileName ?? 'output'}_grades.xlsx';
      }

      setState(() {
        isProcessing = false;
        statusMessage = 'Success! ${grades.length} grades calculated';
      });

      // Navigate to results screen
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
                ResultsScreen(grades: grades, outputFilePath: outputFilePath),
          ),
        );
      }
    } catch (e) {
      setState(() {
        statusMessage = 'Error: ${e.toString()}';
        isProcessing = false;
      });
    }
  }
}
