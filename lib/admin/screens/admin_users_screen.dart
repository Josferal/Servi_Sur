import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/user_model.dart';
import '../providers/admin_dashboard_provider.dart';
import '../widgets/admin_confirmation_dialog.dart';
import '../widgets/admin_data_table.dart';
import '../widgets/admin_filter_bar.dart';
import '../widgets/admin_page_header.dart';
import '../widgets/admin_search_field.dart';
import '../widgets/admin_status_chip.dart';
import '../widgets/admin_table_actions.dart';

class AdminUsersScreen extends StatelessWidget {
  const AdminUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminDashboardProvider>();
    final date = DateFormat('dd MMM yyyy');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AdminPageHeader(
          title: 'Gestion de Usuarios',
          subtitle: 'Control centralizado de clientes, proveedores y staff.',
          actions: [
            AdminHeaderButton(
              label: 'Nuevo usuario',
              icon: Icons.person_add_alt_1_rounded,
              primary: true,
            ),
          ],
        ),
        const SizedBox(height: 20),
        AdminFilterBar(
          filters: [
            SizedBox(
              width: 320,
              child: AdminSearchField(
                hint: 'Buscar usuarios, IDs o correos...',
                onChanged: provider.setUserQuery,
              ),
            ),
            AdminSelectFilter(
              value: provider.userRoleFilter,
              items: provider.roleOptions,
              onChanged: provider.setUserRoleFilter,
            ),
            AdminSelectFilter(
              value: provider.userStatusFilter,
              items: provider.userStatusOptions,
              onChanged: provider.setUserStatusFilter,
            ),
            AdminFilterChip(
              label: 'Limpiar filtros',
              onTap: provider.resetUserFilters,
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (provider.isBusy) ...[
          const LinearProgressIndicator(minHeight: 2),
          const SizedBox(height: 12),
        ],
        AdminDataTable(
          columns: const [
            'Usuario',
            'Email',
            'Rol',
            'Estado',
            'Fecha registro',
            'Acciones',
          ],
          rows: provider.filteredUsers
              .map(
                (user) => AdminTableRow([
                  _UserCell(user: user),
                  Text(user.email),
                  Text(provider.roleLabel(user)),
                  AdminStatusChip(
                    label: provider.userStatusLabel(user.status),
                    color: provider.statusColor(user.status.name),
                  ),
                  Text(date.format(user.createdAt)),
                  AdminTableActions(
                    children: [
                      AdminTableActionButton(
                        tooltip: 'Ver',
                        icon: Icons.visibility_rounded,
                        onPressed: provider.isBusy
                            ? null
                            : () => _showSnack(
                                context,
                                'Usuario ${user.fullName} seleccionado.',
                              ),
                      ),
                      AdminTableActionButton(
                        tooltip: user.status == UserStatus.active
                            ? 'Desactivar'
                            : 'Activar',
                        icon: user.status == UserStatus.active
                            ? Icons.toggle_off_rounded
                            : Icons.toggle_on_rounded,
                        onPressed: provider.isBusy
                            ? null
                            : () => _toggleUser(context, provider, user),
                      ),
                      AdminTableActionButton(
                        tooltip: 'Bloquear',
                        icon: Icons.block_rounded,
                        onPressed:
                            provider.isBusy ||
                                user.status == UserStatus.suspended
                            ? null
                            : () => _blockUser(context, provider, user),
                      ),
                    ],
                  ),
                ]),
              )
              .toList(),
        ),
      ],
    );
  }

  Future<void> _toggleUser(
    BuildContext context,
    AdminDashboardProvider provider,
    UserModel user,
  ) async {
    final activating = user.status != UserStatus.active;
    final confirmed = await showAdminConfirmationDialog(
      context,
      title: activating ? 'Activar usuario' : 'Desactivar usuario',
      message:
          'Se actualizara el estado de ${user.fullName} en la tabla administrativa.',
      confirmLabel: activating ? 'Activar' : 'Desactivar',
    );
    if (!confirmed || !context.mounted) {
      return;
    }

    final success = await provider.toggleUserActive(user);
    if (!context.mounted) {
      return;
    }
    _showSnack(
      context,
      success
          ? 'Usuario actualizado correctamente.'
          : 'No fue posible actualizar el usuario.',
      error: !success,
    );
  }

  Future<void> _blockUser(
    BuildContext context,
    AdminDashboardProvider provider,
    UserModel user,
  ) async {
    final confirmed = await showAdminConfirmationDialog(
      context,
      title: 'Bloquear usuario',
      message: 'El usuario ${user.fullName} quedara suspendido en la sesion.',
      confirmLabel: 'Bloquear',
      destructive: true,
    );
    if (!confirmed || !context.mounted) {
      return;
    }

    final success = await provider.blockUser(user);
    if (!context.mounted) {
      return;
    }
    _showSnack(
      context,
      success
          ? 'Usuario suspendido correctamente.'
          : 'No se puede suspender este usuario.',
      error: !success,
    );
  }

  void _showSnack(BuildContext context, String message, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? Colors.red.shade700 : null,
      ),
    );
  }
}

class _UserCell extends StatelessWidget {
  const _UserCell({required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundImage: user.avatarUrl == null
              ? null
              : NetworkImage(user.avatarUrl!),
          child: user.avatarUrl == null ? Text(user.fullName[0]) : null,
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.fullName,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              Text(
                'ID: ${user.id}',
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
