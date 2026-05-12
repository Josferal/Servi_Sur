import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/provider_profile.dart';
import '../../models/review.dart';
import '../../models/service_item.dart';
import '../../models/user_model.dart';
import '../../providers/cart_provider.dart';
import '../../repositories/marketplace_repository.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/common/rating_badge.dart';

class ServiceDetailScreen extends StatefulWidget {
  const ServiceDetailScreen({super.key, required this.serviceId});

  final String serviceId;

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final repository = context.watch<MarketplaceRepository>();
    final service = repository.findServiceById(widget.serviceId);

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (service == null) {
      return _ServiceNotFound(onBack: _goBack);
    }

    final provider = repository.getProviderForService(service);
    final reviews = repository.getReviewsForService(service.id);

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _HeaderSection(
                  service: service,
                  provider: provider,
                  onBack: _goBack,
                  onShare: () => _shareService(service, provider),
                  onContact: () => _contactProvider(service, provider),
                  onReviews: () => _openReviews(service, reviews),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 126),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ServiceFacts(service: service, provider: provider),
                      const SizedBox(height: 28),
                      Text(
                        'Sobre el servicio',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 18),
                      _AboutServiceCard(service: service),
                      const SizedBox(height: 32),
                      _ReviewsHeader(
                        reviewCount: service.reviewCount,
                        onTap: () => _openReviews(service, reviews),
                      ),
                      const SizedBox(height: 18),
                      _ReviewCard(
                        review: reviews.isEmpty ? null : reviews.first,
                      ),
                      const SizedBox(height: 24),
                      _PopularityCard(service: service),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.background.withValues(alpha: 0.94),
                boxShadow: const [
                  BoxShadow(color: Colors.black54, blurRadius: 24),
                ],
              ),
              child: SafeArea(
                top: false,
                minimum: const EdgeInsets.fromLTRB(24, 14, 24, 16),
                child: PrimaryButton(
                  label: 'SOLICITAR SERVICIO',
                  icon: Icons.arrow_forward_rounded,
                  onPressed: () => _requestService(service),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _goBack() async {
    final didPop = await Navigator.maybePop(context);
    if (!didPop && mounted) {
      context.go('/home');
    }
  }

  Future<void> _shareService(
    ServiceItem service,
    ProviderProfile provider,
  ) async {
    final text = [
      service.title,
      'Proveedor: ${provider.name}',
      service.description,
      'Precio: ${CurrencyFormatter.usd(service.price)} ${service.priceLabel}',
    ].join('\n');

    await SharePlus.instance.share(
      ShareParams(subject: service.title, text: text),
    );
  }

  Future<void> _contactProvider(
    ServiceItem service,
    ProviderProfile provider,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        final phone = provider.phone.trim();
        final email = provider.email.trim();
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Contactar',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 6),
                Text(
                  provider.name,
                  style: const TextStyle(color: AppColors.textMuted),
                ),
                const SizedBox(height: 18),
                _ContactOption(
                  icon: Icons.call_rounded,
                  title: 'Llamar',
                  subtitle: phone.isEmpty ? 'No disponible' : phone,
                  enabled: phone.isNotEmpty,
                  onTap: () => _launchContact(Uri(scheme: 'tel', path: phone)),
                ),
                _ContactOption(
                  icon: Icons.chat_rounded,
                  title: 'WhatsApp / mensaje',
                  subtitle: phone.isEmpty ? 'No disponible' : 'Enviar consulta',
                  enabled: phone.isNotEmpty,
                  onTap: () {
                    final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
                    final uri = Uri.https('wa.me', '/$digits', {
                      'text': 'Hola, me interesa ${service.title}.',
                    });
                    _launchContact(uri);
                  },
                ),
                _ContactOption(
                  icon: Icons.mail_rounded,
                  title: 'Correo',
                  subtitle: email.isEmpty ? 'No disponible' : email,
                  enabled: email.isNotEmpty,
                  onTap: () => _launchContact(
                    Uri(
                      scheme: 'mailto',
                      path: email,
                      queryParameters: {
                        'subject': 'Consulta sobre ${service.title}',
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _launchContact(Uri uri) async {
    Navigator.of(context).pop();
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir esta opción.')),
      );
    }
  }

  void _requestService(ServiceItem service) {
    final repository = context.read<MarketplaceRepository>();
    final user = repository.currentUser;
    if (user.id.isEmpty || user.status != UserStatus.active) {
      context.go('/login');
      return;
    }

    context.read<CartProvider>().selectService(service);
    context.push('/order-summary');
  }

  Future<void> _openReviews(ServiceItem service, List<Review> reviews) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SafeArea(
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.55,
            minChildSize: 0.35,
            maxChildSize: 0.82,
            builder: (context, controller) {
              return ListView(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
                children: [
                  Text(
                    'Reseñas',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      RatingBadge(rating: service.rating),
                      const SizedBox(width: 8),
                      Text(
                        '${service.reviewCount} reseñas',
                        style: const TextStyle(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  if (reviews.isEmpty)
                    const _InlineReview(
                      rating: 5,
                      clientName: 'Cliente verificado',
                      comment:
                          'Servicio recomendado por la comunidad de Servi Sur.',
                    )
                  else
                    ...reviews.map(
                      (review) => _InlineReview(
                        rating: review.rating,
                        clientName: review.clientName,
                        comment: review.comment,
                      ),
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection({
    required this.service,
    required this.provider,
    required this.onBack,
    required this.onShare,
    required this.onContact,
    required this.onReviews,
  });

  final ServiceItem service;
  final ProviderProfile provider;
  final VoidCallback onBack;
  final VoidCallback onShare;
  final VoidCallback onContact;
  final VoidCallback onReviews;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final imageHeight = (screenHeight * 0.28).clamp(190.0, 260.0).toDouble();

    return Column(
      children: [
        Stack(
          children: [
            SizedBox(
              height: imageHeight,
              width: double.infinity,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(28),
                ),
                child: _NetworkImageFallback(imageUrl: service.imageUrl),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(28),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.58),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.5),
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                child: Row(
                  children: [
                    _CircleAction(
                      icon: Icons.arrow_back_rounded,
                      onPressed: onBack,
                    ),
                    const Spacer(),
                    _CircleAction(
                      icon: Icons.share_rounded,
                      onPressed: onShare,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 24,
              right: 24,
              bottom: 22,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (service.badge.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: service.badgeColor ?? AppColors.orange,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        service.badge,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    service.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          child: _ProviderCard(
            service: service,
            provider: provider,
            onContact: onContact,
            onReviews: onReviews,
          ),
        ),
      ],
    );
  }
}

class _ProviderCard extends StatelessWidget {
  const _ProviderCard({
    required this.service,
    required this.provider,
    required this.onContact,
    required this.onReviews,
  });

  final ServiceItem service;
  final ProviderProfile provider;
  final VoidCallback onContact;
  final VoidCallback onReviews;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 22)],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: AppColors.surfaceHigh,
                backgroundImage: provider.avatarUrl.isEmpty
                    ? null
                    : NetworkImage(provider.avatarUrl),
                child: provider.avatarUrl.isEmpty
                    ? const Icon(Icons.person_rounded)
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      provider.name.isEmpty
                          ? service.providerName
                          : provider.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      provider.specialty.isEmpty
                          ? service.categoryName
                          : provider.specialty,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.orangeLight,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: onReviews,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          RatingBadge(rating: service.rating),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              '${service.reviewCount} reseñas',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: onContact,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.surfaceHigh,
              foregroundColor: AppColors.textPrimary,
              minimumSize: const Size.fromHeight(48),
            ),
            child: const Text('Contactar'),
          ),
        ],
      ),
    );
  }
}

class _ServiceFacts extends StatelessWidget {
  const _ServiceFacts({required this.service, required this.provider});

  final ServiceItem service;
  final ProviderProfile provider;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _InfoPill(
          icon: Icons.payments_rounded,
          label:
              '${CurrencyFormatter.usd(service.price)} ${service.priceLabel}',
        ),
        if (service.duration.isNotEmpty)
          _InfoPill(icon: Icons.schedule_rounded, label: service.duration),
        if (service.distance.isNotEmpty)
          _InfoPill(icon: Icons.near_me_rounded, label: service.distance),
        _InfoPill(
          icon: Icons.verified_rounded,
          label: _availabilityLabel(provider.availability),
        ),
      ],
    );
  }

  static String _availabilityLabel(ProviderAvailability availability) {
    return switch (availability) {
      ProviderAvailability.available => 'Disponible',
      ProviderAvailability.busy => 'Ocupado',
      ProviderAvailability.offline => 'Sin conexión',
    };
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.orangeLight, size: 18),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _AboutServiceCard extends StatelessWidget {
  const _AboutServiceCard({required this.service});

  final ServiceItem service;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            service.description.isEmpty
                ? 'Este proveedor aún no agregó una descripción.'
                : service.description,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 17,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 24),
          if (service.tags.isEmpty)
            const Text(
              'Características no disponibles por el momento.',
              style: TextStyle(color: AppColors.textMuted),
            )
          else
            ...service.tags.map(
              (tag) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _Benefit(tag: tag),
              ),
            ),
        ],
      ),
    );
  }
}

