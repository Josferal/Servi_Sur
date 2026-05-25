import 'package:cloud_firestore/cloud_firestore.dart' hide Order;

import '../models/address.dart';
import '../models/client_profile.dart';
import '../models/order.dart';
import '../models/provider_profile.dart';
import '../models/review.dart';
import '../models/service_category.dart';
import '../models/service_item.dart';
import '../models/user_model.dart';
import 'marketplace_repository.dart';
import 'mock_marketplace_repository.dart';

class FirebaseMarketplaceRepository extends MarketplaceRepository {
  FirebaseMarketplaceRepository({
    FirebaseFirestore? firestore,
    MarketplaceRepository? fallbackRepository,
    bool loadOnCreate = true,
  }) : _firestore = firestore,
       _fallback = fallbackRepository ?? MockMarketplaceRepository() {
    if (loadOnCreate) {
      refresh();
    }
  }

  final FirebaseFirestore? _firestore;
  final MarketplaceRepository _fallback;
  final List<ServiceCategory> _categories = [];
  final List<ServiceItem> _services = [];

  bool _isLoading = false;
  String? _errorMessage;
  bool _usingFallback = true;

  FirebaseFirestore get _db => _firestore ?? FirebaseFirestore.instance;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get usingFallback => _usingFallback;

  Future<void> refresh() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([_loadCategories(), _loadServices()]);
      final categories = results[0] as List<ServiceCategory>;
      final services = results[1] as List<ServiceItem>;

      _categories
        ..clear()
        ..addAll(categories);
      _services
        ..clear()
        ..addAll(services);
      _usingFallback = categories.isEmpty && services.isEmpty;
    } on FirebaseException catch (error) {
      _errorMessage = _messageForFirebaseError(error);
      _usingFallback = true;
    } catch (_) {
      _errorMessage = 'No se pudieron cargar categorias y servicios.';
      _usingFallback = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<ServiceCategory>> _loadCategories() async {
    final snapshot = await _db
        .collection('categories')
        .where('isActive', isEqualTo: true)
        .orderBy('sortOrder')
        .get();

    return snapshot.docs
        .map((doc) {
          return ServiceCategory.fromMap({'id': doc.id, ...doc.data()});
        })
        .toList(growable: false);
  }

  Future<List<ServiceItem>> _loadServices() async {
    final snapshot = await _db
        .collection('services')
        .where('isActive', isEqualTo: true)
        .get();

    final services = snapshot.docs
        .map((doc) => ServiceItem.fromMap({'id': doc.id, ...doc.data()}))
        .where((service) => service.status == ServiceStatus.active)
        .toList();

    services.sort((a, b) {
      if (a.isFeatured != b.isFeatured) {
        return a.isFeatured ? -1 : 1;
      }
      return b.rating.compareTo(a.rating);
    });
    return services;
  }

  List<ServiceItem> getServicesByCategory(String categoryId) {
    return getServices()
        .where((service) => service.categoryId == categoryId)
        .toList(growable: false);
  }

  List<ServiceItem> searchServices(String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) {
      return getServices();
    }

    return getServices()
        .where((service) {
          final searchable = [
            service.title,
            service.description,
            service.categoryName,
            service.providerName,
            ...service.tags,
          ].join(' ').toLowerCase();
          return searchable.contains(normalized);
        })
        .toList(growable: false);
  }

  Future<int> seedFromFallback({bool overwrite = false}) async {
    var written = 0;
    final batch = _db.batch();

    for (final category in _fallback.getCategories()) {
      final reference = _db.collection('categories').doc(category.id);
      final snapshot = await reference.get();
      if (snapshot.exists && !overwrite) {
        continue;
      }
      batch.set(reference, {
        ...category.toMap(),
        'iconName': category.iconKey,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      written++;
    }

    for (final service in _fallback.getServices()) {
      final reference = _db.collection('services').doc(service.id);
      final snapshot = await reference.get();
      if (snapshot.exists && !overwrite) {
        continue;
      }
      batch.set(reference, {
        ...service.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      written++;
    }

    if (written > 0) {
      await batch.commit();
    }
    return written;
  }

  @override
  UserModel get currentUser => _fallback.currentUser;

  @override
  ClientProfile get currentClientProfile => _fallback.currentClientProfile;

  @override
  ProviderProfile get featuredProviderProfile =>
      _fallback.featuredProviderProfile;

  @override
  Address get defaultAddress => _fallback.defaultAddress;

  @override
  List<ServiceCategory> getCategories() {
    return _categories.isEmpty
        ? _fallback.getCategories()
        : List.unmodifiable(_categories);
  }

  @override
  List<ServiceItem> getServices() {
    return _services.isEmpty
        ? _fallback.getServices()
        : List.unmodifiable(_services);
  }

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
    return findServiceById(id) ?? _fallback.getServiceById(id);
  }

  @override
  ProviderProfile getProviderForService(ServiceItem service) {
    return _fallback.getProviderForService(service);
  }

  @override
  List<Order> getOrders() => _fallback.getOrders();

  @override
  Order? getActiveOrder() => _fallback.getActiveOrder();

  @override
  List<Review> getReviewsForService(String serviceId) {
    return _fallback.getReviewsForService(serviceId);
  }

  @override
  OrderCreationResult createMockOrder(ServiceRequestDraft draft) {
    return createOrder(draft);
  }

  @override
  OrderCreationResult createOrder(ServiceRequestDraft draft) {
    return _fallback.createOrder(draft);
  }

  String _messageForFirebaseError(FirebaseException error) {
    if (error.code == 'no-app') {
      return 'Firebase no esta inicializado para cargar el marketplace.';
    }
    if (error.code == 'permission-denied') {
      return 'No tienes permiso para leer categorias o servicios.';
    }
    return 'No se pudieron cargar categorias y servicios desde Firestore.';
  }
}
