import 'package:flutter/material.dart';

/// Scrapify color palette — Sage + Cream + Navy.
///
/// Derived from the brand logo:
///  - the green recycle ring  → primary sage greens
///  - the navy ₹ symbol       → text + accent navy
/// Backgrounds use a warm cream instead of pale-white-green to remove
/// the low-contrast "wash" that strained the eye in the previous palette.
///
/// All previously-used field names are preserved (just retuned) so existing
/// screens compile without changes.
class AppColor {
  const AppColor._();

  // ---------------------------------------------------------------------------
  // PRIMARY — sage / forest green (derived from logo recycle ring)
  // ---------------------------------------------------------------------------
  /// Main brand green. Used on CTAs, active states, focused inputs.
  static const Color primary = Color(0xFF2F7D4F);

  /// Subtle tinted-green fill (selected chip background, soft highlights).
  static const Color primaryLight = Color(0xFFD7EADD);

  /// Pressed / dark sage — used for hovered buttons, dark accents.
  static const Color primaryDark = Color(0xFF1F5C39);

  /// Soft sage surface — used behind tiles, large illustrative cards.
  /// Sits one step warmer than the screen background.
  static const Color primarySurface = Color(0xFFE8F1EB);

  /// Mid-sage used for icons and small leaf accents.
  static const Color emeraldMoss = Color(0xFF4F9B6D);

  /// Bright leaf accent — used sparingly for "eco" highlights.
  static const Color leafAccent = Color(0xFF5BA877);

  // ---------------------------------------------------------------------------
  // SECONDARY / NAVY — pulled from the rupee symbol in the logo
  // ---------------------------------------------------------------------------
  /// Deep navy — primary text color and headline-on-light surfaces.
  static const Color deepNavy = Color(0xFF0E2235);

  /// Logo navy — accent for trust/finance contexts (payouts, summaries).
  static const Color brandNavy = Color(0xFF1E3A5F);

  /// Lighter navy — secondary buttons, inactive nav items.
  static const Color brandNavyLight = Color(0xFF2F548A);

  // ---------------------------------------------------------------------------
  // ACCENT (kept names from the previous palette for back-compat)
  // ---------------------------------------------------------------------------
  static const Color accentMint = Color(0xFF3F9D6B);
  static const Color secondary = Color(0xFF1E3A5F);

  // ---------------------------------------------------------------------------
  // SEMANTIC
  // ---------------------------------------------------------------------------
  static const Color success = Color(0xFF3F9D6B);
  static const Color warning = Color(0xFFD88B3C); // warm terracotta — eco feel
  static const Color error = Color(0xFFC44A47); // muted red, less harsh
  static const Color info = Color(0xFF3D6B9A);

  /// Soft tint behind warning toasts / "required" pills.
  static const Color hintPeach = Color(0xFFFCEFD8);

  /// Soft tint behind info banners.
  static const Color alertBlue = Color(0xFFE6EEF7);

  /// Soft tint behind error toasts.
  static const Color errorTint = Color(0xFFFBE7E6);

  /// Soft tint behind success toasts.
  static const Color successTint = Color(0xFFDFF1E6);

  // ---------------------------------------------------------------------------
  // BACKGROUNDS — warm cream (the eye-strain fix)
  // ---------------------------------------------------------------------------
  /// Main app background — a calm warm cream. Easier on eyes than the
  /// old pale-green wash, and lets sage greens "pop" properly.
  static const Color backgroundLight = Color(0xFFF5F1E8);

  /// Lighter cream variant — used for section backgrounds and large illustrations.
  static const Color backgroundCream = Color(0xFFFBF8F1);

  /// Onboarding gets a slightly cooler cream so the bright illustrations sing.
  static const Color onboardingBackground = Color(0xFFF3EFE6);

  /// Card / modal surface — pure white on the cream gives proper contrast.
  static const Color surface = Color(0xFFFFFFFF);

  /// A faint card border — visible on cream but invisible on white.
  static const Color cardBorder = Color(0xFFE5DFD2);

  /// Used for very subtle dividers within cards.
  static const Color hairline = Color(0xFFEDE7D9);

  /// Soft outline used on outlined buttons / chips.
  static const Color outline = Color(0xFFD8D2C2);

  // ---------------------------------------------------------------------------
  // GLASS / DEPTH (kept for back-compat with screens that use these tokens)
  // ---------------------------------------------------------------------------
  static const Color glassHighlight = Color(0xFFFFFFFF);
  static const Color glassShadow = Color(0x140E2235);

  // ---------------------------------------------------------------------------
  // TEXT
  // ---------------------------------------------------------------------------
  /// Primary text — deep navy from logo, ~15:1 contrast on cream.
  static const Color textPrimary = Color(0xFF0E2235);

  /// Secondary text — softened navy-gray.
  static const Color textSecondary = Color(0xFF4F6275);

  /// Muted helper / placeholder text.
  static const Color textMuted = Color(0xFF8A98A8);

  /// Inverse text — used on dark/sage filled surfaces.
  static const Color textOnPrimary = Color(0xFFFBF8F1);

  // ---------------------------------------------------------------------------
  // EARTH / DONATE (used by community/donation cards)
  // ---------------------------------------------------------------------------
  static const Color earth = Color(0xFF8B6F47);
  static const Color rose = Color(0xFFC85A6B); // donate / heart accents
  static const Color roseTint = Color(0xFFF8E1E5);
}
