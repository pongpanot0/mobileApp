import 'package:flutter/material.dart';
import 'package:flutter_echarts/flutter_echarts.dart';
import 'package:lawyerapp/page/componnets/Apiservice.dart';
import 'package:lawyerapp/page/componnets/Card.dart';
import 'package:lawyerapp/page/componnets/customerappbar.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:async';
import 'package:flutter_holo_date_picker/flutter_holo_date_picker.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:lawyerapp/themes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExpensesPage extends StatefulWidget {
  const ExpensesPage({super.key});

  final Color leftBarColor = Colors.yellow;
  final Color rightBarColor = Colors.red;
  final Color avgColor = Colors.redAccent;
  @override
  State<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> {
  List<dynamic> apiData = [];
  int paidtye = 1;

  Color color = Colors.grey;
  DateTime? selectedDate;
  int? selectPayID;
  int? selectPaidType;
  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    fetchData(1);
    getexpensesType();
    _loadCurrentTheme();
    super.initState();
  }

  TextEditingController textController = TextEditingController();
  TextEditingController textController2 = TextEditingController();
  List<Map<String, dynamic>> paid_typeDAta = [
    {'paid_type': 1, 'timeline_status_name': 'โอนให้ก่อน'},
    {'paid_type': 2, 'timeline_status_name': 'รอตั้งเบิก'},
  ];

  Future<void> postData(String textController, String textController2,
      String selectedDate, int selectPayID, int selectPaidType) async {
    try {
      var data = {
        "Payer": 'mobile',
        "PaymentDate": selectedDate,
        "expensesType": selectPayID,
        "expenses_ref": textController2,
        "expenses": textController,
        "paid_type": selectPaidType,
      };
      final apiService = ApiService();

      var response = await apiService.createcaseExpenses(data);

      fetchData(selectPaidType);
    } catch (e) {
      print(e);
    }
  }

  late List<dynamic> expensesType; // <-- Change the type here
  Future<void> getexpensesType() async {
    final apiService = ApiService();
    var response = await apiService.getexpensesType();

    try {
      // Assuming your API response is a List<Map<String, dynamic>>

      setState(() {
        expensesType = response;
      });
    } catch (e) {
      print('Error parsing API response: $e');
      throw Exception('Error fetching timeline types');
    }
  }

  late MyTheme myTheme = Theme2();

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
      } else if (newTheme is Theme2) {
        prefs.setString('current_theme', 'theme2');
      } else if (newTheme is Theme3) {
        prefs.setString('current_theme', 'theme3');
      }
    });
  }

  Color getButtonColor() {
    // Set the button color based on the paidType value
    return paidtye == 1 ? myTheme.bottomColor : myTheme.activeColors;
  }

  Color getButtonColor2() {
    // Set the button color based on the paidType value
    return paidtye == 2 ? myTheme.bottomColor : myTheme.activeColors;
  }

  double sumExpenses = 0.0; // Use double for sum

  Future<void> fetchData(int paidType) async {
    try {
      final apiService = ApiService();
      apiData = await apiService.getExpenses(); // Call your API function
      List<dynamic> fetchedData =
          await apiService.getExpenses(); // Fetch new data

      if (!mounted)
        return; // Check if the widget is still mounted before calling setState

      setState(() {
        // Update the state inside setState

        apiData =
            fetchedData.where((data) => data['paid_type'] == paidType).toList();
        paidtye = paidType;
        sumExpenses = 0.0;
        for (Map<String, dynamic> data in apiData) {
          if (data.containsKey('expenses')) {
            sumExpenses += data['expenses'].toDouble();
          }
        }
      });
    } catch (e) {
      // Handle errors
      print('ja $e');
    }
  }

  @override
  void dispose() {
    // Cancel the timer to avoid memory leaks

    fetchData(1);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 10,
            ),
            Container(
              height: 245,
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 20,
                  ),
                  Expanded(
                    child: Container(
                      height: 150, // Fixed height for MyCard
                      child: MyCard(
                        balance: sumExpenses,
                        cardNumber: 10,
                        expiredMonth: 10,
                        expiredYear: 2025,
                        color: myTheme.cardColors,
                        cardType: "ATM",
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox.fromSize(
                        size: Size(150, 56), // button width and height
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20.0),
                          child: Material(
                            color: getButtonColor(), // button color
                            child: InkWell(
                              autofocus: true,
                              onTap: () {
                                fetchData(1); // Pass the paid_type value
                                color = Colors.red;
                              },
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(Icons.money_off,
                                      color: Colors.white), // icon
                                  Text(
                                    "รอตั้งเบิก",
                                    style: TextStyle(color: Colors.white),
                                  ), // text
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox.fromSize(
                        size: Size(150, 56), // button width and height
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20.0),
                          child: Material(
                            color: getButtonColor2(), // button color
                            child: InkWell(
                              splashColor: Colors.green, // splash color

                              onTap: () {
                                fetchData(2); // Pass the paid_type value
                              }, // button pressed
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(
                                    Icons.money,
                                    color: Colors.white,
                                  ), // icon
                                  Text("เบิกล่วงหน้า",
                                      style: TextStyle(
                                          color: Colors.white)), // text
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              child: Expanded(
                child: ListView.builder(
                  itemCount: apiData.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.only(
                          left: 8.0, right: 8.0, top: 5, bottom: 5),
                      child: Card(
                        color: myTheme.cardTabColors,
                        elevation: 4.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        child: ListTile(
                          title: Text(apiData[index]['expensesType_name']),
                          subtitle: Text(
                            NumberFormat.currency(
                                    locale: 'en_US', symbol: '\$ ')
                                .format(apiData[index]['expenses']),
                          ),
                          onTap: () {
                            // ทำงานเมื่อ Card ถูกแตะ
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: 50)
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: myTheme.cardColors,
        onPressed: () {
          _showDialog(context);
        },
        label: const Text('เพิ่มค่าใช้จ่าย',
            style: TextStyle(color: MyTheme.colorHex)),
        icon: const Icon(Icons.add, color: MyTheme.colorHex, size: 25),
      ),
    );
  }

  void _showDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      StatefulBuilder(builder: (context, setState) {
                        return DropdownButtonHideUnderline(
                          child: DropdownButton2<int?>(
                            isExpanded: true,
                            hint: Text('ประเภทค่าใช้จ่าย'),
                            value: selectPayID,
                            onChanged: (int? newValue) {
                              setState(() {
                                selectPayID = newValue ?? 1;
                              });
                            },
                            items: expensesType.map((timeline) {
                              return DropdownMenuItem<int?>(
                                value: timeline['expensesType_id'],
                                child: Text(timeline['expensesType_name']),
                              );
                            }).toList(),
                          ),
                        );
                      }),
                      SizedBox(
                        height: 20,
                      ),
                      StatefulBuilder(builder: (context, setState) {
                        return DropdownButtonHideUnderline(
                          child: DropdownButton2<int?>(
                            isExpanded: true,
                            hint: Text('ประเภทการเบิก'),
                            value: selectPaidType,
                            onChanged: (int? newValue) {
                              setState(() {
                                selectPaidType = newValue; // Set the new value
                              });
                            },
                            items: paid_typeDAta.map((timeline) {
                              return DropdownMenuItem<int?>(
                                value: timeline['paid_type'],
                                child: Text(timeline['timeline_status_name']),
                              );
                            }).toList(),
                          ),
                        );
                      }),
                      StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) {
                          return Container(
                            width: MediaQuery.of(context).size.width,
                            child: ElevatedButton(
                              onPressed: () async {
                                var datePicked = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2090),
                                );

                                if (datePicked != null) {
                                  setState(() {
                                    selectedDate = datePicked;
                                  });
                                }
                              },
                              child: Text(
                                '${selectedDate != null ? DateFormat('dd-MM-yyyy').format(selectedDate!) : 'วันที่จ่ายเงิน'}',
                              ),
                            ),
                          );
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: textController,
                          decoration: InputDecoration(labelText: 'ค่าใช่จ่าย'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: textController2,
                          decoration: InputDecoration(labelText: 'REF'),
                        ),
                      ),
                      Container(
                        color: Colors.grey,
                        width: MediaQuery.of(context).size.width,
                        child: TextButton(
                          onPressed: () {
                            // Perform actions with
                            //prithe selected values

                            postData(
                                textController.text,
                                textController2.text,
                                selectedDate.toString(),
                                selectPayID ?? 1,
                                selectPaidType ?? 1);
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'ตกลง',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
