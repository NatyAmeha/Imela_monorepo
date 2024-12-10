enum PermissionStatusType {
  granted,
  denied,
  permanentlyDenied,
  restricted,
  limited,
  unknown,
}

enum AppPermissionType {
  camera,
  storage,
  location,
  microphone,
  contacts,
  photos,
}

class PermissionResponse {
  final PermissionStatusType status;
  final String message;
  final bool isGranted;

  PermissionResponse({
    required this.status,
    required this.message,
    required this.isGranted,
  });
}
