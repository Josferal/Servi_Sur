import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:servi_sur/features/admin/domain/entities/admin_order_record.dart';
import 'package:servi_sur/features/admin/presentation/providers/admin_dashboard_provider.dart';
import 'package:servi_sur/features/admin/presentation/widgets/admin_confirmation_dialog.dart';
import 'package:servi_sur/features/admin/presentation/widgets/admin_data_table.dart';
import 'package:servi_sur/features/admin/presentation/widgets/admin_filter_bar.dart';
import 'package:servi_sur/features/admin/presentation/widgets/admin_page_header.dart';
import 'package:servi_sur/features/admin/presentation/widgets/admin_stat_card.dart';
import 'package:servi_sur/features/admin/presentation/widgets/admin_search_field.dart';
import 'package:servi_sur/features/admin/presentation/widgets/admin_status_chip.dart';
import 'package:servi_sur/features/admin/presentation/widgets/admin_table_actions.dart';

class AdminOrdersScreen extends StatelessWidget {
  const AdminOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminDashboardProvider>();
    final date = DateFormat('dd MMM yyyy');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AdminPageHeader(
          title: 'Gestion de Ordenes',
          subtitle: 'Supervisa y administra todas las solicitudes.',
          actions: [
            AdminHeaderButton(label: 'Exportar', icon: Icons.download_rounded),
            AdminHeaderButton(
              label: 'Nueva orden',
              icon: Icons.add_rounded,
              primary: true,
            ),
          ],
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 900 ? 4 : 2;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: provider.dashboardMetrics.take(4).length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                mainAxisExtent: 176,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemBuilder: (context, index) =>
                  AdminStatCard(metric: provider.dashboardMetrics[index + 3]),
            );
          },
        ),
        const SizedBox(height: 20),
        AdminFilterBar(
          filters: [
            SizedBox(
              width: 320,
              child: AdminSearchField(
                hint: 'Buscar ordenes, clientes o servicios...',
                onChanged: provider.setOrderQuery,
              ),
            ),
            ...provider.orderStatusOptions.map(
              (status) => AdminFilterChip(
                label: status,
                selected: provider.orderStatusFilter == status,
                onTap: () => provider.setOrderStatusFilter(status),
              ),
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
            'ID de orden',
            'Cliente',
            'Proveedor',
            'Servicio',
            'Fecha',
            'Total',
            'Estado',
            'Acciones',
          ],
          minWidth: 980,
          rows: provider.filteredOrders
              .map(
                (order) => AdminTableRow([
                  Text('#${order.id.toUpperCase()}'),
                  Text(order.clientName),
                  Text(order.providerName),
                  Text(order.serviceName),
                  Text(date.format(order.date)),
                  Text(provider.formatMoney(order.total)),
                  AdminStatusChip(
                    label: order.status,
                    color: provider.statusColor(order.status),
                  ),
                  AdminTableActions(
                    children: [
                      AdminTableActionButton(
                        tooltip: 'Ver detalle',
                        icon: Icons.visibility_rounded,
                        onPressed: provider.isBusy
                            ? null
                            : () => _showSnack(
                                context,
                                'Orden ${order.id} seleccionada.',
                              ),
                      ),
                      AdminTableActionButton(
                        tooltip: 'Cambiar estado',
                        icon: Icons.swap_horiz_rounded,
                        onPressed: provider.isBusy
                            ? null
                            : () =>
                                  _changeOrderStatus(context, provider, order),
                      ),
                      AdminTableActionButton(
                        tooltip: 'Cancelar',
                        icon: Icons.cancel_outlined,
                        onPressed:
                            provider.isBusy || order.status == 'Cancelada'
                            ? null
                            : () => _cancelOrder(context, provider, order),
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

  Future<void> _changeOrderStatus(
    BuildContext context,
    AdminDashboardProvider provider,
    AdminOrderRecord order,
  ) async {
    final status = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text('Cambiar estado de ${order.id}'),
        children: provider.orderStatusOptions
            .where((status) => status != 'Todas')
            .map(
              (status) => SimpleDialogOption(
                onPressed: () => Navigator.of(context).pop(status),
                child: Row(
                  children: [
                    Icon(
                      order.status == status
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_unchecked_rounded,
                    ),
                    const SizedBox(width: 12),
                    Text(status),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
    if (status == null || status == order.status || !context.mounted) {
      return;
    }

    final success = await provider.setOrderStatus(order.id, status);
    if (!context.mounted) {
      return;
    }
    _showSnack(
      context,
      success
          ? 'Orden actualizada a $status.'
          : 'No fue posible actualizar la orden.',
      error: !success,
    );
  }

  Future<void> _cancelOrder(
    BuildContext context,
    AdminDashboardProvider provider,
    AdminOrderRecord order,
  ) async {
    final confirmed = await showAdminConfirmationDialog(
      context,
      title: 'Cancelar orden',
      message: 'La orden ${order.id} pasara al estado Cancelada.',
      confirmLabel: 'Cancelar orden',
      destructive: true,
    );
    if (!confirmed || !context.mounted) {
      return;
    }

    final success = await provider.cancelOrder(order.id);
    if (!context.mounted) {
      return;
    }
    _showSnack(
      context,
      success ? 'Orden cancelada.' : 'No fue posible cancelar la orden.',
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
