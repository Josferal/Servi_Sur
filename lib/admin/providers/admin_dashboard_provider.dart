import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/service_category.dart';
import '../../models/service_item.dart';
import '../../models/user_model.dart';
import '../core/admin_colors.dart';
import '../models/admin_activity.dart';
import '../models/admin_chart_segment.dart';
import '../models/admin_metric.dart';
import '../models/admin_order_record.dart';
import '../models/admin_report_point.dart';
import '../models/admin_role_config.dart';
import '../models/admin_settings.dart';
import '../repositories/admin_repository.dart';
import '../services/admin_export_service.dart';

class AdminDashboardProvider extends ChangeNotifier {
  AdminDashboardProvider(this._repository)
    : _settings = _repository.getSettings();

  AdminRepository _repository;
  AdminSettings _settings;

  final _compactCurrency = NumberFormat.compactCurrency(
    symbol: r'$',
    locale: 'en_US',
  );
  final _fullCurrency = NumberFormat.currency(symbol: r'$', locale: 'en_US');

  String _userQuery = '';
  String _userRoleFilter = 'Todos los roles';
  String _userStatusFilter = 'Cualquier estado';
  String _serviceQuery = '';
  String _serviceCategoryFilter = 'Todas las categorias';
  String _serviceStatusFilter = 'Todos';
  String _orderQuery = '';
  String _orderStatusFilter = 'Todas';
  String _reportDateFilter = 'Ultimos 30 dias';
  String _reportStatusFilter = 'Todas';
  bool _isBusy = false;

  AdminSettings get settings => _settings;
  bool get isBusy => _isBusy;
  UserModel get currentAdmin => _repository.currentAdmin;
  List<UserModel> get users => _repository.getUsers();
  List<ServiceItem> get services => _repository.getServices();
  List<AdminOrderRecord> get orders => _repository.getOrders();
  List<ServiceCategory> get categories => _repository.getCategories();
  List<AdminActivity> get recentActivity => _repository.getRecentActivity();
  List<AdminReportPoint> get reportPoints => _buildReportPoints(orders);
  List<AdminReportPoint> get filteredReportPoints =>
      _buildReportPoints(filteredReportOrders);
  List<AdminChartSegment> get orderStatusSegments =>
      _buildOrderStatusSegments(orders);
  List<AdminChartSegment> get reportOrderStatusSegments =>
      _buildOrderStatusSegments(filteredReportOrders);
  List<AdminChartSegment> get userRoleSegments =>
      _repository.getUserRoleSegments();
  List<AdminRoleConfig> get roles => _repository.getRoles();

  String get userRoleFilter => _userRoleFilter;
  String get userStatusFilter => _userStatusFilter;
  String get serviceCategoryFilter => _serviceCategoryFilter;
  String get serviceStatusFilter => _serviceStatusFilter;
  String get orderStatusFilter => _orderStatusFilter;
  String get reportDateFilter => _reportDateFilter;
  String get reportStatusFilter => _reportStatusFilter;

  void updateRepository(AdminRepository repository) {
    _repository = repository;
    _settings = repository.getSettings();
  }

  List<UserModel> get filteredUsers {
    return users.where((user) {
      final query = _userQuery.toLowerCase();
      final roleMatches =
          _userRoleFilter == 'Todos los roles' ||
          roleLabel(user) == _userRoleFilter;
      final statusMatches =
          _userStatusFilter == 'Cualquier estado' ||
          userStatusLabel(user.status) == _userStatusFilter;
      final queryMatches =
          query.isEmpty ||
          user.fullName.toLowerCase().contains(query) ||
          user.email.toLowerCase().contains(query) ||
          user.id.toLowerCase().contains(query);
      return roleMatches && statusMatches && queryMatches;
    }).toList();
  }

