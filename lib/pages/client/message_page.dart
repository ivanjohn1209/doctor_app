import 'package:activity_2_flutter/pages/client/chat_page.dart';
import 'package:flutter/material.dart';

class MessagePage extends StatefulWidget {
  @override
  _MessagePageState createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  int _currentIndex = 0;

  // List of user names for example
  final List<String> userNames = [
    'Hazero Joykies',
    'HiroCruz',
    'Gianaly Flores',
    'Shaina Padgayawon',
    'Shainskie Aguilar',
    'Jonnahnie Mae'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(150),
        child: AppBar(
          toolbarHeight: 150.0,
          title: Column(
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 0.0),
                child: Text(
                  "Messages",
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: 'Search',
                    border: InputBorder.none,
                    icon: Icon(Icons.search, color: Color(0xFF43AF43)),
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Color(0xFF43AF43),
          shape: RoundedAppBarShape(), // Custom AppBar shape
        ),
      ),
      body: ListView.builder(
        itemCount: userNames.length, // Example item count
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Color(0xFF43AF43),
              child: Icon(Icons.person, color: Colors.white),
            ),
            title: Text(
              userNames[index],
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('Good morning! How high is your fever?'),
            trailing: Text(
              index == 0
                  ? '9:30'
                  : index == 1
                      ? '10:45'
                      : index == 2
                          ? '3:37'
                          : index == 3
                              ? '2:35'
                              : index == 4
                                  ? '4:35'
                                  : '1:30',
              style: TextStyle(color: Colors.grey),
            ),
            onTap: () {
              // Navigate to the ChatPage with the user's name
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatPage(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class RoundedAppBarShape extends RoundedRectangleBorder {
  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final double radius = 40.0; // Adjust the radius to your preference
    return Path()
      ..moveTo(0, 0)
      ..lineTo(0, rect.height - radius)
      ..quadraticBezierTo(0, rect.height, radius, rect.height) // Bottom-left curve
      ..lineTo(rect.width - radius, rect.height)
      ..quadraticBezierTo(rect.width, rect.height, rect.width, rect.height - radius) // Bottom-right curve
      ..lineTo(rect.width, 0) // Line to the top-right corner
      ..close(); // Close the path
  }
}