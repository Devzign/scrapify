import 'package:flutter/services.dart';

class IndianMobileFormatter extends TextInputFormatter {
  const IndianMobileFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;

    if (text.isEmpty) {
      return newValue;
    }

    if (!RegExp(r'^[6-9]').hasMatch(text[0])) {
      return oldValue;
    }

    return newValue;
  }
}
