import 'package:servi_sur/shared/domain/entities/service_category.dart';
import 'package:servi_sur/shared/domain/entities/service_item.dart';
import 'package:servi_sur/shared/domain/entities/user_model.dart';
import 'package:servi_sur/features/admin/domain/entities/admin_activity.dart';
import 'package:servi_sur/features/admin/domain/entities/admin_chart_segment.dart';
import 'package:servi_sur/features/admin/domain/entities/admin_order_record.dart';
import 'package:servi_sur/features/admin/domain/entities/admin_report_point.dart';
import 'package:servi_sur/features/admin/domain/entities/admin_role_config.dart';
import 'package:servi_sur/features/admin/domain/entities/admin_settings.dart';

abstract class AdminRepository {
  UserModel get currentAdmin;
  String? get lastError;
  AdminSettings getSettings();
  List<UserModel> getUsers();
  List<ServiceItem> getServices();
  List<AdminOrderRecord> getOrders();
  List<ServiceCategory> getCategories();
  List<AdminActivity> getRecentActivity();
  List<AdminReportPoint> getRevenueReport();
  List<AdminChartSegment> getOrderStatusSegments();
  List<AdminChartSegment> getUserRoleSegments();
  List<AdminRoleConfig> getRoles();
  bool updateUserStatus(String userId, UserStatus status);
  bool updateServiceStatus(String serviceId, ServiceStatus status);
  bool deleteService(String serviceId);
  bool updateOrderStatus(String orderId, String status);
  Future<void> loadUsers();
  Future<bool> updateUser(
    String userId, {
    required String name,
    required String phone,
    required UserRole role,
    required UserStatus status,
  });
  Future<bool> createBasicUser({
    required String name,
    required String email,
    required String password,
    required String phone,
    required UserRole role,
    required UserStatus status,
  });
}
