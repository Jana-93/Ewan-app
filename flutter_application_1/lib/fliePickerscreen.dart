import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';

class FilePickerScreen extends StatefulWidget {
  final Function(String) onFileUploaded;
  final String fileType;

  const FilePickerScreen({
    Key? key,
    required this.onFileUploaded,
    this.fileType = 'raw',
  }) : super(key: key);

  @override
  _FilePickerScreenState createState() => _FilePickerScreenState();
}

class _FilePickerScreenState extends State<FilePickerScreen> {
  FilePickerResult? filePickerResult;
  bool isUploading = false;
  String? fileName;
  String? filePath;
  String? errorMessage;

  Future<void> pickFile() async {
    try {
      filePickerResult = await FilePicker.platform.pickFiles(
        type: widget.fileType == 'image' ? FileType.image : FileType.any,
      );

      if (filePickerResult != null) {
        setState(() {
          fileName = filePickerResult!.files.single.name;
          filePath = filePickerResult!.files.single.path;
          errorMessage = null;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "خطأ في اختيار الملف: $e";
      });
    }
  }

  Future<void> uploadFile() async {
    if (filePickerResult == null || filePath == null) {
      setState(() {
        errorMessage = "يرجى اختيار ملف أولاً";
      });
      return;
    }

    setState(() {
      isUploading = true;
      errorMessage = null;
    });

    try {
      String? fileUrl = await uploadToCloudinary(
        File(filePath!),
        widget.fileType,
      );

      if (fileUrl != null) {
        widget.onFileUploaded(fileUrl);
        Navigator.pop(context);
      } else {
        setState(() {
          errorMessage = "فشل رفع الملف";
          isUploading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "خطأ في رفع الملف: $e";
        isUploading = false;
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
      request.fields['upload_preset'] =
          'therapist_files'; // Ensure this preset exists in your Cloudinary account

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = Map<String, dynamic>.from(
          jsonDecode(responseBody) as Map,
        );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("اختيار ملف"),
        backgroundColor: Color(0xFFF6872F),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // File selection area
            GestureDetector(
              onTap: pickFile,
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Color(0xFFF6872F), width: 2),
                ),
                child:
                    widget.fileType == 'image' && filePath != null
                        ? Image.file(File(filePath!), fit: BoxFit.cover)
                        : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              widget.fileType == 'image'
                                  ? Icons.image
                                  : Icons.description,
                              size: 50,
                              color: Color(0xFFF6872F),
                            ),
                            SizedBox(height: 10),
                            Text(
                              fileName ?? "اضغط لاختيار ملف",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
              ),
            ),
            SizedBox(height: 20),
            // Upload button
            ElevatedButton(
              onPressed: isUploading ? null : uploadFile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFF6872F),
              ),
              child:
                  isUploading
                      ? CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                      : Text("رفع الملف"),
            ),
            SizedBox(height: 20),
            // Error message
            if (errorMessage != null)
              Text(
                errorMessage!,
                style: TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}
