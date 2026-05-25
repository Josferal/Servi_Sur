import '../../models/order.dart';
import '../../models/service_category.dart';
import '../../models/service_item.dart';
import '../../models/user_model.dart';
import '../../repositories/marketplace_repository.dart';
import '../core/admin_colors.dart';
import '../models/admin_activity.dart';
import '../models/admin_chart_segment.dart';
import '../models/admin_order_record.dart';
import '../models/admin_report_point.dart';
import '../models/admin_role_config.dart';
import '../models/admin_settings.dart';
import 'admin_repository.dart';

class MockAdminRepository implements AdminRepository {
  MockAdminRepository(this._marketplace);

  final MarketplaceRepository _marketplace;
  List<UserModel>? _users;
  List<ServiceItem>? _services;
  List<AdminOrderRecord>? _orders;
  final List<AdminActivity> _activities = [
    const AdminActivity(
      time: 'Hace 5 min',
      user: 'Alejandro Silva',
      action: 'Contrato Limpieza Profunda',
      status: 'Completada',
    ),
    const AdminActivity(
      time: 'Hace 12 min',
      user: 'Carlos Mendoza',
      action: 'Envio servicio a revision',
      status: 'Pendiente',
    ),
    const AdminActivity(
      time: 'Hace 45 min',
      user: 'Elena Rodriguez',
      action: 'Actualizo perfil de proveedor',
      status: 'Activo',
    ),
    const AdminActivity(
      time: 'Hoy 09:15',
      user: 'Admin Principal',
      action: 'Activo aprobacion manual de proveedores',
      status: 'Configuracion',
    ),
  ];

  @override
  UserModel get currentAdmin => UserModel(
    id: 'admin-001',
    fullName: 'Admin Principal',
    email: 'No definido',
    phone: '+506 2222 0000',
    role: UserRole.admin,
    createdAt: DateTime(2025, 1, 5),
    status: UserStatus.active,
  );

  @override
  AdminSettings getSettings() => const AdminSettings(
    platformName: 'ServiMarket Marketplace',
    supportEmail: 'No definido',
    maintenanceMode: false,
    notificationsEnabled: true,
    manualProviderApproval: true,
    twoFactorRequired: false,
    taxRate: 13,
  );

  @override
  List<UserModel> getUsers() {
    final provider = _marketplace.featuredProviderProfile;
    _users ??= [
      currentAdmin,
      _marketplace.currentUser,
      UserModel(
        id: provider.userId,
        fullName: provider.displayName,
        email: provider.email,
        phone: provider.phone,
        role: UserRole.provider,
        avatarUrl: provider.avatarUrl,
        createdAt: DateTime(2025, 11, 6),
      ),
      UserModel(
        id: 'client-002',
        fullName: 'Elena Rodriguez',
        email: 'No definido',
        phone: '+506 8888 9080',
        role: UserRole.client,
        createdAt: DateTime(2026, 3, 12),
      ),
      UserModel(
        id: 'provider-002',
        fullName: 'Carlos Mendoza',
        email: 'No definido',
        phone: '+506 8888 6767',
        role: UserRole.provider,
        createdAt: DateTime(2026, 2, 4),
      ),
      UserModel(
        id: 'client-003',
        fullName: 'Marina Soto',
        email: 'No definido',
        phone: '+506 7777 3311',
        role: UserRole.client,
        createdAt: DateTime(2026, 1, 21),
        status: UserStatus.inactive,
      ),
      UserModel(
        id: 'provider-003',
        fullName: 'Ricardo Palma',
        email: 'No definido',
        phone: '+506 8700 6677',
        role: UserRole.provider,
        createdAt: DateTime(2025, 12, 9),
        status: UserStatus.suspended,
      ),
    ];
    return List.unmodifiable(_users!);
  }

