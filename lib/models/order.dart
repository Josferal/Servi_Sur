import 'address.dart';

enum OrderStatus { active, completed, cancelled }

class Order {
  const Order({
    required this.id,
    required this.requestId,
    required this.clientId,
    required this.providerId,
    required this.serviceId,
    required this.title,
    required this.providerName,
    required this.category,
    required this.scheduledAt,
    required this.address,
    required this.subtotal,
    required this.platformFee,
    required this.total,
    required this.currency,
    required this.status,
    required this.createdAt,
    this.completedAt,
    this.cancelledAt,
  });

  final String id;
  final String requestId;
  final String clientId;
  final String providerId;
  final String serviceId;
  final String title;
  final String providerName;
  final String category;
  final DateTime scheduledAt;
  final Address address;
  final double subtotal;
  final double platformFee;
  final double total;
  final String currency;
  final OrderStatus status;
  final DateTime createdAt;
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
    String? providerId,
    String? serviceId,
    String? title,
    String? providerName,
    String? category,
    DateTime? scheduledAt,
    Address? address,
    double? subtotal,
    double? platformFee,
    double? total,
    String? currency,
    OrderStatus? status,
    DateTime? createdAt,
    DateTime? completedAt,
    DateTime? cancelledAt,
  }) {
    return Order(
      id: id ?? this.id,
      requestId: requestId ?? this.requestId,
      clientId: clientId ?? this.clientId,
      providerId: providerId ?? this.providerId,
      serviceId: serviceId ?? this.serviceId,
      title: title ?? this.title,
      providerName: providerName ?? this.providerName,
      category: category ?? this.category,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      address: address ?? this.address,
      subtotal: subtotal ?? this.subtotal,
      platformFee: platformFee ?? this.platformFee,
      total: total ?? this.total,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
    );
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'] as String? ?? '',
      requestId: map['requestId'] as String? ?? '',
      clientId: map['clientId'] as String? ?? '',
      providerId: map['providerId'] as String? ?? '',
      serviceId: map['serviceId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      providerName: map['providerName'] as String? ?? '',
      category: map['category'] as String? ?? '',
      scheduledAt:
          DateTime.tryParse(map['scheduledAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      address: Address.fromMap(
        Map<String, dynamic>.from(map['address'] as Map? ?? const {}),
      ),
      subtotal: (map['subtotal'] as num?)?.toDouble() ?? 0,
      platformFee: (map['platformFee'] as num?)?.toDouble() ?? 0,
      total: (map['total'] as num?)?.toDouble() ?? 0,
      currency: map['currency'] as String? ?? 'USD',
      status: OrderStatus.values.byName(map['status'] as String? ?? 'active'),
      createdAt:
          DateTime.tryParse(map['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      completedAt: DateTime.tryParse(map['completedAt'] as String? ?? ''),
      cancelledAt: DateTime.tryParse(map['cancelledAt'] as String? ?? ''),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'requestId': requestId,
      'clientId': clientId,
      'providerId': providerId,
      'serviceId': serviceId,
      'title': title,
      'providerName': providerName,
      'category': category,
      'scheduledAt': scheduledAt.toIso8601String(),
      'address': address.toMap(),
      'subtotal': subtotal,
      'platformFee': platformFee,
      'total': total,
      'currency': currency,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'cancelledAt': cancelledAt?.toIso8601String(),
    };
  }
}
