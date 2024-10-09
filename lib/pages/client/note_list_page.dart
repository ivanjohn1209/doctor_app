import 'package:care_connect/main.dart';
import 'package:care_connect/pages/client/add_note_page.dart';
import 'package:care_connect/pages/doctor/note_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart' as intl; // Alias the intl import

class Doctor {
  final String id;
  final String name;
  final String specialty;
  Doctor({required this.id, required this.name, required this.specialty});

  factory Doctor.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Doctor(
      id: doc.id,
      name: data['name'] ??
          '', // Adjust based on your actual Firestore field names
      specialty: data['specialty'] ?? '',
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

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
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
          backgroundColor: const Color(0xFF43AF43),
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
                        return const Center(child: CircularProgressIndicator());
                      }

                      if ((!snapshot.hasData || snapshot.data!.docs.isEmpty)) {
                        return const Center(child: Text('No notes available.'));
                      }

                      var notes = snapshot.data!.docs;

                      return ListView.builder(
                        itemCount: notes.length,
                        itemBuilder: (context, index) {
                          var note = notes[index];
                          Timestamp timestamp = note['timestamp'] as Timestamp;
                          DateTime dateTime = timestamp.toDate();
                          String formattedDate1 =
                              intl.DateFormat('MM/dd/yyyy hh:mm a')
                                  .format(dateTime);
                          return NoteItem(
                              note: note, formattedTime: formattedDate1);
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
        onPressed: () {
          // Navigator.pushReplacementNamed(context, '/add-note');
          final userData = UserDataProvider.of(context)?.userData;
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddNotePage(userData)),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: 'Add Note',
        backgroundColor: const Color(0xFF43AF43),
      ),
    );
  }
}

class NoteItem extends StatelessWidget {
  final dynamic note; // Pass the whole note object
  final String formattedTime;

  NoteItem({required this.note, required this.formattedTime});

  @override
  Widget build(BuildContext context) {
    // Extracting values from the note object
    String title = note['patientFeels'];
    String name = note['clientName'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF43AF43),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          onTap: () {
            final userData = UserDataProvider.of(context)?.userData;
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => NoteDetail(
                        userData,
                        noteData: note,
                      )),
            );
          },
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Icon(
              note != null &&
                      note.data() != null &&
                      note.data().containsKey('approved')
                  ? (note['approved'] == true
                      ? Icons.check_box_rounded
                      : Icons.disabled_by_default_rounded)
                  : Icons.check_box_outline_blank,
              color: Colors.white),
          title: Text(
            title,
            style: const TextStyle(color: Colors.white),
          ),
          trailing: Text(
            formattedTime,
            style: const TextStyle(color: Colors.white),
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
      ..quadraticBezierTo(
          0, rect.height, radius, rect.height) // Bottom-left curve
      ..lineTo(rect.width - radius, rect.height)
      ..quadraticBezierTo(rect.width, rect.height, rect.width,
          rect.height - radius) // Bottom-right curve
      ..lineTo(rect.width, 0) // Line to the top-right corner
      ..close(); // Close the path
  }
}
