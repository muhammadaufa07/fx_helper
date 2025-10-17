import 'package:package_info_plus/package_info_plus.dart';

class ToolsHelper {
  static Future<void> debugLaunchInfo({required bool isDevMode, required String apiUrl}) async {
    var t = await PackageInfo.fromPlatform();
    print("App Info");
    print("App\t\t: ${t.appName}");
    print("Mode\t\t: ${isDevMode ? "Staging" : "Production"}");
    print("Version\t: ${t.version}+${t.buildNumber}");
    print("API\t\t: $apiUrl");
  }
}
