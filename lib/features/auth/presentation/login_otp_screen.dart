import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
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
import 'widgets/login_status_banner.dart';

class LoginOtpScreen extends ConsumerWidget {
  final String? role;

  const LoginOtpScreen({super.key, this.role});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = loginOtpViewModelProvider(role);

    ref.listen<LoginOtpViewState>(provider, (previous, next) {
      if (next.shouldFocusOtp && previous?.shouldFocusOtp != true) {
        Future<void>.delayed(const Duration(milliseconds: 100), () {
          if (!context.mounted) {
            return;
          }
          FocusScope.of(
            context,
          ).requestFocus(ref.read(provider.notifier).otpFocusNode);
          SystemChannels.textInput.invokeMethod<void>('TextInput.show');
          ref.read(provider.notifier).clearFocusRequest();
        });
      }

      final snackBarMessage = next.snackBarMessage;
      if (snackBarMessage != null &&
          snackBarMessage != previous?.snackBarMessage) {
        showLoginStatusBanner(
          context,
          message: snackBarMessage,
          type: next.isSuccessMessage
              ? LoginStatusBannerType.success
              : LoginStatusBannerType.error,
        );
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.white,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () {
            if (state.otpSent) {
              viewModel.editPhone();
            } else {
              context.pop();
            }
          },
        ),
      ),
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
                if (!state.otpSent && viewModel.isCustomerRole) ...[
                  const SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: viewModel.toggleReferralInput,
                      child: Text(
                        state.showReferralInput
                            ? 'Hide referral code'
                            : 'Have a referral code?',
                        style: const TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  if (state.showReferralInput) ...[
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: state.referralError != null
                              ? Colors.red
                              : Colors.grey.shade300,
                          width: state.referralError != null ? 1.5 : 1,
                        ),
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.white,
                      ),
                      child: TextField(
                        controller: viewModel.referralController,
                        textCapitalization: TextCapitalization.characters,
                        enabled: !state.otpSent,
                        inputFormatters: viewModel.referralInputFormatters,
                        onChanged: viewModel.onReferralChanged,
                        decoration: const InputDecoration(
                          hintText: 'Enter referral code (optional)',
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          counterText: '',
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
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
                if (state.referralError != null) ...[
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
                          state.referralError!,
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
