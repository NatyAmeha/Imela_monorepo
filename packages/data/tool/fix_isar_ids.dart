import 'dart:io';

void main() async {
  final directory = Directory('lib/database/entity');
  final files = directory.listSync().where((f) => f.path.endsWith('.g.dart'));

  int counter = 1;
  for (final file in files) {
    String content = await File(file.path).readAsString();

    // Replace collection IDs
    content = content.replaceAllMapped(
      RegExp(r'id: [-]?\d{15,}'),
      (match) => 'id: ${counter++}',
    );

    // Replace index IDs
    content = content.replaceAllMapped(
      RegExp(r'id: [-]?\d{15,}'),
      (match) => 'id: ${counter++}',
    );

    await File(file.path).writeAsString(content);
    print('Fixed IDs in ${file.path}');
  }

  print('Done fixing Isar IDs');
} 