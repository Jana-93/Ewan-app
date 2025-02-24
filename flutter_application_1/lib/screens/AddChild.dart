import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'HomePage.dart'; // Parent Home Screen
import 'loginScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore for storing user data
import 'userpage.dart';

class AddChild extends StatefulWidget {
  AddChild({super.key});

  @override
  _AddChildState createState() => _AddChildState();
}

class _AddChildState extends State<AddChild> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for user input fields
  final TextEditingController _childNameController = TextEditingController();
  final TextEditingController _childAgeController = TextEditingController();
  final TextEditingController _childStatusController = TextEditingController();

  /// Function to Register Child
  Future<void> registerChild() async {
    try {
      // Get the current user (parent)
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("المستخدم غير مسجل دخول");
      }

      //  Always store in "children" collection, and add the parentId (user's uid)
      await FirebaseFirestore.instance.collection("children").add({
        "childName": _childNameController.text.trim(),
        "childAge": _childAgeController.text.trim(),
        "childStatus": _childStatusController.text.trim(),
        "parentId": user.uid, // Adding parentId to associate with the child
      });

      // Redirect to HomePage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Homepage()),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "تمت إضافة الطفل بنجاح ",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          backgroundColor: const Color.fromARGB(255, 255, 183, 0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                // borderRadius: BorderRadius.circular(20),
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
                  const SizedBox(height: 70),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        const SizedBox(height: 10),
                        FadeInUp(
                          duration: const Duration(milliseconds: 1000),
                          child: const Text(
                            "تسجيل بيانات الطفل",
                            style: TextStyle(color: Colors.white, fontSize: 30),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(60),
                        topRight: Radius.circular(60),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(30),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: <Widget>[
                            const Icon(
                              Icons.account_circle_outlined,
                              size: 100,
                              color: Color.fromARGB(255, 248, 141, 1),
                            ),
                            const SizedBox(height: 5),
                            _buildInputField(
                              "اسم الطفل",
                              controller: _childNameController,
                            ),
                            const SizedBox(height: 20),
                            _buildInputField(
                              "عمر الطفل",
                              controller: _childAgeController,
                            ),
                            const SizedBox(height: 20),
                            _buildInputField(
                              "حالة الطفل",
                              controller: _childStatusController,
                            ),
                            const SizedBox(height: 40),
                            FadeInUp(
                              duration: const Duration(milliseconds: 1600),
                              child: SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color.fromARGB(
                                      255,
                                      255,
                                      145,
                                      1,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate()) {
                                      await registerChild(); // Call register function
                                      if (!mounted) return;
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => UserPage(),
                                        ),
                                      );
                                    }
                                  },
                                  child: const Text(
                                    "إضافة طفل",
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: Icon(
                Icons.arrow_circle_right_outlined,
                color: Colors.white,
                size: 30,
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => UserPage()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Reusable Input Field
  Widget _buildInputField(
    String label, {
    TextEditingController? controller,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(label, style: const TextStyle(color: Colors.black, fontSize: 16)),
        const SizedBox(height: 5),
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
            textAlign: TextAlign.right,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 15,
              ),
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }
}
