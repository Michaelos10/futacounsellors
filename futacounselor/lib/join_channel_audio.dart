import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'config/agora.config.dart' as config;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'components/log_sink.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

/// JoinChannelAudio Example
class JoinChannelAudio extends StatefulWidget {
  final String chatId;
  final String peerName;
  final String Id;

  const JoinChannelAudio(
      {Key? key,
      required this.chatId,
      required this.peerName,
      required this.Id})
      : super(key: key); // Constructor requires chatId.

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<JoinChannelAudio> {
  late final RtcEngine _engine;
  Timer? _ringingTimer;
  String channelId = "test";
  String statusIsJoined = "Ringing...";

  bool isJoined = false,
      openMicrophone = true,
      muteMicrophone = false,
      enableSpeakerphone = true,
      playEffect = false;
  bool _isSetDefaultAudioRouteToSpeakerphone = false;
  bool _enableInEarMonitoring = false;
  double _recordingVolume = 100,
      _playbackVolume = 100,
      _inEarMonitoringVolume = 100;
  late TextEditingController _controller;
  ChannelProfileType _channelProfileType =
      ChannelProfileType.channelProfileLiveBroadcasting;
  late final RtcEngineEventHandler _rtcEngineEventHandler;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: channelId);
    _initEngine();
  }

  @override
  void dispose() {
    super.dispose();
    _dispose();
  }

  Future<void> _dispose() async {
    _engine.unregisterEventHandler(_rtcEngineEventHandler);
    await _engine.leaveChannel();
    await _engine.release();
  }

  // Declare a Timer to handle the timeout

  Future<void> _initEngine() async {
    _engine = createAgoraRtcEngine();
    await _engine.initialize(RtcEngineContext(
      appId: config.appId,
    ));

    print("Agora engine initialized.");

    _rtcEngineEventHandler = RtcEngineEventHandler(
      onError: (ErrorCodeType err, String msg) {
        print('[onError] err: $err, msg: $msg');
      },
      onJoinChannelSuccess: (RtcConnection connection, int elapsed) async {
        print("Joined channel successfully: ${connection.channelId}");

        setState(() {
          isJoined = true;
          statusIsJoined = "Ringing...";
        });

        // Firestore: Set `isCalled` to true
        try {
          await FirebaseFirestore.instance
              .collection('names')
              .doc(widget.Id)
              .update({'isCalled': true});
          print("isCalled set to true for peerId: ${widget.Id}");
        } catch (e) {
          print(
              "Failed to update isCalled for peerId: ${widget.Id}, Error: $e");
        }

        // Start the ringing sound
        _engine.playEffect(
          soundId: 2,
          filePath: 'assets/sounds/callTone.mp3',
          loopCount: 2, // Loop indefinitely
          pitch: 1.0,
          pan: 0.0,
          gain: 100,
          publish: false,
        );

        // Start the 40-second timer
        _ringingTimer = Timer(const Duration(seconds: 20), () async {
          print("No user joined within 20 seconds. Ending the call...");

          // Stop the ringtone
          _engine.stopEffect(2);

          // Firestore: Set `isCalled` back to false
          try {
            await FirebaseFirestore.instance
                .collection('names')
                .doc(widget.Id)
                .update({'isCalled': false});
            print("isCalled set to false for peerId: ${widget.Id}");
          } catch (e) {
            print(
                "Failed to reset isCalled for peerId: ${widget.Id}, Error: $e");
          }

          // Leave the channel
          _leaveChannel();

          // Notify the user
          setState(() {
            statusIsJoined = "No response";
          });

          // Close the dialog (if applicable)
          Navigator.of(context).pop();
        });
      },
      onLeaveChannel: (RtcConnection connection, RtcStats stats) async {
        print("Left the channel.");

        setState(() {
          isJoined = false;
        });

        // Stop the ringtone
        _engine.stopEffect(2);

        // Cancel the timer
        _ringingTimer?.cancel();

        // Firestore: Set `isCalled` back to false
        try {
          await FirebaseFirestore.instance
              .collection('names')
              .doc(widget.Id)
              .update({'isCalled': false});
          print("isCalled reset to false for peerId: ${widget.Id}");
        } catch (e) {
          print("Failed to reset isCalled for peerId: ${widget.Id}, Error: $e");
        }
      },
      onUserJoined: (RtcConnection connection, int uid, int elapsed) async {
        print('Remote user joined: $uid in channel: ${connection.channelId}');

        // Stop the ringtone
        _engine.stopEffect(2);

        // Cancel the timer
        _ringingTimer?.cancel();

        // Firestore: Set `isCalled` to false
        try {
          await FirebaseFirestore.instance
              .collection('names')
              .doc(widget.Id)
              .update({'isCalled': false});
          print("isCalled reset to false for peerId: ${widget.Id}");
        } catch (e) {
          print("Failed to reset isCalled for peerId: ${widget.Id}, Error: $e");
        }

        setState(() {
          statusIsJoined = "Session Ongoing with ${widget.peerName}";
        });

        // Optional notification when a user joins
        _engine.playEffect(
          soundId: 3,
          filePath: 'assets/sounds/ding.mp3',
          loopCount: 1, // Play once
          pitch: 1.0,
          pan: 0.0,
          gain: 100,
          publish: false,
        );
      },
      onUserOffline:
          (RtcConnection connection, int uid, UserOfflineReasonType reason) {
        print('Remote user left: $uid in channel: ${connection.channelId}');
        setState(() {
          statusIsJoined = "${widget.peerName} left";
        });
        _leaveChannel();
        Navigator.of(context).pop();
      },
    );

    _engine.registerEventHandler(_rtcEngineEventHandler);

    await _engine.enableAudio();
    await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await _engine.setAudioProfile(
      profile: AudioProfileType.audioProfileDefault,
      scenario: AudioScenarioType.audioScenarioGameStreaming,
    );
    _joinChannel();
  }

  Future<void> _joinChannel() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      await Permission.microphone.request();
      if (!await Permission.microphone.isGranted) {
        print("Microphone permission not granted.");
        return;
      }
    }

    print("Joining channel...");
    await _engine.joinChannel(
      token: config.token, // Replace with your token for testing
      channelId: widget.chatId,
      uid: 0,
      options: ChannelMediaOptions(
        channelProfile: _channelProfileType,
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
      ),
    );
  }

  _leaveChannel() async {
    await _engine.leaveChannel();
    setState(() {
      isJoined = false;
      openMicrophone = true;
      muteMicrophone = false;
      enableSpeakerphone = true;
      playEffect = false;
      _enableInEarMonitoring = false;
      _recordingVolume = 100;
      _playbackVolume = 100;
      _inEarMonitoringVolume = 100;
    });
  }

  void _toggleMicrophone() async {
    await _engine.muteLocalAudioStream(openMicrophone);
    setState(() {
      openMicrophone = !openMicrophone;
    });
  }

  _muteLocalAudioStream() async {
    await _engine.muteLocalAudioStream(!muteMicrophone);
    setState(() {
      openMicrophone = !openMicrophone;
    });
  }

  void _toggleSpeakerphone() async {
    await _engine.setEnableSpeakerphone(!enableSpeakerphone);
    setState(() {
      enableSpeakerphone = !enableSpeakerphone;
    });
  }

  _onChangeInEarMonitoringVolume(double value) async {
    _inEarMonitoringVolume = value;
    await _engine.setInEarMonitoringVolume(_inEarMonitoringVolume.toInt());
    setState(() {});
  }

  _toggleInEarMonitoring(value) async {
    try {
      await _engine.enableInEarMonitoring(
          enabled: value,
          includeAudioFilters: EarMonitoringFilterType.earMonitoringFilterNone);
      _enableInEarMonitoring = value;
      setState(() {});
    } catch (e) {
      // Do nothing
    }
  }

  @override
  Widget build(BuildContext context) {
    final channelProfileType = [
      ChannelProfileType.channelProfileLiveBroadcasting,
      ChannelProfileType.channelProfileCommunication,
    ];
    final items = channelProfileType
        .map((e) => DropdownMenuItem(
              child: Text(
                e.toString().split('.')[1],
              ),
              value: e,
            ))
        .toList();

    return Dialog(
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        height: 350,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Connection Status
            if (isJoined)
              Column(
                children: [
                  Text(
                    statusIsJoined,
                    style: TextStyle(color: Colors.white),
                  ),
                  // Show remote user status
                ],
              )
            else
              const CircularProgressIndicator(),
            const SizedBox(height: 20),
            // Control Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Mute Button
                IconButton(
                  icon: Icon(
                    openMicrophone ? Icons.mic : Icons.mic_off,
                    color: Colors.white,
                    size: 30,
                  ),
                  onPressed: _toggleMicrophone,
                ),
                IconButton(
                  icon: const Icon(
                    Icons.call_end,
                    color: Colors.red,
                    size: 30,
                  ),
                  onPressed: () async {
                    Navigator.of(context).pop(); // Close the dialog
                    _leaveChannel();
                    try {
                      await FirebaseFirestore.instance
                          .collection('names')
                          .doc(widget.Id)
                          .update({'isCalled': false});
                      print("isCalled reset to false for peerId: ${widget.Id}");
                    } catch (e) {
                      print(
                          "Failed to reset isCalled for peerId: ${widget.Id}, Error: $e");
                    }
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
