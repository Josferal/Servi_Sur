import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/order_item.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/common/app_shell.dart';
import '../../widgets/common/primary_button.dart';

class OrdersHistoryScreen extends StatelessWidget {
  const OrdersHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<CartProvider>().orders;
    final active = orders.firstWhere(
      (order) => order.status == OrderStatus.active,
      orElse: () => orders.first,
    );
    final history = orders.where((order) => order.id != active.id);

    return AppShell(
      currentIndex: 2,
      child: Column(
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
            'PRÓXIMOS SERVICIOS',
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: AppColors.orangeLight),
          ),
          Text('En curso', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 22),
          Container(
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
                      backgroundImage: NetworkImage(
                        'https://images.unsplash.com/photo-1558944351-c78d3854bb5d?auto=format&fit=crop&w=300&q=80',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            active.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(
                            active.providerName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
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
                        active.date.toUpperCase(),
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
                  onPressed: () => context.push('/tracking'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 42),
          Text(
            'RECIENTES',
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: AppColors.orangeLight),
          ),
          Text('Historial', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 20),
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
                  '¿Necesitas algo más?',
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
  final OrderItem order;

  @override
  Widget build(BuildContext context) {
    final cancelled = order.status == OrderStatus.cancelled;
    return Container(
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
                  '${order.date} • ${order.providerName}',
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
    );
  }
}
