import 'package:flutter/foundation.dart';

import '../models/order.dart';
import '../models/service_item.dart';
import '../models/service_request.dart';
import '../repositories/marketplace_repository.dart';

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
    final result = _repository.createMockOrder(draft);
    _selectedService = draft.service;
    _currentRequest = result.request;
    _activeOrder = result.order;
    notifyListeners();
    return result;
  }
}
