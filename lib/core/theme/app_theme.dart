import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_color.dart';

class AppTheme {
  const AppTheme._();

  static const Color primaryColor = AppColor.primary;
  static const Color primaryLight = AppColor.primaryLight;
  static const Color primaryDark = AppColor.primaryDark;

  static const Color accentMint = AppColor.accentMint;
  static const Color secondaryColor = AppColor.secondary;
  static const Color errorColor = AppColor.error;
  static const Color hintPeach = AppColor.hintPeach;
  static const Color alertBlue = AppColor.alertBlue;

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [AppColor.primary, Color(0xFF8BBF9D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Color backgroundLight = AppColor.backgroundLight;
  static const Color surfaceColor = AppColor.surface;

  static const Color textPrimary = AppColor.textPrimary;
  static const Color textSecondary = AppColor.textSecondary;

  static const double cardRadius = 16;
  static const double cardBorderWidth = 1;
  static const Color cardBorderColor = AppColor.cardBorder;

  static BorderRadius get cardBorderRadius => BorderRadius.circular(cardRadius);

  static Border get cardBorder =>
      Border.all(color: cardBorderColor, width: cardBorderWidth);

  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: AppColor.deepNavy.withValues(alpha: 0.08),
      blurRadius: 18,
      offset: const Offset(0, 8),
    ),
  ];

  static BoxDecoration get cardDecoration => BoxDecoration(
    color: surfaceColor,
    borderRadius: cardBorderRadius,
    border: cardBorder,
    boxShadow: cardShadow,
  );

  static BoxDecoration whiteCardDecoration({
    BorderRadius? borderRadius,
    Border? border,
    List<BoxShadow>? boxShadow,
  }) => BoxDecoration(
    color: Colors.white,
    borderRadius: borderRadius ?? cardBorderRadius,
    border: border ?? cardBorder,
    boxShadow: boxShadow ?? cardShadow,
  );

  static List<BoxShadow> get softShadow => cardShadow;

  static ThemeData get lightTheme {
    final baseTextTheme = const TextTheme(
      displayLarge: TextStyle(
        color: textPrimary,
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: TextStyle(
        color: textPrimary,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: TextStyle(
        color: textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w800,
      ),
      bodyLarge: TextStyle(
        color: textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      bodySmall: TextStyle(
        color: textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.normal,
      ),
      bodyMedium: TextStyle(color: textSecondary, fontSize: 14),
    );

    final textTheme = GoogleFonts.notoSansDevanagariTextTheme(baseTextTheme);

    return ThemeData(
      useMaterial3: true,
      fontFamily: GoogleFonts.notoSansDevanagari().fontFamily,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        error: errorColor,
        surface: surfaceColor,
      ),
      scaffoldBackgroundColor: backgroundLight,
      appBarTheme:
          const AppBarTheme(
            backgroundColor: backgroundLight,
            elevation: 0,
            centerTitle: true,
            systemOverlayStyle: SystemUiOverlayStyle.dark,
            iconTheme: IconThemeData(color: textPrimary),
          ).copyWith(
            titleTextStyle: GoogleFonts.notoSansDevanagari(
              color: textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 3,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: cardBorderRadius,
          side: const BorderSide(
            color: cardBorderColor,
            width: cardBorderWidth,
          ),
        ),
        shadowColor: AppColor.deepNavy.withValues(alpha: 0.12),
        surfaceTintColor: Colors.transparent,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          textStyle: GoogleFonts.notoSansDevanagari(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          textStyle: GoogleFonts.notoSansDevanagari(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: errorColor),
        ),
      ),
    );
  }
}
