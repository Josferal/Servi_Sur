import 'package:go_router/go_router.dart';

import '../screens/activity/orders_history_screen.dart';
import '../screens/activity/tracking_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/cart/order_summary_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/home/services_list_screen.dart';
import '../screens/product/service_detail_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/provider/provider_dashboard_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/login',
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
        builder: (context, state) => const TrackingScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/provider',
        builder: (context, state) => const ProviderDashboardScreen(),
      ),
    ],
  );
}
