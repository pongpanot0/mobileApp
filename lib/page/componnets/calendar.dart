import 'package:flutter/material.dart';
import 'package:lawyerapp/page/componnets/Apiservice.dart';
import 'package:lawyerapp/page/componnets/customerappbar.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:intl/intl.dart';

class CalendarViewPage extends StatefulWidget {
  const CalendarViewPage({super.key});

  @override
  State<CalendarViewPage> createState() => _CalendarViewPageState();
}

class _CalendarViewPageState extends State<CalendarViewPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now(); // Initialize with a default value
  Map<DateTime, List<dynamic>> _events = {};
  late Future<List<dynamic>> _calendarDataFuture;
  @override
  void initState() {
    _calendarDataFuture = fetchData();
    super.initState();
  }

  List<dynamic> apiData = [];
  Future<List<dynamic>> fetchData() async {
    try {
      final apiService = ApiService();
      await Future.delayed(Duration(seconds: 2));
      apiData = await apiService.getCase(); // Call your API function

      return apiData;
    } catch (e) {
      // Handle errors
      print('Error: $e');
      return []; // Return an empty list or modify according to your use case
    }
  }

  @override
  void dispose() {
    _calendarDataFuture;
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
          children: [
            SizedBox(
              height: 20,
            ),
            FutureBuilder(
                future: _calendarDataFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // If the Future is still loading, show a loading indicator
                    return Expanded(
                        child: Center(
                            child: CircularProgressIndicator.adaptive()));
                  } else if (snapshot.hasError) {
                    // If the Future throws an error, show an error message
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    // If the Future completes successfully but with no data, show a message
                    return Text('No calendar data found.');
                  } else {
                    return SfCalendar(
                      view: CalendarView.month,
                      dataSource: _getCalendarDataSource(snapshot.data!),
                      backgroundColor: Colors.grey.shade100,
                      onTap: (CalendarTapDetails details) {
                        if (details.targetElement ==
                            CalendarElement.calendarCell) {
                          DateTime selectedDate = details.date!;
                          List<dynamic> eventsOnSelectedDate =
                              _getEventsOnDate(selectedDate, snapshot.data!);
                          showModalBottomSheet(
                            context: context,
                            builder: (context) {
                              return Container(
                                padding: EdgeInsets.all(16.0),
                                child: ListView(
                                  children: [
                                    Text(
                                      'กิจกรรมประจำวัน ${formatDateString(selectedDate.toString())}',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 10),
                                    // Display events for the selected date
                                    ...eventsOnSelectedDate.map((event) {
                                      return Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        child: ListTile(
                                          title: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'สิ่งที่ต้องทำ : ' +
                                                    event[
                                                        'timeline_status_name'],
                                                style: TextStyle(
                                                    color: Colors.black),
                                              ),
                                              SizedBox(height: 15),
                                              Text(
                                                'ลูกค้า : ' +
                                                    event['ClientName'],
                                                style: TextStyle(
                                                    color: Colors.black),
                                              ),
                                              SizedBox(height: 15),
                                              Text(
                                                'ประเภทคดี : ${event['CaseTypeName']}',
                                                style: TextStyle(
                                                    color: Colors.black),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ],
                                ),
                              );
                            },
                          );
                        }
                      },
                    );
                  }
                }),
          ],
        ),
      ),
    );
  }

  String formatDateString(String dateString) {
    // Parse the input date string
    DateTime dateTime = DateTime.parse(dateString);

    // Format the date using intl package
    String formattedDate = DateFormat('dd/MM/yyyy').format(dateTime);

    return formattedDate;
  }

  _DataSource _getCalendarDataSource(List<dynamic> data) {
    List<Appointment> appointments = [];

    // Convert your API data to appointments

    for (var data in apiData) {
      DateTime startTime = DateTime.parse(data['newDate']);
      appointments.add(Appointment(
          startTime: startTime,
          endTime: startTime.add(Duration(minutes: 1)), // Adjust as needed
          subject: data['newDate'],
          isAllDay: true));
    }

    return _DataSource(appointments);
  }

  List<dynamic> _getEventsOnDate(DateTime date, List<dynamic> data) {
    return apiData
        .where((event) =>
            DateTime.parse(event['newDate']).year == date.year &&
            DateTime.parse(event['newDate']).month == date.month &&
            DateTime.parse(event['newDate']).day == date.day)
        .toList();
  }
}

class _DataSource extends CalendarDataSource {
  _DataSource(List<Appointment> source) {
    appointments = source;
  }
}
