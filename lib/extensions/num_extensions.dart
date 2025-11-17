import 'package:fx_helper/formatter_helper.dart';

extension NumExtensions on num {
  String toRp() {
    return FormatterHelper.formatRupiah(this);
  }
}
