class Address {
  const Address({
    required this.id,
    required this.label,
    required this.fullAddress,
    required this.city,
    required this.country,
    this.latitude,
    this.longitude,
    this.notes,
    this.isDefault = false,
  });

  final String id;
  final String label;
  final String fullAddress;
  final String city;
  final String country;
  final double? latitude;
  final double? longitude;
  final String? notes;
  final bool isDefault;

  Address copyWith({
    String? id,
    String? label,
    String? fullAddress,
    String? city,
    String? country,
    double? latitude,
    double? longitude,
    String? notes,
    bool? isDefault,
  }) {
    return Address(
      id: id ?? this.id,
      label: label ?? this.label,
      fullAddress: fullAddress ?? this.fullAddress,
      city: city ?? this.city,
      country: country ?? this.country,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      notes: notes ?? this.notes,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  factory Address.fromMap(Map<String, dynamic> map) {
    return Address(
      id: map['id'] as String? ?? '',
      label: map['label'] as String? ?? '',
      fullAddress: map['fullAddress'] as String? ?? '',
      city: map['city'] as String? ?? '',
      country: map['country'] as String? ?? '',
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      notes: map['notes'] as String?,
      isDefault: map['isDefault'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'label': label,
      'fullAddress': fullAddress,
      'city': city,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'notes': notes,
      'isDefault': isDefault,
    };
  }
}
