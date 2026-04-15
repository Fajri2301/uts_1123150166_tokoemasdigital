import 'package:flutter/material.dart';

extension HexColor on String {
  Color toColor() {
    return Color(int.parse(replaceFirst('#', '0xff')));
  }
}
