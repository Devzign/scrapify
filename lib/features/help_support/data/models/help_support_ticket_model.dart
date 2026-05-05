class HelpSupportTicketModel {
  final int? id;
  final String subject;
  final String message;
  final String? phone;
  final int? orderId;
  final String? status;
  final DateTime? createdAt;

  const HelpSupportTicketModel({
    this.id,
    required this.subject,
    required this.message,
    this.phone,
    this.orderId,
    this.status,
    this.createdAt,
  });

  factory HelpSupportTicketModel.fromJson(Map<String, dynamic> json) {
    return HelpSupportTicketModel(
      id: _asInt(json['id']),
      subject: json['subject']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      phone: json['phone']?.toString(),
      orderId: _asInt(json['order_id']),
      status: json['status']?.toString(),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
    );
  }
}

int? _asInt(dynamic value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '');
}
