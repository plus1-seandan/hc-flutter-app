import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:namer_app/auth.dart';
import 'package:namer_app/configs/api_configs.dart';
import 'package:namer_app/models/hosting_schedule.dart';
import 'package:namer_app/models/member_model.dart';
import 'package:namer_app/widgets/app_drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HostingSchedulesPage extends StatefulWidget {
  @override
  _HostingSchedulesPageState createState() => _HostingSchedulesPageState();
}

class _HostingSchedulesPageState extends State<HostingSchedulesPage> {
  List<HostingSchedule> hostingSchedules = []; // List of hosting schedules
  List<Member> houseChurchMembers = [];
  final User? user = Auth().currentUser;
  int _selectedIndex = 1;

  Member? _selectedMember;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    fetchHostingSchedules(); // Fetch hosting schedules when the page initializes
  }

  List<HostingSchedule> parseHostingSchedules(String responseBody) {
    final parsed = jsonDecode(responseBody);
    return (parsed['hostingSchedules'] as List)
        .map<HostingSchedule>((json) => HostingSchedule.fromJson(json))
        .toList();
  }

  List<Member> parseMembers(String responseBody) {
    final parsed = jsonDecode(responseBody);
    return (parsed['members'] as List)
        .map<Member>((json) => Member.fromJson(json))
        .toList();
  }

  Future<void> fetchHostingSchedules() async {
    setState(() {
      hostingSchedules = [];
      houseChurchMembers = [];
    });
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? hcId = prefs.getString('hcId');
    final response = await http
        .get(Uri.parse('${ApiConfig.baseUrl}/api/hostingSchedule/all/$hcId'));

    if (response.statusCode == 200) {
      setState(() {
        hostingSchedules = parseHostingSchedules(response.body);
        houseChurchMembers = parseMembers(response.body);
      });
    }
  }

  Future<void> addHostingSchedule() async {
    if (_selectedMember == null || _selectedDate == null) {
      return;
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? hcId = prefs.getString('hcId');

    final newSchedule = {
      "hcId": hcId,
      'hostId':
          _selectedMember?.id, // Use the member ID from the selected member
      'date': _selectedDate!.toIso8601String(), // Convert DateTime to String
    };

    await http.post(
      Uri.parse(
          '${ApiConfig.baseUrl}/api/hostingSchedule/'), // Update to your API endpoint
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(newSchedule), // Encode the request body to JSON
    );

    await fetchHostingSchedules(); // Refresh the list after editing

    // setState(() {
    //   hostingSchedules.add(HostingSchedule(
    //       hostId: _selectedMember!, date: _selectedDate!, id: "test"));
    //   _selectedMember = null;
    //   _selectedDate = null;
    // });
  }

  Future<void> editHost(String hostingScheduleId, Member currentHost) async {
    Member? newHost;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Host for Schedule'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return DropdownButton<Member>(
                value: newHost,
                hint: Text('Select New Host'),
                icon: Icon(Icons.arrow_downward),
                onChanged: (Member? selectedMember) {
                  setState(() {
                    newHost = selectedMember; // Update the selected host
                  });
                },
                items: houseChurchMembers
                    .map<DropdownMenuItem<Member>>((Member member) {
                  return DropdownMenuItem<Member>(
                    value: member,
                    child: Text(member.name),
                  );
                }).toList(),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (newHost != null) {
                  final response = await http.put(
                    Uri.parse('${ApiConfig.baseUrl}/api/hostingSchedule/'),
                    headers: {'Content-Type': 'application/json'},
                    body: jsonEncode({
                      'memberId': newHost?.id,
                      "id": hostingScheduleId
                    }), // Send the new host ID
                  );
                  if (response.statusCode == 201) {
                    await fetchHostingSchedules(); // Refresh the list after editing
                    Navigator.of(context).pop(); // Close the dialog
                  } else {
                    // Handle error
                    print('Failed to update host');
                  }
                }
              },
              child: Text('Update'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteHostingSchedule(String hostingScheduleId) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/api/hostingSchedule/$hostingScheduleId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      await fetchHostingSchedules(); // Refresh the list after deletion
    } else {
      // Handle error
      print('Failed to delete hosting schedule');
    }
  }

  void showAddScheduleDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Hosting Schedule'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<Member>(
                    value: _selectedMember, // Current selected value
                    hint: Text(
                        'Select Member'), // Default text if nothing is selected
                    icon: Icon(Icons
                        .arrow_downward), // The icon displayed on the right
                    onChanged: (Member? newValue) {
                      setState(() {
                        _selectedMember =
                            newValue; // Update the selected member
                      });
                    },
                    items: houseChurchMembers
                        .map<DropdownMenuItem<Member>>((Member member) {
                      return DropdownMenuItem<Member>(
                        value: member,
                        child: Text(member.name),
                      );
                    }).toList(), // List of items to display in the dropdown
                  ),
                  SizedBox(height: 16),
                  TextButton(
                    onPressed: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          _selectedDate =
                              pickedDate; // Update the selected date
                        });
                      }
                    },
                    child: Text(
                      _selectedDate == null
                          ? 'Select Date'
                          : 'Selected Date: ${_selectedDate!.toLocal()}'
                              .split(' ')[0], // Show the selected date
                    ),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await addHostingSchedule(); // Call method to add schedule
                Navigator.of(context).pop(); // Close dialog
              },
              child: Text('Add'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hosting Schedules'),
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
          child: ListView.builder(
            itemCount: hostingSchedules.length,
            itemBuilder: (context, index) {
              final hostingSchedule = hostingSchedules[index];
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                elevation: 4,
                margin: EdgeInsets.symmetric(vertical: 8.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        hostingSchedule.date
                            .toLocal()
                            .toString()
                            .split(' ')[0], // Display the date
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 16),
                      Text(
                        hostingSchedule.hostId.name, // Access name directly
                        style: TextStyle(fontSize: 18),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              editHost(hostingSchedule.id,
                                  hostingSchedule.hostId); // Call edit function
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () async {
                              // Show confirmation dialog before deletion
                              bool confirmDelete = await showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text('Delete Hosting Schedule'),
                                    content: Text(
                                        'Are you sure you want to delete this schedule?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context)
                                              .pop(false); // Cancel delete
                                        },
                                        child: Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context)
                                              .pop(true); // Confirm delete
                                        },
                                        child: Text('Delete'),
                                      ),
                                    ],
                                  );
                                },
                              );

                              if (confirmDelete) {
                                await deleteHostingSchedule(
                                    hostingSchedule.id); // Call delete function
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          )),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddScheduleDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}
