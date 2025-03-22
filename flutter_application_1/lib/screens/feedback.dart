import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_application_1/screens/TherapistHomePage.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FeedbackScreen(isDoctor: false),
    );
  }
}

class FeedbackScreen extends StatefulWidget {
  final bool isDoctor;
  FeedbackScreen({required this.isDoctor});

  @override
  _FeedbackScreenState createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final TextEditingController _controller = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void sendMessage() async {
    if (_controller.text.isNotEmpty) {
      await _firestore.collection("feedback").add({
        "message": _controller.text,
        "timestamp": FieldValue.serverTimestamp(),
        "sender": "doctor",
      });
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(239, 108, 0, 1),

        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white, size: 24.sp),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TherapistHomePage()),
            );
          },
        ),
        actions: [
          Text(
            "مراجعاتي",
            style: TextStyle(color: Colors.white, fontSize: 24.sp),
          ),
          SizedBox(width: 15.w),
        ],
      ),

      body: Column(
        children: [
          SizedBox(height: 10.h),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  _firestore
                      .collection("feedback")
                      .orderBy("timestamp", descending: true)
                      .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return Center(child: CircularProgressIndicator());
                var feedbacks = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: feedbacks.length,
                  itemBuilder: (context, index) {
                    var feedback = feedbacks[index];
                    return Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        margin: EdgeInsets.symmetric(
                          vertical: 5.h,
                          horizontal: 15.w,
                        ),

                        padding: EdgeInsets.all(15.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: Color.fromRGBO(239, 108, 0, 1),
                          ),
                          borderRadius: BorderRadius.circular(15.r),
                          boxShadow: [
                            BoxShadow(color: Colors.black12, blurRadius: 4),
                          ],
                        ),
                        child: Text(
                          feedback["message"],
                          textAlign: TextAlign.right,
                          style: TextStyle(fontSize: 16.sp),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          if (widget.isDoctor)
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
