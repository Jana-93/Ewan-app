import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

Future<bool> uploadToCloudinary(FilePickerResult? filePickerResult) async {
  if (filePickerResult == null || filePickerResult.files.isEmpty) {
    print("لا يوجد ملف");
    return false;
  }
  File file = File(filePickerResult.files.single.path!);

  String cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? "";

  //create multiple requests to create files
  var uri = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/raw/upload");
  var request = http.MultipartRequest("post", uri);
  var fileBytes = await file.readAsBytes();
  var multipartFile = http.MultipartFile.fromBytes(
    'file',
    fileBytes,
    filename: file.path.split("/").last,
  );
  request.files.add(multipartFile);
  request.fields['upload_presets'] = 'therapist files';
  request.fields['resource_type'] = 'raw';
  //send the request then wait for the response
  var response = await request.send();

  //get the response as text
  var responseBody = await response.stream.bytesToString();

  print(responseBody);
  if (response.statusCode == 200) {
    print("تم الرفع بنجاح");
    return true;
  } else {
    print("فشل الرفع");
    return false;
  }
}
