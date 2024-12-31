import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'voice_call.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'join_channel_audio.dart';
//import 'package:agora_rtc_engine/agora_rtc_engine.dart';

class ChatScreen extends StatelessWidget {
  final String userId;
  final String peerId;
  final String peerName;
  final String chatId;

  ChatScreen({
    required this.userId,
    required this.peerId,
    required this.peerName,
    required this.chatId,
  });

  final TextEditingController _controller = TextEditingController();

  void _sendMessage() async {
    if (_controller.text.isEmpty) return;

    var message = {
      'text': _controller.text,
      'userId': userId,
      'timestamp': FieldValue.serverTimestamp(),
    };

    FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(message);

    _controller.clear();
  }

  void _showPhoneDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Call'),
          content: Text('Calling in for your session?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Call'),
              onPressed: () {
                // String _chatId = widget
                //     .chatId; // Navigate to the VoiceCallDialog screen using Navigator.push
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => JoinChannelAudio(
                        chatId: chatId, peerName: peerName, Id: peerId),
                  ),
                );
                print('Navigating to VoiceCallDialog...');
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple[300], // Changed from teal
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(
                  FirebaseAuth.instance.currentUser?.photoURL ?? ''),
            ),
            Text(
              'Chat with $peerName',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
                color: Colors.white,
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.phone,
                color: Colors.white, // Green color
              ),
              onPressed: () => _showPhoneDialog(context),
            ),
          ],
        ),
      ),
      body: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              Expanded(
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('chats')
                      .doc(chatId)
                      .collection('messages')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData)
                      return Center(child: CircularProgressIndicator());

                    return ListView(
                      reverse: true,
                      children: snapshot.data!.docs.map((doc) {
                        bool isCurrentUser = doc['userId'] == userId;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Align(
                            alignment: isCurrentUser
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isCurrentUser
                                    ? Colors.deepPurple[
                                        100] // Changed from teal[100]
                                    : Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                doc['text'],
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          labelText: 'Send a message...',
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send,
                          color: Colors.purple), // Changed from teal
                      onPressed: _sendMessage,
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Positioned.fill(
          //   child: Align(
          //     alignment: Alignment.center,
          //     // child: Icon(
          //     //   Icons.message,
          //     //   size: 50,
          //     //   color: Colors.purple[50], // Changed from teal[50]
          //     // ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// class ChatScreen extends StatelessWidget {
//   final String userId;
//   final String peerId;
//   final String peerName;
//   final String chatId;
//
//   ChatScreen({
//     required this.userId,
//     required this.peerId,
//     required this.peerName,
//     required this.chatId,
//   });
//
//   final TextEditingController _controller = TextEditingController();
//
//   void _sendMessage() async {
//     if (_controller.text.isEmpty) return;
//
//     var message = {
//       'text': _controller.text,
//       'userId': userId,
//       'timestamp': FieldValue.serverTimestamp(),
//     };
//
//     FirebaseFirestore.instance
//         .collection('chats')
//         .doc(chatId)
//         .collection('messages')
//         .add(message);
//
//     _controller.clear();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.teal,
//         title: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               'Chat with $peerName',
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 20.0,
//                 color: Colors.white,
//               ),
//             ),
//             CircleAvatar(
//               backgroundImage: NetworkImage(
//                   FirebaseAuth.instance.currentUser?.photoURL ?? ''),
//             ),
//           ],
//         ),
//       ),
//       body: Stack(
//         children: <Widget>[
//           Column(
//             children: <Widget>[
//               Expanded(
//                 child: StreamBuilder(
//                   stream: FirebaseFirestore.instance
//                       .collection('chats')
//                       .doc(chatId)
//                       .collection('messages')
//                       .orderBy('timestamp', descending: true)
//                       .snapshots(),
//                   builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
//                     if (!snapshot.hasData)
//                       return Center(child: CircularProgressIndicator());
//
//                     return ListView(
//                       reverse: true,
//                       children: snapshot.data!.docs.map((doc) {
//                         bool isCurrentUser = doc['userId'] == userId;
//                         return Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 8.0),
//                           child: Align(
//                             alignment: isCurrentUser
//                                 ? Alignment.centerRight
//                                 : Alignment.centerLeft,
//                             child: Container(
//                               padding: EdgeInsets.all(12),
//                               decoration: BoxDecoration(
//                                 color: isCurrentUser
//                                     ? Colors.teal[100]
//                                     : Colors.grey[400],
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               child: Text(
//                                 doc['text'],
//                                 style: TextStyle(
//                                   color: Colors.black,
//                                   fontSize: 16,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         );
//                       }).toList(),
//                     );
//                   },
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Row(
//                   children: <Widget>[
//                     Expanded(
//                       child: TextField(
//                         controller: _controller,
//                         decoration: InputDecoration(
//                           labelText: 'Send a message...',
//                           filled: true,
//                           fillColor: Colors.grey[200],
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: BorderSide.none,
//                           ),
//                         ),
//                       ),
//                     ),
//                     IconButton(
//                       icon: Icon(Icons.send, color: Colors.teal),
//                       onPressed: _sendMessage,
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           Positioned.fill(
//             child: Align(
//               alignment: Alignment.center,
//               child: Icon(
//                 Icons.message,
//                 size: 50,
//                 color: Colors.teal[50],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
//
// class ChatScreen extends StatelessWidget {
//   final User? currentUser = FirebaseAuth.instance.currentUser;
//   final String peerId;
//   String peerName;
//   String chatId;
//
//   ChatScreen(
//       {required this.peerId, required this.peerName, required this.chatId});
//   final TextEditingController _controller = TextEditingController();
//
//   void _sendMessage() async {
//     if (_controller.text.isEmpty) return;
//
//     var message = {
//       'text': _controller.text,
//       'userId': currentUser?.uid,
//       'timestamp': FieldValue.serverTimestamp(),
//     };
//     //Get the reference to the specific chat document
//     FirebaseFirestore.instance
//         .collection('chats')
//         .doc(chatId)
//         .collection('messages')
//         .add(message);
//
//     _controller.clear();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Chat with $peerName')),
//       body: Column(
//         children: <Widget>[
//           Expanded(
//             child: StreamBuilder(
//               stream: FirebaseFirestore.instance
//                   .collection('chats')
//                   .doc(chatId)
//                   .collection('messages')
//                   .orderBy('timestamp', descending: true)
//                   .snapshots(),
//               builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
//                 if (!snapshot.hasData)
//                   return Center(child: CircularProgressIndicator());
//
//                 return ListView(
//                   reverse: true,
//                   children: snapshot.data!.docs.map((doc) {
//                     bool isCurrentUser = doc['userId'] == currentUser?.uid;
//                     return Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Align(
//                         alignment: isCurrentUser
//                             ? Alignment.centerRight
//                             : Alignment.centerLeft,
//                         child: Container(
//                           decoration: BoxDecoration(
//                             color: isCurrentUser
//                                 ? Colors.teal[100]
//                                 : Colors.grey[400],
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           padding: const EdgeInsets.all(12.0),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 doc['text'],
//                                 style: TextStyle(
//                                   color: isCurrentUser
//                                       ? Colors.black
//                                       : Colors.black,
//                                 ),
//                               ),
//                               SizedBox(height: 5),
//                             ],
//                           ),
//                         ),
//                       ),
//                     );
//                   }).toList(),
//                 );
//               },
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: <Widget>[
//                 Expanded(
//                   child: TextField(
//                     controller: _controller,
//                     decoration: InputDecoration(
//                       labelText: 'Send a message...',
//                       filled: true,
//                       fillColor: Colors.grey[200],
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                         borderSide: BorderSide.none,
//                       ),
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   icon: Icon(Icons.send, color: Colors.teal),
//                   onPressed: () => _sendMessage(),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
