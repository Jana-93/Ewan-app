import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/screens/loginScreen.dart';
import 'package:flutter_application_1/screens/Tappointment.dart'; // تأكد من استيراد الصفحات الأخرى

class TherapistProfilePage extends StatefulWidget {
  @override
  _TherapistProfilePageState createState() => _TherapistProfilePageState();
}

class _TherapistProfilePageState extends State<TherapistProfilePage> {
  String? selectedPrice; // سعر الجلسة المحدد
  int _selectedIndex = 0; // الفهرس المحدد لـ navBar

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        // البقاء في الصفحة الحالية (الملف الشخصي)
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Tappointment()),
        );
        break;
      case 2:
        // يمكنك إضافة صفحة أخرى هنا
        break;
      case 3:
        // يمكنك إضافة صفحة أخرى هنا
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
                    padding: const EdgeInsets.only(top: 50),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color.fromARGB(255, 219, 101, 37),
                          Color.fromRGBO(239, 108, 0, 1),
                          Color.fromRGBO(255, 167, 38, 1),
                        ],
                      ),
                      borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(15),
                        bottomLeft: Radius.circular(15),
                      ),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "الملف الشخصي",
                          style: TextStyle(
                            fontSize: 25,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage(data['profileImage']),
                          backgroundColor: Colors.grey[300],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "${data['firstName']} ${data['lastName']}",
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          data['email'],
                          style: const TextStyle(
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ..._buildProfileOptions(data, bio, context),
                ],
              ),
            );
          },
        ),
        bottomNavigationBar: navBar(), // إضافة navBar هنا
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
      // إضافة سعر الجلسة تحت "نبذة عني"
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.orange),
          borderRadius: BorderRadius.circular(10),
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
          title: Text(title, style: const TextStyle(fontSize: 16)),
          onTap: onTap,
        ),
      ),
    );
  }

  Widget _buildEditableProfileOption(
      IconData icon, String title, String value, BuildContext context, Function(String) onSave) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.orange),
          borderRadius: BorderRadius.circular(10),
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
          title: Text(title, style: const TextStyle(fontSize: 16)),
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.orange),
          borderRadius: BorderRadius.circular(10),
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
          title: Text("سعر الجلسة", style: const TextStyle(fontSize: 16)),
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
                    child: Text("$price ﷼"), // استخدام رمز الريال هنا
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
                      SnackBar(content: Text("تم حفظ سعر الجلسة: $selectedPrice ﷼")), // استخدام رمز الريال هنا
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
      height: 60,
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
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
          _buildNavItem(Icons.person, null, 0),
          _buildNavItem(Icons.folder, null, 2),
          _buildNavItem(Icons.calendar_month, null, 1),
          _buildNavItem(Icons.home, null, 3),
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
                    size: 30,
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