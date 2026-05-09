import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_color.dart';

/// Scrapify theme — eco/nature inspired.
///
/// Visual language:
///  - Warm cream background instead of pale-green-white (no more "wash")
///  - Solid white cards with soft warm shadow (proper figure/ground)
///  - Deep sage CTAs at full opacity (no more washed-out 92% alpha)
///  - Navy primary text from the brand logo
///  - Generous radii + clear elevation = modern, calm, on-brand
class AppTheme {
  const AppTheme._();

  // ---------------------------------------------------------------------------
  // COLORS — re-exposed under their old names so existing screens compile.
  // ---------------------------------------------------------------------------
  static const Color primaryColor = AppColor.primary;
  static const Color primaryLight = AppColor.primaryLight;
  static const Color primaryDark = AppColor.primaryDark;
  static const Color primarySurface = AppColor.primarySurface;

  static const Color accentMint = AppColor.accentMint;
  static const Color secondaryColor = AppColor.secondary;
  static const Color errorColor = AppColor.error;
  static const Color warningColor = AppColor.warning;
  static const Color successColor = AppColor.success;
  static const Color infoColor = AppColor.info;
  static const Color hintPeach = AppColor.hintPeach;
  static const Color alertBlue = AppColor.alertBlue;

  static const Color backgroundLight = AppColor.backgroundLight;
  static const Color backgroundCream = AppColor.backgroundCream;
  static const Color surfaceColor = AppColor.surface;

  static const Color textPrimary = AppColor.textPrimary;
  static const Color textSecondary = AppColor.textSecondary;
  static const Color textMuted = AppColor.textMuted;
  static const Color textOnPrimary = AppColor.textOnPrimary;

  static const Color glassHighlight = AppColor.glassHighlight;
  static const Color glassShadow = AppColor.glassShadow;

  static const Color hairline = AppColor.hairline;
  static const Color outline = AppColor.outline;

  static const Color brandNavy = AppColor.brandNavy;
  static const Color leafAccent = AppColor.leafAccent;

  // ---------------------------------------------------------------------------
  // SPACING — 4-pt scale.
  // ---------------------------------------------------------------------------
  static const double space4 = 4;
  static const double space8 = 8;
  static const double space12 = 12;
  static const double space16 = 16;
  static const double space20 = 20;
  static const double space24 = 24;
  static const double space32 = 32;
  static const double space40 = 40;

  // ---------------------------------------------------------------------------
  // RADII
  // ---------------------------------------------------------------------------
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 20;
  static const double radius2xl = 24;
  static const double radiusPill = 999;

  // Old name kept for back-compat.
  static const double cardRadius = 20;
  static const double cardBorderWidth = 1;
  static const Color cardBorderColor = AppColor.cardBorder;

  static BorderRadius get cardBorderRadius => BorderRadius.circular(cardRadius);
  static Border get cardBorder =>
      Border.all(color: cardBorderColor, width: cardBorderWidth);

