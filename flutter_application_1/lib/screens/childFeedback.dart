import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChildFeedback extends StatefulWidget {
  @override
  _ChildFeedbackState createState() => _ChildFeedbackState();
}

class _ChildFeedbackState extends State<ChildFeedback> {
  int _selectedRating = 0;
  final List<String> _emojis = ['😠', '😞', '😐', '😊', '😍'];

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
            SizedBox(height: 20.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _emojis
                  .asMap()
                  .entries
                  .map((entry) {
                    int index = entry.key;
                    String emoji = entry.value;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedRating = index + 1;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(3.w),
                        decoration: BoxDecoration(
                          color: _selectedRating == index + 1
                              ? Colors.orange.withOpacity(0.3)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Text(
                          emoji,
                          style: TextStyle(fontSize: 30.sp),
                        ),
                      ),
                    );
                  })
                  .toList(),
            ),
            SizedBox(height: 40.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.grey[300]!),
                    foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
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
                    style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_selectedRating == 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('الرجاء تحديد تقييم!', textDirection: TextDirection.rtl),
                        ),
                      );
                    } else {
                      print('التقييم المحدد: $_selectedRating');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('شكرًا على تقييمك!', textDirection: TextDirection.rtl),
                        ),
                      );
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) {
                        if (states.contains(MaterialState.pressed)) {
                          return Colors.orange.withOpacity(0.5);
                        }
                        return Colors.transparent;
                      },
                    ),
                    foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
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
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        colors: const [
                          Color.fromARGB(255, 219, 101, 37),
                          Color.fromRGBO(239, 108, 0, 1),
                          Color.fromRGBO(255, 167, 38, 1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 50.w, vertical: 14.h),
                    child: Text(
                      'إرسال التقييم',
                      style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
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