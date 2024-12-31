// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'client_Choose_Appointment.dart';
//
// class CounselorProfile extends StatefulWidget {
//   final String counselorId;
//   final String userName;
//   final String counselorName;
//
//   CounselorProfile({
//     required this.counselorId,
//     required this.userName,
//     required this.counselorName,
//   });
//
//   @override
//   _CounselorProfileState createState() => _CounselorProfileState();
// }
//
// class _CounselorProfileState extends State<CounselorProfile> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   DocumentSnapshot? counselorData;
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchCounselorData();
//   }
//
//   Future<void> _fetchCounselorData() async {
//     DocumentSnapshot doc =
//         await _firestore.collection('users').doc(widget.counselorId).get();
//     setState(() {
//       counselorData = doc;
//     });
//   }
//
//   void _handleCalendarClick({
//     required String counselorId,
//     required String userName,
//     required String counselorName,
//   }) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => ClientView(
//             counselorId: counselorId,
//             userName: userName,
//             counselorName: counselorName),
//       ),
//     );
//     print('Calendar icon clicked');
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (counselorData == null) {
//       return Scaffold(
//         appBar: AppBar(
//           title: Text(
//             'Counselor Profile',
//             style: TextStyle(color: Colors.white), // Set title color to white
//           ),
//           backgroundColor: Colors.teal,
//         ),
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }
//
//     String name = counselorData!['counselorName'] ?? 'Counselor';
//     String profilePictureUrl = counselorData!['profilePictureUrl'] ?? '';
//     String bio = counselorData!['profile'] ?? 'nil';
//     String qualifications = counselorData!['qualifications'] ?? 'none';
//     int experience = counselorData!['experience'] ?? 0; // in years
//
//     List<String> specializations = counselorData!['specialization'] != null
//         ? List<String>.from(counselorData!['specialization'])
//         : [];
//
//     String email = counselorData!['email'] ?? 'nil';
//     String phoneNumber = counselorData!['phone'] ?? '0';
//
//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         title: Text(
//           '$name Profile',
//           style: TextStyle(color: Colors.white), // Set title color to white
//         ),
//         backgroundColor: Colors.teal,
//       ),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Center(
//               child: CircleAvatar(
//                 radius: 50,
//                 backgroundColor: Colors.grey[200], // Placeholder color
//                 backgroundImage: profilePictureUrl.isNotEmpty
//                     ? NetworkImage(profilePictureUrl)
//                     : null,
//                 child: profilePictureUrl.isEmpty
//                     ? Icon(Icons.person, size: 50)
//                     : null,
//               ),
//             ),
//             SizedBox(height: 16),
//             Text(
//               name,
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.teal,
//               ),
//             ),
//             SizedBox(height: 8),
//             Text(
//               'Bio',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.teal,
//               ),
//             ),
//             Text(
//               bio,
//               style: TextStyle(
//                 fontSize: 16,
//                 color: Colors.teal[900],
//               ),
//             ),
//             SizedBox(height: 8),
//             Text(
//               'Qualifications',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.teal,
//               ),
//             ),
//             Text(
//               qualifications,
//               style: TextStyle(
//                 fontSize: 16,
//                 color: Colors.teal[900],
//               ),
//             ),
//             SizedBox(height: 8),
//             Text(
//               'Experience: $experience years',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.teal,
//               ),
//             ),
//             SizedBox(height: 8),
//             Text(
//               'Specializations',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.teal,
//               ),
//             ),
//             ...specializations.map((spec) => Text(
//                   spec,
//                   style: TextStyle(
//                     fontSize: 16,
//                     color: Colors.teal[900],
//                   ),
//                 )),
//             SizedBox(height: 8),
//             Text(
//               'Contact Information',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.teal,
//               ),
//             ),
//             Text(
//               'Email: $email',
//               style: TextStyle(
//                 fontSize: 16,
//                 color: Colors.teal[900],
//               ),
//             ),
//             Text(
//               'Phone: $phoneNumber',
//               style: TextStyle(
//                 fontSize: 16,
//                 color: Colors.teal[900],
//               ),
//             ),
//             SizedBox(height: 24),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 Column(
//                   children: [
//                     GestureDetector(
//                       onTap: () => _handleCalendarClick(
//                         counselorId: widget.counselorId,
//                         userName: widget.userName,
//                         counselorName: widget.counselorName,
//                       ),
//                       child: CircleAvatar(
//                         radius: 40,
//                         backgroundColor: Colors.teal,
//                         child: Icon(
//                           Icons.calendar_today,
//                           size: 36,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 8),
//                     Text(
//                       'Schedule Appointment',
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: Colors.teal,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//       backgroundColor: Color(0xFFF3E5F5), // Light lilac background
//     );
//   }
// }
