import 'package:flutter_test/flutter_test.dart';
import 'package:servi_sur/models/service_category.dart';
import 'package:servi_sur/models/service_item.dart';
import 'package:servi_sur/repositories/mock_marketplace_repository.dart';

void main() {
  test('service category tolerates incomplete Firestore maps', () {
    final category = ServiceCategory.fromMap({'name': 'Limpieza'});

    expect(category.id, isEmpty);
    expect(category.name, 'Limpieza');
    expect(category.isActive, isTrue);
    expect(category.sortOrder, 0);
  });

  test('service item tolerates incomplete Firestore maps', () {
    final service = ServiceItem.fromMap({
      'title': 'Servicio basico',
      'price': 25,
      'priceType': 'visit',
      'reviewsCount': 3,
      'isActive': true,
    });

    expect(service.title, 'Servicio basico');
    expect(service.price, 25);
    expect(service.pricingType, ServicePricingType.visit);
    expect(service.reviewCount, 3);
    expect(service.status, ServiceStatus.active);
  });

  test(
    'mock marketplace repository still provides categories and services',
    () {
      final repository = MockMarketplaceRepository();

      expect(repository.getCategories(), isNotEmpty);
      expect(repository.getServices(), isNotEmpty);
    },
  );
}
