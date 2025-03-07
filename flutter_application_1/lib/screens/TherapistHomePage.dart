import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/feedbackScreen.dart';
import 'package:flutter_application_1/screens/Tappointment.dart';
import 'package:flutter_application_1/screens/user_info_page_t.dart';

class TherapistHomePage extends StatefulWidget {
  @override
  _TherapistHomePageState createState() => _TherapistHomePageState();
}

class _TherapistHomePageState extends State<TherapistHomePage> {
  int _selectedIndex = 3;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => TherapistProfilePage()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Tappointment()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => FeedbackScreen()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => TherapistHomePage()),
        );
        break;
    }
  }

  Future<Map<String, dynamic>> _fetchUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot doc =
          await _firestore.collection('therapists').doc(user.uid).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
    }
    return {};
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(150.0),
          child: FutureBuilder<Map<String, dynamic>>(
            future: _fetchUserData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('حدث خطأ أثناء جلب البيانات'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('لا توجد بيانات'));
              } else {
                Map<String, dynamic> userData = snapshot.data!;
                String firstName = userData['firstName'] ?? 'غير معروف';
                String lastName = userData['lastName'] ?? 'غير معروف';
                String profileImageUrl = userData['profileImage'] ?? '';

                return Container(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
              begin: Alignment.topCenter,
              colors: const [
                Color.fromARGB(255, 219, 101, 37),
                Color.fromRGBO(239, 108, 0, 1),
                Color.fromRGBO(255, 167, 38, 1),
              ],
            ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 50, left: 20, right: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'مرحبًا،',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'د. $firstName $lastName',
                              style: TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          ],
                        ),
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: profileImageUrl.isNotEmpty
                              ? NetworkImage(profileImageUrl)
                              : AssetImage('assets/images/doctor.jpg')
                                  as ImageProvider,
                        ),
                      ],
                    ),
                  ),
                );
              }
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              buildMenuItem('المواعيد السابقة', Icons.history, context),
              buildMenuItem('المواعيد القادمة', Icons.schedule, context),
              buildMenuItem('تقدم المراجعين', Icons.bar_chart, context),
            ],
          ),
        ),
        bottomNavigationBar: navBar(), // استبدل _buildCustomNavBar بـ navBar
      ),
    );
  }

  Widget buildMenuItem(String title, IconData icon, BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: ListTile(
        title: Text(title, textAlign: TextAlign.right),
        leading: Icon(icon, color: Colors.orange),
        trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey),
        onTap: () {
          // Handle navigation or actions
        },
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
}

void main() {
  runApp(
    MaterialApp(debugShowCheckedModeBanner: false, home: TherapistHomePage()),
  );
}