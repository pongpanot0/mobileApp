import 'package:flutter/material.dart';
import 'package:lawyerapp/page/componnets/Apiservice.dart';
import 'package:lawyerapp/page/componnets/customerappbar.dart';
import 'package:lawyerapp/page/componnets/detail/casedetail.dart';
import 'package:lawyerapp/page/componnets/restaurant_info.dart';
import 'package:intl/intl.dart';
import 'package:lawyerapp/themes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class User {
  final String tsb_ref;
  final String rednum;
  final String blacknum;
  final String DuedateSummittree;
  final String Customer_ref;
  final String ClientName;
  final String CaseTypeName;
  final int CaseID;
  final String timeline_status_name;
  final String case_timebar_incoming;
  const User(
      {required this.tsb_ref,
      required this.rednum,
      required this.blacknum,
      required this.DuedateSummittree,
      required this.Customer_ref,
      required this.ClientName,
      required this.CaseTypeName,
      required this.CaseID,
      required this.timeline_status_name,
      required this.case_timebar_incoming});
}

class _HomepageState extends State<Homepage> {
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    fetchData();
    _loadCurrentTheme();
    getProfile();
    super.initState();
  }

  List<dynamic> NotifyArray = [];
  int NotifyCount = 0;
  Future<int> NotifyCountFetct() async {
    try {
      final apiService = ApiService();
      NotifyArray =
          await apiService.getTransactions(); // Call your API function
      int notifyCount = NotifyArray.where((notification) =>
          notification['transaction_notification_isread'] == 0).length;
    
      return notifyCount;
    } catch (e) {
      // Handle errors
      print('Error: $e');
      return 0; // Return an empty list or modify according to your use case
    }
  }

  List<User> users = [];
  Future<List<User>> fetchData() async {
    try {
      final apiService = ApiService();
      await Future.delayed(Duration(seconds: 1));
      List<dynamic> apiData =
          await apiService.getCase(); // Call your API function

      // Transform apiData into a list of User objects
      List<User> users = apiData.map((data) {
        return User(
          tsb_ref: data['tsb_ref'] ?? '',
          rednum: data['rednum'] ?? '',
          blacknum: data['blacknum'] ?? '',
          DuedateSummittree: data['DuedateSummittree'] ?? '',
          Customer_ref: data['Customer_ref'] ?? '',
          ClientName: data['ClientName'] ?? '',
          CaseTypeName: data['CaseTypeName'] ?? '',
          CaseID: data['CaseID'] ?? 1,
          timeline_status_name: data['timeline_status_name'] ?? '',
          case_timebar_incoming: data['case_timebar_incoming'] ?? '',
        );
      }).toList();
  _loadCurrentTheme();
      return users; // Return the list of User objects
    } catch (e) {
      // Handle errors
      print('Error: $e');
      // Return an empty list if there's an error
      return [];
    }
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

  int _currentSegmentIndex = 0;
  final Map<int, Widget> _children = {
    0: Text('Type 1'), // Replace with your desired text or widget.
    1: Text('Type 2'), // Replace with your desired text or widget.
    // Add more segments as needed.
  };
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
        children: [
          SizedBox(
            height: 10,
          ),
          FutureBuilder<dynamic>(
              future: NotifyCountFetct(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center();
                }
                return CustomAppBar(
                    leftIcon: Icons.home,
                    rightIcon: Icons.notifications,
                    NotifyCount: snapshot.data!);
              }),
          FutureBuilder<dynamic>(
            future: getProfile(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center();
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              } else {
                dynamic profileData = snapshot.data!;

                return RestaurantInfo(ProfileData: profileData);
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                /*   SingleChoice() */
                // Add more buttons as needed
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<User>>(
              future:
                  fetchData(), // Call the function that fetches your data asynchronously
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child:
                        CircularProgressIndicator(), // Show a loading indicator while waiting for data
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                        'Error: ${snapshot.error}'), // Show an error message if data fetching fails
                  );
                } else {
                  List<User> users = snapshot.data ??
                      []; // Retrieve the list of users from the snapshot

                  return Container(
                    child: Stack(
                      children: [
                        ListView.builder(
                          itemCount: users.length,
                          itemBuilder: (BuildContext context, int index) {
                            String incomingDateString =
                                users[index].case_timebar_incoming ??
                                    "2024-01-24 00:00:00.000";

                            DateTime incomingDate = DateTime.parse(
                                incomingDateString); // Assuming incomingDateString is in a parseable format

                            String formattedDate =
                                DateFormat('dd-MM-yyyy').format(incomingDate!);
                            return Padding(
                              padding: const EdgeInsets.only(
                                  top: 0, bottom: 20, left: 8, right: 8),
                              child: Card(
                                color: myTheme.cardTabColors,
                                elevation: 4.0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                                child: ListTile(
                                  dense: true,
                                  title: Row(
                                    children: [
                                      Icon(Icons
                                          .add_circle_rounded), // Change this to the desired icon
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text(users[index].tsb_ref),
                                      Spacer(), // Add Spacer to push the icon to the right
                                    ],
                                  ),
                                  subtitle: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                          '${users[index].timeline_status_name}'),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                          'กำหนดการครั้งถัดไปวันที่ ${formattedDate}'),
                                      SizedBox(
                                        height: 5,
                                      ),
                                    ],
                                  ),
                                  trailing: Icon(
                                      Icons.arrow_forward), // ตัวอย่าง icon
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => CaseDetail(
                                              CaseID: users[index].CaseID)),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildSegmentedControlButton(int index, String text) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _currentSegmentIndex = index;
        });
      },
      style: ElevatedButton.styleFrom(
        primary: _currentSegmentIndex == index
            ? Colors.blue // Active color
            : Colors.grey, // Inactive color
      ),
      child: Text(text),
    );
  }
}

enum Calendar { day, week, month, year }

class SingleChoice extends StatefulWidget {
  const SingleChoice({super.key});

  @override
  State<SingleChoice> createState() => _SingleChoiceState();
}

class _SingleChoiceState extends State<SingleChoice> {
  Calendar calendarView = Calendar.day;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 1.1,
      child: SegmentedButton<Calendar>(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color?>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.selected)) {
                return Color.fromARGB(255, 108, 120, 255);
              }
              return null; // Use the component's default.
            },
          ),
        ),
        segments: const <ButtonSegment<Calendar>>[
          ButtonSegment<Calendar>(
              value: Calendar.day,
              label: Text('คดีที่ฟ้อง'),
              icon: Icon(Icons.calendar_view_day)),
          ButtonSegment<Calendar>(
            value: Calendar.week,
            label: Text('คดีที่ถูกฟ้อง'),
            icon: Icon(Icons.calendar_view_week),
          ),
        ],
        selected: <Calendar>{calendarView},
        onSelectionChanged: (Set<Calendar> newSelection) {
          setState(() {
            // By default there is only a single segment that can be
            // selected at one time, so its value is always the first
            // item in the selected set.
            calendarView = newSelection.first;
          });
        },
      ),
    );
  }
}
