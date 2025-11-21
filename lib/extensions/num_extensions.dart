import 'package:flutter/services.dart';
import 'package:fx_helper/formatter_helper.dart';
import 'package:fx_helper/snackbar_helper.dart';

extension NumExtensions on num {
  // void copyToClipboard() {
  //   Clipboard.setData(ClipboardData(text: toString()));
  //   SnackbarHelper.showSnackBar(SnackbarState.success, "Copied to Clipboard");
  // }
  void copyToClipboard() {
    var s = toString();
    Clipboard.setData(ClipboardData(text: s));
    String t = "";
    if (s.length > 20) {
      t = "${s.substring(0, 20)}...";
    } else {
      t = s;
    }
    SnackbarHelper.showSnackBar(SnackbarState.success, "$t Copied to Clipboard");
  }

  String toRp() {
    return FormatterHelper.formatRupiah(this);
  }
}

extension DateTimeExtensions on DateTime {
  String timeUntil({DateTime? until}) {
    // Duration d = ().difference(this);
    Duration d = difference(until ?? DateTime.now());
    // print(d);
    int s = d.inSeconds.abs();
    int h = (s / 3600).toInt();
    int m = ((s -= (h * 3600)) / 60).toInt();
    s -= m * 60;
    return "${h.toString().padLeft(2, "0")}:${m.toString().padLeft(2, "0")}:${s.toString().padLeft(2, "0")}";
    // return "$h$m$s";
  }
}
