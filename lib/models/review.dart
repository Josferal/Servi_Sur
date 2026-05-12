class Review {
  const Review({
    required this.id,
    required this.orderId,
    required this.serviceId,
    required this.providerId,
    required this.clientId,
    required this.clientName,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.clientAvatarUrl,
    this.isPublic = true,
  });

  final String id;
  final String orderId;
  final String serviceId;
  final String providerId;
  final String clientId;
  final String clientName;
  final double rating;
  final String comment;
  final DateTime createdAt;
  final String? clientAvatarUrl;
  final bool isPublic;

  Review copyWith({
    String? id,
    String? orderId,
    String? serviceId,
    String? providerId,
    String? clientId,
    String? clientName,
    double? rating,
    String? comment,
    DateTime? createdAt,
    String? clientAvatarUrl,
    bool? isPublic,
  }) {
    return Review(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      serviceId: serviceId ?? this.serviceId,
      providerId: providerId ?? this.providerId,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      clientAvatarUrl: clientAvatarUrl ?? this.clientAvatarUrl,
      isPublic: isPublic ?? this.isPublic,
    );
  }

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      id: map['id'] as String? ?? '',
      orderId: map['orderId'] as String? ?? '',
      serviceId: map['serviceId'] as String? ?? '',
      providerId: map['providerId'] as String? ?? '',
      clientId: map['clientId'] as String? ?? '',
      clientName: map['clientName'] as String? ?? '',
      rating: (map['rating'] as num?)?.toDouble() ?? 0,
      comment: map['comment'] as String? ?? '',
      createdAt:
          DateTime.tryParse(map['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      clientAvatarUrl: map['clientAvatarUrl'] as String?,
      isPublic: map['isPublic'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'orderId': orderId,
      'serviceId': serviceId,
      'providerId': providerId,
      'clientId': clientId,
      'clientName': clientName,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
      'clientAvatarUrl': clientAvatarUrl,
      'isPublic': isPublic,
    };
  }
}
