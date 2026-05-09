import 'package:flutter/material.dart';

import '../theme/app_color.dart';
import '../theme/app_theme.dart';

class CustomTextField extends StatelessWidget {
  final String? hintText;
  final String? labelText;
  final String? helperText;
  final TextEditingController? controller;
  final bool isPassword;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final bool readOnly;
  final int? maxLines;
  final int? maxLength;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;

  const CustomTextField({
    super.key,
    this.hintText,
    this.labelText,
    this.helperText,
    this.controller,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.done,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.onChanged,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText != null) ...[
          Text(
            labelText!,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColor.textPrimary,
              letterSpacing: 0.1,
            ),
          ),
          const SizedBox(height: AppTheme.space8),
        ],
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          validator: validator,
          readOnly: readOnly,
          maxLines: isPassword ? 1 : maxLines,
          maxLength: maxLength,
          onChanged: onChanged,
          onTap: onTap,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColor.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            helperText: helperText,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            counterText: '',
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }
}
