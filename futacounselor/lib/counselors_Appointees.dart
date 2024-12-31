import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'chat.dart';

class Appointment {
  final String name;
  final String email;
  final Map<String, dynamic> start;
  final DateTime date;
  final bool isBooked;
  final String clientUid;

  Appointment({
    required this.name,
    required this.email,
    required this.start,
    required this.date,
    required this.isBooked,
    required this.clientUid,
  });

  factory Appointment.fromFirestore(DocumentSnapshot doc) {
    try {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return Appointment(
        name: data['clientName'] ?? 'No name',
        email: data['clientEmail'] ?? 'No Email',
        start: data['start'] ?? {},
        date: (data['date'] as Timestamp).toDate(),
        isBooked: data['isBooked'] ?? false,
        clientUid: data['clientUid'] ?? '',
      );
    } catch (e) {
      print('Error creating Appointment from Firestore: $e');
      throw e;
    }
  }
}

class CounselorsAppointees extends StatefulWidget {
  @override
  _CounselorsAppointeesState createState() => _CounselorsAppointeesState();
}

class _CounselorsAppointeesState extends State<CounselorsAppointees> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? currentUser;
  late Stream<List<Appointment>> appointmentsStream;

  Future<String?> fetchChatId(String clientUid) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('chats')
          .where('createdBy', isEqualTo: clientUid)
          .where('createdWith', isEqualTo: currentUser!.uid)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        Map<String, dynamic> data =
            querySnapshot.docs.first.data() as Map<String, dynamic>;
        return data['chatId'];
      } else {
        print('No chat found');
        return null;
      }
    } catch (e) {
      print('Error checking chats: $e');
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    currentUser = _auth.currentUser;
    appointmentsStream = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .collection('availabilities')
        .where('isBooked', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Appointment.fromFirestore(doc))
            .toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF7E57C2),
        title: Text(
          'Counselors Appointments',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: StreamBuilder<List<Appointment>>(
        stream: appointmentsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No appointments found.'));
          }

          snapshot.data!.sort((a, b) {
            int dateComparison = a.date.compareTo(b.date);
            if (dateComparison == 0) {
              int hourA = a.start['hour'];
              int minuteA = a.start['minute'];
              int hourB = b.start['hour'];
              int minuteB = b.start['minute'];
              int timeA = hourA * 60 + minuteA;
              int timeB = hourB * 60 + minuteB;
              return timeA.compareTo(timeB);
            }
            return dateComparison;
          });

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              Appointment appointment = snapshot.data![index];
              String formattedDate =
                  '${appointment.date.day}/${appointment.date.month}/${appointment.date.year}';
              String dayOfWeek = '';
              DateTime now = DateTime.now();
              if (appointment.date.year == now.year &&
                  appointment.date.month == now.month &&
                  appointment.date.day == now.day) {
                dayOfWeek = 'Today';
              } else {
                dayOfWeek = DateFormat.E().format(appointment.date);
              }

              String hourMinute =
                  '${appointment.start['hour']}:${appointment.start['minute']}';
              String amPm = '';
              List<String> timeComponents = hourMinute.split(':');
              int hour = int.parse(timeComponents[0]);
              int minute = int.parse(timeComponents[1]);

              if (hour >= 12) {
                amPm = 'PM';
                hour = hour == 12 ? 12 : hour - 12;
              } else {
                amPm = 'AM';
                hour = hour == 0 ? 12 : hour;
              }

              String formattedTime = '$hour:$minute $amPm';
              String clientUid = appointment.clientUid;

              return GestureDetector(
                onTap: () async {
                  String? chatId = await fetchChatId(clientUid);
                  if (chatId != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          userId: currentUser!.uid,
                          peerId: clientUid,
                          peerName: appointment.name,
                          chatId: chatId,
                        ),
                      ),
                    );
                  } else {
                    // Handle the case where chatId is null (e.g., show a message to the user)
                    print('Chat ID not found.');
                  }
                },
                child: ListTile(
                  leading: Icon(
                    Icons.person,
                    color: Color(0xFF9575CD),
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          appointment.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        '($dayOfWeek, $formattedDate)',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  subtitle: Text(
                    '$formattedTime',
                    style: TextStyle(
                      color: Color(0xFF9575CD),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class UpcomingAppointmentsTile extends StatefulWidget {
  @override
  _UpcomingAppointmentsTileState createState() =>
      _UpcomingAppointmentsTileState();
}

class _UpcomingAppointmentsTileState extends State<UpcomingAppointmentsTile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? currentUser;
  late Stream<QuerySnapshot> appointmentsStream;

  @override
  void initState() {
    super.initState();
    currentUser = _auth.currentUser;
    appointmentsStream = _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('availabilities')
        .where('isBooked', isEqualTo: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: appointmentsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No upcoming appointments.'));
        }

        List<QueryDocumentSnapshot> documents = snapshot.data!.docs;

        // Sort documents by date and time
        documents.sort((a, b) {
          DateTime dateA = (a['date'] as Timestamp).toDate();
          DateTime dateB = (b['date'] as Timestamp).toDate();
          int dateComparison = dateA.compareTo(dateB);
          if (dateComparison == 0) {
            int hourA = a['start']['hour'];
            int minuteA = a['start']['minute'];
            int hourB = b['start']['hour'];
            int minuteB = b['start']['minute'];
            int timeA = hourA * 60 + minuteA;
            int timeB = hourB * 60 + minuteB;
            return timeA.compareTo(timeB);
          }
          return dateComparison;
        });

        // Get the three upcoming appointments
        List<QueryDocumentSnapshot> upcomingAppointments =
            documents.take(3).toList();

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(100.0), // Adjust the radius as needed
          ),
          child: ListTile(
            tileColor: Colors.white, // Set the background color of the tile
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: upcomingAppointments.map((doc) {
                String name = doc['clientName'];
                DateTime date = (doc['date'] as Timestamp).toDate();
                String formattedDate = '${date.day}/${date.month}/${date.year}';
                String hourMinute =
                    '${doc['start']['hour']}:${doc['start']['minute']}';
                String amPm = '';
                List<String> timeComponents = hourMinute.split(':');
                int hour = int.parse(timeComponents[0]);
                int minute = int.parse(timeComponents[1]);

                if (hour >= 12) {
                  amPm = 'PM';
                  hour = hour == 12 ? 12 : hour - 12;
                } else {
                  amPm = 'AM';
                  hour = hour == 0 ? 12 : hour;
                }

                String formattedTime =
                    '$hour:${minute.toString().padLeft(2, '0')} $amPm';
                String dayOfWeek = '';
                DateTime now = DateTime.now();
                if (date.year == now.year &&
                    date.month == now.month &&
                    date.day == now.day) {
                  dayOfWeek = 'Today';
                } else {
                  dayOfWeek = DateFormat.E().format(date);
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        '($dayOfWeek, $formattedDate)',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        formattedTime,
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}
