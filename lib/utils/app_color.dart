import 'package:flutter/material.dart';

class AppColor {
  static const Color primary = Color(0xFF4F9874);
  static const Color primarySoft = Color(0xFF2F7052);
  static const Color primaryExtraSoft = Color(0xFFEAF4ED);
  static const Color secondary = Color(0xFF26352C);
  static const Color secondarySoft = Color(0xFF7C8B81);
  static const Color secondaryExtraSoft = Color(0xFFDCE7DF);
  static const Color error = Color(0xFFC94F4F);
  static const Color success = Color(0xFF39835C);
  static const Color warning = Color(0xFFD28A3D);
  static const Color background = Color(0xFFF7FAF7);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primarySoft],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}