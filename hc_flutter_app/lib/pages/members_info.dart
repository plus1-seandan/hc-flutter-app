import 'package:flutter/material.dart';

class MemberInfoPage extends StatefulWidget {
  @override
  _MemberInfoPageState createState() => _MemberInfoPageState();
}

class _MemberInfoPageState extends State<MemberInfoPage> {
  final List<Map<String, String>> members = [
    {'name': 'John', 'info': 'Loves playing guitar and hiking.'},
    {'name': 'Sarah', 'info': 'Enjoys cooking and reading.'},
    {'name': 'Michael', 'info': 'Passionate about photography.'},
    {'name': 'Emma', 'info': 'Yoga enthusiast and baker.'},
  ];

  void _editMemberInfo(int index) {
    final TextEditingController nameController =
        TextEditingController(text: members[index]['name']);
    final TextEditingController infoController =
        TextEditingController(text: members[index]['info']);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Edit Member Information',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: infoController,
                  decoration: InputDecoration(
                    labelText: 'Additional Info',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      members[index]['name'] = nameController.text;
                      members[index]['info'] = infoController.text;
                    });
                    Navigator.pop(context);
                  },
                  child: Text('Save Changes'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Group Members'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: members.length,
          itemBuilder: (context, index) {
            final member = members[index];
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              elevation: 4,
              margin: EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                title: Text(
                  member['name']!,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(member['info']!),
                onTap: () {
                  _editMemberInfo(index);
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
