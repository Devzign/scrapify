import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

import '../../../core/theme/app_theme.dart';
import 'view_models/login_otp_view_model.dart';
import 'view_models/login_otp_view_state.dart';
import 'widgets/login_intro_panel.dart';
import 'widgets/login_otp_action_button.dart';
import 'widgets/login_otp_input.dart';
import 'widgets/login_phone_field.dart';
import 'widgets/login_resend_otp.dart';

class LoginOtpScreen extends ConsumerWidget {
  final String? role;

  const LoginOtpScreen({super.key, this.role});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = loginOtpViewModelProvider(role);

    ref.listen<LoginOtpViewState>(provider, (previous, next) {
      if (next.shouldFocusOtp && previous?.shouldFocusOtp != true) {
        Future<void>.delayed(const Duration(milliseconds: 100), () {
          ref.read(provider.notifier).otpFocusNode.requestFocus();
          ref.read(provider.notifier).clearFocusRequest();
        });
      }

      final snackBarMessage = next.snackBarMessage;
      if (snackBarMessage != null &&
          snackBarMessage != previous?.snackBarMessage) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(snackBarMessage)));
        ref.read(provider.notifier).clearSnackBar();
      }

      final nextRoute = next.nextRoute;
      if (nextRoute != null) {
        ref.read(provider.notifier).clearNavigation();
        context.go(nextRoute);
      }
    });

    final state = ref.watch(provider);
    final viewModel = ref.read(provider.notifier);

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: LoginOtpActionButton(
        isLoading: state.isLoading,
        otpSent: state.otpSent,
        onPressed: state.otpSent ? viewModel.verifyOtp : viewModel.sendOtp,
      ),
      body: SafeArea(
        child: KeyboardActions(
          config: viewModel.buildKeyboardConfig(),
          disableScroll: true,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const LoginIntroPanel(),
                SizedBox(height: 32.h),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                      height: 1.2,
                    ),
                    children: [
                      TextSpan(text: '${'login.welcome'.tr()}\n'),
                      TextSpan(
                        text: 'login.app_name'.tr(),
                        style: const TextStyle(color: AppTheme.primaryColor),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 32.h),
                Text(
                  state.otpSent
                      ? 'Please enter the OTP sent to your number.'
                      : 'login.subtitle'.tr(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppTheme.textSecondary,
                  ),
                ),
                SizedBox(height: 32.h),
                LoginPhoneField(
                  controller: viewModel.phoneController,
                  focusNode: viewModel.phoneFocusNode,
                  enabled: !state.otpSent,
                  errorText: state.phoneError,
                  onChanged: viewModel.onPhoneChanged,
                ),
                if (state.phoneError != null) ...[
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          state.phoneError!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                SizedBox(height: 16.h),
                if (state.otpSent) ...[
                  LoginOtpInput(
                    controller: viewModel.otpController,
                    focusNode: viewModel.otpFocusNode,
                    otpValue: state.otpValue,
                    hasError: state.otpError,
                    isFocused: state.isOtpFieldFocused,
                    onChanged: viewModel.onOtpChanged,
                  ),
                  SizedBox(height: 24.h),
                  LoginResendOtp(
                    canResendOtp: state.canResendOtp,
                    secondsRemaining: state.secondsRemaining,
                    onResend: viewModel.resendOtp,
                  ),
                  SizedBox(height: 24.h),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
