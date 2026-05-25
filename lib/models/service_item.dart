import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum ServicePricingType { fixed, hourly, visit, project }

enum ServiceStatus { draft, active, paused, archived }

class ServiceItem {
  const ServiceItem({
    required this.id,
    required this.providerId,
    required this.providerName,
    required this.categoryId,
    required this.categoryName,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.currency,
    required this.pricingType,
    required this.rating,
    required this.reviewCount,
    required this.distance,
    required this.duration,
    required this.badge,
    this.badgeColor,
    this.tags = const [],
    this.status = ServiceStatus.active,
    this.isFeatured = false,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String providerId;
  final String providerName;
  final String categoryId;
  final String categoryName;
  final String title;
  final String description;
  final String imageUrl;
  final double price;
  final String currency;
  final ServicePricingType pricingType;
  final double rating;
  final int reviewCount;
  final String distance;
  final String duration;
  final String badge;
  final Color? badgeColor;
  final List<String> tags;
  final ServiceStatus status;
  final bool isFeatured;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  String get category => categoryName;
  String get priceLabel {
    return switch (pricingType) {
      ServicePricingType.hourly => 'por hora',
      ServicePricingType.visit => 'visita',
      ServicePricingType.project => 'proyecto',
      ServicePricingType.fixed => 'servicio',
    };
  }

  ServiceItem copyWith({
    String? id,
    String? providerId,
    String? providerName,
    String? categoryId,
    String? categoryName,
    String? title,
    String? description,
    String? imageUrl,
    double? price,
    String? currency,
    ServicePricingType? pricingType,
    double? rating,
    int? reviewCount,
    String? distance,
    String? duration,
    String? badge,
    Color? badgeColor,
    List<String>? tags,
    ServiceStatus? status,
    bool? isFeatured,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ServiceItem(
      id: id ?? this.id,
      providerId: providerId ?? this.providerId,
      providerName: providerName ?? this.providerName,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      pricingType: pricingType ?? this.pricingType,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      distance: distance ?? this.distance,
      duration: duration ?? this.duration,
      badge: badge ?? this.badge,
      badgeColor: badgeColor ?? this.badgeColor,
      tags: tags ?? this.tags,
      status: status ?? this.status,
      isFeatured: isFeatured ?? this.isFeatured,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory ServiceItem.fromMap(Map<String, dynamic> map) {
    return ServiceItem(
      id: map['id'] as String? ?? '',
      providerId: map['providerId'] as String? ?? '',
      providerName: map['providerName'] as String? ?? '',
      categoryId: map['categoryId'] as String? ?? '',
      categoryName: map['categoryName'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      imageUrl: map['imageUrl'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0,
      currency: map['currency'] as String? ?? 'USD',
      pricingType: ServicePricingType.values.byName(
        map['pricingType'] as String? ?? map['priceType'] as String? ?? 'fixed',
      ),
      rating: (map['rating'] as num?)?.toDouble() ?? 0,
      reviewCount:
          (map['reviewCount'] as num?)?.toInt() ??
          (map['reviewsCount'] as num?)?.toInt() ??
          0,
      distance:
          map['distance'] as String? ?? map['locationText'] as String? ?? '',
      duration: map['duration'] as String? ?? '',
      badge: map['badge'] as String? ?? '',
      badgeColor: map['badgeColorValue'] == null
          ? null
          : Color(map['badgeColorValue'] as int),
      tags: List<String>.from(map['tags'] as List<dynamic>? ?? const []),
      status: _statusFromMap(map),
      isFeatured: map['isFeatured'] as bool? ?? false,
      createdAt: _dateFromValue(map['createdAt']),
      updatedAt: _dateFromValue(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'providerId': providerId,
      'providerName': providerName,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'price': price,
      'currency': currency,
      'pricingType': pricingType.name,
      'priceType': pricingType.name,
      'rating': rating,
      'reviewCount': reviewCount,
      'reviewsCount': reviewCount,
      'distance': distance,
      'locationText': distance,
      'duration': duration,
      'badge': badge,
      'badgeColorValue': badgeColor?.toARGB32(),
      'tags': tags,
      'status': status.name,
      'isActive': status == ServiceStatus.active,
      'isFeatured': isFeatured,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  static ServiceStatus _statusFromMap(Map<String, dynamic> map) {
    final rawStatus = map['status'] as String?;
    if (rawStatus != null && rawStatus.isNotEmpty) {
      try {
        return ServiceStatus.values.byName(rawStatus);
      } on ArgumentError {
        return ServiceStatus.active;
      }
    }

    final isActive = map['isActive'] as bool?;
    return isActive == false ? ServiceStatus.paused : ServiceStatus.active;
  }

  static DateTime? _dateFromValue(Object? value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}
