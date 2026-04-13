import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final Color? backgroundColor;
  final Color? textColor;
  final Widget? leading;
  final Widget? trailing;
  final double minHeight;
  final double borderRadius;
  final double fontSize;
  final FontWeight fontWeight;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.backgroundColor,
    this.textColor,
    this.leading,
    this.trailing,
    this.minHeight = 56,
    this.borderRadius = 18,
    this.fontSize = 16,
    this.fontWeight = FontWeight.w800,
  });

  @override
  Widget build(BuildContext context) {
    if (isOutlined) {
      return OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          side: backgroundColor != null
              ? BorderSide(color: backgroundColor!)
              : null,
          foregroundColor: textColor ?? AppTheme.primaryColor,
          minimumSize: Size(double.infinity, minHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: _buildChild(),
      );
    }

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? AppTheme.primaryColor,
        foregroundColor: textColor ?? Colors.white,
        disabledBackgroundColor: (backgroundColor ?? AppTheme.primaryColor)
            .withValues(alpha: 0.45),
        minimumSize: Size(double.infinity, minHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        textStyle: TextStyle(fontSize: fontSize, fontWeight: fontWeight),
      ),
      child: _buildChild(),
    );
  }

  Widget _buildChild() {
    return isLoading
        ? const SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leading != null) ...[leading!, const SizedBox(width: 8)],
              Text(text),
              if (trailing != null) ...[const SizedBox(width: 8), trailing!],
            ],
          );
  }
}
