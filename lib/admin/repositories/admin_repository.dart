import '../../models/service_category.dart';
import '../../models/service_item.dart';
import '../../models/user_model.dart';
import '../models/admin_activity.dart';
import '../models/admin_chart_segment.dart';
import '../models/admin_order_record.dart';
import '../models/admin_report_point.dart';
import '../models/admin_role_config.dart';
import '../models/admin_settings.dart';

abstract class AdminRepository {
  // TODO(firebase): Implement this contract with Firebase Auth, Firestore
  // and Cloud Functions when real admin data is available.
  UserModel get currentAdmin;
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
}
