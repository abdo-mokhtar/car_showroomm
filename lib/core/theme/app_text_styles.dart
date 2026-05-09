import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  // ✅ Headlines
  static const TextStyle h1 = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 28,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle h2 = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 22,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle h3 = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  // ✅ Body
  static const TextStyle body = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 14,
  );

  static const TextStyle bodySmall = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 12,
  );

  // ✅ Labels
  static const TextStyle label = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 13,
  );

  // ✅ Money
  static const TextStyle money = TextStyle(
    color: AppColors.primary,
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle moneyGreen = TextStyle(
    color: AppColors.success,
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  // ✅ Button
  static const TextStyle button = TextStyle(
    color: Colors.white,
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );
}
