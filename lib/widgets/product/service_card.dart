import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/service_item.dart';
import '../common/rating_badge.dart';

class ServiceCard extends StatelessWidget {
  const ServiceCard({
    super.key,
    required this.service,
    this.onTap,
    this.compact = false,
  });

  final ServiceItem service;
  final VoidCallback? onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: onTap,
      child: Container(
        width: compact ? double.infinity : 310,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(28),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: compact ? 170 : 190,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(service.imageUrl, fit: BoxFit.cover),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.black54, Colors.transparent],
                        begin: Alignment.topCenter,
                        end: Alignment.center,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    top: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: service.badgeColor ?? AppColors.orangeLight,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(
                        service.badge,
                        style: const TextStyle(
                          color: Color(0xFF351807),
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          service.title,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      RatingBadge(rating: service.rating),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    service.providerName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.orangeLight,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    service.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Text(
                        CurrencyFormatter.usd(service.price),
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(color: AppColors.orangeLight),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '/${service.priceLabel}',
                        style: const TextStyle(color: AppColors.textMuted),
                      ),
                      const Spacer(),
                      Container(
                        height: 46,
                        padding: const EdgeInsets.symmetric(horizontal: 22),
                        decoration: BoxDecoration(
                          gradient: AppColors.orangeGradient,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'Reservar',
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
