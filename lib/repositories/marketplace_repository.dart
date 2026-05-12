import '../models/address.dart';
import '../models/client_profile.dart';
import '../models/order.dart';
import '../models/provider_profile.dart';
import '../models/review.dart';
import '../models/service_category.dart';
import '../models/service_item.dart';
import '../models/service_request.dart';
import '../models/user_model.dart';

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

  OrderCreationResult createMockOrder(ServiceRequestDraft draft);
}
