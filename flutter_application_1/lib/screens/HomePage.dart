import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_application_1/screens/appointmentpage.dart';
import 'package:flutter_application_1/screens/loginScreen.dart';
import 'package:flutter_application_1/screens/searchpage.dart';
import 'package:flutter_application_1/screens/userpage.dart';
import 'package:flutter_application_1/screens/feedback.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int selectedIndex = 3;

  void _onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
    // to move between pages
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => UserPage()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Searchpage()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Appointmentpage()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Homepage()),
        );
        break;
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
              begin: Alignment.topCenter,
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
                padding: EdgeInsets.all(20.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    FadeInUp(
                      duration: const Duration(milliseconds: 1000),
                      child: Text(
                        "أهلاً",
                        style: TextStyle(color: Colors.white, fontSize: 40.sp),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
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
                      _buildHealthConsultation(),
                      SizedBox(height: 20.h),
                      FadeInUp(
                        duration: const Duration(milliseconds: 1400),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            SizedBox(height: 10.h),
                            Container(
                              padding: EdgeInsets.all(10.r),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: Colors.white),
                                ),
                              ),
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
    );
  }

  Widget _buildHealthConsultation() {
    return Column(
      children: [
        _buildHealthConsultationSection(
          title: "تحدث إلى مختص صحي الآن",
          description: "احصل على استشارة طبية عن بعد لطفلك",
          imagePath: 'assets/images/doco.jpg',
          actionText: "تصفح مزودي خدمتنا الصحية عن بعد",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Searchpage()),
            );
          },
        ),
        SizedBox(height: 16.h),
        _buildHealthConsultationSection(
          title: "اطّلع على تقدم طفلك",
          description:
              "تابع التقدم الذي يحرزه طفلك من خلال ملاحظات المختصين بعد كل جلسة ",
          imagePath: 'assets/images/feedback.jpg',
          actionText: "عرض سجل المراجعات",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FeedbackScreen(isDoctor: false),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildHealthConsultationSection({
    required String title,
    required String description,
    required String imagePath,
    required String actionText,
    required VoidCallback onTap,
  }) {
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
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.right,
                ),
                SizedBox(height: 2.h),
                Text(
                  description,
                  style: TextStyle(fontSize: 12.sp, color: Colors.black87),
                  textAlign: TextAlign.right,
                ),
                SizedBox(height: 8.h),
                GestureDetector(
                  onTap: onTap,
                  child: Text(
                    actionText,
                    style: TextStyle(fontSize: 12.sp, color: Color(0xFFFCB47A)),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
          Expanded(flex: 1, child: Image.asset(imagePath, fit: BoxFit.contain)),
        ],
      ),
    );
  }

  //nav bar
  Widget navBar() {
    return Container(
      height: 60.h,
      width: double.infinity,
      margin: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 12.h),
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
          _buildNavItem(Icons.calendar_today, 2),
          _buildNavItem(Icons.search, 1),
          _buildImageItem("assets/images/ewan.png", 3),
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
            margin: EdgeInsets.only(right: 15.w),
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
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: LoginScreen()));
}