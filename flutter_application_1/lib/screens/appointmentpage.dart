import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_application_1/screens/HomePage.dart';
import 'package:flutter_application_1/screens/searchpage.dart';
import 'package:flutter_application_1/screens/userpage.dart';
import 'package:firebase_core/firebase_core.dart';

class Appointmentpage extends StatefulWidget {
  const Appointmentpage({super.key});

  @override
  State<Appointmentpage> createState() => _AppointmentpageState();
}

enum FilterStatus { upcoming, complete, canceled }

class _AppointmentpageState extends State<Appointmentpage> {
  FilterStatus status = FilterStatus.upcoming; // Initial state
  int selectedIndex = 2;
  Alignment _alignment = Alignment.centerLeft;

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

  List<dynamic> schedules = [
    {
      "doctorName": "سارة عبدالله",
      "ProfilePicture": "assets/images/doctor.jpg",
      "status": FilterStatus.upcoming,
      "date": "2024-02-18",
      "day": "Sunday",
      "time": "10:00 AM",
    },
    {
      "doctorName": "نورة محمد",
      "ProfilePicture": "assets/images/doctor.jpg",
      "status": FilterStatus.complete,
      "date": "2024-02-18",
      "day": "Sunday",
      "time": "10:00 AM",
    },
    {
      "doctorName": "منى صالح",
      "ProfilePicture": "assets/images/doctor.jpg",
      "status": FilterStatus.canceled,
      "date": "2024-02-18",
      "day": "Sunday",
      "time": "10:00 AM",
    },
  ];

  @override
  Widget build(BuildContext context) {
    List<dynamic> filteredSchedules =
        schedules.where((var schedule) {
          return schedule['status'] == status;
        }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            "مواعيدي",
                            style: TextStyle(color: Colors.white, fontSize: 40),
                            textAlign: TextAlign.right,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
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
                    children: <Widget>[
                      const SizedBox(height: 20),
                      Stack(
                        children: [
                          // Background container for buttons
                          Container(
                            width: double.infinity,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                for (FilterStatus filterStatus
                                    in FilterStatus.values)
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          status = filterStatus;
                                          _alignment =
                                              filterStatus ==
                                                      FilterStatus.upcoming
                                                  ? Alignment.centerLeft
                                                  : filterStatus ==
                                                      FilterStatus.complete
                                                  ? Alignment.center
                                                  : Alignment.centerRight;
                                        });
                                      },
                                      child: Center(
                                        child: Text(
                                          filterStatus == FilterStatus.upcoming
                                              ? "قادمة"
                                              : filterStatus ==
                                                  FilterStatus.complete
                                              ? "مكتملة"
                                              : "ملغاة",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                status == filterStatus
                                                    ? Colors.orange
                                                    : Colors.black,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          // Animated moving highlight
                          AnimatedAlign(
                            alignment: _alignment,
                            duration: const Duration(milliseconds: 200),
                            child: Container(
                              width:
                                  MediaQuery.of(context).size.width /
                                  3.5, // Each tab width
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFCB47A),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Center(
                                child: Text(
                                  status == FilterStatus.upcoming
                                      ? "قادمة"
                                      : status == FilterStatus.complete
                                      ? "مكتملة"
                                      : "ملغاة",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      FadeInUp(
                        duration: const Duration(milliseconds: 1400),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.all(10),
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: filteredSchedules.length,
                                itemBuilder: (context, index) {
                                  var schedule = filteredSchedules[index];

                                  bool isLastElement =
                                      filteredSchedules.length + 1 == index;
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                        255,
                                        255,
                                        255,
                                        255,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 10,
                                          spreadRadius: 5,
                                          offset: Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    margin:
                                        !isLastElement
                                            ? const EdgeInsets.only(bottom: 20)
                                            : EdgeInsets.zero,
                                    child: Padding(
                                      padding: const EdgeInsets.all(15),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Row(
                                            children: [
                                              CircleAvatar(
                                                backgroundImage: AssetImage(
                                                  schedule['ProfilePicture'],
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    schedule['doctorName'],
                                                    style: const TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Text(
                                                    schedule['category'] ?? '',
                                                    style: const TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 15),
                                          ScheduleCard(
                                            date: schedule['date'] ?? '',
                                            day: schedule['day'] ?? '',
                                            time: schedule['time'] ?? '',
                                          ),
                                          const SizedBox(height: 15),

                                          // Show buttons only if the status is "Upcoming"
                                          if (schedule['status'] ==
                                              FilterStatus.upcoming)
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: OutlinedButton(
                                                    style:
                                                        OutlinedButton.styleFrom(
                                                          side: const BorderSide(
                                                            color:
                                                                Color.fromARGB(
                                                                  255,
                                                                  223,
                                                                  222,
                                                                  222,
                                                                ),
                                                            width: 2,
                                                          ), // Border color
                                                        ),
                                                    onPressed: () {},
                                                    child: const Text(
                                                      'إلغاء',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.orange,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 20),
                                                Expanded(
                                                  child: OutlinedButton(
                                                    style:
                                                        OutlinedButton.styleFrom(
                                                          backgroundColor:
                                                              Colors.orange,
                                                          side: const BorderSide(
                                                            color:
                                                                Color.fromARGB(
                                                                  255,
                                                                  222,
                                                                  221,
                                                                  221,
                                                                ),
                                                            width: 2,
                                                          ), // Border color
                                                        ),
                                                    onPressed: () {},
                                                    child: const Text(
                                                      'تغيير الموعد',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
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

class ScheduleCard extends StatelessWidget {
  const ScheduleCard({
    Key? key,
    required this.date,
    required this.day,
    required this.time,
  }) : super(key: key);
  final String date;
  final String day;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 238, 235, 235),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 5,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: [
              const Icon(Icons.calendar_today, color: Colors.orange, size: 16),
              const SizedBox(width: 5),
              Text(
                day.isNotEmpty ? day : '18/2/2025',
                style: const TextStyle(color: Colors.orange, fontSize: 14),
              ),
            ],
          ),
          Row(
            children: [
              const Icon(Icons.access_time, color: Colors.orange, size: 16),
              const SizedBox(width: 5),
              Text(
                time.isNotEmpty ? time : '11:00 AM',
                style: const TextStyle(color: Colors.orange, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
