import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryPurple = Color(0xFF6A5AE0);
  static const Color secondaryPurple = Color(0xFF5648B8);
  static const Color accentGreen = Color(0xFFCCFF00);
  static const Color textWhite = Colors.white;
  static const Color textBlack = Colors.black87;
  static const Color bgWhite = Colors.white;
}
class AppTextStyles {
  static const TextStyle headerName = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textWhite,
  );

  static const TextStyle headerDepartment = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Colors.white70,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textBlack,
  );

  static const TextStyle cardTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.textBlack,
  );
}