import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter/services.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

import '../../../../core/utils/role_route_resolver.dart';
import '../../providers/auth_provider.dart';
import 'login_otp_view_state.dart';

final loginOtpViewModelProvider = StateNotifierProvider.autoDispose
    .family<LoginOtpViewModel, LoginOtpViewState, String?>((ref, role) {
      return LoginOtpViewModel(ref, role);
    });

class LoginOtpViewModel extends StateNotifier<LoginOtpViewState> {
  final Ref _ref;
  late final TextEditingController userNameController;
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
    phoneController = TextEditingController();
    otpController = TextEditingController();
    referralController = TextEditingController();
    phoneFocusNode = FocusNode();
    otpFocusNode = FocusNode();

    otpFocusNode.addListener(_handleOtpFocusChanged);

    _ref.onDispose(() {
      _timer?.cancel();
      userNameController.dispose();
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

  void toggleReferralInput() {
    state = state.copyWith(showReferralInput: !state.showReferralInput);
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
    final phone = phoneController.text.trim();
    if (isCustomerRole) {
      final userNameError = _validateUserName(userName);
      if (userNameError != null) {
        state = state.copyWith(userNameError: userNameError);
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

    // Pre-validate referral code (customer only) — fail fast before sending OTP.
    if (isCustomerRole && referralCode.isNotEmpty) {
      final preCheck = await authRepository.validateReferralCode(referralCode);
      if (!preCheck.isSuccess) {
        state = state.copyWith(
          isLoading: false,
          referralError: preCheck.errorMessage ?? 'Invalid referral code',
        );
        return;
      }
    }

    final response = await authRepository.sendOtp(
      name: isCustomerRole ? userName : null,
      phone: phone,
      role: selectedRole,
      referralCode: isCustomerRole && referralCode.isNotEmpty
          ? referralCode
          : null,
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
    final authNotifier = _ref.read(authProvider.notifier);
    final referralCode = referralController.text.trim();
    final isSuccess = await authNotifier.login(
      phone,
      otp,
      role: selectedRole,
      referralCode: isCustomerRole && referralCode.isNotEmpty
          ? referralCode
          : null,
    );

    state = state.copyWith(isLoading: false);

    if (isSuccess) {
      final loggedInUser = _ref.read(authProvider);
      final resolvedRole = (loggedInUser?.roles.isNotEmpty ?? false)
          ? loggedInUser!.roles.first
          : selectedRole;

      final referralApplied =
          _ref.read(authRepositoryProvider).lastReferralApplied;

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

  String? _validatePhone(String value) {
    if (value.isEmpty) {
      return 'Please enter your mobile number.';
    }
    if (value.length < 10) {
      return 'Mobile number must be 10 digits.';
    }
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
      return 'Please enter a valid Indian mobile number.';
    }
    return null;
  }

  String? _validateUserName(String value) {
    if (value.isEmpty) {
      return 'Please enter your user name.';
    }
    if (value.length < 2) {
      return 'User name must be at least 2 characters.';
    }
    return null;
  }

  String? _validateReferral(String value) {
    if (value.trim().isEmpty) {
      return null;
    }
    if (value.length > 6) {
      return 'Referral code must be at most 6 characters.';
    }
    if (!RegExp(r'^[A-Z0-9]+$').hasMatch(value)) {
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
}
