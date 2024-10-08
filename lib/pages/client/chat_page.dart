import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatPage extends StatefulWidget {
  final String chatDocumentId; // Pass the chatDocumentId to specify the chat
  final dynamic? chatData; // Pass the chatDocumentId to specify the chat

  ChatPage({required this.chatDocumentId, this.chatData});


  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  bool _isSending = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose(); // Dispose the scroll controller
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
         User? user = FirebaseAuth.instance.currentUser;
      var isDocVal = user?.uid == widget.chatData['doctor'];
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Colors.white,
              radius: 20,
              child: Icon(Icons.person, color: Colors.green),
            ),
            const SizedBox(width: 10),
            Text(
             isDocVal ? widget.chatData['doctorName'] + " (Doctor)":widget.chatData['clientName'] + ' (Client)',
              style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
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
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(widget.chatDocumentId)
                  .collection('convo')
                  .orderBy('timestamp', descending: false) // Sort by timestamp
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("No messages yet."));
                }

                var messages = snapshot.data!.docs;
  // Scroll to the bottom after messages are built
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                  }
                });
                return ListView.builder(
                  controller: _scrollController, // Attach the scroll controller
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var messageData = messages[index];
                          User? user = FirebaseAuth.instance.currentUser;
                    var isDoc = messageData['sender'] == widget.chatData['doctor'];
                    var isCurrUser = messageData['sender'] == user?.uid;

                    return _buildMessageRow(
                      isDoc ? widget.chatData['doctorName'] + " (Doctor)":widget.chatData['clientName'] + ' (Client)',
                      messageData['message'],
                      isCurrUser,
                    );
                  },
                );
              },
            ),
          ),
          // Input Field
          _buildMessageInput(),
        ],
      ),
    );
  }

  // Message Row
  Widget _buildMessageRow(String sender, String message, bool isCurrUser) {
    return Align(
      alignment: isCurrUser ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isCurrUser ? Colors.green.shade100 : Colors.white,
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
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Type your message...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
              ),
            ),
          ),
          _isSending
              ? CircularProgressIndicator()
              : IconButton(
                  icon: const Icon(Icons.send, color: Colors.green),
                  onPressed: _sendMessage,
                ),
        ],
      ),
    );
  }

  // Send Message Function
  Future<void> _sendMessage() async {
    String message = _messageController.text.trim();

    if (message.isNotEmpty) {
      try {
        // Get current user information
                User? user = FirebaseAuth.instance.currentUser;
        await FirebaseFirestore.instance
            .collection('chats')
            .doc(widget.chatDocumentId)
            .collection('convo')
            .add({
          'message': message,
          'sender': user?.uid, // Doctor or Patient
          'timestamp': FieldValue.serverTimestamp(), // Timestamp
        });

        // Clear the message input field
        _messageController.clear();
      } catch (e) {
        // Handle error (e.g., show a snackbar or dialog)
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to send message')));
      } finally {
        setState(() {
          _isSending = false;
        });
      }
    }
  }
}
