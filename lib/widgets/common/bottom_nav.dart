import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/app_provider.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key, required this.currentIndex});

  final int currentIndex;

  void _changeTab(BuildContext context, int index, String route) {
    context.read<AppProvider>().setTab(index);
    context.go(route);
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      _NavItem('INICIO', Icons.home_outlined, '/home'),
      _NavItem('CATEGORIAS', Icons.grid_view_rounded, '/services'),
      _NavItem('ACTIVIDAD', Icons.receipt_long_rounded, '/activity'),
      _NavItem('CUENTA', Icons.person_outline_rounded, '/profile'),
    ];

    return Container(
      height: 78,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xF2141414),
        borderRadius: BorderRadius.circular(36),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 24,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(items.length, (index) {
          final item = items[index];
          final selected = index == currentIndex;
          return Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(28),
              onTap: () => _changeTab(context, index, item.route),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? AppColors.orange : Colors.transparent,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      item.icon,
                      color: selected ? Colors.white : AppColors.textMuted,
                      size: 22,
                    ),
                    const SizedBox(height: 3),
                    FittedBox(
                      child: Text(
                        item.label,
                        style: TextStyle(
                          color: selected ? Colors.white : AppColors.textMuted,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.label, this.icon, this.route);
  final String label;
  final IconData icon;
  final String route;
}
