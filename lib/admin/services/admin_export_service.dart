import '../../models/service_item.dart';
import '../../models/user_model.dart';
import '../models/admin_order_record.dart';
import 'admin_csv_downloader.dart';

class AdminExportService {
  const AdminExportService._();

  static String buildAdminReportCsv({
    required List<UserModel> users,
    required List<ServiceItem> services,
    required List<AdminOrderRecord> orders,
  }) {
    final rows = <List<String>>[
      ['seccion', 'id', 'nombre', 'tipo', 'estado', 'valor', 'detalle'],
      [
        'resumen',
        'usuarios',
        'Usuarios registrados',
        'metrica',
        '',
        users.length.toString(),
        '',
      ],
      [
        'resumen',
        'servicios',
        'Servicios disponibles',
        'metrica',
        '',
        services.length.toString(),
        '',
      ],
      [
        'resumen',
        'ordenes',
        'Ordenes totales',
        'metrica',
        '',
        orders.length.toString(),
        '',
      ],
      [
        'resumen',
        'ingresos',
        'Ingresos completados',
        'metrica',
        'Completada',
        orders
            .where((order) => order.status == 'Completada')
            .fold<double>(0, (total, order) => total + order.total)
            .toStringAsFixed(2),
        'USD',
      ],
      ...users.map(
        (user) => [
          'usuarios',
          user.id,
          user.fullName,
          user.role.name,
          user.status.name,
          user.email,
          user.phone,
        ],
      ),
      ...services.map(
        (service) => [
          'servicios',
          service.id,
          service.title,
          service.categoryName,
          service.status.name,
          service.price.toStringAsFixed(2),
          service.providerName,
        ],
      ),
      ...orders.map(
        (order) => [
          'ordenes',
          order.id,
          order.serviceName,
          order.category,
          order.status,
          order.total.toStringAsFixed(2),
          '${order.clientName} / ${order.providerName}',
        ],
      ),
    ];

    return _rowsToCsv(rows);
  }

  static Future<bool> downloadAdminReportCsv({
    required List<UserModel> users,
    required List<ServiceItem> services,
    required List<AdminOrderRecord> orders,
  }) {
    final csv = buildAdminReportCsv(
      users: users,
      services: services,
      orders: orders,
    );
    final stamp = DateTime.now().toIso8601String().substring(0, 10);
    return downloadCsv(csv, 'servimarket-admin-report-$stamp.csv');
  }

  static String ordersToCsv(List<AdminOrderRecord> orders) {
    final rows = [
      ['id', 'cliente', 'proveedor', 'servicio', 'estado', 'monto'],
      ...orders.map(
        (order) => [
          order.id,
          order.clientName,
          order.providerName,
          order.serviceName,
          order.status,
          order.total.toStringAsFixed(2),
        ],
      ),
    ];
    return _rowsToCsv(rows);
  }

  static String _rowsToCsv(List<List<String>> rows) {
    return rows.map((row) => row.map(_escapeCsv).join(',')).join('\n');
  }

  static String _escapeCsv(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }
}
