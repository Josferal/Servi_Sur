import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../models/address.dart';
import '../models/client_profile.dart';
import '../models/order.dart';
import '../models/provider_profile.dart';
import '../models/review.dart';
import '../models/service_category.dart';
import '../models/service_item.dart';
import '../models/service_request.dart';
import '../models/user_model.dart';

class MockMarketplaceService {
  static final clientUser = UserModel(
    id: 'user-client-001',
    fullName: 'Alejandro Silva',
    email: 'alejandro.silva@servisur.app',
    phone: '+506 8888 1212',
    role: UserRole.client,
    avatarUrl:
        'https://images.unsplash.com/photo-1560250097-0b93528c311a?auto=format&fit=crop&w=600&q=80',
    createdAt: DateTime(2026, 1, 10),
  );

  static final providerUser = UserModel(
    id: 'user-provider-001',
    fullName: 'Alejandro Rivera',
    email: 'alejandro.rivera@servisur.app',
    phone: '+506 8888 4545',
    role: UserRole.provider,
    avatarUrl:
        'https://images.unsplash.com/photo-1560250097-0b93528c311a?auto=format&fit=crop&w=600&q=80',
    createdAt: DateTime(2025, 11, 6),
  );

  static const defaultAddress = Address(
    id: 'address-001',
    label: 'Casa',
    fullAddress: 'Central Park West, San Lorenzo',
    city: 'San Lorenzo',
    country: 'Costa Rica',
    latitude: 9.9281,
    longitude: -84.0907,
    isDefault: true,
  );

  static const categories = [
    ServiceCategory(
      id: 'electricians',
      name: 'Electricistas',
      icon: Icons.flash_on_rounded,
      iconKey: 'electricians',
      subtitle: 'Instalaciones y fallas',
      sortOrder: 1,
    ),
    ServiceCategory(
      id: 'plumbers',
      name: 'Plomeros',
      icon: Icons.handyman_rounded,
      iconKey: 'plumbers',
      subtitle: 'Emergencias y mantenimiento',
      sortOrder: 2,
    ),
    ServiceCategory(
      id: 'food',
      name: 'Comida',
      icon: Icons.restaurant_rounded,
      iconKey: 'food',
      subtitle: 'Chefs y pedidos express',
      sortOrder: 3,
    ),
    ServiceCategory(
      id: 'transport',
      name: 'Transporte',
      icon: Icons.local_shipping_rounded,
      iconKey: 'transport',
      subtitle: 'Mudanzas y entregas',
      sortOrder: 4,
    ),
    ServiceCategory(
      id: 'cleaning',
      name: 'Limpieza',
      icon: Icons.cleaning_services_rounded,
      iconKey: 'cleaning',
      subtitle: 'Hogar y oficina',
      sortOrder: 5,
    ),
    ServiceCategory(
      id: 'design',
      name: 'Diseño',
      icon: Icons.architecture_rounded,
      iconKey: 'design',
      subtitle: 'Interiores y remodelación',
      sortOrder: 6,
    ),
  ];

  static final clientProfile = ClientProfile(
    id: 'client-profile-001',
    userId: clientUser.id,
    defaultAddressId: defaultAddress.id,
    addresses: const [defaultAddress],
    favoriteServiceIds: const ['spark', 'clean', 'kitchen'],
    paymentMethodIds: const ['pm-visa-4242'],
  );

  static final profile = ProviderProfile(
    id: 'provider-profile-001',
    userId: providerUser.id,
    displayName: 'Alejandro Silva',
    businessName: 'Rivera Studio',
    specialty: 'Miembro Premium',
    email: providerUser.email,
    phone: providerUser.phone,
    avatarUrl: providerUser.avatarUrl ?? '',
    bio:
        'Especialista en remodelaciones premium y diseño de interiores minimalistas.',
    address: defaultAddress,
    serviceCategoryIds: const ['design', 'cleaning'],
    yearsOfExperience: 8,
    rating: 4.9,
    reviewCount: 128,
    isVerified: true,
    portfolioImageUrls: const [
      'https://images.unsplash.com/photo-1600210492486-724fe5c67fb0?auto=format&fit=crop&w=900&q=80',
      'https://images.unsplash.com/photo-1600607687920-4e2a09cf159d?auto=format&fit=crop&w=500&q=80',
    ],
  );

