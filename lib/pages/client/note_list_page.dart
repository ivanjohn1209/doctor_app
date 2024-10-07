import 'package:activity_2_flutter/main.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Doctor {
  final String id;
  final String name;

  Doctor({required this.id, required this.name});

  factory Doctor.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Doctor(
      id: doc.id,
      name: data['name'] ??
          '', // Adjust based on your actual Firestore field names
    );
  }
}

class NoteListPage extends StatefulWidget {
  const NoteListPage({super.key});
  @override
  State<NoteListPage> createState() => _NoteListPageState();
}

class _NoteListPageState extends State<NoteListPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _commentController = TextEditingController();
  List<Doctor> doctors = []; // List to hold doctor names
  final TextEditingController _noteController = TextEditingController();
  String? dropdownValue;

  @override
  void initState() {
    super.initState();
    fetchDoctors();
  }

  Future<void> fetchDoctors() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('accounts')
          .where('type', isEqualTo: 'Doctor')
          .get();

      setState(() {
        doctors =
            querySnapshot.docs.map((doc) => Doctor.fromFirestore(doc)).toList();
        // Set default dropdown value if there are doctors available
        if (doctors.isNotEmpty) {
          dropdownValue = doctors.first.id;
        }
      });
    } catch (e) {
      print("Failed to fetch doctors: $e");
    }
  }

  Future<dynamic> _showNoteDetails(DocumentSnapshot note) async {
    User? user = FirebaseAuth.instance.currentUser;
    var timestamp = note['timestamp'];
    var formattedTime = timestamp != null
        ? (timestamp as Timestamp).toDate().toString()
        : 'No timestamp';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Dialog.fullscreen(
              child: Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Note Details:',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          SizedBox(height: 16.0),
                          Text('Content: ${note['content'] ?? 'No content'}'),
                          SizedBox(height: 10),
                          Text('Timestamp: $formattedTime'),
                          SizedBox(height: 10),
                          Text(
                              'Client Name: ${note['clientName'] ?? 'Unknown Client'}'),
                          SizedBox(height: 10),
                          Text(
                              'Client Email: ${note['clientEmail'] ?? 'Unknown Email'}'),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('Close'),
                          ),
                          SizedBox(height: 20),
                          Expanded(
                            child: StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('accounts')
                                  .doc(user?.uid)
                                  .collection('notes')
                                  .doc(note.id)
                                  .collection('comments')
                                  .orderBy('timestamp')
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }
                                if (!snapshot.hasData ||
                                    snapshot.data!.docs.isEmpty) {
                                  return const Center(
                                      child: Text('No comments yet.'));
                                }
                                var comments = snapshot.data!.docs;

                                return ListView.builder(
                                  itemCount: comments.length,
                                  itemBuilder: (context, index) {
                                    var comment = comments[index];
                                    var commentTimestamp = comment['timestamp'];
                                    var commentFormattedTime =
                                        commentTimestamp != null
                                            ? (commentTimestamp as Timestamp)
                                                .toDate()
                                                .toString()
                                            : 'No timestamp';

                                    return ListTile(
                                      title: Text(
                                          comment['content'] ?? 'No content'),
                                      subtitle: Text(commentFormattedTime),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            controller: _noteController,
                            decoration: InputDecoration(
                              hintText: 'Add a comment...',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        SizedBox(width: 8.0),
                        ElevatedButton(
                          onPressed: () async {
                            if (_noteController.text.isNotEmpty) {
                              try {
                                User? user = FirebaseAuth.instance.currentUser;
                                if (user != null) {
                                  await FirebaseFirestore.instance
                                      .collection('accounts')
                                      .doc(user.uid)
                                      .collection('notes')
                                      .doc(note.id)
                                      .collection('comments')
                                      .add({
                                    'content': _noteController.text,
                                    'clientName':
                                        user.displayName ?? 'Anonymous',
                                    'clientId': user.uid,
                                    'timestamp': Timestamp.now()
                                  });

                                  _noteController.clear();
                                }
                              } catch (e) {
                                print("Failed to add comment: $e");
                              }
                            }
                          },
                          child: Text('Add'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<dynamic> _showAddNoteDialog() {
    _noteController.clear();
    final userData = UserDataProvider.of(context)?.userData;
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Dialog.fullscreen(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Add Note:',
                      textAlign: TextAlign.left,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16.0),
                    TextField(
                      controller: _noteController,
                      decoration: const InputDecoration(
                        hintText: 'Enter your note',
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 12.0),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Doctor',
                        border: UnderlineInputBorder(),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: dropdownValue,
                          isExpanded: true,
                          icon: Icon(Icons.arrow_drop_down),
                          items: doctors
                              .map<DropdownMenuItem<String>>((Doctor doctor) {
                            return DropdownMenuItem<String>(
                              value: doctor.id,
                              child: Text(doctor.name),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              dropdownValue = newValue;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('Close'),
                        ),
                        SizedBox(width: 8.0),
                        ElevatedButton(
                          onPressed: () async {
                            if (_noteController.text.isNotEmpty) {
                              try {
                                User? user = FirebaseAuth.instance.currentUser;
                                if (user != null) {
                                  await FirebaseFirestore.instance
                                      .collection('accounts')
                                      .doc(user.uid)
                                      .collection('notes')
                                      .add({
                                    'content': _noteController.text,
                                    'assignedTo': dropdownValue,
                                    'clientName': userData?['name'],
                                    'clientEmail': userData?['email'],
                                    'clientId': user.uid,
                                    'timestamp': Timestamp.now()
                                  });

                                  Navigator.pop(context);
                                }
                              } catch (e) {
                                print("Failed to add note: $e");
                              }
                            }
                          },
                          child: Text('Save'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;
    return Scaffold(
      // appBar: PreferredSize(
      //   preferredSize: Size.fromHeight(100), // Custom height
      //   child: AppBar(
      //     title: Text('My Notes'),
      //     centerTitle: true,
      //     backgroundColor: Color(0xFF43AF43),
      //     shape: RoundedAppBarShape(), // Custom AppBar shape
      //   ),
      // ),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100), 
        child: AppBar(
          toolbarHeight: 200.0,
          title: const Column(
          children: [
          const SizedBox(height: 20),
          Text(
            "My Notes",
            style: TextStyle(fontSize: 20, color: Colors.white), 
        ),
          ],
        ),
          centerTitle: true,
          backgroundColor: Color(0xFF43AF43),
          shape: RoundedAppBarShape(), // Custom AppBar shape
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: user != null
                ? StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection('accounts')
                        .doc(user.uid)
                        .collection('notes')
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(child: Text('No notes available.'));
                      }

                      var notes = snapshot.data!.docs;

                      return ListView.builder(
                        itemCount: notes.length,
                        itemBuilder: (context, index) {
                          var note = notes[index];
                          // return ListTile(
                          //   title: Text(note['content']),
                          //   subtitle:
                          //       Text(note['timestamp'].toDate().toString()),
                          //   onTap: () => _showNoteDetails(note),
                          // );
                          return NoteItem(title: note['content'], time: '5:00am');
                        },
                      );
                    },
                  )
                : const Center(
                    child: Text('Please log in to view your notes.')),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddNoteDialog(),
        child: Icon(Icons.add, color: Colors.white),
        tooltip: 'Add Note',
        backgroundColor: Color(0xFF43AF43),
      ),
    );
  }
}


class NoteItem extends StatelessWidget {
  final String title;
  final String time;

  NoteItem({required this.title, required this.time});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFF43AF43),
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
