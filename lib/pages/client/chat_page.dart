import 'package:flutter/material.dart';

class ChatPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              radius: 20,
              child: Icon(Icons.person, color: Colors.green),
            ),
            SizedBox(width: 10),
            Text(
              'Doctor',
              style: TextStyle(fontSize: 20,color: Colors.white),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          // Message List
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(16),
              children: [
                _buildMessageRow('Doctor', 'What brings you in today?', true),
                _buildMessageRow('Patient', "I've had headaches for a week.", false),
                _buildMessageRow('Doctor', 'Are they constant?', true),
                _buildMessageRow('Patient', 'No, worse in the mornings.', false),
                _buildMessageRow('Doctor', 'Try more water and rest.', true),
              ],
            ),
          ),
          // Input Field
          _buildMessageInput(),
        ],
      ),
    );
  }

  // Message Row
  Widget _buildMessageRow(String sender, String message, bool isDoctor) {
    return Align(
      alignment: isDoctor ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDoctor ? Colors.green.shade100 : Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: Colors.green,
              child: Icon(Icons.person, color: Colors.white),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sender,
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                ),
                SizedBox(height: 5),
                Text(message),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Message Input Field
  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.green.shade100,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          const Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Type your message...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.green),
            onPressed: () {
              // Handle message send action
            },
          ),
        ],
      ),
    );
  }
}
