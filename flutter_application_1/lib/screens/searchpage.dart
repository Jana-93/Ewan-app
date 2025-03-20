import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/ConfirmationPage.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_application_1/screens/HomePage.dart';
import 'package:flutter_application_1/screens/userpage.dart';
import 'package:flutter_application_1/screens/appointmentpage.dart';
import 'package:flutter_application_1/firestore_service.dart';
import 'package:animate_do/animate_do.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';

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
  List<Map<String, dynamic>> filteredTherapists = [];
  List<Map<String, dynamic>> children = [];

  
  List<String> specialties = ["الكل", "علاج نفسي", "علاج سلوكي", "علاج معرفي"];
  String selectedSpecialty = "الكل";

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
        filteredTherapists = therapists;
      });
    } catch (e) {
      print("Error fetching therapists: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("حدث خطأ أثناء جلب المعالجين")),
      );
    }
  }

  Future<void> _fetchChildren() async {
    try {
      List<Map<String, dynamic>> fetchedChildren =
          await _firestoreService.getChildrenForCurrentUser();
      print("Fetched Children: $fetchedChildren");
      setState(() {
        children = fetchedChildren;
      });
    } catch (e) {
      print("Error fetching children: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("حدث خطأ أثناء جلب الأطفال")),
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? selected = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("اختر التاريخ"),
          content: Container(
            width: double.maxFinite,
            child: TableCalendar(
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
                Navigator.pop(context, selectedDay);
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
          ),
        );
      },
    );

    if (selected != null) {
      setState(() {
        _selectedDay = selected;
      });
      await _selectTime(context);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final String? selected = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TimeSelectionPage()),
    );

    if (selected != null) {
      setState(() {
        selectedTime = selected;
      });

      // افتح رابط الدفع Stripe في متصفح خارجي
      await _launchPaymentUrl();
    }
  }

  Future<void> _launchPaymentUrl() async {
    const url = "https://buy.stripe.com/test_8wMeYogGXfwq1occMO"; // رابط الدفع

    try {
      
      await FlutterWebBrowser.openWebPage(
        url: url,
        customTabsOptions: CustomTabsOptions(
          colorScheme: CustomTabsColorScheme.dark,
          toolbarColor: Colors.deepOrange,
          secondaryToolbarColor: Colors.black,
          navigationBarColor: Colors.black,
          addDefaultShareMenuItem: true,
          instantAppsEnabled: true,
          showTitle: true,
          urlBarHidingEnabled: true,
        ),
      );

      await Future.delayed(Duration(seconds: 10));

      await FlutterWebBrowser.close();

      _navigateToConfirmationPage(context);
    } catch (e) {
      print("Error launching payment URL: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("تعذر فتح رابط الدفع")),
      );
    }
  }

  void _navigateToConfirmationPage(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ConfirmationPage(
          therapists: therapists,
          selectedTherapistIndex: selectedTherapistIndex,
          children: children,
          selectedChildIndex: selectedChildIndex,
          selectedDay: _selectedDay!,
          selectedTime: selectedTime!,
          firestoreService: _firestoreService,
        ),
      ),
    );
  }

  void _filterTherapists() {
    if (selectedSpecialty == "الكل") {
      setState(() {
        filteredTherapists = therapists;
      });
    } else {
      setState(() {
        filteredTherapists = therapists
            .where((therapist) => therapist["specialty"] == selectedSpecialty)
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              colors: [
                Color.fromARGB(255, 219, 101, 37),
                Color.fromRGBO(239, 108, 0, 1),
                Color.fromRGBO(255, 167, 38, 1),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              SizedBox(height: 60.h),
              Padding(
                padding: EdgeInsets.all(10.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    FadeInUp(
                      duration: Duration(milliseconds: 1000),
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
              Container(
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
                      SizedBox(height: 10.h),
                      
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: specialties.map((specialty) {
                            return Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4.w),
                              child: ChoiceChip(
                                label: Text(specialty),
                                selected: selectedSpecialty == specialty,
                                onSelected: (selected) {
                                  setState(() {
                                    selectedSpecialty = specialty;
                                    _filterTherapists();
                                  });
                                },
                                selectedColor: Colors.orange,
                                labelStyle: TextStyle(color: Colors.deepOrange),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Container(
                        height: 400.h,
                        child: ListView.builder(
                          itemCount: filteredTherapists.length,
                          itemBuilder: (context, index) {
                            bool isSelected = selectedTherapistIndex == index;
                            return Card(
                              margin: EdgeInsets.symmetric(vertical: 8.h),
                              color: isSelected
                                  ? Colors.orange.withOpacity(0.2)
                                  : Colors.white,
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundImage:
                                      filteredTherapists[index]["profileImage"] != null
                                          ? NetworkImage(
                                              filteredTherapists[index]["profileImage"],
                                            )
                                          : AssetImage(
                                              "path_to_default_image.jpg",
                                            ),
                                ),
                                title: Text(
                                  "${filteredTherapists[index]["firstName"] ?? ""} ${filteredTherapists[index]["lastName"] ?? ""}",
                                  style: TextStyle(
                                    color: isSelected ? Colors.orange : Colors.black,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    fontSize: 16.sp,
                                  ),
                                ),
                                subtitle: Text(
                                  filteredTherapists[index]["specialty"] ??
                                      "No Specialty Information",
                                  style: TextStyle(
                                    color: isSelected ? Colors.orange : Colors.grey,
                                    fontSize: 14.sp,
                                  ),
                                ),
                                trailing: Text(
                                  filteredTherapists[index]["experience"] ??
                                      "Experience Unavailable",
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
                          Container(
                            height: 200.h,
                            child: ListView.builder(
                              itemCount: children.length,
                              itemBuilder: (context, index) {
                                bool isSelected = selectedChildIndex == index;
                                return Card(
                                  margin: EdgeInsets.symmetric(vertical: 8.h),
                                  color: isSelected
                                      ? Colors.orange.withOpacity(0.2)
                                      : Colors.orange,
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
                                      WidgetsBinding.instance.addPostFrameCallback((_) {
                                        _selectDate(context);
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
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
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
            offset: Offset(0, 5),
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
        title: Text("اختر الوقت", style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromRGBO(239, 108, 0, 1),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(45.w),
        child: Column(
          children: [
            Image.asset(
              "assets/images/s1.jpg",
              width: 100.w,
              height: 100.h,
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.error, color: Colors.red);
              },
            ),
            SizedBox(height: 20.h),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: List.generate(10, (index) {
                String time;
                if (index < 4) {
                  time = "${8 + index}:00 صباحًا";
                } else {
                  time = "${index - 4 + 12}:00 مساءً";
                }
                return ChoiceChip(
                  label: Text(time),
                  selected: false,
                  onSelected: (selected) {
                    Navigator.pop(context, time);
                  },
                  selectedColor: Colors.orange,
                  labelStyle: TextStyle(color: Colors.deepOrange),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}