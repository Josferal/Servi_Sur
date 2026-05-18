import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../core/admin_colors.dart';
import '../providers/admin_dashboard_provider.dart';
import '../services/admin_session_service.dart';
import 'admin_search_field.dart';

class AdminTopBar extends StatelessWidget {
  const AdminTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminDashboardProvider>();
    final admin = provider.currentAdmin;
    final today = DateFormat('dd MMM yyyy, HH:mm').format(DateTime.now());
    final width = MediaQuery.sizeOf(context).width;
    final showDate = width >= 1060;
    final showUserText = width >= 1220;

    return Container(
      height: 78,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: AdminColors.surface,
        border: Border(bottom: BorderSide(color: AdminColors.outlineSoft)),
      ),
      child: Row(
        children: [
          Expanded(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: AdminSearchField(
                hint: 'Buscar transacciones, usuarios o servicios...',
              ),
            ),
          ),
          const SizedBox(width: 18),
          if (showDate) ...[
            _TopBarPill(icon: Icons.today_rounded, label: today),
            const SizedBox(width: 10),
          ],
          _TopBarIconButton(
            tooltip: 'Notificaciones',
            icon: Icons.notifications_none_rounded,
            onPressed: () {},
          ),
          _TopBarIconButton(
            tooltip: 'Exportaciones',
            icon: Icons.file_download_outlined,
            onPressed: () async {
              final downloaded = await provider.downloadAdminReportCsv();
              if (!context.mounted) {
                return;
              }
              final csv = provider.buildAdminReportCsv();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    downloaded
                        ? 'CSV descargado (${csv.length} caracteres)'
                        : 'CSV preparado para exportacion (${csv.length} caracteres)',
                  ),
                ),
              );
            },
          ),
          _TopBarIconButton(
            tooltip: 'Ayuda',
            icon: Icons.help_outline_rounded,
            onPressed: () {},
          ),
          _TopBarIconButton(
            tooltip: 'Cerrar sesion',
            icon: Icons.logout_rounded,
            onPressed: () async {
              await AdminSessionService().signOut();
              if (context.mounted) {
                context.go('/admin/login');
              }
            },
          ),
          const SizedBox(width: 8),
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AdminColors.primary,
                child: Text(
                  admin.fullName.isEmpty ? 'A' : admin.fullName.substring(0, 1),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (showUserText) ...[
                const SizedBox(width: 10),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 160),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        admin.fullName,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      const Text(
                        'Superuser',
                        style: TextStyle(
                          color: AdminColors.textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _TopBarIconButton extends StatelessWidget {
  const _TopBarIconButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: Icon(icon),
      ),
    );
  }
}

class _TopBarPill extends StatelessWidget {
  const _TopBarPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AdminColors.surfaceLow,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AdminColors.primary),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: AdminColors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
