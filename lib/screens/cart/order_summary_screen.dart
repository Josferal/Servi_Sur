import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/navigation/app_navigation.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../providers/cart_provider.dart';
import '../../repositories/marketplace_repository.dart';
import '../../services/auth_service.dart';
import '../../services/order_service.dart';
import '../../services/storage_service.dart';
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
  static const _maxImages = 3;
  static const _maxImageBytes = StorageService.maxImageBytes;

  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController(text: 'Mañana (08:00 - 12:00)');
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<XFile> _selectedImages = [];
  final Map<String, Uint8List> _previewBytes = {};
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
                  Expanded(
                    child: _MiniOption(
                      icon: Icons.camera_alt_outlined,
                      label: _selectedImages.isEmpty
                          ? 'Adjuntar Fotos\n(Opcional)'
                          : '${_selectedImages.length}/$_maxImages fotos\nadjuntas',
                      onTap: _isSubmitting ? null : _pickImages,
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
              if (_selectedImages.isNotEmpty) ...[
                const SizedBox(height: 14),
                _ImagePreviewStrip(
                  images: _selectedImages,
                  previewBytes: _previewBytes,
                  onRemove: _isSubmitting ? null : _removeImage,
                ),
              ],
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

  Future<void> _pickImages() async {
    final remainingSlots = _maxImages - _selectedImages.length;
    if (remainingSlots <= 0) {
      _showSnackBar('Puedes adjuntar hasta $_maxImages fotos.');
      return;
    }

    try {
      final pickedImages = await _imagePicker.pickMultiImage(
        imageQuality: 82,
        limit: remainingSlots,
      );
      if (pickedImages.isEmpty) {
        return;
      }

      var rejected = 0;
      for (final image in pickedImages.take(remainingSlots)) {
        final bytes = await image.readAsBytes();
        if (bytes.length > _maxImageBytes || !_isImageFile(image)) {
          rejected++;
          continue;
        }
        _selectedImages.add(image);
        _previewBytes[image.path] = bytes;
      }

      if (!mounted) {
        return;
      }
      setState(() {});
      if (rejected > 0) {
        _showSnackBar('Algunas fotos superaban 5 MB o no eran imagenes.');
      }
    } catch (_) {
      if (mounted) {
        _showSnackBar('No se pudieron seleccionar las fotos.');
      }
    }
  }

  void _removeImage(int index) {
    final image = _selectedImages.removeAt(index);
    _previewBytes.remove(image.path);
    setState(() {});
  }

  bool _isImageFile(XFile image) {
    final mimeType = image.mimeType;
    if (mimeType != null && mimeType.startsWith('image/')) {
      return true;
    }
    final lower = image.name.toLowerCase();
    return lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.webp') ||
        lower.endsWith('.gif');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
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
      final createdOrder = await orderService.createOrderFromRequest(request);
      var order = createdOrder;
      var requestWithImages = request;
      var failedUploads = 0;

      if (_selectedImages.isNotEmpty) {
        final storageService = StorageService();
        final uploadedImages = <UploadedRequestImage>[];

        for (final image in _selectedImages) {
          try {
            final uploaded = await storageService.uploadRequestImage(
              uid: user.uid,
              orderId: createdOrder.id,
              file: image,
            );
            uploadedImages.add(uploaded);
          } catch (_) {
            failedUploads++;
          }
        }

        if (uploadedImages.isNotEmpty) {
          final imageUrls = uploadedImages.map((image) => image.url).toList();
          final imagePaths = uploadedImages.map((image) => image.path).toList();
          final attachments = uploadedImages
              .map((image) => image.toMap())
              .toList();
          try {
            await orderService.attachImagesToRequest(
              requestId: request.id,
              imageUrls: imageUrls,
              imagePaths: imagePaths,
              attachments: attachments,
            );
            await orderService.attachImagesToOrder(
              orderId: createdOrder.id,
              imageUrls: imageUrls,
              imagePaths: imagePaths,
              attachments: attachments,
            );
            requestWithImages = request.copyWith(
              photoUrls: imageUrls,
              imageUrls: imageUrls,
              imagePaths: imagePaths,
              attachments: attachments,
            );
            order = createdOrder.copyWith(
              imageUrls: imageUrls,
              imagePaths: imagePaths,
              attachments: attachments,
            );
          } catch (_) {
            failedUploads = _selectedImages.length;
            for (final image in uploadedImages) {
              try {
                await storageService.deleteImage(image.path);
              } catch (_) {}
            }
          }
        }
      }

      if (!mounted) {
        return;
      }
      if (failedUploads > 0) {
        _showSnackBar(
          failedUploads == _selectedImages.length
              ? 'La orden se creo, pero no se pudieron subir las fotos.'
              : 'La orden se creo con algunas fotos adjuntas.',
        );
      }
      cart.setConfirmedOrder(
        service: service,
        request: requestWithImages,
        order: order,
      );
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
  const _MiniOption({required this.icon, required this.label, this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: onTap,
      child: Container(
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
      ),
    );
  }
}

class _ImagePreviewStrip extends StatelessWidget {
  const _ImagePreviewStrip({
    required this.images,
    required this.previewBytes,
    required this.onRemove,
  });

  final List<XFile> images;
  final Map<String, Uint8List> previewBytes;
  final ValueChanged<int>? onRemove;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 86,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final image = images[index];
          final bytes = previewBytes[image.path];
          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  width: 86,
                  height: 86,
                  color: AppColors.surface,
                  child: bytes == null
                      ? const Icon(
                          Icons.image_rounded,
                          color: AppColors.textMuted,
                        )
                      : Image.memory(bytes, fit: BoxFit.cover),
                ),
              ),
              if (onRemove != null)
                Positioned(
                  top: 4,
                  right: 4,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => onRemove!(index),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.72),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
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
