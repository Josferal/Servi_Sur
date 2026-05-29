import 'package:flutter/material.dart';

import 'package:servi_sur/features/admin/core/admin_colors.dart';
import 'package:servi_sur/features/admin/domain/entities/admin_metric.dart';

class AdminStatCard extends StatelessWidget {
  const AdminStatCard({super.key, required this.metric});

  final AdminMetric metric;

  @override
  Widget build(BuildContext context) {
    final color = metric.colorValue == null
        ? AdminColors.primary
        : Color(metric.colorValue!);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AdminColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminColors.outlineSoft),
        boxShadow: const [
          BoxShadow(
            color: AdminColors.shadow,
            blurRadius: 22,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(_iconForKey(metric.iconKey), color: color),
              ),
              const Spacer(),
              if (metric.delta != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    metric.delta!,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            metric.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AdminColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              metric.value,
              style: Theme.of(context).textTheme.displayLarge,
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconForKey(String key) {
    return switch (key) {
      'attach_money_rounded' => Icons.attach_money_rounded,
      'design_services_rounded' => Icons.design_services_rounded,
      'group_rounded' => Icons.group_rounded,
      'payments_rounded' => Icons.payments_rounded,
      'pending_actions_rounded' => Icons.pending_actions_rounded,
      'person_add_alt_1_rounded' => Icons.person_add_alt_1_rounded,
      'receipt_long_rounded' => Icons.receipt_long_rounded,
      'star_rounded' => Icons.star_rounded,
      'task_alt_rounded' => Icons.task_alt_rounded,
      'verified_user_rounded' => Icons.verified_user_rounded,
      _ => Icons.analytics_rounded,
    };
  }
}