  @override
  List<ServiceItem> getServices() {
    final base = _marketplace.getServices();
    _services ??= [
      ...base,
      base[0].copyWith(
        id: 'smart-ac',
        title: 'Reparacion de Aire Acondicionado',
        categoryId: 'electricians',
        categoryName: 'Electricistas',
        providerName: 'ElectroFix Soluciones',
        price: 70,
        rating: 4.7,
        reviewCount: 56,
        status: ServiceStatus.paused,
        isFeatured: false,
      ),
      base[1].copyWith(
        id: 'garden-care',
        title: 'Jardineria Mensual',
        categoryId: 'cleaning',
        categoryName: 'Limpieza',
        providerName: 'Jardines del Norte',
        price: 65,
        rating: 4.6,
        reviewCount: 42,
        status: ServiceStatus.draft,
        isFeatured: false,
      ),
      base[3].copyWith(
        id: 'express-delivery',
        title: 'Entrega Express Comercial',
        providerName: 'Fast Delivery',
        price: 45,
        rating: 4.5,
        reviewCount: 38,
        status: ServiceStatus.active,
        isFeatured: false,
      ),
    ];
    return List.unmodifiable(_services!);
  }

  @override
  List<AdminOrderRecord> getOrders() {
    final mapped = _marketplace.getOrders().map((order) {
      return AdminOrderRecord(
        id: order.id,
        clientName: _clientName(order.clientId),
        providerName: order.providerName,
        serviceName: order.title,
        category: order.category,
        date: order.scheduledAt,
        status: _orderStatusLabel(order.status),
        total: order.total,
        currency: order.currency,
      );
    }).toList();

    _orders ??= [
      AdminOrderRecord(
        id: 'order-010',
        clientName: 'Roberto Gomez',
        providerName: 'Expertos Plomeros',
        serviceName: 'Plomeria de emergencia',
        category: 'Plomeria',
        date: DateTime(2026, 5, 14, 10, 30),
        status: 'Pendiente',
        total: 85,
        currency: 'USD',
      ),
      AdminOrderRecord(
        id: 'order-011',
        clientName: 'Ana Martinez',
        providerName: 'CleanHome Pro',
        serviceName: 'Limpieza General',
        category: 'Limpieza',
        date: DateTime(2026, 5, 13, 14),
        status: 'En proceso',
        total: 45,
        currency: 'USD',
      ),
      ...mapped,
      AdminOrderRecord(
        id: 'order-012',
        clientName: 'Laura Ruiz',
        providerName: 'Jardines del Norte',
        serviceName: 'Jardineria Mensual',
        category: 'Jardineria',
        date: DateTime(2026, 5, 10, 8),
        status: 'Completada',
        total: 65,
        currency: 'USD',
      ),
    ];
    return List.unmodifiable(_orders!);
  }

  @override
  List<ServiceCategory> getCategories() => _marketplace.getCategories();

  @override
  List<AdminActivity> getRecentActivity() =>
      List.unmodifiable(_activities.take(12));

  @override
  List<AdminReportPoint> getRevenueReport() => const [
    AdminReportPoint(label: 'Lun', current: 42, previous: 30),
    AdminReportPoint(label: 'Mar', current: 58, previous: 36),
    AdminReportPoint(label: 'Mie', current: 46, previous: 44),
    AdminReportPoint(label: 'Jue', current: 70, previous: 52),
    AdminReportPoint(label: 'Vie', current: 86, previous: 64),
    AdminReportPoint(label: 'Sab', current: 62, previous: 48),
    AdminReportPoint(label: 'Dom', current: 74, previous: 56),
  ];

