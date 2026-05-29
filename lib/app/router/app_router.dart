import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import 'package:servi_sur/features/admin/core/admin_routes.dart';
import 'package:servi_sur/features/admin/presentation/pages/admin_dashboard_screen.dart';
import 'package:servi_sur/features/admin/presentation/pages/admin_login_screen.dart';
import 'package:servi_sur/features/admin/presentation/pages/admin_orders_screen.dart';
import 'package:servi_sur/features/admin/presentation/pages/admin_reports_screen.dart';
import 'package:servi_sur/features/admin/presentation/pages/admin_services_screen.dart';
import 'package:servi_sur/features/admin/presentation/pages/admin_settings_screen.dart';
import 'package:servi_sur/features/admin/presentation/pages/admin_users_screen.dart';
import 'package:servi_sur/features/admin/presentation/widgets/admin_shell.dart';
import 'package:servi_sur/features/activity/presentation/pages/orders_history_screen.dart';
import 'package:servi_sur/features/tracking/presentation/pages/tracking_screen.dart';
import 'package:servi_sur/features/auth/presentation/pages/login_screen.dart';
import 'package:servi_sur/features/auth/presentation/pages/register_screen.dart';
import 'package:servi_sur/features/order/presentation/pages/order_summary_screen.dart';
import 'package:servi_sur/features/home/presentation/pages/home_screen.dart';
import 'package:servi_sur/features/services/presentation/pages/services_list_screen.dart';
import 'package:servi_sur/features/service_detail/presentation/pages/service_detail_screen.dart';
import 'package:servi_sur/features/profile/presentation/pages/profile_screen.dart';
import 'package:servi_sur/features/provider/presentation/pages/provider_dashboard_screen.dart';
import 'package:servi_sur/features/auth/data/datasources/auth_service.dart';
import 'package:servi_sur/features/profile/data/datasources/user_profile_service.dart';

class AppRouter {
  static final _authService = AuthService();
  static final _profileService = UserProfileService();

  static final router = GoRouter(
    initialLocation: '/login',
    refreshListenable: GoRouterRefreshStream(_authService.authStateChanges),
    redirect: (context, state) async {
      final location = state.uri.path;
      final isAuthRoute =
          location == '/login' ||
          location == '/register' ||
          location == AdminRoutes.login;
      final isPrivateRoute = _isPrivateRoute(location);
      final user = _authService.currentUser;

      if (user == null) {
        return isPrivateRoute ? '/login' : null;
      }

      final profile = await _profileService.ensureUserProfile(
        uid: user.uid,
        email: user.email ?? '',
        name: user.displayName,
      );

      if (!_profileService.isActive(profile)) {
        await _authService.signOut();
        return '/login';
      }

      final role = profile['role'] as String? ?? 'client';
      final roleHome = _routeForRole(role);

      if (isAuthRoute) {
        return roleHome;
      }

      if (role == 'client' && _isProviderOrAdminRoute(location)) {
        return '/home';
      }

      if (role == 'provider' && _isAdminRoute(location)) {
        return '/provider';
      }

      if (role == 'admin' && _isClientRoute(location)) {
        return AdminRoutes.dashboard;
      }

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/services',
        builder: (context, state) => const ServicesListScreen(),
      ),
      GoRoute(
        path: '/service/:id',
        builder: (context, state) =>
            ServiceDetailScreen(serviceId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/order-summary',
        builder: (context, state) => const OrderSummaryScreen(),
      ),
      GoRoute(
        path: '/activity',
        builder: (context, state) => const OrdersHistoryScreen(),
      ),
      GoRoute(
        path: '/tracking',
        builder: (context, state) =>
            TrackingScreen(orderId: state.uri.queryParameters['orderId']),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/provider',
        builder: (context, state) => const ProviderDashboardScreen(),
      ),
      GoRoute(
        path: AdminRoutes.login,
        builder: (context, state) => const AdminLoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => AdminShell(child: child),
        routes: [
          GoRoute(
            path: AdminRoutes.dashboard,
            builder: (context, state) => const AdminDashboardScreen(),
          ),
          GoRoute(
            path: AdminRoutes.users,
            builder: (context, state) => const AdminUsersScreen(),
          ),
          GoRoute(
            path: AdminRoutes.services,
            builder: (context, state) => const AdminServicesScreen(),
          ),
          GoRoute(
            path: AdminRoutes.orders,
            builder: (context, state) => const AdminOrdersScreen(),
          ),
          GoRoute(
            path: AdminRoutes.reports,
            builder: (context, state) => const AdminReportsScreen(),
          ),
          GoRoute(
            path: AdminRoutes.settings,
            builder: (context, state) => const AdminSettingsScreen(),
          ),
        ],
      ),
    ],
  );

  static bool _isPrivateRoute(String location) {
    return _isClientRoute(location) ||
        location == '/provider' ||
        _isAdminRoute(location);
  }

  static bool _isClientRoute(String location) {
    return location == '/home' ||
        location == '/services' ||
        location.startsWith('/service/') ||
        location == '/order-summary' ||
        location == '/activity' ||
        location == '/tracking' ||
        location == '/profile';
  }

  static bool _isAdminRoute(String location) {
    return location == AdminRoutes.dashboard ||
        location.startsWith('${AdminRoutes.dashboard}/') &&
            location != AdminRoutes.login;
  }

  static bool _isProviderOrAdminRoute(String location) {
    return location == '/provider' || _isAdminRoute(location);
  }

  static String _routeForRole(String role) {
    switch (role) {
      case 'admin':
        return AdminRoutes.dashboard;
      case 'provider':
        return '/provider';
      case 'client':
      default:
        return '/home';
    }
  }
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
