import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../repositories/marketplace_repository.dart';
import '../../widgets/common/app_shell.dart';
import '../../widgets/product/service_card.dart';

class ServicesListScreen extends StatelessWidget {
  const ServicesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final services = context.watch<MarketplaceRepository>().getServices();

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
