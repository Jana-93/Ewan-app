import 'dart:ui';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/callVideo/data/model/agora_manager_model.dart';
import 'package:flutter_application_1/screens/appointmentpage.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
  int? _remoteUid;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _remoteMuted = widget.initialMuted;
    _remoteCameraOff = widget.initialCameraOff;

    widget.engine.registerEventHandler(
      RtcEngineEventHandler(
        onUserJoined: (connection, uid, elapsed) {
          setState(() => _remoteUid = uid);
        },
        onUserOffline: (connection, uid, reason) {
          if (_remoteUid == uid) {
            setState(() => _remoteUid = null);
          }
        },
        onUserMuteAudio: (connection, uid, muted) {
          if (uid == _remoteUid) setState(() => _remoteMuted = muted);
        },
        onUserEnableVideo: (connection, uid, enabled) {
          if (uid == _remoteUid) setState(() => _remoteCameraOff = !enabled);
        },
      ),
    );

    _listenForRemoteCameraState();
  }

  void _listenForRemoteCameraState() {
    _firestore.collection('cameraState').doc("cameraState").snapshots().listen((
      snapshot,
    ) {
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
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            colors: const [
              Color.fromARGB(255, 219, 101, 37),
              Color.fromRGBO(239, 108, 0, 1),
              Color.fromRGBO(255, 167, 38, 1),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            SizedBox(height: 60.h),
            Padding(
              padding: EdgeInsets.all(10.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 30.sp,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  Text(
                    "اللعبة",
                    style: TextStyle(color: Colors.white, fontSize: 40.sp),
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40.r),
                    topRight: Radius.circular(40.r),
                  ),
                ),
                child: Stack(
                  children: [
                    if (_remoteUid != null)
                      Positioned(
                        left: _floatingPosition.dx,
                        top: _floatingPosition.dy,
                        child: GestureDetector(
                          onPanUpdate: (details) {
                            setState(() => _floatingPosition += details.delta);
                          },
                          child: SizedBox(
                            width: 150.w,
                            height: 200.h,
                            child: Stack(
                              children: [
                                _remoteVideo(),
                                if (_remoteMuted)
                                  Positioned(
                                    top: 5.h,
                                    right: 5.w,
                                    child: Icon(
                                      Icons.mic_off,
                                      color: Colors.white,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      bottom: 1.h,
                      left: 0,
                      right: 0,
                      height: 300.h,
                      child: DrawingBoard(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _remoteVideo() {
    if (_remoteUid != null) {
      return _remoteCameraOff
          ? Center(
            child: Container(
              color: Colors.grey[200],
              child: Icon(Icons.videocam_off, size: 60.sp),
            ),
          )
          : AgoraVideoView(
            controller: VideoViewController.remote(
              rtcEngine: widget.engine,
              canvas: VideoCanvas(uid: _remoteUid),
              connection: RtcConnection(
                channelId: AgoraManagerModel.channelName,
              ),
            ),
          );
    } else {
      return Center(
        child: Text('الطرف الاخر ليس متصل', style: TextStyle(fontSize: 16.sp)),
      );
    }
  }
}

class DrawingBoard extends StatefulWidget {
  @override
  _DrawingBoardState createState() => _DrawingBoardState();
}

class _DrawingBoardState extends State<DrawingBoard> {
  Color selectedColor = Colors.black;
  double strokeWidth = 5;
  List<DrawingPoint> drawingPoints = [];
  List<Color> colors = [
    Colors.pink,
    Colors.red,
    Colors.black,
    Colors.yellow,
    Colors.amberAccent,
    Colors.purple,
    Colors.green,
    Colors.white,
  ];
  bool isDrawing = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Listener(
            behavior: HitTestBehavior.opaque,
            onPointerDown: (PointerDownEvent event) {
              setState(() {
                isDrawing = true;
                drawingPoints.add(
                  DrawingPoint(
                    event.localPosition,
                    Paint()
                      ..color = selectedColor
                      ..isAntiAlias = true
                      ..strokeWidth = strokeWidth
                      ..strokeCap = StrokeCap.round
                      ..blendMode =
                          selectedColor == Colors.white
                              ? BlendMode.clear
                              : BlendMode.srcOver,
                  ),
                );
              });
            },
            onPointerMove: (PointerMoveEvent event) {
              if (isDrawing) {
                setState(() {
                  drawingPoints.add(
                    DrawingPoint(
                      event.localPosition,
                      Paint()
                        ..color = selectedColor
                        ..isAntiAlias = true
                        ..strokeWidth = strokeWidth
                        ..strokeCap = StrokeCap.round
                        ..blendMode =
                            selectedColor == Colors.white
                                ? BlendMode.clear
                                : BlendMode.srcOver,
                    ),
                  );
                });
              }
            },
            onPointerUp: (PointerUpEvent event) {
              setState(() {
                isDrawing = false;
              });
            },
            child: CustomPaint(
              painter: _DrawingPainter(drawingPoints),
              size: Size.infinite,
            ),
          ),
          IgnorePointer(
            ignoring: isDrawing,
            child: Column(
              children: [
                SafeArea(
                  child: Padding(
                    padding: EdgeInsets.only(top: 80.h, right: 20.w),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 200.w,
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                            ),
                            child: Slider(
                              min: 0,
                              max: 40,
                              value: strokeWidth,
                              onChanged:
                                  (val) => setState(() => strokeWidth = val),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed:
                                () => setState(() => drawingPoints.clear()),
                            icon: Icon(Icons.clear),
                            label: Text(
                              " مسح الشاشة",
                              style: TextStyle(fontSize: 14.sp),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Spacer(),
                Container(
                  color: const Color.fromARGB(255, 249, 236, 222),
                  padding: EdgeInsets.all(10.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(
                      colors.length,
                      (index) => _buildColorChoice(colors[index]),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorChoice(Color color) {
    bool isSelected = selectedColor == color;
    return GestureDetector(
      onTap: () => setState(() => selectedColor = color),
      child: Container(
        height: isSelected ? 47.h : 40.h,
        width: isSelected ? 47.w : 40.w,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border:
              isSelected ? Border.all(color: Colors.white, width: 3.w) : null,
        ),
      ),
    );
  }
}

class _DrawingPainter extends CustomPainter {
  final List<DrawingPoint> drawingPoints;

  _DrawingPainter(this.drawingPoints);

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < drawingPoints.length - 1; i++) {
      if (drawingPoints[i] != null && drawingPoints[i + 1] != null) {
        canvas.drawLine(
          drawingPoints[i].offset,
          drawingPoints[i + 1].offset,
          drawingPoints[i].paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class DrawingPoint {
  Offset offset;
  Paint paint;

  DrawingPoint(this.offset, this.paint);
}