  static final services = [
    ServiceItem(
      id: 'spark',
      providerId: 'provider-profile-002',
      providerName: 'Carlos Mendoza',
      categoryId: 'electricians',
      categoryName: 'Electricistas',
      title: 'Master Spark Electric',
      description:
          'Cableado residencial, domótica, revisiones de tablero y mantenimiento premium.',
      imageUrl:
          'https://images.unsplash.com/photo-1621905252507-b35492cc74b4?auto=format&fit=crop&w=900&q=80',
      price: 45,
      currency: 'USD',
      pricingType: ServicePricingType.hourly,
      rating: 4.9,
      reviewCount: 120,
      distance: '1.2 km',
      duration: '30-45 min',
      badge: 'TOP RATED',
      tags: const ['domótica', 'cableado', 'residencial'],
      isFeatured: true,
      createdAt: DateTime(2026, 1, 12),
    ),
    ServiceItem(
      id: 'clean',
      providerId: 'provider-profile-003',
      providerName: 'Elena Rodríguez',
      categoryId: 'cleaning',
      categoryName: 'Limpieza',
      title: 'Limpieza Profunda',
      description:
          'Desinfección profunda, organización minimalista y productos biodegradables.',
      imageUrl:
          'https://images.unsplash.com/photo-1581578731548-c64695cc6952?auto=format&fit=crop&w=900&q=80',
      price: 45,
      currency: 'USD',
      pricingType: ServicePricingType.visit,
      rating: 4.9,
      reviewCount: 98,
      distance: '2.4 km',
      duration: '45-60 min',
      badge: 'MEJOR VALORADO',
      tags: const ['desinfección', 'hogar', 'eco'],
      isFeatured: true,
      createdAt: DateTime(2026, 1, 18),
    ),
    ServiceItem(
      id: 'kitchen',
      providerId: profile.id,
      providerName: 'Alejandro Rivera',
      categoryId: 'design',
      categoryName: 'Diseño',
      title: 'Diseño de Cocinas Pro',
      description:
          'Remodelación integral, renders 3D y selección de materiales para interiores.',
      imageUrl:
          'https://images.unsplash.com/photo-1556911220-bff31c812dba?auto=format&fit=crop&w=900&q=80',
      price: 150,
      currency: 'USD',
      pricingType: ServicePricingType.project,
      rating: 5,
      reviewCount: 64,
      distance: '1.2 km',
      duration: 'Disponible',
      badge: 'OFERTA',
      badgeColor: AppColors.blue,
      tags: const ['cocinas', 'renders 3D', 'interiores'],
      isFeatured: true,
      createdAt: DateTime(2026, 2, 2),
    ),
    ServiceItem(
      id: 'moving',
      providerId: 'provider-profile-004',
      providerName: 'Transporte Sur',
      categoryId: 'transport',
      categoryName: 'Transporte',
      title: 'Mudanzas Global',
      description:
          'Cuidado extremo para muebles, entregas express y carga asegurada.',
      imageUrl:
          'https://images.unsplash.com/photo-1600518464441-9154a4dea21b?auto=format&fit=crop&w=900&q=80',
      price: 80,
      currency: 'USD',
      pricingType: ServicePricingType.fixed,
      rating: 4.8,
      reviewCount: 72,
      distance: '3.5 km',
      duration: 'Express',
      badge: 'NUEVO',
      badgeColor: AppColors.blue,
      tags: const ['mudanza', 'express', 'asegurado'],
      createdAt: DateTime(2026, 2, 14),
    ),
  ];

