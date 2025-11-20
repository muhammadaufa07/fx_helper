import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:fx_helper/in_app_notification.dart';

/// A global key for showing SnackBars across the entire app
/// using [SnackbarHelper.showSnackBar].
///
/// Example:
/// ```dart
/// MaterialApp(
///   scaffoldMessengerKey: globalSnackbarKey,
///   home: MyHomePage(),
/// )
/// ```
final GlobalKey<ScaffoldMessengerState> globalSnackbarKey = GlobalKey<ScaffoldMessengerState>();
final GlobalKey<NavigatorState> globalNavigatorKey = GlobalKey<NavigatorState>();

/// Different types of snackbar states that define color and style.
enum SnackbarState { success, error, warning }

/// A helper class for showing custom styled SnackBars.
///
/// Example:
/// ```dart
/// SnackbarHelper.showSnackBar(
///   SnackbarState.success,
///   "Data saved successfully!",
/// );
/// ```
class SnackbarHelper {
  /// Shows a Snackbar with custom styles depending on [SnackbarState].
  ///
  /// Parameters:
  /// - [state]: Defines the snackbar type (`success`, `error`, `warning`).
  /// - [message]: The message to display.
  /// - [showButton]: Whether to show an action button (default: `false`).
  /// - [buttonTitle]: The label of the action button (default: `"Close"`).
  /// - [onTap]: Callback when the button is tapped.
  /// - [duration]: How long the snackbar is displayed (default: 2 seconds).
  ///
  /// Example:
  /// ```dart
  /// SnackbarHelper.showSnackBar(
  ///   SnackbarState.success,
  ///   "Profile updated successfully!",
  ///   showButton: true,
  ///   buttonTitle: "Undo",
  ///   onTap: () {
  ///     print("Undo tapped");
  ///   },
  ///   duration: Duration(seconds: 3),
  /// );
  /// ```
  static void showSnackBar(
    SnackbarState state,
    String message, {
    // bool showButton = false,
    String? buttonTitle,
    Function()? onTap,
    Duration? duration,
  }) {
    final SnackBar snackBar = SnackBar(
      behavior: SnackBarBehavior.floating,
      showCloseIcon: true,
      duration: duration ?? const Duration(seconds: 2),
      backgroundColor: _getbackground(state),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(message, style: TextStyle(color: _getTextColor(state))),
          ),
          onTap != null
              ? ElevatedButton(
                  onPressed: onTap,
                  style: ButtonStyle(
                    minimumSize: WidgetStatePropertyAll<Size>(Size.zero),
                    backgroundColor: WidgetStatePropertyAll<Color>(Colors.white),
                    padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 4, horizontal: 16)),
                  ),
                  child: Text(buttonTitle ?? "Close", style: TextStyle(color: _getbackground(state))),
                )
              : Container(),
        ],
      ),
    );
    globalSnackbarKey.currentState?.showSnackBar(snackBar);
  }

  /// Avoid when message more than 2 lines
  /// Usage:
  ///   SnackbarHelper.showSnackBar2(
  ///     SnackbarState.success,
  ///     "Message",
  ///   );
  static void fancy(
    SnackbarState state,
    String message, {
    bool showButton = false,
    String? buttonTitle,
    Function()? onTap,
    Duration? duration,
  }) {
    final snackBar = SnackBar(
      /// need to set following properties for best effect of awesome_snackbar_content
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      duration: duration ?? const Duration(seconds: 2),
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        /*  */
        messageTextStyle: TextStyle(overflow: TextOverflow.visible),
        inMaterialBanner: true,
        title: _getTitle(state),
        message: message,
        contentType: _getContentType(state),
      ),
    );
    globalSnackbarKey.currentState?.showSnackBar(snackBar);
  }

  static void inApp(
    BuildContext context,
    SnackbarState state,
    String message, {
    bool showButton = false,
    String? buttonTitle,
    Function()? onTap,
    Duration? duration,
  }) {
    InAppNotification.show(
      context,
      icon: _getIcon(state, _getbackground(state) ?? Colors.green),
      title: _getTitle(state),
      message: message,
      color: _getbackground(state) ?? Colors.green,
      duration: duration ?? Duration(seconds: 5),
    );
  }

  static Widget _getIcon(SnackbarState state, Color color) {
    switch (state) {
      case SnackbarState.success:
        return Icon(Icons.check_circle, color: color, size: 48);
      case SnackbarState.error:
        return Icon(Icons.close, color: color, size: 48);
      case SnackbarState.warning:
        return Icon(Icons.donut_large_rounded, color: color, size: 48);
    }
  }

  static Color? _getTextColor(SnackbarState state) {
    switch (state) {
      case SnackbarState.success:
        return Colors.white;
      case SnackbarState.error:
        return Colors.white;
      case SnackbarState.warning:
        return Colors.white;
    }
  }

  static Color? _getbackground(SnackbarState state) {
    switch (state) {
      case SnackbarState.success:
        return null;
      case SnackbarState.error:
        return Colors.red;
      case SnackbarState.warning:
        return Colors.orange;
    }
  }

  static ContentType _getContentType(SnackbarState state) {
    switch (state) {
      case SnackbarState.success:
        return ContentType.success;
      case SnackbarState.error:
        return ContentType.failure;
      case SnackbarState.warning:
        return ContentType.warning;
    }
  }

  static String _getTitle(SnackbarState state) {
    switch (state) {
      case SnackbarState.success:
        return "Success";
      case SnackbarState.error:
        return "Gagal";
      case SnackbarState.warning:
        return "Notice";
    }
  }
}
