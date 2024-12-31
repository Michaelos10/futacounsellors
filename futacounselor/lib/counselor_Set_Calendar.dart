import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CounselorCalendar extends StatefulWidget {
  @override
  _CounselorCalendarState createState() => _CounselorCalendarState();
}

class _CounselorCalendarState extends State<CounselorCalendar> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<TimeRange>> _availability = {};

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadAvailabilities();
  }

  Future<void> _loadAvailabilities() async {
    var snapshot = await _firestore
        .collection('users')
        .doc(_currentUser!.uid) // Use counselor's UID here
        .collection('availabilities')
        .get();

    Map<DateTime, List<TimeRange>> availabilities = {};

    for (var doc in snapshot.docs) {
      DateTime date = (doc['date'] as Timestamp).toDate();
      DateTime normalizedDate = DateTime(date.year, date.month, date.day);

      TimeOfDay start = TimeOfDay(
        hour: doc['start']['hour'],
        minute: doc['start']['minute'],
      );
      TimeOfDay end = TimeOfDay(
        hour: doc['end']['hour'],
        minute: doc['end']['minute'],
      );

      bool isBooked = doc['isBooked'] ?? false; // Fetch isBooked status

      if (availabilities[normalizedDate] == null) {
        availabilities[normalizedDate] = [];
      }
      availabilities[normalizedDate]!.add(TimeRange(
        start: start,
        end: end,
        isBooked: isBooked, // Store isBooked status in TimeRange object
      ));
    }

    setState(() {
      _availability = availabilities;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF7E57C2),
        title: Text('Set your availability',
            style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2000, 1, 1),
            lastDay: DateTime.utc(2100, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              _pickTimeRange(context, selectedDay);
            },
            calendarFormat: _calendarFormat,
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (_availability.containsKey(date)) {
                  return Positioned(
                    bottom: 1,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue,
                      ),
                      child: Center(
                        child: Text(
                          '${_availability[date]?.length}',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                  );
                }
                return SizedBox();
              },
              selectedBuilder: (context, date, _) {
                return Container(
                  margin: const EdgeInsets.all(4.0),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Text(
                    '${date.day}',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              },
              todayBuilder: (context, date, _) {
                bool isBooked =
                    _availability[date]?.any((tr) => tr.isBooked) ?? false;
                return Container(
                  margin: const EdgeInsets.all(4.0),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isBooked ? Colors.green : Colors.blue[300],
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${date.day}',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 8.0),
          Text(
            'All Selected Availabilities:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: ListView(
              children: _availability.keys.map((date) {
                String day = _getDayOfWeek(date);
                return ExpansionTile(
                  title: Text(
                      '$day, ${date.toLocal().toIso8601String().substring(0, 10)}'),
                  children: _availability[date]!.map((timeRange) {
                    Color tileColor =
                        timeRange.isBooked ? Colors.red : Colors.green;

                    return ListTile(
                      title: Text(
                        'From: ${timeRange.start.format(context)} To: ${timeRange.end.format(context)}',
                        style: TextStyle(color: tileColor),
                      ),
                    );
                  }).toList(),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _pickTimeRange(BuildContext context, DateTime selectedDay) async {
    TimeOfDay? startTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: 9, minute: 0),
    );

    if (startTime == null) return;

    TimeOfDay? endTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: 17, minute: 0),
    );

    if (endTime == null) return;

    setState(() {
      if (_availability[selectedDay] == null) {
        _availability[selectedDay] = [];
      }
      _availability[selectedDay]!
          .add(TimeRange(start: startTime, end: endTime, isBooked: false));
    });

    await _saveToFirestore(selectedDay, startTime, endTime);
  }

  Future<void> _saveToFirestore(
      DateTime date, TimeOfDay start, TimeOfDay end) async {
    if (_currentUser == null) {
      print('No user signed in.');
      return;
    }

    try {
      await _firestore
          .collection('users')
          .doc(_currentUser!.uid)
          .collection('availabilities')
          .add({
        'date': Timestamp.fromDate(date),
        'start': {'hour': start.hour, 'minute': start.minute},
        'end': {'hour': end.hour, 'minute': end.minute},
        'isBooked': false,
      });
      print('Data saved to Firestore.');
    } catch (e) {
      print('Failed to save data to Firestore: $e');
    }
  }

  String _getDayOfWeek(DateTime date) {
    List<String> days = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday'
    ];
    return days[date.weekday % 7];
  }
}

class TimeRange {
  final TimeOfDay start;
  final TimeOfDay end;
  bool isBooked;

  TimeRange({required this.start, required this.end, this.isBooked = false});
}
