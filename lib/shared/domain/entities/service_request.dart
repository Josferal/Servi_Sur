import 'address.dart';
import 'date_value_parser.dart';

enum ServiceRequestStatus {
  draft,
  pending,
  accepted,
  rejected,
  cancelled,
  convertedToOrder,
}

class ServiceRequest {
  const ServiceRequest({
    required this.id,
    required this.clientId,
    this.clientName = '',
    this.clientEmail = '',
    required this.serviceId,
    this.serviceTitle = '',
    this.categoryId = '',
    this.categoryName = '',
    this.providerName = '',
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
    this.imageUrls = const [],
    this.imagePaths = const [],
    this.attachments = const [],
    this.isEmergency = false,
    this.acceptedAt,
    this.cancelledAt,
  });

  final String id;
  final String clientId;
  final String clientName;
  final String clientEmail;
  final String serviceId;
  final String serviceTitle;
  final String categoryId;
  final String categoryName;
  final String providerId;
  final String providerName;
  final Address address;
  final DateTime preferredDate;
  final String timeSlot;
  final String problemDescription;
  final double estimatedTotal;
  final String currency;
  final ServiceRequestStatus status;
  final DateTime createdAt;
  final List<String> photoUrls;
  final List<String> imageUrls;
  final List<String> imagePaths;
  final List<Map<String, dynamic>> attachments;
  final bool isEmergency;
  final DateTime? acceptedAt;
  final DateTime? cancelledAt;

  ServiceRequest copyWith({
    String? id,
    String? clientId,
    String? clientName,
    String? clientEmail,
    String? serviceId,
    String? serviceTitle,
    String? categoryId,
    String? categoryName,
    String? providerId,
    String? providerName,
    Address? address,
    DateTime? preferredDate,
    String? timeSlot,
    String? problemDescription,
    double? estimatedTotal,
    String? currency,
    ServiceRequestStatus? status,
    DateTime? createdAt,
    List<String>? photoUrls,
    List<String>? imageUrls,
    List<String>? imagePaths,
    List<Map<String, dynamic>>? attachments,
    bool? isEmergency,
    DateTime? acceptedAt,
    DateTime? cancelledAt,
  }) {
    return ServiceRequest(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      clientEmail: clientEmail ?? this.clientEmail,
      serviceId: serviceId ?? this.serviceId,
      serviceTitle: serviceTitle ?? this.serviceTitle,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      providerId: providerId ?? this.providerId,
      providerName: providerName ?? this.providerName,
      address: address ?? this.address,
      preferredDate: preferredDate ?? this.preferredDate,
      timeSlot: timeSlot ?? this.timeSlot,
      problemDescription: problemDescription ?? this.problemDescription,
      estimatedTotal: estimatedTotal ?? this.estimatedTotal,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      photoUrls: photoUrls ?? this.photoUrls,
      imageUrls: imageUrls ?? this.imageUrls,
      imagePaths: imagePaths ?? this.imagePaths,
      attachments: attachments ?? this.attachments,
      isEmergency: isEmergency ?? this.isEmergency,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
    );
  }

  factory ServiceRequest.fromMap(Map<String, dynamic> map) {
    return ServiceRequest(
      id: map['id'] as String? ?? '',
      clientId: map['clientId'] as String? ?? '',
      clientName: map['clientName'] as String? ?? '',
      clientEmail: map['clientEmail'] as String? ?? '',
      serviceId: map['serviceId'] as String? ?? '',
      serviceTitle: map['serviceTitle'] as String? ?? '',
      categoryId: map['categoryId'] as String? ?? '',
      categoryName: map['categoryName'] as String? ?? '',
      providerId: map['providerId'] as String? ?? '',
      providerName: map['providerName'] as String? ?? '',
      address: Address.fromMap(
        Map<String, dynamic>.from(
          map['address'] as Map? ??
              {
                'fullAddress': map['addressText'] as String? ?? '',
                'label': 'Servicio',
              },
        ),
      ),
      preferredDate: _dateFromValue(
        map['preferredDate'] ?? map['scheduledDate'],
      ),
      timeSlot:
          map['timeSlot'] as String? ?? map['scheduledTime'] as String? ?? '',
      problemDescription:
          map['problemDescription'] as String? ??
          map['description'] as String? ??
          '',
      estimatedTotal:
          (map['estimatedTotal'] as num?)?.toDouble() ??
          (map['estimatedPrice'] as num?)?.toDouble() ??
          0,
      currency: map['currency'] as String? ?? 'USD',
      status: _statusFromValue(map['status']),
      createdAt: _dateFromValue(map['createdAt']),
      photoUrls: _stringListFromValue(map['photoUrls'] ?? map['imageUrls']),
      imageUrls: _stringListFromValue(map['imageUrls'] ?? map['photoUrls']),
      imagePaths: _stringListFromValue(map['imagePaths']),
      attachments: _mapListFromValue(map['attachments']),
      isEmergency: map['isEmergency'] as bool? ?? false,
      acceptedAt: _nullableDateFromValue(map['acceptedAt']),
      cancelledAt: _nullableDateFromValue(map['cancelledAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'clientId': clientId,
      'clientName': clientName,
      'clientEmail': clientEmail,
      'serviceId': serviceId,
      'serviceTitle': serviceTitle,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'providerId': providerId,
      'providerName': providerName,
      'address': address.toMap(),
      'addressText': address.fullAddress,
      'preferredDate': preferredDate.toIso8601String(),
      'scheduledDate': preferredDate.toIso8601String(),
      'timeSlot': timeSlot,
      'scheduledTime': timeSlot,
      'problemDescription': problemDescription,
      'description': problemDescription,
      'estimatedTotal': estimatedTotal,
      'estimatedPrice': estimatedTotal,
      'currency': currency,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'photoUrls': photoUrls,
      'imageUrls': imageUrls,
      'imagePaths': imagePaths,
      'attachments': attachments,
      'isEmergency': isEmergency,
      'acceptedAt': acceptedAt?.toIso8601String(),
      'cancelledAt': cancelledAt?.toIso8601String(),
    };
  }

  static ServiceRequestStatus _statusFromValue(Object? value) {
    final name = value as String? ?? 'draft';
    try {
      return ServiceRequestStatus.values.byName(name);
    } on ArgumentError {
      return ServiceRequestStatus.pending;
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
