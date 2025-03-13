import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore for storing user data
import 'userpage.dart';
import 'package:uuid/uuid.dart'; // Import uuid package

class AddChild extends StatefulWidget {
  AddChild({super.key});

  @override
  _AddChildState createState() => _AddChildState();
}

class _AddChildState extends State<AddChild> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for user input fields
  final TextEditingController _childNameController = TextEditingController();
  String? selectedChildAge; // Variable to hold the selected age
  final TextEditingController _childStatusController = TextEditingController();

  // Add childId as a variable
  String? childId; // This will hold the childId

  /// Function to Register Child
  Future<void> registerChild() async {
    try {
      // Get the current user (parent)
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("المستخدم غير مسجل دخول");
      }

      if (_childNameController.text.trim().isEmpty) {
        throw Exception("يرجى إدخال اسم الطفل");
      }

      if (selectedChildAge == null) {
        throw Exception("يرجى اختيار عمر الطفل");
      }

      if (_childStatusController.text.trim().isEmpty) {
        throw Exception("يرجى إدخال حالة الطفل");
      }

      // Generate a unique childId
      var uuid = Uuid();
      childId = uuid.v4(); // Assign a unique ID to childId

      // Always store in "children" collection, and add the parentId (user's uid)
      await FirebaseFirestore.instance.collection("children").add({
        "childId": childId, // Add the generated childId
        "childName": _childNameController.text.trim(),
        "childAge": selectedChildAge, // Use selected child age
        "childStatus": _childStatusController.text.trim(),
        "parentId": user.uid, // Adding parentId to associate with the child
      });

      // Show success message
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

      // Redirect to HomePage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => UserPage()),
      );
    } catch (e) {
      print("Error: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          backgroundColor: const Color.fromARGB(255, 99, 98, 98),
          duration: Duration(seconds: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
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
                            _buildAgeDropdown(), // Use dropdown for age
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
            textAlign: TextAlign.right, // Align text to the right
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

  /// Dropdown for child's age
  Widget _buildAgeDropdown() {
    List<String> ages = List.generate(
      7,
      (index) => (5 + index).toString(),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text(
          "عمر الطفل",
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
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
          child: DropdownButtonHideUnderline(
            child: DropdownButtonFormField<String>(
              value: selectedChildAge,
              isExpanded: true,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
              ),
              hint: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "اختر عمر الطفل",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              icon: const Icon(
                Icons.arrow_drop_down,
                color: Colors.grey,
              ),
              iconEnabledColor: Colors.grey,
              items: ages.map((age) {
                return DropdownMenuItem<String>(
                  value: age,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(age),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedChildAge = value; // Update selected child age
                });
              },
              validator: (value) {
                if (value == null) {
                  return "يرجى اختيار عمر الطفل";
                }
                return null;
              },
            ),
          ),
        ),
      ],
    );
  }
}