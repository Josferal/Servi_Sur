import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../services/auth_service.dart';
import '../../services/user_profile_service.dart';
import '../../widgets/common/app_shell.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final profileService = UserProfileService();
    final user = authService.currentUser;

    return AppShell(
      currentIndex: 3,
      child: FutureBuilder<Map<String, dynamic>?>(
        future: user == null
            ? Future<Map<String, dynamic>?>.value(null)
            : profileService.ensureUserProfile(
                uid: user.uid,
                email: user.email ?? '',
                name: user.displayName,
              ),
        builder: (context, snapshot) {
          final profile = snapshot.data;
          final name = _profileValue(profile, 'name', fallback: 'No definido');
          final email = _profileValue(
            profile,
            'email',
            fallback: user?.email ?? 'No definido',
          );
          final role = _profileValue(profile, 'role', fallback: 'client');
          final status = _profileValue(profile, 'status', fallback: 'active');

          return Column(
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.location_on_rounded,
                    color: AppColors.orange,
                  ),
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
                    backgroundColor: AppColors.surfaceHigh,
                    child: Text(
                      _initialForName(name),
                      style: const TextStyle(
                        color: AppColors.orangeLight,
                        fontSize: 46,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
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
                role.toUpperCase(),
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: AppColors.orangeLight),
              ),
              const SizedBox(height: 8),
              Text(
                name,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 6),
              Text(
                email,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 42),
              _ProfileCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Perfil de usuario',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 18),
                    _ProfileInfoRow(
                      icon: Icons.badge_outlined,
                      label: 'Nombre',
                      value: name,
                    ),
                    _ProfileInfoRow(
                      icon: Icons.mail_outline_rounded,
                      label: 'Correo',
                      value: email,
                    ),
                    _ProfileInfoRow(
                      icon: Icons.verified_user_outlined,
                      label: 'Rol',
                      value: role,
                    ),
                    _ProfileInfoRow(
                      icon: Icons.check_circle_outline_rounded,
                      label: 'Estado',
                      value: status,
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
                      'Historial de servicios',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 18),
                    const _EmptyProfileSection(
                      icon: Icons.work_outline_rounded,
                      title: 'Historial no conectado',
                      subtitle:
                          'Los servicios reales se conectaran en la siguiente fase.',
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
                      'Metodos de pago',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 18),
                    const _EmptyProfileSection(
                      icon: Icons.credit_card_off_rounded,
                      title: 'No definido',
                      subtitle: 'Aun no hay metodo de pago conectado.',
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
                          'Configuracion',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.settings_rounded,
                          color: AppColors.orange,
                        ),
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
                      value: 'Espanol',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _ProfileCard(
                child: Column(
                  children: [
                    IconButton.filled(
                      onPressed: () async {
                        await AuthService().signOut();
                        if (context.mounted) {
                          context.go('/login');
                        }
                      },
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
                      'Cerrar sesion',
                      style: TextStyle(
                        color: AppColors.danger,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),
              if (role == 'provider')
                TextButton(
                  onPressed: () => context.push('/provider'),
                  child: const Text('Entrar al panel de proveedor'),
                ),
            ],
          );
        },
      ),
    );
  }

  static String _profileValue(
    Map<String, dynamic>? profile,
    String key, {
    required String fallback,
  }) {
    final value = profile?[key];
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
    return fallback;
  }

  static String _initialForName(String name) {
    final value = name.trim();
    if (value.isEmpty || value == 'No definido') {
      return '?';
    }
    return value.characters.first.toUpperCase();
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

class _ProfileInfoRow extends StatelessWidget {
  const _ProfileInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.background,
            child: Icon(icon, color: AppColors.orangeLight),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: AppColors.textMuted)),
                const SizedBox(height: 4),
                Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyProfileSection extends StatelessWidget {
  const _EmptyProfileSection({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.surfaceHigh,
            child: Icon(icon, color: AppColors.blue),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
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
            value ?? '>',
            style: const TextStyle(color: AppColors.orangeLight),
          ),
        ],
      ),
    );
  }
}
