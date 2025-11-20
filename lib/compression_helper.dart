import 'dart:io';
import 'dart:math';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fx_helper/storage_helper.dart';

class CompressionHelper {
  static String _genRandFileName() {
    DateTime time = DateTime.now();
    return "${time.microsecondsSinceEpoch}-${Random().nextInt(999999)}";
  }

  /// Compress image
  ///
  /// ```
  /// var image = await PickerHelper.pickImage(context);
  /// File? f = await CompressionHelper.compressImage(image);
  /// ```
  static Future<File?> compressImage(
    File? originalFile, {
    CompressFormat format = CompressFormat.jpeg,
    int q = 25,
  }) async {
    late File? compressedFile;
    try {
      /* New File Temp */
      var tempDir = await StorageHelper.getTempDir("compression");
      String fileName = _genRandFileName();

      final String targetPath =
          "$tempDir/imagetemp-$fileName-${(q / 100).toStringAsFixed(2)}-compressed.${format.name}";

      if (originalFile != null) {
        final XFile? result = await FlutterImageCompress.compressAndGetFile(
          originalFile.path,
          targetPath,
          quality: q,
          format: format,
          numberOfRetries: 5,
          rotate: 180,
        );
        compressedFile = File(result?.path ?? "");
      }
    } catch (e) {
      print(e.toString());
    }

    return compressedFile;
  }

  /// remove all cache and temporary files.
  ///
  /// ```
  /// CompressionHelper.cleanCache();
  /// ```
  static Future<void> cleanCache() async {
    try {
      final dir = Directory(await StorageHelper.getTempDir("compression"));
      List<FileSystemEntity> files = await dir.list().toList();
      for (FileSystemEntity e in files) {
        print("DELETED CACHE: ${e.path}");
        e.deleteSync();
      }
    } catch (e) {
      print(e.toString());
    }
  }
}
