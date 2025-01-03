import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class CallNotificationPage extends StatefulWidget {
  final String callerName;
  final String callerId;

  const CallNotificationPage({
    Key? key,
    required this.callerName,
    required this.callerId,
  }) : super(key: key);

  @override
  _CallNotificationPageState createState() => _CallNotificationPageState();
}

class _CallNotificationPageState extends State<CallNotificationPage>
    with SingleTickerProviderStateMixin {
  late AudioPlayer _audioPlayer;
  double _iconSize = 24.0; // Initial size of the animated icon

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _playRingtone();
    _startIconAnimation();
  }

  Future<void> _playRingtone() async {
    await _audioPlayer.play(
      AssetSource(
          'sounds/ringtone.mp3'), // Ensure this file exists in your assets
      volume: 1.0,
    );
  }

  void _startIconAnimation() {
    Future.delayed(Duration(milliseconds: 250), () {
      if (mounted) {
        setState(() {
          _iconSize = _iconSize == 24.0 ? 30.0 : 24.0; // Toggle icon size
        });
        _startIconAnimation();
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.stop(); // Stop the ringtone when the page is closed
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo.shade50,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Incoming Call...',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(width: 8),
                AnimatedContainer(
                  duration: Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  width: _iconSize,
                  height: _iconSize,
                  child: Icon(
                    Icons.call,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Icon(
              Icons.account_circle,
              size: 120,
              color: Color(0xFF512DA8),
            ),
            SizedBox(height: 20),
            Text(
              widget.callerName,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    print('Call Accepted');
                    // Add your accept call logic here
                  },
                  icon: Icon(Icons.call, color: Colors.white),
                  label: Text('Accept'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(300),
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    print('Call Rejected');
                    // Add your reject call logic here
                  },
                  icon: Icon(Icons.call_end, color: Colors.white),
                  label: Text('Reject'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(300),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
