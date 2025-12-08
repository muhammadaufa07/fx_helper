import 'package:no_screenshot/no_screenshot.dart';
import 'dart:developer';

class ScreenshotHelper {
  static final _noScreenshot = NoScreenshot.instance;

  static Future<void> disable() async {
    try {
      bool result = await _noScreenshot.screenshotOff();
      log("Screenshot is Disabled [${result ? "success" : "failed"}]");
    } catch (e) {
      log(e.toString());
    }
  }

  static Future<void> enable() async {
    try {
      bool result = await _noScreenshot.screenshotOff();
      log("Screenshot is Enabled [${result ? "success" : "failed"}]");
    } catch (e) {
      log("Screenshot is Enabled");
    }
  }
}
