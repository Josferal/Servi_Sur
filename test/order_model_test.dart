import 'package:flutter_test/flutter_test.dart';
import 'package:servi_sur/models/order.dart';
import 'package:servi_sur/models/service_request.dart';

void main() {
  test('order tolerates incomplete Firestore maps', () {
    final order = Order.fromMap({
      'serviceTitle': 'Limpieza',
      'totalAmount': 28,
      'status': 'inProgress',
      'trackingStatus': 'onTheWay',
    });

    expect(order.title, 'Limpieza');
    expect(order.total, 28);
    expect(order.status, OrderStatus.inProgress);
    expect(order.trackingStatus, OrderTrackingStatus.onTheWay);
  });

  test('service request parses Firestore style fields', () {
    final request = ServiceRequest.fromMap({
      'serviceTitle': 'Plomeria',
      'description': 'Fuga en cocina',
      'scheduledTime': '08:00 - 12:00',
      'status': 'convertedToOrder',
    });

    expect(request.serviceTitle, 'Plomeria');
    expect(request.problemDescription, 'Fuga en cocina');
    expect(request.timeSlot, '08:00 - 12:00');
    expect(request.status, ServiceRequestStatus.convertedToOrder);
  });

  test('unknown order states fall back safely', () {
    final order = Order.fromMap({
      'status': 'mystery',
      'trackingStatus': 'elsewhere',
    });

    expect(order.status, OrderStatus.pending);
    expect(order.trackingStatus, OrderTrackingStatus.requested);
  });

  test('service request accepts estimatedPrice and unknown status', () {
    final request = ServiceRequest.fromMap({
      'estimatedPrice': 42,
      'status': 'unexpected',
    });

    expect(request.estimatedTotal, 42);
    expect(request.status, ServiceRequestStatus.pending);
  });
}
