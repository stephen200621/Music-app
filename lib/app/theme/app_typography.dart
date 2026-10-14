import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  AppTypography._();

  static TextStyle get displayLarge => GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: AppColors.mainText,
        letterSpacing: -0.5,
      );

  static TextStyle get displayMedium => GoogleFonts.inter(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: AppColors.mainText,
        letterSpacing: -0.3,
      );

  static TextStyle get screenTitle => GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.mainText,
        letterSpacing: -0.2,
      );

  static TextStyle get sectionHeading => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.mainText,
        letterSpacing: -0.1,
      );

  static TextStyle get songTitleLarge => GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.mainText,
        height: 1.2,
      );

  static TextStyle get songTitleMedium => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.mainText,
      );

  static TextStyle get artistNameLarge => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.secondaryText,
      );

  static TextStyle get artistNameMedium => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.secondaryText,
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: AppColors.secondaryText,
        height: 1.4,
      );

  static TextStyle get metadata => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.subtleText,
        letterSpacing: 0.2,
      );

  static TextStyle get controlLabel => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.mainText,
        letterSpacing: 0.4,
      );

  static TextStyle get badgeText => GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: AppColors.mainText,
        letterSpacing: 0.5,
      );
}
