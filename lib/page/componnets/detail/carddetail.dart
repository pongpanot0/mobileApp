import 'package:flutter/material.dart';
import 'package:lawyerapp/themes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CardDetail extends StatelessWidget {
  final double balance;
  final int cardNumber;
  final int expiredMonth;
  final int expiredYear;
  final String cardType;
  final String Balance;
  final color;

  const CardDetail(
      {super.key,
      required this.balance,
      required this.cardNumber,
      required this.expiredMonth,
      required this.expiredYear,
      required this.color,
      required this.cardType,
      required this.Balance});

  @override
  Widget build(BuildContext context) {
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Container(
        height: 100,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color,
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
                  Balance,
                  style: TextStyle(
                    color: myTheme.fontColors,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              cardType,
              style: TextStyle(
                color: myTheme.fontColors,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
