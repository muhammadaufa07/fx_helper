import 'dart:io';

import 'package:path_provider/path_provider.dart';

class StorageHelper {
  /// get directory or create directory if not exist
  ///
  ///
  /// /root/[subDirectory]
  static Future<String> getTempDir(String subDirectory) async {
    Directory? tmpDir;
    try {
      Directory rootTmpDir = await getTemporaryDirectory();
      tmpDir = Directory("${rootTmpDir.path}/FxHelper/$subDirectory");
      print(tmpDir);
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

  static Future<void> printAllCache() async {
    try {
      final dir = await getTemporaryDirectory();
      List<FileSystemEntity> files = await dir.list().toList();
      for (FileSystemEntity e in files) {
        print("CACHE: ${e.path}");
      }
    } catch (e) {
      print(e.toString());
    }
  }

  static Future<String?> getDownloadDir() async {
    String path = "";
    if (Platform.isAndroid) {
      path = "/storage/emulated/0/Download/";
    } else {
      var dir = await getApplicationDocumentsDirectory();
      path = dir.path;
    }
    print("DOWNLOAD DIR: $path");
    return path;
  }
}