class _Benefit extends StatelessWidget {
  const _Benefit({required this.tag});

  final String tag;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: AppColors.blue.withValues(alpha: 0.25),
          child: Icon(_iconForTag(tag), color: AppColors.blue),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _titleForTag(tag),
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              Text(
                'Incluido en este servicio',
                style: const TextStyle(color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _iconForTag(String tag) {
    final value = tag.toLowerCase();
    if (value.contains('eco') || value.contains('bio')) {
      return Icons.eco_rounded;
    }
    if (value.contains('express') || value.contains('emergencia')) {
      return Icons.bolt_rounded;
    }
    if (value.contains('3d') || value.contains('diseño')) {
      return Icons.view_in_ar_rounded;
    }
    return Icons.check_circle_rounded;
  }

  String _titleForTag(String tag) {
    if (tag.isEmpty) {
      return 'Característica';
    }
    return tag[0].toUpperCase() + tag.substring(1);
  }
}

class _ReviewsHeader extends StatelessWidget {
  const _ReviewsHeader({required this.reviewCount, required this.onTap});

  final int reviewCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Reseñas destacadas',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        TextButton(onPressed: onTap, child: Text('Ver todas ($reviewCount)')),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});

  final Review? review;

  @override
  Widget build(BuildContext context) {
    final comment =
        review?.comment ?? 'Aún no hay reseñas publicadas para este servicio.';
    final clientName = review?.clientName ?? 'Servi Sur';
    final rating = review?.rating ?? 5;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '★' * rating.round().clamp(1, 5),
            style: const TextStyle(color: AppColors.orange, fontSize: 18),
          ),
          const SizedBox(height: 14),
          Text(
            '"$comment"',
            style: const TextStyle(
              fontSize: 18,
              fontStyle: FontStyle.italic,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          Text(clientName, style: const TextStyle(fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _PopularityCard extends StatelessWidget {
  const _PopularityCard({required this.service});

  final ServiceItem service;

  @override
  Widget build(BuildContext context) {
    final satisfaction = (service.rating / 5).clamp(0.0, 1.0);
    final repeatRate = (service.reviewCount / 140).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'POPULARIDAD DEL SERVICIO',
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 22),
          _Progress(
            label: 'Satisfacción del cliente',
            value: satisfaction,
            text: '${(satisfaction * 100).round()}%',
          ),
          const SizedBox(height: 18),
          _Progress(
            label: 'Actividad de reseñas',
            value: repeatRate,
            text: '${(repeatRate * 100).round()}%',
          ),
        ],
      ),
    );
  }
}

class _Progress extends StatelessWidget {
  const _Progress({
    required this.label,
    required this.value,
    required this.text,
  });
  final String label;
  final double value;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ),
            Text(
              text,
              style: const TextStyle(
                color: AppColors.orangeLight,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: value,
          minHeight: 10,
          borderRadius: BorderRadius.circular(8),
          color: AppColors.orange,
          backgroundColor: AppColors.surfaceHigh,
        ),
      ],
    );
  }
}

