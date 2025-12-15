import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fx_helper/network/fx_network.dart';
import 'package:fx_helper/snackbar_helper.dart';
import 'package:fx_helper/widgets/fx_theme.dart';
import 'package:http/http.dart' as http;

class NetMsgDialog {
  static bool widgetInView = false;
  static final GlobalKey _networkDialogGlobalKey = GlobalKey();

  static void handleError(BuildContext context, e, http.Response? res) async {
    // print(e);
    // print(res);
    print("_networkDialogGlobalKey.currentWidget");
    print(_networkDialogGlobalKey.currentWidget);
    if (widgetInView || _networkDialogGlobalKey.currentWidget != null) return;

    String title = "Error";
    String msg = "Something Went Wrong";
    try {
      if (e is SocketException) {
        title = "Socket Exception";
        msg = "No Connection, Please check your connection";
      } else if (e is FormatException) {
        title = "Format Exception";
        msg = "Error while Parsing Data";
      } else if (e is TimeoutException) {
        title = "Ops! Timeout";
        msg = "Please check your connection";
      } else if (e is ApiException) {
        title = "Error ${res?.statusCode ?? res?.reasonPhrase ?? "e70"}";
        if (e.message != "") {
          msg = e.message;
        } else {
          msg = jsonDecode(res?.body ?? "")["message"] ?? e.toString() ?? "e71";
        }
      } else if (e is http.ClientException) {
        title = "Client Exception";
        msg = "Please check your connection";
      } else {
        if (res != null && res.body.toString().isNotEmpty) {
          msg = jsonDecode(res.body)["message"];
        } else {
          msg = e.toString();
        }
      }
    } catch (e) {
      msg = "e72: ${e.toString()}";
    }

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
                // Expanded(
                //   child: ElevatedButton(
                //     style: ButtonStyle(padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 4))),
                //     onPressed: () {
                //       // if (onReload != null && onReload is Function) {
                //       //   onReload.call();
                //       // }
                //       // Navigator.pop(context);
                //     },
                //     child: Text(
                //       'RELOAD',
                //       style: textStyleTiny(dContext).copyWith(color: Colors.white, fontWeight: FontWeight.normal),
                //     ),
                //   ),
                // ),
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
