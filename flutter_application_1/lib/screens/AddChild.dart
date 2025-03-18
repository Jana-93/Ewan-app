import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore for storing user data
import 'userpage.dart';
import 'package:uuid/uuid.dart'; // Import uuid package
import 'package:flutter_screenutil/flutter_screenutil.dart';

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

      // Check if all fields are empty
      if (_childNameController.text.trim().isEmpty &&
          selectedChildAge == null &&
          _childStatusController.text.trim().isEmpty) {
        throw Exception("يرجى تعبئة الحقول");
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

      // Check if a child with the same name already exists
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance
              .collection("children")
              .where("childName", isEqualTo: _childNameController.text.trim())
              .where(
                "parentId",
                isEqualTo: user.uid,
              ) // Ensure it's the same parent
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        throw Exception("يوجد طفل بنفس الاسم بالفعل");
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
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          backgroundColor: const Color.fromARGB(255, 255, 183, 0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
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
            style: TextStyle(fontSize: 16.sp, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          backgroundColor: const Color.fromARGB(255, 99, 98, 98),
          duration: Duration(seconds: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
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
                  begin: Alignment.topLeft,
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
                  SizedBox(height: 70.h),
                  Padding(
                    padding: EdgeInsets.all(10.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(height: 10.h),
                        FadeInUp(
                          duration: const Duration(milliseconds: 1000),
                          child: Text(
                            "تسجيل بيانات الطفل",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 30.sp,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(60.r),
                        topRight: Radius.circular(60.r),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(30.r),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: <Widget>[
                            Icon(
                              Icons.account_circle_outlined,
                              size: 100.sp,
                              color: const Color.fromARGB(255, 248, 141, 1),
                            ),
                            SizedBox(height: 5.h),
                            _buildInputField(
                              "اسم الطفل",
                              controller: _childNameController,
                            ),
                            SizedBox(height: 20.h),
                            _buildAgeDropdown(), // Use dropdown for age
                            SizedBox(height: 20.h),
                            _buildInputField(
                              "حالة الطفل",
                              controller: _childStatusController,
                            ),
                            SizedBox(height: 40.h),
                            FadeInUp(
                              duration: const Duration(milliseconds: 1600),
                              child: SizedBox(
                                width: double.infinity,
                                height: 50.h,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color.fromARGB(
                                      255,
                                      255,
                                      145,
                                      1,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.r),
                                    ),
                                  ),
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate()) {
                                      await registerChild(); // Call register function
                                    }
                                  },
                                  child: Text(
                                    "إضافة طفل",
                                    style: TextStyle(
                                      fontSize: 20.sp,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 20.h),
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
            top: 40.h,
            right: 20.w,
            child: IconButton(
              icon: Icon(
                Icons.arrow_circle_right_outlined,
                color: Colors.white,
                size: 30.sp,
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
        Text(label, style: TextStyle(color: Colors.black, fontSize: 16.sp)),
        SizedBox(height: 5.h),
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
            textAlign: TextAlign.right, // Align text to the right
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20.w,
                vertical: 15.h,
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
    List<String> ages = List.generate(7, (index) => (5 + index).toString());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          "عمر الطفل",
          style: TextStyle(color: Colors.black, fontSize: 16.sp),
        ),
        SizedBox(height: 5.h),
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
          child: DropdownButtonHideUnderline(
            child: DropdownButtonFormField<String>(
              value: selectedChildAge,
              isExpanded: true,
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 20.w,
                  vertical: 15.h,
                ),
              ),
              hint: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "اختر عمر الطفل",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              icon: Icon(Icons.arrow_drop_down, color: Colors.grey),
              iconEnabledColor: Colors.grey,
              items:
                  ages.map((age) {
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
