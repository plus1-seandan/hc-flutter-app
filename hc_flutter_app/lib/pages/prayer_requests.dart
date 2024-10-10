import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PrayerRequestsPage extends StatefulWidget {
  @override
  _PrayerRequestsPageState createState() => _PrayerRequestsPageState();
}

class PrayerRequest {
  final String name;
  final String request;

  PrayerRequest({required this.name, required this.request});
}

class _PrayerRequestsPageState extends State<PrayerRequestsPage> {
  List<PrayerRequest> prayerRequests = [];

  @override
  void initState() {
    super.initState();
    fetchPrayerRequests(); // Fetch prayer requests when the page initializes
  }

  Future<void> fetchPrayerRequests() async {
    final response = await http
        .get(Uri.parse('http://192.168.1.74:8000/api/prayerRequest/'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      setState(() {
        prayerRequests = (data['prayerRequests'] as List)
            .map((request) => PrayerRequest(
                  name: request['memberId']['name'] ?? 'Unknown',
                  request: request['request'] ?? 'No request provided',
                ))
            .toList();
      });
    }
  }

  /*
  Future<void> addPrayerRequest(String name, String request) async {
    // Create a new prayer request object
    final newRequest = {
      'memberId': {'name': name}, // Adjust this according to your API
      'request': request,
    };

    // Send a POST request to the server
    final response = await http.post(
      Uri.parse('http://192.168.1.74:8000/api/prayerRequest/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(newRequest),
    );

    // Check if the request was successful
    if (response.statusCode == 201) {
      // If successful, add the new request to the list and update the UI
      final data = jsonDecode(response.body);
      setState(() {
        prayerRequests.add(PrayerRequest(
          name: data['prayerRequest']['memberId']
              ['name'], // Update according to response structure
          request: data['prayerRequest']['request'],
        ));
      });
    } else {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add prayer request')),
      );
    }
  }
  */
  void showAddRequestDialog() {
    final nameController = TextEditingController();
    final requestController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Prayer Request'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: requestController,
                decoration: InputDecoration(labelText: 'Request'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Add the prayer request and close the dialog
                // addPrayerRequest(nameController.text, requestController.text);
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
                        prayerRequest.name, // Access name directly
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
