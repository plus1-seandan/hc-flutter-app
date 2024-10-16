import 'package:flutter/material.dart';
import 'package:namer_app/auth.dart';
import 'package:namer_app/pages/hosting_schedules.dart';
import 'package:namer_app/pages/main_page.dart';
import 'package:namer_app/pages/members_info.dart';
import 'package:namer_app/pages/prayer_requests.dart';

class AppDrawer extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const AppDrawer({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

  Future<void> signOut() async {
    await Auth().signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text('Drawer Header'),
          ),
          ListTile(
            title: const Text('Home'),
            selected: selectedIndex == 0,
            onTap: () {
              onItemTapped(0);
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HouseChurchPage()),
              );
            },
          ),
          ListTile(
            title: const Text('Prayer Requests'),
            selected: selectedIndex == 1,
            onTap: () {
              onItemTapped(1);
              Navigator.pop(context); // Close the drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PrayerRequestsPage()),
              );
            },
          ),
          ListTile(
            title: const Text('Members'),
            selected: selectedIndex == 2,
            onTap: () {
              onItemTapped(2);
              Navigator.pop(context); // Close the drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MemberInfoPage()),
              );
            },
          ),
          ListTile(
            title: const Text('HostingSchedules'),
            selected: selectedIndex == 3,
            onTap: () {
              onItemTapped(2);
              Navigator.pop(context); // Close the drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HostingSchedulesPage()),
              );
            },
          ),
          ListTile(
            title: const Text('Sign Out'),
            selected: selectedIndex == 4,
            onTap: () {
              Navigator.pop(context); // Close the drawer
              signOut();
            },
          ),
        ],
      ),
    );
  }
}
