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
        print("CacheData: ${e.path}");
      }
    } catch (e) {
      print(e.toString());
    }
  }

  static Future<void> printAllAppData() async {
    try {
      final dir = await getApplicationSupportDirectory();
      List<FileSystemEntity> files = await dir.list(recursive: true, followLinks: false).toList();
      for (FileSystemEntity e in files) {
        print("AppSupportData: ${e.path}");
      }
    } catch (e) {
      print(e.toString());
    }
  }

  static Future<void> deleteAllAppSupportData() async {
    try {
      final dir = await getApplicationSupportDirectory();
      List<FileSystemEntity> files = await dir.list(recursive: true, followLinks: false).toList();
      for (FileSystemEntity e in files) {
        try {
          print("DELETE: AppSupportData: ${e.path}");
          e.deleteSync();
        } catch (e) {
          print(e);
        }
      }
    } catch (e) {
      print(e.toString());
    }
  }

  static Future<void> deleteAllCacheData() async {
    try {
      final dir = await getApplicationSupportDirectory();
      List<FileSystemEntity> files = await dir.list(recursive: true, followLinks: false).toList();
      for (FileSystemEntity e in files) {
        try {
          print("DELETE: CacheData: ${e.path}");
          e.deleteSync();
        } catch (e) {
          print(e);
        }
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
