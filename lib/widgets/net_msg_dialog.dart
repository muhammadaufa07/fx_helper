import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fx_helper/snackbar_helper.dart';
import 'package:fx_helper/widgets/fx_theme.dart';

class NetMsgDialog {
  static bool widgetInView = false;
  static final GlobalKey _networkDialogGlobalKey = GlobalKey();

  static void handleError(BuildContext context, e, dynamic res) async {
    print(e);
    print(res);
    print("_networkDialogGlobalKey.currentWidget");
    print(_networkDialogGlobalKey.currentWidget);
    if (widgetInView || _networkDialogGlobalKey.currentWidget != null) return;

    String title = "Error";
    String msg = "Something Went Wrong";
    try {
      if (e.toString().contains("SocketException")) {
        title = "Socket Exception";
        msg = "No Connection, Please check your connection";
      } else if (e.toString().contains("FormatException")) {
        title = "Format Exception";
        msg = "Error while Parsing Data";
      } else if (e.toString().contains("TimeoutException")) {
        title = "Ops! Timeout";
        msg = "Please check your connection";
      } else if (e.toString().contains("ApiException")) {
        title = "Error ${res?.statusCode ?? "c"}";
        msg = jsonDecode(res.body)["message"];
      } else {
        msg = jsonDecode(res.body)["message"];
      }
    } catch (e) {}

    if (context.mounted) {
      widgetInView = true;
      await showDialog<String>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext dContext) => AlertDialog(
          key: _networkDialogGlobalKey,
          backgroundColor: Colors.white,
          title: Text(
            title,
            textAlign: TextAlign.center,
            style: textStyleMediumBig(dContext).copyWith(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          content: Text(
            msg,
            textAlign: TextAlign.center,
            style: textStyleTiny(dContext).copyWith(color: Colors.black, fontWeight: FontWeight.normal),
          ),
          actions: <Widget>[
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ButtonStyle(padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 4))),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'OK',
                      style: textStyleTiny(dContext).copyWith(color: Colors.white, fontWeight: FontWeight.normal),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
      widgetInView = false;
    } else {
      SnackbarHelper.showSnackBar(SnackbarState.warning, e.toString());
    }
  }
}
