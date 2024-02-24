import 'dart:async';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:lawyerapp/firebase_options.dart';
import 'package:lawyerapp/page/Mainscreen.dart';
import 'package:lawyerapp/page/componnets/splashscreen.dart';
import 'package:lawyerapp/service/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:lawyerapp/page/componnets/Apiservice.dart';
import 'package:lawyerapp/page/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('User granted permission');
  } else {
    print('User declined or has not accepted permission');
  }
  FirebaseMessaging.onBackgroundMessage(_firebaseMessageingBackgroundHandler);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    // Handle foreground messages
    print("Handling a background message: ${message.notification?.body}");
    notificationService.sendNotification(message.notification?.body);
  });
  runApp(MyApp());
}

NotificationService notificationService = NotificationService();
Future<void> _firebaseMessageingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print("_FirebaseMessageBackgroundHandler: $message");
}

@pragma('vm:entry-point') //สำคัญสำหรับ Run background
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Process the message and handle notifications, etc.
  notificationService.sendNotification(message.notification?.body);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      home: FutureBuilder<String?>(
        future: ApiService().getToken(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Loading state
            return CircularProgressIndicator();
          } else if (snapshot.hasData && snapshot.data != null) {
            // Token exists, navigate to main screen
            return SplashScreen();
          } else {
            // No token, show login screen
            return LoginPage();
          }
        },
      ),
      navigatorKey: navigatorKey,
    );
  }

  String? getTokenSync() {
    SharedPreferences prefs;
    String? token;

    // Try to get the token synchronously
    try {
      prefs = SharedPreferences.getInstance() as SharedPreferences;
      token = prefs.getString('token');
    } catch (e) {
      token = null;
    }

    return token;
  }
}
