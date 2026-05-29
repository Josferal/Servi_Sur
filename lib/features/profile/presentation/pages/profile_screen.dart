import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:servi_sur/app/theme/app_colors.dart';
import 'package:servi_sur/features/auth/data/datasources/auth_service.dart';
import 'package:servi_sur/features/profile/data/datasources/user_profile_service.dart';
import 'package:servi_sur/services/account_service.dart';
import 'package:servi_sur/shared/presentation/widgets/common/app_shell.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = AuthService();
  final _profileService = UserProfileService();
  final _accountService = AccountService();
  Future<Map<String, dynamic>?>? _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _loadProfile();
  }

  Future<Map<String, dynamic>?> _loadProfile() {
    final user = _authService.currentUser;
    return user == null
        ? Future<Map<String, dynamic>?>.value(null)
        : _profileService.ensureUserProfile(
            uid: user.uid,
            email: user.email ?? '',
            name: user.displayName,
          );
  }

  void _refreshProfile() {
    setState(() => _profileFuture = _loadProfile());
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    return AppShell(
      currentIndex: 3,
      child: FutureBuilder<Map<String, dynamic>?>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _ProfileCard(
              child: Text(
                'No se pudo cargar el perfil. Intenta de nuevo.',
                style: TextStyle(color: AppColors.danger),
              ),
            );
          }

          final profile = snapshot.data;
          final name = _profileValue(profile, 'name', fallback: 'No definido');
          final email = _profileValue(
            profile,
            'email',
            fallback: user?.email ?? 'No definido',
          );
          final phone = _profileValue(
            profile,
            'phone',
            fallback: 'No definido',
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
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      iconSize: 18,
                      onPressed: user == null
                          ? null
                          : () => _editProfile(
                              context,
                              uid: user.uid,
                              name: name == 'No definido' ? '' : name,
                              phone: phone == 'No definido' ? '' : phone,
                            ),
                      icon: const Icon(
                        Icons.edit_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
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
                      icon: Icons.phone_outlined,
                      label: 'Telefono',
                      value: phone,
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
                    const SizedBox(height: 8),
                    FilledButton.icon(
                      onPressed: user == null
                          ? null
                          : () => _editProfile(
                              context,
                              uid: user.uid,
                              name: name == 'No definido' ? '' : name,
                              phone: phone == 'No definido' ? '' : phone,
                            ),
                      icon: const Icon(Icons.edit_rounded),
                      label: const Text('Editar perfil'),
                    ),
                    const SizedBox(height: 10),
                    TextButton.icon(
                      onPressed: user == null
                          ? null
                          : () => _changePassword(context),
                      icon: const Icon(Icons.password_rounded),
                      label: const Text('Cambiar contrasena'),
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
                        await _authService.signOut();
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

  Future<void> _editProfile(
    BuildContext context, {
    required String uid,
    required String name,
    required String phone,
  }) async {
    final nameController = TextEditingController(text: name);
    final phoneController = TextEditingController(text: phone);

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            24,
            24,
            MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Editar perfil',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 18),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Telefono'),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Guardar cambios'),
                ),
              ),
            ],
          ),
        );
      },
    );

    final nextName = nameController.text;
    final nextPhone = phoneController.text;
    nameController.dispose();
    phoneController.dispose();

    if (saved != true || !context.mounted) {
      return;
    }

    try {
      await _accountService.updateOwnProfile(
        uid: uid,
        name: nextName,
        phone: nextPhone,
      );
      if (!context.mounted) {
        return;
      }
      _refreshProfile();
      _showSnack(context, 'Perfil actualizado correctamente.');
    } on AccountServiceException catch (error) {
      if (context.mounted) {
        _showSnack(context, error.message, error: true);
      }
    }
  }

  Future<void> _changePassword(BuildContext context) async {
    final passwordController = TextEditingController();

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cambiar contrasena'),
          content: TextField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Nueva contrasena',
              helperText: 'Minimo 6 caracteres.',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Actualizar'),
            ),
          ],
        );
      },
    );

    final newPassword = passwordController.text;
    passwordController.dispose();

    if (saved != true || !context.mounted) {
      return;
    }

    try {
      await _accountService.updateCurrentPassword(newPassword);
      if (context.mounted) {
        _showSnack(context, 'Contrasena actualizada correctamente.');
      }
    } on AccountServiceException catch (error) {
      if (context.mounted) {
        _showSnack(context, error.message, error: true);
      }
    }
  }

  void _showSnack(BuildContext context, String message, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? AppColors.danger : null,
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
