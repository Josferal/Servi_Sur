import 'address.dart';

class ClientProfile {
  const ClientProfile({
    required this.id,
    required this.userId,
    required this.defaultAddressId,
    required this.addresses,
    this.favoriteServiceIds = const [],
    this.paymentMethodIds = const [],
  });

  final String id;
  final String userId;
  final String defaultAddressId;
  final List<Address> addresses;
  final List<String> favoriteServiceIds;
  final List<String> paymentMethodIds;

  Address? get defaultAddress {
    for (final address in addresses) {
      if (address.id == defaultAddressId) {
        return address;
      }
    }
    return addresses.isEmpty ? null : addresses.first;
  }

  ClientProfile copyWith({
    String? id,
    String? userId,
    String? defaultAddressId,
    List<Address>? addresses,
    List<String>? favoriteServiceIds,
    List<String>? paymentMethodIds,
  }) {
    return ClientProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      defaultAddressId: defaultAddressId ?? this.defaultAddressId,
      addresses: addresses ?? this.addresses,
      favoriteServiceIds: favoriteServiceIds ?? this.favoriteServiceIds,
      paymentMethodIds: paymentMethodIds ?? this.paymentMethodIds,
    );
  }

  factory ClientProfile.fromMap(Map<String, dynamic> map) {
    return ClientProfile(
      id: map['id'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      defaultAddressId: map['defaultAddressId'] as String? ?? '',
      addresses: ((map['addresses'] as List<dynamic>?) ?? const [])
          .map(
            (item) => Address.fromMap(Map<String, dynamic>.from(item as Map)),
          )
          .toList(),
      favoriteServiceIds: List<String>.from(
        map['favoriteServiceIds'] as List<dynamic>? ?? const [],
      ),
      paymentMethodIds: List<String>.from(
        map['paymentMethodIds'] as List<dynamic>? ?? const [],
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'defaultAddressId': defaultAddressId,
      'addresses': addresses.map((address) => address.toMap()).toList(),
      'favoriteServiceIds': favoriteServiceIds,
      'paymentMethodIds': paymentMethodIds,
    };
  }
}
