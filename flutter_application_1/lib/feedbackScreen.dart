import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // دالة لجلب الأطفال الذين أنهوا الجلسات
  Stream<List<Map<String, dynamic>>> getCompletedSessions() {
    return _firestore
        .collection('appointments')
        .where('status', isEqualTo: 'completed') // الجلسات المكتملة فقط
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  // دالة لإرسال feedback
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
        title: const Text("الجلسات المكتملة"),
        backgroundColor: Colors.orange,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: getCompletedSessions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('لا توجد جلسات مكتملة.'));
          }

          List<Map<String, dynamic>> sessions = snapshot.data!;

          return ListView.builder(
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              var session = sessions[index];
              return ListTile(
                title: Text(session['clientName'] ?? "No Name"),
                subtitle: Text(session['category'] ?? ''),
                trailing: IconButton(
                  icon: const Icon(Icons.message, color: Colors.orange),
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

  // عرض مربع حوار لإرسال feedback
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
          title: Text("إرسال Feedback لـ $childName"),
          content: TextField(
            controller: feedbackController,
            decoration: const InputDecoration(hintText: "أدخل Feedback هنا..."),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("إلغاء"),
            ),
            TextButton(
              onPressed: () async {
                if (feedbackController.text.isNotEmpty) {
                  await sendFeedback(childId, feedbackController.text);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("تم إرسال Feedback بنجاح!")),
                  );
                }
              },
              child: const Text("إرسال"),
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
