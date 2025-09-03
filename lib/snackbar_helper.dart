import 'package:flutter/material.dart';

final GlobalKey<ScaffoldMessengerState> snackbarKey = GlobalKey<ScaffoldMessengerState>();

enum SnackbarState { success, error, warning }

class SnackbarHelper {
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
          Text(message, style: TextStyle(color: _getTextColor(state))),
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
    snackbarKey.currentState?.showSnackBar(snackBar);
  }
}
