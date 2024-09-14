import 'dart:io';

class FileUpload{
  File? file;
  String? url;
  bool isFeatured;

  FileUpload({this.file, this.url, this.isFeatured =false});
}