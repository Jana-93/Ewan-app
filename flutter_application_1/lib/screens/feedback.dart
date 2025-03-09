import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // تهيئة Firebase
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FeedbackScreen(isDoctor: false), // غيّر إلى true إذا كنت الدكتور
    );
  }
}

class FeedbackScreen extends StatefulWidget {
  final bool isDoctor; // هل المستخدم دكتور أم ولي أمر؟
  FeedbackScreen({required this.isDoctor});

  @override
  _FeedbackScreenState createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final TextEditingController _controller = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // دالة إرسال المراجعة (تعمل فقط إذا كان المستخدم دكتورًا)
  void sendMessage() async {
    if (_controller.text.isNotEmpty) {
      await _firestore.collection("feedback").add({
        "message": _controller.text,
        "timestamp": FieldValue.serverTimestamp(),
        "sender": "doctor"
      });
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text("مراجعاتي", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {}, // إضافة التنقل للصفحة السابقة
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection("feedback")
                  .orderBy("timestamp", descending: true) // ترتيب من الأحدث إلى الأقدم
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                var feedbacks = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: feedbacks.length,
                  itemBuilder: (context, index) {
                    var feedback = feedbacks[index];
                    return Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.orange),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(color: Colors.black12, blurRadius: 4)
                          ],
                        ),
                        child: Text(
                          feedback["message"],
                          textAlign: TextAlign.right,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          if (widget.isDoctor) // إظهار حقل الإدخال فقط للدكتور
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: "أضف مراجعتك...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide(color: Colors.orange),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send, color: Colors.orange),
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
