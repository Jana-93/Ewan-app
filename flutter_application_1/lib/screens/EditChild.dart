import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'userpage.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EditChild extends StatefulWidget {
  final String childId;

  const EditChild({Key? key, required this.childId}) : super(key: key);

  @override
  _EditChildState createState() => _EditChildState();
}

class _EditChildState extends State<EditChild> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _childNameController = TextEditingController();
  final TextEditingController _childStatusController = TextEditingController();

  String? _selectedAge;
  final List<String> _ages = List.generate(
    7,
    (index) => (index + 5).toString(),
  );

  @override
  void initState() {
    super.initState();
    _loadChildData();
  }

  Future<void> _loadChildData() async {
    try {
      DocumentSnapshot childDoc = await FirebaseFirestore.instance
          .collection("children")
          .doc(widget.childId)
          .get();

      if (childDoc.exists) {
        setState(() {
          _childNameController.text = childDoc['childName'] ?? '';
          _selectedAge = childDoc['childAge'] ?? '';
          _childStatusController.text = childDoc['childStatus'] ?? '';
        });
      } else {
        throw Exception("الطفل غير موجود");
      }
    } catch (e) {
      print("Error loading child data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "حدث خطأ أثناء تحميل بيانات الطفل",
            style: TextStyle(color: Colors.white, fontSize: 14.sp),
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _updateChildData() async {
    try {
      if (_formKey.currentState!.validate()) {
        // Show confirmation dialog
        bool confirmUpdate = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                "تأكيد الحفظ",
                style: TextStyle(fontSize: 18.sp,fontFamily: "NotoKufiArabic"),
                textAlign: TextAlign.center,
              ),
              content: Text(
                "هل أنت متأكد من حفظ التعديلات؟",
                style: TextStyle(fontSize: 16.sp),
                textAlign: TextAlign.center,
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false); // Return false if canceled
                  },
                  child: Text(
                    "إلغاء",
                    style: TextStyle(fontSize: 16.sp,color: Colors.lightBlue),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true); // Return true if confirmed
                  },
                  child: Text(
                    "حفظ",
                    style: TextStyle(fontSize: 16.sp,color: Colors.deepOrange),
                  ),
                ),
              ],
            );
          },
        );

        // If user confirmed, proceed with the update
        if (confirmUpdate == true) {
          await FirebaseFirestore.instance
              .collection("children")
              .doc(widget.childId)
              .update({
            "childName": _childNameController.text.trim(),
            "childAge": _selectedAge,
            "childStatus": _childStatusController.text.trim(),
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "تم تحديث بيانات الطفل بنجاح",
                style: TextStyle(color: Colors.white, fontSize: 14.sp),
                textAlign: TextAlign.center,
              ),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 2),
            ),
          );

          if (!mounted) return;

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => UserPage()),
          );
        }
      }
    } catch (e) {
      print("Error updating child data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "حدث خطأ أثناء تحديث بيانات الطفل",
            style: TextStyle(color: Colors.white, fontSize: 14.sp),
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
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
                  SizedBox(height: 70.h),
                  Padding(
                    padding: EdgeInsets.all(20.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(height: 10.h),
                        Text(
                          "تعديل بيانات الطفل",
                          style: TextStyle(color: Colors.white, fontSize: 30.sp),
                          textAlign: TextAlign.center,
                        ),
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
                            _buildAgeDropdown(), // Dropdown for child's age
                            SizedBox(height: 20.h),
                            _buildInputField(
                              "حالة الطفل",
                              controller: _childStatusController,
                            ),
                            SizedBox(height: 40.h),
                            SizedBox(
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
                                onPressed: _updateChildData,
                                child: Text(
                                  "حفظ التعديلات",
                                  style: TextStyle(
                                    fontSize: 20.sp,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
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

  Widget _buildInputField(String label, {TextEditingController? controller}) {
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
            textAlign: TextAlign.right,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20.w,
                vertical: 15.h,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'الرجاء إدخال $label';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAgeDropdown() {
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
          child: DropdownButtonFormField<String>(
            value: _selectedAge,
            items: _ages.map((String age) {
              return DropdownMenuItem<String>(
                value: age,
                child: Text(age, textAlign: TextAlign.right),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedAge = newValue; // Update selected age
              });
            },
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20.w,
                vertical: 15.h,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'الرجاء اختيار عمر الطفل';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }
}