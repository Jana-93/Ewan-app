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
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            children: [
              Image.asset("assets/images/tick.jpg", height: 200),
              // Ensure the correct asset path
              SizedBox(height: 5),
              Text(
                "!تم الدفع بنجاح",
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "تم تأكيد حجزك",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),

          SizedBox(height: 30),
          ElevatedButton(
            onPressed: () async {
              // Execute the required code after confirmation
              await _addAppointment(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 255, 163, 26),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 100, vertical: 15),
              elevation: 5,
            ),
            child: Text(" العودة للرئيسية", style: TextStyle(fontSize: 20)),
          ),
        ],
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("تم حجز الموعد بنجاح!")));

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
