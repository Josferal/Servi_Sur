import 'package:flutter_test/flutter_test.dart';
import 'package:servi_sur/shared/domain/entities/order.dart';
import 'package:servi_sur/shared/domain/entities/service_request.dart';

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

  test('order tolerates missing image fields', () {
    final order = Order.fromMap({'serviceTitle': 'Electricidad'});

    expect(order.imageUrls, isEmpty);
    expect(order.imagePaths, isEmpty);
    expect(order.attachments, isEmpty);
  });

  test('order parses image metadata from Firestore maps', () {
    final order = Order.fromMap({
      'imageUrls': ['https://example.com/a.jpg'],
      'imagePaths': ['request_images/u/o/a.jpg'],
      'attachments': [
        {
          'url': 'https://example.com/a.jpg',
          'path': 'request_images/u/o/a.jpg',
        },
      ],
    });

    expect(order.imageUrls, ['https://example.com/a.jpg']);
    expect(order.imagePaths, ['request_images/u/o/a.jpg']);
    expect(order.attachments.first['path'], 'request_images/u/o/a.jpg');
  });

  test('service request parses imageUrls and falls back from photoUrls', () {
    final withImageUrls = ServiceRequest.fromMap({
      'imageUrls': ['https://example.com/request.jpg'],
      'imagePaths': ['request_images/u/r/request.jpg'],
    });
    final withPhotoUrls = ServiceRequest.fromMap({
      'photoUrls': ['https://example.com/legacy.jpg'],
    });

    expect(withImageUrls.imageUrls, ['https://example.com/request.jpg']);
    expect(withImageUrls.photoUrls, ['https://example.com/request.jpg']);
    expect(withImageUrls.imagePaths, ['request_images/u/r/request.jpg']);
    expect(withPhotoUrls.imageUrls, ['https://example.com/legacy.jpg']);
  });
}
