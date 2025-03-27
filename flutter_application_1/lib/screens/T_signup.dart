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
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
  final TextEditingController confirmPasswordController = TextEditingController();
  String? selectedSpecialty;
  String? selectedExperience;
  File? profileImage;
  File? qualificationFile;
  File? licenseFile;
  final picker = ImagePicker();
  String profileFileName = "";
  String qualificationFileName = "";
  String licenseFileName = "";
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final List<String> specialties = ['علاج سلوكي', 'علاج معرفي', 'علاج نفسي'];
  final List<String> experienceYears = [
    '1 سنة',
    '2 سنة',
    '3 سنوات',
    '4 سنوات',
    '5+ سنوات',
  ];

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "هذا الحقل مطلوب";
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return "صيغة البريد الإلكتروني غير صحيحة";
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return "هذا الحقل مطلوب";
    }
    if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
      return "يرجى إدخال رقم جوال صحيح (10 أرقام)";
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "هذا الحقل مطلوب";
    }
    if (value.length < 8) {
      return "يجب أن تحتوي كلمة المرور على 8 خانات على الأقل";
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return "يجب أن تحتوي كلمة المرور على رقم واحد على الأقل";
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return "يجب أن تحتوي كلمة المرور على حرف صغير واحد على الأقل";
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return "يجب أن تحتوي كلمة المرور على حرف كبير واحد على الأقل";
    }
    return null;
  }

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
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: false,
    );

    if (result != null) {
      if (result.files.single.extension?.toLowerCase() != 'pdf') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'يجب رفع ملف PDF فقط',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

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

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
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
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
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
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      
      if (!qualificationFileName.toLowerCase().endsWith('.pdf') ||
          !licenseFileName.toLowerCase().endsWith('.pdf')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'يجب أن تكون جميع الملفات بصيغة PDF',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      try {
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

        String? profileUrl = await uploadToCloudinary(profileImage!, 'image');
        String? qualificationUrl = await uploadToCloudinary(
          qualificationFile!,
          'raw',
        );
        String? licenseUrl = await uploadToCloudinary(licenseFile!, 'raw');

        if (profileUrl == null ||
            qualificationUrl == null ||
            licenseUrl == null) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "فشل رفع الملفات، يرجى المحاولة مرة أخرى",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );
          return;
        }

        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: emailController.text.trim(),
              password: passwordController.text.trim(),
            );

        String userId = userCredential.user!.uid;

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
              'createdAt': FieldValue.serverTimestamp(),
              'status': 'pending',
            });

        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "تم إنشاء الحساب بنجاح",
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            backgroundColor: Color(0xFFFCB47A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 4),
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      } on FirebaseAuthException catch (e) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.message ?? "حدث خطأ ما",
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      } catch (e) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString(),
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
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
                begin: Alignment.topLeft,
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
                SizedBox(height: 40.h),
                Padding(
                  padding: EdgeInsets.all(10.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      FadeInUp(
                        duration: const Duration(milliseconds: 1000),
                        child: Text(
                          "حساب جديد",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 37.sp,
                            fontFamily: "NotoKufiArabic",
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                      
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40.r),
                      topRight: Radius.circular(40.r),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(30.r),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          SizedBox(height: 10.h),
                          GestureDetector(
                            onTap: pickProfileImage,
                            child: CircleAvatar(
                              radius: 40.r,
                              backgroundColor: Colors.grey,
                              backgroundImage:
                                  profileImage != null
                                      ? FileImage(profileImage!)
                                      : null,
                              child:
                                  profileImage == null
                                      ? Icon(Icons.person, size: 40.sp)
                                      : null,
                            ),
                          ),
                          if (profileImage != null)
                            Padding(
                              padding: EdgeInsets.only(top: 8.h),
                              child: Text(
                                profileFileName,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          SizedBox(height: 20.h),
                          _buildInputField(
                            "الاسم الأول",
                            controller: firstNameController,
                          ),
                          SizedBox(height: 20.h),
                          _buildInputField(
                            "الاسم الأخير",
                            controller: lastNameController,
                          ),
                          SizedBox(height: 20.h),
                          _buildEmailField(
                            "البريد الإلكتروني",
                            controller: emailController,
                          ),
                          SizedBox(height: 20.h),
                          _buildPasswordField(
                            "كلمة المرور",
                            controller: passwordController,
                            validator: _validatePassword,
                            obscureText: _obscurePassword,
                            toggleVisibility: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          SizedBox(height: 20.h),
                          _buildPasswordField(
                            "إعادة كتابة كلمة المرور",
                            controller: confirmPasswordController,
                            validator: _validateConfirmPassword,
                            obscureText: _obscureConfirmPassword,
                            toggleVisibility: () {
                              setState(() {
                                _obscureConfirmPassword = !_obscureConfirmPassword;
                              });
                            },
                          ),
                          SizedBox(height: 20.h),
                          _buildPhoneField(
                            "رقم الجوال",
                            controller: phoneController,
                          ),
                          SizedBox(height: 20.h),
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
                          SizedBox(height: 20.h),
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
                          SizedBox(height: 20.h),
                          _buildFilePickerButton(
                            icon: Icons.description,
                            label: 'رفع المؤهلات العلمية (PDF فقط)',
                            onPressed: () => pickFile('qualification'),
                            fileName: qualificationFileName,
                          ),
                          SizedBox(height: 20.h),
                          _buildFilePickerButton(
                            icon: Icons.assignment,
                            label: 'رفع الرخصة (PDF فقط)',
                            onPressed: () => pickFile('license'),
                            fileName: licenseFileName,
                          ),
                          SizedBox(height: 40.h),
                          FadeInUp(
                            duration: const Duration(milliseconds: 1600),
                            child: SizedBox(
                              width: double.infinity,
                              height: 50.h,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF6872F),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50.r),
                                  ),
                                  padding: EdgeInsets.symmetric(vertical: 15.h),
                                ),
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    await signUpTherapist();
                                  }
                                },
                                child: Text(
                                  "إنشاء حساب",
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20.h),
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
                                    fontSize: 16.sp,
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
        Text(label, style: TextStyle(color: Colors.black, fontSize: 16.sp)),
        SizedBox(height: 10.h),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.r),
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
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20.w,
                vertical: 15.h,
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

  Widget _buildEmailField(String label, {TextEditingController? controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(label, style: TextStyle(color: Colors.black, fontSize: 16.sp)),
        SizedBox(height: 10.h),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.r),
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
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20.w,
                vertical: 15.h,
              ),
            ),
            validator: _validateEmail,
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneField(String label, {TextEditingController? controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(label, style: TextStyle(color: Colors.black, fontSize: 16.sp)),
        SizedBox(height: 10.h),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.r),
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
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20.w,
                vertical: 15.h,
              ),
              
            ),
            validator: _validatePhone,
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField(
    String label, {
    required TextEditingController controller,
    required String? Function(String?)? validator,
    required bool obscureText,
    required VoidCallback toggleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(label, style: TextStyle(color: Colors.black, fontSize: 16.sp)),
        SizedBox(height: 10.h),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.r),
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
            obscureText: obscureText,
            textAlign: TextAlign.right,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20.w,
                vertical: 15.h,
              ),
              prefixIcon: IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: toggleVisibility,
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
        Text(label, style: TextStyle(color: Colors.black, fontSize: 16.sp)),
        SizedBox(height: 10.h),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.r),
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
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20.w,
                vertical: 15.h,
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
            borderRadius: BorderRadius.circular(10.r),
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
                SizedBox(width: 10.w),
                Text(
                  label,
                  style: TextStyle(fontSize: 16.sp, color: Colors.black),
                ),
              ],
            ),
          ),
        ),
        if (fileName.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: 8.h),
            child: Text(
              fileName,
              style: TextStyle(fontSize: 12.sp, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }
}