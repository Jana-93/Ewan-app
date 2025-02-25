import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/loginScreen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:animate_do/animate_do.dart';

class TherapistSignUpPage extends StatefulWidget {
  @override
  _TherapistSignUpPageState createState() => _TherapistSignUpPageState();
}

class _TherapistSignUpPageState extends State<TherapistSignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
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

  // دالة التحقق من كلمة المرور
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "هذا الحقل مطلوب";
    }
    if (value.length < 8) {
      return "يجب أن تحتوي كلمة المرور على 8 خانات على الأقل";
    }
    if (!RegExp(r'[A-Za-z]').hasMatch(value)) {
      return "يجب أن تحتوي كلمة المرور على حرف واحد على الأقل";
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return "يجب أن تحتوي كلمة المرور على رقم واحد على الأقل";
    }
    return null;
  }

  // دالة التحقق من تطابق كلمة المرور
  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return "هذا الحقل مطلوب";
    }
    if (value != passwordController.text) {
      return "كلمة المرور غير متطابقة";
    }
    return null;
  }

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
    if (_formKey.currentState!.validate()) {
      if (passwordController.text != confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "كلمة المرور غير متطابقة",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      if (profileImage != null &&
          qualificationFile != null &&
          licenseFile != null) {
        try {
          // إنشاء حساب باستخدام البريد الإلكتروني وكلمة المرور
          UserCredential userCredential = await FirebaseAuth.instance
              .createUserWithEmailAndPassword(
                email: emailController.text.trim(),
                password: passwordController.text.trim(),
              );

          String userId = userCredential.user!.uid;

          // رفع الملفات إلى Firebase Storage
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

          // حفظ بيانات المعالج في Firestore
          await FirebaseFirestore.instance
              .collection('therapists')
              .doc(userId)
              .set({
                'uid': userId,
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

          // إظهار رسالة نجاح
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "تم إنشاء الحساب بنجاح",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              backgroundColor: Color(0xFFFCB47A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );

          // الانتقال إلى شاشة تسجيل الدخول
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );
        } on FirebaseAuthException catch (e) {
          // التعامل مع الأخطاء
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                e.message ?? "حدث خطأ ما",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
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
                const SizedBox(height: 50),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      FadeInUp(
                        duration: const Duration(milliseconds: 1000),
                        child: const Text(
                          "حساب جديد",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 37,
                            fontFamily: "NotoKufiArabic",
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(30),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: pickImage,
                            child: CircleAvatar(
                              radius: 40,
                              backgroundColor: Colors.grey,
                              backgroundImage: profileImage != null
                                  ? FileImage(profileImage!)
                                  : null,
                              child: profileImage == null
                                  ? Icon(Icons.person, size: 40)
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildInputField(
                            "الاسم الأول",
                            controller: firstNameController,
                          ),
                          const SizedBox(height: 20),
                          _buildInputField(
                            "الاسم الأخير",
                            controller: lastNameController,
                          ),
                          const SizedBox(height: 20),
                          _buildInputField(
                            "البريد الإلكتروني",
                            controller: emailController,
                          ),
                          const SizedBox(height: 20),
                          _buildPasswordField(
                            "كلمة المرور",
                            controller: passwordController,
                            validator: _validatePassword,
                          ),
                          const SizedBox(height: 20),
                          _buildPasswordField(
                            "إعادة كتابة كلمة المرور",
                            controller: confirmPasswordController,
                            validator: _validateConfirmPassword,
                          ),
                          const SizedBox(height: 20),
                          _buildInputField(
                            "رقم الجوال",
                            controller: phoneController,
                          ),
                          const SizedBox(height: 20),
                          _buildDropdown(
                            "التخصص الدقيق",
                            value: selectedSpecialty,
                            items: specialties,
                            onChanged: (value) {
                              setState(() {
                                selectedSpecialty = value as String;
                              });
                            },
                          ),
                          const SizedBox(height: 20),
                          _buildDropdown(
                            "سنوات الخبرة",
                            value: selectedExperience,
                            items: experienceYears,
                            onChanged: (value) {
                              setState(() {
                                selectedExperience = value as String;
                              });
                            },
                          ),
                          const SizedBox(height: 20),
                          _buildFilePickerButton(
                            icon: Icons.description,
                            label: 'رفع المؤهلات العلمية',
                            onPressed: () => pickFile('qualification'),
                          ),
                          const SizedBox(height: 20),
                          _buildFilePickerButton(
                            icon: Icons.assignment,
                            label: 'رفع الرخصة',
                            onPressed: () => pickFile('license'),
                          ),
                          const SizedBox(height: 40),
                          FadeInUp(
                            duration: const Duration(milliseconds: 1600),
                            child: SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF6872F),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 15,
                                  ),
                                ),
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    await signUpTherapist();
                                  }
                                },
                                child: const Text(
                                  "إنشاء حساب",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          FadeInUp(
                            duration: const Duration(milliseconds: 1800),
                            child: Center(
                              child: TextButton(
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => LoginScreen(),
                                    ),
                                  );
                                },
                                child: Text(
                                  "تسجيل الدخول كطبيب/ أب ",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFFF6872F),
                                    decoration: TextDecoration.underline,
                                    decorationColor: Color(0xFFF6872F),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String label, {TextEditingController? controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(label, style: TextStyle(color: Colors.black, fontSize: 16)),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(225, 95, 27, .3),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            textAlign: TextAlign.right,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 15,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return "هذا الحقل مطلوب";
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField(
    String label, {
    required TextEditingController controller,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(label, style: TextStyle(color: Colors.black, fontSize: 16)),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(225, 95, 27, .3),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            obscureText: true,
            textAlign: TextAlign.right,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 15,
              ),
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(
    String label, {
    required String? value,
    required List<String> items,
    required Function(dynamic) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(label, style: TextStyle(color: Colors.black, fontSize: 16)),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(225, 95, 27, .3),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: DropdownButtonFormField(
            value: value,
            items:
                items
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
            onChanged: onChanged,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 15,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return "هذا الحقل مطلوب";
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilePickerButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(225, 95, 27, .3),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: TextButton(
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Color(0xFFF6872F)),
            const SizedBox(width: 10),
            Text(label, style: TextStyle(fontSize: 16, color: Colors.black)),
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
