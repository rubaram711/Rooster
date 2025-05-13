import 'dart:io';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

class ImagePickerHelper {
  static Future<Uint8List?> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // Convert File to Uint8List
      return await File(pickedFile.path).readAsBytes();
    }
    return null;
  }
}
