import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/admin_colors.dart';
import '../core/admin_theme.dart';
import '../services/admin_session_service.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _session = AdminSessionService();
  final _emailController = TextEditingController(text: 'admin@servimarket.com');
  final _passwordController = TextEditingController(text: 'admin123');
  bool _remember = true;
  bool _loading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _redirectIfSignedIn();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _redirectIfSignedIn() async {
    final signedIn = await _session.isSignedIn();
    if (signedIn && mounted) {
      context.go('/admin');
    }
  }

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    final signedIn = await _session.signIn(
      email: _emailController.text,
      password: _passwordController.text,
      remember: _remember,
    );
    if (!mounted) {
      return;
    }

    if (signedIn) {
      context.go('/admin');
      return;
    }

    setState(() {
      _loading = false;
      _errorMessage = 'Credenciales administrativas invalidas.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AdminTheme.light,
      child: Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) {
            final showVisual = constraints.maxWidth >= 920;
            return Row(
              children: [
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: Padding(
                        padding: const EdgeInsets.all(28),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: AdminColors.primary,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.storefront_rounded,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'ServiMarket',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ],
                            ),
                            const SizedBox(height: 38),
                            Text(
                              'Bienvenido de nuevo',
                              style: Theme.of(context).textTheme.headlineLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Ingrese sus credenciales para acceder al panel.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 26),
                            TextField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                prefixIcon: Icon(Icons.mail_outline_rounded),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                labelText: 'Contrasena',
                                prefixIcon: Icon(Icons.lock_outline_rounded),
                              ),
                            ),
                            const SizedBox(height: 8),
                            CheckboxListTile(
                              contentPadding: EdgeInsets.zero,
                              value: _remember,
                              onChanged: (value) =>
                                  setState(() => _remember = value ?? true),
                              title: const Text('Recordar mi sesion'),
                              controlAffinity: ListTileControlAffinity.leading,
                            ),
                            if (_errorMessage != null) ...[
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AdminColors.dangerSoft,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AdminColors.danger.withValues(
                                      alpha: 0.24,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(
                                    color: AdminColors.danger,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                            const SizedBox(height: 14),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                onPressed: _loading ? null : _submit,
                                icon: _loading
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.2,
                                        ),
                                      )
                                    : const Icon(Icons.login_rounded),
                                label: Text(
                                  _loading
                                      ? 'Validando...'
                                      : 'Ingresar al panel',
                                ),
                                style: FilledButton.styleFrom(
                                  backgroundColor: AdminColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                if (showVisual)
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE1F7EC), Color(0xFFFFFFFF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.analytics_rounded,
                          color: AdminColors.primary,
                          size: 150,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
