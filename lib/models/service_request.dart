import 'address.dart';

enum ServiceRequestStatus {
  draft,
  pending,
  accepted,
  inProgress,
  completed,
  cancelled,
}

class ServiceRequest {
  const ServiceRequest({
    required this.id,
    required this.clientId,
    required this.serviceId,
    required this.providerId,
    required this.address,
    required this.preferredDate,
    required this.timeSlot,
    required this.problemDescription,
    required this.estimatedTotal,
    required this.currency,
    required this.status,
    required this.createdAt,
    this.photoUrls = const [],
    this.isEmergency = false,
    this.acceptedAt,
    this.cancelledAt,
  });

  final String id;
  final String clientId;
  final String serviceId;
  final String providerId;
  final Address address;
  final DateTime preferredDate;
  final String timeSlot;
  final String problemDescription;
  final double estimatedTotal;
  final String currency;
  final ServiceRequestStatus status;
  final DateTime createdAt;
  final List<String> photoUrls;
  final bool isEmergency;
  final DateTime? acceptedAt;
  final DateTime? cancelledAt;

  ServiceRequest copyWith({
    String? id,
    String? clientId,
    String? serviceId,
    String? providerId,
    Address? address,
    DateTime? preferredDate,
    String? timeSlot,
    String? problemDescription,
    double? estimatedTotal,
    String? currency,
    ServiceRequestStatus? status,
    DateTime? createdAt,
    List<String>? photoUrls,
    bool? isEmergency,
    DateTime? acceptedAt,
    DateTime? cancelledAt,
  }) {
    return ServiceRequest(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      serviceId: serviceId ?? this.serviceId,
      providerId: providerId ?? this.providerId,
      address: address ?? this.address,
      preferredDate: preferredDate ?? this.preferredDate,
      timeSlot: timeSlot ?? this.timeSlot,
      problemDescription: problemDescription ?? this.problemDescription,
      estimatedTotal: estimatedTotal ?? this.estimatedTotal,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      photoUrls: photoUrls ?? this.photoUrls,
      isEmergency: isEmergency ?? this.isEmergency,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
    );
  }

  factory ServiceRequest.fromMap(Map<String, dynamic> map) {
    return ServiceRequest(
      id: map['id'] as String? ?? '',
      clientId: map['clientId'] as String? ?? '',
      serviceId: map['serviceId'] as String? ?? '',
      providerId: map['providerId'] as String? ?? '',
      address: Address.fromMap(
        Map<String, dynamic>.from(map['address'] as Map? ?? const {}),
      ),
      preferredDate:
          DateTime.tryParse(map['preferredDate'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      timeSlot: map['timeSlot'] as String? ?? '',
      problemDescription: map['problemDescription'] as String? ?? '',
      estimatedTotal: (map['estimatedTotal'] as num?)?.toDouble() ?? 0,
      currency: map['currency'] as String? ?? 'USD',
      status: ServiceRequestStatus.values.byName(
        map['status'] as String? ?? 'draft',
      ),
      createdAt:
          DateTime.tryParse(map['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      photoUrls: List<String>.from(
        map['photoUrls'] as List<dynamic>? ?? const [],
      ),
      isEmergency: map['isEmergency'] as bool? ?? false,
      acceptedAt: DateTime.tryParse(map['acceptedAt'] as String? ?? ''),
      cancelledAt: DateTime.tryParse(map['cancelledAt'] as String? ?? ''),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'clientId': clientId,
      'serviceId': serviceId,
      'providerId': providerId,
      'address': address.toMap(),
      'preferredDate': preferredDate.toIso8601String(),
      'timeSlot': timeSlot,
      'problemDescription': problemDescription,
      'estimatedTotal': estimatedTotal,
      'currency': currency,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'photoUrls': photoUrls,
      'isEmergency': isEmergency,
      'acceptedAt': acceptedAt?.toIso8601String(),
      'cancelledAt': cancelledAt?.toIso8601String(),
    };
  }
}
