import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_application_1/screens/HomePage.dart';
import 'package:flutter_application_1/screens/searchpage.dart';
import 'package:flutter_application_1/screens/userpage.dart';
import 'package:flutter_application_1/firestore_service.dart';
import 'package:intl/intl.dart'; // Import the intl package for date formatting

class Appointmentpage extends StatefulWidget {
  const Appointmentpage({super.key});

  @override
  State<Appointmentpage> createState() => _AppointmentpageState();
}

class _AppointmentpageState extends State<Appointmentpage> {
  int selectedIndex = 2;
  final FirestoreService _firestoreService = FirestoreService();

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
                      // Use StreamBuilder to fetch appointments from Firestore
                      StreamBuilder<List<Map<String, dynamic>>>(
                        stream: _firestoreService.getAppointments(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          }
                          if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          }
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return Text('No upcoming appointments available.');
                          }

                          List<dynamic> upcomingSchedules =
                              snapshot.data!
                                  .where(
                                    (schedule) =>
                                        schedule['status'] == 'upcoming',
                                  )
                                  .toList();

                          return FadeInUp(
                            duration: const Duration(milliseconds: 1400),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: upcomingSchedules.length,
                                    itemBuilder: (context, index) {
                                      var schedule = upcomingSchedules[index];
                                      bool isLastElement =
                                          index == upcomingSchedules.length - 1;
                                      return AppointmentCard(
                                        key: ValueKey(
                                          schedule['date'],
                                        ), // Ensure unique key
                                        schedule: schedule,
                                        isLastElement: isLastElement,
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
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

class AppointmentCard extends StatefulWidget {
  final Map<String, dynamic> schedule;
  final bool isLastElement;

  const AppointmentCard({
    Key? key,
    required this.schedule,
    required this.isLastElement,
  }) : super(key: key);

  @override
  _AppointmentCardState createState() => _AppointmentCardState();
}

class _AppointmentCardState extends State<AppointmentCard> {
  final FirestoreService _firestoreService = FirestoreService();
  late Future<Map<String, dynamic>> _therapistDataFuture;

  @override
  void initState() {
    super.initState();
    String uid = widget.schedule['therapistUid'] ?? '';
    _therapistDataFuture = _firestoreService.getTherapistData(uid);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _therapistDataFuture,
      builder: (context, therapistSnapshot) {
        if (therapistSnapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        if (therapistSnapshot.hasError) {
          return Text('Error: ${therapistSnapshot.error}');
        }
        if (!therapistSnapshot.hasData) {
          return Text('Therapist not found.');
        }

        Map<String, dynamic> therapistData = therapistSnapshot.data!;

        return Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 255, 255, 255),
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
              !widget.isLastElement
                  ? const EdgeInsets.only(bottom: 20)
                  : EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage:
                          therapistData['profileImage'] != null
                              ? NetworkImage(therapistData['profileImage'])
                              : AssetImage("assets/images/icon.jpg"),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${therapistData['firstName'] ?? 'Unknown'} ${therapistData['lastName'] ?? ''}",
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          therapistData['specialty'] ??
                              "No Specialty Information",
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                ScheduleCard(
                  date: widget.schedule['date'] ?? '',
                  time: widget.schedule['time'] ?? '',
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          side: const BorderSide(
                            color: Color.fromARGB(255, 222, 221, 221),
                            width: 2,
                          ),
                        ),
                        onPressed: () {
                          // Implement start session logic
                        },
                        child: const Text(
                          'بدء الجلسة',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Color.fromARGB(255, 223, 222, 222),
                            width: 2,
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Searchpage(),
                            ),
                          );
                        },
                        child: const Text(
                          'تغيير الموعد',
                          style: TextStyle(fontSize: 16, color: Colors.orange),
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
    );
  }
}

class ScheduleCard extends StatelessWidget {
  final String date;
  final String time;

  const ScheduleCard({Key? key, required this.date, required this.time})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Check if the date string is not null or empty
    if (date.isNotEmpty) {
      // Parse the date string into a DateTime object
      DateTime parsedDate = DateTime.parse(date);

      // Format the date into the desired display format
      String formattedDate = DateFormat('dd/MM/yyyy').format(parsedDate);

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
                const Icon(
                  Icons.calendar_today,
                  color: Colors.orange,
                  size: 16,
                ),
                const SizedBox(width: 5),
                Text(
                  formattedDate,
                  style: const TextStyle(color: Colors.orange, fontSize: 14),
                ),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.access_time, color: Colors.orange, size: 16),
                const SizedBox(width: 5),
                Text(
                  time.isNotEmpty ? time : '10:00 صباحًا',
                  style: const TextStyle(color: Colors.orange, fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      return Container();
    }
  }
}
