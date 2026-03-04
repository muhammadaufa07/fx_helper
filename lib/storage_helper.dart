import 'dart:developer';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class StorageHelper {
  static Future<Directory> getTempDir(String? subDirectory) async {
    Directory rootTmpDir = await getApplicationSupportDirectory();
    Directory tmpDir = Directory("${rootTmpDir.path}${subDirectory ?? ""}");
    if (!tmpDir.existsSync()) {
      log("Target dir not exist");
      tmpDir.createSync(recursive: true);
      log("${tmpDir.path} created!");
    }
    return tmpDir;
  }

  static Future<File> createTempFromFile(File file, {String? subpath}) async {
    Directory d = await getTempDir(subpath);
    String name = "${DateTime.now().millisecondsSinceEpoch}";
    String ext = ".${file.path.split('.').last}";
    return file.copy("${d.path}/$name$ext");
  }

  static Future<void> printAllCache({String? path}) async {
    var rootPath = (await StorageHelper.getTempDir(path)).path;
    _printAllCache(path: rootPath);
  }

  static Future<void> _printAllCache({String? path}) async {
    try {
      Directory dir = Directory(path ?? "");
      List<FileSystemEntity> files = await dir.list().toList();
      for (FileSystemEntity e in files) {
        if (e.statSync().type == FileSystemEntityType.directory) {
          await _printAllCache(path: e.path);
        } else {
          log("[cache] ${e.path}");
        }
      }
    } catch (e) {
      log(e.toString());
    }
  }

  static Future<void> deleteAllAppSupportData({String? path}) async {
    try {
      Directory dir = await getTempDir(path);
      List<FileSystemEntity> files = await dir.list(recursive: false, followLinks: false).toList();
      for (FileSystemEntity e in files) {
        try {
          log("[delete] ${e.path}");
          e.deleteSync(recursive: true);
        } catch (e) {
          log(e.toString());
        }
      }
    } catch (e) {
      log(e.toString());
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
    log("DOWNLOAD DIR: $path");
    return path;
  }
}
