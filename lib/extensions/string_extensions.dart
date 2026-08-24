import 'dart:math';

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
    if (term.length == 1) {
      try {
        StringBuffer buf = StringBuffer();
        String x = term.toUpperCase();
        String y = term.toLowerCase();
        for (int i = 0; i < length; i += 1) {
          if (term[i] == x) {
            buf.write("<mark>$x</mark>");
          } else if (term[i] == y) {
            buf.write("<mark>$y</mark>");
          }
        }
        return buf.toString();
      } catch (e) {
        print(e.toString());
      }
    }
    try {
      List<RegExpMatch> t = RegExp(term, caseSensitive: false).allMatches(this).toList();
      String k = this;
      for (int i = 0; i < t.length; i += 1) {
        var z = substring(t[i].start, t[i].end);
        k = k.replaceRange(t[i].start + (i * 13), t[i].end + (i * 13), "<mark>$z</mark>");
      }
      return k;
    } catch (e) {
      print(e.toString());
    }
    // fall back to old way.
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
