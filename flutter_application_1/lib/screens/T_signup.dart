import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // إضافة استيراد FirebaseAuth
import 'dart:io';

class TherapistSignUpPage extends StatefulWidget {
  @override
  _TherapistSignUpPageState createState() => _TherapistSignUpPageState();
}

class _TherapistSignUpPageState extends State<TherapistSignUpPage> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  String? selectedSpecialty;
  String? selectedExperience;
  File? profileImage;
  File? qualificationFile;
  File? licenseFile;
  final picker = ImagePicker();

  final List<String> specialties = ['علاج سلوكي', 'علاج معرفي', 'علاج نفسي'];
  final List<String> experienceYears = [
    '1 سنة',
    '2 سنة',
    '3 سنوات',
    '4 سنوات',
    '5+ سنوات',
  ];

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> pickFile(String type) async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (type == 'qualification') qualificationFile = File(pickedFile.path);
        if (type == 'license') licenseFile = File(pickedFile.path);
      });
    }
  }

  Future<String> uploadFile(File file, String path) async {
    Reference storageRef = FirebaseStorage.instance.ref().child(path);
    UploadTask uploadTask = storageRef.putFile(file);
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  Future<void> signUpTherapist() async {
    if (profileImage != null &&
        qualificationFile != null &&
        licenseFile != null) {
      String profileUrl = await uploadFile(
        profileImage!,
        'therapists/profile.jpg',
      );
      String qualificationUrl = await uploadFile(
        qualificationFile!,
        'therapists/qualification.pdf',
      );
      String licenseUrl = await uploadFile(
        licenseFile!,
        'therapists/license.pdf',
      );

      String userId =
          FirebaseAuth.instance.currentUser!.uid; // الحصول على uid للمستخدم

      // إضافة بيانات المعالج إلى Firestore مع الـ uid
      await FirebaseFirestore.instance.collection('therapists').add({
        'uid': userId, // إضافة الـ uid
        'firstName': firstNameController.text,
        'lastName': lastNameController.text,
        'email': emailController.text,
        'phone': phoneController.text,
        'specialty': selectedSpecialty,
        'experience': selectedExperience,
        'profileImage': profileUrl,
        'qualificationFile': qualificationUrl,
        'licenseFile': licenseUrl,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('حساب جديد')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: pickImage,
              child: CircleAvatar(
                radius: 40,
                backgroundColor: Colors.grey,
                backgroundImage:
                    profileImage != null ? FileImage(profileImage!) : null,
                child:
                    profileImage == null ? Icon(Icons.person, size: 40) : null,
              ),
            ),
            TextField(
              controller: firstNameController,
              decoration: InputDecoration(labelText: 'الاسم الأول'),
            ),
            TextField(
              controller: lastNameController,
              decoration: InputDecoration(labelText: 'الاسم الأخير'),
            ),
            DropdownButtonFormField(
              value: selectedSpecialty,
              items:
                  specialties
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
              onChanged:
                  (value) =>
                      setState(() => selectedSpecialty = value as String),
              decoration: InputDecoration(labelText: 'التخصص الدقيق'),
            ),
            DropdownButtonFormField(
              value: selectedExperience,
              items:
                  experienceYears
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
              onChanged:
                  (value) =>
                      setState(() => selectedExperience = value as String),
              decoration: InputDecoration(labelText: 'سنوات الخبرة'),
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'البريد الإلكتروني'),
            ),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(labelText: 'رقم الجوال'),
            ),
            ElevatedButton(
              onPressed: () => pickFile('qualification'),
              child: Text('رفع المؤهلات العلمية'),
            ),
            ElevatedButton(
              onPressed: () => pickFile('license'),
              child: Text('رفع الرخصة'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: signUpTherapist,
              child: Text('إنشاء حساب'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(
    MaterialApp(debugShowCheckedModeBanner: false, home: TherapistSignUpPage()),
  );
}
