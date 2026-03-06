import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_html/html.dart' as html;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DownloadUtil {
  static Future<String> downloadGradesExcel(
    Uint8List excelBytes,
    String fileName,
  ) async {
    try {
      if (kIsWeb) {
        _downloadWeb(excelBytes, fileName);
        return 'Downloaded to browser downloads';
      } else {
        return await _downloadMobile(excelBytes, fileName);
      }
    } catch (e) {
      throw Exception('Failed to download file: $e');
    }
  }

  static void _downloadWeb(Uint8List bytes, String fileName) {
    final blob = html.Blob([bytes],
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute('download', fileName)
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  static Future<String> _downloadMobile(Uint8List bytes, String fileName) async {
    try {
      Directory? directory;
      
      if (Platform.isAndroid) {
        // Android: Save to Downloads folder
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else if (Platform.isIOS) {
        // iOS: Save to app documents directory
        directory = await getApplicationDocumentsDirectory();
      } else {
        // Desktop: Use downloads directory
        directory = await getDownloadsDirectory();
      }

      if (directory == null) {
        throw Exception('Could not access storage');
      }

      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(bytes);
      
      return file.path;
    } catch (e) {
      throw Exception('Failed to save file: $e');
    }
  }
}
