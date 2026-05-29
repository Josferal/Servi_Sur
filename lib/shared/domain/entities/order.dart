import 'address.dart';
import 'date_value_parser.dart';

enum OrderStatus { pending, accepted, inProgress, active, completed, cancelled }

enum OrderTrackingStatus {
  requested,
  assigned,
  onTheWay,
  arrived,
  working,
  completed,
}

class Order {
  const Order({
    required this.id,
    required this.requestId,
    required this.clientId,
    this.clientName = '',
    this.clientEmail = '',
    required this.providerId,
    required this.serviceId,
    required this.title,
    required this.providerName,
    required this.category,
    this.categoryId = '',
    this.description = '',
    this.scheduledTime = '',
    this.trackingStatus = OrderTrackingStatus.requested,
    required this.scheduledAt,
    required this.address,
    required this.subtotal,
    required this.platformFee,
    required this.total,
    required this.currency,
    required this.status,
    required this.createdAt,
    this.imageUrls = const [],
    this.imagePaths = const [],
    this.attachments = const [],
    this.completedAt,
    this.cancelledAt,
  });

  final String id;
  final String requestId;
  final String clientId;
  final String clientName;
  final String clientEmail;
  final String providerId;
  final String serviceId;
  final String title;
  final String providerName;
  final String category;
  final String categoryId;
  final String description;
  final String scheduledTime;
  final OrderTrackingStatus trackingStatus;
  final DateTime scheduledAt;
  final Address address;
  final double subtotal;
  final double platformFee;
  final double total;
  final String currency;
  final OrderStatus status;
  final DateTime createdAt;
  final List<String> imageUrls;
  final List<String> imagePaths;
  final List<Map<String, dynamic>> attachments;
  final DateTime? completedAt;
  final DateTime? cancelledAt;

  String get date {
    final day = scheduledAt.day.toString().padLeft(2, '0');
    final month = scheduledAt.month.toString().padLeft(2, '0');
    final hour = scheduledAt.hour.toString().padLeft(2, '0');
    final minute = scheduledAt.minute.toString().padLeft(2, '0');
    return '$day/$month, $hour:$minute';
  }

