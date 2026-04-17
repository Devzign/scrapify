import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/widgets/custom_button.dart';

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
      child: CustomButton(
        onPressed: isLoading ? null : onPressed,
        isLoading: isLoading,
        text: otpSent ? 'login.verify_otp'.tr() : 'login.get_otp'.tr(),
        trailing: const FaIcon(FontAwesomeIcons.arrowRight, size: 20),
      ),
    );
  }
}
