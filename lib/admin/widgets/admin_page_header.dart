import 'package:flutter/material.dart';

import '../core/admin_colors.dart';

class AdminPageHeader extends StatelessWidget {
  const AdminPageHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.actions = const [],
  });

  final String title;
  final String subtitle;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 14,
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AdminColors.textMuted),
              ),
            ],
          ),
        ),
        if (actions.isNotEmpty)
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.end,
            children: actions,
          ),
      ],
    );
  }
}

class AdminHeaderButton extends StatelessWidget {
  const AdminHeaderButton({
    super.key,
    required this.label,
    required this.icon,
    this.primary = false,
    this.onPressed,
  });

  final String label;
  final IconData icon;
  final bool primary;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final foreground = primary ? Colors.white : AdminColors.text;
    final background = primary ? AdminColors.primary : AdminColors.surface;

    return FilledButton.icon(
      onPressed: onPressed ?? () {},
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: FilledButton.styleFrom(
        backgroundColor: background,
        foregroundColor: foreground,
        elevation: primary ? 1 : 0,
        side: primary ? null : const BorderSide(color: AdminColors.outlineSoft),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
