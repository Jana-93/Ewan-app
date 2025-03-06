import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/loginScreen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  String profileFileName = "";
  String qualificationFileName = "";
  String licenseFileName = "";

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

  Future<void> pickProfileImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        profileImage = File(pickedFile.path);
        profileFileName = pickedFile.path.split('/').last;
      });
    }
  }

  Future<void> pickFile(String type) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        if (type == 'qualification') {
          qualificationFile = File(result.files.single.path!);
          qualificationFileName = result.files.single.name;
        }
        if (type == 'license') {
          licenseFile = File(result.files.single.path!);
          licenseFileName = result.files.single.name;
        }
      });
    }
  }

  Future<String?> uploadToCloudinary(File file, String resourceType) async {
    try {
      String cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? "";
      if (cloudName.isEmpty) {
        throw Exception("CLOUDINARY_CLOUD_NAME is not set in .env file");
      }

      var uri = Uri.parse(
        "https://api.cloudinary.com/v1_1/$cloudName/$resourceType/upload",
      );
      var request = http.MultipartRequest("POST", uri);

      var fileBytes = await file.readAsBytes();
      var multipartFile = http.MultipartFile.fromBytes(
        'file',
        fileBytes,
        filename: file.path.split("/").last,
      );

      request.files.add(multipartFile);
      request.fields['upload_preset'] = 'therapist files';

      // Send the request and wait for the response
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      // Parse response to extract URL
      if (response.statusCode == 200) {
        // Extract and return the URL from the response
        final Map<String, dynamic> responseData = jsonDecode(responseBody);
        return responseData['secure_url'] as String;
      } else {
        print("Upload failed with status: ${response.statusCode}");
        print("Response: $responseBody");
        return null;
      }
    } catch (e) {
      print("Error uploading to Cloudinary: $e");
      return null;
    }
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

      if (profileImage == null ||
          qualificationFile == null ||
          licenseFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "يرجى رفع جميع الملفات المطلوبة",
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

      try {
        // إظهار مؤشر التحميل
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF6872F)),
              ),
            );
          },
        );

        // رفع الملفات إلى Cloudinary
        String? profileUrl = await uploadToCloudinary(profileImage!, 'image');
        String? qualificationUrl = await uploadToCloudinary(
          qualificationFile!,
          'raw',
        );
        String? licenseUrl = await uploadToCloudinary(licenseFile!, 'raw');

        if (profileUrl == null ||
            qualificationUrl == null ||
            licenseUrl == null) {
          Navigator.pop(context); // إغلاق مؤشر التحميل
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "فشل رفع الملفات، يرجى المحاولة مرة أخرى",
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

        // إنشاء حساب باستخدام البريد الإلكتروني وكلمة المرور
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: emailController.text.trim(),
              password: passwordController.text.trim(),
            );

        String userId = userCredential.user!.uid;

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

        // إغلاق مؤشر التحميل
        Navigator.pop(context);

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
        // إغلاق مؤشر التحميل
        Navigator.pop(context);

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
      } catch (e) {
        // إغلاق مؤشر التحميل
        Navigator.pop(context);

        // التعامل مع الأخطاء العامة
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString(),
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
                            onTap: pickProfileImage,
                            child: CircleAvatar(
                              radius: 40,
                              backgroundColor: Colors.grey,
                              backgroundImage:
                                  profileImage != null
                                      ? FileImage(profileImage!)
                                      : null,
                              child:
                                  profileImage == null
                                      ? Icon(Icons.person, size: 40)
                                      : null,
                            ),
                          ),
                          if (profileImage != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                profileFileName,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                                textAlign: TextAlign.center,
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
                            fileName: qualificationFileName,
                          ),
                          const SizedBox(height: 20),
                          _buildFilePickerButton(
                            icon: Icons.assignment,
                            label: 'رفع الرخصة',
                            onPressed: () => pickFile('license'),
                            fileName: licenseFileName,
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
    required String fileName,
  }) {
    return Column(
      children: [
        Container(
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
                Text(
                  label,
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
              ],
            ),
          ),
        ),
        if (fileName.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              fileName,
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }
}
