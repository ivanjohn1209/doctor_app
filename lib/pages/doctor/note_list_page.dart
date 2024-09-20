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

class DoctorNoteListPage extends StatefulWidget {
  const DoctorNoteListPage({super.key});

  @override
  State<DoctorNoteListPage> createState() => _DoctorNoteListPageState();
}

class _DoctorNoteListPageState extends State<DoctorNoteListPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Doctor> doctors = [];
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
        if (doctors.isNotEmpty) {
          dropdownValue = doctors.first.id; // Set default dropdown value
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
      appBar: AppBar(
        title: const Text('Client Notes'),
      ),
      body: Column(
        children: [
          // Dropdown for selecting doctors
          Expanded(
            child: user != null
                ? StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collectionGroup('notes')
                        .orderBy('timestamp', descending: true)
                        .where('assignedTo', isEqualTo: user.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error loading notes.'));
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(child: Text('No notes available.'));
                      }

                      var notes = snapshot.data!.docs;

                      return ListView.builder(
                        itemCount: notes.length,
                        itemBuilder: (context, index) {
                          var note = notes[index];
                          var timestamp = note['timestamp'];
                          var formattedTime = timestamp != null
                              ? (timestamp as Timestamp).toDate().toString()
                              : 'No timestamp';

                          return ListTile(
                            title: Text(
                                'Client: ${note['clientName'] ?? 'Unknown Client'}'),
                            subtitle: Text(
                                'Note: ${note['content'] ?? 'No content'}\nTime: $formattedTime'),
                          );
                        },
                      );
                    },
                  )
                : const Center(
                    child: Text('Please log in to view your notes.')),
          ),
        ],
      ),
    );
  }
}
