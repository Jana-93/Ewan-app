import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/HomePage.dart';
import 'package:flutter_application_1/screens/userpage.dart';
import 'package:flutter_application_1/screens/searchpage.dart';
import 'package:flutter_application_1/screens/appointmentpage.dart';

class Searchpage extends StatefulWidget {
  @override
  _SearchpageState createState() => _SearchpageState();
}

class _SearchpageState extends State<Searchpage> {
  int selectedIndex = 1;
  int selectedDoctorIndex = -1;
  String searchQuery = "";

  List<Map<String, dynamic>> doctors = [
    {
      "name": "د. عبدالعزيز فهد",
      "specialty": "أخصائي نفسي",
      "deg": "حاصل على درجة دكتوارة في الارشاد النفسي",
      "price": "100 ريال",
      "image": "assets/images/doc3.jpg",
    },
    {
      "name": "د. سارة محمد",
      "specialty": "أخصائية نفسية",
      "deg": "حاصله على ماجستير في علم النفس",
      "price": "85 ريال",
      "image": "assets/images/doctor.jpg",
    },
    {
      "name": "د. نورة محمد",
      "specialty": "أخصائي نفسي",
      "deg": "حاصله على درجة ماجستير في علم النفس من جامعة الملك سعود",
      "price": "85 ريال",
      "image": "assets/images/doc1.jpg",
    },
    {
      "name": "د. شرف سعد",
      "specialty": "أخصائي نفسي",
      "deg": "حاصل على درجة ماجستير في علم النفس من جامعة الملك خالد",
      "price": "85 ريال",
      "image": "assets/images/doc4.jpg",
    },
  ];

  void _onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => UserPage()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Searchpage()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Appointmentpage()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Homepage()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
          
            begin: Alignment.topCenter,
            colors: [
              const Color.fromARGB(255, 219, 101, 37),
              const Color.fromRGBO(239, 108, 0, 1),
              const Color.fromRGBO(255, 167, 38, 1),
            ],
           

          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 60),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: const [
                  Text(
                    "البحث عن طبيب",
                    style: TextStyle(color: Colors.white, fontSize: 40),
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(60),
                    topRight: Radius.circular(60),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    children: [
                      TextField(
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: "اختر الطبيب المناسب لك",
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: ListView.builder(
                          itemCount: doctors.length,
                          itemBuilder: (context, index) {
                            return Card(
                              margin: EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: AssetImage(
                                    doctors[index]["image"],
                                  ),
                                ),
                                title: Text(doctors[index]["name"]),
                                subtitle: Text(doctors[index]["deg"]),
                                trailing: Text(
                                  doctors[index]["price"],
                                  style: TextStyle(color: Colors.green),
                                ),
                                onTap: () {
                                  setState(() {
                                    selectedDoctorIndex = index;
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: navBar(),
    );
  }

  //nav bar
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
          _buildNavItem(Icons.person, 0),
          _buildNavItem(Icons.calendar_today, 2),
          _buildNavItem(Icons.search, 1),
          _buildImageItem("assets/images/ewan.png", 3),
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
            margin: const EdgeInsets.only(right: 15),
            child: ImageIcon(
              AssetImage("assets/images/ewan.png"),
              size: 60,
              color: isSelected ? Colors.deepOrange : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
