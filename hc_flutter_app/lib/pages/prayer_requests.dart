import 'package:flutter/material.dart';

class PrayerRequestsPage extends StatelessWidget {
  final List<Map<String, String>> prayerRequests = [
    {'name': 'John', 'request': 'Pray for my upcoming exams.'},
    {'name': 'Sarah', 'request': 'Health recovery for my mother.'},
    {'name': 'Michael', 'request': 'Guidance in my job search.'},
    {'name': 'Emma', 'request': 'Peace and joy in my family.'},
  ];

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
                        prayerRequest['name']!,
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
                        prayerRequest['request']!,
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
    );
  }
}
