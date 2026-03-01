import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';

class LoginOtpScreen extends ConsumerStatefulWidget {
  final String? role;

  const LoginOtpScreen({super.key, this.role});

  @override
  ConsumerState<LoginOtpScreen> createState() => _LoginOtpScreenState();
}

class _LoginOtpScreenState extends ConsumerState<LoginOtpScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _otpSent = false;
  bool _isLoading = false;
  String? _phoneError;

  // ── Single hidden TextField for OTP ─────────────────────────────────────────
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _otpFocusNode = FocusNode();
  String _otpValue = '';
  bool _otpError = false; // turns boxes red on failed verification

  @override
  void initState() {
    super.initState();
    _otpController.addListener(() {
      setState(() => _otpValue = _otpController.text);
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _otpFocusNode.dispose();
    super.dispose();
  }

  // ── Phone validation ─────────────────────────────────────────────────────────

  String? _validatePhone(String value) {
    if (value.isEmpty) return 'Please enter your mobile number.';
    if (value.length < 10) return 'Mobile number must be 10 digits.';
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
      return 'Please enter a valid Indian mobile number.';
    }
    return null;
  }

  void _sendOtp() async {
    final phone = _phoneController.text.trim();
    final error = _validatePhone(phone);
    if (error != null) {
      setState(() => _phoneError = error);
      return;
    }
    setState(() {
      _phoneError = null;
      _isLoading = true;
    });

    final authRepo = ref.read(authRepositoryProvider);
    final selectedRole = widget.role ?? 'customer';
    final response = await authRepo.sendOtp(phone: phone, role: selectedRole);
    setState(() => _isLoading = false);

    if (response.isSuccess) {
      setState(() => _otpSent = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('OTP: ${response.data}')),
      );
      Future.delayed(const Duration(milliseconds: 100), () {
        _otpFocusNode.requestFocus();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.errorMessage ?? 'Failed to send OTP')),
      );
    }
  }

  void _verifyOtp() async {
    final phone = _phoneController.text.trim();
    final otp = _otpValue;

    if (otp.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the complete 4-digit OTP.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final authNotifier = ref.read(authProvider.notifier);
    final success = await authNotifier.login(phone, otp);
    setState(() => _isLoading = false);

    if (success) {
      final selectedRole = widget.role ?? 'customer';
      if (selectedRole == 'customer') {
        context.go(AppRoutes.customerDashboard);
      } else if (selectedRole == 'pickup_partner') {
        context.go(AppRoutes.pickupDashboard);
      } else if (selectedRole == 'warehouse') {
        context.go(AppRoutes.warehouseDashboard);
      } else if (selectedRole == 'dealer') {
        context.go(AppRoutes.partnerDashboard);
      } else {
        context.go(AppRoutes.customerDashboard);
      }
    } else {
      // Shake boxes red
      setState(() => _otpError = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Invalid OTP or login failed. Please try again.')),
      );
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  // ── Reusable action button ─────────────────────────────────────────────────
  Widget _buildActionButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      child: ElevatedButton(
        onPressed: _isLoading ? null : (_otpSent ? _verifyOtp : _sendOtp),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _otpSent
                        ? 'login.verify_otp'.tr()
                        : 'login.get_otp'.tr(),
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 8),
                  const FaIcon(FontAwesomeIcons.arrowRight, size: 20),
                ],
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // ── Button pinned to the bottom ────────────────────────────────────────
      bottomNavigationBar: _buildActionButton(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Top graphic block
              Container(
                height: 200.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5B99F),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _mockInputBar(),
                        const SizedBox(height: 8),
                        _mockInputBar(),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 32.h),

              // Title
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
              SizedBox(height: 8.h),
              SizedBox(height: 24.h),

              // Subtitle
              Text(
                _otpSent
                    ? 'Please enter the OTP sent to your number.'
                    : 'login.subtitle'.tr(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 16, color: AppTheme.textSecondary),
              ),
              SizedBox(height: 32.h),

              // ── Phone Input ──────────────────────────────────────────────────
              _buildPhoneField(),

              if (_phoneError != null) ...[
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.red, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        _phoneError!,
                        style:
                            const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],

              SizedBox(height: 16.h),

              // ── OTP 4-Box Input ──────────────────────────────────────────────
              if (_otpSent) ...[
                _buildOtpSection(),
                SizedBox(height: 24.h),
              ],

            ],
          ),
        ),
      ),
    );
  }

  // ── Phone field ──────────────────────────────────────────────────────────────

  Widget _buildPhoneField() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: _phoneError != null ? Colors.red : Colors.grey.shade300,
          width: _phoneError != null ? 1.5 : 1,
        ),
        borderRadius: BorderRadius.circular(30),
        color: _otpSent ? Colors.grey.shade100 : Colors.white,
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 8.0),
            child: Row(
              children: [
                FaIcon(FontAwesomeIcons.flag,
                    color: Colors.green.shade800, size: 20),
                const SizedBox(width: 8),
                const Text('+91',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),
          Container(height: 24, width: 1, color: Colors.grey.shade300),
          Expanded(
            child: TextField(
              controller: _phoneController,
              keyboardType: TextInputType.number,
              enabled: !_otpSent,
              maxLength: 10,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                _IndianMobileFormatter(),
                LengthLimitingTextInputFormatter(10),
              ],
              onChanged: (v) {
                if (_phoneError != null) {
                  setState(() => _phoneError = _validatePhone(v.trim()));
                }
              },
              decoration: InputDecoration(
                hintText: 'login.phone_hint'.tr(),
                hintStyle: const TextStyle(fontSize: 14),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                counterText: '',
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── OTP Section: hidden field + 4 display boxes ──────────────────────────────
  //
  // A zero-size TextField captures all keyboard input.
  // The 4 Container boxes are pure display widgets — NO TextField inside them,
  // so there is zero possibility of any cursor / selection / circle artifact.

  Widget _buildOtpSection() {
    return GestureDetector(
      onTap: () => _otpFocusNode.requestFocus(),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ── Hidden field (off-screen / invisible) ───────────────────────────
          Positioned(
            left: -300,
            child: SizedBox(
              width: 1,
              height: 1,
              child: TextField(
                controller: _otpController,
                focusNode: _otpFocusNode,
                keyboardType: TextInputType.number,
                maxLength: 4,
                showCursor: false,
                autofocus: false,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  counterText: '',
                ),
                onChanged: (v) {
                  setState(() {
                    _otpValue = v;
                    _otpError = false; // clear error as user re-types
                  });
                  if (v.length == 4) {
                    _otpFocusNode.unfocus();
                    _verifyOtp();
                  }
                },
              ),
            ),
          ),
          // ── 4 display boxes ─────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(4, (i) => _buildDisplayBox(i)),
          ),
        ],
      ),
    );
  }

  Widget _buildDisplayBox(int index) {
    final digit =
        index < _otpValue.length ? _otpValue[index] : '';
    final isCurrent =
        _otpFocusNode.hasFocus && index == _otpValue.length.clamp(0, 3);
    final isFilled = digit.isNotEmpty;

    // When API returns error, all boxes turn red
    final Color borderColor = _otpError
        ? Colors.red
        : isCurrent
            ? AppTheme.primaryColor
            : isFilled
                ? AppTheme.primaryColor.withValues(alpha: 0.5)
                : Colors.grey.shade300;

    final Color bgColor = _otpError
        ? Colors.red.withValues(alpha: 0.05)
        : isCurrent
            ? AppTheme.primaryColor.withValues(alpha: 0.05)
            : Colors.white;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 60.w,
      height: 60.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor,
          width: (_otpError || isCurrent) ? 2 : 1.5,
        ),
        color: bgColor,
        boxShadow: _otpError
            ? [
                BoxShadow(
                  color: Colors.red.withValues(alpha: 0.15),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ]
            : isCurrent
                ? [
                    BoxShadow(
                      color: AppTheme.primaryColor.withValues(alpha: 0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
      ),
      alignment: Alignment.center,
      child: Text(
        digit,
        style: TextStyle(
          fontSize: 22.sp,
          fontWeight: FontWeight.bold,
          color: _otpError ? Colors.red : AppTheme.textPrimary,
        ),
      ),
    );
  }

  Widget _mockInputBar() {
    return Container(
      width: 100,
      height: 24,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      alignment: Alignment.centerLeft,
      child: const Text(
        'Login',
        style: TextStyle(color: Colors.grey, fontSize: 10),
      ),
    );
  }
}

// ── Indian mobile number formatter ────────────────────────────────────────────

class _IndianMobileFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.isEmpty) return newValue;
    if (!RegExp(r'^[6-9]').hasMatch(text)) return oldValue;
    return newValue;
  }
}
