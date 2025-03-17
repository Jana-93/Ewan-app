import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter_application_1/callVideo/data/model/agora_manager_model.dart';
import 'package:flutter_application_1/callVideo/presentation/views/game_screen.dart';
import 'package:flutter_application_1/screens/childFeedback.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VideoCallScreen extends StatefulWidget {
  final String user;
  const VideoCallScreen({super.key, required this.user});

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  int? _remoteUid;
  bool _localUserJoined = false;
  bool _isMuted = false;
  bool _isCameraOn = true;
  bool _remoteMuted = false;
  bool _remoteCameraOff = false;
  late RtcEngine _engine;
  VideoPlayerController? _introVideoController;
  VideoPlayerController? _outroVideoController;
  bool _isIntroVideoPlaying = true;
  bool _isOutroVideoPlaying = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    if (widget.user == "patient") {
      _initVideos();
    }
    initAgora();
    _listenForGameScreenNavigation();
    _listenForRemoteCameraState();
  }

  Future<void> _initVideos() async {
    _introVideoController = VideoPlayerController.asset('assets/video/first.mp4')
      ..initialize().then((_) {
        setState(() {});
        _introVideoController!.play();
        _introVideoController!.addListener(() {
          if (!_introVideoController!.value.isPlaying &&
              _introVideoController!.value.position >=
                  _introVideoController!.value.duration) {
            setState(() {
              _isIntroVideoPlaying = false;
            });
          }
        });
      });

    _outroVideoController = VideoPlayerController.asset('assets/video/end.mp4')
      ..initialize().then((_) {
        setState(() {});
      });
  }

  Future<void> initAgora() async {
    await [Permission.microphone, Permission.camera].request();

    _engine = createAgoraRtcEngine();
    await _engine.initialize(
      RtcEngineContext(
        appId: AgoraManagerModel.appId,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
      ),
    );

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (connection, elapsed) {
          setState(() => _localUserJoined = true);
        },
        onUserJoined: (connection, remoteUid, elapsed) {
          setState(() => _remoteUid = remoteUid);
        },
        onUserOffline: (connection, remoteUid, reason) {
          setState(() {
            _remoteUid = null;
            _remoteMuted = false;
            _remoteCameraOff = false;
          });
        },
        onUserMuteAudio: (connection, uid, muted) {
          if (uid == _remoteUid) setState(() => _remoteMuted = muted);
        },
        onUserEnableVideo: (connection, uid, enabled) {
          if (uid == _remoteUid) setState(() => _remoteCameraOff = !enabled);
        },
      ),
    );

    await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await _engine.enableVideo();
    await _engine.startPreview();

    await _engine.joinChannel(
      token: AgoraManagerModel.token,
      channelId: AgoraManagerModel.channelName,
      uid: 0,
      options: const ChannelMediaOptions(),
    );
  }

  void _listenForGameScreenNavigation() {
    if (widget.user == "doctor") {
      _firestore.collection('calls').doc("calls").snapshots().listen((snapshot) {
        if (snapshot.exists && snapshot.data()?['navigateToGame'] == true) {
          _navigateToGameScreen();
        }
      });
    }
  }

  void _listenForRemoteCameraState() {
    _firestore.collection('cameraState').doc("cameraState").snapshots().listen((snapshot) {
      if (snapshot.exists) {
        setState(() {
          if (widget.user == "doctor") {
            _remoteCameraOff = snapshot.data()?['patientCameraOff'] ?? false;
          } else {
            _remoteCameraOff = snapshot.data()?['doctorCameraOff'] ?? false;
          }
        });
      }
    });
  }

  void _updateCameraState(bool isCameraOn) {
    if (widget.user == "doctor") {
      _firestore.collection('cameraState').doc("cameraState").update({
        'doctorCameraOff': !isCameraOn,
      });
    } else {
      _firestore.collection('cameraState').doc("cameraState").update({
        'patientCameraOff': !isCameraOn,
      });
    }
  }

  @override
  void dispose() {
    _dispose();
    if (widget.user == "patient") {
      _introVideoController!.dispose();
      _outroVideoController!.dispose();
    }
    super.dispose();
  }

  Future<void> _dispose() async {
    await _engine.leaveChannel();
    await _engine.release();
  }

  void _toggleMute() {
    setState(() => _isMuted = !_isMuted);
    _engine.muteLocalAudioStream(_isMuted);
  }

  void _toggleCamera() {
    setState(() => _isCameraOn = !_isCameraOn);
    _engine.enableLocalVideo(_isCameraOn);
    _updateCameraState(_isCameraOn);
  }

  void _endCall() {
    if (widget.user == "patient") {
      setState(() {
        _isOutroVideoPlaying = true;
        _outroVideoController!.play();
      });

      _outroVideoController!.addListener(() {
        if (!_outroVideoController!.value.isPlaying &&
            _outroVideoController!.value.position >=
                _outroVideoController!.value.duration) {
          _outroVideoController!.dispose();
          Navigator.pop(context);
        }
      });
    } else {
      Navigator.pop(context);
    }

    if (widget.user == "patient") {
      _firestore.collection('calls').doc("calls").set({
        'navigateToGame': false,
      });
    }
  }

  void _navigateToGameScreen() {
    if (widget.user == "patient") {
      _firestore.collection('calls').doc("calls").set({'navigateToGame': true});
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameScreen(
          engine: _engine,
          remoteUid: _remoteUid,
          localUserJoined: _localUserJoined,
          initialCameraOff: _remoteCameraOff,
          initialMuted: _remoteMuted,
        ),
      ),
    );
  }

  void _showAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: Text('انهاء', style: TextStyle(color: Colors.orange, fontSize: 20.sp)),
            content: Text('هل انت متأكد من انهاء الجلسة؟', style: TextStyle(fontSize: 16.sp)),
            actions: <Widget>[
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        _endCall();
                        Navigator.of(context).pop();
                      },
                      child: Text('نعم', style: TextStyle(fontSize: 14.sp)),
                    ),
                    SizedBox(width: 15.w),
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('لا', style: TextStyle(fontSize: 14.sp)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _skipIntroVideo() {
    setState(() {
      _isIntroVideoPlaying = false;
      _introVideoController!.pause();
    });
  }

  void _outerIntroVideo() {
    setState(() {
      _isOutroVideoPlaying = false;
      _outroVideoController!.pause();
      Navigator.pop(context);
    });
    _navigateToChildFeedbackScreen();
  }

  void _navigateToChildFeedbackScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChildFeedback()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.orange,
          title: Text(
            'مكالمة فيديو',
            style: TextStyle(color: Colors.white, fontSize: 20.sp),
          ),
        ),
        body: Stack(
          children: [
            if (_isIntroVideoPlaying && widget.user == "patient")
              Stack(
                children: [
                  Center(
                    child: _introVideoController!.value.isInitialized
                        ? SizedBox(
                            width: double.infinity,
                            child: AspectRatio(
                              aspectRatio: _introVideoController!.value.aspectRatio,
                              child: VideoPlayer(_introVideoController!),
                            ),
                          )
                        : CircularProgressIndicator(),
                  ),
                  Positioned(
                    top: 20.h,
                    right: 20.w,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _skipIntroVideo,
                      child: Text('تخطي', style: TextStyle(fontSize: 14.sp)),
                    ),
                  ),
                ],
              )
            else if (_isOutroVideoPlaying && widget.user == "patient")
              Stack(
                children: [
                  Center(
                    child: _outroVideoController!.value.isInitialized
                        ? SizedBox(
                            width: double.infinity,
                            child: AspectRatio(
                              aspectRatio: _outroVideoController!.value.aspectRatio,
                              child: VideoPlayer(_outroVideoController!),
                            ),
                          )
                        : CircularProgressIndicator(),
                  ),
                  Positioned(
                    top: 20.h,
                    right: 20.w,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _outerIntroVideo,
                      child: Text('تخطي', style: TextStyle(fontSize: 14.sp)),
                    ),
                  ),
                ],
              )
            else
              Stack(
                children: [
                  Center(child: _remoteVideo()),
                  Align(
                    alignment: Alignment.topLeft,
                    child: SizedBox(
                      width: 100.w,
                      height: 150.h,
                      child: _localPreview(),
                    ),
                  ),
                  Positioned(
                    bottom: 20.h,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: Icon(_isMuted ? Icons.mic_off : Icons.mic, size: 24.sp),
                          onPressed: _toggleMute,
                        ),
                        IconButton(
                          icon: Icon(
                            _isCameraOn ? Icons.videocam : Icons.videocam_off,
                            size: 24.sp,
                          ),
                          onPressed: _toggleCamera,
                        ),
                        IconButton(
                          icon: Icon(Icons.call_end, size: 24.sp),
                          onPressed: () {
                            _showAlertDialog(context);
                          },
                          color: Colors.red,
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 100.h,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _navigateToGameScreen,
                        child: Text('الذهاب للعبة', style: TextStyle(fontSize: 14.sp)),
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

  Widget _localPreview() {
    return Stack(
      children: [
        if (_isCameraOn && _localUserJoined)
          AgoraVideoView(
            controller: VideoViewController(
              rtcEngine: _engine,
              canvas: const VideoCanvas(uid: 0),
            ),
          )
        else
          Container(
            color: Colors.grey[200],
            child: Icon(Icons.videocam_off, size: 40.sp),
          ),
        if (_isMuted)
          Positioned(
            top: 5.h,
            right: 5.w,
            child: Icon(Icons.mic_off, color: Colors.white, size: 20.sp),
          ),
      ],
    );
  }

  Widget _remoteVideo() {
    return Stack(
      children: [
        if (_remoteUid != null)
          _remoteCameraOff
              ? Center(
                  child: Container(
                    color: Colors.grey[200],
                    child: Icon(Icons.videocam_off, size: 100.sp),
                  ),
                )
              : AgoraVideoView(
                  controller: VideoViewController.remote(
                    rtcEngine: _engine,
                    canvas: VideoCanvas(uid: _remoteUid),
                    connection: RtcConnection(
                      channelId: AgoraManagerModel.channelName,
                    ),
                  ),
                )
        else
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('انتظر الطرف الآخر لبدء المكالمة', style: TextStyle(fontSize: 16.sp)),
              SizedBox(height: 15.h),
              CircularProgressIndicator(color: Colors.black),
            ],
          ),
        if (_remoteMuted)
          Positioned(
            top: 10.h,
            right: 10.w,
            child: Icon(Icons.mic_off, color: Colors.white, size: 24.sp),
          ),
      ],
    );
  }
}