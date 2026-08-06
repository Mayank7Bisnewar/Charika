import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static final heading = GoogleFonts.poppins(
    fontSize: 30,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static final title = GoogleFonts.poppins(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static final body = GoogleFonts.poppins(
    fontSize: 16,
    color: AppColors.textPrimary,
  );

  static final caption = GoogleFonts.poppins(
    fontSize: 13,
    color: AppColors.textSecondary,
  );
}