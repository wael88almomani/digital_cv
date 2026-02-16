import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalImageStore {
  LocalImageStore(this._prefs, {ImagePicker? picker})
    : _picker = picker ?? ImagePicker();

  final SharedPreferences _prefs;
  final ImagePicker _picker;

  SharedPreferences get prefs => _prefs;

  static const _imageKeyPrefix = 'cv_profile_image_';
  static const _legacyImageKey = 'local_profile_image';

  /// Pick and save image for a specific CV
  Future<String?> pickAndSaveImageForCv(String cvId) async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (picked == null) return null;

    final directory = await getApplicationDocumentsDirectory();
    final extension = path.extension(picked.path);
    final fileName =
        'profile_${cvId}_${DateTime.now().millisecondsSinceEpoch}$extension';
    final savedFile = await File(
      picked.path,
    ).copy(path.join(directory.path, fileName));

    await _prefs.setString('$_imageKeyPrefix$cvId', savedFile.path);
    return savedFile.path;
  }

  /// Get image path for a specific CV
  String? getImagePathForCv(String cvId) {
    return _prefs.getString('$_imageKeyPrefix$cvId');
  }

  /// Clear image for a specific CV
  Future<void> clearImageForCv(String cvId) async {
    final imagePath = _prefs.getString('$_imageKeyPrefix$cvId');
    if (imagePath != null) {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
      }
    }
    await _prefs.remove('$_imageKeyPrefix$cvId');
  }

  // Legacy methods for backward compatibility
  Future<String?> pickAndSaveImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (picked == null) return null;

    final directory = await getApplicationDocumentsDirectory();
    final extension = path.extension(picked.path);
    final fileName =
        'profile_${DateTime.now().millisecondsSinceEpoch}$extension';
    final savedFile = await File(
      picked.path,
    ).copy(path.join(directory.path, fileName));

    await _prefs.setString(_legacyImageKey, savedFile.path);
    return savedFile.path;
  }

  String? getImagePath() => _prefs.getString(_legacyImageKey);

  Future<void> clearImage() async {
    await _prefs.remove(_legacyImageKey);
  }
}
