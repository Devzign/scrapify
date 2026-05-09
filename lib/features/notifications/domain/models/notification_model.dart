class NotificationModel {
  final String id;
  final String title;
  final String body;
  final bool isRead;
  final DateTime createdAt;
  final Map<String, dynamic>? data;
  final DateTime? readAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.isRead,
    required this.createdAt,
    this.data,
    this.readAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final payload = json['data'];
    final payloadMap = payload is Map
        ? Map<String, dynamic>.from(payload)
        : null;
    final readAt = _parseDateTime(json['read_at']);
    return NotificationModel(
      id: json['id'].toString(),
      title:
          payloadMap?['title']?.toString() ??
          json['title']?.toString() ??
          '',
      body:
          payloadMap?['message']?.toString() ??
          payloadMap?['body']?.toString() ??
          json['message']?.toString() ??
          json['body']?.toString() ??
          '',
      isRead: readAt != null || json['is_read'] == true || json['is_read'] == 1,
      createdAt: _parseDateTime(json['created_at']) ?? DateTime.now(),
      data: payloadMap,
      readAt: readAt,
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) {
      return null;
    }
    return DateTime.tryParse(value.toString());
  }
}
