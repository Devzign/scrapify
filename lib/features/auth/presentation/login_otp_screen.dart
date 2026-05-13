import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

import '../../../core/services/location_service.dart';
import '../../../core/theme/app_color.dart';
import '../../../core/widgets/app_text_field.dart';
import 'view_models/login_otp_view_model.dart';
import 'view_models/login_otp_view_state.dart';
import 'widgets/login_otp_input.dart';
import 'widgets/login_phone_field.dart';
import 'widgets/login_resend_otp.dart';
import 'widgets/login_status_banner.dart';
import '../../../core/utils/app_routes.dart';

class LoginOtpScreen extends ConsumerStatefulWidget {
  final String? role;

  const LoginOtpScreen({super.key, this.role});

  @override
  ConsumerState<LoginOtpScreen> createState() => _LoginOtpScreenState();
}

class _LoginOtpScreenState extends ConsumerState<LoginOtpScreen>
    with WidgetsBindingObserver {
  final LocationService _locationService = LocationService();
  bool _locationInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeLocation();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Re-try location silently when user returns from device Settings
    // (they may have just turned on GPS or granted permission)
    if (state == AppLifecycleState.resumed && _locationInitialized) {
      _tryGetLocationSilentlyOnResume();
    }
  }

  Future<void> _initializeLocation() async {
    _locationInitialized = true;

    // First: request the OS permission dialog (shows even if GPS is off)
    final permission = await _locationService.requestPermissionOnly();

    if (permission == LocationPermission.deniedForever) {
      if (mounted) _showPermanentlyDeniedDialog();
      return;
    }

    if (permission == LocationPermission.denied) {
      // User declined — don't force, just proceed without location
      return;
    }

    // Permission granted — now check if location services (GPS) are on
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) await _showLocationServicesDialog();
      return;
    }

    // Everything is good — get location and cache it
    await _tryGetLocationSilently();
  }

  Future<void> _tryGetLocationSilently() async {
    final result = await _locationService.getCurrentPositionWithStatus();
    if (result.status == LocationStatus.servicesDisabled && mounted) {
      await _showLocationServicesDialog();
    }
    // On success, location is automatically cached inside LocationService
  }

  /// Called on app resume — silently tries to get location, no dialogs shown.
  /// This handles the case where the user just enabled GPS in device settings.
  Future<void> _tryGetLocationSilentlyOnResume() async {
    final permission = await _locationService.requestPermissionOnly();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    // GPS is now on — get and cache the location quietly
    await _locationService.getCurrentPositionWithStatus();
  }

  Future<void> _showLocationServicesDialog() async {
    if (!mounted) return;
    final shouldOpen = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColor.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.gps_fixed_rounded,
                color: AppColor.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'GPS is Turned Off',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColor.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: AppColor.primary,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Location permission: Granted ✓',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColor.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Your GPS (Location Services) is currently OFF on your device. Please turn it on so Scrapify can check pickup availability in your area.',
              style: TextStyle(fontSize: 13, height: 1.5),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'Skip for now',
              style: TextStyle(color: AppColor.textSecondary, fontSize: 13),
            ),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            icon: const Icon(Icons.settings_rounded, size: 16),
            label: const Text('Turn On GPS'),
          ),
        ],
      ),
    );

    if (shouldOpen == true) {
      await Geolocator.openLocationSettings();
      // User will return from settings — didChangeAppLifecycleState handles retry
    }
  }

  void _showPermanentlyDeniedDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.location_off_rounded, color: AppColor.error, size: 24),
            const SizedBox(width: 10),
            const Text(
              'Location Denied',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: const Text(
          'Location permission was denied. To enable it, please go to app settings and allow location access.',
          style: TextStyle(fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColor.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              Geolocator.openAppSettings();
            },
            child: const Text('App Settings'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = loginOtpViewModelProvider(widget.role);

    ref.listen<LoginOtpViewState>(provider, (previous, next) {
      if (next.shouldFocusOtp && previous?.shouldFocusOtp != true) {
        Future<void>.delayed(const Duration(milliseconds: 100), () {
          if (!context.mounted) return;
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
      backgroundColor: AppColor.primary,
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          _GreenHeader(
            onBack: () {
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

          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColor.backgroundLight,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: KeyboardActions(
                config: viewModel.buildKeyboardConfig(),
                disableScroll: true,
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    24,
                    20,
                    24,
                    MediaQuery.of(context).viewInsets.bottom + 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Login / Register toggle ────────────────────────────
                      if (viewModel.isCustomerRole && !state.otpSent) ...[
                        _LoginRegisterToggle(
                          isRegister: state.isRegisterMode,
                          onLogin: () =>
                              viewModel.setAuthMode(registerMode: false),
                          onRegister: () =>
                              viewModel.setAuthMode(registerMode: true),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // ── OTP-sent heading ───────────────────────────────────
                      if (state.otpSent) ...[
                        const _SectionHeading(
                          title: 'Enter OTP',
                          subtitle:
                              'Please enter the 6-digit code sent to your number',
                        ),
                        const SizedBox(height: 20),
                      ] else ...[
                        _SectionHeading(
                          title: state.isRegisterMode
                              ? 'Create Account'
                              : 'Welcome Back!',
                          subtitle: 'login.subtitle'.tr(),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // ── Register-only fields ───────────────────────────────
                      if (viewModel.isCustomerRole && state.isRegisterMode) ...[
                        AppTextField(
                          controller: viewModel.userNameController,
                          enabled: !state.otpSent,
                          textInputAction: TextInputAction.next,
                          onChanged: viewModel.onUserNameChanged,
                          hintText: 'Full name',
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
                          const SizedBox(height: 6),
                          _InlineError(message: state.userNameError!),
                        ],
                        const SizedBox(height: 12),
                        AppTextField(
                          controller: viewModel.emailController,
                          enabled: !state.otpSent,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          onChanged: viewModel.onEmailChanged,
                          hintText: 'Email address',
                          prefixIconConstraints: const BoxConstraints(
                            minWidth: 0,
                            minHeight: 0,
                          ),
                          prefixIcon: const Padding(
                            padding: EdgeInsets.only(left: 14, right: 10),
                            child: Icon(
                              Icons.alternate_email_rounded,
                              size: 20,
                              color: AppColor.textSecondary,
                            ),
                          ),
                        ),
                        if (state.emailError != null) ...[
                          const SizedBox(height: 6),
                          _InlineError(message: state.emailError!),
                        ],
                        const SizedBox(height: 12),
                      ],

                      // ── Phone field ────────────────────────────────────────
                      LoginPhoneField(
                        controller: viewModel.phoneController,
                        focusNode: viewModel.phoneFocusNode,
                        enabled: !state.otpSent,
                        errorText: state.phoneError,
                        onChanged: viewModel.onPhoneChanged,
                      ),
                      if (state.phoneError != null) ...[
                        const SizedBox(height: 6),
                        _InlineError(message: state.phoneError!),
                      ],

                      // ── Referral code ──────────────────────────────────────
                      if (!state.otpSent &&
                          viewModel.isCustomerRole &&
                          state.isRegisterMode) ...[
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: viewModel.toggleReferralInput,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                state.showReferralInput
                                    ? Icons.remove_circle_outline_rounded
                                    : Icons.add_circle_outline_rounded,
                                size: 16,
                                color: AppColor.primary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                state.showReferralInput
                                    ? 'Hide referral code'
                                    : 'Have a referral code?',
                                style: const TextStyle(
                                  color: AppColor.primary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (state.showReferralInput) ...[
                          const SizedBox(height: 10),
                          AppTextField(
                            controller: viewModel.referralController,
                            textCapitalization: TextCapitalization.characters,
                            enabled: !state.otpSent,
                            inputFormatters: viewModel.referralInputFormatters,
                            onChanged: viewModel.onReferralChanged,
                            hintText: 'Referral code (optional)',
                            counterText: '',
                            hasError: state.referralError != null,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColor.textPrimary,
                              letterSpacing: 0.4,
                            ),
                          ),
                          if (state.referralError != null) ...[
                            const SizedBox(height: 6),
                            _InlineError(message: state.referralError!),
                          ],
                        ],
                      ],

                      // ── OTP input ──────────────────────────────────────────
                      if (state.otpSent) ...[
                        const SizedBox(height: 24),
                        LoginOtpInput(
                          controller: viewModel.otpController,
                          focusNode: viewModel.otpFocusNode,
                          otpValue: state.otpValue,
                          hasError: state.otpError,
                          isFocused: state.isOtpFieldFocused,
                          onChanged: viewModel.onOtpChanged,
                        ),
                        const SizedBox(height: 20),
                        LoginResendOtp(
                          canResendOtp: state.canResendOtp,
                          secondsRemaining: state.secondsRemaining,
                          onResend: viewModel.resendOtp,
                        ),
                      ],

                      const SizedBox(height: 28),

                      // ── CTA button (inline for scroll safety) ─────────────
                      _InlineCta(
                        isLoading: state.isLoading,
                        otpSent: state.otpSent,
                        onPressed: state.otpSent
                            ? viewModel.verifyOtp
                            : viewModel.sendOtp,
                      ),

                      SizedBox(height: 12.h),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// GREEN HEADER
// ────────────────────────────────────────────────────────────────────────────

class _GreenHeader extends StatelessWidget {
  final VoidCallback onBack;

  const _GreenHeader({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColor.primary,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Row 1: back button  ←  badge ──────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: onBack,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.30),
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.35),
                        width: 1,
                      ),
                    ),
                    child: const Text(
                      "INDIA'S SMARTEST SCRAP PICKUP",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                ],
              ),

              // ── Row 2: title ───────────────────────────────────────────────
              const SizedBox(height: 20),
              RichText(
                text: const TextSpan(
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                    letterSpacing: -0.4,
                  ),
                  children: [
                    TextSpan(text: 'Turn your '),
                    TextSpan(
                      text: 'scrap\n',
                      style: TextStyle(color: Color(0xFFB8F0C8)),
                    ),
                    TextSpan(text: 'into '),
                    TextSpan(
                      text: 'cash',
                      style: TextStyle(color: Color(0xFFB8F0C8)),
                    ),
                    TextSpan(text: ' in minutes!'),
                  ],
                ),
              ),

              // ── Row 3: subtitle ────────────────────────────────────────────
              const SizedBox(height: 8),
              Text(
                'कबाड़ हटाओ, कैश पाओ — Book a doorstep pickup',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.80),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// LOGIN / REGISTER TOGGLE TABS
// ────────────────────────────────────────────────────────────────────────────

class _LoginRegisterToggle extends StatelessWidget {
  final bool isRegister;
  final VoidCallback onLogin;
  final VoidCallback onRegister;

  const _LoginRegisterToggle({
    required this.isRegister,
    required this.onLogin,
    required this.onRegister,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColor.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColor.outline),
        boxShadow: [
          BoxShadow(
            color: AppColor.primary.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _Tab(label: 'Login', isActive: !isRegister, onTap: onLogin),
          _Tab(label: 'Register', isActive: isRegister, onTap: onRegister),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _Tab({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          height: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive ? AppColor.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isActive ? Colors.white : AppColor.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// SECTION HEADING
// ────────────────────────────────────────────────────────────────────────────

class _SectionHeading extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeading({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColor.deepNavy,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 13,
            color: AppColor.textSecondary,
            fontWeight: FontWeight.w500,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// INLINE CTA BUTTON
// ────────────────────────────────────────────────────────────────────────────

class _InlineCta extends StatelessWidget {
  final bool isLoading;
  final bool otpSent;
  final VoidCallback onPressed;

  const _InlineCta({
    required this.isLoading,
    required this.otpSent,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    otpSent ? 'login.verify_otp'.tr() : 'login.get_otp'.tr(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded, size: 20),
                ],
              ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// INLINE ERROR
// ────────────────────────────────────────────────────────────────────────────

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
