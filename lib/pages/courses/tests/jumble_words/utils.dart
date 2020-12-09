import 'dart:ui';
import 'package:flutter/widgets.dart';

Color nameToColor(String name) {
  if (name.length > 1) {
    final int hash = name.hashCode & 0xfff;
    final double hue = (360.0 * hash / (1 << 4)) % 360.0;
    return HSVColor.fromAHSV(1, hue, .7, 1).toColor();
  } else {
    return Color(0xFF171717);
  }
}
