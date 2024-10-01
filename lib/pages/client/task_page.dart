import 'package:flutter/material.dart';
import 'package:intl/intl.dart';  // Add this import for date formatting

class TaskPage extends StatefulWidget {
  @override
  _TaskPageState createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  // Track the start of the current week
  DateTime _currentWeekStart = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));

  // Method to get the name of the month dynamically
  String get currentMonth => DateFormat.MMMM().format(_currentWeekStart);

  // Method to get the days of the current week
  List<DateTime> get weekDays {
    return List.generate(7, (index) {
      return _currentWeekStart.add(Duration(days: index));
    });
  }

  // Go to the previous week
  void _previousWeek() {
    setState(() {
      _currentWeekStart = _currentWeekStart.subtract(Duration(days: 7));
    });
  }

  // Go to the next week
  void _nextWeek() {
    setState(() {
      _currentWeekStart = _currentWeekStart.add(Duration(days: 7));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: _previousWeek,  // Go to the previous week
        ),
        title: Text(currentMonth),  // Display dynamic month
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_forward),
            onPressed: _nextWeek,  // Go to the next week
          ),
        ],
      ),
      body: Column(
        children: [
          // Calendar Row
          Container(
            color: Colors.green,
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (index) {
                return Column(
                  children: [
                    Text(
                      DateFormat.E().format(weekDays[index]).toUpperCase(),  // Display day name
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "${weekDays[index].day}",  // Display day number
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                );
              }),
            ),
          ),
          // Today's Task Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "TODAY'S TASK",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          // Task List
          Expanded(
            child: ListView(
              children: [
                TaskItem(title: "Medicine", time: "10:00am"),
                TaskItem(title: "Water", time: "9:00am"),
                TaskItem(title: "Fruits", time: "8:30am"),
                TaskItem(title: "Check-up", time: "8:00am"),
                TaskItem(title: "Appointment", time: "5:00am"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TaskItem extends StatelessWidget {
  final String title;
  final String time;

  TaskItem({required this.title, required this.time});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Icon(Icons.radio_button_unchecked, color: Colors.white),
          title: Text(
            title,
            style: TextStyle(color: Colors.white),
          ),
          trailing: Text(
            time,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
