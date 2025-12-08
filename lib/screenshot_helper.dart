import 'package:no_screenshot/no_screenshot.dart';
import 'dart:developer';

class ScreenshotHelper {
  static final _noScreenshot = NoScreenshot.instance;

  static Future<void> disable() async {
    bool result = await _noScreenshot.screenshotOff();
    log("Screenshot is ${result ? "Enabled" : "Disabled"}");
  }

  static Future<void> enable() async {
    bool result = await _noScreenshot.screenshotOff();
    log("Screenshot is ${result ? "Enabled" : "Disabled"}");
  }
}
