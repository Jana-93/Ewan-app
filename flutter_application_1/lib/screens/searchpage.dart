import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
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

  @override
  void initState() {
    super.initState();
    _fetchTherapists();
    _fetchCurrentUserParentId().then((parentId) {
      if (parentId != null) {
        _fetchChildren(parentId);
      }
    });
  }

  Future<void> _fetchTherapists() async {
    try {
      List<Map<String, dynamic>> fetchedTherapists =
          await _firestoreService.getTherapists();
      setState(() {
        therapists = fetchedTherapists;
        filteredTherapists = fetchedTherapists;
      });
    } catch (e) {
      print("Error fetching therapists: $e");
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("حدث خطأ أثناء جلب المعالجين")));
    }
  }

  Future<void> _fetchChildren(String parentId) async {
    try {
      List<Map<String, dynamic>> fetchedChildren =
          await _firestoreService.getChildrenByParentId(parentId);
      print("Fetched Children: $fetchedChildren");
      setState(() {
        children = fetchedChildren;
      });
    } catch (e) {
      print("Error fetching children: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("حدث خطأ أثناء جلب الأطفال")));
    }
  }

  Future<String?> _fetchCurrentUserParentId() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        return user.uid;
      }
    } catch (e) {
      print("Error fetching current user parent ID: $e");
    }
    return null;
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

  void _filterTherapists(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredTherapists = therapists;
      } else {
        filteredTherapists = therapists.where((therapist) {
          final name = '${therapist["firstName"] ?? ""} ${therapist["lastName"] ?? ""}'.toLowerCase();
          final specialty = therapist["specialty"]?.toLowerCase() ?? "";
          final bio = therapist["bio"]?.toLowerCase() ?? "";
          return name.contains(query.toLowerCase()) || 
                 specialty.contains(query.toLowerCase()) ||
                 bio.contains(query.toLowerCase());
        }).toList();
      }
    });
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
              firstDay: DateTime.now(),
              lastDay: DateTime.utc(2030, 3, 14),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                if (!selectedDay.isBefore(DateTime.now().subtract(Duration(days: 1)))) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                  Navigator.pop(context, selectedDay);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("لا يمكن اختيار تاريخ منقضي")),
                  );
                }
              },
              enabledDayPredicate: (day) {
                return !day.isBefore(DateTime.now().subtract(Duration(days: 1)));
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
                disabledTextStyle: TextStyle(color: Colors.grey),
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

      await _launchPaymentUrl();
    }
  }

  Future<void> _launchPaymentUrl() async {
    const url = "https://buy.stripe.com/test_8wMeYogGXfwq1occMO";

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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("تعذر فتح رابط الدفع")));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
            SizedBox(height: 40.h),
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
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.r),
                    topRight: Radius.circular(30.r),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(30.w),
                  child: Column(
                    children: [
                      TextField(
                        onChanged: _filterTherapists,
                        decoration: InputDecoration(
                          hintText: "ابحث عن الطبيب بالاسم أو التخصص ",
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                      ),
                      SizedBox(height: 10.h),
                      if (searchQuery.isNotEmpty && filteredTherapists.isEmpty)
                        Padding(
                          padding: EdgeInsets.all(16.w),
                          child: Text(
                            "لا توجد نتائج مطابقة للبحث",
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      Expanded(
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
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 35.0,
                                  horizontal: 16.0,
                                ),
                                trailing: CircleAvatar(
                                  backgroundImage:
                                      filteredTherapists[index]["profileImage"] != null
                                          ? NetworkImage(
                                              filteredTherapists[index]["profileImage"],
                                            )
                                          : AssetImage(
                                              "path_to_default_image.jpg",
                                            ) as ImageProvider,
                                ),
                                title: Text(
                                  "${filteredTherapists[index]["firstName"] ?? ""} ${filteredTherapists[index]["lastName"] ?? ""}",
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.orange
                                        : Colors.black,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    fontSize: 16.sp,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                                subtitle: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.end,
                                  children: [
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: IntrinsicWidth(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 4.0,
                                            horizontal: 10.0,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color.fromARGB(
                                              255,
                                              255,
                                              172,
                                              104,
                                            ),
                                            border: Border.all(
                                              color: Colors.orange,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              50,
                                            ),
                                          ),
                                          child: Text(
                                            filteredTherapists[index]["specialty"] ??
                                                "لا يوجد تخصص",
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                    Text(
                                      filteredTherapists[index]["bio"] ??
                                          "empty",
                                      style: TextStyle(
                                        color: const Color.fromARGB(
                                          255,
                                          66,
                                          66,
                                          66,
                                        ),
                                        fontSize: 20.sp,
                                      ),
                                      textAlign: TextAlign.right,
                                    ),
                                    SizedBox(height: 12.0),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          filteredTherapists[index]["experience"] ??
                                              "Experience Unavailable",
                                          style: TextStyle(
                                            color: isSelected
                                                ? Colors.orange
                                                : Colors.green,
                                            fontSize: 16.sp,
                                          ),
                                        ),
                                        SizedBox(width: 8.w),
                                        Icon(
                                          Icons.star,
                                          color: Colors.orange,
                                          size: 20.sp,
                                        ),
                                        SizedBox(width: 4.w),
                                        Text(
                                          "${filteredTherapists[index]["averageRating"]?.toStringAsFixed(2) ?? "0.00"}",
                                          style: TextStyle(
                                            color: Colors.orange,
                                            fontSize: 16.sp,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                onTap: () async {
                                  try {
                                    setState(() {
                                      selectedTherapistIndex = index;
                                    });
                                    await _fetchCurrentUserParentId();
                                  } catch (e) {
                                    print("Error selecting therapist: $e");
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "حدث خطأ أثناء اختيار المعالج",
                                        ),
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
                                  color: isSelected
                                      ? Colors.orange.withOpacity(0.2)
                                      : Color.fromARGB(255, 250, 165, 95),
                                  child: ListTile(
                                    title: Text(
                                      "${children[index]["childName"] ?? "No Name"}",
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.orange
                                            : Colors.white,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        fontSize: 16.sp,
                                      ),
                                    ),
                                    onTap: () {
                                      setState(() {
                                        selectedChildIndex = index;
                                      });
                                      WidgetsBinding.instance
                                          .addPostFrameCallback((_) {
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
            Image.asset("assets/images/s1.jpg", width: 100.w, height: 100.h),
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