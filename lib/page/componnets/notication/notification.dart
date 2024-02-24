import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lawyerapp/page/Mainscreen.dart';
import 'package:lawyerapp/page/componnets/Apiservice.dart';
import 'package:lawyerapp/themes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    fetchData();
    super.initState();
    _loadCurrentTheme();
  }

  late MyTheme myTheme = Theme2();

  _loadCurrentTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? themeName = prefs.getString('current_theme');

    if (themeName == 'theme1') {
      myTheme = Theme1();
    } else if (themeName == 'theme2') {
      myTheme = Theme2();
    } else if (themeName == 'theme3') {
      myTheme = Theme3();
    } else if (themeName == 'theme4') {
      myTheme = Theme4();
    }
  }

  List<dynamic> apiData = [];
  Future<List<dynamic>> fetchData() async {
    try {
      final apiService = ApiService();
      await Future.delayed(Duration(seconds: 2));
      apiData = await apiService.getTransactions(); // Call your API function

      return apiData;
    } catch (e) {
      // Handle errors
      print('Error: $e');
      return []; // Return an empty list or modify according to your use case
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
        future: _loadCurrentTheme(),
        builder: (context, snapshot) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: myTheme.cardColors,
              title: Text('Notifications'),
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                        builder: (context) => Mainscreen(
                              data: 'ok',
                              screen: 0,
                            )),
                  );
                },
              ),
            ),
            body: FutureBuilder(
              future:
                  fetchData(), // Replace `fetchData()` with your function that returns a Future containing your data
              builder: (context, snapshot) {
                print(snapshot);
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else {
                  final List<dynamic> notificationData = snapshot.data!;
                  final List<Widget> notificationWidgets = [];

                  // Loop through the data and categorize notifications based on the isread status
                  List<Map<String, dynamic>> unreadNotifications = [];
                  List<Map<String, dynamic>> readNotifications = [];

                  // Separate notifications based on read status
                  for (var notification in notificationData) {
                    if (notification['transaction_notification_isread'] == 0) {
                      unreadNotifications.add(notification);
                    } else {
                      readNotifications.add(notification);
                    }
                  }

                  // Add widgets for unread notifications
                  if (unreadNotifications.isNotEmpty) {
                    notificationWidgets.add(_buildNotificationGroup(
                        'ยังไม่ได้อ่าน', unreadNotifications, context));
                  }

                  // Add widgets for read notifications
                  if (readNotifications.isNotEmpty) {
                    notificationWidgets.add(_buildNotificationGroup(
                        'อ่านแล้ว', readNotifications, context));
                  }

                  return ListView(
                    children: notificationWidgets,
                  );
                }
              },
            ),
          );
        });
    ;
  }

  Widget _buildNotificationGroup(
      String title, List<dynamic> notifications, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            elevation: 4,
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
              width: MediaQuery.of(context).size.width,
              child: Text(
                title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        Column(
          children: notifications.map((notification) {
            return _buildNotificationItem(notification, context);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildNotificationItem(dynamic notification, BuildContext context) {
    String messageText = '';
    // Customize the layout for each notification item here
    if (notification['transaction_notification_isbeforeecase'] != null &&
        notification['transaction_notification_isbeforeecase'] == 1) {
      messageText = 'มีการเพิ่มก่อนฟ้องใหม่';
    }
    // Check if transaction_notification_isexpenses is 1
    else if (notification['transaction_notification_isexpenses'] != null &&
        notification['transaction_notification_isexpenses'] == 1) {
      messageText = 'มีการเพิ่มค่าใช้จ่ายใหม่';
    } else {
      messageText = notification['message'] ?? "";
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 2,
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
          width: MediaQuery.of(context).size.width,
          child: Text(
            messageText, // Exam,ple: Accessing message from notification data
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
