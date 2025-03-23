import 'package:flutter/material.dart';
import 'package:flutter_application_1/firestore_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_application_1/screens/HomePage.dart';


class ChildFeedback extends StatefulWidget {
  final String uid;  // تم تغيير therapistId إلى uid

  ChildFeedback({required this.uid}); // تم تغيير therapistId إلى uid

  @override
  _ChildFeedbackState createState() => _ChildFeedbackState();
}

class _ChildFeedbackState extends State<ChildFeedback> {
  double _rating = 0;
  final FirestoreService _firestoreService = FirestoreService(); // إضافة FirestoreService

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'تقييم الجلسة',
          style: TextStyle(
            fontSize: 25.sp,
            fontFamily: "NotoKufiArabic",
            color: Colors.orangeAccent[200],
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'شكراً على انضمامك للجلسة !',
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 15.sp),
              textDirection: TextDirection.rtl,
            ),
            SizedBox(height: 10.h),
            Text(
              ':قيم تجربتك ',
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 15.sp),
            ),
            SizedBox(height: 30.h),
            Center(
              child: RatingBar.builder(
                initialRating: _rating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: false,
                itemCount: 5,
                itemSize: 40.sp,
                itemPadding: EdgeInsets.symmetric(horizontal: 4.w),
                itemBuilder: (context, _) => Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  setState(() {
                    _rating = rating;
                  });
                },
              ),
            ),
            SizedBox(height: 40.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => Homepage()),
                    );
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                      Colors.grey[300]!,
                    ),
                    foregroundColor: MaterialStateProperty.all<Color>(
                      Colors.black,
                    ),
                    elevation: MaterialStateProperty.all<double>(0),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                    ),
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      EdgeInsets.symmetric(horizontal: 30.w, vertical: 15.h),
                    ),
                  ),
                  child: Text(
                    'إلغاء',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_rating == 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'الرجاء تحديد تقييم!',
                            textDirection: TextDirection.rtl,
                          ),
                        ),
                      );
                    } else {
                      print('التقييم المحدد: $_rating');
                      
                      // إرسال التقييم إلى Firestore باستخدام uid
                      try {
                        await _firestoreService.addRating(widget.uid, _rating);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'شكرًا على تقييمك!',
                              textDirection: TextDirection.rtl,
                            ),
                          ),
                        );
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => Homepage()),
                        );
                      } catch (e) {
                        print("Error sending rating: $e");
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'حدث خطأ أثناء إرسال التقييم!',
                              textDirection: TextDirection.rtl,
                            ),
                          ),
                        );
                      }
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color>((
                      Set<MaterialState> states,
                    ) {
                      if (states.contains(MaterialState.pressed)) {
                        return Color(0xFFF6872F).withOpacity(0.5);
                      }
                      return Color(0xFFF6872F);
                    }),
                    foregroundColor: MaterialStateProperty.all<Color>(
                      Colors.white,
                    ),
                    elevation: MaterialStateProperty.all<double>(0),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                    ),
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      EdgeInsets.symmetric(horizontal: 30.w, vertical: 15.h),
                    ),
                  ),
                  child: Text(
                    'إرسال التقييم',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
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