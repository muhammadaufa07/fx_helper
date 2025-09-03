import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class FormatterHelper {
  static String formatRp(int price) {
    var formatter = NumberFormat('###,###', 'id');
    return "Rp ${formatter.format((price))}";
  }

  static String formatRpDouble(double price) {
    var formatter = NumberFormat('###,###', 'id');
    return "Rp ${formatter.format((price))}";
  }

  static String formatDatedMy(String date) {
    var dateTime = DateTime.tryParse(date);
    if (dateTime == null) {
      return "";
    }
    return DateFormat(('d-M-yyyy')).format(dateTime);
  }

  static String formateDateEEEDDMMMYYYY(String date) {
    var dateTime = DateTime.tryParse(date);
    if (dateTime == null) {
      return "";
    }
    return DateFormat('E, dd MMM yyyy').format(dateTime);
  }

  static String formatDateDDMMMYYYYHHMM(String date) {
    var dateTime = DateTime.tryParse(date);
    if (dateTime == null) {
      return "";
    }
    return DateFormat('dd MMM yyyy HH:mm:ss').format(dateTime);
  }

  static String formatDateEEEEdMMMy(String date) {
    var dateTime = DateTime.tryParse(date);
    if (dateTime == null) {
      return "";
    }
    return DateFormat('EEEE, d MMMM y').format(dateTime);
  }

  static String formatDateEEEEddMMMMyyyy(String date) {
    var dateTime = DateTime.tryParse(date);
    if (dateTime == null) {
      return "";
    }
    return DateFormat('EEEE, dd MMMM yyyy').format(dateTime);
  }

  static String formatDateToTimeHHMMss(String date) {
    if (date == "") {
      return "";
    }
    var dateTime = DateTime.tryParse(date);
    if (dateTime == null) {
      return "";
    }
    return DateFormat('HH:mm:ss').format(dateTime);
  }

  static String formatDateToTimeHHmm(String date) {
    if (date == "") {
      return "";
    }
    var dateTime = DateTime.tryParse(date);
    if (dateTime == null) {
      return "";
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

  // static String formatDateYYYYMMdd(String date) {
  //   var dateTime = DateTime.tryParse(date);
  //   if (dateTime == null) {
  //     return "";
  //   }
  //   return DateFormat(('yyyy-MM-dd')).format(dateTime);
  // }

  // static String formateDateDayMonthYear(String date) {
  //   if (date.isEmpty) {
  //     return "";
  //   }
  //   var dateTime = DateTime.tryParse(date);
  //   if (dateTime == null) {
  //     return "";
  //   }
  //   return DateFormat('dd MMM yyyy').format(dateTime);
  // }

  // static TextEditingValue formatTextEditingValue(String text, TextEditingValue oldValue) {
  //   if (text.isEmpty) return oldValue.copyWith(text: '');

  //   try {
  //     // Remove non-numeric characters for parsing
  //     String cleanedText = text.replaceAll(RegExp(r'[^0-9]'), '');

  //     // Parse to integer and reformat
  //     int value = int.parse(cleanedText);
  //     String formatted = formatRp(value);

  //     // Calculate new caret position
  //     int newCursorPosition = formatted.length - (text.length - oldValue.selection.end);
  //     return TextEditingValue(
  //       text: formatted,
  //       selection: TextSelection.collapsed(offset: newCursorPosition),
  //     );
  //   } catch (e) {
  //     return oldValue; // Return old value if parsing fails
  //   }
  // }

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

  static int parseCurrency(String formattedText) {
    String cleanedText = formattedText.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(cleanedText) ?? 0;
  }

  // static String getMonthName(int monthNumber) {
  //   List<String> monthNames = [
  //     '', // index ke-0 dikosongkan biar index 1 = Januari
  //     'Januari',
  //     'Februari',
  //     'Maret',
  //     'April',
  //     'Mei',
  //     'Juni',
  //     'Juli',
  //     'Agustus',
  //     'September',
  //     'Oktober',
  //     'November',
  //     'Desember',
  //   ];

  //   if (monthNumber < 1 || monthNumber > 12) return 'Bulan tidak valid';
  //   return monthNames[monthNumber];
  // }
}
