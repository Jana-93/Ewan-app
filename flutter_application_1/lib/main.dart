import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/AddChild.dart';
import 'package:flutter_application_1/screens/ChatScreen.dart';
import 'package:flutter_application_1/screens/HomePage.dart';
import 'package:flutter_application_1/screens/appointmentpage.dart';

import 'screens/Authentication.dart';
import 'package:flutter_application_1/screens/getStarted.dart'; // Import the getStarted screen
import 'package:flutter_application_1/screens/psignup.dart';
import 'package:flutter_application_1/screens/userpage.dart';
import 'screens/TherapistHomePage.dart';
import 'screens/loginScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

// Import the login screen
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    //  Check if Firebase is already initialized before initializing it again
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    print(" Firebase initialized successfully!");
  } catch (e) {
    print(" Firebase initialization failed: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginScreen(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(useMaterial3: true),
      // Move between screens
      // initialRoute: "/",
      // routes: {
      //   "/": (context) => const Getstarted(),
      //   "/login": (context) => LoginScreen(),
      //   "/authin": (context) => Authentication(),
      // },

      // StreamBuilder(
      //     stream: FirebaseAuth.instance.authStateChanges(),
      //     builder: (context, snapshot) {
      //       if (snapshot.connectionState == ConnectionState.waiting) {
      //         return Center(
      //             child: CircularProgressIndicator(
      //           color: Colors.white,
      //         ));

      //       }else if(snapshot.hasError){
      //         return showSnackBar(context,"something want error");
      //       }
      //     }),
    );
  }
}
