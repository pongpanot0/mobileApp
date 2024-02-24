import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/* https://mcon-oil.mconcrete.co.th/api_lawyer */
class ApiService {
  static const String baseUrl = 'https://mcon-oil.mconcrete.co.th/api_lawyer';
  Future<void> saveToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    return token;
  }

  Future<List<dynamic>> getCase() async {
    var url = Uri.parse('$baseUrl/case/get'); // Replace with your API endpoint

    try {
      var response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Token': await getToken() ?? ""
        },
        body: jsonEncode({
          'data': 'mobile',
        }),
      );

      if (response.statusCode == 200) {
        print('Data posted successfully');
        var responseData = json.decode(response.body);
        return responseData['data'];
      } else {
        throw Exception('Failed to post data to API');
      }
    } catch (e) {
      // Handle network or server errors
      throw Exception('Exception: $e');
    }
  }

  Future<List<dynamic>> getTransactions() async {
    var url = Uri.parse(
        '$baseUrl/transactionnotification/get'); // Replace with your API endpoint

    try {
      var response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Token': "${await getToken()}" ?? ""
        },
      );

      if (response.statusCode == 200) {
        print('Data posted successfully');
        var responseData = json.decode(response.body);
        return responseData['data'];
      } else {
        throw Exception('Failed to post data to API');
      }
    } catch (e) {
      // Handle network or server errors
      throw Exception('Exception: $e');
    }
  }

  Future<dynamic> updateProfile(File imageFile) async {
    try {
      var apiUrl = '$baseUrl/update/profile'; // Replace with your API endpoint

      // Create a multipart request
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));

      // Add the image file to the request
      var fileStream = http.ByteStream(Stream.castFrom(imageFile.openRead()));
      var length = await imageFile.length();
      Map<String, String> headers = {
        "Content-type": "multipart/form-data",
        'Token': await getToken() ?? ""
      };
      var multipartFile = http.MultipartFile(
        'image',
        fileStream,
        length,
        filename: imageFile.path.split('/').last,
      );
      request.headers.addAll(headers);
      request.files.add(multipartFile);

      // Send the request
      var response = await request.send();

      // Check the response status
      if (response.statusCode == 200) {
        // Request was successful

        var responseBody = await response.stream.bytesToString();
        print('Response Body: $responseBody');

        // Optionally, you can parse the response body as JSON if applicable
        var responseData = json.decode(responseBody);

        // Handle the response accordingly

        await imageFile.delete();
        return responseData['status'];
      } else {
        // Request failed
        var errorResponse = await response.stream.bytesToString();
        print(errorResponse);
        // Handle the error response accordingly
      }
    } catch (error) {
      // Handle other errors
      print('Error uploading image: $error');
    }
  }

  Future<List<dynamic>> getProfile() async {
    var url =
        Uri.parse('$baseUrl/get/profile'); // Replace with your API endpoint

    try {
      var response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Token': "${await getToken()}" ?? ""
        },
      );

      if (response.statusCode == 200) {
        print('Data posted successfully');
        var responseData = json.decode(response.body);
        return responseData['data'];
      } else {
        throw Exception('Failed to post data to API');
      }
    } catch (e) {
      // Handle network or server errors
      throw Exception('Exception: $e');
    }
  }

  Future<dynamic> getCaseByid(int CaseID) async {
    var url =
        Uri.parse('$baseUrl/caseByid/get'); // Replace with your API endpoint

    try {
      var response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'data': CaseID,
        }),
      );

      if (response.statusCode == 200) {
        print('Data posted successfully');
        var responseData = json.decode(response.body);

        Map<dynamic, dynamic> data;

        data = {
          "data": responseData['data'],
          "caseExpenses": responseData['caseExpenses'],
          "CaseNotices": responseData['CaseNotices'],
          "caseLawyer": responseData['caseLawyer'],
          "case_plainiff": responseData['case_plainiff'],
          "case_defendant": responseData['case_defendant'],
          "timelien": responseData['timelien']
        };
        return data;
      } else {
        throw Exception('Failed to post data to API');
      }
    } catch (e) {
      // Handle network or server errors
      throw Exception('Exception: $e');
    }
  }

  Future<List<dynamic>> getExpenses() async {
    var url = Uri.parse(
        '$baseUrl/caseexpenses/get'); // Replace with your API endpoint

    try {
      var response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Token': "${await getToken()}" ?? ""
        },
        body: jsonEncode({
          'data': "mobile",
        }),
      );

      if (response.statusCode == 200) {
        print('Data posted successfully');
        var responseData = json.decode(response.body);
        return responseData['data'];
      } else {
        throw Exception('Failed to post data to API');
      }
    } catch (e) {
      // Handle network or server errors
      throw Exception('Exception: $e');
    }
  }

  Future<String> Login(
      String username, String password, String mobiletoken) async {
    var url =
        Uri.parse('$baseUrl/loginmobile'); // Replace with your API endpoint

    try {
      var response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'username': username,
          'password': password,
          'employee_mobiletoken': mobiletoken
        }),
      );

      if (response.statusCode == 200) {
        print('Data posted successfully');
        var responseData = json.decode(response.body);
        await saveToken(responseData['token']);
        return responseData['token'];
      } else {
        throw Exception('Failed to post data to API');
      }
    } catch (e) {
      // Handle network or server errors
      throw Exception('Exception: $e');
    }
  }

  Future<List<dynamic>> getTimelineType() async {
    var url = Uri.parse(
        '$baseUrl/timelinetype/get'); // Replace with your API endpoint

    try {
      var response = await http.get(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        print('Data posted successfully');
        var responseData = json.decode(response.body);

        return responseData['data'];
      } else {
        throw Exception('Failed to post data to API');
      }
    } catch (e) {
      // Handle network or server errors
      throw Exception('Exception: $e');
    }
  }

  Future<int> createtodolist(dynamic data) async {
    var url =
        Uri.parse('$baseUrl/task/create'); // Replace with your API endpoint

    try {
      var response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'data': data,
        }),
      );

      if (response.statusCode == 200) {
        print('Data posted successfully');
        var responseData = json.decode(response.body);

        return responseData['status'];
      } else {
        throw Exception('Failed to post data to API');
      }
    } catch (e) {
      print(e);
      throw Exception('Exception: $e');
    }
  }

  Future<int> updateTask(dynamic data) async {
    var url =
        Uri.parse('$baseUrl/task/update'); // Replace with your API endpoint

    try {
      var response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'data': data,
        }),
      );

      if (response.statusCode == 200) {
        print('Data posted successfully');
        var responseData = json.decode(response.body);

        return responseData['status'];
      } else {
        throw Exception('Failed to post data to API');
      }
    } catch (e) {
      // Handle network or server errors
      throw Exception('Exception: $e');
    }
  }

  Future<List<dynamic>> caseTodolist(int case_timeline_id) async {
    var url = Uri.parse('$baseUrl/task/get'); // Replace with your API endpoint

    try {
      var response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, int>{
          'data': case_timeline_id,
        }),
      );

      if (response.statusCode == 200) {
        print('Data posted successfully');
        var responseData = json.decode(response.body);

        return responseData['data'];
      } else {
        throw Exception('Failed to post data to API');
      }
    } catch (e) {
      // Handle network or server errors
      throw Exception('Exception: $e');
    }
  }

  Future<int> createcaseExpenses(dynamic data) async {
    var url = Uri.parse(
        '$baseUrl/caseexpenses/create'); // Replace with your API endpoint

    try {
      var response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Token': "${await getToken()}" ?? ""
        },
        body: jsonEncode({
          'data': data,
        }),
      );

      if (response.statusCode == 200) {
        print('Data posted successfully');
        var responseData = json.decode(response.body);

        return responseData['status'];
      } else {
        throw Exception('Failed to post data to API');
      }
    } catch (e) {
      // Handle network or server errors
      throw Exception('Exception: $e');
    }
  }

  Future<int> createcaseTimeline(dynamic data) async {
    var url = Uri.parse(
        '$baseUrl/casetimeline/create'); // Replace with your API endpoint

    try {
      var response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'data': data,
        }),
      );

      if (response.statusCode == 200) {
        print('Data posted successfully');
        var responseData = json.decode(response.body);
        print(responseData);
        return responseData['status'];
      } else {
        throw Exception('Failed to post data to API');
      }
    } catch (e) {
      // Handle network or server errors
      throw Exception('Exception: $e');
    }
  }

  Future<List<dynamic>> getexpensesType() async {
    var url =
        Uri.parse('$baseUrl/expenses/get'); // Replace with your API endpoint

    try {
      var response = await http.get(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        print('Data posted successfully');
        var responseData = json.decode(response.body);

        return responseData['data'];
      } else {
        throw Exception('Failed to post data to API');
      }
    } catch (e) {
      // Handle network or server errors
      throw Exception('Exception: $e');
    }
  }

  // Add more methods for other API calls as needed
}
