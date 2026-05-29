import 'package:servi_sur/shared/domain/entities/address.dart';
import 'package:servi_sur/shared/domain/entities/client_profile.dart';
import 'package:servi_sur/shared/domain/entities/order.dart';
import 'package:servi_sur/shared/domain/entities/provider_profile.dart';
import 'package:servi_sur/shared/domain/entities/review.dart';
import 'package:servi_sur/shared/domain/entities/service_category.dart';
import 'package:servi_sur/shared/domain/entities/service_item.dart';
import 'package:servi_sur/shared/domain/entities/service_request.dart';
import 'package:servi_sur/shared/domain/entities/user_model.dart';

class ServiceRequestDraft {
  const ServiceRequestDraft({
    required this.service,
    required this.addressText,
    required this.preferredDate,
    required this.timeSlot,
    required this.problemDescription,
    required this.isEmergency,
  });

  final ServiceItem service;
  final String addressText;
  final DateTime preferredDate;
  final String timeSlot;
  final String problemDescription;
  final bool isEmergency;
}

class OrderCreationResult {
  const OrderCreationResult({required this.request, required this.order});

  final ServiceRequest request;
  final Order order;
}

abstract class MarketplaceRepository {
  UserModel get currentUser;
  ClientProfile get currentClientProfile;
  ProviderProfile get featuredProviderProfile;
  Address get defaultAddress;

  List<ServiceCategory> getCategories();
  List<ServiceItem> getServices();
  ServiceItem? findServiceById(String id);
  ServiceItem getServiceById(String id);
  ProviderProfile getProviderForService(ServiceItem service);
  List<Order> getOrders();
  Order? getActiveOrder();
  List<Review> getReviewsForService(String serviceId);

  OrderCreationResult createOrder(ServiceRequestDraft draft);
  OrderCreationResult createMockOrder(ServiceRequestDraft draft);
}
