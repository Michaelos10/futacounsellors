import 'dart:async';
import 'dart:html';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:js' as js;

// Replace with your Agora App ID, Token, and Channel Name
const appId = "8d072eeda64f4b7391fe34108a5b9385";
const token = ""; // Use a valid token if required by Agora settings

class VoiceCallDialog extends StatefulWidget {
  final String chatId;

  const VoiceCallDialog({
    Key? key,
    required this.chatId,
  }) : super(key: key);

  @override
  _VoiceCallDialogState createState() => _VoiceCallDialogState();
}

class _VoiceCallDialogState extends State<VoiceCallDialog> {
  bool _localUserJoined = false;
  int? _remoteUid;
  bool _isMuted = false;
  bool _isSpeakerOn = false;

  @override
  void initState() {
    super.initState();
    initAgoraWeb();
    //setupJavascriptHandlers();
  }

  Future<void> initAgoraWeb() async {
    if (window.navigator.mediaDevices == null) {
      print('MediaDevices not supported on web.');
      return;
    }

    final stream =
        await window.navigator.mediaDevices!.getUserMedia({'audio': true});
    print('Microphone permission granted on web.');

    final client = js.context.callMethod('createAgoraClient');
    print("client created");
    if (client != null) {
      // Define Dart functions to handle success and failure of joining the channel
      var onJoinSuccess = js.allowInterop((uid) {
        setState(() {
          _localUserJoined = true;
        });
        print("User joined with UID: $uid");
      });

      var onJoinFailure = js.allowInterop((error) {
        print("Failed to join channel: $error");
      });

      // Call the JavaScript function to join the Agora channel
      js.context.callMethod('joinAgoraChannel', [
        client,
        token,
        widget.chatId,
        0, // UID
        onJoinSuccess,
        onJoinFailure
      ]);
    } else {
      print("Error: Agora client could not be created.");
    }
  }

  // void setupJavascriptHandlers() {
  //   // Define Dart functions that JavaScript will call when remote users join/leave
  //   js.context['onRemoteUserJoined'] = (int uid) {
  //     setState(() {
  //       _remoteUid = uid;
  //     });
  //     print("Remote user joined with UID: $uid");
  //   };
  //
  //   js.context['onRemoteUserLeft'] = (int uid) {
  //     setState(() {
  //       if (_remoteUid == uid) {
  //         _remoteUid = null;
  //       }
  //     });
  //     print("Remote user left with UID: $uid");
  //   };
  // }

  Future<void> _dispose() async {
    if (kIsWeb) {
      // Call JavaScript function to leave Agora channel
      js.context.callMethod('leaveAgoraChannel', []);
    }
  }

  @override
  void dispose() {
    _dispose();
    super.dispose();
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });
    if (kIsWeb) {
      // Call JavaScript function to toggle mute
      js.context.callMethod('toggleMute', [_isMuted]);
    }
  }

  void _toggleSpeaker() {
    setState(() {
      _isSpeakerOn = !_isSpeakerOn;
    });
    if (kIsWeb) {
      // Call JavaScript function to toggle speaker
      js.context.callMethod('toggleSpeaker', [_isSpeakerOn]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        height: 350,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_localUserJoined)
              Column(
                children: [
                  const Text(
                    'Calling...',
                    style: TextStyle(color: Colors.white),
                  ),
                  _remoteUid != null
                      ? Text(
                          'Remote user $_remoteUid joined',
                          style: const TextStyle(color: Colors.white),
                        )
                      : const Text(
                          'Waiting for other user...',
                          style: TextStyle(color: Colors.white),
                        ),
                ],
              )
            else
              const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Mute Button
                IconButton(
                  icon: Icon(
                    _isMuted ? Icons.mic_off : Icons.mic,
                    color: Colors.white,
                    size: 30,
                  ),
                  onPressed: _toggleMute,
                ),
                // Speaker/Phone Button
                IconButton(
                  icon: Icon(
                    _isSpeakerOn ? Icons.volume_up : Icons.phone_in_talk,
                    color: Colors.white,
                    size: 30,
                  ),
                  onPressed: _toggleSpeaker,
                ),
                // End Call Button
                IconButton(
                  icon: const Icon(
                    Icons.call_end,
                    color: Colors.red,
                    size: 30,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                    _dispose();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