  List<ServiceItem> get filteredServices {
    return services.where((service) {
      final query = _serviceQuery.toLowerCase();
      final categoryMatches =
          _serviceCategoryFilter == 'Todas las categorias' ||
          service.categoryName == _serviceCategoryFilter;
      final statusMatches =
          _serviceStatusFilter == 'Todos' ||
          serviceStatusLabel(service.status) == _serviceStatusFilter;
      final queryMatches =
          query.isEmpty ||
          service.title.toLowerCase().contains(query) ||
          service.providerName.toLowerCase().contains(query) ||
          service.categoryName.toLowerCase().contains(query) ||
          service.id.toLowerCase().contains(query);
      return categoryMatches && statusMatches && queryMatches;
    }).toList();
  }

  List<AdminOrderRecord> get filteredOrders {
    return orders.where((order) {
      final query = _orderQuery.toLowerCase();
      final statusMatches =
          _orderStatusFilter == 'Todas' || order.status == _orderStatusFilter;
      final queryMatches =
          query.isEmpty ||
          order.id.toLowerCase().contains(query) ||
          order.clientName.toLowerCase().contains(query) ||
          order.providerName.toLowerCase().contains(query) ||
          order.serviceName.toLowerCase().contains(query);
      return statusMatches && queryMatches;
    }).toList();
  }

  List<AdminOrderRecord> get filteredReportOrders {
    return orders.where((order) {
      final dateMatches = _matchesReportDate(order.date);
      final statusMatches =
          _reportStatusFilter == 'Todas' || order.status == _reportStatusFilter;
      return dateMatches && statusMatches;
    }).toList();
  }

  List<AdminMetric> get dashboardMetrics {
    final providers = users
        .where(
          (user) =>
              user.role == UserRole.provider &&
              user.status == UserStatus.active,
        )
        .length;
    final activeServices = services
        .where((service) => service.status == ServiceStatus.active)
        .length;
    final pendingOrders = orders
        .where((order) => order.status == 'Pendiente')
        .length;
    final completedOrders = orders
        .where((order) => order.status == 'Completada')
        .length;

    return [
      AdminMetric(
        label: 'Usuarios registrados',
        value: users.length.toString(),
        icon: Icons.group_rounded,
        delta: '+8.2%',
      ),
      AdminMetric(
        label: 'Proveedores activos',
        value: providers.toString(),
        icon: Icons.verified_user_rounded,
        delta: '+5.4%',
      ),
      AdminMetric(
        label: 'Servicios activos',
        value: activeServices.toString(),
        icon: Icons.design_services_rounded,
        delta: '+12.4%',
      ),
      AdminMetric(
        label: 'Ordenes totales',
        value: orders.length.toString(),
        icon: Icons.receipt_long_rounded,
        delta: '+6.1%',
      ),
      AdminMetric(
        label: 'Ordenes pendientes',
        value: pendingOrders.toString(),
        icon: Icons.pending_actions_rounded,
        delta: 'Atencion',
        color: AdminColors.warning,
      ),
      AdminMetric(
        label: 'Ordenes completadas',
        value: completedOrders.toString(),
        icon: Icons.task_alt_rounded,
        delta: '+9.3%',
      ),
      AdminMetric(
        label: 'Ingresos simulados',
        value: _compactCurrency.format(totalRevenue),
        icon: Icons.payments_rounded,
        delta: '+4.8%',
      ),
    ];
  }

  List<AdminMetric> get reportMetrics {
    final scopedOrders = filteredReportOrders;
    final completedOrders = scopedOrders
        .where((order) => order.status == 'Completada')
        .toList();
    final scopedRevenue = completedOrders.fold<double>(
      0,
      (total, order) => total + order.total,
    );

    return [
      AdminMetric(
        label: 'Ingresos totales',
        value: _fullCurrency.format(scopedRevenue),
        icon: Icons.attach_money_rounded,
        delta: '+10.5%',
      ),
      AdminMetric(
        label: 'Ordenes completadas',
        value: completedOrders.length.toString(),
        icon: Icons.receipt_long_rounded,
        delta: '+6.1%',
      ),
      AdminMetric(
        label: 'Nuevos usuarios',
        value: users
            .where((user) => user.createdAt.isAfter(DateTime(2026, 1, 1)))
            .length
            .toString(),
        icon: Icons.person_add_alt_1_rounded,
        delta: '+8.2%',
      ),
      const AdminMetric(
        label: 'Satisfaccion cliente',
        value: '4.8 / 5.0',
        icon: Icons.star_rounded,
        delta: '+0.3',
      ),
    ];
  }

