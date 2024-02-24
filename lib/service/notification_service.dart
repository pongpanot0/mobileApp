import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  void initialize() async {
    // Initialize time zone settings
    tz.initializeTimeZones();

    // Initialize local notifications plugin
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('mipmap/launcher_icon');
    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: androidInitializationSettings, iOS: null);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void sendNotification(String? message) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails("channelId", "channelName",
            importance: Importance.max,
            priority: Priority.max,
            icon: 'mipmap/launcher_icon');

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    await flutterLocalNotificationsPlugin.show(
        0, 'LawyerApp', message, notificationDetails);
  }
}
