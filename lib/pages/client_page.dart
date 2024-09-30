import 'package:flutter/material.dart';
import 'client/note_list_page.dart';
import 'client/notification_page.dart';
import 'client/settings_page.dart';

class ClientPage extends StatefulWidget {
  @override
  _ClientPageState createState() => _ClientPageState();
}

class _ClientPageState extends State<ClientPage> {
  int _selectedIndex = 0;
  static List<Widget> _widgetOptions = <Widget>[
    const NoteListPage(),
    NotificationPage(),
    SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Client Page')),
      body: _widgetOptions.elementAt(_selectedIndex),
    //   bottomNavigationBar: BottomNavigationBar(
    //     items: const <BottomNavigationBarItem>[
    //       BottomNavigationBarItem(
    //         icon: Icon(Icons.note),
    //         label: 'Notes',
    //       ),
    //       BottomNavigationBarItem(
    //         icon: Icon(Icons.notifications),
    //         label: 'Notifications',
    //       ),
    //       BottomNavigationBarItem(
    //         icon: Icon(Icons.settings),
    //         label: 'Settings',
    //       ),
    //     ],
    //     currentIndex: _selectedIndex,
    //     selectedItemColor: Colors.blue,
    //     onTap: _onItemTapped,
    //   ),
    // );
bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 16.0), // Add bottom margin here
        child: Container(
          width: MediaQuery.of(context).size.width * 0.7, // 70% of screen width
          decoration: BoxDecoration(
            color: Colors.green, // Background color of the bar
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10.0,
                spreadRadius: 2.0,
                offset: const Offset(0, -2), // Shadow below the bar
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            child: BottomNavigationBar(
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.filter_alt),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.add),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.message),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.notifications),
                  label: '',
                ),
              ],
              currentIndex: _selectedIndex,
              selectedItemColor: Colors.black, // Icon color when selected
              unselectedItemColor: Colors.black, // Icon color when unselected
              elevation: 0, // Remove shadow from the BottomNavigationBar
              onTap: _onItemTapped,
              showUnselectedLabels: false,
              showSelectedLabels: false,
            ),
          ),
        ),
      ),
    );
  }
}
