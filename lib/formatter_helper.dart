import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class FormatterHelper {
  static final String _errorMessage = "Date Error";

  // ORIGINAL: formatRp / formatRpDouble
  /// Format value into Indonesian Rupiah (e.g., `Rp25.000`).
  static String formatRupiah(num? value) {
    if (value == null) return "Rp0";
    final formatter = NumberFormat.currency(locale: "id_ID", symbol: "Rp", decimalDigits: 0);
    return formatter.format(value);
  }

  // ORIGINAL: formatDatedMy
  /// Format date into `d-M-yyyy` (e.g., `5-9-2025`).
  static String formatDateDMY(DateTime? date) {
    if (date == null) return _errorMessage;
    return DateFormat('d-M-yyyy', 'id').format(date);
  }

  // ORIGINAL: formateDateEEEDDMMMYYYY
  /// Format date into `E, dd MMM yyyy` (e.g., `Sen, 15 Sep 2025`).
  static String formatDateShortWeekday(DateTime? date) {
    if (date == null) return _errorMessage;
    return DateFormat('E, dd MMM yyyy', 'id').format(date);
  }

  // ORIGINAL: formatDateDDMMMYYYYHHMM
  /// Format datetime into `dd MMM yyyy HH:mm:ss` (e.g., `15 Sep 2025 14:30:00`).
  static String formatDateWithTime(DateTime? date) {
    if (date == null) return _errorMessage;
    return DateFormat('dd MMM yyyy HH:mm:ss', 'id').format(date);
  }

  // ORIGINAL: formatDateEEEEdMMMy
  /// Format date into long form `EEEE, d MMMM y` (e.g., `Senin, 15 September 2025`).
  static String formatDateFull(DateTime? date) {
    if (date == null) return _errorMessage;
    return DateFormat('EEEE, d MMMM y', 'id').format(date);
  }

  // ORIGINAL: formatDateEEEEddMMMMyyyy
  /// Format date into `EEEE, dd MMMM yyyy` (e.g., `Senin, 15 September 2025`).
  static String formatDateFullWithDay(DateTime? date) {
    if (date == null) return _errorMessage;
    return DateFormat('EEEE, dd MMMM yyyy', 'id').format(date);
  }

  // ORIGINAL: formatDateToTimeHHMMss
  /// Format time into `HH:mm:ss` (e.g., `14:30:45`).
  static String formatTimeWithSeconds(DateTime? date) {
    if (date == null) return _errorMessage;
    return DateFormat('HH:mm:ss').format(date);
  }

  // ORIGINAL: formatDateToTimeHHmm
  /// Format time into `HH:mm` (e.g., `14:30`).
  static String formatTime(DateTime? date) {
    if (date == null) return _errorMessage;
    return DateFormat('HH:mm').format(date);
  }

  // ORIGINAL: formatDateYYYYMMdd
  /// Format date into `yyyy-MM-dd` (ISO-like).
  static String formatDateISO(DateTime? date) {
    if (date == null) return _errorMessage;
    return DateFormat('yyyy-MM-dd').format(date);
  }

  // ORIGINAL: formateDateDayMonthYear
  /// Format date into `dd MMM yyyy` (e.g., `15 Sep 2025`).
  static String formatDateReadable(DateTime? date) {
    if (date == null) return _errorMessage;
    return DateFormat('dd MMM yyyy', 'id').format(date);
  }

  // ORIGINAL: formatTextEditingValue
  static TextEditingValue formatTextEditingValue(String text, TextEditingValue oldValue) {
    if (text.isEmpty) return oldValue.copyWith(text: '');

    try {
      String cleanedText = text.replaceAll(RegExp(r'[^0-9]'), '');
      int value = int.parse(cleanedText);
      String formatted = formatRupiah(value);

      int newCursorPosition = formatted.length - (text.length - oldValue.selection.end);
      return TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: newCursorPosition),
      );
    } catch (_) {
      return oldValue;
    }
  }

  // ORIGINAL: currencyInputFormatter
  static TextInputFormatter get currencyInputFormatter => TextInputFormatter.withFunction((oldValue, newValue) {
    if (newValue.text.isEmpty) {
      return TextEditingValue(text: '', selection: const TextSelection.collapsed(offset: 0));
    }

    String numeric = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (numeric.isEmpty) return TextEditingValue(text: '');

    double value = double.parse(numeric);
    String formatted = formatRupiah(value);

    int cursorPosition = formatted.length - (numeric.length - newValue.selection.baseOffset);
    cursorPosition = cursorPosition.clamp(0, formatted.length);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: cursorPosition),
    );
  });

  // ORIGINAL: parseCurrency
  static int parseCurrency(String text) {
    String cleaned = text.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(cleaned) ?? 0;
  }

  // ORIGINAL: getMonthName
  static String getMonthName(int month) {
    const monthNames = [
      '',
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
    return (month >= 1 && month <= 12) ? monthNames[month] : 'Bulan tidak valid';
  }
}
