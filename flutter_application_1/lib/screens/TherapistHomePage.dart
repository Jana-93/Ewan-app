import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/feedbackScreen.dart';
import 'package:flutter_application_1/screens/Tappointment.dart';
import 'package:flutter_application_1/screens/user_info_page_t.dart';

class TherapistHomePage extends StatefulWidget {
  @override
  _TherapistHomePageState createState() => _TherapistHomePageState();
}

class _TherapistHomePageState extends State<TherapistHomePage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
 
}


void main() {
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: TherapistHomePage()));
}