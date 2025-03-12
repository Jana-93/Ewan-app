
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/callVideo/data/model/agora_manager_model.dart';

class GameScreen extends StatefulWidget {
  final RtcEngine engine;
  final int? remoteUid;
  final bool localUserJoined;
  final bool initialCameraOff;
  final bool initialMuted;

  const GameScreen({
    super.key,
    required this.engine,
    required this.remoteUid,
    required this.localUserJoined,
    this.initialCameraOff = false,
    this.initialMuted = false,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  Offset _floatingPosition = const Offset(100, 100);
  late bool _remoteMuted;
  late bool _remoteCameraOff;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _remoteMuted = widget.initialMuted;
    _remoteCameraOff = widget.initialCameraOff;

    widget.engine.registerEventHandler(
      RtcEngineEventHandler(
        onUserMuteAudio: (connection, uid, muted) {
          if (uid == widget.remoteUid) setState(() => _remoteMuted = muted);
        },
        onUserEnableVideo: (connection, uid, enabled) {
          if (uid == widget.remoteUid)
            setState(() => _remoteCameraOff = !enabled);
        },
      ),
    );

    _listenForRemoteCameraState();
  }

  void _listenForRemoteCameraState() {
    _firestore.collection('cameraState').doc("cameraState").snapshots().listen((snapshot) {
      if (snapshot.exists) {
        setState(() {
          _remoteCameraOff = snapshot.data()?['doctorCameraOff'] ?? false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('صفحة اللعبة')),
      body: Stack(
        children: [
          const Center(child: Text('محتوى صفحة اللعبة')),
          Positioned(
            left: _floatingPosition.dx,
            top: _floatingPosition.dy,
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() => _floatingPosition += details.delta);
              },
              child: SizedBox(
                width: 150,
                height: 200,
                child: Stack(
                  children: [
                    _remoteVideo(),
                    if (_remoteMuted)
                      const Positioned(
                        top: 5,
                        right: 5,
                        child: Icon(Icons.mic_off, color: Colors.white),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _remoteVideo() {
    if (widget.remoteUid != null) {
      return _remoteCameraOff
          ? Center(
              child: Container(
                color: Colors.grey[200],
                child: const Icon(Icons.videocam_off, size: 60),
              ),
            )
          : AgoraVideoView(
              controller: VideoViewController.remote(
                rtcEngine: widget.engine,
                canvas: VideoCanvas(uid: widget.remoteUid),
                connection:
                    RtcConnection(channelId: AgoraManagerModel.channelName),
              ),
            );
    } else {
      return const Center(child: Text('الطرف الاخر ليس متصل'));
    }
  }
}