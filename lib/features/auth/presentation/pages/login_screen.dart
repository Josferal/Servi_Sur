import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:servi_sur/app/theme/app_colors.dart';
import 'package:servi_sur/features/auth/data/datasources/auth_service.dart';
import 'package:servi_sur/features/profile/data/datasources/user_profile_service.dart';
import 'package:servi_sur/shared/presentation/widgets/common/dark_input.dart';
import 'package:servi_sur/shared/presentation/widgets/common/primary_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  final _profileService = UserProfileService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final credential = await _authService.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      final user = credential.user;
      if (user == null) {
        throw const AuthServiceException('No se pudo iniciar la sesion.');
      }

      final profile = await _profileService.ensureUserProfile(
        uid: user.uid,
        email: user.email ?? _emailController.text,
        name: user.displayName,
      );

      if (!_profileService.isActive(profile)) {
        await _authService.signOut();
        throw const AuthServiceException(
          'Tu cuenta esta inactiva o bloqueada. Contacta al soporte.',
        );
      }

      await _profileService.touchLastLogin(user.uid);

      if (!mounted) {
        return;
      }
      context.go(_routeForRole(profile['role'] as String?));
    } on AuthServiceException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _errorMessage = error.message);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(
        () => _errorMessage = 'No se pudo iniciar sesion. Intenta de nuevo.',
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(
        () => _errorMessage =
            'Escribe tu correo para enviarte el enlace de recuperacion.',
      );
      return;
    }

    try {
      await _authService.sendPasswordResetEmail(email: email);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Revisa tu correo para recuperar acceso.'),
        ),
      );
    } on AuthServiceException catch (error) {
      if (mounted) {
        setState(() => _errorMessage = error.message);
      }
    }
  }

  String _routeForRole(String? role) {
    switch (role) {
      case 'admin':
        return '/admin';
      case 'provider':
        return '/provider';
      case 'client':
      default:
        return '/home';
    }
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return 'Ingresa tu correo.';
    }
    if (!email.contains('@')) {
      return 'Ingresa un correo valido.';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if ((value ?? '').isEmpty) {
      return 'Ingresa tu contrasena.';
    }
    return null;
  }

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
              child: Form(
                key: _formKey,
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
                          DarkInput(
                            label: 'CORREO',
                            hint: 'Correo electronico',
                            icon: Icons.person_outline_rounded,
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            validator: _validateEmail,
                          ),
                          const SizedBox(height: 24),
                          DarkInput(
                            label: 'CONTRASENA',
                            hint: '********',
                            icon: Icons.lock_outline_rounded,
                            isPassword: true,
                            controller: _passwordController,
                            textInputAction: TextInputAction.done,
                            validator: _validatePassword,
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _loading ? null : _resetPassword,
                              child: const Text(
                                'Olvidaste tu contrasena?',
                                style: TextStyle(
                                  color: AppColors.orange,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                          if (_errorMessage != null) ...[
                            Text(
                              _errorMessage!,
                              style: const TextStyle(
                                color: AppColors.danger,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                          const SizedBox(height: 10),
                          _loading
                              ? const Center(child: CircularProgressIndicator())
                              : PrimaryButton(
                                  label: 'Iniciar Sesion',
                                  onPressed: _submit,
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
                              onPressed: _loading
                                  ? null
                                  : () => context.push('/register'),
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
                          'Terminos',
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
          ),
        ],
      ),
    );
  }
}
