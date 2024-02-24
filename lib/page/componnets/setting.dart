import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lawyerapp/page/Mainscreen.dart';
import 'package:lawyerapp/page/componnets/Apiservice.dart';
import 'package:lawyerapp/page/login.dart';
import 'package:lawyerapp/themes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert'; // Import dart:convert library
import 'dart:typed_data';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  String base64Image = '';

  Future<void> clearToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  Future<dynamic> _uploadImageToApi(File image) async {
    try {
      final apiService = ApiService();
      int status = await apiService.updateProfile(image);
      setState(() {
        getProfile();
      });
    } catch (e) {
      print('Error: $e');
      throw e; // Rethrow the error to handle it in the caller
    }
  }

  late MyTheme myTheme;
  @override
  void initState() {
    super.initState();
    myTheme = Theme1(); // หรือใช้ธีมเริ่มต้นที่คุณต้องการ
    _loadCurrentTheme();
    getProfile();
  }

  late List<dynamic> ProfileData; // <-- Change the type here
  Future<dynamic> getProfile() async {
    try {
      final apiService = ApiService();
      dynamic profileData =
          await apiService.getProfile(); // Call your API function
      await Future.delayed(Duration(seconds: 1));
      return profileData;
    } catch (e) {
      // Handle errors
      print('Error: $e');
      throw e; // Rethrow the error to handle it in the caller
    }
  }

  _loadCurrentTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? themeName = prefs.getString('current_theme');
    setState(() {
      if (themeName == 'theme1') {
        myTheme = Theme1();
      } else if (themeName == 'theme2') {
        myTheme = Theme2();
      } else if (themeName == 'theme3') {
        myTheme = Theme3();
      } else if (themeName == 'theme4') {
        myTheme = Theme4();
      }
    });
  }

  _switchTheme(MyTheme newTheme) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      myTheme = newTheme;
      if (newTheme is Theme1) {
        prefs.setString('current_theme', 'theme1');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Mainscreen(data: 'update', screen: 3),
          ),
        );
      } else if (newTheme is Theme2) {
        prefs.setString('current_theme', 'theme2');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Mainscreen(data: 'update', screen: 3),
          ),
        );
      } else if (newTheme is Theme3) {
        prefs.setString('current_theme', 'theme3');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Mainscreen(data: 'update', screen: 3),
          ),
        );
      } else if (newTheme is Theme4) {
        prefs.setString('current_theme', 'theme4');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Mainscreen(data: 'update', screen: 3),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Uint8List bytes = base64.decode(base64Image);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            scale: 1.7,
            alignment: Alignment.center,
            opacity: 0.1,
            image: AssetImage(
              'images/newbackground.png',
            ), // Replace with your image URL
            fit: BoxFit.contain,
          ),
        ),
        child: Stack(
          children: [
            FutureBuilder(
                future: getProfile(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  } else {
                    var dataArray = snapshot.data as List<dynamic>;

                    return Positioned(
                      top: MediaQuery.of(context).size.height / 2 -
                          350.0, // Adjust as needed
                      left: MediaQuery.of(context).size.width / 2 -
                          180.0, // Adjust as needed
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.amber
                                    .shade200, // Set the border color for the CircleAvatar
                                width:
                                    2.0, // Set the border width for the CircleAvatar
                              ),
                            ),
                            child: GestureDetector(
                              onTap: () {
                                _pickImageFromGallery(); // Call the method to pick an image from the gallery
                              },
                              child: CircleAvatar(
                                radius: 100.0,
                                backgroundImage:
                                    dataArray[0]['employee_pic'] != null
                                        ? MemoryImage(
                                            base64Decode(
                                                dataArray[0]['employee_pic']),
                                          )
                                        : MemoryImage(
                                            base64Decode(
                                                "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"),
                                          ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          GestureDetector(
                            onTap: () {
                              _showColorInfo();
                            },
                            child: Container(
                                height: 70,
                                width: MediaQuery.of(context).size.width / 1.1,
                                padding: EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: myTheme.cardColors,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("เลือกธีม",
                                            style: TextStyle(
                                                fontSize: 18,
                                                color: myTheme.cardfontColors)),
                                      ],
                                    ),
                                  ],
                                )),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                              height: 100,
                              width: MediaQuery.of(context).size.width / 1.1,
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: myTheme.cardColors,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                          "${dataArray[0]['employee_firstname']} ${dataArray[0]['employee_lastname']}",
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: myTheme.cardfontColors)),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("${dataArray[0]['employee_email']}",
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: myTheme.cardfontColors)),
                                    ],
                                  ),
                                ],
                              )),
                          SizedBox(
                            height: 20,
                          ),
                          Container(
                              height: 70,
                              width: MediaQuery.of(context).size.width / 1.1,
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: myTheme.cardColors,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      clearToken();
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => LoginPage()),
                                      );
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "LogOut",
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: myTheme.cardfontColors),
                                        ),
                                        Icon(
                                          Icons.logout_outlined,
                                          color: myTheme.cardfontColors,
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              )),
                          SizedBox(
                            height: 20,
                          ),
                          Container(
                              height: 70,
                              width: MediaQuery.of(context).size.width / 1.1,
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: myTheme.danger,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Delete Account",
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: myTheme.fontColors),
                                      ),
                                      Icon(
                                        Icons.delete_sweep_outlined,
                                        size: 30,
                                        color: myTheme.fontColors,
                                      )
                                    ],
                                  ),
                                ],
                              )),
                        ],
                      ),
                    );
                  }
                }),
            // Centered Circular Image
          ],
        ),
      ),
    );
  }

  _showColorInfo() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height,
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Theme1"),
                  GestureDetector(
                    onTap: () => _switchTheme(Theme1()),
                    child: Card(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Theme1().cardColors,
                                border:
                                    Border.all(color: Colors.black, width: 1)),
                            child: myTheme == Theme1()
                                ? Icon(Icons.check, color: Colors.white)
                                : null,
                          ),
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Theme1().cardTabColors,
                                border:
                                    Border.all(color: Colors.black, width: 1)),
                            child: myTheme == Theme1()
                                ? Icon(Icons.check, color: Colors.white)
                                : null,
                          ),
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Theme1().activeColors,
                                border:
                                    Border.all(color: Colors.black, width: 1)),
                            child: myTheme == Theme1()
                                ? Icon(Icons.check, color: Colors.white)
                                : null,
                          ),
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Theme1().bottomColor,
                                border:
                                    Border.all(color: Colors.black, width: 1)),
                            child: myTheme == Theme1()
                                ? Icon(Icons.check, color: Colors.white)
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  Text("Theme2"),
                  GestureDetector(
                    onTap: () => _switchTheme(Theme2()),
                    child: Card(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Theme2().cardColors,
                                border:
                                    Border.all(color: Colors.black, width: 1)),
                            child: myTheme == Theme2()
                                ? Icon(Icons.check, color: Colors.white)
                                : null,
                          ),
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Theme2().cardTabColors,
                                border:
                                    Border.all(color: Colors.black, width: 1)),
                            child: myTheme == Theme2()
                                ? Icon(Icons.check, color: Colors.white)
                                : null,
                          ),
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Theme2().activeColors,
                                border:
                                    Border.all(color: Colors.black, width: 1)),
                            child: myTheme == Theme2()
                                ? Icon(Icons.check, color: Colors.white)
                                : null,
                          ),
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Theme2().bottomColor,
                                border:
                                    Border.all(color: Colors.black, width: 1)),
                            child: myTheme == Theme2()
                                ? Icon(Icons.check, color: Colors.white)
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  Text("Theme3"),
                  GestureDetector(
                    onTap: () => _switchTheme(Theme3()),
                    child: Card(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Theme3().cardColors,
                                border:
                                    Border.all(color: Colors.black, width: 1)),
                            child: myTheme == Theme3()
                                ? Icon(Icons.check, color: Colors.white)
                                : null,
                          ),
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Theme3().cardTabColors,
                                border:
                                    Border.all(color: Colors.black, width: 1)),
                            child: myTheme == Theme3()
                                ? Icon(Icons.check, color: Colors.white)
                                : null,
                          ),
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Theme3().activeColors,
                                border:
                                    Border.all(color: Colors.black, width: 1)),
                            child: myTheme == Theme3()
                                ? Icon(Icons.check, color: Colors.white)
                                : null,
                          ),
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Theme3().bottomColor,
                                border:
                                    Border.all(color: Colors.black, width: 1)),
                            child: myTheme == Theme3()
                                ? Icon(Icons.check, color: Colors.white)
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  Text("Theme4"),
                  GestureDetector(
                    onTap: () => _switchTheme(Theme4()),
                    child: Card(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Theme4().cardColors,
                                border:
                                    Border.all(color: Colors.black, width: 1)),
                            child: myTheme == Theme4()
                                ? Icon(Icons.check, color: Colors.white)
                                : null,
                          ),
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Theme4().cardTabColors,
                                border:
                                    Border.all(color: Colors.black, width: 1)),
                            child: myTheme == Theme4()
                                ? Icon(Icons.check, color: Colors.white)
                                : null,
                          ),
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Theme4().activeColors,
                                border:
                                    Border.all(color: Colors.black, width: 1)),
                            child: myTheme == Theme4()
                                ? Icon(Icons.check, color: Colors.white)
                                : null,
                          ),
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Theme4().bottomColor,
                                border:
                                    Border.all(color: Colors.black, width: 1)),
                            child: myTheme == Theme4()
                                ? Icon(Icons.check, color: Colors.white)
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _pickImageFromGallery() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxHeight: 1000,
      maxWidth: 1000,
      imageQuality: 40,
    );
    if (image != null) {
      // Convert the XFile to File
      File pickedFile = File(image.path);

      // Upload the image to the API
      _uploadImageToApi(pickedFile);
    } else {
      print('No image selected.');
    }
  }
}
