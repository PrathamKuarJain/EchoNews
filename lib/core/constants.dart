import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFF000000); // pure black
  static const Color primary = Color(0xFF1D9BF0);    // X brand blue
  static const Color textMain = Color(0xFFE7E9EA);   // almost white
  static const Color textSecondary = Color(0xFF71767B); // grayish
  static const Color border = Color(0xFF2F3336);     // dark border gray
  static const Color white = Color(0xFF000000);      // overriding old white to act as card background (black)
}

class AppConstants {
  static const String perspectiveApiKey = "";
  static const String geminiApiKey = "";
}

class AppSpacing {
  static const double xs = 4.0;
  static const double s = 8.0;
  static const double m = 16.0;
  static const double l = 24.0;
  static const double xl = 32.0;
}

class Responsive {
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600;

  static bool isSmallPhone(BuildContext context) =>
      MediaQuery.of(context).size.width < 360;

  static double getWidth(BuildContext context) => MediaQuery.of(context).size.width;
  static double getHeight(BuildContext context) => MediaQuery.of(context).size.height;
}
