import 'package:flutter/material.dart';
import 'package:lawyerapp/firebase_options.dart';
import 'package:lawyerapp/page/Mainscreen.dart';
import 'package:lawyerapp/page/componnets/Apiservice.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  late String mobiletoken;
  void initState() {
    super.initState();
    // Initialize the mobiletoken in the initState method
    getFirebaseToken();
  }

  Future<void> getFirebaseToken() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    FirebaseMessaging messaging = FirebaseMessaging.instance;
    FirebaseMessaging.instance.getToken().then((value) {
      print("getTokenLogin :$value");

      setState(() {
        mobiletoken = value ?? "";
      });
    });
  }

  Future<void> sendDataToApi() async {
    final String username = usernameController.text;
    final String password = passwordController.text;

    try {
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      FirebaseMessaging messaging = FirebaseMessaging.instance;
      String firebaseToken = await FirebaseMessaging.instance.getToken() ?? "";
     

      String token =
          await ApiService().Login(username, password, firebaseToken ?? "");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Mainscreen(data:'ok',screen: 0,)),
      );
      // Check the response data and perform actions accordingly
      print('Login successful. Received token: $token');
    } catch (e) {
      // Handle login failure
      print('Login failed. Exception: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 0, left: 16, right: 16, bottom: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 100.0),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 200,
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.fill,
                  image: AssetImage(
                      'images/logo.png'), // Add your logo image path here
                ),
              ),
            ),
            SizedBox(height: 30.0), // Space between logo and form fields
            // Username Field
            TextField(
              controller: usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20.0), // Space between fields
            // Password Field
            TextField(
              obscureText: true,
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20.0), // Space between fields
            // Login Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shadowColor: Colors.greenAccent,
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32.0)),
                minimumSize:
                    Size(MediaQuery.of(context).size.width, 40), //////// HERE
              ),
              onPressed: () {
                sendDataToApi();
              },
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
