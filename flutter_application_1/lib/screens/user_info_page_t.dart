import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter_application_1/screens/TherapistHomePage.dart';
import 'package:flutter_application_1/screens/loginScreen.dart';
import 'package:flutter_application_1/screens/Tappointment.dart';

class TherapistProfilePage extends StatefulWidget {
  @override
  _TherapistProfilePageState createState() => _TherapistProfilePageState();
}

class _TherapistProfilePageState extends State<TherapistProfilePage> {
  String? selectedPrice;
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
      
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Tappointment()),
        );
        break;
      case 2:
      
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => TherapistHomePage()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('therapists').doc(uid).get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Center(child: Text('لم يتم العثور على بيانات الطبيب'));
            }

            var data = snapshot.data!.data() as Map<String, dynamic>;
            String bio = data['bio'] ?? "لا يوجد وصف";

            if (data['bio'] == null) {
              FirebaseFirestore.instance
                  .collection('therapists')
                  .doc(uid)
                  .update({'bio': bio});
            }

            return SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.only(top: 50.h),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: const [
                          Color.fromARGB(255, 219, 101, 37),
                          Color.fromRGBO(239, 108, 0, 1),
                          Color.fromRGBO(255, 167, 38, 1),
                        ],
                      ),
                      borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(15.r),
                        bottomLeft: Radius.circular(15.r),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          "الملف الشخصي",
                          style: TextStyle(
                            fontSize: 25.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        CircleAvatar(
                          radius: 50.r,
                          backgroundImage: NetworkImage(data['profileImage']),
                          backgroundColor: Colors.grey[300],
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          "${data['firstName']} ${data['lastName']}",
                          style: TextStyle(
                            fontSize: 20.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          data['email'],
                          style: TextStyle(
                            color: Colors.white70,
                          ),
                        ),
                        SizedBox(height: 20.h),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),
                  ..._buildProfileOptions(data, bio, context),
                ],
              ),
            );
          },
        ),
        bottomNavigationBar: navBar(),
      ),
    );
  }

  List<Widget> _buildProfileOptions(Map<String, dynamic> data, String bio, BuildContext context) {
    return [
      _buildEditableProfileOption(
        Icons.info,
        "نبذة عني",
        bio,
        context,
        (newBio) async {
          await FirebaseFirestore.instance
              .collection('therapists')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .update({'bio': newBio});
        },
      ),
      _buildPriceOption(context),
      _buildProfileOption(Icons.work, "التخصص الدقيق: ${data['specialty']}", context, () {}),
      _buildProfileOption(Icons.timeline, "سنوات الخبرة: ${data['experience']}", context, () {}),
      _buildProfileOption(Icons.phone, "رقم الجوال: ${data['phone']}", context, () {}),
      _buildProfileOption(Icons.logout, "تسجيل الخروج", context, () {
        FirebaseAuth.instance.signOut();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }),
    ];
  }

  Widget _buildProfileOption(
      IconData icon, String title, BuildContext context, VoidCallback onTap) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 5.h),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.orange),
          borderRadius: BorderRadius.circular(10.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          leading: Icon(icon, color: Colors.orange),
          title: Text(title, style: TextStyle(fontSize: 16.sp)),
          onTap: onTap,
        ),
      ),
    );
  }

  Widget _buildEditableProfileOption(
      IconData icon, String title, String value, BuildContext context, Function(String) onSave) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 5.h),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.orange),
          borderRadius: BorderRadius.circular(10.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          leading: Icon(icon, color: Colors.orange),
          title: Text(title, style: TextStyle(fontSize: 16.sp)),
          subtitle: Text(value),
          trailing: IconButton(
            icon: Icon(Icons.edit, color: Colors.blue),
            onPressed: () {
              _showEditDialog(context, value, onSave);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPriceOption(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 5.h),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.orange),
          borderRadius: BorderRadius.circular(10.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          leading: Icon(Icons.monetization_on, color: Colors.orange),
          title: Text("سعر الجلسة", style: TextStyle(fontSize: 16.sp)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<String>(
                value: selectedPrice,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedPrice = newValue;
                  });
                },
                items: List.generate(7, (index) {
                  int price = 40 + (index * 10);
                  return DropdownMenuItem<String>(
                    value: price.toString(),
                    child: Text("$price ﷼"),
                  );
                }),
              ),
              IconButton(
                icon: Icon(Icons.save, color: Colors.blue),
                onPressed: () async {
                  if (selectedPrice != null) {
                    await FirebaseFirestore.instance
                        .collection('therapists')
                        .doc(FirebaseAuth.instance.currentUser!.uid)
                        .update({'sessionPrice': selectedPrice});
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("تم حفظ سعر الجلسة: $selectedPrice ﷼")),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("الرجاء اختيار سعر الجلسة أولاً")),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget navBar() {
    return Container(
      height: 60.h,
      margin: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 5,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home, null, 3),
          _buildNavItem(Icons.folder, null, 2),
          _buildNavItem(Icons.calendar_month, null, 1),
          _buildNavItem(Icons.person, null, 0),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData? icon, String? imagePath, int index) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        _onItemTapped(index);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            alignment: Alignment.center,
            child: imagePath != null
                ? ImageIcon(
                    AssetImage(imagePath),
                    size: 30.sp,
                    color: isSelected ? Colors.deepOrange : Colors.grey,
                  )
                : Icon(
                    icon,
                    color: isSelected ? Colors.deepOrange : Colors.grey,
                  ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, String initialValue, Function(String) onSave) {
    TextEditingController controller = TextEditingController(text: initialValue);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("تعديل النبذة"),
          content: TextField(
            controller: controller,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: "أدخل نبذة عنك",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("إلغاء"),
            ),
            TextButton(
              onPressed: () {
                onSave(controller.text);
                Navigator.of(context).pop();
              },
              child: Text("حفظ"),
            ),
          ],
        );
      },
    );
  }
}