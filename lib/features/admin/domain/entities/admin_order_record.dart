class AdminOrderRecord {
  const AdminOrderRecord({
    required this.id,
    required this.clientName,
    required this.providerName,
    required this.serviceName,
    required this.category,
    required this.date,
    required this.status,
    required this.total,
    required this.currency,
  });

  final String id;
  final String clientName;
  final String providerName;
  final String serviceName;
  final String category;
  final DateTime date;
  final String status;
  final double total;
  final String currency;

  AdminOrderRecord copyWith({
    String? id,
    String? clientName,
    String? providerName,
    String? serviceName,
    String? category,
    DateTime? date,
    String? status,
    double? total,
    String? currency,
  }) {
    return AdminOrderRecord(
      id: id ?? this.id,
      clientName: clientName ?? this.clientName,
      providerName: providerName ?? this.providerName,
      serviceName: serviceName ?? this.serviceName,
      category: category ?? this.category,
      date: date ?? this.date,
      status: status ?? this.status,
      total: total ?? this.total,
      currency: currency ?? this.currency,
    );
  }
}
