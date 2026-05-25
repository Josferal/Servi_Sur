import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/navigation/app_navigation.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../providers/cart_provider.dart';
import '../../repositories/marketplace_repository.dart';
import '../../services/auth_service.dart';
import '../../services/order_service.dart';
import '../../services/user_profile_service.dart';
import '../../widgets/cart/summary_row.dart';
import '../../widgets/common/dark_input.dart';
import '../../widgets/common/primary_button.dart';

class OrderSummaryScreen extends StatefulWidget {
  const OrderSummaryScreen({super.key});

  @override
  State<OrderSummaryScreen> createState() => _OrderSummaryScreenState();
}

class _OrderSummaryScreenState extends State<OrderSummaryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController(text: 'Mañana (08:00 - 12:00)');
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isEmergency = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final repository = context.read<MarketplaceRepository>();
    _addressController.text = repository.defaultAddress.fullAddress;
  }

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final repository = context.watch<MarketplaceRepository>();
    final service = cart.selectedService ?? repository.getServices().first;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => AppNavigation.popOrFallback(context),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Nueva Solicitud'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.help_outline_rounded,
              color: AppColors.orange,
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 178,
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(service.imageUrl),
                    fit: BoxFit.cover,
                    colorFilter: const ColorFilter.mode(
                      Colors.black45,
                      BlendMode.darken,
                    ),
                  ),
                  borderRadius: BorderRadius.circular(28),
                ),
                alignment: Alignment.bottomLeft,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.blue,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Text(
                        'SERVICIOS PREMIUM',
                        style: TextStyle(
                          color: Color(0xFF04243A),
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      service.title,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const _FormSection(
                icon: Icons.calendar_month_rounded,
                title: 'Fecha y Hora',
              ),
              const SizedBox(height: 14),
              DarkInput(
                label: 'DÍA DE PREFERENCIA',
                hint: 'mm/dd/yyyy',
                controller: _dateController,
                keyboardType: TextInputType.datetime,
                textInputAction: TextInputAction.next,
                validator: _validateDate,
                trailing: const Icon(
                  Icons.calendar_today_outlined,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 18),
              DarkInput(
                label: 'FRANJA HORARIA',
                hint: 'Mañana (08:00 - 12:00)',
                controller: _timeController,
                textInputAction: TextInputAction.next,
                validator: _requiredField,
                trailing: const Icon(
                  Icons.schedule_rounded,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 30),
              const _FormSection(
                icon: Icons.location_on_rounded,
                title: 'Ubicación del Servicio',
              ),
              const SizedBox(height: 14),
              DarkInput(
                label: 'DIRECCIÓN COMPLETA',
                hint: 'Calle, número, piso o local...',
                controller: _addressController,
                textInputAction: TextInputAction.next,
                validator: _requiredField,
                trailing: const Icon(
                  Icons.my_location_rounded,
                  color: AppColors.orangeLight,
                ),
              ),
              const SizedBox(height: 30),
              const _FormSection(
                icon: Icons.notes_rounded,
                title: 'Detalles del Problema',
              ),
              const SizedBox(height: 14),
              DarkInput(
                label: 'DESCRIPCIÓN DEL PROBLEMA',
                hint: 'Cuéntanos más sobre lo que necesitas solucionar...',
                controller: _descriptionController,
                maxLines: 4,
                validator: _requiredField,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Expanded(
                    child: _MiniOption(
                      icon: Icons.camera_alt_outlined,
                      label: 'Adjuntar Fotos\n(Opcional)',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _EmergencyOption(
                      value: _isEmergency,
                      onChanged: (value) {
                        setState(() {
                          _isEmergency = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    SummaryRow(
                      label: service.title,
                      value: CurrencyFormatter.usd(service.price),
                    ),
                    const SummaryRow(
                      label: 'Tarifa de plataforma',
                      value: '\$3',
                    ),
                    const Divider(color: AppColors.divider),
                    SummaryRow(
                      label: 'Total estimado',
                      value: CurrencyFormatter.usd(service.price + 3),
                      highlight: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
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
              _isSubmitting
                  ? const Center(child: CircularProgressIndicator())
                  : PrimaryButton(
                      label: 'Confirmar solicitud',
                      icon: Icons.arrow_forward_rounded,
                      onPressed: _confirmRequest,
                    ),
              const SizedBox(height: 14),
              const Center(
                child: Text(
                  'AL CONFIRMAR, UN PROFESIONAL REVISARÁ TU CASO EN MENOS DE 15 MIN.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _requiredField(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo requerido';
    }
    return null;
  }

  String? _validateDate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo requerido';
    }
    if (_parseDate(value) == null) {
      return 'Usa el formato mm/dd/yyyy';
    }
    return null;
  }

  DateTime? _parseDate(String value) {
    final parts = value.trim().split('/');
    if (parts.length != 3) {
      return null;
    }
    final month = int.tryParse(parts[0]);
    final day = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (month == null || day == null || year == null) {
      return null;
    }
    if (month < 1 || month > 12 || day < 1 || day > 31 || year < 2024) {
      return null;
    }
    return DateTime(year, month, day, 8);
  }

  Future<void> _confirmRequest() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final cart = context.read<CartProvider>();
    final repository = context.read<MarketplaceRepository>();
    final services = repository.getServices();
    final service =
        cart.selectedService ?? (services.isEmpty ? null : services.first);
    final user = AuthService().currentUser;

    if (user == null) {
      context.go('/login');
      return;
    }
    if (service == null) {
      setState(() => _errorMessage = 'Selecciona un servicio para continuar.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final profile = await UserProfileService().ensureUserProfile(
        uid: user.uid,
        email: user.email ?? '',
        name: user.displayName,
      );
      final clientName = (profile['name'] as String?)?.trim().isNotEmpty == true
          ? profile['name'] as String
          : user.displayName ?? 'No definido';
      final clientEmail = user.email ?? profile['email'] as String? ?? '';
      final orderService = OrderService();
      final request = await orderService.createServiceRequest(
        service: service,
        clientId: user.uid,
        clientName: clientName,
        clientEmail: clientEmail,
        description: _descriptionController.text,
        addressText: _addressController.text,
        scheduledDate: _parseDate(_dateController.text)!,
        scheduledTime: _timeController.text,
        estimatedPrice: service.price + 3,
        isEmergency: _isEmergency,
      );
      final order = await orderService.createOrderFromRequest(request);

      if (!mounted) {
        return;
      }
      cart.setConfirmedOrder(service: service, request: request, order: order);
      context.go('/tracking?orderId=${order.id}');
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(
        () =>
            _errorMessage = 'No se pudo crear la solicitud. Intenta de nuevo.',
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}

class _FormSection extends StatelessWidget {
  const _FormSection({required this.icon, required this.title});
  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 17,
          backgroundColor: AppColors.orangeDark.withValues(alpha: 0.36),
          child: Icon(icon, color: AppColors.orange, size: 19),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
      ],
    );
  }
}

class _MiniOption extends StatelessWidget {
  const _MiniOption({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 116,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.orangeLight),
          const Spacer(),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _EmergencyOption extends StatelessWidget {
  const _EmergencyOption({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: () => onChanged(!value),
      child: Container(
        height: 116,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: value ? AppColors.orangeDark : AppColors.surface,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: value ? Colors.white : AppColors.orangeLight,
            ),
            const Spacer(),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    '¿Es una\nemergencia?',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                Switch(
                  value: value,
                  onChanged: onChanged,
                  activeThumbColor: AppColors.orangeLight,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
