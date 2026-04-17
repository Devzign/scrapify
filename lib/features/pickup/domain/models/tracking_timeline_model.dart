class TrackingTimelineModel {
  final int id;
  final String pickupCode;
  final String status;
  final DateTime? scheduledAt;
  final double? latitude;
  final double? longitude;
  final TrackingAgent? agent;
  final List<TrackingEvent> events;

  TrackingTimelineModel({
    required this.id,
    required this.pickupCode,
    required this.status,
    required this.scheduledAt,
    this.latitude,
    this.longitude,
    required this.agent,
    required this.events,
  });

  factory TrackingTimelineModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? const {};
    final timeline = data['timeline'] as List<dynamic>? ?? const [];

    return TrackingTimelineModel(
      id: (data['id'] as num?)?.toInt() ?? 0,
      pickupCode: data['pickup_code']?.toString() ?? '',
      status: data['status']?.toString() ?? '',
      scheduledAt: _parseDateTime(data['scheduled_at']?.toString()),
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      agent: data['agent'] is Map<String, dynamic>
          ? TrackingAgent.fromJson(data['agent'] as Map<String, dynamic>)
          : null,
      events: timeline
          .map((e) => TrackingEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class TrackingAgent {
  final String name;
  final String? phone;
  final String? vehicle;
  final double? rating;
  final String? imageUrl;

  TrackingAgent({
    required this.name,
    this.phone,
    this.vehicle,
    this.rating,
    this.imageUrl,
  });

  factory TrackingAgent.fromJson(Map<String, dynamic> json) {
    return TrackingAgent(
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString(),
      vehicle:
          json['vehicle']?.toString() ?? json['vehicle_number']?.toString(),
      rating: (json['rating'] as num?)?.toDouble(),
      imageUrl: json['image']?.toString() ?? json['avatar']?.toString(),
    );
  }
}

class TrackingEvent {
  final String status;
  final String title;
  final String? description;
  final DateTime? timestamp;
  final bool isCompleted;

  TrackingEvent({
    required this.status,
    required this.title,
    this.description,
    required this.timestamp,
    required this.isCompleted,
  });

  factory TrackingEvent.fromJson(Map<String, dynamic> json) {
    final status = json['status']?.toString() ?? '';

    return TrackingEvent(
      status: status,
      title: json['label']?.toString() ?? json['title']?.toString() ?? status,
      description: json['description']?.toString(),
      timestamp: _parseDateTime(
        json['time']?.toString() ?? json['timestamp']?.toString(),
      ),
      isCompleted: json['is_completed'] == true || status != 'pending',
    );
  }
}

DateTime? _parseDateTime(String? value) {
  if (value == null || value.isEmpty) {
    return null;
  }

  return DateTime.tryParse(value);
}
