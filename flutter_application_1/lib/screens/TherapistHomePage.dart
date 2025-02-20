import 'package:flutter/material.dart';

class TherapistHomePage extends StatefulWidget {
  @override
  _TherapistHomePageState createState() => _TherapistHomePageState();
}

class _TherapistHomePageState extends State<TherapistHomePage> {
  int _selectedIndex = 3;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(150.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.orange,
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
                        'د. سارة محمد',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ],
                  ),
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage(
                      'assets/images/doctor.jpg',
                    ), // ✅ Fixed syntax error
                  ),
                ],
              ),
            ),
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
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.orange,
          unselectedItemColor: Colors.grey,
          currentIndex: _selectedIndex, // ✅ Maintains the selected index
          onTap: _onItemTapped, // ✅ Handles navigation
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'الملف الشخصي',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.folder), label: 'الملفات'),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: 'المواعيد',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
          ],
        ),
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
}

void main() {
  runApp(
    MaterialApp(debugShowCheckedModeBanner: false, home: TherapistHomePage()),
  );
}
