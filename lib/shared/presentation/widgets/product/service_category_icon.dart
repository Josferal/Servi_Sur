import 'package:flutter/material.dart';
import 'package:servi_sur/shared/domain/entities/service_category.dart';

extension ServiceCategoryIcon on ServiceCategory {
  IconData get icon {
    return switch (iconKey) {
      'electricians' => Icons.flash_on_rounded,
      'plumbers' => Icons.handyman_rounded,
      'food' => Icons.restaurant_rounded,
      'transport' => Icons.local_shipping_rounded,
      'cleaning' => Icons.cleaning_services_rounded,
      'design' => Icons.architecture_rounded,
      _ => Icons.category_rounded,
    };
  }
}
