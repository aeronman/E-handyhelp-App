import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});
  @override
  _MessagesScreenState createState() => _MessagesScreenState();
}
class _MessagesScreenState extends State<MessagesScreen>{
   List<dynamic> messages = [];
   String _id = '';
  @override
  void initState() {
    super.initState();
    _loadHandymanData();

  }
  Future<void> _loadHandymanData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _id = prefs.getString('_id')?? '';
     
       fetchMessages();
      
    });
  }
  Future<void> fetchMessages() async {
    print('id:'+_id);
  final response = await http.get(Uri.parse('http://127.0.0.1:3000/api/user-messages?userId=$_id'));

  if (response.statusCode == 200) {
    setState(() {
      messages = json.decode(response.body);
    });
  } else {
    throw Exception('Failed to load messages');
  }
  }


  void navigateToChat(String bookingId, String handymanId, String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(bookingId: bookingId, handymanId: handymanId,userId: userId,),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Messages', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[900],
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  return MessageCard(
                    name: '${message['userFirstName']} ${message['userManLastName']}',
                    message: '${message['last_message']}...',
                    onTap: () {
                      navigateToChat(message['booking_id'],message['handyman_id'],message['user_id']);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageCard extends StatelessWidget {
  final String name;
  final String message;
  final VoidCallback onTap;

  MessageCard({required this.name, required this.message, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
          side: BorderSide(color: Colors.blue),
        ),
        child: ListTile(
          leading: Container(
            width: 50.0,
            height: 50.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[300],
            ),
          ),
          title: Text(name),
          subtitle: Text(message),
        ),
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String bookingId;
  final String handymanId;
  final String userId;
  

  ChatScreen({required this.bookingId,required this.handymanId, required this.userId});

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  List<dynamic> _messages = [];

  @override
  void initState() {
    super.initState();
    fetchConversation();
  }

  Future<void> fetchConversation() async {
    final response = await http.get(Uri.parse('http://127.0.0.1:3000/api/user-conversation/${widget.bookingId}'));
    if (response.statusCode == 200) {
      setState(() {
        _messages = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load conversation');
    }
  }

  Future<void> _sendMessage() async {
    if (_controller.text.isNotEmpty) {
      // Prepare the message data
      final newMessage = {
        'contents': _controller.text,
        'handyman_id': widget.handymanId, // Pass handyman_id dynamically
        'user_id': widget.userId, // Pass user_id dynamically
        'booking_id': widget.bookingId, // Pass booking_id dynamically
      };

      try {
        // Send the message to the backend API
        final response = await http.post(
          Uri.parse('http://127.0.0.1:3000/api/send-message-user'), // Your API endpoint
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode(newMessage),
        );

        if (response.statusCode == 200) {
         fetchConversation();
          
        } else {
          throw Exception('Failed to send message');
        }
      } catch (error) {
        print('Error sending message: $error');
      }

      // Clear the input field
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                String sender = message['sender'] == 'user'
                    ? 'You'
                    : '${message['handyMan_details']['fname']} ${message['handyMan_details']['lname']}'; // Display user’s full name
                
                return MessageWidget(
                  text: message['contents'],
                  sender: sender,
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(hintText: 'Enter your message...'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage, // Send the message when the button is pressed
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MessageWidget extends StatelessWidget {
  final String text;
  final String sender;

  MessageWidget({required this.text, required this.sender});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: sender == 'You' ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            sender,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Material(
            borderRadius: BorderRadius.circular(10.0),
            elevation: 5.0,
            color: sender == 'You' ? Colors.lightBlueAccent : Colors.grey[300],
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Text(
                text,
                style: TextStyle(fontSize: 16.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

  