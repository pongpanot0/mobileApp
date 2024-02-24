import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:lawyerapp/page/componnets/Homepage.dart';
import 'package:lawyerapp/page/componnets/calendar.dart';
import 'package:lawyerapp/page/componnets/expenses.dart';
import 'package:lawyerapp/page/componnets/setting.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../themes.dart';

class Mainscreen extends StatefulWidget {
  final String data;
  final int screen;

  const Mainscreen({Key? key, required this.data, required this.screen});

  @override
  State<Mainscreen> createState() => _MainscreenState();
}

class _MainscreenState extends State<Mainscreen> {
  int _selectedIndex = 0;
  static const List<Widget> _widgetOptions = <Widget>[
    Homepage(),
    CalendarViewPage(),
    ExpensesPage(),
    SettingPage(),
  ];

  String message = "";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arguments = ModalRoute.of(context)!.settings.arguments;
    if (arguments != null) {
      Map? pushArguments = arguments as Map;
      setState(() {
        message = pushArguments["message"];
      });
    }
  }

  int counter = 2;
  late MyTheme myTheme = Theme2();
  String data = ""; // กำหนดค่าเริ่มต้นของ data
  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.screen;
    _loadCurrentTheme();
    if (data == "update") {
      _loadCurrentTheme();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: <Widget>[
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage(
                    'images/background.png'), // ตัวอย่าง path ของ background image
                fit: BoxFit.cover,
                opacity: 0.1),
          ),
        ),
        Container(
          child: _widgetOptions.elementAt(_selectedIndex),
        )
      ]),
      bottomNavigationBar: Container(
        color: myTheme.bottomColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20),
          child: GNav(
              duration: Duration(milliseconds: 400),
              iconSize: 24,
              backgroundColor: myTheme.bottomColor,
              color: Colors.white,
              activeColor: myTheme.fontColors,
              tabBackgroundColor: myTheme.activeColors,
              gap: 8,
              selectedIndex: _selectedIndex,
              padding: EdgeInsets.all(16),
              onTabChange: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              tabs: const [
                GButton(
                  icon: Icons.home,
                  text: 'Home',
                ),
                GButton(
                  icon: Icons.calendar_month,
                  text: 'Calendar',
                ),
                GButton(
                  icon: Icons.attach_money_rounded,
                  text: 'Expenses',
                ),
                GButton(
                  icon: Icons.settings,
                  text: 'Settings',
                ),
              ]),
        ),
      ),
    );
  }
}
