import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

import '../../../core/theme/app_color.dart';
import '../../../core/widgets/app_text_field.dart';
import 'view_models/login_otp_view_model.dart';
import 'view_models/login_otp_view_state.dart';
import 'widgets/login_intro_panel.dart';
import 'widgets/login_otp_action_button.dart';
import 'widgets/login_otp_input.dart';
import 'widgets/login_phone_field.dart';
import 'widgets/login_resend_otp.dart';
import 'widgets/login_status_banner.dart';
import '../../../core/utils/app_routes.dart';

class LoginOtpScreen extends ConsumerWidget {
  final String? role;

  const LoginOtpScreen({super.key, this.role});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = loginOtpViewModelProvider(role);

    ref.listen<LoginOtpViewState>(provider, (previous, next) {
      if (next.shouldFocusOtp && previous?.shouldFocusOtp != true) {
        Future<void>.delayed(const Duration(milliseconds: 100), () {
          if (!context.mounted) return;
          FocusScope.of(context)
              .requestFocus(ref.read(provider.notifier).otpFocusNode);
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
      backgroundColor: AppColor.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColor.backgroundLight,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        elevation: 0,
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_rounded, color: AppColor.textPrimary),
          onPressed: () {
            if (state.otpSent) {
              viewModel.editPhone();
            } else {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(AppRoutes.role);
              }
            }
          },
        ),
      ),
      bottomNavigationBar: LoginOtpActionButton(
        isLoading: state.isLoading,
        otpSent: state.otpSent,
        onPressed: state.otpSent ? viewModel.verifyOtp : viewModel.sendOtp,
      ),
      body: Stack(
        children: [
          // Eco glow at the top.
          Positioned(
            top: -120,
            left: -80,
            right: -80,
            child: IgnorePointer(
              child: Container(
                height: 360,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColor.primary.withValues(alpha: 0.14),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: KeyboardActions(
              config: viewModel.buildKeyboardConfig(),
              disableScroll: true,
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const LoginIntroPanel(),
                    SizedBox(height: 8.h),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppColor.deepNavy,
                          height: 1.2,
                          letterSpacing: -0.4,
                        ),
                        children: [
                          TextSpan(text: '${'login.welcome'.tr()}\n'),
                          TextSpan(
                            text: 'login.app_name'.tr(),
                            style: const TextStyle(color: AppColor.primary),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      state.otpSent
                          ? 'Please enter the OTP sent to your number.'
                          : 'login.subtitle'.tr(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColor.textSecondary,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 28.h),
                    if (viewModel.isCustomerRole) ...[
                      AppTextField(
                        controller: viewModel.userNameController,
                        enabled: !state.otpSent,
                        textInputAction: TextInputAction.next,
                        onChanged: viewModel.onUserNameChanged,
                        hintText: 'Enter user name',
                        prefixIconConstraints: const BoxConstraints(
                          minWidth: 0,
                          minHeight: 0,
                        ),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(left: 14, right: 10),
                          child: Image.asset(
                            'assets/images/user-profile.png',
                            width: 20,
                            height: 20,
                          ),
                        ),
                      ),
                      if (state.userNameError != null) ...[
                        const SizedBox(height: 8),
                        _InlineError(message: state.userNameError!),
                      ],
                      const SizedBox(height: 8),
                    ],
                    LoginPhoneField(
                      controller: viewModel.phoneController,
                      focusNode: viewModel.phoneFocusNode,
                      enabled: !state.otpSent,
                      errorText: state.phoneError,
                      onChanged: viewModel.onPhoneChanged,
                    ),
                    if (!state.otpSent && viewModel.isCustomerRole) ...[
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          onTap: viewModel.toggleReferralInput,
                          child: Text(
                            state.showReferralInput
                                ? 'Hide referral code'
                                : 'Have a referral code?',
                            style: const TextStyle(
                              color: AppColor.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      if (state.showReferralInput) ...[
                        const SizedBox(height: 8),
                        AppTextField(
                          controller: viewModel.referralController,
                          textCapitalization: TextCapitalization.characters,
                          enabled: !state.otpSent,
                          inputFormatters: viewModel.referralInputFormatters,
                          onChanged: viewModel.onReferralChanged,
                          hintText: 'Enter referral code (optional)',
                          counterText: '',
                          hasError: state.referralError != null,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColor.textPrimary,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ],
                    if (state.phoneError != null) ...[
                      const SizedBox(height: 8),
                      _InlineError(message: state.phoneError!),
                    ],
                    if (state.referralError != null) ...[
                      const SizedBox(height: 8),
                      _InlineError(message: state.referralError!),
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
                      SizedBox(height: 22.h),
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
        ],
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  final String message;
  const _InlineError({required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: AppColor.error,
              size: 14,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                message,
                style: const TextStyle(
                  color: AppColor.error,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
