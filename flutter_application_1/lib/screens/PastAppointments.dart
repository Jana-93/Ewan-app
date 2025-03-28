import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PastAppointments extends StatefulWidget {
  const PastAppointments({super.key});

  @override
  State<PastAppointments> createState() => _PastAppointmentsState();
}

class _PastAppointmentsState extends State<PastAppointments> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Map<String, dynamic>>> getPastAppointments() {
    return _firestore
        .collection('appointments')
        .where('status', isEqualTo: 'completed')
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
              begin: Alignment.topLeft,
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
              SizedBox(height: 40.h),
              Padding(
                padding: EdgeInsets.all(10.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 30.sp,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    Text(
                      "المواعيد السابقة",
                      style: TextStyle(color: Colors.white, fontSize: 40.sp),
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ),
              // SizedBox(height: 10.h),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.r),
                    topRight: Radius.circular(30.r),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(30.w),
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: 20.h),
                      StreamBuilder<List<Map<String, dynamic>>>(
                        stream: getPastAppointments(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }
                          if (snapshot.hasError) {
                            return Center(
                              child: Text('Error: ${snapshot.error}'),
                            );
                          }
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return Center(child: Text('لا يوجد مواعيد سابقة'));
                          }

                          List<Map<String, dynamic>> appointments =
                              snapshot.data!;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children:
                                appointments.map((appointment) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20.r),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 10,
                                          spreadRadius: 5,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    margin: EdgeInsets.only(bottom: 20.h),
                                    child: Padding(
                                      padding: EdgeInsets.all(15.w),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,//اسم الطفل يمين 
                                            children: [
                                              Text(
                                                appointment['childName'] ??
                                                    "No Name",
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16.sp,
                                                ),
                                              ),
                                              SizedBox(height: 5.h),
                                              Text(
                                                appointment['category'] ?? '',
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 12.sp,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 15.h),
                                          ScheduleCard(
                                            date: appointment['date'] ?? '',
                                            time: appointment['time'] ?? '',
                                          ),
                                          SizedBox(height: 15.h),
                                          Text(
                                            'حالة الموعد: ${appointment['status'] ?? 'مكتمل'}',
                                            style: TextStyle(
                                              color: Colors.orange,
                                              fontSize: 14.sp,
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
    String formattedDate = "Invalid Date";

    try {
      if (date.isNotEmpty) {
        DateTime parsedDate = DateTime.parse(date);
        formattedDate = DateFormat('dd/MM/yyyy').format(parsedDate);
      }
    } catch (e) {
      print("Error parsing date: $e");
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 238, 235, 235),
        borderRadius: BorderRadius.circular(10.r),
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
      padding: EdgeInsets.all(20.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: [
              Icon(Icons.calendar_today, color: Colors.orange, size: 16.sp),
              SizedBox(width: 5.w),
              Text(
                formattedDate,
                style: TextStyle(color: Colors.orange, fontSize: 14.sp),
              ),
            ],
          ),
          Row(
            children: [
              Icon(Icons.access_time, color: Colors.orange, size: 16.sp),
              SizedBox(width: 5.w),
              Text(
                time.isNotEmpty ? time : '10:00 صباحًا',
                style: TextStyle(color: Colors.orange, fontSize: 14.sp),
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
    MaterialApp(debugShowCheckedModeBanner: false, home: PastAppointments()),
  );
}
