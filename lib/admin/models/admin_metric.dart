import 'package:flutter/material.dart';

class AdminMetric {
  const AdminMetric({
    required this.label,
    required this.value,
    required this.icon,
    this.delta,
    this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final String? delta;
  final Color? color;
}
