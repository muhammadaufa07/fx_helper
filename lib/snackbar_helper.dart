import 'package:flutter/material.dart';

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
  /// Returns the text color for the snackbar based on its [SnackbarState].
  ///
  /// Example:
  /// ```dart
  /// Color? textColor = SnackbarHelper._getTextColor(SnackbarState.error); // Colors.white
  /// ```
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

  /// Returns the background color for the snackbar based on its [SnackbarState].
  ///
  /// Example:
  /// ```dart
  /// Color? bg = SnackbarHelper._getbackground(SnackbarState.error); // Colors.red
  /// ```
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
    bool showButton = false,
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
          showButton
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
}
