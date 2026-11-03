import 'package:flutter/material.dart';

class Responsive {
  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.shortestSide >= 600;
  }

  static double horizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 800) return (width - 700) / 2;
    if (width > 500) return 24.0;
    return 16.0;
  }
}

