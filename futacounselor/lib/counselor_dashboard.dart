import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'counselor_login_page.dart';
import 'counselors_Appointees.dart';
import 'counselor_Set_Calendar.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class CounselorDashboard extends StatelessWidget {
  final _auth = FirebaseAuth.instance;

  Future<void> _handleSignOut(BuildContext context) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'online': false, 'last_active': Timestamp.now()});

        await _auth.signOut();
        print('User signed out and marked offline.');
      }
    } catch (e) {
      print('Error signing out: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out. Please try again.')),
      );
    }
  }

  void _showExitConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dialog dismissal on tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Exit"),
          content: Text("Are you sure you want to exit the app?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Close the dialog
              child: Text(
                "Cancel",
                style: TextStyle(color: Colors.grey[700]),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  // Optional: Sign out logic before exiting
                  await _handleSignOut(context);
                } catch (e) {
                  print("Error during sign-out: $e");
                }

                // Close the app only on Android
                if (defaultTargetPlatform == TargetPlatform.android) {
                  SystemNavigator.pop();
                } else {
                  // On iOS, show a message or simply close the dialog
                  Navigator.of(context).pop();
                  print("Exiting the app is not allowed on iOS.");
                }
              },
              child: Text("Exit"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF7E57C2), // Deep purple
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, //(0xFFEDE7F6), // Light purple background
      appBar: AppBar(
        backgroundColor: Color(0xFF7E57C2),
        title: Text(
          'Your Dashboard',
          style: TextStyle(color: Colors.white),
        ),
        elevation: 0.0,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.black),
            onPressed: () async {
              _showExitConfirmationDialog(context);
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                decoration: BoxDecoration(
                  color: Color(0xFF9575CD), // Deep purple for the container
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Row(
                  children: [
                    Text(
                      ('Welcome, ${_auth.currentUser?.email ?? 'Guest'}'),
                      style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white), // White text on purple
                    ),
                    Spacer(),
                    Icon(Icons.notifications, color: Colors.white),
                  ],
                ),
              ),
              SizedBox(height: 20.0),
              Wrap(
                spacing: 20.0,
                runSpacing: 20.0,
                children: [
                  ActionTile(
                    title: ' Set Calendar  ',
                    icon: Icon(Icons.calendar_today,
                        color: Color(0xFF9575CD)), // Light purple
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CounselorCalendar()),
                    ),
                  ),
                  Spacer(),
                  ActionTile(
                    title: 'Notes & Journal',
                    icon: Icon(Icons.edit,
                        color: Color(0xFF9575CD)), // Light purple
                    onTap: () => print('Notes & Journal'),
                  ),
                ],
              ),
              SizedBox(height: 20.0),
              Container(
                padding: EdgeInsets.all(15.0),
                decoration: BoxDecoration(
                  color: Color(
                      0xFFD1C4E9), //(                      0xFFE1BEE7), // A light lavender for appointments section
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ' Upcoming Appointments',
                      style: TextStyle(
                          fontSize: 16.0, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10.0),
                    UpcomingAppointmentsTile(),
                    SizedBox(height: 10.0),
                    TextButton(
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CounselorsAppointees())),
                      child: Text('View All Appointments'),
                      style: TextButton.styleFrom(
                        backgroundColor:
                            Color(0xFF7E57C2), // Medium purple for button
                        foregroundColor: Colors.white, // White text color
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.0),
              Container(
                padding: EdgeInsets.all(15.0),
                decoration: BoxDecoration(
                  color: Color(
                      0xFFD1C4E9), // Light purple for the spotlight section
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ActionTile extends StatelessWidget {
  final String title;
  final Icon icon;
  final VoidCallback onTap;

  const ActionTile(
      {required this.title, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(15.0),
        decoration: BoxDecoration(
          color: Color(0xFFEDE7F6), // Lighter purple background for each tile
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            SizedBox(height: 5.0),
            Text(title,
                style: TextStyle(
                    color: Colors.black)), // Text color for readability
          ],
        ),
      ),
    );
  }
}
//
// class AppointmentTile extends StatelessWidget {
//   final String clientName;
//   final String time;
//   final String status;
//   final VoidCallback? onTap;
//
//   const AppointmentTile({
//     required this.clientName,
//     required this.time,
//     required this.status,
//     this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onTap,
//       child: Row(
//         children: [
//           Text(
//             clientName,
//             style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
//           ),
//           Spacer(),
//           Text(
//             time,
//             style: TextStyle(fontSize: 14.0),
//           ),
//           Spacer(),
//           Container(
//             padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 2.0),
//             decoration: BoxDecoration(
//               color: status == 'Confirmed'
//                   ? Color(0xFF8E24AA) // Purple for confirmed status
//                   : status == 'Pending Confirmation'
//                       ? Color(0xFFD1C4E9) // Light purple for pending
//                       : Colors.red, // Red for other statuses
//               borderRadius: BorderRadius.circular(5.0),
//             ),
//             child: Text(
//               status,
//               style: TextStyle(color: Colors.white, fontSize: 12.0),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
