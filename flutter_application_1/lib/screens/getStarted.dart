import 'package:flutter/material.dart';

class Getstarted extends StatelessWidget {
  const Getstarted({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            SizedBox(height: 100),
            Center(
              child: Image.asset(
                "assets/images/getStarted_doctor.jpg",
                height: 300,
              ),
            ),
            // SizedBox(
            //   height:100 ,
            // ),
            Text(""),

            Text(
              "تواصل الآن مع الطبيب أونلاين لمساعدة طفلك ",
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, "/login");
              },
              child: Text(
                "ابدأ الآن",
                style: TextStyle(
                  color: const Color.fromARGB(255, 255, 255, 255),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                selectionColor: Colors.purple,
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(
                  Color.fromARGB(255, 246, 137, 47),
                ),
                padding: MaterialStateProperty.all(
                  EdgeInsets.symmetric(horizontal: 90, vertical: 10),
                ),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(70),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
