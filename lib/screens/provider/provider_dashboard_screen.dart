import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/navigation/app_navigation.dart';
import '../../core/theme/app_colors.dart';
import '../../repositories/marketplace_repository.dart';
import '../../widgets/common/app_shell.dart';
import '../../widgets/common/primary_button.dart';

class ProviderDashboardScreen extends StatelessWidget {
  const ProviderDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context
        .watch<MarketplaceRepository>()
        .featuredProviderProfile;

    return AppShell(
      currentIndex: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => AppNavigation.popOrFallback(context),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              const Spacer(),
              Text(
                'Panel proveedor',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.search_rounded),
              ),
            ],
          ),
          const SizedBox(height: 28),
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Stack(
              children: [
                Image.network(
                  profile.avatarUrl,
                  height: 330,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  left: 22,
                  bottom: 22,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.orange,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Text(
                      'Verificado',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'DISEÑO & ARQUITECTURA',
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: AppColors.orange),
          ),
          const SizedBox(height: 10),
          Text(
            'Alejandro\nRivera',
            style: Theme.of(context).textTheme.displayLarge,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _Metric(
                  value: profile.rating.toStringAsFixed(1),
                  label: '★★★★★',
                ),
              ),
              Expanded(
                child: _Metric(value: '${profile.reviews}', label: 'RESEÑAS'),
              ),
              Expanded(
                child: _Metric(value: profile.experience, label: 'EXPERIENCIA'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            profile.bio,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 18,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 28),
          PrimaryButton(
            label: 'Contratar',
            onPressed: () => context.push('/order-summary'),
          ),
          const SizedBox(height: 42),
          Text(
            'Servicios ofrecidos',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 22),
          const _ProviderService(
            icon: Icons.architecture_rounded,
            title: 'Diseño Conceptual',
            price: 'Desde \$1,200',
            text:
                'Planificación detallada, renders 3D y selección de materiales para tu próximo proyecto.',
            progress: 0.85,
            color: AppColors.orange,
          ),
          const SizedBox(height: 22),
          const _ProviderService(
            icon: Icons.format_paint_rounded,
            title: 'Remodelación Express',
            price: 'Desde \$450',
            text:
                'Actualización rápida de acabados, pintura premium y optimización de iluminación.',
            progress: 0.60,
            color: AppColors.blue,
          ),
          const SizedBox(height: 42),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PORTAFOLIO',
                      style: Theme.of(
                        context,
                      ).textTheme.labelSmall?.copyWith(color: AppColors.orange),
                    ),
                    Text(
                      'Trabajos\nrealizados',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.arrow_forward_rounded),
                label: const Text('Ver todos'),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: Image.network(
              profile.portfolioImageUrls.first,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.network(
                    profile.portfolioImageUrls.last,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Center(
                    child: Text(
                      '4',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: label.contains('★')
                ? AppColors.orange
                : AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _ProviderService extends StatelessWidget {
  const _ProviderService({
    required this.icon,
    required this.title,
    required this.price,
    required this.text,
    required this.progress,
    required this.color,
  });
  final IconData icon;
  final String title;
  final String price;
  final String text;
  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.18),
                child: Icon(icon, color: color),
              ),
              const Spacer(),
              Text(price, style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
          const SizedBox(height: 24),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            text,
            style: const TextStyle(
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 24),
          LinearProgressIndicator(
            value: progress,
            minHeight: 5,
            color: color,
            backgroundColor: AppColors.surfaceHigh,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text(
                'POPULARIDAD',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              Text(
                '${(progress * 100).round()}%',
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
