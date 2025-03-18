import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'HomePage.dart'; // Parent Home Screen
import 'loginScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore for storing user data
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Psignup extends StatefulWidget {
  Psignup({super.key});

  @override
  _PsignupState createState() => _PsignupState();
}

class _PsignupState extends State<Psignup> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for user input fields
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // State to track password visibility
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  /// Function to Register Parents
  Future<void> register() async {
    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      // Get the user ID (UID)
      String uid = credential.user!.uid;

      //  Always store in "parents" collection
      await FirebaseFirestore.instance.collection("parents").doc(uid).set({
        "firstName": _firstNameController.text.trim(),
        "lastName": _lastNameController.text.trim(),
        "email": _emailController.text.trim(),
        "phone": _phoneController.text.trim(),
        "uid": uid,
      });

      //  Redirect Parent to HomePage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Homepage()),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "تم إنشاء الحساب بنجاح ",
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          backgroundColor: Color(0xFFFCB47A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print(" Error: $e");
    }
  }

  ///  Password Validation
  String? _validatePassword(String value) {
    if (value.length < 8)
      return "يجب أن تحتوي كلمة المرور على 8 خانات على الأقل";
    if (!RegExp(r'[A-Za-z]').hasMatch(value))
      return "يجب أن تحتوي كلمة المرور على حرف واحد على الأقل";
    if (!RegExp(r'[0-9]').hasMatch(value))
      return "يجب أن تحتوي كلمة المرور على رقم واحد على الأقل";
    return null;
  }

  ///  Confirm Password Validation
  String? _validateConfirmPassword(String value) {
    if (value != _passwordController.text) return "كلمة المرور غير متطابقة";
    return null;
  }

  ///  Email Validation
  String? _validateEmail(String value) {
    if (value.isEmpty) {
      return "هذا الحقل مطلوب";
    }
    // Regular expression for email validation
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return "البريد الإلكتروني غير صحيح";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
              ),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                colors: [
                  Color.fromARGB(255, 219, 101, 37),
                  Color.fromRGBO(239, 108, 0, 1),
                  Color.fromRGBO(255, 167, 38, 1),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                SizedBox(height: 50.h),
                Padding(
                  padding: EdgeInsets.all(20.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      FadeInUp(
                        duration: const Duration(milliseconds: 1000),
                        child: Text(
                          "حساب جديد",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 37.sp,
                            fontFamily: "NotoKufiArabic",
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                      SizedBox(height: 10.h),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40.r),
                      topRight: Radius.circular(40.r),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(30.r),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          SizedBox(height: 10.h),
                          _buildInputField(
                            "الاسم الأول",
                            controller: _firstNameController,
                          ),
                          SizedBox(height: 20.h),
                          _buildInputField(
                            "الاسم الأخير",
                            controller: _lastNameController,
                          ),
                          SizedBox(height: 20.h),
                          _buildInputField(
                            "البريد الإلكتروني",
                            controller: _emailController,
                            validator: _validateEmail,
                          ),
                          SizedBox(height: 20.h),
                          _buildPasswordField(
                            "كلمة المرور",
                            controller: _passwordController,
                            obscureText: !_isPasswordVisible,
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                            icon: _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          SizedBox(height: 20.h),
                          _buildPasswordField(
                            "إعادة كتابة كلمة المرور",
                            controller: _confirmPasswordController,
                            obscureText: !_isConfirmPasswordVisible,
                            onPressed: () {
                              setState(() {
                                _isConfirmPasswordVisible =
                                    !_isConfirmPasswordVisible;
                              });
                            },
                            icon: _isConfirmPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          SizedBox(height: 20.h),
                          _buildInputField(
                            "رقم الجوال",
                            controller: _phoneController,
                          ),
                          SizedBox(height: 40.h),
                          FadeInUp(
                            duration: const Duration(milliseconds: 1600),
                            child: SizedBox(
                              width: double.infinity,
                              height: 50.h,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF6872F),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      50.r,
                                    ),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    vertical: 15.h,
                                    horizontal: 20.w,
                                  ),
                                ),
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    await register();
                                    if (!mounted) return;
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => LoginScreen(),
                                      ),
                                    );
                                  }
                                },
                                child: Text(
                                  "إنشاء حساب",
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 20.h,
                          ),
                          FadeInUp(
                            duration: const Duration(milliseconds: 1800),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LoginScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                "لديك حساب؟ سجل الآن",
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: Color(0xFFFCB47A),
                                  decoration: TextDecoration.underline,
                                  decorationColor: Color(0xFFFCB47A),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ///  Reusable Input Field
  Widget _buildInputField(
    String label, {
    bool obscureText = false,
    TextEditingController? controller,
    String? Function(String)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.black, fontSize: 16.sp),
        ),
        SizedBox(height: 10.h),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.r),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(225, 95, 27, .3),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            textAlign: TextAlign.right,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20.w,
                vertical: 15.h,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return "هذا الحقل مطلوب";
              if (validator != null) return validator(value);
              return null;
            },
          ),
        ),
      ],
    );
  }

  ///  Reusable Password Field with Visibility Icon
  Widget _buildPasswordField(
    String label, {
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback onPressed,
    required IconData icon,
    String? Function(String)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.black, fontSize: 16.sp),
        ),
        SizedBox(height: 10.h),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.r),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(225, 95, 27, .3),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            textAlign: TextAlign.right,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20.w,
                vertical: 15.h,
              ),
              
              prefixIcon: IconButton(
                icon: Icon(icon),
                onPressed: onPressed,
                color: Colors.grey,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return "هذا الحقل مطلوب";
              if (validator != null) return validator(value);
              return null;
            },
          ),
        ),
      ],
    );
  }
}