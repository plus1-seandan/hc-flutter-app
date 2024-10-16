import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:namer_app/auth.dart';
import 'package:namer_app/configs/api_configs.dart';
import 'package:namer_app/models/member_model.dart';
import 'package:namer_app/models/prayer_request_model.dart';
import 'package:namer_app/widgets/app_drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrayerRequestsPage extends StatefulWidget {
  @override
  _PrayerRequestsPageState createState() => _PrayerRequestsPageState();
}

class _PrayerRequestsPageState extends State<PrayerRequestsPage> {
  List<PrayerRequest> prayerRequests = [];
  List<Member> houseChurchMembers = [];

  final User? user = Auth().currentUser;
  int _selectedIndex = 1;

  // Default selected item
  Member? _selectedMember;
  String? _prayerRequest;

  @override
  void initState() {
    super.initState();
    fetchPrayerRequests(); // Fetch prayer requests when the page initializes
  }

  List<PrayerRequest> parsePrayerRequests(String responseBody) {
    final parsed = jsonDecode(responseBody);
    return (parsed['prayerRequests'] as List)
        .map<PrayerRequest>((json) => PrayerRequest.fromJson(json))
        .toList();
  }

  List<Member> parseMembers(String responseBody) {
    final parsed = jsonDecode(responseBody);
    return (parsed['members'] as List)
        .map<Member>((json) => Member.fromJson(json))
        .toList();
  }

  Future<void> fetchPrayerRequests() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? hcId = prefs.getString('hcId');
    final response = await http
        .get(Uri.parse('${ApiConfig.baseUrl}/api/prayerRequest/$hcId'));

    if (response.statusCode == 200) {
      setState(() {
        prayerRequests = parsePrayerRequests(response.body);
        houseChurchMembers = parseMembers(response.body);
      });
    }
  }

  Future<void> addPrayerRequest() async {
    print(_selectedMember);
    print(_prayerRequest);
    if (_selectedMember == null || _prayerRequest == null) {
      return;
    }
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? hcId = prefs.getString('hcId');

    final newRequest = {
      "hcId": hcId,
      'memberId':
          _selectedMember?.id, // Use the member ID from the selected member
      'request': _prayerRequest,
    };
    await http.post(
      Uri.parse(
          '${ApiConfig.baseUrl}/api/prayerRequest'), // Update to your API endpoint
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(newRequest), // Encode the request body to JSON
    );
    setState(() {
      prayerRequests.add(new PrayerRequest(
          member: _selectedMember!, request: _prayerRequest!));
      _selectedMember = null;
      _prayerRequest = null;
    });
  }

  void showAddRequestDialog() {
    final nameController = TextEditingController();
    final requestController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Prayer Request'),
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
                  TextField(
                    controller: requestController,
                    decoration: InputDecoration(
                      labelText: 'Request',
                      border: OutlineInputBorder(), // Optional: Add a border
                    ),
                    maxLines: 5, // Set the number of lines
                    minLines: 3, // Minimum lines to show
                    onChanged: (String? newString) {
                      setState(() {
                        _prayerRequest =
                            newString; // Update the selected member
                      });
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await addPrayerRequest();
                Navigator.of(context).pop();
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
        title: Text('Prayer Requests'),
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
          itemCount: prayerRequests.length,
          itemBuilder: (context, index) {
            final prayerRequest = prayerRequests[index];
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              elevation: 4,
              margin: EdgeInsets.symmetric(vertical: 8.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        prayerRequest.member.name, // Access name directly
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      flex: 3,
                      child: Text(
                        prayerRequest.request, // Access request directly
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddRequestDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}
