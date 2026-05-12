import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../widgets/common/dark_input.dart';
import '../../widgets/common/primary_button.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(-1.1, -0.1),
                radius: 1.2,
                colors: [Color(0x664A1E08), AppColors.background],
              ),
            ),
            child: SizedBox.expand(),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    height: 64,
                    width: 64,
                    decoration: BoxDecoration(
                      gradient: AppColors.orangeGradient,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: const [
                        BoxShadow(color: Color(0x55FF7417), blurRadius: 28),
                      ],
                    ),
                    child: const Icon(
                      Icons.flash_on_rounded,
                      color: Colors.white,
                      size: 34,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'BIENVENIDO',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Accede a los mejores servicios locales',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: AppColors.surface.withValues(alpha: 0.94),
                      borderRadius: BorderRadius.circular(34),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const DarkInput(
                          label: 'CORREO O TELÉFONO',
                          hint: 'nombre@ejemplo.com',
                          icon: Icons.person_outline_rounded,
                        ),
                        const SizedBox(height: 24),
                        const DarkInput(
                          label: 'CONTRASEÑA',
                          hint: '********',
                          icon: Icons.lock_outline_rounded,
                          isPassword: true,
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            child: const Text(
                              '¿Olvidaste tu contraseña?',
                              style: TextStyle(
                                color: AppColors.orange,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        PrimaryButton(
                          label: 'Iniciar Sesión',
                          onPressed: () => context.go('/home'),
                        ),
                        const SizedBox(height: 36),
                        const Center(
                          child: Text(
                            'No tienes una cuenta?',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: FilledButton(
                            onPressed: () => context.push('/register'),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.surfaceHigh,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                            child: const Text(
                              'Crear cuenta',
                              style: TextStyle(fontWeight: FontWeight.w900),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 46),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Términos',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(width: 28),
                      Text(
                        'Privacidad',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(width: 28),
                      Text(
                        'Soporte',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
