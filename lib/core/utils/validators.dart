/// Centralized form validators for Scrapify.
///
/// Conventions:
/// - Validators return `null` when the value is valid, or a human-readable
///   error string otherwise.
/// - "Required" is enforced explicitly via `Validators.required(...)` or by
///   composing it with another validator. Format-only validators (e.g.
///   `email`) treat empty strings as valid so they can be used on optional
///   fields. Use `combine([required, email])` for required-and-email fields.
/// - All validators are pure functions and safe to call from `TextFormField`'s
///   `validator:` callback or from manual `_formKey.currentState!.validate()`
///   flows.
class Validators {
  const Validators._();

  // ---------------------------------------------------------------------------
  // Composition
  // ---------------------------------------------------------------------------

  /// Combine multiple validators. The first non-null error wins.
  static String? Function(String?) combine(
    List<String? Function(String?)> validators,
  ) {
    return (value) {
      for (final v in validators) {
        final err = v(value);
        if (err != null) return err;
      }
      return null;
    };
  }

  // ---------------------------------------------------------------------------
  // Generic
  // ---------------------------------------------------------------------------

  /// Required field. Trims the value before checking emptiness.
  static String? required(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Minimum length (after trim). Empty values pass; combine with [required].
  static String? Function(String?) minLength(int n, {String fieldName = 'This field'}) {
    return (value) {
      if (value == null || value.trim().isEmpty) return null;
      if (value.trim().length < n) {
        return '$fieldName must be at least $n characters';
      }
      return null;
    };
  }

  /// Maximum length (after trim).
  static String? Function(String?) maxLength(int n, {String fieldName = 'This field'}) {
    return (value) {
      if (value == null) return null;
      if (value.trim().length > n) {
        return '$fieldName must be at most $n characters';
      }
      return null;
    };
  }

  /// Match a regex pattern. Empty values pass; combine with [required].
  static String? Function(String?) pattern(
    RegExp regex, {
    required String message,
  }) {
    return (value) {
      if (value == null || value.isEmpty) return null;
      if (!regex.hasMatch(value)) return message;
      return null;
    };
  }

  // ---------------------------------------------------------------------------
  // Names / addresses
  // ---------------------------------------------------------------------------

  /// Person name: 2–50 characters, letters / spaces / hyphen / dot / apostrophe.
  static String? name(String? value, {String fieldName = 'Name'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    final trimmed = value.trim();
    if (trimmed.length < 2) return '$fieldName is too short';
    if (trimmed.length > 50) return '$fieldName is too long';
    final ok = RegExp(r"^[A-Za-z][A-Za-z\s.\-']{1,49}$").hasMatch(trimmed);
    if (!ok) return 'Enter a valid $fieldName';
    return null;
  }

  /// Free-form address line: 5–200 characters.
  static String? address(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Address is required';
    }
    final trimmed = value.trim();
    if (trimmed.length < 5) return 'Address looks too short';
    if (trimmed.length > 200) return 'Address is too long';
    return null;
  }

  /// City / area / state / district name: 2–60 characters, letters/spaces/hyphen.
  static String? cityOrArea(String? value, {String fieldName = 'City'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    final trimmed = value.trim();
    if (trimmed.length < 2 || trimmed.length > 60) {
      return 'Enter a valid $fieldName';
    }
    if (!RegExp(r"^[A-Za-z][A-Za-z\s.\-']{1,59}$").hasMatch(trimmed)) {
      return 'Enter a valid $fieldName';
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Phone / OTP
  // ---------------------------------------------------------------------------

  /// Indian mobile: exactly 10 digits, must start with 6/7/8/9.
  /// Strips a leading `+91` or `0` so the user can paste in either form.
  static String? indianMobile(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Mobile number is required';
    }
    var v = value.trim().replaceAll(RegExp(r'\s+'), '');
    if (v.startsWith('+91')) v = v.substring(3);
    if (v.startsWith('91') && v.length == 12) v = v.substring(2);
    if (v.startsWith('0')) v = v.substring(1);
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(v)) {
      return 'Enter a valid 10-digit Indian mobile number';
    }
    return null;
  }

  /// Numeric OTP of [length] digits (default 6).
  static String? Function(String?) otp({int length = 6}) {
    return (value) {
      if (value == null || value.isEmpty) return 'Enter the OTP';
      if (!RegExp(r'^\d+$').hasMatch(value)) {
        return 'OTP must contain only digits';
      }
      if (value.length != length) return 'OTP must be $length digits';
      return null;
    };
  }

  // ---------------------------------------------------------------------------
  // Email / web
  // ---------------------------------------------------------------------------

  /// Email — RFC-light. Pass empty for optional fields.
  static String? email(String? value, {bool requiredField = false}) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) {
      return requiredField ? 'Email is required' : null;
    }
    final ok = RegExp(
      r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(v);
    if (!ok) return 'Enter a valid email address';
    return null;
  }

  // ---------------------------------------------------------------------------
  // Indian-format identifiers
  // ---------------------------------------------------------------------------

  /// Indian PIN code: 6 digits, first digit 1-9 (no leading zero).
  static String? pinCode(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'PIN code is required';
    if (!RegExp(r'^[1-9]\d{5}$').hasMatch(v)) {
      return 'Enter a valid 6-digit PIN code';
    }
    return null;
  }

  /// Aadhaar: 12 digits. Allows spaces; doesn't enforce Verhoeff checksum.
  static String? aadhaar(String? value) {
    final v = value?.replaceAll(RegExp(r'\s+'), '') ?? '';
    if (v.isEmpty) return 'Aadhaar number is required';
    if (!RegExp(r'^\d{12}$').hasMatch(v)) {
      return 'Enter a valid 12-digit Aadhaar number';
    }
    return null;
  }

  /// PAN: AAAAA9999A (5 letters, 4 digits, 1 letter), case-insensitive input.
  static String? pan(String? value) {
    final v = value?.trim().toUpperCase() ?? '';
    if (v.isEmpty) return 'PAN is required';
    if (!RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$').hasMatch(v)) {
      return 'Enter a valid PAN (e.g. ABCDE1234F)';
    }
    return null;
  }

  /// IFSC: 4 letters + 0 + 6 alphanumeric, case-insensitive input.
  static String? ifsc(String? value) {
    final v = value?.trim().toUpperCase() ?? '';
    if (v.isEmpty) return 'IFSC code is required';
    if (!RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$').hasMatch(v)) {
      return 'Enter a valid IFSC code';
    }
    return null;
  }

  /// Bank account number: 9–18 digits.
  static String? accountNumber(String? value) {
    final v = value?.replaceAll(RegExp(r'\s+'), '') ?? '';
    if (v.isEmpty) return 'Account number is required';
    if (!RegExp(r'^\d{9,18}$').hasMatch(v)) {
      return 'Enter a valid account number';
    }
    return null;
  }

  /// UPI VPA: e.g. `name@bank`. Letters, digits, `.`, `-`, `_` either side of `@`.
  static String? upi(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'UPI ID is required';
    if (!RegExp(r'^[a-zA-Z0-9.\-_]{2,256}@[a-zA-Z]{2,64}$').hasMatch(v)) {
      return 'Enter a valid UPI ID (e.g. name@bank)';
    }
    return null;
  }

  /// GSTIN: 15 chars — 2 digits state, 10 chars PAN, 1 digit entity, `Z`, 1 alphanumeric check.
  static String? gstin(String? value) {
    final v = value?.trim().toUpperCase() ?? '';
    if (v.isEmpty) return 'GSTIN is required';
    final ok = RegExp(
      r'^\d{2}[A-Z]{5}\d{4}[A-Z]\d[A-Z]Z[A-Z\d]$',
    ).hasMatch(v);
    if (!ok) return 'Enter a valid GSTIN';
    return null;
  }

  // ---------------------------------------------------------------------------
  // Numbers
  // ---------------------------------------------------------------------------

  /// Positive non-zero number (decimals allowed). Used for weights.
  static String? positiveNumber(String? value, {String fieldName = 'Value'}) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return '$fieldName is required';
    final n = double.tryParse(v);
    if (n == null) return 'Enter a valid number';
    if (n <= 0) return '$fieldName must be greater than 0';
    return null;
  }

