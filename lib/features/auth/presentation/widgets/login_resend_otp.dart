import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_theme.dart';

class LoginResendOtp extends StatelessWidget {
  final bool canResendOtp;
  final int secondsRemaining;
  final VoidCallback onResend;

  const LoginResendOtp({
    super.key,
    required this.canResendOtp,
    required this.secondsRemaining,
    required this.onResend,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Didn't receive the code? ",
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 14.sp),
        ),
        canResendOtp
            ? GestureDetector(
                onTap: onResend,
                child: Text(
                  'Resend OTP',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                ),
              )
            : Text(
                'Resend in $secondsRemaining s',
                style: TextStyle(
                  color: AppTheme.primaryColor.withValues(alpha: 0.5),
                  fontWeight: FontWeight.w600,
                  fontSize: 14.sp,
                ),
              ),
      ],
    );
  }
}
