import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lawyerapp/themes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyCard extends StatefulWidget {
  final double balance;
  final int cardNumber;
  final int expiredMonth;
  final int expiredYear;
  final String cardType;
  final color;

  const MyCard({
    super.key,
    required this.balance,
    required this.cardNumber,
    required this.expiredMonth,
    required this.expiredYear,
    required this.color,
    required this.cardType,
  });

  @override
  State<MyCard> createState() => _MyCardState();
}

class _MyCardState extends State<MyCard> {
  late MyTheme myTheme = Theme2();

  @override
  void initState() {
    _loadCurrentTheme();
    super.initState();
  }

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

  _switchTheme(MyTheme newTheme) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    myTheme = newTheme;
    if (newTheme is Theme1) {
      prefs.setString('current_theme', 'theme1');
    } else if (newTheme is Theme2) {
      prefs.setString('current_theme', 'theme2');
    } else if (newTheme is Theme3) {
      prefs.setString('current_theme', 'theme3');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        height: 180,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "จำนวนเงิน",
                  style: TextStyle(color: myTheme.cardfontColors, fontSize: 28),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              NumberFormat.currency(locale: 'en_US', symbol: '\$ ')
                  .format(widget.balance),
              style: TextStyle(
                color: myTheme.cardfontColors,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
