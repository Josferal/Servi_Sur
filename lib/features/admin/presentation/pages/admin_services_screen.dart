import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:servi_sur/shared/domain/entities/service_item.dart';
import 'package:servi_sur/features/admin/presentation/providers/admin_dashboard_provider.dart';
import 'package:servi_sur/features/admin/presentation/widgets/admin_confirmation_dialog.dart';
import 'package:servi_sur/features/admin/presentation/widgets/admin_data_table.dart';
import 'package:servi_sur/features/admin/presentation/widgets/admin_filter_bar.dart';
import 'package:servi_sur/features/admin/presentation/widgets/admin_page_header.dart';
import 'package:servi_sur/features/admin/presentation/widgets/admin_search_field.dart';
import 'package:servi_sur/features/admin/presentation/widgets/admin_status_chip.dart';
import 'package:servi_sur/features/admin/presentation/widgets/admin_table_actions.dart';

class AdminServicesScreen extends StatelessWidget {
  const AdminServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminDashboardProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AdminPageHeader(
          title: 'Gestion de Servicios',
          subtitle:
              'Supervisa y administra el catalogo de servicios disponibles.',
          actions: [
            AdminHeaderButton(label: 'Exportar', icon: Icons.download_rounded),
            AdminHeaderButton(
              label: 'Nuevo servicio',
              icon: Icons.add_rounded,
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
                hint: 'Buscar servicios, categorias o proveedores...',
                onChanged: provider.setServiceQuery,
              ),
            ),
            AdminSelectFilter(
              value: provider.serviceCategoryFilter,
              items: provider.serviceCategoryOptions,
              onChanged: provider.setServiceCategoryFilter,
            ),
            AdminSelectFilter(
              value: provider.serviceStatusFilter,
              items: provider.serviceStatusOptions,
              onChanged: provider.setServiceStatusFilter,
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
            'Servicio',
            'Categoria',
            'Proveedor',
            'Precio',
            'Rating',
            'Estado',
            'Acciones',
          ],
          minWidth: 980,
          rows: provider.filteredServices
              .map(
                (service) => AdminTableRow([
                  _ServiceCell(service: service),
                  Text(service.categoryName),
                  Text(service.providerName),
                  Text(
                    '${provider.formatMoney(service.price)} / ${service.priceLabel}',
                  ),
                  Text(
                    '${service.rating.toStringAsFixed(1)} (${service.reviewCount})',
                  ),
                  AdminStatusChip(
                    label: provider.serviceStatusLabel(service.status),
                    color: provider.statusColor(service.status.name),
                  ),
                  AdminTableActions(
                    children: [
                      AdminTableActionButton(
                        tooltip: 'Aprobar',
                        icon: Icons.check_circle_outline_rounded,
                        onPressed:
                            provider.isBusy ||
                                service.status == ServiceStatus.active
                            ? null
                            : () => _approveService(context, provider, service),
                      ),
                      AdminTableActionButton(
                        tooltip: 'Pausar',
                        icon: Icons.pause_circle_outline_rounded,
                        onPressed:
                            provider.isBusy ||
                                service.status == ServiceStatus.paused
                            ? null
                            : () => _pauseService(context, provider, service),
                      ),
                      AdminTableActionButton(
                        tooltip: 'Ocultar',
                        icon: Icons.visibility_off_rounded,
                        onPressed:
                            provider.isBusy ||
                                service.status == ServiceStatus.archived
                            ? null
                            : () => _hideService(context, provider, service),
                      ),
                      AdminTableActionButton(
                        tooltip: 'Eliminar',
                        icon: Icons.delete_outline_rounded,
                        onPressed: provider.isBusy
                            ? null
                            : () => _deleteService(context, provider, service),
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

  Future<void> _approveService(
    BuildContext context,
    AdminDashboardProvider provider,
    ServiceItem service,
  ) async {
    final success = await provider.approveService(service.id);
    if (!context.mounted) {
      return;
    }
    _showSnack(
      context,
      success
          ? 'Servicio aprobado y publicado.'
          : 'No fue posible aprobar el servicio.',
      error: !success,
    );
  }

  Future<void> _pauseService(
    BuildContext context,
    AdminDashboardProvider provider,
    ServiceItem service,
  ) async {
    final confirmed = await showAdminConfirmationDialog(
      context,
      title: 'Pausar servicio',
      message: 'El servicio ${service.title} dejara de mostrarse como activo.',
      confirmLabel: 'Pausar',
    );
    if (!confirmed || !context.mounted) {
      return;
    }

    final success = await provider.pauseService(service.id);
    if (!context.mounted) {
      return;
    }
    _showSnack(
      context,
      success ? 'Servicio pausado.' : 'No fue posible pausar el servicio.',
      error: !success,
    );
  }

  Future<void> _hideService(
    BuildContext context,
    AdminDashboardProvider provider,
    ServiceItem service,
  ) async {
    final confirmed = await showAdminConfirmationDialog(
      context,
      title: 'Ocultar servicio',
      message: 'El servicio ${service.title} pasara al estado archivado.',
      confirmLabel: 'Ocultar',
    );
    if (!confirmed || !context.mounted) {
      return;
    }

    final success = await provider.hideService(service.id);
    if (!context.mounted) {
      return;
    }
    _showSnack(
      context,
      success ? 'Servicio ocultado.' : 'No fue posible ocultar el servicio.',
      error: !success,
    );
  }

  Future<void> _deleteService(
    BuildContext context,
    AdminDashboardProvider provider,
    ServiceItem service,
  ) async {
    final confirmed = await showAdminConfirmationDialog(
      context,
      title: 'Eliminar servicio mock',
      message: 'El servicio ${service.title} se eliminara solo de esta sesion.',
      confirmLabel: 'Eliminar',
      destructive: true,
    );
    if (!confirmed || !context.mounted) {
      return;
    }

    final success = await provider.deleteService(service.id);
    if (!context.mounted) {
      return;
    }
    _showSnack(
      context,
      success ? 'Servicio eliminado.' : 'No fue posible eliminar el servicio.',
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

class _ServiceCell extends StatelessWidget {
  const _ServiceCell({required this.service});

  final ServiceItem service;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            service.imageUrl,
            width: 42,
            height: 42,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const SizedBox(
              width: 42,
              height: 42,
              child: ColoredBox(color: Color(0xFFE9EFE9)),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                service.title,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              Text(
                'ID: ${service.id}',
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
