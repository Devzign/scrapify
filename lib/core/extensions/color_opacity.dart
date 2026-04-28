import 'package:flutter/material.dart';

extension ColorOpacity on Color {
  Color o(double opacity) {
    return withValues(alpha: opacity);
  }
}
