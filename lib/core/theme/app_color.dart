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
  // BACKGROUNDS — pale mint green (matches the scrapi5.com website palette)
  // ---------------------------------------------------------------------------
  /// Main app background — a crisp pale mint that mirrors the scrapi5.com
  /// website palette exactly. Slightly more saturated than before for a
  /// cleaner, more eye-catching backdrop against white cards.
  static const Color backgroundLight = Color(0xFFD4EDCA);

  /// Lighter cream variant — used inside cards for image backdrops and
  /// section panels (kept warm so product photography reads naturally).
  static const Color backgroundCream = Color(0xFFFBF8F1);

  /// Warm cream backdrop behind product images on category/sub-category
  /// cards — slightly more saturated than `backgroundCream` so it stands
  /// out cleanly against the white card body and the mint page background.
  static const Color imageBg = Color(0xFFF5EFE0);

  /// Onboarding shares the website's pale-mint hero so the very first screen
  /// already feels consistent with the rest of the app.
  static const Color onboardingBackground = Color(0xFFE5F2E0);

  /// Card / modal surface — pure white. Reads cleanly on the new pale-mint
  /// background and matches the website's white product cards.
  static const Color surface = Color(0xFFFFFFFF);

  /// Card border — slightly stronger so white cards clearly pop against the
  /// mint background. Maintains a clean, modern look without being harsh.
  static const Color cardBorder = Color(0xFFD6DDD2);

  /// Used for very subtle dividers within cards.
  static const Color hairline = Color(0xFFE9EEE6);

  /// Soft outline used on outlined buttons / chips.
  static const Color outline = Color(0xFFCFD7CB);

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
