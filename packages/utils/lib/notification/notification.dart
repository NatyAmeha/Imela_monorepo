class AppNotificationResponse {
  final bool success;
  final String message;

  AppNotificationResponse({
    required this.success,
    required this.message,
  });
}

enum AppNotificationType {
  basic,
  scheduled,
  recurring,
}

