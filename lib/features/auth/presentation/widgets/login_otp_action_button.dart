import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginOtpActionButton extends StatelessWidget {
  final bool isLoading;
  final bool otpSent;
  final VoidCallback onPressed;

  const LoginOtpActionButton({
    super.key,
    required this.isLoading,
    required this.otpSent,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    otpSent ? 'login.verify_otp'.tr() : 'login.get_otp'.tr(),
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 8),
                  const FaIcon(FontAwesomeIcons.arrowRight, size: 20),
                ],
              ),
      ),
    );
  }
}
