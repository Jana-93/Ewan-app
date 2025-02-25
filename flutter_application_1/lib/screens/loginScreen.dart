import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_application_1/screens/HomePage.dart';
import 'package:flutter_application_1/screens/T_signup.dart';
import 'package:flutter_application_1/screens/TherapistHomePage.dart';
import 'package:flutter_application_1/screens/psignup.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isVisible = true;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> login() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('يرجى إدخال البريد الإلكتروني وكلمة المرور')),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('تم تسجيل الدخول بنجاح')));

      if (!mounted) return; // تجنب الأخطاء عند استخدام context
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Homepage()),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = "حدث خطأ ";

      if (e.code == 'user-not-found') {
        errorMessage = 'البريد الإلكتروني غير مسجل';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'كلمة المرور غير صحيحة';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'البريد الإلكتروني غير صحيح';
      } else if (e.code == 'network-request-failed') {
        errorMessage = 'تحقق من اتصال الإنترنت';
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              // borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
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
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      FadeInUp(
                        duration: const Duration(milliseconds: 1000),
                        child: const Text(
                          "تسجيل الدخول",
                          style: TextStyle(color: Colors.white, fontSize: 40),
                          textAlign: TextAlign.right,
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(50),
                      topRight: Radius.circular(50),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      children: <Widget>[
                        const SizedBox(height: 10),
                        FadeInUp(
                          duration: const Duration(milliseconds: 1400),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              const Text(
                                "البريد الإلكتروني",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 15),
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
                                child: TextField(
                                  controller: emailController,
                                  textAlign: TextAlign.right,
                                  decoration: InputDecoration(
                                    hintText: "أدخل البريد الإلكتروني ",
                                    hintStyle: TextStyle(color: Colors.grey),
                                    border: InputBorder.none,
                                    prefixIcon: Icon(
                                      Icons.email,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 5),
                              const Text(
                                "كلمة المرور",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                              ),
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
                                child: TextField(
                                  obscureText: isVisible,
                                  controller: passwordController,
                                  textAlign: TextAlign.right,
                                  decoration: InputDecoration(
                                    hintText: "أدخل كلمة المرور",
                                    hintStyle: TextStyle(color: Colors.grey),
                                    border: InputBorder.none,
                                    prefixIcon: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          isVisible = !isVisible;
                                        });
                                      },
                                      icon: Icon(
                                        isVisible
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 50),
                        FadeInUp(
                          duration: const Duration(milliseconds: 1600),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF6872F),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
                              ),
                              child: const Text(
                                "تسجيل الدخول",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        FadeInUp(
                          duration: const Duration(milliseconds: 1650),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "ليس لديك حساب؟ ",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(""),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Psignup(),
                                    ),
                                  );
                                },
                                child: FadeInUp(
                                  duration: const Duration(milliseconds: 1600),
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        // تحويل المستخدم إلى صفحة التسجيل
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => Psignup(),
                                          ), // استبدل SignupPage بالصفحة الفعلية الخاصة بك
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromARGB(
                                          255,
                                          255,
                                          255,
                                          255,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            50,
                                          ),
                                          side: BorderSide(
                                            color: const Color(0xFFFCB47A),
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 15,
                                        ),
                                      ),
                                      child: const Text(
                                        "تسجيل دخول جديد",
                                        style: TextStyle(
                                          color: Colors.orangeAccent,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => TherapistSignUpPage(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "تسجيل الدخول كطبيب ",
                                  style: TextStyle(
                                    color: Color(0xFFFCB47A),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                    decorationColor: Color(0xFFFCB47A),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
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
}