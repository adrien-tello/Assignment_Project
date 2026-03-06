import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:http/http.dart' as http;
import '../models/student.dart';
import '../models/student_grade.dart';

class AuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  AuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }
}

class GoogleSheetsService {
  static const _scopes = [sheets.SheetsApi.spreadsheetsScope];
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: _scopes);

  Future<GoogleSignInAccount?> signIn() async {
    try {
      return _googleSignIn.currentUser ?? await _googleSignIn.signIn();
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  Future<List<Student>> readStudentsFromSheet(String spreadsheetInput) async {
    final account = await signIn();
    if (account == null) throw Exception('User not authenticated');

    final authHeaders = await account.authHeaders;
    final client = AuthClient(authHeaders);
    final sheetsApi = sheets.SheetsApi(client);
    final spreadsheetId = _extractSpreadsheetId(spreadsheetInput);

    try {
      final spreadsheet = await sheetsApi.spreadsheets.get(spreadsheetId);
      final sheetTitle = spreadsheet.sheets?.first.properties?.title ?? 'Sheet1';
      final range = '$sheetTitle!A:C';
      final response = await sheetsApi.spreadsheets.values.get(spreadsheetId, range);

      if (response.values == null || response.values!.isEmpty) {
        throw Exception('No data found in the sheet');
      }

      List<Student> students = [];
      for (int i = 1; i < response.values!.length; i++) {
        final row = response.values![i];
        if (row.length < 3) continue;

        final id = row[0].toString().trim();
        final name = row[1].toString().trim();
        final marks = double.tryParse(row[2].toString().trim());

        if (id.isNotEmpty && name.isNotEmpty && marks != null) {
          students.add(Student(id: id, name: name, marks: marks));
        }
      }
      return students;
    } finally {
      client.close();
    }
  }

  String _extractSpreadsheetId(String input) {
    final regExp = RegExp(r'/spreadsheets/d/([a-zA-Z0-9-_]+)');
    final match = regExp.firstMatch(input);
    return match?.group(1) ?? input;
  }

  Future<String> exportGradesToNewSheet(List<StudentGrade> grades, String fileName) async {
    final account = await signIn();
    if (account == null) throw Exception('User not authenticated');

    final authHeaders = await account.authHeaders;
    final client = AuthClient(authHeaders);
    final sheetsApi = sheets.SheetsApi(client);

    try {
      final spreadsheet = sheets.Spreadsheet(
        properties: sheets.SpreadsheetProperties(title: fileName),
      );
      
      final created = await sheetsApi.spreadsheets.create(spreadsheet);
      final spreadsheetId = created.spreadsheetId;
      if (spreadsheetId == null) throw Exception('Failed to create spreadsheet');

      final headers = ['Student ID', 'Name', 'Marks', 'Grade'];
      final rows = grades.map((g) => [g.id, g.name, g.marks, g.grade]).toList();
      final data = [headers, ...rows];

      final valueRange = sheets.ValueRange(values: data);
      await sheetsApi.spreadsheets.values.update(
        valueRange, spreadsheetId, 'Sheet1!A1', valueInputOption: 'RAW');

      return created.spreadsheetUrl ?? 'https://docs.google.com/spreadsheets/d/$spreadsheetId';
    } finally {
      client.close();
    }
  }
}
