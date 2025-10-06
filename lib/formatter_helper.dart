import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class FormatterHelper {
  static final String _errorMessage = "Date Error";

  /// Format an integer into Indonesian Rupiah currency.
  ///
  /// Example:
  /// ```dart
  /// FormatterHelper.formatRp(25000); // "Rp25,000"
  /// ```
  static String formatRp(int? price) {
    if (price == null) {
      return "Rp0";
    }
    var formatter = NumberFormat('###,###', 'id');
    return "Rp${formatter.format((price))}";
  }

  /// Format a double into Indonesian Rupiah currency.
  ///
  /// Example:
  /// ```dart
  /// FormatterHelper.formatRpDouble(12345.67); // "Rp12,346"
  /// ```
  static String formatRpDouble(double? price) {
    if (price == null) {
      return "Rp0";
    }
    var formatter = NumberFormat('###,###', 'id');
    return "Rp${formatter.format((price))}";
  }

  /// Format a date into `d-M-yyyy` (e.g., `5-9-2025`).
  ///
  /// Returns `"Date Error"` if the input is null.
  ///
  /// Example:
  /// ```dart
  /// FormatterHelper.formatDatedMy(DateTime(2025, 9, 15)); // "15-9-2025"
  /// ```
  static String formatDatedMy(DateTime? dateTime) {
    if (dateTime == null) {
      return _errorMessage;
    }
    return DateFormat(('d-M-yyyy')).format(dateTime);
  }

  /// Format a date into `E, dd MMM yyyy` with Indonesian locale.
  /// Example output: `Sen, 15 Sep 2025`.
  ///
  /// Example:
  /// ```dart
  /// FormatterHelper.formateDateEEEDDMMMYYYY(DateTime(2025, 9, 15)); // "Sen, 15 Sep 2025"
  /// ```
  static String formateDateEEEDDMMMYYYY(DateTime? dateTime) {
    if (dateTime == null) {
      return "Date Error";
    }
    return DateFormat('E, dd MMM yyyy', 'id').format(dateTime);
  }

  /// Format a date into `dd MMM yyyy HH:mm:ss` (e.g., `15 Sep 2025 14:30:00`).
  ///
  /// Example:
  /// ```dart
  /// FormatterHelper.formatDateDDMMMYYYYHHMM(DateTime(2025, 9, 15, 14, 30)); // "15 Sep 2025 14:30:00"
  /// ```
  static String formatDateDDMMMYYYYHHMM(DateTime? dateTime) {
    if (dateTime == null) {
      return "Date Error";
    }
    return DateFormat('dd MMM yyyy HH:mm:ss').format(dateTime);
  }

  /// Format a date into `EEEE, d MMMM y` with Indonesian locale.
  /// Example output: `Senin, 15 September 2025`.
  ///
  /// Example:
  /// ```dart
  /// FormatterHelper.formatDateEEEEdMMMy(DateTime(2025, 9, 15)); // "Senin, 15 September 2025"
  /// ```
  static String formatDateEEEEdMMMy(DateTime? dateTime) {
    if (dateTime == null) {
      return "Date Error";
    }
    return DateFormat('EEEE, d MMMM y', 'id').format(dateTime);
  }

  /// Format a date into `EEEE, dd MMMM yyyy` with Indonesian locale.
  /// Example output: `Senin, 15 September 2025`.
  ///
  /// Example:
  /// ```dart
  /// FormatterHelper.formatDateEEEEddMMMMyyyy(DateTime(2025, 9, 15)); // "Senin, 15 September 2025"
  /// ```
  static String formatDateEEEEddMMMMyyyy(DateTime? dateTime) {
    if (dateTime == null) {
      return "Date Error";
    }
    return DateFormat('EEEE, dd MMMM yyyy', 'id').format(dateTime);
  }

  /// Format a time into `HH:mm:ss` (e.g., `14:30:45`).
  ///
  /// Example:
  /// ```dart
  /// FormatterHelper.formatDateToTimeHHMMss(DateTime(2025, 9, 15, 14, 30, 45)); // "14:30:45"
  /// ```
  static String formatDateToTimeHHMMss(DateTime? dateTime) {
    if (dateTime == null) {
      return "Date Error";
    }
    return DateFormat('HH:mm:ss').format(dateTime);
  }

  /// Format a time into `HH:mm` (e.g., `14:30`).
  ///
  /// Example:
  /// ```dart
  /// FormatterHelper.formatDateToTimeHHmm(DateTime(2025, 9, 15, 14, 30)); // "14:30"
  /// ```
  static String formatDateToTimeHHmm(DateTime? dateTime) {
    if (dateTime == null) {
      return "Date Error";
    }
    return DateFormat('HH:mm').format(dateTime);
  }

  // static String getHeaderFormattedDate() => "${DateFormat('E, dd MMM yyyy HH:mm:ss').format(DateTime.now())} +0700";
  // String formatDateDDMMMYYYY(String date) {
  //   var dateTime = DateTime.tryParse(date);
  //   if (dateTime == null) {
  //     return "";
  //   }
  //   return "${DateFormat('dd MMM yyyy').format(dateTime)} +0700";
  // }

  /// Format a date into `yyyy-MM-dd` (e.g., `2025-09-15`).
  ///
  /// Example:
  /// ```dart
  /// FormatterHelper.formatDateYYYYMMdd(DateTime(2025, 9, 15)); // "2025-09-15"
  /// ```
  static String formatDateYYYYMMdd(DateTime? dateTime) {
    if (dateTime == null) {
      return "Date Error";
    }
    return DateFormat(('yyyy-MM-dd')).format(dateTime);
  }

  static String formateDateDayMonthYear(DateTime? dateTime) {
    if (dateTime == null) {
      return "Date Error";
    }
    return DateFormat('dd MMM yyyy').format(dateTime);
  }

  static TextEditingValue formatTextEditingValue(String text, TextEditingValue oldValue) {
    if (text.isEmpty) return oldValue.copyWith(text: '');

    try {
      // Remove non-numeric characters for parsing
      String cleanedText = text.replaceAll(RegExp(r'[^0-9]'), '');

      // Parse to integer and reformat
      int value = int.parse(cleanedText);
      String formatted = formatRp(value);

      // Calculate new caret position
      int newCursorPosition = formatted.length - (text.length - oldValue.selection.end);
      return TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: newCursorPosition),
      );
    } catch (e) {
      return oldValue; // Return old value if parsing fails
    }
  }

  /// A custom [TextInputFormatter] for currency input in Indonesian Rupiah format.
  ///
  /// It automatically adds "Rp" and formats numbers as the user types.
  ///
  /// Example:
  /// ```dart
  /// TextField(
  ///   inputFormatters: [FormatterHelper.currencyInputFormatter],
  ///   keyboardType: TextInputType.number,
  /// )
  /// ```
  static TextInputFormatter get currencyInputFormatter => TextInputFormatter.withFunction((oldValue, newValue) {
    if (newValue.text.isEmpty) {
      return TextEditingValue(text: '', selection: TextSelection.collapsed(offset: 0));
    }

    // Hapus semua karakter kecuali angka
    String cleanValue = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (cleanValue.isEmpty) {
      return TextEditingValue(text: '', selection: TextSelection.collapsed(offset: 0));
    }

    // Konversi ke angka
    double value = double.parse(cleanValue);

    // Format ulang angka menjadi Rupiah
    String formattedText = NumberFormat.currency(locale: "id_ID", symbol: "Rp", decimalDigits: 0).format(value);

    // Hitung perbedaan panjang sebelum dan sesudah format
    int newCursorPosition = formattedText.length - (cleanValue.length - newValue.selection.baseOffset);

    // Pastikan posisi kursor tetap dalam batas teks
    newCursorPosition = newCursorPosition.clamp(0, formattedText.length);

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: newCursorPosition),
    );
  });

  /// Parse a Rupiah formatted string back into an integer.
  ///
  /// Example:
  /// ```dart
  /// FormatterHelper.parseCurrency("Rp12,345"); // 12345
  /// ```
  static int parseCurrency(String formattedText) {
    String cleanedText = formattedText.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(cleanedText) ?? 0;
  }

  /// Get the name of a month based on its number.
  ///
  /// Example:
  /// ```dart
  /// FormatterHelper.getMonthName(1); // "Januari"
  /// ```
  static String getMonthName(int monthNumber) {
    List<String> monthNames = [
      '', // index 0 is not used, so index 1 is Januari
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    if (monthNumber < 1 || monthNumber > 12) return 'Bulan tidak valid';
    return monthNames[monthNumber];
  }
}
