import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/firestore_service.dart';
import 'package:intl/intl.dart'; // لتنسيق التاريخ

class Tappointment extends StatefulWidget {
  const Tappointment({super.key});

  @override
  State<Tappointment> createState() => _TappointmentState();
}

class _TappointmentState extends State<Tappointment> {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("مواعيد الطبيب"),
        backgroundColor: Colors.deepOrange,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // عرض المواعيد
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: _firestoreService.getAppointments(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('حدث خطأ: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('لا توجد مواعيد متاحة.'));
                }

                List<dynamic> appointments = snapshot.data!;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: appointments.length,
                  itemBuilder: (context, index) {
                    var appointment = appointments[index];
                    return AppointmentCard(
                      patientName: appointment['patientName'] ?? "غير معروف",
                      date: appointment['date'] ?? "",
                      time: appointment['time'] ?? "",
                      status: appointment['status'] ?? "غير معروف",
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class AppointmentCard extends StatelessWidget {
  final String patientName;
  final String date;
  final String time;
  final String status;

  const AppointmentCard({
    required this.patientName,
    required this.date,
    required this.time,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // اسم المريض
            Text(
              patientName,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),

            // التاريخ والوقت
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.deepOrange),
                SizedBox(width: 5),
                Text(
                  DateFormat('dd/MM/yyyy').format(DateTime.parse(date)),
                  style: TextStyle(color: Colors.grey[700]),
                ),
                SizedBox(width: 20),
                Icon(Icons.access_time, size: 16, color: Colors.deepOrange),
                SizedBox(width: 5),
                Text(
                  time,
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
            ),
            SizedBox(height: 8),

            // حالة الموعد
            Row(
              children: [
                Icon(
                  Icons.circle,
                  size: 12,
                  color: status == 'مكتملة'
                      ? Colors.green
                      : status == 'ملغاة'
                          ? Colors.red
                          : Colors.orange,
                ),
                SizedBox(width: 4),
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    // تعديل الموعد
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: Text(
                    "تعديل الموعد",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}