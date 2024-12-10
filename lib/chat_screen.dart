import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref().child('messages');
  final TextEditingController _controller = TextEditingController();
  List<Map<dynamic, dynamic>> messages = [];

  @override
  void initState() {
    super.initState();
    // Listen for new messages from Firebase
    _dbRef.onChildAdded.listen((event) {
      setState(() {
        messages.add(event.snapshot.value as Map<dynamic, dynamic>);
      });
    });
  }

  void sendMessage(String message) {
    if (message.trim().isNotEmpty) {
      // Send user's message to Firebase
      _dbRef.push().set({'message': message, 'sender': 'user'});

      // Generate a basic bot response
      String botResponse = _generateResponse(message);
      _dbRef.push().set({'message': botResponse, 'sender': 'bot'});

      _controller.clear();
    }
  }

  String _generateResponse(String message) {
    if (message.toLowerCase().contains('hello')) return 'Hello! How can I assist you?';
    return 'I am not sure I understand. Could you rephrase?';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chatbot'),
      ),
      body: Column(
        children: [
          // Chat messages list
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isBot = message['sender'] == 'bot';
                return Container(
                  padding: const EdgeInsets.all(8.0),
                  alignment: isBot ? Alignment.centerLeft : Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isBot ? Colors.grey[300] : Colors.blue[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      message['message'],
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                );
              },
            ),
          ),
          // Input field and send button
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => sendMessage(_controller.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}