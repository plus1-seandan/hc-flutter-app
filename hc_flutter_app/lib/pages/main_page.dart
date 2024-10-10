import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:namer_app/auth.dart';

class HouseChurchPage extends StatefulWidget {
  @override
  _HouseChurchPageState createState() => _HouseChurchPageState();
}

class _HouseChurchPageState extends State<HouseChurchPage> {
  String location = 'Loading...';
  String dateTime = 'Loading...';

  Future<void> signOut() async {
    await Auth().signOut();
  }

  Widget _signoutButton() {
    return ElevatedButton(onPressed: signOut, child: const Text('Sign Out'));
  }

  @override
  void initState() {
    super.initState();
    fetchHouseChurchDetails();
  }

  Future<void> fetchHouseChurchDetails() async {
    try {
      final response = await http.get(
          Uri.parse('http://192.168.1.74:8000/api/hostingSchedule/getLatest'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          location = data['latestHostingSchedule']?['memberId']?['address'] ??
              'Unknown Address';
          var dateTimeDate =
              DateTime.parse(data['latestHostingSchedule']?['date']);
          String formattedDate =
              DateFormat('MMMM d, yyyy').format(dateTimeDate);
          dateTime = formattedDate;
        });
      } else {
        setState(() {
          location = 'Failed to load location';
          dateTime = 'Failed to load date & time';
        });
      }
    } catch (error) {
      setState(() {
        location = 'Error loading location';
        dateTime = 'Error loading date & time';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('House Church This Week'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'House Church Location:',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    Text(
                      location,
                      style: TextStyle(fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Date & Time:',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    Text(
                      dateTime,
                      style: TextStyle(fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                    _signoutButton()
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
