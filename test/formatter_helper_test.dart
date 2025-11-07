import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fx_helper/formatter_helper.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  // Ensure locale date formatting is ready
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  group('Currency Formatting', () {
    test('formatRupiah handles null', () {
      expect(FormatterHelper.formatRupiah(null), "Rp0");
    });

    test('formatRupiah formats integer', () {
      expect(FormatterHelper.formatRupiah(25000), "Rp25.000");
    });

    test('formatRupiah formats double', () {
      expect(FormatterHelper.formatRupiah(25000.75), "Rp25.001");
    });

    test('parseCurrency returns correct integer', () {
      expect(FormatterHelper.parseCurrency("Rp25.000"), 25000);
    });
  });

  group('Date Formatting', () {
    final date = DateTime(2025, 9, 15, 14, 30, 45); // 15 Sept 2025

    test('formatDateDMY', () {
      expect(FormatterHelper.formatDateDMY(date), "15-9-2025");
    });

    test('formatDateShortWeekday', () {
      expect(FormatterHelper.formatDateShortWeekday(date), "Sen, 15 Sep 2025");
    });

    test('formatDateWithTime', () {
      expect(FormatterHelper.formatDateWithTime(date), "15 Sep 2025 14:30:45");
    });

    test('formatDateFull', () {
      expect(FormatterHelper.formatDateFull(date), "Senin, 15 September 2025");
    });

    test('formatDateFullWithDay', () {
      expect(FormatterHelper.formatDateFullWithDay(date), "Senin, 15 September 2025");
    });

    test('formatDateISO', () {
      expect(FormatterHelper.formatDateISO(date), "2025-09-15");
    });

    test('formatDateReadable', () {
      expect(FormatterHelper.formatDateReadable(date), "15 Sep 2025");
    });

    test('Null dates return Date Error', () {
      expect(FormatterHelper.formatDateDMY(null), "Date Error");
      expect(FormatterHelper.formatDateFull(null), "Date Error");
      expect(FormatterHelper.formatTime(null), "Date Error");
    });
  });

  group('Time Formatting', () {
    final date = DateTime(2025, 9, 15, 14, 30, 45);

    test('formatTimeWithSeconds', () {
      expect(FormatterHelper.formatTimeWithSeconds(date), "14:30:45");
    });

    test('formatTime', () {
      expect(FormatterHelper.formatTime(date), "14:30");
    });
  });

  group('Month Name', () {
    test('getMonthName returns correct month', () {
      expect(FormatterHelper.getMonthName(1), "Januari");
      expect(FormatterHelper.getMonthName(12), "Desember");
    });

    test('getMonthName returns error on invalid input', () {
      expect(FormatterHelper.getMonthName(0), "Bulan tidak valid");
      expect(FormatterHelper.getMonthName(13), "Bulan tidak valid");
    });
  });

  group('Currency Input Formatter (TextEditingValue)', () {
    test('Formats input and maintains cursor position', () {
      const oldValue = TextEditingValue(text: "Rp1.000", selection: TextSelection.collapsed(offset: 7));
      const newValue = TextEditingValue(text: "Rp1.0002", selection: TextSelection.collapsed(offset: 8));

      final result = FormatterHelper.currencyInputFormatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, "Rp10.002"); // Re-formatted
      expect(result.selection.baseOffset, result.text.length); // Cursor at end
    });

    test('Empty input resets to blank', () {
      const oldValue = TextEditingValue(text: "Rp500");
      const newValue = TextEditingValue(text: "");
      final result = FormatterHelper.currencyInputFormatter.formatEditUpdate(oldValue, newValue);
      expect(result.text, "");
    });
  });
}