  @override
  List<AdminChartSegment> getOrderStatusSegments() {
    final orders = getOrders();
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
        value: orders
            .where((order) => order.status == status)
            .length
            .toDouble(),
        color: colors[index],
      );
    });
  }

  @override
  List<AdminChartSegment> getUserRoleSegments() {
    final users = getUsers();
    return [
      AdminChartSegment(
        label: 'Clientes',
        value: users
            .where((user) => user.role == UserRole.client)
            .length
            .toDouble(),
        color: AdminColors.primary,
      ),
      AdminChartSegment(
        label: 'Proveedores',
        value: users
            .where((user) => user.role == UserRole.provider)
            .length
            .toDouble(),
        color: AdminColors.blue,
      ),
      AdminChartSegment(
        label: 'Administradores',
        value: users
            .where((user) => user.role == UserRole.admin)
            .length
            .toDouble(),
        color: AdminColors.warning,
      ),
    ];
  }

  @override
  List<AdminRoleConfig> getRoles() => const [
    AdminRoleConfig(
      name: 'Administrador',
      description: 'Gestion total del marketplace y configuraciones.',
      users: 1,
      permissions: ['usuarios', 'servicios', 'ordenes', 'reportes'],
    ),
    AdminRoleConfig(
      name: 'Proveedor',
      description: 'Gestiona servicios, disponibilidad y ordenes asignadas.',
      users: 3,
      permissions: ['servicios', 'ordenes'],
    ),
    AdminRoleConfig(
      name: 'Cliente',
      description: 'Solicita servicios y administra su perfil.',
      users: 3,
      permissions: ['solicitudes', 'perfil'],
    ),
  ];

  @override
  bool updateUserStatus(String userId, UserStatus status) {
    getUsers();
    final users = _users!;
    final index = users.indexWhere((user) => user.id == userId);
    if (index == -1 ||
        (userId == currentAdmin.id && status != UserStatus.active)) {
      return false;
    }

    final user = users[index];
    users[index] = user.copyWith(status: status);
    _recordActivity(
      user: currentAdmin.fullName,
      action: '${_userStatusAction(status)} ${user.fullName}',
      status: _userStatusLabel(status),
    );
    return true;
  }

  @override
  bool updateServiceStatus(String serviceId, ServiceStatus status) {
    getServices();
    final services = _services!;
    final index = services.indexWhere((service) => service.id == serviceId);
    if (index == -1) {
      return false;
    }

    final service = services[index];
    services[index] = service.copyWith(
      status: status,
      updatedAt: DateTime.now(),
    );
    _recordActivity(
      user: currentAdmin.fullName,
      action: '${_serviceStatusAction(status)} ${service.title}',
      status: _serviceStatusLabel(status),
    );
    return true;
  }

  @override
  bool deleteService(String serviceId) {
    getServices();
    final services = _services!;
    final index = services.indexWhere((service) => service.id == serviceId);
    if (index == -1) {
      return false;
    }

    final service = services.removeAt(index);
    _recordActivity(
      user: currentAdmin.fullName,
      action: 'Elimino servicio mock ${service.title}',
      status: 'Eliminado',
    );
    return true;
  }

  @override
  bool updateOrderStatus(String orderId, String status) {
    getOrders();
    final orders = _orders!;
    final index = orders.indexWhere((order) => order.id == orderId);
    if (index == -1) {
      return false;
    }

    final order = orders[index];
    orders[index] = order.copyWith(status: status);
    _recordActivity(
      user: currentAdmin.fullName,
      action: 'Cambio orden ${order.id} a $status',
      status: status,
    );
    return true;
  }

  String _clientName(String clientId) {
    for (final user in getUsers()) {
      if (user.id == clientId) {
        return user.fullName;
      }
    }
    return 'Cliente ServiMarket';
  }

  String _orderStatusLabel(OrderStatus status) {
    return switch (status) {
      OrderStatus.pending => 'Pendiente',
      OrderStatus.accepted => 'Aceptada',
      OrderStatus.inProgress => 'En proceso',
      OrderStatus.active => 'En proceso',
      OrderStatus.completed => 'Completada',
      OrderStatus.cancelled => 'Cancelada',
    };
  }

  void _recordActivity({
    required String user,
    required String action,
    required String status,
  }) {
    _activities.insert(
      0,
      AdminActivity(time: 'Ahora', user: user, action: action, status: status),
    );
  }

  String _userStatusAction(UserStatus status) {
    return switch (status) {
      UserStatus.active => 'Activo usuario',
      UserStatus.inactive => 'Desactivo usuario',
      UserStatus.suspended => 'Suspendio usuario',
      UserStatus.deleted => 'Elimino usuario',
    };
  }

  String _userStatusLabel(UserStatus status) {
    return switch (status) {
      UserStatus.active => 'Activo',
      UserStatus.inactive => 'Inactivo',
      UserStatus.suspended => 'Suspendido',
      UserStatus.deleted => 'Eliminado',
    };
  }

  String _serviceStatusAction(ServiceStatus status) {
    return switch (status) {
      ServiceStatus.draft => 'Envio servicio a revision',
      ServiceStatus.active => 'Aprobo servicio',
      ServiceStatus.paused => 'Pauso servicio',
      ServiceStatus.archived => 'Oculto servicio',
    };
  }

  String _serviceStatusLabel(ServiceStatus status) {
    return switch (status) {
      ServiceStatus.draft => 'Pendiente',
      ServiceStatus.active => 'Publicado',
      ServiceStatus.paused => 'Pausado',
      ServiceStatus.archived => 'Archivado',
    };
  }
}
