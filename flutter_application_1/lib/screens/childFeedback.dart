import 'package:flutter/material.dart';
import 'package:flutter_application_1/firestore_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_application_1/screens/HomePage.dart';

class ChildFeedback extends StatefulWidget {
  final String uid;

  const ChildFeedback({required this.uid, Key? key}) : super(key: key);

  @override
  _ChildFeedbackState createState() => _ChildFeedbackState();
}

class _ChildFeedbackState extends State<ChildFeedback> {
  double _rating = 0;
  final FirestoreService _firestoreService = FirestoreService();
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F9F9),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Header Section
                  _buildHeader(),
                  SizedBox(height: 40.h),
                  
                  // Illustration
                  _buildIllustration(),
                  SizedBox(height: 40.h),
                  
                  // Rating Section
                  _buildRatingSection(),
                  SizedBox(height: 40.h),
                  
                  // Buttons Section
                  _buildActionButtons(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              icon: Icon(Icons.close, size: 28.sp, color: Colors.grey),
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Homepage()),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Text(
          'كيف كانت جلستك؟',
          style: TextStyle(
            fontSize: 28.sp,
            fontFamily: "NotoKufiArabic",
            color: const Color(0xFFF6872F),
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'سعدنا بوجودك معنا! نرغب في معرفة رأيك لتقديم تجربة أفضل',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16.sp,
            color: Colors.grey[700],
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildIllustration() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Image.asset(
        'assets/images/rrr.jpg',
        width: 180.w,
        height: 180.h,
      
      ),
    );
  }

  Widget _buildRatingSection() {
    return Column(
      children: [
        RatingBar.builder(
          initialRating: _rating,
          minRating: 1,
          direction: Axis.horizontal,
          allowHalfRating: false,
          itemCount: 5,
          itemSize: 50.sp,
          itemPadding: EdgeInsets.symmetric(horizontal: 6.w),
          itemBuilder: (context, _) => Icon(
            Icons.star_rounded,
            color: Colors.amber,
          ),
          unratedColor: Colors.grey[300],
          glowColor: Colors.amber.withAlpha(50),
          onRatingUpdate: (rating) => setState(() => _rating = rating),
        ),
        SizedBox(height: 16.h),
        AnimatedOpacity(
          opacity: _rating > 0 ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: Text(
            _getRatingText(_rating),
            style: TextStyle(
              fontSize: 18.sp,
              color: const Color(0xFFF6872F),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  String _getRatingText(double rating) {
    switch (rating.toInt()) {
      case 1:
        return 'لم تعجبني الجلسة';
      case 2:
        return 'بحاجة لتحسين';
      case 3:
        return 'جيدة';
      case 4:
        return 'رائعة جداً';
      case 5:
        return 'ممتازة! أحببتها كثيراً';
      default:
        return '';
    }
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Homepage()),
            ),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              side: BorderSide(color: Colors.grey[300]!),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Text(
              'تخطي',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey[700],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: ElevatedButton(
            onPressed: _rating == 0 ? null : _submitRating,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              backgroundColor: const Color(0xFFF6872F),
              disabledBackgroundColor: const Color(0xFFF6872F).withOpacity(0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              elevation: 0,
            ),
            child: _isSubmitting
                ? SizedBox(
                    width: 20.w,
                    height: 20.h,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    'إرسال التقييم',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Future<void> _submitRating() async {
    setState(() => _isSubmitting = true);
    
    try {
      await _firestoreService.addRating(widget.uid, _rating);
      
      // Show success dialog
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 60.sp),
              SizedBox(height: 16.h),
              Text(
                'شكراً لك!',
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'تم استلام تقييمك بنجاح',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 24.h),
              ElevatedButton(
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Homepage()),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 242, 141, 59),
                  minimumSize: Size(double.infinity, 48.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'العودة للرئيسية',
                  style: TextStyle(fontSize: 16.sp,color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'حدث خطأ أثناء إرسال التقييم!',
            textDirection: TextDirection.rtl,
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}