  Order copyWith({
    String? id,
    String? requestId,
    String? clientId,
    String? clientName,
    String? clientEmail,
    String? providerId,
    String? serviceId,
    String? title,
    String? providerName,
    String? category,
    String? categoryId,
    String? description,
    String? scheduledTime,
    OrderTrackingStatus? trackingStatus,
    DateTime? scheduledAt,
    Address? address,
    double? subtotal,
    double? platformFee,
    double? total,
    String? currency,
    OrderStatus? status,
    DateTime? createdAt,
    List<String>? imageUrls,
    List<String>? imagePaths,
    List<Map<String, dynamic>>? attachments,
    DateTime? completedAt,
    DateTime? cancelledAt,
  }) {
    return Order(
      id: id ?? this.id,
      requestId: requestId ?? this.requestId,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      clientEmail: clientEmail ?? this.clientEmail,
      providerId: providerId ?? this.providerId,
      serviceId: serviceId ?? this.serviceId,
      title: title ?? this.title,
      providerName: providerName ?? this.providerName,
      category: category ?? this.category,
      categoryId: categoryId ?? this.categoryId,
      description: description ?? this.description,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      trackingStatus: trackingStatus ?? this.trackingStatus,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      address: address ?? this.address,
      subtotal: subtotal ?? this.subtotal,
      platformFee: platformFee ?? this.platformFee,
      total: total ?? this.total,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      imageUrls: imageUrls ?? this.imageUrls,
      imagePaths: imagePaths ?? this.imagePaths,
      attachments: attachments ?? this.attachments,
      completedAt: completedAt ?? this.completedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
    );
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'] as String? ?? '',
      requestId: map['requestId'] as String? ?? '',
      clientId: map['clientId'] as String? ?? '',
      clientName: map['clientName'] as String? ?? '',
      clientEmail: map['clientEmail'] as String? ?? '',
      providerId: map['providerId'] as String? ?? '',
      serviceId: map['serviceId'] as String? ?? '',
      title: map['title'] as String? ?? map['serviceTitle'] as String? ?? '',
      providerName: map['providerName'] as String? ?? '',
      category:
          map['category'] as String? ?? map['categoryName'] as String? ?? '',
      categoryId: map['categoryId'] as String? ?? '',
      description: map['description'] as String? ?? '',
      scheduledTime: map['scheduledTime'] as String? ?? '',
      trackingStatus: _trackingStatusFromValue(map['trackingStatus']),
      scheduledAt: _dateFromValue(map['scheduledAt'] ?? map['scheduledDate']),
      address: Address.fromMap(
        Map<String, dynamic>.from(
          map['address'] as Map? ??
              {
                'fullAddress': map['addressText'] as String? ?? '',
                'label': 'Servicio',
              },
        ),
      ),
      subtotal:
          (map['subtotal'] as num?)?.toDouble() ??
          (map['totalAmount'] as num?)?.toDouble() ??
          0,
      platformFee: (map['platformFee'] as num?)?.toDouble() ?? 0,
      total:
          (map['total'] as num?)?.toDouble() ??
          (map['totalAmount'] as num?)?.toDouble() ??
          0,
      currency: map['currency'] as String? ?? 'USD',
      status: _statusFromValue(map['status']),
      createdAt: _dateFromValue(map['createdAt']),
      imageUrls: _stringListFromValue(map['imageUrls'] ?? map['photoUrls']),
      imagePaths: _stringListFromValue(map['imagePaths']),
      attachments: _mapListFromValue(map['attachments']),
      completedAt: _nullableDateFromValue(map['completedAt']),
      cancelledAt: _nullableDateFromValue(map['cancelledAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'requestId': requestId,
      'clientId': clientId,
      'clientName': clientName,
      'clientEmail': clientEmail,
      'providerId': providerId,
      'serviceId': serviceId,
      'title': title,
      'serviceTitle': title,
      'providerName': providerName,
      'category': category,
      'categoryId': categoryId,
      'categoryName': category,
      'description': description,
      'scheduledTime': scheduledTime,
      'trackingStatus': trackingStatus.name,
      'scheduledAt': scheduledAt.toIso8601String(),
      'scheduledDate': scheduledAt.toIso8601String(),
      'address': address.toMap(),
      'addressText': address.fullAddress,
      'subtotal': subtotal,
      'platformFee': platformFee,
      'total': total,
      'totalAmount': total,
      'currency': currency,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'imageUrls': imageUrls,
      'imagePaths': imagePaths,
      'attachments': attachments,
      'completedAt': completedAt?.toIso8601String(),
      'cancelledAt': cancelledAt?.toIso8601String(),
    };
  }

  static OrderStatus _statusFromValue(Object? value) {
    final name = value as String? ?? 'pending';
    try {
      return OrderStatus.values.byName(name);
    } on ArgumentError {
      return name == 'accepted' ? OrderStatus.active : OrderStatus.pending;
    }
  }

  static OrderTrackingStatus _trackingStatusFromValue(Object? value) {
    final name = value as String? ?? 'requested';
    try {
      return OrderTrackingStatus.values.byName(name);
    } on ArgumentError {
      return OrderTrackingStatus.requested;
    }
  }

  static DateTime _dateFromValue(Object? value) {
    return _nullableDateFromValue(value) ??
        DateTime.fromMillisecondsSinceEpoch(0);
  }

  static DateTime? _nullableDateFromValue(Object? value) {
    return dateTimeFromValue(value);
  }

  static List<String> _stringListFromValue(Object? value) {
    if (value is Iterable) {
      return value.whereType<String>().toList();
    }
    return const [];
  }

  static List<Map<String, dynamic>> _mapListFromValue(Object? value) {
    if (value is Iterable) {
      return value
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }
    return const [];
  }
}