  static final serviceRequests = [
    ServiceRequest(
      id: 'request-001',
      clientId: clientUser.id,
      serviceId: 'clean',
      providerId: 'provider-profile-003',
      address: defaultAddress,
      preferredDate: DateTime(2026, 5, 4, 8),
      timeSlot: 'Mañana (08:00 - 12:00)',
      problemDescription: 'Limpieza profunda para sala, cocina y ventanales.',
      estimatedTotal: 48,
      currency: 'USD',
      status: ServiceRequestStatus.accepted,
      createdAt: DateTime(2026, 5, 3, 19, 15),
      acceptedAt: DateTime(2026, 5, 3, 19, 28),
    ),
  ];

  static final orders = [
    Order(
      id: 'order-001',
      requestId: 'request-001',
      clientId: clientUser.id,
      providerId: 'provider-profile-005',
      serviceId: 'dog-walk',
      title: 'Paseo VIP',
      providerName: 'Marco Valerio',
      category: 'Mascotas',
      scheduledAt: DateTime(2026, 5, 4, 14, 30),
      address: defaultAddress,
      subtotal: 32,
      platformFee: 3,
      total: 35,
      currency: 'USD',
      status: OrderStatus.active,
      createdAt: DateTime(2026, 5, 3, 18, 10),
    ),
    Order(
      id: 'order-002',
      requestId: 'request-002',
      clientId: clientUser.id,
      providerId: 'provider-profile-003',
      serviceId: 'clean',
      title: 'Limpieza Profunda',
      providerName: 'Soluciones Hogar',
      category: 'Limpieza',
      scheduledAt: DateTime(2026, 4, 12, 9),
      address: defaultAddress,
      subtotal: 42,
      platformFee: 3,
      total: 45,
      currency: 'USD',
      status: OrderStatus.completed,
      createdAt: DateTime(2026, 4, 10, 16, 20),
      completedAt: DateTime(2026, 4, 12, 11, 30),
    ),
    Order(
      id: 'order-003',
      requestId: 'request-003',
      clientId: clientUser.id,
      providerId: 'provider-profile-006',
      serviceId: 'urgent-plumbing',
      title: 'Plomería Urgente',
      providerName: 'Mario Bros Inc.',
      category: 'Plomería',
      scheduledAt: DateTime(2026, 4, 8, 15),
      address: defaultAddress,
      subtotal: 25,
      platformFee: 3,
      total: 28,
      currency: 'USD',
      status: OrderStatus.cancelled,
      createdAt: DateTime(2026, 4, 8, 8, 45),
      cancelledAt: DateTime(2026, 4, 8, 9, 5),
    ),
    Order(
      id: 'order-004',
      requestId: 'request-004',
      clientId: clientUser.id,
      providerId: 'provider-profile-007',
      serviceId: 'dog-training',
      title: 'Entrenamiento Canino',
      providerName: 'Dr. Bark',
      category: 'Mascotas',
      scheduledAt: DateTime(2026, 4, 5, 10),
      address: defaultAddress,
      subtotal: 57,
      platformFee: 3,
      total: 60,
      currency: 'USD',
      status: OrderStatus.completed,
      createdAt: DateTime(2026, 4, 3, 13, 20),
      completedAt: DateTime(2026, 4, 5, 11, 15),
    ),
  ];

  static final reviews = [
    Review(
      id: 'review-001',
      orderId: 'order-002',
      serviceId: 'clean',
      providerId: 'provider-profile-003',
      clientId: clientUser.id,
      clientName: clientUser.fullName,
      rating: 5,
      comment:
          'La atención al detalle fue excepcional. Todo quedó impecable y el servicio se sintió premium desde el primer contacto.',
      createdAt: DateTime(2026, 4, 12, 12),
      clientAvatarUrl: clientUser.avatarUrl,
    ),
  ];
}
