import 'package:flutter/services.dart';
import 'package:fx_helper/formatter_helper.dart';
import 'package:fx_helper/snackbar_helper.dart';

extension NumExtensions on num {
  void copyToClipboard() {
    Clipboard.setData(ClipboardData(text: toString()));
    SnackbarHelper.showSnackBar(SnackbarState.success, "Copied to Clipboard");
  }

  String toRp() {
    return FormatterHelper.formatRupiah(this);
  }
}
