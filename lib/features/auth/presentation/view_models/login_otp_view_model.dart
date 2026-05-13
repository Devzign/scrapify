import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter/services.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

import '../../../../core/services/location_service.dart';
import '../../../../core/services/fcm_service.dart';
import '../../../../core/utils/role_route_resolver.dart';
import '../../../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../../settings/providers/settings_provider.dart';
import 'login_otp_view_state.dart';

final loginOtpViewModelProvider = StateNotifierProvider.autoDispose
    .family<LoginOtpViewModel, LoginOtpViewState, String?>((ref, role) {
      return LoginOtpViewModel(ref, role);
    });

class LoginOtpViewModel extends StateNotifier<LoginOtpViewState> {
  final Ref _ref;
  final LocationService _locationService = LocationService();
  late final TextEditingController userNameController;
  late final TextEditingController emailController;
  late final TextEditingController phoneController;
  late final TextEditingController otpController;
  late final TextEditingController referralController;
  late final FocusNode phoneFocusNode;
  late final FocusNode otpFocusNode;
  final String? _selectedRole;

  Timer? _timer;

  LoginOtpViewModel(this._ref, this._selectedRole)
    : super(const LoginOtpViewState()) {
    userNameController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    otpController = TextEditingController();
    referralController = TextEditingController();
    phoneFocusNode = FocusNode();
    otpFocusNode = FocusNode();

    otpFocusNode.addListener(_handleOtpFocusChanged);

    _ref.onDispose(() {
      _timer?.cancel();
      userNameController.dispose();
      emailController.dispose();
      phoneController.dispose();
      otpController.dispose();
      referralController.dispose();
      phoneFocusNode.dispose();
      otpFocusNode.removeListener(_handleOtpFocusChanged);
      otpFocusNode.dispose();
    });
  }

  String get selectedRole {
    return _selectedRole ?? 'customer';
  }

  bool get isCustomerRole => selectedRole == 'customer';
  bool get isRegisterMode => state.isRegisterMode;

  List<TextInputFormatter> get referralInputFormatters => [
    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
    LengthLimitingTextInputFormatter(6),
    TextInputFormatter.withFunction((oldValue, newValue) {
      return newValue.copyWith(text: newValue.text.toUpperCase());
    }),
  ];

  KeyboardActionsConfig buildKeyboardConfig() {
    return KeyboardActionsConfig(
      keyboardActionsPlatform: KeyboardActionsPlatform.ALL,
      keyboardBarColor: Colors.grey[200],
      nextFocus: false,
      actions: [
        KeyboardActionsItem(
          focusNode: phoneFocusNode,
          displayArrows: false,
          displayDoneButton: true,
        ),
      ],
    );
  }

  void onPhoneChanged(String value) {
    if (state.phoneError == null) {
      return;
    }

    final error = _validatePhone(value.trim());
    state = state.copyWith(phoneError: error, clearPhoneError: error == null);
  }

  void onUserNameChanged(String value) {
    if (state.userNameError == null) {
      return;
    }
    final error = _validateUserName(value.trim());
    state = state.copyWith(
      userNameError: error,
      clearUserNameError: error == null,
    );
  }

  void onOtpChanged(String value) {
    state = state.copyWith(otpValue: value, otpError: false);

    if (value.length == 6) {
      otpFocusNode.unfocus();
      unawaited(verifyOtp());
    }
  }

  void onEmailChanged(String value) {
    if (state.emailError == null) {
      return;
    }
    final error = _validateEmail(value.trim());
    state = state.copyWith(emailError: error, clearEmailError: error == null);
  }

  void toggleReferralInput() {
    state = state.copyWith(showReferralInput: !state.showReferralInput);
  }

  void setAuthMode({required bool registerMode}) {
    _timer?.cancel();
    otpController.clear();
    state = state.copyWith(
      isRegisterMode: registerMode,
      otpSent: false,
      otpValue: '',
      otpError: false,
      canResendOtp: false,
      secondsRemaining: 30,
      clearUserNameError: true,
      clearEmailError: true,
      clearPhoneError: true,
      clearReferralError: true,
    );
  }

