import 'package:servi_sur/shared/domain/entities/address.dart';
import 'package:servi_sur/shared/domain/entities/client_profile.dart';
import 'package:servi_sur/shared/domain/entities/order.dart';
import 'package:servi_sur/shared/domain/entities/provider_profile.dart';
import 'package:servi_sur/shared/domain/entities/review.dart';
import 'package:servi_sur/shared/domain/entities/service_category.dart';
import 'package:servi_sur/shared/domain/entities/service_item.dart';
import 'package:servi_sur/shared/domain/entities/service_request.dart';
import 'package:servi_sur/shared/domain/entities/user_model.dart';
import 'package:flutter/foundation.dart';

import 'package:servi_sur/shared/data/datasources/mock_marketplace_datasource.dart';
import 'package:servi_sur/shared/domain/repositories/marketplace_repository.dart';

class MockMarketplaceRepository extends ChangeNotifier
    implements MarketplaceRepository {
  MockMarketplaceRepository()
    : _orders = [...MockMarketplaceService.orders],
      _requests = [...MockMarketplaceService.serviceRequests];

  final List<Order> _orders;
  final List<ServiceRequest> _requests;

  @override
  UserModel get currentUser => MockMarketplaceService.clientUser;

  @override
  ClientProfile get currentClientProfile =>
      MockMarketplaceService.clientProfile;

  @override
  ProviderProfile get featuredProviderProfile => MockMarketplaceService.profile;

  @override
  Address get defaultAddress => MockMarketplaceService.defaultAddress;

  @override
  List<ServiceCategory> getCategories() => MockMarketplaceService.categories;

  @override
  List<ServiceItem> getServices() => MockMarketplaceService.services;

  @override
  ServiceItem? findServiceById(String id) {
    for (final service in getServices()) {
      if (service.id == id) {
        return service;
      }
    }
    return null;
  }

  @override
  ServiceItem getServiceById(String id) {
    return findServiceById(id) ?? getServices().first;
  }

  @override
  ProviderProfile getProviderForService(ServiceItem service) {
    if (service.providerId == featuredProviderProfile.id) {
      return featuredProviderProfile;
    }

    return featuredProviderProfile.copyWith(
      id: service.providerId,
      displayName: service.providerName,
      businessName: service.providerName,
      specialty: service.categoryName,
      email: 'No definido',
      phone: '+506 8888 4545',
      rating: service.rating,
      reviewCount: service.reviewCount,
      serviceCategoryIds: [service.categoryId],
    );
  }

  @override
  List<Order> getOrders() => List.unmodifiable(_orders);

  @override
  Order? getActiveOrder() {
    for (final order in _orders) {
      if (order.status == OrderStatus.active) {
        return order;
      }
    }
    return null;
  }

  @override
  List<Review> getReviewsForService(String serviceId) {
    return MockMarketplaceService.reviews
        .where((review) => review.serviceId == serviceId)
        .toList(growable: false);
  }

  @override
  OrderCreationResult createOrder(ServiceRequestDraft draft) {
    final now = DateTime.now();
    final timestamp = now.millisecondsSinceEpoch;
    final requestId = 'request-$timestamp';
    final orderId = 'order-$timestamp';
    final address = defaultAddress.copyWith(
      id: 'address-$timestamp',
      fullAddress: draft.addressText.trim(),
    );

    final request = ServiceRequest(
      id: requestId,
      clientId: currentUser.id,
      serviceId: draft.service.id,
      providerId: draft.service.providerId,
      address: address,
      preferredDate: draft.preferredDate,
      timeSlot: draft.timeSlot.trim(),
      problemDescription: draft.problemDescription.trim(),
      estimatedTotal: draft.service.price + 3,
      currency: draft.service.currency,
      status: ServiceRequestStatus.accepted,
      createdAt: now,
      isEmergency: draft.isEmergency,
      acceptedAt: now,
    );

    final order = Order(
      id: orderId,
      requestId: request.id,
      clientId: currentUser.id,
      providerId: draft.service.providerId,
      serviceId: draft.service.id,
      title: draft.service.title,
      providerName: draft.service.providerName,
      category: draft.service.categoryName,
      scheduledAt: draft.preferredDate,
      address: address,
      subtotal: draft.service.price,
      platformFee: 3,
      total: draft.service.price + 3,
      currency: draft.service.currency,
      status: OrderStatus.active,
      createdAt: now,
    );

    _requests.insert(0, request);
    _orders.removeWhere((item) => item.id == order.id);
    _orders.insert(0, order);

    return OrderCreationResult(request: request, order: order);
  }

  @override
  OrderCreationResult createMockOrder(ServiceRequestDraft draft) {
    return createOrder(draft);
  }
}
