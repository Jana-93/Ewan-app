import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/PaymentPage.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_application_1/screens/HomePage.dart';
import 'package:flutter_application_1/screens/userpage.dart';
import 'package:flutter_application_1/screens/appointmentpage.dart';
import 'package:flutter_application_1/firestore_service.dart';
import 'package:animate_do/animate_do.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Searchpage extends StatefulWidget {
  @override
  _SearchpageState createState() => _SearchpageState();
}

class _SearchpageState extends State<Searchpage> {
  final FirestoreService _firestoreService = FirestoreService();
  int selectedIndex = 1;
  int selectedTherapistIndex = -1;
  int selectedChildIndex = -1;
  String searchQuery = "";
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String? selectedTime;

  List<Map<String, dynamic>> therapists = [];
  List<Map<String, dynamic>> children = [];

  @override
  void initState() {
    super.initState();
    _fetchTherapists();
    _fetchChildren();
  }

  Future<void> _fetchTherapists() async {
    try {
      List<Map<String, dynamic>> fetchedTherapists =
          await _firestoreService.getTherapists();
      setState(() {
        therapists = fetchedTherapists;
      });
    } catch (e) {
      print("Error fetching therapists: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("حدث خطأ أثناء جلب المعالجين"),
        ),
      );
    }
  }

  Future<void> _fetchChildren() async {
    try {
      List<Map<String, dynamic>> fetchedChildren =
          await _firestoreService.getchildren();
      print("Fetched Children: $fetchedChildren");
      setState(() {
        children = fetchedChildren;
      });
    } catch (e) {
      print("Error fetching children: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("حدث خطأ أثناء جلب الأطفال"),
        ),
      );
    }
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

  Future<void> _selectTime(BuildContext context) async {
    final String? selected = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TimeSelectionPage(),
      ),
    );

    if (selected != null) {
      setState(() {
        selectedTime = selected;
      });
      _navigateToPaymentPage();
    }
  }

  void _navigateToPaymentPage() async {
    if (_selectedDay == null || selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("يرجى تحديد التاريخ والوقت"),
        ),
      );
      return;
    }

    String uid = FirebaseAuth.instance.currentUser!.uid;
    String therapistUid = therapists[selectedTherapistIndex]["uid"] ?? "unknown";
    String therapistName = "${therapists[selectedTherapistIndex]["firstName"] ?? ""} ${therapists[selectedTherapistIndex]["lastName"] ?? ""}";
    String childName = "${children[selectedChildIndex]["childName"] ?? "No Name"}";

    final appointmentData = {
      "userId": uid,
      "therapistUid": therapistUid,
      "therapistName": therapistName,
      "childName": childName,
      "date": "${_selectedDay!.year}-${_selectedDay!.month.toString().padLeft(2, '0')}-${_selectedDay!.day.toString().padLeft(2, '0')}",
      "time": selectedTime,
      "price": therapists[selectedTherapistIndex]["price"] ?? "0",
      "status": "upcoming",
    };

    try {
      await _firestoreService.addAppointment(appointmentData);
      print("Appointment added successfully");

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentPage(
            amount: int.tryParse(therapists[selectedTherapistIndex]["price"]?.replaceAll("ريال", "").trim() ?? "0") ?? 0,
            currency: "SAR",
            appointmentData: appointmentData,
            onPaymentSuccess: () {
              _firestoreService.addAppointment(appointmentData);
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
            SizedBox(height: 60.h),
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  FadeInUp(
                    duration: const Duration(milliseconds: 1000),
                    child: Text(
                      "الأطباء",
                      style: TextStyle(color: Colors.white, fontSize: 40.sp),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50.r),
                    topRight: Radius.circular(50.r),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(30.w),
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
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Expanded(
                        child: ListView.builder(
                          itemCount: therapists.length,
                          itemBuilder: (context, index) {
                            bool isSelected = selectedTherapistIndex == index;
                            return Card(
                              margin: EdgeInsets.symmetric(vertical: 8.h),
                              color: isSelected ? Colors.orange.withOpacity(0.2) : Colors.white,
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: therapists[index]["profileImage"] != null
                                      ? NetworkImage(therapists[index]["profileImage"])
                                      : AssetImage("path_to_default_image.jpg"),
                                ),
                                title: Text(
                                  "${therapists[index]["firstName"] ?? ""} ${therapists[index]["lastName"] ?? ""}",
                                  style: TextStyle(
                                    color: isSelected ? Colors.orange : Colors.black,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    fontSize: 16.sp,
                                  ),
                                ),
                                subtitle: Text(
                                  therapists[index]["specialty"] ?? "No Specialty Information",
                                  style: TextStyle(
                                    color: isSelected ? Colors.orange : Colors.grey,
                                    fontSize: 14.sp,
                                  ),
                                ),
                                trailing: Text(
                                  therapists[index]["experience"] ?? "Experience Unavailable",
                                  style: TextStyle(
                                    color: isSelected ? Colors.orange : Colors.green,
                                    fontSize: 14.sp,
                                  ),
                                ),
                                onTap: () async {
                                  try {
                                    setState(() {
                                      selectedTherapistIndex = index;
                                    });
                                    await _fetchChildren();
                                  } catch (e) {
                                    print("Error fetching children: $e");
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("حدث خطأ أثناء جلب الأطفال"),
                                      ),
                                    );
                                  }
                                },
                              ),
                            );
                          },
                        ),
                      ),
                      if (selectedTherapistIndex != -1) ...[
                        SizedBox(height: 20.h),
                        Text(
                          "الأطفال المتاحين",
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        if (children.isNotEmpty)
                          Expanded(
                            child: ListView.builder(
                              itemCount: children.length,
                              itemBuilder: (context, index) {
                                bool isSelected = selectedChildIndex == index;
                                return Card(
                                  margin: EdgeInsets.symmetric(vertical: 8.h),
                                  color: isSelected ? Colors.orange.withOpacity(0.2) : Colors.orange,
                                  child: ListTile(
                                    title: Text(
                                      "${children[index]["childName"] ?? "No Name"}",
                                      style: TextStyle(
                                        color: isSelected ? Colors.orange : Colors.black,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                        fontSize: 16.sp,
                                      ),
                                    ),
                                    onTap: () {
                                      setState(() {
                                        selectedChildIndex = index;
                                      });
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        if (children.isEmpty)
                          Padding(
                            padding: EdgeInsets.all(16.w),
                            child: Text(
                              "لا يوجد أطفال متاحين",
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        if (selectedChildIndex != -1) ...[
                          SizedBox(height: 20.h),
                          TableCalendar(
                            firstDay: DateTime.utc(2010, 10, 16),
                            lastDay: DateTime.utc(2030, 3, 14),
                            focusedDay: _focusedDay,
                            calendarFormat: _calendarFormat,
                            selectedDayPredicate: (day) {
                              return isSameDay(_selectedDay, day);
                            },
                            onDaySelected: (selectedDay, focusedDay) async {
                              setState(() {
                                _selectedDay = selectedDay;
                                _focusedDay = focusedDay;
                              });
                              await _selectTime(context);
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
                                fontSize: 18.sp,
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
                          if (selectedTime != null) ...[
                            SizedBox(height: 20.h),
                            Text(
                              "الوقت المحدد: $selectedTime",
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ],
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
      height: 60.h,
      width: double.infinity,
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
            margin: EdgeInsets.only(
              top: 15.h,
              bottom: 0,
              left: 30.w,
              right: 30.w,
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
            margin: EdgeInsets.only(right: 15.w),
            child: ImageIcon(
              AssetImage(imagePath),
              size: 60.sp,
              color: isSelected ? Colors.deepOrange : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class TimeSelectionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("اختر الوقت"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: List.generate(10, (index) {
            String time = "${8 + index}:00 صباحًا";
            return ChoiceChip(
              label: Text(time),
              selected: false,
              onSelected: (selected) {
                Navigator.pop(context, time);
              },
              selectedColor: Colors.deepOrange,
              labelStyle: TextStyle(
                color: Colors.black,
              ),
            );
          }),
        ),
      ),
    );
  }
}