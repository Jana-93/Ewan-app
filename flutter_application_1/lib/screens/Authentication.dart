import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/HomePage.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class Authentication extends StatefulWidget {
  @override
  _AuthenticationState createState() => _AuthenticationState();
}

class _AuthenticationState extends State<Authentication> {
  TextEditingController otpController = TextEditingController();
  String currentText = "";
  int _secondsRemaining = 30;
  bool _canResend = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    _secondsRemaining = 30;
    _canResend = false;
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        setState(() {
          _canResend = true;
          timer.cancel();
        });
      }
    });
  }

  void resendCode() {
    if (_canResend) {
      print("تم إرسال الرمز من جديد");
      startTimer();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("تم إرسال رمز التحقق ")));
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "أدخل رمز التحقق ",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            PinCodeTextField(
              appContext: context,
              length: 4,
              controller: otpController,
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  currentText = value;
                });
              },
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular(8),
                fieldHeight: 50,
                fieldWidth: 50,
                activeFillColor: const Color.fromARGB(255, 255, 255, 255),
                inactiveFillColor: const Color.fromARGB(255, 255, 255, 255)!,
                selectedFillColor: const Color.fromARGB(255, 255, 255, 255)!,
                activeColor: Colors.orange,
                inactiveColor: Colors.grey[200],
                selectedColor: Colors.orange,
              ),
              enableActiveFill: true,
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Homepage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: EdgeInsets.symmetric(vertical: 13, horizontal: 80),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  // side: BorderSide(
                  //   color:Colors.orange[300],
                  //   width: 2,
                  // ),
                ),
              ).copyWith(
                overlayColor: MaterialStateProperty.resolveWith<Color>((
                  Set<MaterialState> states,
                ) {
                  if (states.contains(MaterialState.pressed)) {
                    return Colors.orangeAccent;
                  }
                  return const Color.fromARGB(255, 254, 254, 254);
                }),
              ),
              child: Text(
                "تحقق",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              _canResend
                  ? "لم يصلك الرمز؟"
                  : "انتظر $_secondsRemaining ثانية لإعادة الإرسال",
              style: TextStyle(
                fontSize: 13,
                color: const Color.fromARGB(255, 83, 160, 249),
              ),
            ),
            TextButton(
              onPressed: _canResend ? resendCode : null,
              child: Text(
                "إعادة إرسال الرمز",
                style: TextStyle(
                  color:
                      _canResend
                          ? const Color.fromARGB(255, 247, 148, 0)
                          : const Color.fromARGB(255, 182, 183, 184),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
