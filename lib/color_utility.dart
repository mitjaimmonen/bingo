import 'package:flutter/material.dart';

extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `false`).
  String toHexString({bool leadingHashSign = false}) =>
      '${leadingHashSign ? '#' : ''}'
      '${(a * 255).toInt().toRadixString(16).padLeft(2, '0')}'
      '${(r * 255).toInt().toRadixString(16).padLeft(2, '0')}'
      '${(g * 255).toInt().toRadixString(16).padLeft(2, '0')}'
      '${(b * 255).toInt().toRadixString(16).padLeft(2, '0')}';

  // This is used because flutter deprecated using Color.value
  /// Returns the int value of the color
  int toInt() {
    return int.parse(toHexString(), radix: 16);
  }
}
