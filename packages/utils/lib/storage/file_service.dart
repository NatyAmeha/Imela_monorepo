import 'package:file_picker/file_picker.dart';

abstract class IFileService {
  Future<String?> pickFile(String type);
}

class FileService implements IFileService {
  @override
  Future<String?> pickFile(String type) async {
    // Open file picker to select an Excel file
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [type], // xlsx
      );
      if (result != null && result.files.isNotEmpty) {
        // Return the file path
        return result.files.single.path;
      }

      // If no file selected, return null
      return null;
    } catch (e) {
      print('file picker error: $e');
    }
  }
}
