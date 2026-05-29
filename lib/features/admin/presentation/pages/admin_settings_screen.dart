import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:servi_sur/features/admin/core/admin_colors.dart';
import 'package:servi_sur/features/admin/presentation/providers/admin_dashboard_provider.dart';
import 'package:servi_sur/features/admin/presentation/widgets/admin_page_header.dart';
import 'package:servi_sur/features/admin/presentation/widgets/admin_status_chip.dart';
import 'package:servi_sur/shared/presentation/widgets/product/service_category_icon.dart';

class AdminSettingsScreen extends StatelessWidget {
  const AdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminDashboardProvider>();
    final settings = provider.settings;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AdminPageHeader(
          title: 'Configuracion del Sistema',
          subtitle: 'Gestiona preferencias globales, categorias y seguridad.',
          actions: [
            AdminHeaderButton(
              label: 'Guardar cambios',
              icon: Icons.save_rounded,
              primary: true,
            ),
          ],
        ),
        const SizedBox(height: 22),
        LayoutBuilder(
          builder: (context, constraints) {
            final stacked = constraints.maxWidth < 1040;
            final left = Column(
              children: [
                _SettingsCard(
                  title: 'Informacion de la plataforma',
                  child: Column(
                    children: [
                      TextFormField(
                        initialValue: settings.platformName,
                        decoration: const InputDecoration(
                          labelText: 'Nombre de la plataforma',
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: settings.supportEmail,
                        decoration: const InputDecoration(
                          labelText: 'Email de soporte',
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: settings.taxRate.toStringAsFixed(0),
                        decoration: const InputDecoration(
                          labelText: 'IVA / impuesto (%)',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                _SettingsCard(
                  title: 'Preferencias del sistema',
                  child: Column(
                    children: [
                      _PreferenceSwitch(
                        title: 'Modo mantenimiento',
                        subtitle: 'Desactiva el acceso publico temporalmente.',
                        value: settings.maintenanceMode,
                        onChanged: (value) => provider.updateSettings(
                          settings.copyWith(maintenanceMode: value),
                        ),
                      ),
                      _PreferenceSwitch(
                        title: 'Notificaciones activas',
                        subtitle: 'Envia alertas operativas al equipo admin.',
                        value: settings.notificationsEnabled,
                        onChanged: (value) => provider.updateSettings(
                          settings.copyWith(notificationsEnabled: value),
                        ),
                      ),
                      _PreferenceSwitch(
                        title: 'Aprobacion manual de proveedores',
                        subtitle: 'Revisa proveedores antes de publicarlos.',
                        value: settings.manualProviderApproval,
                        onChanged: (value) => provider.updateSettings(
                          settings.copyWith(manualProviderApproval: value),
                        ),
                      ),
                      _PreferenceSwitch(
                        title: 'Doble factor obligatorio',
                        subtitle: 'Preparado para autenticacion admin real.',
                        value: settings.twoFactorRequired,
                        onChanged: (value) => provider.updateSettings(
                          settings.copyWith(twoFactorRequired: value),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );

            final right = Column(
              children: [
                _SettingsCard(
                  title: 'Gestion visual de categorias',
                  child: Column(
                    children: provider.categories
                        .map(
                          (category) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              backgroundColor: AdminColors.primarySoft,
                              child: Icon(
                                category.icon,
                                color: AdminColors.primary,
                              ),
                            ),
                            title: Text(category.name),
                            subtitle: Text(category.subtitle),
                            trailing: AdminStatusChip(
                              label: category.isActive ? 'Activa' : 'Inactiva',
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                const SizedBox(height: 22),
                _SettingsCard(
                  title: 'Roles de usuario',
                  child: Column(
                    children: provider.roles
                        .map(
                          (role) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(role.name),
                            subtitle: Text(role.description),
                            trailing: Text(
                              '${role.users} usuarios',
                              style: const TextStyle(
                                color: AdminColors.primary,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            );

            return stacked
                ? Column(children: [left, const SizedBox(height: 22), right])
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: left),
                      const SizedBox(width: 22),
                      Expanded(flex: 2, child: right),
                    ],
                  );
          },
        ),
      ],
    );
  }
}

class _PreferenceSwitch extends StatelessWidget {
  const _PreferenceSwitch({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
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
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const Divider(height: 28),
          child,
        ],
      ),
    );
  }
}
