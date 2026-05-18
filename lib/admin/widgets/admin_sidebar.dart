import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/admin_colors.dart';

class AdminSidebar extends StatelessWidget {
  const AdminSidebar({super.key, required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;

    return Container(
      width: compact ? 86 : 260,
      decoration: const BoxDecoration(
        color: AdminColors.sidebar,
        border: Border(right: BorderSide(color: Color(0xFF252A27))),
      ),
      padding: const EdgeInsets.fromLTRB(18, 26, 18, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AdminColors.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.storefront_rounded,
                  color: Colors.white,
                ),
              ),
              if (!compact) ...[
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ServiMarket',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'Administracion',
                        style: TextStyle(
                          color: AdminColors.sidebarMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 34),
          ..._items.map(
            (item) => _SidebarItem(
              item: item,
              compact: compact,
              selected: item.route == '/admin'
                  ? location == '/admin'
                  : location.startsWith(item.route),
            ),
          ),
          const Spacer(),
          if (!compact)
            const Text(
              'Admin Principal\nSuperuser',
              style: TextStyle(
                color: AdminColors.sidebarMuted,
                fontSize: 12,
                height: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.item,
    required this.compact,
    required this.selected,
  });

  final _AdminNavItem item;
  final bool compact;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Tooltip(
        message: compact ? item.label : '',
        waitDuration: const Duration(milliseconds: 500),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => context.go(item.route),
          child: Container(
            height: 46,
            padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 14),
            decoration: BoxDecoration(
              color: selected ? AdminColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: selected
                    ? Colors.white.withValues(alpha: 0.12)
                    : Colors.transparent,
              ),
            ),
            child: Row(
              mainAxisAlignment: compact
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                Icon(
                  item.icon,
                  size: 21,
                  color: selected ? Colors.white : AdminColors.sidebarMuted,
                ),
                if (!compact) ...[
                  const SizedBox(width: 12),
                  Text(
                    item.label,
                    style: TextStyle(
                      color: selected ? Colors.white : const Color(0xFFBCCAC0),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AdminNavItem {
  const _AdminNavItem(this.label, this.route, this.icon);

  final String label;
  final String route;
  final IconData icon;
}

const _items = [
  _AdminNavItem('Dashboard', '/admin', Icons.dashboard_rounded),
  _AdminNavItem('Usuarios', '/admin/users', Icons.group_rounded),
  _AdminNavItem('Servicios', '/admin/services', Icons.design_services_rounded),
  _AdminNavItem('Ordenes', '/admin/orders', Icons.receipt_long_rounded),
  _AdminNavItem('Reportes', '/admin/reports', Icons.bar_chart_rounded),
  _AdminNavItem('Configuracion', '/admin/settings', Icons.settings_rounded),
];
