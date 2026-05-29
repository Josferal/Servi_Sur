class AdminMetric {
  const AdminMetric({
    required this.label,
    required this.value,
    required this.iconKey,
    this.delta,
    this.colorValue,
  });

  final String label;
  final String value;
  final String iconKey;
  final String? delta;
  final int? colorValue;
}
