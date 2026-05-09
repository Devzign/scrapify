import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_theme.dart';
import '../formatters/indian_mobile_formatter.dart';

class LoginPhoneField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool enabled;
  final String? errorText;
  final ValueChanged<String> onChanged;

  const LoginPhoneField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.enabled,
    required this.errorText,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppTheme.radiusLg);
    final baseBorder = errorText != null ? AppColor.error : AppColor.outline;

    return SizedBox(
      height: 60,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.done,
        enabled: enabled,
        maxLength: 10,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColor.textPrimary,
          letterSpacing: 0.6,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          IndianMobileFormatter(),
          LengthLimitingTextInputFormatter(10),
        ],
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Enter mobile number *',
          hintStyle: const TextStyle(
            fontSize: 15,
            color: AppColor.textMuted,
            fontWeight: FontWeight.w500,
          ),
          filled: true,
          fillColor: enabled ? AppColor.surface : AppColor.backgroundCream,
          counterText: '',
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
          prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 39,
                  height: 26,
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(2)),
                    child: Image(
                      image: AssetImage('assets/images/indian_flag.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(height: 24, width: 1, color: AppColor.hairline),
              ],
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: radius,
            borderSide: BorderSide(color: baseBorder, width: errorText != null ? 1.5 : 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: radius,
            borderSide: BorderSide(color: baseBorder, width: errorText != null ? 1.5 : 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: radius,
            borderSide: BorderSide(
              color: errorText != null ? AppColor.error : AppColor.primary,
              width: errorText != null ? 1.5 : 1.4,
            ),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: radius,
            borderSide: const BorderSide(color: AppColor.hairline, width: 1),
          ),
        ),
      ),
    );
  }
}
