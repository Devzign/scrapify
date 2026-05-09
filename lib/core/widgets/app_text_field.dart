import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_color.dart';
import '../theme/app_theme.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool enabled;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final String? counterText;
  final bool hasError;
  final Color? fillColor;
  final EdgeInsetsGeometry? contentPadding;
  final TextStyle? style;
  final double height;
  final Widget? prefixIcon;
  final BoxConstraints? prefixIconConstraints;

  const AppTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.enabled = true,
    this.textInputAction,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.onChanged,
    this.counterText,
    this.hasError = false,
    this.fillColor,
    this.contentPadding,
    this.style,
    this.height = 72,
    this.prefixIcon,
    this.prefixIconConstraints,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppTheme.radiusLg);
    final baseBorder = hasError ? AppColor.error : AppColor.outline;
    final fieldFill = fillColor ?? (enabled ? AppColor.surface : AppColor.backgroundCream);

    return SizedBox(
      height: height,
      child: TextField(
        controller: controller,
        enabled: enabled,
        textInputAction: textInputAction,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        inputFormatters: inputFormatters,
        onChanged: onChanged,
        style: style ??
            const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColor.textPrimary,
            ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            fontSize: 15,
            color: AppColor.textMuted,
            fontWeight: FontWeight.w500,
          ),
          filled: true,
          fillColor: fieldFill,
          counterText: counterText,
          contentPadding: contentPadding ??
              const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
          prefixIcon: prefixIcon,
          prefixIconConstraints: prefixIconConstraints,
          border: OutlineInputBorder(
            borderRadius: radius,
            borderSide:
                BorderSide(color: baseBorder, width: hasError ? 1.5 : 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: radius,
            borderSide:
                BorderSide(color: baseBorder, width: hasError ? 1.5 : 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: radius,
            borderSide: BorderSide(
              color: hasError ? AppColor.error : AppColor.primary,
              width: hasError ? 1.5 : 1.4,
            ),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: radius,
            borderSide: const BorderSide(color: AppColor.hairline, width: 1),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: radius,
            borderSide: const BorderSide(color: AppColor.error, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: radius,
            borderSide: const BorderSide(color: AppColor.error, width: 1.5),
          ),
        ),
      ),
    );
  }
}
