import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'HomePage.dart'; // Parent Home Screen
import 'loginScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore for storing user data

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
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          backgroundColor: Color(0xFFFCB47A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                // topLeft: Radius.circular(60),
                // topRight: Radius.circular(60),
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
                const SizedBox(height: 50),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      FadeInUp(
                        duration: const Duration(milliseconds: 1000),
                        child: const Text(
                          "حساب جديد",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 37,
                            fontFamily: "NotoKufiArabic",
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
                // const SizedBox(height: 20),
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(30),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          // const SizedBox(height: 60),
                          const SizedBox(height: 10),
                          _buildInputField(
                            "الاسم الأول",
                            controller: _firstNameController,
                          ),
                          const SizedBox(height: 20),
                          _buildInputField(
                            "الاسم الأخير",
                            controller: _lastNameController,
                          ),
                          const SizedBox(height: 20),
                          _buildInputField(
                            "البريد الإلكتروني",
                            controller: _emailController,
                          ),
                          const SizedBox(height: 20),
                          _buildInputField(
                            "كلمة المرور",
                            controller: _passwordController,
                            obscureText: true,
                            validator: _validatePassword,
                          ),
                          const SizedBox(height: 20),
                          _buildInputField(
                            "إعادة كتابة كلمة المرور",
                            controller: _confirmPasswordController,
                            obscureText: true,
                            validator: _validateConfirmPassword,
                          ),
                          const SizedBox(height: 20),
                          _buildInputField(
                            "رقم الجوال",
                            controller: _phoneController,
                          ),
                          const SizedBox(height: 40),
                          FadeInUp(
                            duration: const Duration(milliseconds: 1600),
                            child: SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF6872F),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 15,
                                  ),
                                ),
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    await register(); // Call register function
                                    if (!mounted) return;
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => LoginScreen(),
                                      ),
                                    );
                                  }
                                },
                                child: const Text(
                                  "إنشاء حساب",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
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
                              child: const Text(
                                "لديك حساب؟ سجل الآن",
                                style: TextStyle(
                                  fontSize: 16,
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
        Text(label, style: const TextStyle(color: Colors.black, fontSize: 16)),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
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
            // textDirection: TextDirection.rtl,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 15,
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
