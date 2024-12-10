// lib/models/storage_response.dart
class StorageResponse {
  final bool success;
  final String? errorMessage;
  final List<String>? downloadUrls;

  StorageResponse({required this.success, this.errorMessage, this.downloadUrls});
}