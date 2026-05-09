import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class ImageHelper {
  // ✅ اختيار صورة من الجهاز
  static Future<String?> pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) return null;

    final file = File(result.files.first.path!);
    return await _saveImage(file);
  }

  // ✅ اختيار أكثر من صورة
  static Future<List<String>> pickMultipleImages() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );

    if (result == null || result.files.isEmpty) return [];

    final savedPaths = <String>[];
    for (final file in result.files) {
      if (file.path != null) {
        final saved = await _saveImage(File(file.path!));
        if (saved != null) savedPaths.add(saved);
      }
    }
    return savedPaths;
  }

  // ✅ حفظ الصورة في مجلد الأبلكيشن
  static Future<String?> _saveImage(File file) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${appDir.path}/car_images');
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}${path.extension(file.path)}';
      final savedFile = await file.copy('${imagesDir.path}/$fileName');
      return savedFile.path;
    } catch (e) {
      return null;
    }
  }

  // ✅ حذف صورة
  static Future<void> deleteImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // ignore
    }
  }

  // ✅ التحقق إن الصورة موجودة
  static bool imageExists(String? imagePath) {
    if (imagePath == null) return false;
    return File(imagePath).existsSync();
  }
}