  void onReferralChanged(String value) {
    if (state.referralError == null) {
      return;
    }
    final error = _validateReferral(value);
    state = state.copyWith(
      referralError: error,
      clearReferralError: error == null,
    );
  }

  Future<void> sendOtp() async {
    final userName = userNameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    if (isCustomerRole && state.isRegisterMode) {
      final userNameError = _validateUserName(userName);
      if (userNameError != null) {
        state = state.copyWith(userNameError: userNameError);
        return;
      }
      final emailError = _validateEmail(email);
      if (emailError != null) {
        state = state.copyWith(emailError: emailError);
        return;
      }
    }

    final error = _validatePhone(phone);

    if (error != null) {
      state = state.copyWith(phoneError: error);
      return;
    }

    state = state.copyWith(
      clearUserNameError: true,
      clearEmailError: true,
      clearPhoneError: true,
      clearReferralError: true,
      isLoading: true,
      otpError: false,
    );

    final referralCode = referralController.text.trim();
    final referralError = _validateReferral(referralCode);
    if (referralError != null) {
      state = state.copyWith(isLoading: false, referralError: referralError);
      return;
    }

    final authRepository = _ref.read(authRepositoryProvider);
    final locationPayload = await _buildLocationPayload();

    // Pre-validate referral code (customer only) — fail fast before sending OTP.
    if (isCustomerRole && state.isRegisterMode && referralCode.isNotEmpty) {
      final preCheck = await authRepository.validateReferralCode(referralCode);
      if (!preCheck.isSuccess) {
        state = state.copyWith(
          isLoading: false,
          referralError: preCheck.errorMessage ?? 'Invalid referral code',
        );
        return;
      }
    }

    final response = isCustomerRole
        ? (state.isRegisterMode
              ? await authRepository.sendRegistrationOtp(
                  phone: phone,
                  name: userName,
                  email: email,
                  referralCode: referralCode.isNotEmpty ? referralCode : null,
                  latitude: locationPayload.latitude,
                  longitude: locationPayload.longitude,
                  locationName: locationPayload.locationName,
                )
              : await authRepository.sendLoginOtp(
                  phone: phone,
                  latitude: locationPayload.latitude,
                  longitude: locationPayload.longitude,
                  locationName: locationPayload.locationName,
                ))
        : await authRepository.sendOtp(
            phone: phone,
            role: selectedRole,
            name: null,
          );

    state = state.copyWith(isLoading: false);

    if (!response.isSuccess) {
      state = state.copyWith(
        snackBarMessage: response.errorMessage ?? 'Failed to send OTP',
        isSuccessMessage: false,
      );
      return;
    }

    _startTimer();
    state = state.copyWith(
      otpSent: true,
      snackBarMessage: 'OTP: ${response.data}',
      isSuccessMessage: true,
      shouldFocusOtp: true,
    );
  }

  Future<void> resendOtp() async {
    if (!state.canResendOtp || state.isLoading) {
      return;
    }

    await sendOtp();
  }

  void editPhone() {
    _timer?.cancel();
    otpController.clear();
    state = state.copyWith(
      otpSent: false,
      otpValue: '',
      otpError: false,
      canResendOtp: false,
      secondsRemaining: 30,
    );
    phoneFocusNode.requestFocus();
  }

