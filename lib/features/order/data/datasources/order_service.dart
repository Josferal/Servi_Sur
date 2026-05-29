import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:firebase_auth/firebase_auth.dart';

import 'package:servi_sur/shared/domain/entities/address.dart';
import 'package:servi_sur/shared/domain/entities/order.dart';
import 'package:servi_sur/shared/domain/entities/service_item.dart';
import 'package:servi_sur/shared/domain/entities/service_request.dart';

class OrderService {
  OrderService({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore,
      _auth = auth;

  final FirebaseFirestore? _firestore;
  final FirebaseAuth? _auth;

  FirebaseFirestore get _db => _firestore ?? FirebaseFirestore.instance;
  FirebaseAuth get _firebaseAuth => _auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _requests =>
      _db.collection('serviceRequests');

  CollectionReference<Map<String, dynamic>> get _orders =>
      _db.collection('orders');

  Future<ServiceRequest> createServiceRequest({
    required ServiceItem service,
    required String clientId,
    required String clientName,
    required String clientEmail,
    required String description,
    required String addressText,
    required DateTime scheduledDate,
    required String scheduledTime,
    required double estimatedPrice,
    bool isEmergency = false,
  }) async {
    final reference = _requests.doc();
    final address = Address(
      id: 'address-${reference.id}',
      label: 'Servicio',
      fullAddress: addressText.trim(),
      city: '',
      country: 'Costa Rica',
    );
    final data = {
      'id': reference.id,
      'clientId': clientId,
      'clientName': clientName,
      'clientEmail': clientEmail,
      'serviceId': service.id,
      'serviceTitle': service.title,
      'categoryId': service.categoryId,
      'categoryName': service.categoryName,
      'providerId': service.providerId,
      'providerName': service.providerName,
      'description': description.trim(),
      'addressText': addressText.trim(),
      'address': address.toMap(),
      'scheduledDate': Timestamp.fromDate(scheduledDate),
      'scheduledTime': scheduledTime.trim(),
      'estimatedPrice': estimatedPrice,
      'estimatedTotal': estimatedPrice,
      'currency': service.currency,
      'status': ServiceRequestStatus.pending.name,
      'photoUrls': <String>[],
      'imageUrls': <String>[],
      'imagePaths': <String>[],
      'attachments': <Map<String, dynamic>>[],
      'isEmergency': isEmergency,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    await reference.set(data);
    return ServiceRequest.fromMap({...data, 'createdAt': Timestamp.now()});
  }

  Future<Order> createOrderFromRequest(ServiceRequest request) async {
    final reference = _orders.doc();
    final data = {
      'id': reference.id,
      'requestId': request.id,
      'clientId': request.clientId,
      'clientName': request.clientName,
      'clientEmail': request.clientEmail,
      'serviceId': request.serviceId,
      'serviceTitle': request.serviceTitle,
      'categoryId': request.categoryId,
      'categoryName': request.categoryName,
      'providerId': request.providerId,
      'providerName': request.providerName,
      'description': request.problemDescription,
      'addressText': request.address.fullAddress,
      'address': request.address.toMap(),
      'scheduledDate': Timestamp.fromDate(request.preferredDate),
      'scheduledTime': request.timeSlot,
      'totalAmount': request.estimatedTotal,
      'total': request.estimatedTotal,
      'subtotal': request.estimatedTotal,
      'platformFee': 0,
      'currency': request.currency,
      'status': OrderStatus.pending.name,
      'trackingStatus': OrderTrackingStatus.requested.name,
      'imageUrls': request.imageUrls,
      'imagePaths': request.imagePaths,
      'attachments': request.attachments,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    final batch = _db.batch();
    batch.set(reference, data);
    batch.update(_requests.doc(request.id), {
      'status': ServiceRequestStatus.convertedToOrder.name,
      'updatedAt': FieldValue.serverTimestamp(),
      'orderId': reference.id,
    });
    await batch.commit();

    return Order.fromMap({...data, 'createdAt': Timestamp.now()});
  }

  Future<Order> createOrder({
    required ServiceItem service,
    required String clientId,
    required String clientName,
    required String clientEmail,
    required String description,
    required String addressText,
    required DateTime scheduledDate,
    required String scheduledTime,
    required double totalAmount,
    bool isEmergency = false,
  }) async {
    final request = await createServiceRequest(
      service: service,
      clientId: clientId,
      clientName: clientName,
      clientEmail: clientEmail,
      description: description,
      addressText: addressText,
      scheduledDate: scheduledDate,
      scheduledTime: scheduledTime,
      estimatedPrice: totalAmount,
      isEmergency: isEmergency,
    );
    return createOrderFromRequest(request);
  }

  Future<List<Order>> getOrdersByClient(String clientId) async {
    final snapshot = await _orders.where('clientId', isEqualTo: clientId).get();
    return _sortOrders(snapshot.docs.map(_orderFromDoc).toList());
  }

  Future<List<Order>> getOrdersByProvider(String providerId) async {
    final snapshot = await _orders
        .where('providerId', isEqualTo: providerId)
        .get();
    return _sortOrders(snapshot.docs.map(_orderFromDoc).toList());
  }

  Future<Order?> getOrderById(String orderId) async {
    final snapshot = await _orders.doc(orderId).get();
    if (!snapshot.exists || snapshot.data() == null) {
      return null;
    }
    return _orderFromDoc(snapshot);
  }

  Stream<List<Order>> watchOrdersByClient(String clientId) {
    return _orders
        .where('clientId', isEqualTo: clientId)
        .snapshots()
        .map(
          (snapshot) => _sortOrders(snapshot.docs.map(_orderFromDoc).toList()),
        );
  }

  Stream<List<Order>> watchOrdersByProvider(String providerId) {
    return _orders
        .where('providerId', isEqualTo: providerId)
        .snapshots()
        .map(
          (snapshot) => _sortOrders(snapshot.docs.map(_orderFromDoc).toList()),
        );
  }

  Stream<Order?> watchOrderById(String orderId) {
    return _orders.doc(orderId).snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        return null;
      }
      return _orderFromDoc(snapshot);
    });
  }

  Future<void> updateOrderStatus({
    required String orderId,
    OrderStatus? status,
    OrderTrackingStatus? trackingStatus,
  }) {
    return _orders.doc(orderId).update({
      if (status != null) 'status': status.name,
      if (trackingStatus != null) 'trackingStatus': trackingStatus.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> attachImagesToRequest({
    required String requestId,
    required List<String> imageUrls,
    required List<String> imagePaths,
    List<Map<String, dynamic>> attachments = const [],
  }) {
    return _requests.doc(requestId).update({
      'photoUrls': imageUrls,
      'imageUrls': imageUrls,
      'imagePaths': imagePaths,
      'attachments': attachments,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> attachImagesToOrder({
    required String orderId,
    required List<String> imageUrls,
    required List<String> imagePaths,
    List<Map<String, dynamic>> attachments = const [],
  }) {
    return _orders.doc(orderId).update({
      'imageUrls': imageUrls,
      'imagePaths': imagePaths,
      'attachments': attachments,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  User? get currentUser {
    try {
      return _firebaseAuth.currentUser;
    } on FirebaseException catch (error) {
      if (error.code == 'no-app') {
        return null;
      }
      rethrow;
    }
  }

  Order _orderFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    return Order.fromMap({'id': doc.id, ...?doc.data()});
  }

  List<Order> _sortOrders(List<Order> orders) {
    orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return orders;
  }
}