  // ---------------------------------------------------------------------------
  // ELEVATION — soft warm shadows (no harsh black).
  // ---------------------------------------------------------------------------
  static List<BoxShadow> get e1 => const [
        BoxShadow(
          color: Color(0x0F0E2235), // navy at 6%
          blurRadius: 12,
          offset: Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get e2 => const [
        BoxShadow(
          color: Color(0x140E2235), // navy at 8%
          blurRadius: 24,
          offset: Offset(0, 10),
        ),
      ];

  static List<BoxShadow> get e3 => const [
        BoxShadow(
          color: Color(0x1F0E2235), // navy at 12%
          blurRadius: 36,
          offset: Offset(0, 18),
        ),
      ];

  /// Back-compat aliases.
  static List<BoxShadow> get cardShadow => e1;
  static List<BoxShadow> get softShadow => e1;

  // ---------------------------------------------------------------------------
  // GRADIENTS
  // ---------------------------------------------------------------------------
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [AppColor.primary, AppColor.primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient sageHeader = LinearGradient(
    colors: [AppColor.primary, AppColor.emeraldMoss],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient creamFade = LinearGradient(
    colors: [AppColor.backgroundCream, AppColor.backgroundLight],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ---------------------------------------------------------------------------
  // CARDS — solid white on cream, real shadow, real border.
  // ---------------------------------------------------------------------------
  static BoxDecoration get cardDecoration => BoxDecoration(
        color: surfaceColor,
        borderRadius: cardBorderRadius,
        border: Border.all(color: cardBorderColor, width: 1),
        boxShadow: e1,
      );

  static BoxDecoration whiteCardDecoration({
    BorderRadius? borderRadius,
    Border? border,
    List<BoxShadow>? boxShadow,
  }) =>
      BoxDecoration(
        color: surfaceColor,
        borderRadius: borderRadius ?? cardBorderRadius,
        border: border ?? Border.all(color: cardBorderColor, width: 1),
        boxShadow: boxShadow ?? e1,
      );

  /// Tinted sage card — for "highlighted" or "selected" sections.
  static BoxDecoration get sageCardDecoration => BoxDecoration(
        color: AppColor.primarySurface,
        borderRadius: cardBorderRadius,
        border: Border.all(color: AppColor.primaryLight, width: 1),
      );

  // ---------------------------------------------------------------------------
  // TYPOGRAPHY
  // ---------------------------------------------------------------------------
  static TextTheme _buildTextTheme() {
    final base = const TextTheme(
      displayLarge: TextStyle(
        color: textPrimary,
        fontSize: 34,
        fontWeight: FontWeight.w800,
        height: 1.15,
        letterSpacing: -0.5,
      ),
      displayMedium: TextStyle(
        color: textPrimary,
        fontSize: 26,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: -0.3,
      ),
      displaySmall: TextStyle(
        color: textPrimary,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        height: 1.25,
      ),
      headlineMedium: TextStyle(
        color: textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: TextStyle(
        color: textPrimary,
        fontSize: 17,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: TextStyle(
        color: textPrimary,
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(
        color: textPrimary,
        fontSize: 15,
        fontWeight: FontWeight.w500,
        height: 1.45,
      ),
      bodyMedium: TextStyle(
        color: textSecondary,
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 1.45,
      ),
      bodySmall: TextStyle(
        color: textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
    );

    return GoogleFonts.poppinsTextTheme(base).copyWith(
      labelLarge: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      labelMedium: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: textSecondary,
        letterSpacing: 0.4,
      ),
      labelSmall: GoogleFonts.poppins(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: textMuted,
        letterSpacing: 0.6,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // THEME
  // ---------------------------------------------------------------------------
  static ThemeData get lightTheme {
    final textTheme = _buildTextTheme();

    return ThemeData(
      useMaterial3: true,
      fontFamily: GoogleFonts.poppins().fontFamily,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        onPrimary: Colors.white,
        primaryContainer: AppColor.primarySurface,
        onPrimaryContainer: AppColor.primaryDark,
        secondary: brandNavy,
        onSecondary: Colors.white,
        secondaryContainer: AppColor.alertBlue,
        onSecondaryContainer: AppColor.brandNavy,
        error: errorColor,
        onError: Colors.white,
        surface: surfaceColor,
        onSurface: textPrimary,
        surfaceContainerHighest: AppColor.backgroundCream,
        outline: AppColor.outline,
        outlineVariant: AppColor.hairline,
      ),
      scaffoldBackgroundColor: backgroundLight,
      canvasColor: backgroundLight,
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundLight,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        iconTheme: const IconThemeData(color: textPrimary),
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
      ),
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: cardBorderRadius,
          side: const BorderSide(color: cardBorderColor, width: 1),
        ),
        shadowColor: glassShadow,
        surfaceTintColor: Colors.transparent,
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
        ),
        iconColor: AppColor.brandNavy,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(double.infinity, 54),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLg),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          backgroundColor: Colors.transparent,
          side: const BorderSide(color: AppColor.outline, width: 1.2),
          minimumSize: const Size(double.infinity, 54),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLg),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          borderSide: const BorderSide(color: AppColor.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          borderSide: const BorderSide(color: AppColor.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          borderSide: const BorderSide(color: primaryColor, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          borderSide: const BorderSide(color: errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          borderSide: const BorderSide(color: errorColor, width: 1.6),
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(color: AppColor.textMuted),
        labelStyle: textTheme.bodyMedium?.copyWith(color: textSecondary),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceColor,
        selectedColor: AppColor.primarySurface,
        disabledColor: AppColor.hairline,
        labelStyle: textTheme.bodyMedium!.copyWith(
          color: textPrimary,
          fontWeight: FontWeight.w600,
        ),
        secondaryLabelStyle: textTheme.bodyMedium!.copyWith(
          color: primaryDark,
          fontWeight: FontWeight.w700,
        ),
        side: const BorderSide(color: AppColor.outline),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusPill),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColor.hairline,
        thickness: 1,
        space: 1,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: AppColor.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        showUnselectedLabels: true,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColor.deepNavy,
        contentTextStyle: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: primaryColor,
        unselectedLabelColor: AppColor.textMuted,
        indicatorSize: TabBarIndicatorSize.label,
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(color: primaryColor, width: 2.5),
        ),
        labelStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryColor,
        linearTrackColor: AppColor.primarySurface,
        circularTrackColor: AppColor.primarySurface,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius2xl),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surfaceColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(radius2xl),
          ),
        ),
      ),
    );
  }
}
