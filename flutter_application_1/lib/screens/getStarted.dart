import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Getstarted extends StatelessWidget {
  const Getstarted({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            SizedBox(height: 100.h),
            Center(
              child: Image.asset(
                "assets/images/getStarted_doctor.jpg",
                height: 300.h,
              ),
            ),
            Text(
              "تواصل الآن مع الطبيب أونلاين لمساعدة طفلك",
              style: TextStyle(color: Colors.grey, fontSize: 16.sp),
            ),
            SizedBox(height: 20.h),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, "/login");
              },
              child: Text(
                "ابدأ الآن",
                style: TextStyle(
                  color: const Color.fromARGB(255, 255, 255, 255),
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(
                  Color.fromARGB(255, 246, 137, 47),
                ),
                padding: MaterialStateProperty.all(
                  EdgeInsets.symmetric(horizontal: 90.w, vertical: 10.h),
                ),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(70.r),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}