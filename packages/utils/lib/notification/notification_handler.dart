import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:imela_utils/notification/notification.dart';
import 'package:timezone/timezone.dart' as tz;

abstract class INotificationService {
  Future<AppNotificationResponse> showNotification(AppNotificationType type, {String? title, String? body});
  Future<AppNotificationResponse> scheduleNotification({required String title, required String body, required DateTime scheduleTime});
  Future<AppNotificationResponse> cancelNotification(int id);
  Future<void> initialize();
  Future<void> handleFCM();
}



class AppNotificationService implements INotificationService {
  late FlutterLocalNotificationsPlugin _localNotifications;
  late FirebaseMessaging _firebaseMessaging;

  @override
  Future<void> initialize() async {
    // Initialize FlutterLocalNotificationsPlugin
    _localNotifications = FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings();
    const InitializationSettings settings = InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        // Handle on notification tap
      },
    );

    // Initialize Firebase Messaging
    _firebaseMessaging = FirebaseMessaging.instance;
    _firebaseMessaging.setAutoInitEnabled(true);

    // Request notification permissions for iOS
    if (Platform.isIOS) {
      await _firebaseMessaging.requestPermission();
    }

    // Handle incoming FCM notifications
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      showNotification(AppNotificationType.basic, title: message.notification?.title, body: message.notification?.body);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Handle when the app is opened from a notification
    });
  }

  @override
  Future<void> handleFCM() async {
    // Get the FCM token for the device
    String? fcmToken = await _firebaseMessaging.getToken();
    print('FCM Token: $fcmToken');
    // You can send the FCM token to your backend for push notifications
  }

  @override
  Future<AppNotificationResponse> showNotification(AppNotificationType type, {String? title, String? body}) async {
    try {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'channel_id',
        'channel_name',
        channelDescription: 'channel_description',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker',
      );
      const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);

      await _localNotifications.show(
        0, // Notification ID
        title ?? 'Default Title',
        body ?? 'Default Body',
        platformDetails,
      );

      return AppNotificationResponse(success: true, message: 'Notification sent.');
    } catch (ex) {
      return AppNotificationResponse(success: false, message: 'Error showing notification: $ex');
    }
  }

  @override
  Future<AppNotificationResponse> scheduleNotification({required String title, required String body, required DateTime scheduleTime}) async {
    try {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'channel_id',
        'channel_name',
        channelDescription: 'channel_description',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker',
      );
      const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);

      await _localNotifications.zonedSchedule(
        0, // Notification ID
        title,
        body,
        tz.TZDateTime.from(scheduleTime, tz.local), // Schedule time
        platformDetails,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );

      return AppNotificationResponse(success: true, message: 'Notification scheduled.');
    } catch (ex) {
      return AppNotificationResponse(success: false, message: 'Error scheduling notification: $ex');
    }
  }

  @override
  Future<AppNotificationResponse> cancelNotification(int id) async {
    try {
      await _localNotifications.cancel(id);
      return AppNotificationResponse(success: true, message: 'Notification canceled.');
    } catch (ex) {
      return AppNotificationResponse(success: false, message: 'Error canceling notification: $ex');
    }
  }
}

