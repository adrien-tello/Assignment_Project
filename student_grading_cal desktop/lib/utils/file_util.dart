import 'dart:io';

/// Utility class for file operations
class FileUtil {
  /// Check if file exists
  static bool fileExists(String filePath) {
    return File(filePath).existsSync();
  }

  /// Get file extension
  static String getFileExtension(String filePath) {
    return File(filePath).path.split('.').last.toLowerCase();
  }

  /// Get file name without extension
  static String getFileNameWithoutExtension(String filePath) {
    final fileName = File(filePath).path.split(Platform.pathSeparator).last;
    return fileName.split('.').first;
  }

  /// Create directory if it doesn't exist
  static Future<void> createDirectoryIfNotExists(String dirPath) async {
    final dir = Directory(dirPath);
    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }
  }

  /// Get file size in bytes
  static int getFileSize(String filePath) {
    return File(filePath).lengthSync();
  }

  /// Delete file
  static Future<void> deleteFile(String filePath) async {
    final file = File(filePath);
    if (file.existsSync()) {
      await file.delete();
    }
  }
}
