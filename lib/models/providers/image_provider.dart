import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cloudinary/cloudinary.dart';
import 'package:image_picker/image_picker.dart';

class CloudinaryProvider {
  static final CloudinaryProvider instance = CloudinaryProvider._init();

  final Cloudinary cloudinary =
      Cloudinary.signedConfig(
          apiKey: '${dotenv.env["CLOUDINARY_API_KEY"]}',
          apiSecret: '${dotenv.env["CLOUDINARY_API_SECRET"]}',
          cloudName: 'ddytbxzsn');

  CloudinaryProvider._init();

  Future<String?> uploadImage(File file, String folder, String fileName) async {
    final response = await cloudinary.upload(
        file: file.path,
        fileBytes: file.readAsBytesSync(),
        resourceType: CloudinaryResourceType.image,
        folder: folder,
        fileName: fileName,
        progressCallback: (count, total) {
          print('Uploading image from file with progress: $count/$total');
        });

    if (response.isSuccessful) {
      print('Get your image from with ${response.secureUrl}');
    }
    return response.secureUrl;
  }

  Future<File?> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      return File(pickedFile.path);
    } else {
      return null;
    }
  }
}
