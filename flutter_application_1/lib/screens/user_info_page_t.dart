import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TherapistProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String uid =
        FirebaseAuth.instance.currentUser!.uid; // جلب UID الخاص بالطبيب

    return Scaffold(
      appBar: AppBar(title: Text('معلوماتي'),),
      
      body: FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance.collection('therapists').doc(uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('لم يتم العثور على بيانات الطبيب'));
          }

          var data = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(data['profileImage']),
                  backgroundColor: Colors.grey[300],
                ),
                SizedBox(height: 16),
                buildInfoTile(': الاسم الأول ', data['firstName']),
                buildInfoTile(': الاسم الأخير  ', data['lastName']),
                buildInfoTile(': التخصص الدقيق ', data['specialty']),
                buildInfoTile(': سنوات الخبرة  ', data['experience']),
                buildInfoTile(': البريد الإلكتروني  ', data['email']),
                buildInfoTile(': رقم الجوال  ', data['phone']),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildInfoTile(String title, String value) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 5),
        ],
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}
