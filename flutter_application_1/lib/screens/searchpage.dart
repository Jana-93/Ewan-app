import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/PaymentPage.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_application_1/screens/HomePage.dart';
import 'package:flutter_application_1/screens/userpage.dart';
import 'package:flutter_application_1/screens/appointmentpage.dart';
import 'package:flutter_application_1/firestore_service.dart';
import 'package:animate_do/animate_do.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart'; // Import the uuid package

class Searchpage extends StatefulWidget {
  @override
  _SearchpageState createState() => _SearchpageState();
}

class _SearchpageState extends State<Searchpage> {
  final FirestoreService _firestoreService = FirestoreService();
  int selectedIndex = 1;
  int selectedTherapistIndex = -1;
  String searchQuery = "";
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  List<Map<String, dynamic>> therapists = [];

  @override
  void initState() {
    super.initState();
    _fetchTherapists();
  }

  Future<void> _fetchTherapists() async {
    List<Map<String, dynamic>> fetchedTherapists =
        await _firestoreService.getTherapists();
    setState(() {
      therapists = fetchedTherapists;
    });
  }

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
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
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
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            const SizedBox(height: 60),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  FadeInUp(
                    duration: const Duration(milliseconds: 1000),
                    child: const Text(
                      "الأطباء",
                      style: TextStyle(color: Colors.white, fontSize: 40),
                      textAlign: TextAlign.right,
                    ),
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
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
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
                          itemCount: therapists.length,
                          itemBuilder: (context, index) {
                            bool isSelected = selectedTherapistIndex == index;
                            return Card(
                              margin: EdgeInsets.symmetric(vertical: 8),
                              color:
                                  isSelected
                                      ? Colors.orange.withOpacity(0.2)
                                      : Colors.white,
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundImage:
                                      therapists[index]["profileImage"] != null
                                          ? NetworkImage(
                                            therapists[index]["profileImage"],
                                          )
                                          : AssetImage(
                                            "path_to_default_image.jpg",
                                          ), // Provide a default image
                                ),
                                title: Text(
                                  "${therapists[index]["firstName"] ?? ""} ${therapists[index]["lastName"] ?? ""}",
                                  style: TextStyle(
                                    color:
                                        isSelected
                                            ? Colors.orange
                                            : Colors.black,
                                    fontWeight:
                                        isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                  ),
                                ),
                                subtitle: Text(
                                  therapists[index]["specialty"] ??
                                      "No Specialty Information",
                                  style: TextStyle(
                                    color:
                                        isSelected
                                            ? Colors.orange
                                            : Colors.grey,
                                  ),
                                ),
                                trailing: Text(
                                  therapists[index]["experience"] ??
                                      "Experience Unavailable",
                                  style: TextStyle(
                                    color:
                                        isSelected
                                            ? Colors.orange
                                            : Colors.green,
                                  ),
                                ),
                                onTap: () {
                                  setState(() {
                                    selectedTherapistIndex = index;
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      ),
                      if (selectedTherapistIndex != -1) ...[
                        const SizedBox(height: 20),
                        TableCalendar(
                          firstDay: DateTime.utc(2010, 10, 16),
                          lastDay: DateTime.utc(2030, 3, 14),
                          focusedDay: _focusedDay,
                          calendarFormat: _calendarFormat,
                          selectedDayPredicate: (day) {
                            return isSameDay(_selectedDay, day);
                          },
                          onDaySelected: (selectedDay, focusedDay) {
                            setState(() {
                              _selectedDay = selectedDay;
                              _focusedDay = focusedDay;
                            });
                          },
                          onFormatChanged: (format) {
                            setState(() {
                              _calendarFormat = format;
                            });
                          },
                          onPageChanged: (focusedDay) {
                            _focusedDay = focusedDay;
                          },
                          calendarStyle: CalendarStyle(
                            todayDecoration: BoxDecoration(
                              color: Colors.orange,
                              shape: BoxShape.circle,
                            ),
                            selectedDecoration: BoxDecoration(
                              color: Colors.deepOrange,
                              shape: BoxShape.circle,
                            ),
                            weekendTextStyle: TextStyle(color: Colors.red),
                            defaultTextStyle: TextStyle(color: Colors.black),
                          ),
                          headerStyle: HeaderStyle(
                            formatButtonVisible: false,
                            titleTextStyle: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            leftChevronIcon: Icon(
                              Icons.chevron_left,
                              color: Colors.deepOrange,
                            ),
                            rightChevronIcon: Icon(
                              Icons.chevron_right,
                              color: Colors.deepOrange,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                if (_selectedDay == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("يرجى تحديد تاريخ الحجز"),
                                    ),
                                  );
                                  return;
                                }

                                String uid =
                                    FirebaseAuth.instance.currentUser!.uid;
                                String therapistUid =
                                    therapists[selectedTherapistIndex]["uid"] ??
                                    "unknown";
                                String therapistName =
                                    "${therapists[selectedTherapistIndex]["firstName"] ?? ""} ${therapists[selectedTherapistIndex]["lastName"] ?? ""}";

                                final appointmentData = {
                                  "userId": uid,
                                  "therapistUid":
                                      therapistUid, // Ensure this matches the field name in Firebase
                                  "therapistName": therapistName,
                                  "date":
                                      "${_selectedDay!.year}-${_selectedDay!.month.toString().padLeft(2, '0')}-${_selectedDay!.day.toString().padLeft(2, '0')}",
                                  "time": "10:00 صباحًا",
                                  "price":
                                      therapists[selectedTherapistIndex]["price"] ??
                                      "0",
                                  "status": "upcoming",
                                };

                                try {
                                  await _firestoreService.addAppointment(
                                    appointmentData,
                                  );
                                  print("Appointment added successfully");

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => PaymentPage(
                                            amount:
                                                int.tryParse(
                                                  therapists[selectedTherapistIndex]["price"]
                                                          ?.replaceAll(
                                                            "ريال",
                                                            "",
                                                          )
                                                          .trim() ??
                                                      "0",
                                                ) ??
                                                0,
                                            currency: "SAR",
                                            appointmentData: appointmentData,
                                            onPaymentSuccess: () {
                                              _firestoreService.addAppointment(
                                                appointmentData,
                                              );
                                            },
                                          ),
                                    ),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("حدث خطأ أثناء حجز الموعد"),
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepOrange,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                "التالي",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ],
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
              AssetImage(imagePath),
              size: 60,
              color: isSelected ? Colors.deepOrange : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
