import 'package:flutter/material.dart';

class ServiceCategory {
  const ServiceCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.subtitle,
    this.iconKey = 'category',
    this.description,
    this.imageUrl,
    this.isActive = true,
    this.sortOrder = 0,
  });

  final String id;
  final String name;
  final IconData icon;
  final String subtitle;
  final String iconKey;
  final String? description;
  final String? imageUrl;
  final bool isActive;
  final int sortOrder;

  ServiceCategory copyWith({
    String? id,
    String? name,
    IconData? icon,
    String? subtitle,
    String? iconKey,
    String? description,
    String? imageUrl,
    bool? isActive,
    int? sortOrder,
  }) {
    return ServiceCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      subtitle: subtitle ?? this.subtitle,
      iconKey: iconKey ?? this.iconKey,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  factory ServiceCategory.fromMap(Map<String, dynamic> map) {
    return ServiceCategory(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      icon: _iconFromKey(
        map['iconKey'] as String? ??
            map['iconName'] as String? ??
            map['icon'] as String? ??
            'category',
      ),
      subtitle:
          map['subtitle'] as String? ?? map['description'] as String? ?? '',
      iconKey:
          map['iconKey'] as String? ??
          map['iconName'] as String? ??
          map['icon'] as String? ??
          'category',
      description: map['description'] as String?,
      imageUrl: map['imageUrl'] as String?,
      isActive: map['isActive'] as bool? ?? true,
      sortOrder: (map['sortOrder'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'iconKey': iconKey,
      'subtitle': subtitle,
      'description': description,
      'imageUrl': imageUrl,
      'isActive': isActive,
      'sortOrder': sortOrder,
    };
  }

  static IconData _iconFromKey(String key) {
    return switch (key) {
      'electricians' => Icons.flash_on_rounded,
      'plumbers' => Icons.handyman_rounded,
      'food' => Icons.restaurant_rounded,
      'transport' => Icons.local_shipping_rounded,
      'cleaning' => Icons.cleaning_services_rounded,
      'design' => Icons.architecture_rounded,
      _ => Icons.category_rounded,
    };
  }
}
