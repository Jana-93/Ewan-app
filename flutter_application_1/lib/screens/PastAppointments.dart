import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';


class PastAppointments extends StatefulWidget {
  const PastAppointments({super.key});


  @override
  State<PastAppointments> createState() => _PastAppointmentsState();
}


class _PastAppointmentsState extends State<PastAppointments> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  // دالة لجلب المواعيد السابقة
  Stream<List<Map<String, dynamic>>> getPastAppointments() {
    return _firestore
        .collection('appointments')
        .where('status', isEqualTo: 'completed') // المواعيد المكتملة فقط
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              colors: [
                const Color.fromARGB(255, 219, 101, 37),
                const Color.fromRGBO(239, 108, 0, 1),
                const Color.fromRGBO(255, 167, 38, 1),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              const SizedBox(height: 60),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    const Text(
                      "المواعيد السابقة",
                      style: TextStyle(color: Colors.white, fontSize: 40),
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    children: <Widget>[
                      const SizedBox(height: 20),
                      StreamBuilder<List<Map<String, dynamic>>>(
                        stream: getPastAppointments(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (snapshot.hasError) {
                            return Center(child: Text('Error: ${snapshot.error}'));
                          }
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Center(child: Text('لا توجد مواعيد سابقة.'));
                          }


                          List<Map<String, dynamic>> appointments = snapshot.data!;


                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: appointments.map((appointment) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 10,
                                      spreadRadius: 5,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                margin: const EdgeInsets.only(bottom: 20),
                                child: Padding(
                                  padding: const EdgeInsets.all(15),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            appointment['clientName'] ?? "No Name",
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            appointment['category'] ?? '',
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 15),
                                      ScheduleCard(
                                        date: appointment['date'] ?? '',
                                        time: appointment['time'] ?? '',
                                      ),
                                      const SizedBox(height: 15),
                                      Text(
                                        'حالة الموعد: ${appointment['status'] ?? 'مكتمل'}',
                                        style: const TextStyle(
                                          color: Colors.orange,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class ScheduleCard extends StatelessWidget {
  final String date;
  final String time;


  const ScheduleCard({Key? key, required this.date, required this.time})
      : super(key: key);


  @override
  Widget build(BuildContext context) {
    if (date.isNotEmpty) {
      DateTime parsedDate = DateTime.parse(date);
      String formattedDate = DateFormat('dd/MM/yyyy').format(parsedDate);


      return Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 238, 235, 235),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 15,
              spreadRadius: 5,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  color: Colors.orange,
                  size: 16,
                ),
                const SizedBox(width: 5),
                Text(
                  formattedDate,
                  style: const TextStyle(color: Colors.orange, fontSize: 14),
                ),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.access_time, color: Colors.orange, size: 16),
                const SizedBox(width: 5),
                Text(
                  time.isNotEmpty ? time : '10:00 صباحًا',
                  style: const TextStyle(color: Colors.orange, fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      return Container();
    }
  }
}


void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PastAppointments(),
    ),
  );
}