  double get totalRevenue => orders
      .where((order) => order.status == 'Completada')
      .fold<double>(0, (total, order) => total + order.total);

  List<String> get roleOptions => const [
    'Todos los roles',
    'Cliente',
    'Proveedor',
    'Administrador',
  ];

  List<String> get userStatusOptions => const [
    'Cualquier estado',
    'Activo',
    'Inactivo',
    'Suspendido',
  ];

  List<String> get serviceCategoryOptions => [
    'Todas las categorias',
    ...services.map((service) => service.categoryName).toSet(),
  ];

  List<String> get serviceStatusOptions => const [
    'Todos',
    'Publicado',
    'Pendiente',
    'Pausado',
    'Archivado',
  ];

  List<String> get orderStatusOptions => const [
    'Todas',
    'Pendiente',
    'En proceso',
    'Completada',
    'Cancelada',
  ];

  List<String> get reportDateOptions => const [
    'Ultimos 7 dias',
    'Ultimos 30 dias',
    'Este trimestre',
  ];

  void setUserQuery(String value) {
    _userQuery = value;
    notifyListeners();
  }

  void setUserRoleFilter(String? value) {
    _userRoleFilter = value ?? 'Todos los roles';
    notifyListeners();
  }

  void setUserStatusFilter(String? value) {
    _userStatusFilter = value ?? 'Cualquier estado';
    notifyListeners();
  }

  void resetUserFilters() {
    _userQuery = '';
    _userRoleFilter = 'Todos los roles';
    _userStatusFilter = 'Cualquier estado';
    notifyListeners();
  }

  void setServiceQuery(String value) {
    _serviceQuery = value;
    notifyListeners();
  }

  void setServiceCategoryFilter(String? value) {
    _serviceCategoryFilter = value ?? 'Todas las categorias';
    notifyListeners();
  }

  void setServiceStatusFilter(String? value) {
    _serviceStatusFilter = value ?? 'Todos';
    notifyListeners();
  }

  void setOrderQuery(String value) {
    _orderQuery = value;
    notifyListeners();
  }

  void setOrderStatusFilter(String value) {
    _orderStatusFilter = value;
    notifyListeners();
  }

  void setReportDateFilter(String? value) {
    _reportDateFilter = value ?? 'Ultimos 30 dias';
    notifyListeners();
  }

  void setReportStatusFilter(String value) {
    _reportStatusFilter = value;
    notifyListeners();
  }

  void updateSettings(AdminSettings settings) {
    _settings = settings;
    notifyListeners();
  }

  Future<bool> setUserStatus(String userId, UserStatus status) {
    return _runMutation(() => _repository.updateUserStatus(userId, status));
  }

  Future<bool> toggleUserActive(UserModel user) {
    final nextStatus = user.status == UserStatus.active
        ? UserStatus.inactive
        : UserStatus.active;
    return setUserStatus(user.id, nextStatus);
  }

  Future<bool> blockUser(UserModel user) {
    return setUserStatus(user.id, UserStatus.suspended);
  }

  Future<bool> approveService(String serviceId) {
    return _runMutation(
      () => _repository.updateServiceStatus(serviceId, ServiceStatus.active),
    );
  }

  Future<bool> pauseService(String serviceId) {
    return _runMutation(
      () => _repository.updateServiceStatus(serviceId, ServiceStatus.paused),
    );
  }

  Future<bool> hideService(String serviceId) {
    return _runMutation(
      () => _repository.updateServiceStatus(serviceId, ServiceStatus.archived),
    );
  }

  Future<bool> deleteService(String serviceId) {
    return _runMutation(() => _repository.deleteService(serviceId));
  }

  Future<bool> setOrderStatus(String orderId, String status) {
    return _runMutation(() => _repository.updateOrderStatus(orderId, status));
  }

