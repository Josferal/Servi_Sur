import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../repositories/marketplace_repository.dart';
import '../../widgets/common/app_shell.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = context.watch<MarketplaceRepository>();
    final profile = repository.featuredProviderProfile;
    final orders = repository.getOrders();

    return AppShell(
      currentIndex: 3,
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.location_on_rounded, color: AppColors.orange),
              const SizedBox(width: 8),
              const Text(
                'Entregar a...',
                style: TextStyle(color: AppColors.textMuted),
              ),
              const Spacer(),
              Text('Perfil', style: Theme.of(context).textTheme.titleLarge),
              const Spacer(),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.search_rounded),
              ),
            ],
          ),
          const SizedBox(height: 26),
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 70,
                backgroundImage: NetworkImage(profile.avatarUrl),
              ),
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.orange,
                child: const Icon(
                  Icons.edit_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Text(
            profile.specialty.toUpperCase(),
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: AppColors.orangeLight),
          ),
          const SizedBox(height: 8),
          Text(
            profile.name,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 6),
          Text(
            profile.email,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 42),
          _ProfileCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Historial de servicios',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 18),
                ...orders
                    .skip(1)
                    .take(2)
                    .map(
                      (order) => Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              backgroundColor: AppColors.surfaceHigh,
                              child: Icon(
                                Icons.work_outline_rounded,
                                color: AppColors.blue,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                order.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            Text(
                              CurrencyFormatter.usd(order.total),
                              style: const TextStyle(
                                color: AppColors.orangeLight,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                TextButton.icon(
                  onPressed: () => context.push('/activity'),
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: const Text('Ver todo el historial'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _ProfileCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Métodos de pago',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 18),
                Container(
                  height: 128,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2B2B2B), Color(0xFF111111)],
                    ),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '••••  ••••  ••••  4242',
                        style: TextStyle(fontSize: 18, letterSpacing: 1.4),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'ALEJANDRO SILVA',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                FilledButton(
                  onPressed: () {},
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.surfaceHigh,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: const Text('Gestionar tarjetas'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _ProfileCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Configuración',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Spacer(),
                    const Icon(Icons.settings_rounded, color: AppColors.orange),
                  ],
                ),
                const SizedBox(height: 16),
                const _SettingRow(
                  icon: Icons.notifications_none_rounded,
                  label: 'Notificaciones',
                ),
                const _SettingRow(
                  icon: Icons.lock_outline_rounded,
                  label: 'Privacidad',
                ),
                const _SettingRow(
                  icon: Icons.language_rounded,
                  label: 'Idioma',
                  value: 'Español',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _ProfileCard(
            child: Column(
              children: [
                IconButton.filled(
                  onPressed: () => context.go('/login'),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFF601C22),
                  ),
                  icon: const Icon(
                    Icons.logout_rounded,
                    color: AppColors.danger,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Cerrar sesión',
                  style: TextStyle(
                    color: AppColors.danger,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 36),
          TextButton(
            onPressed: () => context.push('/provider'),
            child: const Text('Entrar al panel de proveedor'),
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
      ),
      child: child,
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({required this.icon, required this.label, this.value});
  final IconData icon;
  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
          ),
          Text(
            value ?? '›',
            style: const TextStyle(color: AppColors.orangeLight),
          ),
        ],
      ),
    );
  }
}
