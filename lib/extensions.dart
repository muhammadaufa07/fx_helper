import 'package:fx_helper/regexp_helper.dart';

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

  bool isUrl() {
    return RegexpHelper.isUrl(this);
  }
}
