import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Map<String, dynamic>>> getCompletedSessions() {
    return _firestore
        .collection('appointments')
        .where('status', isEqualTo: 'completed')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Future<void> sendFeedback(String childId, String feedback) async {
    await _firestore.collection('feedback').doc(childId).set({
      'feedback': feedback,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("الجلسات المكتملة", style: TextStyle(fontSize: 20.sp)),
        backgroundColor: Colors.orange,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: getCompletedSessions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('لا توجد جلسات مكتملة.', style: TextStyle(fontSize: 16.sp)));
          }

          List<Map<String, dynamic>> sessions = snapshot.data!;

          return ListView.builder(
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              var session = sessions[index];
              return ListTile(
                title: Text(session['clientName'] ?? "No Name", style: TextStyle(fontSize: 16.sp)),
                subtitle: Text(session['category'] ?? '', style: TextStyle(fontSize: 14.sp)),
                trailing: IconButton(
                  icon: Icon(Icons.message, color: Colors.orange, size: 24.sp),
                  onPressed: () {
                    _showFeedbackDialog(
                      context,
                      session['clientName'],
                      session['childId'],
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showFeedbackDialog(
    BuildContext context,
    String childName,
    String childId,
  ) {
    TextEditingController feedbackController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("إرسال Feedback لـ $childName", style: TextStyle(fontSize: 18.sp)),
          content: TextField(
            controller: feedbackController,
            decoration: InputDecoration(hintText: "أدخل Feedback هنا...", hintStyle: TextStyle(fontSize: 14.sp)),
            maxLines: 3,
            style: TextStyle(fontSize: 14.sp),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("إلغاء", style: TextStyle(fontSize: 14.sp)),
            ),
            TextButton(
              onPressed: () async {
                if (feedbackController.text.isNotEmpty) {
                  await sendFeedback(childId, feedbackController.text);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("تم إرسال Feedback بنجاح!", style: TextStyle(fontSize: 14.sp))),
                  );
                }
              },
              child: Text("إرسال", style: TextStyle(fontSize: 14.sp)),
            ),
          ],
        );
      },
    );
  }
}

void main() {
  runApp(
    MaterialApp(debugShowCheckedModeBanner: false, home: FeedbackScreen()),
  );
}