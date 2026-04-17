class KycDocumentModel {
  final int id;
  final String documentType;
  final String? documentNumber;
  final String imageUrl;
  final String status;
  final String? rejectionReason;
  final DateTime? createdAt;

  KycDocumentModel({
    required this.id,
    required this.documentType,
    this.documentNumber,
    required this.imageUrl,
    required this.status,
    this.rejectionReason,
    this.createdAt,
  });

  factory KycDocumentModel.fromJson(Map<String, dynamic> json) {
    return KycDocumentModel(
      id: _parseInt(json['id']) ?? 0,
      documentType: json['document_type']?.toString() ?? '',
      documentNumber: json['document_number']?.toString(),
      imageUrl: json['image']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      rejectionReason: json['rejection_reason']?.toString(),
      createdAt: _parseDateTime(json['created_at']),
    );
  }

  static int? _parseInt(dynamic value) {
    if (value is int) return value;
    if (value == null) return null;
    return int.tryParse(value.toString());
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
