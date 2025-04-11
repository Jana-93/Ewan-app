import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_application_1/callVideo/presentation/views/video_call_screen.dart';
import 'package:flutter_application_1/feedbackScreen.dart';
import 'package:flutter_application_1/firestore_service.dart';
import 'package:flutter_application_1/screens/TherapistHomePage.dart';
import 'package:flutter_application_1/screens/user_info_page_t.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Tappointment extends StatefulWidget {
  final String pataintId;
  final String therapistId;
  const Tappointment({Key? key, required this.therapistId, required this.pataintId}) : super(key: key);

  @override
  State<Tappointment> createState() => _TappointmentState();
}

class _TappointmentState extends State<Tappointment> {
  final FirestoreService _firestoreService = FirestoreService();
  int selectedIndex = 1;

  void _onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => TherapistProfilePage(
             therapistId: widget.therapistId,
                        pataintId: widget.pataintId,
          )),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Tappointment(
            pataintId: widget.pataintId,
             therapistId: widget.therapistId,
          )),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => TherapistHomePage(
            therapistId: widget.therapistId,
             patientId: widget.pataintId,
          )),
        );
        break;
    }
  }

  Future<Map<String, dynamic>> _fetchChildDataByName(String childName) async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance
              .collection('children')
              .where('childName', isEqualTo: childName)
              .get();

      if (snapshot.docs.isNotEmpty) {
        print("Child data found: ${snapshot.docs.first.data()}");
        return snapshot.docs.first.data() as Map<String, dynamic>;
      } else {
        print("No child found with name: $childName");
        throw Exception("child removed");
      }
    } catch (e) {
      print("Error fetching child data: $e");
      throw e;
    }
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
                padding: EdgeInsets.all(10.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    FadeInUp(
                      duration: const Duration(milliseconds: 1000),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "مواعيدي",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 40.sp,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.r),
                    topRight: Radius.circular(30.r),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(30.r),
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: 20.h),
                      StreamBuilder<List<Map<String, dynamic>>>(
                        stream: _firestoreService.getAppointmentsByTherapistId(
                          FirebaseAuth.instance.currentUser!.uid,
                        ),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          }
                          if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          }
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return Text('لا يوجد مواعيد قادمة');
                          }

                          List<dynamic> appointments = snapshot.data!;

                          return FadeInUp(
                            duration: const Duration(milliseconds: 1400),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                SizedBox(height: 10.h),
                                Container(
                                  padding: EdgeInsets.all(10.r),
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: appointments.length,
                                    itemBuilder: (context, index) {
                                      var appointment = appointments[index];
                                      bool isLastElement =
                                          index == appointments.length - 1;

                                      return FutureBuilder<
                                        Map<String, dynamic>
                                      >(
                                        future:
                                            appointment['childName'] != null &&
                                                    appointment['childName']
                                                        .isNotEmpty
                                                ? _fetchChildDataByName(
                                                  appointment['childName'],
                                                )
                                                : Future.value({}),
                                        builder: (context, childSnapshot) {
                                          if (childSnapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return CircularProgressIndicator();
                                          }
                                          if (childSnapshot.hasError) {
                                            return Text(
                                              'Error: ${childSnapshot.error}',
                                            );
                                          }

                                          var childData = childSnapshot.data!;

                                          return Container(
                                            decoration: BoxDecoration(
                                              color: const Color.fromARGB(
                                                255,
                                                255,
                                                255,
                                                255,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(20.r),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.2),
                                                  blurRadius: 10,
                                                  spreadRadius: 5,
                                                  offset: Offset(0, 5),
                                                ),
                                              ],
                                            ),
                                            margin:
                                                !isLastElement
                                                    ? EdgeInsets.only(
                                                      bottom: 20.h,
                                                    )
                                                    : EdgeInsets.zero,
                                            child: Padding(
                                              padding: EdgeInsets.all(15.r),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.stretch,
                                                children: [
                                                  Row(
                                                    children: [
                                                      CircleAvatar(
                                                        backgroundImage: AssetImage(
                                                          appointment['ProfilePicture'] ??
                                                              "assets/images/icon.jpg",
                                                        ),
                                                      ),
                                                      SizedBox(width: 10.w),
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            childData['childName'] ??
                                                                "No Name",
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              fontSize: 16.sp,
                                                            ),
                                                          ),
                                                          SizedBox(height: 5.h),
                                                          Text(
                                                            appointment['category'] ??
                                                                '',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.grey,
                                                              fontSize: 12.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 15.h),
                                                  ScheduleCard(
                                                    date:
                                                        appointment['date'] ??
                                                        '',
                                                    time:
                                                        appointment['time'] ??
                                                        '',
                                                  ),
                                                  SizedBox(height: 15.h),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Expanded(
                                                        child: OutlinedButton(
                                                          style: OutlinedButton.styleFrom(
                                                            backgroundColor:
                                                                Colors.orange,
                                                            side: const BorderSide(
                                                              color:
                                                                  Color.fromARGB(
                                                                    255,
                                                                    222,
                                                                    221,
                                                                    221,
                                                                  ),
                                                              width: 2,
                                                            ),
                                                          ),
                                                          onPressed: () {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (
                                                                      context,
                                                                    ) => VideoCallScreen(
                                                                      pataintId: appointment['userId'],
                                                                      user:
                                                                          'doctor',
                                                                      therapistUid:
                                                                          appointment['therapistUid'],
                                                                      uid: '',
                                                                    ),
                                                              ),
                                                            );
                                                          },
                                                          child: Text(
                                                            'بدء الجلسة',
                                                            style: TextStyle(
                                                              fontSize: 16.sp,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
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
      bottomNavigationBar: navBar(),
    );
  }

  Widget navBar() {
    return Container(
      height: 60.h,
      width: double.infinity,
      margin: EdgeInsets.only(left: 35.w, right: 35.w, bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 5,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildNavItem(Icons.person, 0),
          _buildNavItem(Icons.calendar_today, 1),
          _buildImageItem("assets/images/ewan.png", 2),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    bool isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () {
        _onItemTapped(index);
      },
      child: Column(
        children: [
          Container(
            alignment: Alignment.center,
            margin: EdgeInsets.only(
              top: 15.h,
              bottom: 0,
              left: 30.w,
              right: 30.w,
            ),
            child: Icon(
              icon,
              color: isSelected ? Colors.deepOrange : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageItem(String imagePath, int index) {
    bool isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () {
        _onItemTapped(index);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            alignment: Alignment.center,
            margin: EdgeInsets.only(right: 30.w),
            child: ImageIcon(
              AssetImage(imagePath),
              size: 60.sp,
              color: isSelected ? Colors.deepOrange : Colors.grey,
            ),
          ),
        ],
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
        padding: EdgeInsets.all(20.r),
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
    } else {
      return Container();
    }
  }
}
