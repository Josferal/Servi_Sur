import 'address.dart';

enum ProviderAvailability { available, busy, offline }

class ProviderProfile {
  const ProviderProfile({
    required this.id,
    required this.userId,
    required this.displayName,
    required this.businessName,
    required this.specialty,
    required this.email,
    required this.phone,
    required this.avatarUrl,
    required this.bio,
    required this.address,
    required this.serviceCategoryIds,
    required this.yearsOfExperience,
    required this.rating,
    required this.reviewCount,
    this.isVerified = false,
    this.availability = ProviderAvailability.available,
    this.portfolioImageUrls = const [],
  });

  final String id;
  final String userId;
  final String displayName;
  final String businessName;
  final String specialty;
  final String email;
  final String phone;
  final String avatarUrl;
  final String bio;
  final Address address;
  final List<String> serviceCategoryIds;
  final int yearsOfExperience;
  final double rating;
  final int reviewCount;
  final bool isVerified;
  final ProviderAvailability availability;
  final List<String> portfolioImageUrls;

  String get name => displayName;
  int get reviews => reviewCount;
  String get experience => '+$yearsOfExperience años';

  ProviderProfile copyWith({
    String? id,
    String? userId,
    String? displayName,
    String? businessName,
    String? specialty,
    String? email,
    String? phone,
    String? avatarUrl,
    String? bio,
    Address? address,
    List<String>? serviceCategoryIds,
    int? yearsOfExperience,
    double? rating,
    int? reviewCount,
    bool? isVerified,
    ProviderAvailability? availability,
    List<String>? portfolioImageUrls,
  }) {
    return ProviderProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      businessName: businessName ?? this.businessName,
      specialty: specialty ?? this.specialty,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      address: address ?? this.address,
      serviceCategoryIds: serviceCategoryIds ?? this.serviceCategoryIds,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isVerified: isVerified ?? this.isVerified,
      availability: availability ?? this.availability,
      portfolioImageUrls: portfolioImageUrls ?? this.portfolioImageUrls,
    );
  }

  factory ProviderProfile.fromMap(Map<String, dynamic> map) {
    return ProviderProfile(
      id: map['id'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      displayName: map['displayName'] as String? ?? '',
      businessName: map['businessName'] as String? ?? '',
      specialty: map['specialty'] as String? ?? '',
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      avatarUrl: map['avatarUrl'] as String? ?? '',
      bio: map['bio'] as String? ?? '',
      address: Address.fromMap(
        Map<String, dynamic>.from(map['address'] as Map? ?? const {}),
      ),
      serviceCategoryIds: List<String>.from(
        map['serviceCategoryIds'] as List<dynamic>? ?? const [],
      ),
      yearsOfExperience: map['yearsOfExperience'] as int? ?? 0,
      rating: (map['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: map['reviewCount'] as int? ?? 0,
      isVerified: map['isVerified'] as bool? ?? false,
      availability: ProviderAvailability.values.byName(
        map['availability'] as String? ?? 'available',
      ),
      portfolioImageUrls: List<String>.from(
        map['portfolioImageUrls'] as List<dynamic>? ?? const [],
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'displayName': displayName,
      'businessName': businessName,
      'specialty': specialty,
      'email': email,
      'phone': phone,
      'avatarUrl': avatarUrl,
      'bio': bio,
      'address': address.toMap(),
      'serviceCategoryIds': serviceCategoryIds,
      'yearsOfExperience': yearsOfExperience,
      'rating': rating,
      'reviewCount': reviewCount,
      'isVerified': isVerified,
      'availability': availability.name,
      'portfolioImageUrls': portfolioImageUrls,
    };
  }
}
