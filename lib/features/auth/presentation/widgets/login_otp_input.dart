import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_theme.dart';

class LoginOtpInput extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String otpValue;
  final bool hasError;
  final bool isFocused;
  final ValueChanged<String> onChanged;

  const LoginOtpInput({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.otpValue,
    required this.hasError,
    required this.isFocused,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: focusNode.requestFocus,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: -300,
            child: SizedBox(
              width: 1,
              height: 1,
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                keyboardType: TextInputType.number,
                maxLength: 6,
                showCursor: false,
                autofocus: false,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  counterText: '',
                ),
                onChanged: onChanged,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(6, (index) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 2.w),
                child: _buildOtpDigitBox(
                  digit: index < otpValue.length ? otpValue[index] : '',
                  isCurrent: isFocused && index == otpValue.length.clamp(0, 5),
                  hasError: hasError,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

Widget _buildOtpDigitBox({
  required String digit,
  required bool isCurrent,
  required bool hasError,
}) {
  final isFilled = digit.isNotEmpty;
  final borderColor = hasError
      ? Colors.red
      : isCurrent
      ? AppTheme.primaryColor
      : isFilled
      ? AppTheme.primaryColor.withValues(alpha: 0.5)
      : Colors.grey.shade300;
  final backgroundColor = hasError
      ? Colors.red.withValues(alpha: 0.05)
      : isCurrent
      ? AppTheme.primaryColor.withValues(alpha: 0.05)
      : Colors.white;

  return AnimatedContainer(
    duration: const Duration(milliseconds: 200),
    width: 45.w,
    height: 56.h,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: borderColor, width: 1.5),
    ),
    child: Text(
      digit,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppTheme.textPrimary,
      ),
    ),
  );
}
