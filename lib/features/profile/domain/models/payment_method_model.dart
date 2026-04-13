class PaymentMethodModel {
  final int id;
  final String type; // 'bank' or 'upi'
  final String? bankName;
  final String? accountNumber;
  final String? ifscCode;
  final String? accountHolderName;
  final String? upiId;
  final bool isDefault;

  PaymentMethodModel({
    required this.id,
    required this.type,
    this.bankName,
    this.accountNumber,
    this.ifscCode,
    this.accountHolderName,
    this.upiId,
    required this.isDefault,
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      type: json['type'] ?? 'bank',
      bankName: json['bank_name'],
      accountNumber: json['account_number'],
      ifscCode: json['ifsc_code'],
      accountHolderName: json['account_holder_name'],
      upiId: json['upi_id'],
      isDefault: json['is_default'] == true || json['is_default'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'account_number': accountNumber ?? '',
      'ifsc_code': ifscCode ?? '',
      'bank_name': bankName ?? '',
      'account_holder_name': accountHolderName ?? '',
      'upi_id': upiId ?? '',
      'is_default': isDefault,
    };
  }

  PaymentMethodModel copyWith({
    int? id,
    String? type,
    String? bankName,
    String? accountNumber,
    String? ifscCode,
    String? accountHolderName,
    String? upiId,
    bool? isDefault,
  }) {
    return PaymentMethodModel(
      id: id ?? this.id,
      type: type ?? this.type,
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      ifscCode: ifscCode ?? this.ifscCode,
      accountHolderName: accountHolderName ?? this.accountHolderName,
      upiId: upiId ?? this.upiId,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  bool get isBank => type == 'bank';
  bool get isUpi => type == 'upi';

  String get maskedAccountNumber {
    final value = accountNumber?.trim() ?? '';
    if (value.isEmpty) {
      return '';
    }

    final visibleDigits = value.length <= 4
        ? value
        : value.substring(value.length - 4);
    return '****$visibleDigits';
  }
}
