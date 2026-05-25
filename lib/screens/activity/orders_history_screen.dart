import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/order.dart';
import '../../providers/cart_provider.dart';
import '../../services/auth_service.dart';
import '../../services/order_service.dart';
import '../../services/user_profile_service.dart';
import '../../widgets/common/app_shell.dart';
import '../../widgets/common/primary_button.dart';

class OrdersHistoryScreen extends StatelessWidget {
  const OrdersHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;

    if (user == null) {
      return _ActivityScaffold(
        child: _EmptyState(
          title: 'Inicia sesion',
          message: 'Necesitas iniciar sesion para ver tu actividad.',
          actionLabel: 'Ir al login',
          onAction: () => context.go('/login'),
        ),
      );
    }

    return FutureBuilder<Map<String, dynamic>>(
      future: UserProfileService().ensureUserProfile(
        uid: user.uid,
        email: user.email ?? '',
        name: user.displayName,
      ),
      builder: (context, profileSnapshot) {
        if (profileSnapshot.connectionState == ConnectionState.waiting) {
          return const _ActivityScaffold(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final role = profileSnapshot.data?['role'] as String? ?? 'client';
        if (role == 'admin') {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              context.go('/admin');
            }
          });
          return const _ActivityScaffold(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final stream = role == 'provider'
            ? OrderService().watchOrdersByProvider(user.uid)
            : OrderService().watchOrdersByClient(user.uid);

        return StreamBuilder<List<Order>>(
          stream: stream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const _ActivityScaffold(
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.hasError) {
              final fallbackOrders = context.watch<CartProvider>().orders;
              return _ActivityScaffold(
                child: _OrdersContent(
                  orders: fallbackOrders,
                  banner:
                      'No se pudo cargar Firestore. Mostrando datos temporales.',
                ),
              );
            }

            final orders = snapshot.data ?? const <Order>[];
            if (orders.isEmpty) {
              return _ActivityScaffold(
                child: _EmptyState(
                  title: 'Sin ordenes todavia',
                  message:
                      'Cuando confirmes una solicitud, aparecera en esta seccion.',
                  actionLabel: 'Explorar servicios',
                  onAction: () => context.go('/services'),
                ),
              );
            }

            return _ActivityScaffold(child: _OrdersContent(orders: orders));
          },
        );
      },
    );
  }
}

class _ActivityScaffold extends StatelessWidget {
  const _ActivityScaffold({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AppShell(currentIndex: 2, child: child);
  }
}

class _OrdersContent extends StatelessWidget {
  const _OrdersContent({required this.orders, this.banner});

  final List<Order> orders;
  final String? banner;

  @override
  Widget build(BuildContext context) {
    final activeOrders = orders
        .where(
          (order) =>
              order.status != OrderStatus.completed &&
              order.status != OrderStatus.cancelled,
        )
        .toList();
    final active = activeOrders.isEmpty ? orders.first : activeOrders.first;
    final history = orders.where((order) => order.id != active.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.receipt_long_rounded, color: AppColors.orange),
            const SizedBox(width: 10),
            Text('Actividad', style: Theme.of(context).textTheme.titleLarge),
            const Spacer(),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.search_rounded),
            ),
          ],
        ),
        if (banner != null) ...[
          const SizedBox(height: 18),
          _Banner(message: banner!),
        ],
        const SizedBox(height: 28),
        Container(
          height: 54,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Row(
            children: [
              Expanded(child: _Segment(label: 'Activos', selected: true)),
              Expanded(child: _Segment(label: 'Historial', selected: false)),
            ],
          ),
        ),
        const SizedBox(height: 36),
        Text(
          'PROXIMOS SERVICIOS',
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: AppColors.orangeLight),
        ),
        Text('En curso', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 22),
        _ActiveOrderCard(order: active),
        const SizedBox(height: 42),
        Text(
          'RECIENTES',
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: AppColors.orangeLight),
        ),
        Text('Historial', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 20),
        if (history.isEmpty)
          const Text(
            'Aun no hay ordenes anteriores.',
            style: TextStyle(color: AppColors.textSecondary),
          )
        else
          ...history.map(
            (order) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _OrderTile(order: order),
            ),
          ),
        const SizedBox(height: 30),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: AppColors.surfaceSoft,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            children: [
              Text(
                'Necesitas algo mas?',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              const Text(
                'Vuelve a contratar tus servicios favoritos con un solo toque.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => context.go('/services'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                ),
                child: const Text('Explorar Servicios'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActiveOrderCard extends StatelessWidget {
  const _ActiveOrderCard({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.surfaceHigh,
                child: Icon(Icons.home_repair_service_rounded),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      order.providerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF603517),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Text(
                  order.date.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.orangeLight,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          PrimaryButton(
            label: 'Seguir en mapa',
            icon: Icons.near_me_rounded,
            onPressed: () => context.push('/tracking?orderId=${order.id}'),
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({required this.label, required this.selected});
  final String label;
  final bool selected;
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: selected ? AppColors.orangeGradient : null,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w900)),
    );
  }
}

class _OrderTile extends StatelessWidget {
  const _OrderTile({required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    final cancelled = order.status == OrderStatus.cancelled;
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () => context.push('/tracking?orderId=${order.id}'),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.surfaceHigh,
              child: Icon(
                cancelled ? Icons.close_rounded : Icons.check_rounded,
                color: cancelled ? AppColors.danger : AppColors.orangeLight,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  Text(
                    '${order.date} - ${order.providerName}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              CurrencyFormatter.usd(order.total),
              style: TextStyle(
                color: cancelled ? AppColors.textMuted : AppColors.textPrimary,
                decoration: cancelled ? TextDecoration.lineThrough : null,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        message,
        style: const TextStyle(color: AppColors.textSecondary),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.receipt_long_rounded,
              color: AppColors.orangeLight,
              size: 38,
            ),
            const SizedBox(height: 14),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 18),
            FilledButton(onPressed: onAction, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}
