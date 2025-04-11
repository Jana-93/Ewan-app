import 'package:cloud_firestore/cloud_firestore.dart';
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
            onPressed: ()  {
         donefunction(context); 
         
              // Execute the required code after confirmation
               ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("تم حجز الموعد بنجاح!")),
    );


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



  donefunction(BuildContext context) {
     Navigator.pushReplacement(
       context,
       MaterialPageRoute(builder: (context) => Homepage()),   
     );
  }

}
