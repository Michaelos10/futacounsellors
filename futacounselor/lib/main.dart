import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'counselor_Set_Calendar.dart';
import 'counselor_login_page.dart';
import 'dart:html'; // For browser-specific events
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'dart:html'; // For browser-specific events
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart'; // For DefaultFirebaseOptions
import 'counselor_login_page.dart';
import 'incoming_call.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _setupUserPresence();
    // IncomingCallDialogHandler(peerId: 'iPgAMiSFKxXjU1fw7IktfBiKzrf2');
  }
//sj
  /// Tracks user presence based on authentication state and browser events
  void _setupUserPresence() {
    // Listen for authentication state changes
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        _setOnlineStatus(user.uid, true);

        // Listen for page unload (close tab or refresh)
        window.onBeforeUnload.listen((event) async {
          await _setOnlineStatus(user.uid, false);
        });

        // Handle tab visibility changes (switching tabs)
        document.onVisibilityChange.listen((event) async {
          if (document.visibilityState == 'hidden') {
            await _setOnlineStatus(user.uid, false);
          } else {
            await _setOnlineStatus(user.uid, true);
          }
        });
      }
    });
  }

  /// Updates the user's online status in Firestore
  Future<void> _setOnlineStatus(String uid, bool isOnline) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'online': isOnline,
        'last_active': Timestamp.now(),
      });
    } catch (e) {
      print('Error updating online status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FUTA Counsellor',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: AppBarTheme(iconTheme: IconThemeData(color: Colors.white)),
      ),
      home: CounselorLoginPage(), // Replace with your actual login page
    );
  }
}

/*
// CHALLENGES TO SOLVE

// 11/6/24 let the choosen date reflect on the clients calendar and once clicked the a list of time should appear.
//      once the time tile is clicked let the appointment class be updated with the selected time along the name.

// --create a apppointment scheduling session
//   -display counsellors time plans for 3days
//   -take clients choice and update to DB
//   -attach a no. to the appointment and send to client
//--collects only Name and Email
//  -collects email during appointment scheduling and send both userId and a reminder through
//      mail.
//29-6-24
//   -receives this userId from the user at the login page, and open the chat room created with the user Id
//  - create a widget at the login page,
//      -showing the services offered by the coundseling unit
//      -change the login to book_appointment or schedule_appointment
//      - then use the continue or chat button after inserting the userId to go straight to the chat room
//
//1/7/24
//  Delete used/unused anonymous, appointment and chats info

//we Can consider user sign up much later once this idea is rolling
//

//  --Sign-up clients with ewmail and password
// -- Eliminate the anonymous chat and Sign_up users
//  -store chat data locally but transmit it through firestore
//
//
//  */
/* TO DEPLOY WEB APP
flutter build web
firebase login
firebase init
firebase deploy

 */