import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat.dart';

class CounselorAppointments extends StatelessWidget {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('  YOUR CLIENTS', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal, // Set the app bar color to teal
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('chats')
            .where('createdWith', isEqualTo: currentUser?.uid)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var chatDocs = snapshot.data!.docs;

          if (chatDocs.isEmpty) {
            return Center(child: Text('No appointments found.'));
          }

          return ListView.builder(
            itemCount: chatDocs.length,
            itemBuilder: (context, index) {
              var chatDoc = chatDocs[index];
              var chatName = chatDoc['name'];
              var peerId = chatDoc['createdBy'];
              var chatId = chatDoc['chatId'];

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: ListTile(
                  leading: Icon(
                    Icons.person,
                    color: Colors.teal,
                    size: 40.0,
                  ),
                  title: Text(
                    chatName,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onTap: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                            peerId: peerId, peerName: chatName, chatId: chatId),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
