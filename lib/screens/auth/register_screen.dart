import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/navigation/app_navigation.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/common/dark_input.dart';
import '../../widgets/common/primary_button.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 30, 28, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: AppColors.orangeGradient,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Icon(
                      Icons.grid_view_rounded,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'SERVI SUR',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
              const SizedBox(height: 56),
              Text(
                'Crear cuenta',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 8),
              Wrap(
                children: [
                  const Text(
                    '¿Ya eres parte de la comunidad? ',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => AppNavigation.popOrFallback(
                      context,
                      fallbackRoute: '/login',
                    ),
                    child: const Text(
                      'Inicia sesión',
                      style: TextStyle(
                        color: AppColors.orangeLight,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 44),
              const DarkInput(
                label: 'Nombre completo',
                hint: 'Ej. Carlos Mendoza',
                icon: Icons.person_outline_rounded,
              ),
              const SizedBox(height: 22),
              const DarkInput(
                label: 'Correo o teléfono',
                hint: 'nombre@ejemplo.com',
                icon: Icons.alternate_email_rounded,
              ),
              const SizedBox(height: 22),
              const DarkInput(
                label: 'Contraseña',
                hint: '********',
                icon: Icons.lock_outline_rounded,
                isPassword: true,
              ),
              const SizedBox(height: 28),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceSoft,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Acepto los Términos de Servicio y la Política de Privacidad.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                label: 'Registrarse',
                icon: Icons.arrow_forward_rounded,
                onPressed: () => context.go('/home'),
              ),
              const SizedBox(height: 36),
              Row(
                children: [
                  Expanded(child: Divider(color: AppColors.divider)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Text(
                      'O CONTINUAR CON',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: AppColors.divider)),
                ],
              ),
              const SizedBox(height: 26),
              Row(
                children: [
                  Expanded(
                    child: _SocialButton(
                      label: 'Google',
                      icon: Icons.g_mobiledata_rounded,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _SocialButton(
                      label: 'Facebook',
                      icon: Icons.facebook_rounded,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.orangeLight),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
