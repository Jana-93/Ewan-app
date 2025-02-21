import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/screens/AddChild.dart';
import 'package:flutter_application_1/screens/HomePage.dart';
import 'package:flutter_application_1/screens/appointmentpage.dart';
import 'package:flutter_application_1/screens/loginScreen.dart';
import 'package:flutter_application_1/screens/searchpage.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  int selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => UserPage()));
        break;
      case 1:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => Searchpage()));
        break;
      case 2:
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => Appointmentpage()));
        break;
      case 3:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => Homepage()));
        break;
    }
  }

  Future<List<Map<String, dynamic>>> _getChildrenData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      var snapshot = await FirebaseFirestore.instance
          .collection("children")
          .where("parentId", isEqualTo: user.uid)
          .get();
      return snapshot.docs.map((doc) {
        return {
          "childName": doc['childName'],
          "childIcon": Icons.account_circle_outlined,
          "childId": doc.id,
        };
      }).toList();
    } else {
      throw Exception("المستخدم غير مسجل دخول");
    }
  }

  Future<DocumentSnapshot> _getUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return await FirebaseFirestore.instance
          .collection('parents')
          .doc(user.uid)
          .get();
    } else {
      throw Exception("المستخدم غير مسجل دخول");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: FutureBuilder<List<Map<String, dynamic>>>(
          future: _getChildrenData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(child: Text('حدث خطأ.'));
            }

            return FutureBuilder<DocumentSnapshot>(
              future: _getUserData(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (userSnapshot.hasError) {
                  return const Center(
                      child: Text('حدث خطأ في تحميل البيانات.'));
                }

                if (!userSnapshot.hasData) {
                  return const Center(child: Text('لا توجد بيانات للمستخدم.'));
                }

                var userData = userSnapshot.data!;
                String firstName =
                    userData['firstName'] ?? 'الاسم الأول غير متوفر';
                String lastName =
                    userData['lastName'] ?? 'الاسم الأخير غير متوفر';
                String email = FirebaseAuth.instance.currentUser?.email ??
                    'البريد الإلكتروني غير متوفر';

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
                            ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: Image.asset(
                                "assets/images/user-icon.jpg",
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "$firstName $lastName",
                              style: const TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              email,
                              style: const TextStyle(
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      ...snapshot.data!.map((childData) {
                        return _buildProfileOption(
                          childData['childIcon'],
                          childData['childName'],
                          context,
                          () {},
                          onDelete: () {
                            _showDeleteDialog(context, childData['childId'],
                                childData['childName']);
                          },
                        );
                      }).toList(),
                      _buildProfileOption(Icons.add, "إضافة طفل", context, () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AddChild()),
                        );
                      }),
                      _buildProfileOption(
                          Icons.logout, "تسجيل الخروج", context, _logout),
                    ],
                  ),
                );
              },
            );
          },
        ),
        bottomNavigationBar: FadeInUp(
          duration: const Duration(milliseconds: 1000),
          child: navBar(),
        ),
      ),
    );
  }

  void _logout() {
    FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  // Navigation Bar
  Widget navBar() {
    return Container(
      height: 60,
      width: double.infinity,
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
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildImageItem("assets/images/ewan.png", 3),
          _buildNavItem(Icons.search, 1),
          _buildNavItem(Icons.calendar_today, 2),
          _buildNavItem(Icons.person, 0),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    bool isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () {
        _onItemTapped(index);
      },
      child: Column(
        children: [
          Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.only(
              top: 15,
              bottom: 0,
              left: 30,
              right: 30,
            ),
            child: Icon(
              icon,
              color: isSelected ? Colors.deepOrange : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageItem(String imagePath, int index) {
    bool isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () {
        _onItemTapped(index);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.only(
              right: 15,
            ),
            child: ImageIcon(
              AssetImage(imagePath),
              size: 60,
              color: isSelected ? Colors.deepOrange : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption(
      IconData icon, String title, BuildContext context, VoidCallback onTap,
      {VoidCallback? onDelete}) {
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
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (onDelete != null)
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: onDelete,
                ),
            ],
          ),
          onTap: onTap,
        ),
      ),
    );
  }

  // Dialog confirmation for deletion
  void _showDeleteDialog(
      BuildContext context, String childId, String childName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("تأكيد الحذف"),
          content: Text("هل أنت متأكد من حذف الطفل '$childName'?"),
          backgroundColor: Colors.white,
          actions: [
            TextButton(
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance
                      .collection('children')
                      .doc(childId)
                      .delete();
                  Navigator.of(context).pop();
                  setState(() {});
                } catch (e) {
                  print("حدث خطأ أثناء الحذف: $e");
                }
              },
              child: const Text("حذف", style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("إلغاء"),
            ),
          ],
        );
      },
    );
  }
}