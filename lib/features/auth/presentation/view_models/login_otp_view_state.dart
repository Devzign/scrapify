class LoginOtpViewState {
  final bool otpSent;
  final bool isLoading;
  final bool otpError;
  final bool canResendOtp;
  final bool shouldFocusOtp;
  final bool isOtpFieldFocused;
  final bool showReferralInput;
  final String otpValue;
  final String? phoneError;
  final String? referralError;
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
    this.showReferralInput = false,
    this.otpValue = '',
    this.phoneError,
    this.referralError,
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
    bool? showReferralInput,
    String? otpValue,
    String? phoneError,
    String? referralError,
    String? snackBarMessage,
    bool? isSuccessMessage,
    String? nextRoute,
    int? secondsRemaining,
    bool clearPhoneError = false,
    bool clearReferralError = false,
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
      showReferralInput: showReferralInput ?? this.showReferralInput,
      otpValue: otpValue ?? this.otpValue,
      phoneError: clearPhoneError ? null : phoneError ?? this.phoneError,
      referralError: clearReferralError
          ? null
          : referralError ?? this.referralError,
      snackBarMessage: clearSnackBarMessage
          ? null
          : snackBarMessage ?? this.snackBarMessage,
      isSuccessMessage: isSuccessMessage ?? this.isSuccessMessage,
      nextRoute: clearNextRoute ? null : nextRoute ?? this.nextRoute,
      secondsRemaining: secondsRemaining ?? this.secondsRemaining,
    );
  }
}
