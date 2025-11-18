import 'dart:io';
import 'dart:math';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

class CompressionHelper {
  static Future<String> getTempDir() async {
    Directory? tmpDir;
    try {
      Directory rootTmpDir = await getTemporaryDirectory();
      tmpDir = Directory("${rootTmpDir.path}/FxHelper/compression");
      if (!tmpDir.existsSync()) {
        print("Target dir not exist");
        tmpDir.createSync(recursive: true);
        print("${tmpDir.path} created!");
      }
    } catch (e) {
      print(e.toString());
    }

    return tmpDir?.path ?? "";
  }

  static String _genRandFileName() {
    DateTime time = DateTime.now();
    return "${time.microsecondsSinceEpoch}-${Random().nextInt(999999)}";
  }

  /// Compress image
  ///
  /// var image = await PickerHelper.pickImage(context);
  /// File file = File(image?.path ?? "");
  /// File? f = await CompressionHelper.compressImage(file);
  /// await CompressionHelper.cleanCache();
  static Future<File?> compressImage(
    File? originalFile, {
    CompressFormat format = CompressFormat.jpeg,
    int q = 25,
  }) async {
    late File? compressedFile;
    try {
      /* New File Temp */
      var tempDir = await getTempDir();
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

  static Future<void> cleanCache() async {
    try {
      final dir = Directory(await getTempDir());
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
