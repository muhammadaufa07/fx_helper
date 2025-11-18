import 'package:flutter/services.dart';
import 'package:fx_helper/regexp_helper.dart';
import 'package:fx_helper/snackbar_helper.dart';
import 'package:html/parser.dart';

extension StringExtensions on String {
  /// Capitalizes the **first letter of each word** in the string.
  ///
  /// This method:
  /// - Splits the text by spaces.
  /// - Converts the **first character** of each word to uppercase.
  /// - Converts the **remaining characters** of the word to lowercase.
  /// - Joins the words back together with spaces.
  ///
  /// Example:
  /// ```dart
  /// final name = 'john DOE';
  /// print(name.capitalize()); // Output: 'John Doe'
  /// ```
  ///
  /// Returns a new [String] with each word capitalized.
  String capitalize() {
    return split(' ')
        .map((word) {
          if (word.isEmpty) return '';
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  String capitalizeFirstWord() {
    if (length == 0) {
      return "";
    } else if (length == 1) {
      return this[0].toUpperCase();
    }
    return this[0].toUpperCase() + substring(1, length);
  }

  bool isUrl() {
    return RegexpHelper.isUrl(this);
  }

  String stripHtml() {
    String t = "";
    try {
      final doc = parse(this);
      t = parse(doc.body?.text).documentElement?.text ?? "";
    } catch (e) {
      print(e.toString());
    }
    return t;
  }

  /// highlight matching text. use in HtmlView
  String htmlHighlight(String term, {bool caseSensitive = false}) {
    return replaceAll(RegExp(term, caseSensitive: caseSensitive), "<mark>$term</mark>");
  }

  void copyToClipboard() {
    Clipboard.setData(ClipboardData(text: this));
    String t = "";
    if (length > 20) {
      t = "${substring(0, 20)}...";
    } else {
      t = this;
    }
    SnackbarHelper.showSnackBar(SnackbarState.success, "$t Copied to Clipboard");
  }
}
