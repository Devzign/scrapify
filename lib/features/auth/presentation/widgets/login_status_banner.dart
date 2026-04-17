import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

enum LoginStatusBannerType { success, warning, error, info }

void showLoginStatusBanner(
  BuildContext context, {
  required String message,
  required LoginStatusBannerType type,
}) {
  final scheme = _bannerScheme(type);

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        backgroundColor: Colors.transparent,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: scheme.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: scheme.border),
            boxShadow: [
              BoxShadow(
                color: scheme.shadow,
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              FaIcon(scheme.icon, color: scheme.foreground, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: scheme.foreground,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
}

({
  Color background,
  Color border,
  Color foreground,
  Color shadow,
  IconData icon,
})
_bannerScheme(LoginStatusBannerType type) {
  switch (type) {
    case LoginStatusBannerType.success:
      return (
        background: const Color(0xFFEAF9EE),
        border: const Color(0xFFCBEED5),
        foreground: const Color(0xFF57C96D),
        shadow: const Color(0x3357C96D),
        icon: FontAwesomeIcons.circleCheck,
      );
    case LoginStatusBannerType.warning:
      return (
        background: const Color(0xFFFFF7E8),
        border: const Color(0xFFF8E0A4),
        foreground: const Color(0xFFF0B23A),
        shadow: const Color(0x33F0B23A),
        icon: FontAwesomeIcons.triangleExclamation,
      );
    case LoginStatusBannerType.error:
      return (
        background: const Color(0xFFFDEDEE),
        border: const Color(0xFFF3D1D3),
        foreground: const Color(0xFFEB6B68),
        shadow: const Color(0x33EB6B68),
        icon: FontAwesomeIcons.circleXmark,
      );
    case LoginStatusBannerType.info:
      return (
        background: const Color(0xFFF3F5F9),
        border: const Color(0xFFD6DCE6),
        foreground: const Color(0xFF202124),
        shadow: const Color(0x1A202124),
        icon: FontAwesomeIcons.circleInfo,
      );
  }
}
