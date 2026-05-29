import 'package:flutter/material.dart';
import 'package:servi_sur/shared/domain/entities/service_item.dart';

extension ServiceBadgeColor on ServiceItem {
  Color? get badgeColor {
    final value = badgeColorValue;
    return value == null ? null : Color(value);
  }
}
