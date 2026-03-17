import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
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
  late final TextEditingController phoneController;
  late final TextEditingController otpController;
  late final FocusNode phoneFocusNode;
  late final FocusNode otpFocusNode;
  final String? _selectedRole;

  Timer? _timer;

  LoginOtpViewModel(this._ref, this._selectedRole)
    : super(const LoginOtpViewState()) {
    phoneController = TextEditingController();
    otpController = TextEditingController();
    phoneFocusNode = FocusNode();
    otpFocusNode = FocusNode();

    otpFocusNode.addListener(_handleOtpFocusChanged);

    _ref.onDispose(() {
      _timer?.cancel();
      phoneController.dispose();
      otpController.dispose();
      phoneFocusNode.dispose();
      otpFocusNode.removeListener(_handleOtpFocusChanged);
      otpFocusNode.dispose();
    });
  }

  String get selectedRole {
    return _selectedRole ?? 'customer';
  }

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

  void onOtpChanged(String value) {
    state = state.copyWith(otpValue: value, otpError: false);

    if (value.length == 6) {
      otpFocusNode.unfocus();
      unawaited(verifyOtp());
    }
  }

  Future<void> sendOtp() async {
    final phone = phoneController.text.trim();
    final error = _validatePhone(phone);

    if (error != null) {
      state = state.copyWith(phoneError: error);
      return;
    }

    state = state.copyWith(
      clearPhoneError: true,
      isLoading: true,
      otpError: false,
    );

    final authRepository = _ref.read(authRepositoryProvider);
    final response = await authRepository.sendOtp(
      phone: phone,
      role: selectedRole,
    );

    state = state.copyWith(isLoading: false);

    if (!response.isSuccess) {
      state = state.copyWith(
        snackBarMessage: response.errorMessage ?? 'Failed to send OTP',
      );
      return;
    }

    _startTimer();
    state = state.copyWith(
      otpSent: true,
      snackBarMessage: 'OTP: ${response.data}',
      shouldFocusOtp: true,
    );
  }

  Future<void> resendOtp() async {
    if (!state.canResendOtp || state.isLoading) {
      return;
    }

    await sendOtp();
  }

  Future<void> verifyOtp() async {
    final phone = phoneController.text.trim();
    final otp = state.otpValue;

    if (otp.length < 6) {
      state = state.copyWith(
        snackBarMessage: 'Please enter the complete 6-digit OTP.',
      );
      return;
    }

    state = state.copyWith(isLoading: true);
    final authNotifier = _ref.read(authProvider.notifier);
    final isSuccess = await authNotifier.login(phone, otp);

    state = state.copyWith(isLoading: false);

    if (isSuccess) {
      state = state.copyWith(
        nextRoute: RoleRouteResolver.resolve(selectedRole),
      );
      return;
    }

    state = state.copyWith(
      otpError: true,
      snackBarMessage: 'Invalid OTP or login failed. Please try again.',
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
