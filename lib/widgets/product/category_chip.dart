import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/category.dart';

class CategoryChipCard extends StatelessWidget {
  const CategoryChipCard({
    super.key,
    required this.category,
    this.onTap,
    this.selected = false,
  });

  final ServiceCategory category;
  final VoidCallback? onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: SizedBox(
        width: 92,
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: selected ? AppColors.orange : AppColors.surface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: selected ? AppColors.orangeLight : Colors.transparent,
                ),
              ),
              child: Icon(
                category.icon,
                color: selected ? Colors.white : AppColors.orangeLight,
                size: 30,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              category.name,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}
