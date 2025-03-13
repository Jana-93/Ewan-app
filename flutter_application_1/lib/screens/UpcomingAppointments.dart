import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class UpcomingAppointments extends StatefulWidget {
  const UpcomingAppointments({super.key});

  @override
  State<UpcomingAppointments> createState() => _UpcomingAppointmentsState();
}

class _UpcomingAppointmentsState extends State<UpcomingAppointments> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to fetch upcoming appointments
  Stream<List<Map<String, dynamic>>> getUpcomingAppointments() {
    return _firestore
        .collection('appointments')
        .where('status', isEqualTo: 'upcoming') // Only upcoming appointments
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
                      "المواعيد القادمة",
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
                        stream: getUpcomingAppointments(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (snapshot.hasError) {
                            return Center(
                              child: Text('Error: ${snapshot.error}'),
                            );
                          }
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Center(
                              child: Text('لا توجد مواعيد قادمة.'),
                            );
                          }

                          // Remove duplicates based on a combination of fields
                          Set<String> seenAppointments = Set<String>();
                          List<Map<String, dynamic>> uniqueAppointments =
                              snapshot.data!.where((appointment) {
                                String id =
                                    '${appointment['childName']}_${appointment['date']}_${appointment['time']}';
                                if (seenAppointments.contains(id)) {
                                  return false;
                                } else {
                                  seenAppointments.add(id);
                                  return true;
                                }
                              }).toList();

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children:
                                uniqueAppointments.map((appointment) {
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                appointment['childName'] ??
                                                    "No Name",
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
                                            date:
                                                appointment['date'] as String?,
                                            time:
                                                appointment['time'] as String?,
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
  final String? date; // Allow date to be null
  final String? time; // Allow time to be null

  const ScheduleCard({Key? key, required this.date, required this.time})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    String formattedDate = "Invalid Date";

    try {
      if (date != null && date!.isNotEmpty) {
        DateTime parsedDate = DateTime.parse(date!);
        formattedDate = DateFormat('dd/MM/yyyy').format(parsedDate);
      } else {
        formattedDate = "No Date Available";
      }
    } catch (e) {
      // Handle date parsing error
      print("Error parsing date: $e");
    }

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
              const Icon(Icons.calendar_today, color: Colors.orange, size: 16),
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
                time?.isNotEmpty == true ? time! : '10:00 صباحًا',
                style: const TextStyle(color: Colors.orange, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: UpcomingAppointments(),
    ),
  );
}
