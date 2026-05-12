import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/order.dart';
import '../../providers/cart_provider.dart';
import '../../repositories/marketplace_repository.dart';
import '../../widgets/common/app_shell.dart';

class TrackingScreen extends StatelessWidget {
  const TrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final repository = context.watch<MarketplaceRepository>();
    final order = cart.activeOrder ?? repository.getOrders().first;
    final service =
        cart.selectedService ??
        repository.getServices().firstWhere(
          (item) => item.id == order.serviceId,
          orElse: () => repository.getServices().first,
        );

    return AppShell(
      currentIndex: 2,
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 104),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on_rounded, color: AppColors.orange),
              const SizedBox(width: 8),
              Text(
                'Entregar a...',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.search_rounded, color: AppColors.orange),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Container(
            height: 210,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Stack(
              children: [
                Positioned.fill(child: CustomPaint(painter: _MapPainter())),
                const Center(
                  child: Icon(
                    Icons.location_on_rounded,
                    size: 58,
                    color: AppColors.surfaceHigh,
                  ),
                ),
              ],
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -34),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surfaceSoft,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 32,
                    backgroundImage: NetworkImage(
                      'https://images.unsplash.com/photo-1560250097-0b93528c311a?auto=format&fit=crop&w=300&q=80',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.providerName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const Text(
                          'Proveedor Premium',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  IconButton.filled(
                    onPressed: () {},
                    icon: const Icon(Icons.call_rounded),
                  ),
                ],
              ),
            ),
          ),
          _StatusCard(order: order),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.categoryName.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.blue,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  order.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  service.description,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const Divider(height: 34, color: AppColors.divider),
                Row(
                  children: [
                    const Text(
                      'Total estimado',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    const Spacer(),
                    Text(
                      CurrencyFormatter.usd(order.total),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => context.go('/activity'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.surfaceHigh,
              foregroundColor: AppColors.orangeLight,
              minimumSize: const Size.fromHeight(54),
            ),
            child: const Text('Ver actividad'),
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.order});

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'ESTADO DEL\nSERVICIO',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.orangeLight,
                  ),
                ),
              ),
              const Text(
                'Llegada\nestimada',
                textAlign: TextAlign.right,
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                'En camino',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const Spacer(),
              Text(
                '14:45',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.orangeLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 34),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _Step(
                  icon: Icons.event_available_rounded,
                  label: 'PENDIENTE',
                  done: true,
                ),
              ),
              Expanded(
                child: _Step(
                  icon: Icons.check_circle_rounded,
                  label: 'ACEPTADO',
                  done: true,
                ),
              ),
              Expanded(
                child: _Step(
                  icon: Icons.local_shipping_rounded,
                  label: 'EN CAMINO',
                  done: true,
                ),
              ),
              Expanded(
                child: _Step(
                  icon: Icons.settings_rounded,
                  label: 'FINALIZADO',
                  done: false,
                ),
              ),
            ],
          ),
          const SizedBox(height: 34),
          Text(
            'El proveedor está a 2 km de ${order.address.label.toLowerCase()}',
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          Text(
            'Hace 2 minutos • ${order.address.city}',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.icon, required this.label, required this.done});
  final IconData icon;
  final String label;
  final bool done;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: done ? AppColors.orangeLight : AppColors.surfaceHigh,
          child: Icon(
            icon,
            color: done ? AppColors.background : AppColors.textMuted,
            size: 19,
          ),
        ),
        const SizedBox(height: 8),
        FittedBox(
          child: Text(
            label,
            style: TextStyle(
              color: done ? AppColors.orangeLight : AppColors.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.surfaceHigh.withValues(alpha: 0.45)
      ..strokeWidth = 1;
    for (var i = 0; i < 8; i++) {
      final y = size.height * (i / 8);
      canvas.drawLine(Offset(0, y), Offset(size.width, y + 40), paint);
      final x = size.width * (i / 8);
      canvas.drawLine(Offset(x, 0), Offset(x - 40, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
