import 'package:flutter/foundation.dart';

import 'package:servi_sur/shared/domain/entities/order.dart';
import 'package:servi_sur/shared/domain/entities/service_item.dart';
import 'package:servi_sur/shared/domain/entities/service_request.dart';
import 'package:servi_sur/shared/domain/repositories/marketplace_repository.dart';

class CartProvider extends ChangeNotifier {
  CartProvider(this._repository);

  MarketplaceRepository _repository;
  ServiceItem? _selectedService;
  ServiceRequest? _currentRequest;
  Order? _activeOrder;

  ServiceItem? get selectedService => _selectedService;
  ServiceRequest? get currentRequest => _currentRequest;
  Order? get activeOrder => _activeOrder ?? _repository.getActiveOrder();
  List<Order> get orders => _repository.getOrders();
  double get total => _selectedService?.price ?? 0;

  void updateRepository(MarketplaceRepository repository) {
    _repository = repository;
  }

  void selectService(ServiceItem service) {
    _selectedService = service;
    _currentRequest = null;
    _activeOrder = null;
    notifyListeners();
  }

  OrderCreationResult confirmRequest(ServiceRequestDraft draft) {
    final result = _repository.createOrder(draft);
    _selectedService = draft.service;
    _currentRequest = result.request;
    _activeOrder = result.order;
    notifyListeners();
    return result;
  }

  void setConfirmedOrder({
    required ServiceItem service,
    required ServiceRequest request,
    required Order order,
  }) {
    _selectedService = service;
    _currentRequest = request;
    _activeOrder = order;
    notifyListeners();
  }
}