  /// Positive integer (no decimals). Used for quantities.
  static String? positiveInteger(String? value, {String fieldName = 'Quantity'}) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return '$fieldName is required';
    final n = int.tryParse(v);
    if (n == null) return '$fieldName must be a whole number';
    if (n <= 0) return '$fieldName must be greater than 0';
    return null;
  }

  /// Weight in kg: 0.01 .. 10000.
  static String? weight(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Weight is required';
    final n = double.tryParse(v);
    if (n == null) return 'Enter a valid weight';
    if (n < 0.01) return 'Weight is too small';
    if (n > 10000) return 'Weight is too large';
    return null;
  }

  /// Money / rate per kg: 0 .. 1,00,000. Allows 0 to mark "no rate".
  static String? rate(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Rate is required';
    final n = double.tryParse(v);
    if (n == null) return 'Enter a valid rate';
    if (n < 0) return 'Rate cannot be negative';
    if (n > 100000) return 'Rate is unreasonably large';
    return null;
  }

  // ---------------------------------------------------------------------------
  // Dates
  // ---------------------------------------------------------------------------

  /// Reject dates strictly in the past (compared against DateTime.now() at the
  /// day boundary). Returns null for null input — pair with a "required"
  /// adjacent check in your screen if the date is mandatory.
  static String? notInPast(DateTime? value, {String fieldName = 'Date'}) {
    if (value == null) return null;
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);
    if (value.isBefore(start)) {
      return '$fieldName cannot be in the past';
    }
    return null;
  }

  /// Require a future-or-now [DateTime] (used for scheduled pickups).
  static String? scheduledAt(DateTime? value) {
    if (value == null) return 'Pick a date and time';
    if (value.isBefore(DateTime.now())) {
      return 'Pick a date and time in the future';
    }
    return null;
  }
}
