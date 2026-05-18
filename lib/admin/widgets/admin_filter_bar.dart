import 'package:flutter/material.dart';

import '../core/admin_colors.dart';

class AdminFilterBar extends StatelessWidget {
  const AdminFilterBar({super.key, required this.filters, this.trailing});

  final List<Widget> filters;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AdminColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminColors.outlineSoft),
        boxShadow: const [
          BoxShadow(
            color: AdminColors.shadow,
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [...filters, ?trailing],
      ),
    );
  }
}

class AdminFilterChip extends StatelessWidget {
  const AdminFilterChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AdminColors.primary : AdminColors.surfaceHigh,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AdminColors.textMuted,
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class AdminSelectFilter extends StatelessWidget {
  const AdminSelectFilter({
    super.key,
    required this.value,
    required this.items,
    this.onChanged,
  });

  final String value;
  final List<String> items;
  final ValueChanged<String?>? onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AdminColors.surfaceInput,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AdminColors.outlineSoft),
        ),
        child: DropdownButton<String>(
          value: value,
          items: items
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: onChanged ?? (_) {},
        ),
      ),
    );
  }
}
