import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

enum ToastState { success, error, warning }

class ToastHelper {
  Color? _getTextColor(ToastState state) {
    switch (state) {
      case ToastState.success:
        return Colors.white;
      case ToastState.error:
        return Colors.white;
      case ToastState.warning:
        return Colors.white;
    }
  }

  Color? _getBackground(ToastState state) {
    switch (state) {
      case ToastState.success:
        return Colors.green;
      case ToastState.error:
        return Colors.red;
      case ToastState.warning:
        return Colors.orange;
    }
  }

  void showToast(ToastState state, String message, {ToastGravity gravity = ToastGravity.BOTTOM}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: gravity,
      backgroundColor: _getBackground(state),
      textColor: _getTextColor(state),
      fontSize: 16.0,
    );
  }
}
