import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../repositories/firebase_marketplace_repository.dart';
import '../../repositories/marketplace_repository.dart';
import '../../widgets/common/app_shell.dart';
import '../../widgets/product/service_card.dart';

class ServicesListScreen extends StatelessWidget {
  const ServicesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = context.watch<MarketplaceRepository>();
    final firebaseRepository = repository is FirebaseMarketplaceRepository
        ? repository
        : null;
    final services = repository.getServices();

    return AppShell(
      currentIndex: 1,
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
                icon: const Icon(Icons.search_rounded),
              ),
            ],
          ),
          const SizedBox(height: 34),
          Text(
            'SERVICIOS PREMIUM',
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: AppColors.orange),
          ),
          const SizedBox(height: 8),
          Text(
            'Limpieza del Hogar',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 10),
          const Text(
            'Profesionales verificados listos para transformar tu espacio con equipos de alta gama.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
          ),
          if (firebaseRepository != null) ...[
            const SizedBox(height: 18),
            _MarketplaceStatus(repository: firebaseRepository),
          ],
          const SizedBox(height: 30),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['Todo', 'Mejor valorados', 'Express', 'Ofertas'].map((
                label,
              ) {
                final selected = label == 'Todo';
                return Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.orange : AppColors.surfaceSoft,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Text(
                    label,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 34),
          if (services.isEmpty)
            const _EmptyServicesMessage()
          else
            ...services.map(
              (service) => Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: ServiceCard(
                  service: service,
                  compact: true,
                  onTap: () => context.push('/service/${service.id}'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MarketplaceStatus extends StatelessWidget {
  const _MarketplaceStatus({required this.repository});

  final FirebaseMarketplaceRepository repository;

  @override
  Widget build(BuildContext context) {
    if (repository.isLoading) {
      return const LinearProgressIndicator(minHeight: 4);
    }

    final message = repository.errorMessage;
    if (message != null) {
      return _StatusMessage(
        icon: Icons.cloud_off_rounded,
        text: '$message Mostrando datos temporales.',
      );
    }

    if (repository.usingFallback) {
      return const _StatusMessage(
        icon: Icons.info_outline_rounded,
        text: 'Firestore no tiene datos aun. Mostrando datos temporales.',
      );
    }

    return const SizedBox.shrink();
  }
}

class _StatusMessage extends StatelessWidget {
  const _StatusMessage({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.orangeLight, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyServicesMessage extends StatelessWidget {
  const _EmptyServicesMessage();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
      ),
      child: const Text(
        'No hay servicios disponibles por el momento.',
        textAlign: TextAlign.center,
        style: TextStyle(color: AppColors.textSecondary),
      ),
    );
  }
}
