import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/firestore_service.dart';
import 'package:flutter_application_1/screens/HomePage.dart';

class ConfirmationPage extends StatelessWidget {
  final List<Map<String, dynamic>> therapists;
  final int selectedTherapistIndex;
  final List<Map<String, dynamic>> children;
  final int selectedChildIndex;
  final DateTime selectedDay;
  final String selectedTime;
  final FirestoreService firestoreService;

  ConfirmationPage({
    required this.therapists,
    required this.selectedTherapistIndex,
    required this.children,
    required this.selectedChildIndex,
    required this.selectedDay,
    required this.selectedTime,
    required this.firestoreService,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("الرجاء الدفع  "),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            
            SizedBox(height: 20),
            Text(
              "   ادفع لتأكيد الحجز!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // تنفيذ الكود المطلوب بعد التأكيد
                await _addAppointment(context);
              },
              child: Text("تأكيد الحجز"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addAppointment(BuildContext context) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    String therapistUid =
        therapists[selectedTherapistIndex]["uid"] ?? "unknown";
    String therapistName =
        "${therapists[selectedTherapistIndex]["firstName"] ?? ""} ${therapists[selectedTherapistIndex]["lastName"] ?? ""}";
    String childName =
        "${children[selectedChildIndex]["childName"] ?? "No Name"}";

    final appointmentData = {
      "userId": uid,
      "therapistUid": therapistUid,
      "therapistName": therapistName,
      "childName": childName,
      "date":
          "${selectedDay.year}-${selectedDay.month.toString().padLeft(2, '0')}-${selectedDay.day.toString().padLeft(2, '0')}",
      "time": selectedTime,
      "price": therapists[selectedTherapistIndex]["price"] ?? "0",
      "status": "upcoming",
    };

    try {
      await firestoreService.addAppointment(appointmentData);
      print("Appointment added successfully");

      // عرض رسالة نجاح
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("تم حجز الموعد بنجاح!")),
      );

      // الانتقال إلى الصفحة الرئيسية أو أي صفحة أخرى
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Homepage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("حدث خطأ أثناء حجز الموعد: ${e.toString()}")),
      );
    }
  }
}