class _ContactOption extends StatelessWidget {
  const _ContactOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      enabled: enabled,
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: AppColors.orangeDark.withValues(alpha: 0.35),
        child: Icon(icon, color: AppColors.orangeLight),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: enabled ? onTap : null,
    );
  }
}

class _InlineReview extends StatelessWidget {
  const _InlineReview({
    required this.rating,
    required this.clientName,
    required this.comment,
  });

  final double rating;
  final String clientName;
  final String comment;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surfaceHigh,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '★' * rating.round().clamp(1, 5),
              style: const TextStyle(color: AppColors.orange),
            ),
            const SizedBox(height: 8),
            Text(comment, style: const TextStyle(height: 1.35)),
            const SizedBox(height: 10),
            Text(
              clientName,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleAction extends StatelessWidget {
  const _CircleAction({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton.filled(
      onPressed: onPressed,
      icon: Icon(icon),
      style: IconButton.styleFrom(
        backgroundColor: Colors.black.withValues(alpha: 0.45),
        foregroundColor: Colors.white,
      ),
    );
  }
}

class _NetworkImageFallback extends StatelessWidget {
  const _NetworkImageFallback({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return const _ImagePlaceholder();
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => const _ImagePlaceholder(),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }
        return const _ImagePlaceholder(isLoading: true);
      },
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({this.isLoading = false});

  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceHigh,
      alignment: Alignment.center,
      child: isLoading
          ? const CircularProgressIndicator()
          : const Icon(
              Icons.home_repair_service_rounded,
              color: AppColors.textMuted,
              size: 46,
            ),
    );
  }
}

class _ServiceNotFound extends StatelessWidget {
  const _ServiceNotFound({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CircleAction(icon: Icons.arrow_back_rounded, onPressed: onBack),
              const Spacer(),
              const Icon(
                Icons.search_off_rounded,
                color: AppColors.orangeLight,
                size: 52,
              ),
              const SizedBox(height: 18),
              Text(
                'Servicio no encontrado',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 10),
              const Text(
                'El servicio que intentas abrir no está disponible.',
                style: TextStyle(color: AppColors.textMuted),
              ),
              const Spacer(),
              PrimaryButton(label: 'Volver al inicio', onPressed: onBack),
            ],
          ),
        ),
      ),
    );
  }
}
