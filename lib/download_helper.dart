import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fx_helper/network/fx_network.dart';
import 'package:fx_helper/snackbar_helper.dart';
import 'package:fx_helper/storage_helper.dart';
import 'package:fx_helper/widgets/net_msg_dialog.dart';
import 'package:mime/mime.dart';
import 'package:open_file_manager/open_file_manager.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:url_launcher/url_launcher.dart';

/// Download and safe files
///
/// ```
/// android Manifest:
///   <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
///   <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
///
/// ios info.plist:
///   <key>UISupportsDocumentBrowser</key>
///   <true/>
/// ```
class DownloadHelper extends ChangeNotifier {
  static bool isLoading = false;

  static String _genRandFileName() {
    DateTime time = DateTime.now();
    return "${time.microsecondsSinceEpoch}-${Random().nextInt(999999)}";
  }

  Future<File?> downloadFile(BuildContext context, String path) async {
    print("downloadFile($path)");
    isLoading = true;
    notifyListeners();
    dynamic res;
    File? file;
    try {
      SnackbarHelper.showSnackBar(SnackbarState.success, "Mendownload");
      res = await FxNetworkLocal().getGlobal(path);
      String ext = "";
      res.headers.forEach((key, value) {
        if (key == "content-type") {
          ext = ".${extensionFromMime(value)}";
          return;
        }
      });
      String? targetPath = await StorageHelper.getDownloadDir();
      String? fileName = _genRandFileName();
      file = File("$targetPath/$fileName$ext");
      file.writeAsBytesSync(res.bodyBytes);
      SnackbarHelper.showSnackBar(
        SnackbarState.success,
        "$fileName.$ext Berhasil Disimpan",
        buttonTitle: "Buka",
        onTap: () async {
          openFileManager(
            androidConfig: AndroidConfig(
              folderPath: await StorageHelper.getDownloadDir() ?? "",
              folderType: AndroidFolderType.download,
            ),
            iosConfig: IosConfig(
              // Path is case-sensitive here.
              folderPath: 'Documents',
            ),
          );
        },
      );
    } catch (e) {
      NetMsgDialog.handleError(context, e, res);
    }

    isLoading = false;
    notifyListeners();
    return file;
  }
}
