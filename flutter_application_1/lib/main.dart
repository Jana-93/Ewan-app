import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/AddChild.dart';
import 'package:flutter_application_1/screens/ChatScreen.dart';
import 'package:flutter_application_1/screens/HomePage.dart';
import 'package:flutter_application_1/screens/Stripe_payment/strip_keys.dart';
import 'package:flutter_application_1/screens/appointmentpage.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import 'screens/Authentication.dart';
import 'package:flutter_application_1/screens/getStarted.dart'; // Import the getStarted screen
import 'package:flutter_application_1/screens/psignup.dart';
import 'package:flutter_application_1/screens/userpage.dart';
import 'screens/TherapistHomePage.dart';
import 'screens/loginScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Import the login screen
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  Stripe.publishableKey =
      "pk_test_51QtSxo2f7zIkZUDJgmIQZKjWfAlipphU1N0sulqz0lqgpPIdkIEpAeFKBCu31jJZMpnq9M9KOsQmTDz3lSvxSbbT00aQMVj7jT"; // أدخل مفتاح النشر الصحيح هنا

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
