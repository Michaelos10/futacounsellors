// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// jk
// class IncomingCallDialogHandler extends StatefulWidget {
//   final String peerId;
//
//   const IncomingCallDialogHandler({Key? key, required this.peerId})
//       : super(key: key);
//
//   @override
//   _IncomingCallDialogHandlerState createState() =>
//       _IncomingCallDialogHandlerState();
// }
//
// class _IncomingCallDialogHandlerState extends State<IncomingCallDialogHandler> {
//   bool isCalled =
//       false; // Local variable to track the status of the incoming call
//
//   @override
//   void initState() {
//     super.initState();
//     _listenForIncomingCall();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return isCalled
//         ? Center(
//             child: Dialog(
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(20),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text("Incoming Call", style: TextStyle(fontSize: 20)),
//                     SizedBox(height: 20),
//                     ElevatedButton(
//                       onPressed: () {
//                         // Handle accepting the call, for example, by navigating to the call screen
//                         Navigator.of(context).pop(); // Close the dialog
//                       },
//                       child: Text("Accept Call"),
//                     ),
//                     ElevatedButton(
//                       onPressed: () {
//                         // Handle rejecting the call, by updating 'isCalled' in Firestore to false
//                         FirebaseFirestore.instance
//                             .collection('users')
//                             .doc(widget.peerId)
//                             .update({'isCalled': false});
//                         Navigator.of(context).pop(); // Close the dialog
//                       },
//                       child: Text("Reject Call"),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           )
//         : SizedBox(); // No dialog if 'isCalled' is false
//   }
//
//   // Function to listen for the 'isCalled' field changes in Firestore
//   Future<void> _listenForIncomingCall() async {
//     FirebaseFirestore.instance
//         .collection('users')
//         .doc(widget.peerId)
//         .snapshots()
//         .listen((snapshot) {
//       if (snapshot.exists && snapshot.data() != null) {
//         final isCalledField = snapshot.data()?['isCalled'];
//         if (isCalledField == true) {
//           setState(() {
//             isCalled = true;
//           });
//         } else {
//           setState(() {
//             isCalled = false;
//           });
//         }
//       }
//     });
//   }
// }