  Future<void> verifyOtp() async {
    final phone = phoneController.text.trim();
    final otp = state.otpValue;

    if (otp.length < 6) {
      state = state.copyWith(
        snackBarMessage: 'Please enter the complete 6-digit OTP.',
        isSuccessMessage: false,
      );
      return;
    }

    state = state.copyWith(isLoading: true);
    final referralCode = referralController.text.trim();
    final authRepository = _ref.read(authRepositoryProvider);
    final locationPayload = await _buildLocationPayload();
    final response = isCustomerRole
        ? (state.isRegisterMode
              ? await authRepository.verifyRegistrationOtp(
                  phone: phone,
                  otp: otp,
                  referralCode: referralCode.isNotEmpty ? referralCode : null,
                  latitude: locationPayload.latitude,
                  longitude: locationPayload.longitude,
                  locationName: locationPayload.locationName,
                )
              : await authRepository.verifyLoginOtp(
                  phone: phone,
                  otp: otp,
                  latitude: locationPayload.latitude,
                  longitude: locationPayload.longitude,
                  locationName: locationPayload.locationName,
                ))
        : await authRepository.verifyOtp(
            phone: phone,
            otp: otp,
            role: selectedRole,
          );

    state = state.copyWith(isLoading: false);

    if (response.isSuccess) {
      final loggedInUser = response.data;
      final resolvedRole = (loggedInUser?.roles.isNotEmpty ?? false)
          ? loggedInUser!.roles.first
          : selectedRole;

      final fcmToken = await FcmService.instance.getToken();
      await _ref
          .read(settingsProvider.notifier)
          .syncSettings(
            latitude: locationPayload.latitude,
            longitude: locationPayload.longitude,
            locationName: locationPayload.locationName,
            fcmToken: fcmToken,
          );

      final referralApplied = _ref
          .read(authRepositoryProvider)
          .lastReferralApplied;

      state = state.copyWith(
        nextRoute: RoleRouteResolver.resolve(resolvedRole),
        snackBarMessage: referralApplied ? 'Referral applied 🎉' : null,
        isSuccessMessage: referralApplied ? true : null,
      );
      return;
    }

    state = state.copyWith(
      otpError: true,
      snackBarMessage: 'Invalid OTP or login failed. Please try again.',
      isSuccessMessage: false,
    );
  }

  void clearSnackBar() {
    state = state.copyWith(clearSnackBarMessage: true);
  }

  void clearNavigation() {
    state = state.copyWith(clearNextRoute: true);
  }

  void clearFocusRequest() {
    state = state.copyWith(shouldFocusOtp: false);
  }

  String? _validatePhone(String value) => Validators.indianMobile(value);

  String? _validateUserName(String value) =>
      Validators.name(value, fieldName: 'Name');
  String? _validateEmail(String value) =>
      Validators.email(value, requiredField: true);

  String? _validateReferral(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    if (trimmed.length > 6) {
      return 'Referral code must be at most 6 characters.';
    }
    if (!RegExp(r'^[A-Z0-9]+$').hasMatch(trimmed)) {
      return 'Use only letters and numbers.';
    }
    return null;
  }

  void _startTimer() {
    _timer?.cancel();
    state = state.copyWith(canResendOtp: false, secondsRemaining: 30);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.secondsRemaining == 0) {
        timer.cancel();
        state = state.copyWith(canResendOtp: true);
        return;
      }

      state = state.copyWith(secondsRemaining: state.secondsRemaining - 1);
    });
  }

  void _handleOtpFocusChanged() {
    state = state.copyWith(isOtpFieldFocused: otpFocusNode.hasFocus);
  }

  Future<_AuthLocationPayload> _buildLocationPayload() async {
    final appSettings = _ref.read(settingsProvider);
    final rawLat = appSettings.settings['latitude'];
    final rawLng = appSettings.settings['longitude'];

    double? latitude = rawLat is num
        ? rawLat.toDouble()
        : double.tryParse('$rawLat');
    double? longitude = rawLng is num
        ? rawLng.toDouble()
        : double.tryParse('$rawLng');
    String locationName = appSettings.serviceAvailability.locationName.trim();

    if (latitude == null || longitude == null) {
      final bestLocation = await _locationService.getBestAvailableLocation();
      latitude = bestLocation?.latitude;
      longitude = bestLocation?.longitude;
      if (locationName.isEmpty) {
        locationName = bestLocation?.locationName?.trim() ?? '';
      }
    }

    if (locationName.isEmpty && latitude != null && longitude != null) {
      locationName =
          await _locationService.getLocationName(latitude, longitude) ?? '';
    }

    return _AuthLocationPayload(
      latitude: latitude,
      longitude: longitude,
      locationName: locationName.isEmpty ? null : locationName,
    );
  }
}

class _AuthLocationPayload {
  const _AuthLocationPayload({
    this.latitude,
    this.longitude,
    this.locationName,
  });

  final double? latitude;
  final double? longitude;
  final String? locationName;
}
