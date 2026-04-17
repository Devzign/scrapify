class LoginOtpViewState {
  final bool otpSent;
  final bool isLoading;
  final bool otpError;
  final bool canResendOtp;
  final bool shouldFocusOtp;
  final bool isOtpFieldFocused;
  final String otpValue;
  final String? phoneError;
  final String? snackBarMessage;
  final bool isSuccessMessage;
  final String? nextRoute;
  final int secondsRemaining;

  const LoginOtpViewState({
    this.otpSent = false,
    this.isLoading = false,
    this.otpError = false,
    this.canResendOtp = false,
    this.shouldFocusOtp = false,
    this.isOtpFieldFocused = false,
    this.otpValue = '',
    this.phoneError,
    this.snackBarMessage,
    this.isSuccessMessage = false,
    this.nextRoute,
    this.secondsRemaining = 30,
  });

  LoginOtpViewState copyWith({
    bool? otpSent,
    bool? isLoading,
    bool? otpError,
    bool? canResendOtp,
    bool? shouldFocusOtp,
    bool? isOtpFieldFocused,
    String? otpValue,
    String? phoneError,
    String? snackBarMessage,
    bool? isSuccessMessage,
    String? nextRoute,
    int? secondsRemaining,
    bool clearPhoneError = false,
    bool clearSnackBarMessage = false,
    bool clearNextRoute = false,
  }) {
    return LoginOtpViewState(
      otpSent: otpSent ?? this.otpSent,
      isLoading: isLoading ?? this.isLoading,
      otpError: otpError ?? this.otpError,
      canResendOtp: canResendOtp ?? this.canResendOtp,
      shouldFocusOtp: shouldFocusOtp ?? this.shouldFocusOtp,
      isOtpFieldFocused: isOtpFieldFocused ?? this.isOtpFieldFocused,
      otpValue: otpValue ?? this.otpValue,
      phoneError: clearPhoneError ? null : phoneError ?? this.phoneError,
      snackBarMessage: clearSnackBarMessage
          ? null
          : snackBarMessage ?? this.snackBarMessage,
      isSuccessMessage: isSuccessMessage ?? this.isSuccessMessage,
      nextRoute: clearNextRoute ? null : nextRoute ?? this.nextRoute,
      secondsRemaining: secondsRemaining ?? this.secondsRemaining,
    );
  }
}
