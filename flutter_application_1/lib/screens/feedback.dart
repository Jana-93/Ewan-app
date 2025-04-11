import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/screens/TherapistHomePage.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class FeedbackScreen extends StatefulWidget {
  final String therapistId;
  final bool isDoctor;
  final String pataintId;
  
  FeedbackScreen({required this.isDoctor, required this.therapistId, required this.pataintId});

  @override
  _FeedbackScreenState createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final TextEditingController _controller = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Map<String, String> _patientNames = {};
  final Map<String, String> _therapistNames = {};

  @override
  void initState() {
    super.initState();
    _loadNames();
  }

  Future<void> _loadNames() async {
    try {
      // Get all relevant feedback first
      final feedbackSnapshot = await _firestore.collection('feedback')
          .where(widget.isDoctor ? 'therapistId' : 'patientId', 
                isEqualTo: widget.isDoctor ? widget.therapistId : widget.pataintId)
          .get();

      // Extract unique IDs
      final patientIds = feedbackSnapshot.docs
          .map((doc) => doc['patientId'] as String)
          .toSet()
          .toList();
          
      final therapistIds = feedbackSnapshot.docs
          .map((doc) => doc['therapistId'] as String)
          .toSet()
          .toList();

      // Fetch all names in batches
      final patientsSnapshot = await _firestore.collection('patients')
          .where(FieldPath.documentId, whereIn: patientIds)
          .get();
          
      final therapistsSnapshot = await _firestore.collection('therapists')
          .where(FieldPath.documentId, whereIn: therapistIds)
          .get();

      // Store names in maps
      for (var doc in patientsSnapshot.docs) {
        _patientNames[doc.id] = doc['name'] ?? "المريض";
      }
      
      for (var doc in therapistsSnapshot.docs) {
        _therapistNames[doc.id] = doc['firstName'] ?? "الطبيب";
      }
      
      setState(() {});
    } catch (e) {
      debugPrint('Error loading names: $e');
    }
  }

  Future<void> sendMessage() async {
    if (_controller.text.isEmpty) return;
    
    try {
      await _firestore.collection("feedback").add({
        "message": _controller.text,
        "timestamp": FieldValue.serverTimestamp(),
        "therapistId": widget.therapistId,
        "patientId": widget.pataintId,
      });
      _controller.clear();
    } catch (e) {
      debugPrint('Error sending message: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء إرسال المراجعة')),
      );
    }
  }

  Stream<List<QueryDocumentSnapshot>> getMessages() {
    return _firestore
        .collection('feedback')
        .where(widget.isDoctor ? 'therapistId' : 'patientId', 
              isEqualTo: widget.isDoctor ? widget.therapistId : widget.pataintId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .handleError((error) {
          debugPrint('Firestore error: $error');
          return Stream.value([]);
        })
        .map((snapshot) => snapshot.docs);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(239, 108, 0, 1),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white, size: 24.sp),
          onPressed: () {
            if (widget.isDoctor) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => TherapistHomePage(
                  therapistId: widget.therapistId,
                  patientId: widget.pataintId,
                )),
              );
            } else {
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          Text(
            widget.isDoctor ? "المراجعات المرسلة" : "مراجعاتي",
            style: TextStyle(color: Colors.white, fontSize: 24.sp),
          ),
          SizedBox(width: 15.w),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 10.h),
          Expanded(
            child: StreamBuilder<List<QueryDocumentSnapshot>>(
              stream: getMessages(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('حدث خطأ في تحميل المراجعات'),
                        SizedBox(height: 10.h),
                        TextButton(
                          onPressed: () => setState(() {}),
                          child: Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  );
                }
                
                // if (!snapshot.hasData) {
                //   return const Center(child: CircularProgressIndicator());
                // }

                final messages = snapshot.data;
                if (messages?.isEmpty ?? true) {
                  return Center(child: Text('لا توجد مراجعات بعد'));
                }

                return ListView.builder(
                  reverse: true,
                  itemCount: messages?.length ?? 0,
                  itemBuilder: (context, index) {
                    final doc = messages?[index] ?? messages![0];
                    final data = doc.data() as Map<String, dynamic>;
                    final therapistId = data['therapistId'] as String;
                    final patientId = data['patientId'] as String;
                    final therapistName = _therapistNames[therapistId] ?? "الطبيب";
                    final patientName = _patientNames[patientId] ?? "المريض";
                    final timestamp = data['timestamp'] as Timestamp;
                    final isFromCurrentTherapist = therapistId == widget.therapistId;
                    
                    return MessageBubble(
                      message: data['message'],
                      isTherapist: isFromCurrentTherapist,
                      senderName: isFromCurrentTherapist ? patientName : therapistName,
                      timestamp: timestamp,
                      date: DateFormat('yyyy-MM-dd').format(timestamp.toDate()),
                      isCurrentUser: isFromCurrentTherapist,
                    );
                  },
                );
              },
            ),
          ),
          if (widget.isDoctor && widget.pataintId.isNotEmpty)
            Padding(
              padding: EdgeInsets.all(10.w),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textAlign: TextAlign.right,
                      decoration: InputDecoration(
                        hintText: " ...اضف مراجعتك ",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.r),
                          borderSide: BorderSide(color: Colors.orange),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.send,
                      color: Color.fromRGBO(239, 108, 0, 1),
                      size: 24.sp,
                    ),
                    onPressed: sendMessage,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String message;
  final bool isTherapist;
  final String senderName;
  final Timestamp timestamp;
  final String? date;
  final bool isCurrentUser;

  const MessageBubble({
    required this.message,
    required this.isTherapist,
    required this.senderName,
    required this.timestamp,
    this.date,
    required this.isCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isCurrentUser ? Alignment.topRight : Alignment.topLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: 300.w),
        margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: isCurrentUser ? Colors.blue[100] : Colors.grey[200],
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              senderName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
                color: isCurrentUser ? Colors.blue[800] : Colors.grey[800],
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              message,
              style: TextStyle(fontSize: 16.sp),
              textAlign: isCurrentUser ? TextAlign.right : TextAlign.left,
            ),
            SizedBox(height: 4.h),
            Row(
              mainAxisAlignment: isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                Text(
                  date ?? DateFormat('yyyy-MM-dd').format(timestamp.toDate()),
                  style: TextStyle(fontSize: 10.sp, color: Colors.grey),
                ),
                SizedBox(width: 8.w),
                Text(
                  DateFormat('h:mm a').format(timestamp.toDate()),
                  style: TextStyle(fontSize: 10.sp, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}