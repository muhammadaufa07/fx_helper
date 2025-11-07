import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fx_helper/formatter_helper.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
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
    final dateTime = DateTime(2025, 9, 15, 14, 30, 45);
    final dateOnly = DateTime(2025, 9, 15, 14, 30);

    test('formatDateShortWeekdayWithTime', () {
      expect(FormatterHelper.formatDateShortWeekdayWithTime(dateTime), "Sen, 15 Sep 2025 14:30:45");
    });

    test('formatDateDMYWithTime', () {
      expect(FormatterHelper.formatDateDMYWithTime(dateOnly), "15-09-2025 14:30");
    });

    test('formatDateDMY', () {
      expect(FormatterHelper.formatDateDMY(dateTime), "15-9-2025");
    });

    test('formatDateShortWeekday', () {
      expect(FormatterHelper.formatDateShortWeekday(dateTime), "Sen, 15 Sep 2025");
    });

    test('formatDateWithTime', () {
      expect(FormatterHelper.formatDateWithTime(dateTime), "15 Sep 2025 14:30:45");
    });

    test('formatDateFull', () {
      expect(FormatterHelper.formatDateFull(dateTime), "Senin, 15 September 2025");
    });

    test('formatDateFullWithDay', () {
      expect(FormatterHelper.formatDateFullWithDay(dateTime), "Senin, 15 September 2025");
    });

    test('formatDateISO', () {
      expect(FormatterHelper.formatDateISO(dateTime), "2025-09-15");
    });

    test('formatDateReadable', () {
      expect(FormatterHelper.formatDateReadable(dateTime), "15 Sep 2025");
    });

    test('Null dates return empty string', () {
      expect(FormatterHelper.formatDateDMY(null), "");
      expect(FormatterHelper.formatDateFull(null), "");
      expect(FormatterHelper.formatTime(null), "");
    });
  });

  group('Time Formatting', () {
    final dateTime = DateTime(2025, 9, 15, 14, 30, 45);

    test('formatTimeWithSeconds', () {
      expect(FormatterHelper.formatTimeWithSeconds(dateTime), "14:30:45");
    });

    test('formatTime', () {
      expect(FormatterHelper.formatTime(dateTime), "14:30");
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

  group('Currency Input Formatter', () {
    test('Formats input and maintains cursor position', () {
      const oldValue = TextEditingValue(text: "Rp1.000", selection: TextSelection.collapsed(offset: 7));
      const newValue = TextEditingValue(text: "Rp1.0002", selection: TextSelection.collapsed(offset: 8));

      final result = FormatterHelper.currencyInputFormatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, "Rp10.002");
      expect(result.selection.baseOffset, result.text.length);
    });

    test('Empty input resets to blank', () {
      const oldValue = TextEditingValue(text: "Rp500");
      const newValue = TextEditingValue(text: "");
      final result = FormatterHelper.currencyInputFormatter.formatEditUpdate(oldValue, newValue);
      expect(result.text, "");
    });
  });

  group('TextEditingValue Formatter', () {
    test('formats numeric string correctly', () {
      final oldValue = TextEditingValue(text: "");
      final result = FormatterHelper.formatTextEditingValue("25000", oldValue);
      expect(result.text, "Rp25.000");
    });

    test('returns oldValue for invalid input', () {
      final oldValue = TextEditingValue(text: "Rp10.000");
      final result = FormatterHelper.formatTextEditingValue("abc", oldValue);
      expect(result.text, oldValue.text);
    });
  });
}
