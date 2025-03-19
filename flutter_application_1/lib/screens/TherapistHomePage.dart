import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter_application_1/screens/PastAppointments.dart';
import 'package:flutter_application_1/screens/Tappointment.dart';
import 'package:flutter_application_1/screens/UpcomingAppointments.dart';
import 'package:flutter_application_1/screens/feedback.dart';
import 'package:flutter_application_1/screens/user_info_page_t.dart';
import 'package:animate_do/animate_do.dart';

class TherapistHomePage extends StatefulWidget {
  @override
  _TherapistHomePageState createState() => _TherapistHomePageState();
}

class _TherapistHomePageState extends State<TherapistHomePage> {
  int selectedIndex = 2;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => TherapistProfilePage()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Tappointment()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => TherapistHomePage()),
        );
        break;
    }
  }

  Future<Map<String, dynamic>> _fetchUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot doc =
          await _firestore.collection('therapists').doc(user.uid).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
    }
    return {};
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                colors: const [
                  Color.fromARGB(255, 219, 101, 37),
                  Color.fromRGBO(239, 108, 0, 1),
                  Color.fromRGBO(255, 167, 38, 1),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                SizedBox(height: 60.h),
                Padding(
                  padding: EdgeInsets.all(10.r),
                  child: FutureBuilder<Map<String, dynamic>>(
                    future: _fetchUserData(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text('حدث خطأ أثناء جلب البيانات'),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Text('لا توجد بيانات'));
                      } else {
                        Map<String, dynamic> userData = snapshot.data!;
                        String firstName = userData['firstName'] ?? 'غير معروف';
                        String lastName = userData['lastName'] ?? 'غير معروف';
                        String profileImageUrl = userData['profileImage'] ?? '';

                        return FadeInUp(
                          duration: const Duration(milliseconds: 1000),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    "مرحبًا،",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 30.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "د. $firstName $lastName",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20.sp,
                                    ),
                                  ),
                                ],
                              ),
                              CircleAvatar(
                                radius: 35.r,
                                backgroundImage:
                                    profileImageUrl.isNotEmpty
                                        ? NetworkImage(profileImageUrl)
                                        : AssetImage('assets/images/doctor.jpg')
                                            as ImageProvider,
                              ),
                            ],
                          ),
                        );
                      }
                    },
                  ),
                ),
                SizedBox(height: 20.h),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(50.r),
                      topRight: Radius.circular(50.r),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(30.r),
                    child: Column(
                      children: <Widget>[
                        SizedBox(height: 30.h),
                        FadeInUp(
                          duration: const Duration(milliseconds: 1400),
                          child: Column(
                            children: [
                              buildMenuItem(
                                'المواعيد السابقة',
                                'assets/images/c2.webp',
                                context,
                              ),
                              SizedBox(height: 16.h),
                              buildMenuItem(
                                'المواعيد القادمة',
                                'assets/images/c.jfif',
                                context,
                              ),
                              SizedBox(height: 16.h),
                              buildMenuItem(
                                'تقدم المراجعين',
                                'assets/images/review.jpg',
                                context,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: FadeInUp(
          duration: const Duration(milliseconds: 1000),
          child: navBar(),
        ),
      ),
    );
  }

  Widget buildMenuItem(String title, String imagePath, BuildContext context) {
    return Container(
      width: 360.w,
      height: 130.h,
      padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 2,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // الصورة
          Expanded(
            flex: 1,
            child: Image.asset(
              imagePath,
              width: 90.w, // زيادة عرض الصورة
              height: 80.h, // زيادة ارتفاع الصورة
              fit: BoxFit.fill, // لجعل الصورة تملأ المساحة المحددة
            ),
          ),
          SizedBox(width: 16.w), // زيادة المسافة بين الصورة والنص
          // النص
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment:
                  MainAxisAlignment.center, // جعل النص في المنتصف عموديًا
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18.sp, // زيادة حجم النص
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.left,
                ),
                SizedBox(height: 8.h), // زيادة المسافة بين العنوان والنص الفرعي
                GestureDetector(
                  onTap: () {
                    // Handle navigation based on the title
                    switch (title) {
                      case 'المواعيد السابقة':
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PastAppointments(),
                          ),
                        );
                        break;
                      case 'المواعيد القادمة':
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UpcomingAppointments(),
                          ),
                        );
                        break;
                      case 'تقدم المراجعين':
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => FeedbackScreen(isDoctor: true),
                          ),
                        );
                        break;
                    }
                  },
                  child: Text(
                    'عرض التفاصيل',
                    style: TextStyle(
                      fontSize: 14.sp, // زيادة حجم النص الفرعي
                      color: Color(0xFFFCB47A),
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
          _buildImageItem("assets/images/ewan.png", 2),
          _buildNavItem(Icons.calendar_today, 1),
          _buildNavItem(Icons.person, 0),
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

void main() {
  runApp(
    MaterialApp(debugShowCheckedModeBanner: false, home: TherapistHomePage()),
  );
}