  Future<bool> cancelOrder(String orderId) {
    return setOrderStatus(orderId, 'Cancelada');
  }

  String buildOrdersCsv() {
    return AdminExportService.ordersToCsv(orders);
  }

  String buildAdminReportCsv() {
    return AdminExportService.buildAdminReportCsv(
      users: users,
      services: services,
      orders: orders,
    );
  }

  Future<bool> downloadAdminReportCsv() {
    return AdminExportService.downloadAdminReportCsv(
      users: users,
      services: services,
      orders: orders,
    );
  }

  String formatMoney(num value) => _fullCurrency.format(value);

  Future<bool> _runMutation(bool Function() mutation) async {
    if (_isBusy) {
      return false;
    }

    _isBusy = true;
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 160));

    final success = mutation();
    _isBusy = false;
    notifyListeners();
    return success;
  }

  bool _matchesReportDate(DateTime date) {
    final now = DateTime.now();
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final today = DateTime(now.year, now.month, now.day);

    return switch (_reportDateFilter) {
      'Ultimos 7 dias' => !normalizedDate.isBefore(
        today.subtract(const Duration(days: 7)),
      ),
      'Este trimestre' => !normalizedDate.isBefore(
        DateTime(now.year, ((now.month - 1) ~/ 3) * 3 + 1),
      ),
      _ => !normalizedDate.isBefore(today.subtract(const Duration(days: 30))),
    };
  }

  List<AdminReportPoint> _buildReportPoints(List<AdminOrderRecord> source) {
    const labels = ['Lun', 'Mar', 'Mie', 'Jue', 'Vie', 'Sab', 'Dom'];
    return List.generate(labels.length, (index) {
      final weekday = index + 1;
      final current = source
          .where(
            (order) =>
                order.status == 'Completada' && order.date.weekday == weekday,
          )
          .fold<double>(0, (total, order) => total + order.total);

      return AdminReportPoint(
        label: labels[index],
        current: current,
        previous: current == 0 ? (index + 1) * 4.0 : current * 0.72,
      );
    });
  }

  List<AdminChartSegment> _buildOrderStatusSegments(
    List<AdminOrderRecord> source,
  ) {
    final statuses = ['Pendiente', 'En proceso', 'Completada', 'Cancelada'];
    final colors = [
      AdminColors.warning,
      AdminColors.blue,
      AdminColors.primary,
      AdminColors.danger,
    ];

    return List.generate(statuses.length, (index) {
      final status = statuses[index];
      return AdminChartSegment(
        label: status,
        value: source
            .where((order) => order.status == status)
            .length
            .toDouble(),
        color: colors[index],
      );
    });
  }

  String roleLabel(UserModel user) {
    return switch (user.role) {
      UserRole.admin => 'Administrador',
      UserRole.provider => 'Proveedor',
      UserRole.client => 'Cliente',
    };
  }

  String userStatusLabel(UserStatus status) {
    return switch (status) {
      UserStatus.active => 'Activo',
      UserStatus.inactive => 'Inactivo',
      UserStatus.suspended => 'Suspendido',
      UserStatus.deleted => 'Eliminado',
    };
  }

  String serviceStatusLabel(ServiceStatus status) {
    return switch (status) {
      ServiceStatus.draft => 'Pendiente',
      ServiceStatus.active => 'Publicado',
      ServiceStatus.paused => 'Pausado',
      ServiceStatus.archived => 'Archivado',
    };
  }

  Color statusColor(String status) {
    final normalized = status.toLowerCase();
    if (normalized.contains('cancel') ||
        normalized.contains('suspend') ||
        normalized.contains('elimin')) {
      return AdminColors.danger;
    }
    if (normalized.contains('pend') ||
        normalized.contains('revision') ||
        normalized.contains('draft')) {
      return AdminColors.warning;
    }
    if (normalized.contains('proceso') ||
        normalized.contains('inactivo') ||
        normalized.contains('paus')) {
      return AdminColors.blue;
    }
    return AdminColors.primary;
  }
}
