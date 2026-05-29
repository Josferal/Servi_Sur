import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:servi_sur/app/router/app_navigation.dart';
import 'package:servi_sur/app/theme/app_colors.dart';
import 'package:servi_sur/features/auth/data/datasources/auth_service.dart';
import 'package:servi_sur/features/profile/data/datasources/user_profile_service.dart';
import 'package:servi_sur/shared/presentation/widgets/common/dark_input.dart';
import 'package:servi_sur/shared/presentation/widgets/common/primary_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  final _profileService = UserProfileService();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _acceptedTerms = false;
  bool _loading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    if (!_acceptedTerms) {
      setState(
        () => _errorMessage =
            'Debes aceptar los terminos y la politica de privacidad.',
      );
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final credential = await _authService.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      final user = credential.user;
      if (user == null) {
        throw const AuthServiceException('No se pudo crear la cuenta.');
      }

      await user.updateDisplayName(_nameController.text.trim());
      await _profileService.createUserProfile(
        uid: user.uid,
        name: _nameController.text,
        email: user.email ?? _emailController.text,
      );

      if (mounted) {
        context.go('/home');
      }
    } on AuthServiceException catch (error) {
      if (mounted) {
        setState(() => _errorMessage = error.message);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _errorMessage = 'No se pudo completar el registro.');
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  String? _validateName(String? value) {
    if ((value?.trim() ?? '').length < 3) {
      return 'Ingresa tu nombre completo.';
    }
    return null;
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
    final password = value ?? '';
    if (password.isEmpty) {
      return 'Ingresa una contrasena.';
    }
    if (password.length < 6) {
      return 'Debe tener al menos 6 caracteres.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 30, 28, 24),
          child: Form(
            key: _formKey,
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
                      'Ya eres parte de la comunidad? ',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                    GestureDetector(
                      onTap: _loading
                          ? null
                          : () => AppNavigation.popOrFallback(
                              context,
                              fallbackRoute: '/login',
                            ),
                      child: const Text(
                        'Inicia sesion',
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
                DarkInput(
                  label: 'Nombre completo',
                  hint: 'Ej. Carlos Mendoza',
                  icon: Icons.person_outline_rounded,
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  validator: _validateName,
                ),
                const SizedBox(height: 22),
                DarkInput(
                  label: 'Correo',
                  hint: 'Correo electronico',
                  icon: Icons.alternate_email_rounded,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: _validateEmail,
                ),
                const SizedBox(height: 22),
                DarkInput(
                  label: 'Contrasena',
                  hint: '********',
                  icon: Icons.lock_outline_rounded,
                  isPassword: true,
                  controller: _passwordController,
                  textInputAction: TextInputAction.done,
                  validator: _validatePassword,
                ),
                const SizedBox(height: 28),
                InkWell(
                  onTap: _loading
                      ? null
                      : () => setState(() => _acceptedTerms = !_acceptedTerms),
                  borderRadius: BorderRadius.circular(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: _acceptedTerms
                              ? AppColors.orange
                              : AppColors.surfaceSoft,
                          shape: BoxShape.circle,
                        ),
                        child: _acceptedTerms
                            ? const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 14,
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Acepto los Terminos de Servicio y la Politica de Privacidad.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: AppColors.danger,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                _loading
                    ? const Center(child: CircularProgressIndicator())
                    : PrimaryButton(
                        label: 'Registrarse',
                        icon: Icons.arrow_forward_rounded,
                        onPressed: _submit,
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
