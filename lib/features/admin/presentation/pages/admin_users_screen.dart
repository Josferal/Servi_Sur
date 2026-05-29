import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:servi_sur/shared/domain/entities/user_model.dart';
import 'package:servi_sur/features/admin/presentation/providers/admin_dashboard_provider.dart';
import 'package:servi_sur/features/admin/presentation/widgets/admin_confirmation_dialog.dart';
import 'package:servi_sur/features/admin/presentation/widgets/admin_data_table.dart';
import 'package:servi_sur/features/admin/presentation/widgets/admin_filter_bar.dart';
import 'package:servi_sur/features/admin/presentation/widgets/admin_page_header.dart';
import 'package:servi_sur/features/admin/presentation/widgets/admin_search_field.dart';
import 'package:servi_sur/features/admin/presentation/widgets/admin_status_chip.dart';
import 'package:servi_sur/features/admin/presentation/widgets/admin_table_actions.dart';

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
        ),
        Align(
          alignment: Alignment.centerRight,
          child: AdminHeaderButton(
            label: 'Nuevo usuario',
            icon: Icons.person_add_alt_1_rounded,
            primary: true,
            onPressed: provider.isBusy
                ? null
                : () => _showCreateUserDialog(context, provider),
          ),
        ),
        const SizedBox(height: 20),
        if (provider.userError != null) ...[
          _AdminInlineMessage(message: provider.userError!, isError: true),
          const SizedBox(height: 14),
        ],
        if (provider.isLoadingUsers) ...[
          const LinearProgressIndicator(minHeight: 2),
          const SizedBox(height: 12),
        ],
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
        if (provider.isBusy && !provider.isLoadingUsers) ...[
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
                            : () => _showUserDetailDialog(context, user),
                      ),
                      AdminTableActionButton(
                        tooltip: 'Editar',
                        icon: Icons.edit_rounded,
                        onPressed: provider.isBusy
                            ? null
                            : () =>
                                  _showEditUserDialog(context, provider, user),
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

  Future<void> _showUserDetailDialog(BuildContext context, UserModel user) {
    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(user.fullName.isEmpty ? 'Usuario' : user.fullName),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DetailLine(label: 'ID', value: user.id),
              _DetailLine(label: 'Correo', value: user.email),
              _DetailLine(label: 'Telefono', value: user.phone),
              _DetailLine(label: 'Rol', value: user.role.name),
              _DetailLine(label: 'Estado', value: user.status.name),
              _DetailLine(
                label: 'Creado',
                value: DateFormat('dd/MM/yyyy HH:mm').format(user.createdAt),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditUserDialog(
    BuildContext context,
    AdminDashboardProvider provider,
    UserModel user,
  ) async {
    final nameController = TextEditingController(text: user.fullName);
    final phoneController = TextEditingController(text: user.phone);
    var role = user.role;
    var status = user.status;

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Editar usuario'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Nombre'),
                    ),
                    TextField(
                      controller: phoneController,
                      decoration: const InputDecoration(labelText: 'Telefono'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<UserRole>(
                      initialValue: role,
                      decoration: const InputDecoration(labelText: 'Rol'),
                      items: UserRole.values
                          .map(
                            (value) => DropdownMenuItem(
                              value: value,
                              child: Text(value.name),
                            ),
                          )
                          .toList(),
                      onChanged: provider.currentAdmin.isAdmin
                          ? (value) => setDialogState(
                              () => role = value ?? UserRole.client,
                            )
                          : null,
                    ),
                    DropdownButtonFormField<UserStatus>(
                      initialValue: status,
                      decoration: const InputDecoration(labelText: 'Estado'),
                      items: UserStatus.values
                          .where((value) => value != UserStatus.deleted)
                          .map(
                            (value) => DropdownMenuItem(
                              value: value,
                              child: Text(value.name),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => setDialogState(
                        () => status = value ?? UserStatus.active,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );

    final name = nameController.text;
    final phone = phoneController.text;
    nameController.dispose();
    phoneController.dispose();

    if (saved != true || !context.mounted) {
      return;
    }

    final success = await provider.saveUser(
      user,
      name: name,
      phone: phone,
      role: role,
      status: status,
    );
    if (!context.mounted) {
      return;
    }
    _showSnack(
      context,
      success ? 'Usuario guardado correctamente.' : 'No se pudo guardar.',
      error: !success,
    );
  }

  Future<void> _showCreateUserDialog(
    BuildContext context,
    AdminDashboardProvider provider,
  ) async {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final phoneController = TextEditingController();
    var role = UserRole.client;
    var status = UserStatus.active;

    final created = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Nuevo usuario'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Nombre'),
                    ),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'Correo'),
                    ),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Contrasena temporal',
                      ),
                    ),
                    TextField(
                      controller: phoneController,
                      decoration: const InputDecoration(labelText: 'Telefono'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<UserRole>(
                      initialValue: role,
                      decoration: const InputDecoration(labelText: 'Rol'),
                      items: UserRole.values
                          .map(
                            (value) => DropdownMenuItem(
                              value: value,
                              child: Text(value.name),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setDialogState(() => role = value ?? UserRole.client),
                    ),
                    DropdownButtonFormField<UserStatus>(
                      initialValue: status,
                      decoration: const InputDecoration(labelText: 'Estado'),
                      items: UserStatus.values
                          .where((value) => value != UserStatus.deleted)
                          .map(
                            (value) => DropdownMenuItem(
                              value: value,
                              child: Text(value.name),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => setDialogState(
                        () => status = value ?? UserStatus.active,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Crear'),
                ),
              ],
            );
          },
        );
      },
    );

    final name = nameController.text;
    final email = emailController.text;
    final password = passwordController.text;
    final phone = phoneController.text;
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();

    if (created != true || !context.mounted) {
      return;
    }

    final success = await provider.createBasicUser(
      name: name,
      email: email,
      password: password,
      phone: phone,
      role: role,
      status: status,
    );
    if (!context.mounted) {
      return;
    }
    _showSnack(
      context,
      success
          ? 'Cuenta creada correctamente.'
          : 'No se pudo crear la cuenta. Revisa permisos y correo.',
      error: !success,
    );
  }
}

class _AdminInlineMessage extends StatelessWidget {
  const _AdminInlineMessage({required this.message, required this.isError});

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isError
            ? Colors.red.withValues(alpha: 0.12)
            : Colors.green.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isError
              ? Colors.red.withValues(alpha: 0.3)
              : Colors.green.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        message,
        style: TextStyle(
          color: isError ? Colors.red.shade200 : Colors.green.shade200,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SelectableText('$label: $value'),
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
          child: user.avatarUrl == null ? Text(_initialFor(user)) : null,
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

  String _initialFor(UserModel user) {
    final name = user.fullName.trim();
    if (name.isNotEmpty) {
      return name.characters.first.toUpperCase();
    }
    final email = user.email.trim();
    if (email.isNotEmpty) {
      return email.characters.first.toUpperCase();
    }
    return '?';
  }
}
