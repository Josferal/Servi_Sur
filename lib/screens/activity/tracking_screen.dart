import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/order.dart';
import '../../repositories/marketplace_repository.dart';
import '../../services/order_service.dart';
import '../../widgets/common/app_shell.dart';

class TrackingScreen extends StatelessWidget {
  const TrackingScreen({super.key, this.orderId});

  final String? orderId;

  @override
  Widget build(BuildContext context) {
    final repository = context.watch<MarketplaceRepository>();

    if (orderId != null && orderId!.isNotEmpty) {
      return StreamBuilder<Order?>(
        stream: OrderService().watchOrderById(orderId!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final order = snapshot.data;
          if (snapshot.hasError || order == null) {
            return _TrackingEmptyState(
              message: snapshot.hasError
                  ? 'No se pudo cargar la orden.'
                  : 'No encontramos esta orden.',
            );
          }

          return _TrackingContent(order: order, repository: repository);
        },
      );
    }

    return const _TrackingEmptyState(
      message:
          'Falta el identificador de la orden. Abre el seguimiento desde actividad.',
    );
  }
}

class _TrackingContent extends StatelessWidget {
  const _TrackingContent({required this.order, required this.repository});

  final Order order;
  final MarketplaceRepository repository;

  @override
  Widget build(BuildContext context) {
    final service = repository.findServiceById(order.serviceId);
    final categoryName = service?.categoryName ?? order.category;
    final description = service?.description ?? order.description;

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
                // TODO(maps): Replace this temporary visual with real tracking.
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
                    backgroundColor: AppColors.surfaceHigh,
                    child: Icon(Icons.engineering_rounded),
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
                          'Proveedor asignado',
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
                  categoryName.toUpperCase(),
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
                  description.isEmpty
                      ? 'Sin descripcion adicional.'
                      : description,
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
                'Horario\nprogramado',
                textAlign: TextAlign.right,
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                _trackingLabel(order.trackingStatus),
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const Spacer(),
              Text(
                order.scheduledTime.isEmpty ? '--:--' : order.scheduledTime,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.orangeLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 34),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _Step(
                  icon: Icons.event_available_rounded,
                  label: 'SOLICITADO',
                  done: _isAtLeast(order.trackingStatus, 0),
                ),
              ),
              Expanded(
                child: _Step(
                  icon: Icons.check_circle_rounded,
                  label: 'ASIGNADO',
                  done: _isAtLeast(order.trackingStatus, 1),
                ),
              ),
              Expanded(
                child: _Step(
                  icon: Icons.local_shipping_rounded,
                  label: 'EN CAMINO',
                  done: _isAtLeast(order.trackingStatus, 2),
                ),
              ),
              Expanded(
                child: _Step(
                  icon: Icons.settings_rounded,
                  label: 'FINALIZADO',
                  done: _isAtLeast(order.trackingStatus, 5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 34),
          Text(
            'Direccion: ${order.address.fullAddress.isEmpty ? 'No definida' : order.address.fullAddress}',
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          Text(
            'Estado: ${order.status.name}',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  String _trackingLabel(OrderTrackingStatus status) {
    return switch (status) {
      OrderTrackingStatus.requested => 'Solicitado',
      OrderTrackingStatus.assigned => 'Asignado',
      OrderTrackingStatus.onTheWay => 'En camino',
      OrderTrackingStatus.arrived => 'Llego',
      OrderTrackingStatus.working => 'En trabajo',
      OrderTrackingStatus.completed => 'Finalizado',
    };
  }

  bool _isAtLeast(OrderTrackingStatus status, int step) {
    return status.index >= step;
  }
}

class _TrackingEmptyState extends StatelessWidget {
  const _TrackingEmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return AppShell(
      currentIndex: 2,
      child: Center(
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
                Icons.near_me_disabled_rounded,
                color: AppColors.orangeLight,
                size: 40,
              ),
              const SizedBox(height: 14),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 18),
              FilledButton(
                onPressed: () => context.go('/activity'),
                child: const Text('Volver a actividad'),
              ),
            ],
          ),
        ),
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
