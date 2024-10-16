import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:namer_app/auth.dart';
import 'package:namer_app/configs/api_configs.dart';
import 'package:namer_app/widgets/app_drawer.dart';

class HouseChurchPage extends StatefulWidget {
  @override
  _HouseChurchPageState createState() => _HouseChurchPageState();
}

class _HouseChurchPageState extends State<HouseChurchPage> {
  String location = 'Loading...';
  String dateTime = 'Loading...';
  String hostName = 'Loading...';
  String scheduleId = "";
  final User? user = Auth().currentUser;
  List<Map<String, dynamic>> houseChurchAttendance = [];
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchHouseChurchDetails();
  }

  Future<void> fetchHouseChurchDetails() async {
    try {
      final response = await http.get(
          Uri.parse('${ApiConfig.baseUrl}/api/hostingSchedule/${user?.email}'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          scheduleId = data['latestHostingSchedule']?['_id'];
          location = data['latestHostingSchedule']?['hostId']?['address'] ??
              'Unknown Address';
          var dateTimeDate =
              DateTime.parse(data['latestHostingSchedule']?['date']);
          String formattedDate =
              DateFormat('MMMM d, yyyy').format(dateTimeDate);
          dateTime = formattedDate;
          hostName = data['latestHostingSchedule']?['hostId']?['name'] ??
              'Unknown Host';
          houseChurchAttendance = List<Map<String, dynamic>>.from(
            data['houseChurchAttendance'].map((member) => {
                  'memberId': member['memberId'],
                  'name': member['name'],
                  'isAttending': member['isAttending']
                }),
          );
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

  Future<void> updateAttendance(
      String scheduleId, String memberId, bool isAttending) async {
    final url = Uri.parse(
        '${ApiConfig.baseUrl}/api/hostingSchedule/attendance/$scheduleId');

    try {
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'isAttending': isAttending,
          'attendeeId': memberId,
        }),
      );

      if (response.statusCode == 200) {
        print('Attendance updated successfully');
      } else {
        print('Failed to update attendance: ${response.statusCode}');
      }
    } catch (error) {
      print('Error updating attendance: $error');
    }
  }

  Widget buildAttendanceList() {
    print({'houseChurchAttendance': houseChurchAttendance});
    return ListView.builder(
      shrinkWrap: true,
      itemCount: houseChurchAttendance.length,
      itemBuilder: (context, index) {
        final member = houseChurchAttendance[index];
        return ListTile(
          title: Text(member['name']),
          trailing: Switch(
            value: member['isAttending'],
            onChanged: (bool value) async {
              setState(() {
                member['isAttending'] = value; // Update local state first
              });
              // Await the updateAttendance function
              await updateAttendance(scheduleId, member['memberId'], value);
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('House Church This Week'),
      ),
      drawer: AppDrawer(
        selectedIndex: _selectedIndex,
        onItemTapped: (index) {
          setState(() {
            _selectedIndex = index;
          });
          // Close the drawer after selection
          Navigator.pop(context);
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
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
                      'Hosted By:',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      hostName, // Make sure to replace this with the actual variable that holds the host's name
                      style: TextStyle(fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    SizedBox(height: 20),
                    Text(
                      'Date:',
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
                  ],
                ),
              ),
            ),
            SizedBox(height: 20), // Spacing between cards
            Expanded(
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Attendance List:',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Expanded(
                        child: buildAttendanceList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
