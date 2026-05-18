import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/admin_dashboard_provider.dart';
import '../widgets/admin_chart_card.dart';
import '../widgets/admin_data_table.dart';
import '../widgets/admin_filter_bar.dart';
import '../widgets/admin_page_header.dart';
import '../widgets/admin_stat_card.dart';
import '../widgets/admin_status_chip.dart';

class AdminReportsScreen extends StatelessWidget {
  const AdminReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminDashboardProvider>();
    final date = DateFormat('dd MMM yyyy');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AdminPageHeader(
          title: 'Reportes y Estadisticas',
          subtitle: 'Analisis del rendimiento de la plataforma ServiMarket.',
          actions: [
            const AdminHeaderButton(
              label: 'Filtrar por fecha',
              icon: Icons.date_range_rounded,
            ),
            const AdminHeaderButton(
              label: 'Exportar PDF',
              icon: Icons.picture_as_pdf_rounded,
            ),
            const AdminHeaderButton(
              label: 'Exportar Excel',
              icon: Icons.table_chart_rounded,
            ),
            AdminHeaderButton(
              label: 'Exportar CSV',
              icon: Icons.download_rounded,
              primary: true,
              onPressed: () => _downloadCsv(context, provider),
            ),
          ],
        ),
        const SizedBox(height: 22),
        AdminFilterBar(
          filters: [
            AdminSelectFilter(
              value: provider.reportDateFilter,
              items: provider.reportDateOptions,
              onChanged: provider.setReportDateFilter,
            ),
            ...provider.orderStatusOptions.map(
              (status) => AdminFilterChip(
                label: status,
                selected: provider.reportStatusFilter == status,
                onTap: () => provider.setReportStatusFilter(status),
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        if (provider.isBusy) ...[
          const LinearProgressIndicator(minHeight: 2),
          const SizedBox(height: 12),
        ],
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 1200
                ? 4
                : constraints.maxWidth >= 760
                ? 2
                : 1;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: provider.reportMetrics.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                mainAxisExtent: 176,
                crossAxisSpacing: 18,
                mainAxisSpacing: 18,
              ),
              itemBuilder: (context, index) =>
                  AdminStatCard(metric: provider.reportMetrics[index]),
            );
          },
        ),
        const SizedBox(height: 22),
        _ReportCharts(provider: provider),
        const SizedBox(height: 22),
        AdminDataTable(
          columns: const [
            'ID Transaccion',
            'Servicio',
            'Cliente',
            'Fecha',
            'Monto',
            'Estado',
          ],
          rows: provider.filteredReportOrders
              .map(
                (order) => AdminTableRow([
                  Text('#${order.id.toUpperCase()}'),
                  Text(order.serviceName),
                  Text(order.clientName),
                  Text(date.format(order.date)),
                  Text(provider.formatMoney(order.total)),
                  AdminStatusChip(
                    label: order.status,
                    color: provider.statusColor(order.status),
                  ),
                ]),
              )
              .toList(),
        ),
      ],
    );
  }

  static Future<void> _downloadCsv(
    BuildContext context,
    AdminDashboardProvider provider,
  ) async {
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
  }
}

class _ReportCharts extends StatelessWidget {
  const _ReportCharts({required this.provider});

  final AdminDashboardProvider provider;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 1180;
        final charts = [
          AdminChartCard(
            title: 'Crecimiento semanal',
            subtitle: 'Semana actual vs anterior.',
            points: provider.filteredReportPoints,
            type: AdminChartType.line,
          ),
          AdminChartCard(
            title: 'Ingresos por dia',
            subtitle: 'Volumen comparativo por jornada.',
            points: provider.filteredReportPoints,
            type: AdminChartType.bar,
          ),
          AdminChartCard(
            title: 'Ordenes por estado',
            subtitle: 'Distribucion segun filtros aplicados.',
            segments: provider.reportOrderStatusSegments,
            type: AdminChartType.pie,
          ),
        ];

        if (!wide) {
          return Column(
            children: charts
                .map(
                  (chart) => Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: chart,
                  ),
                )
                .toList(),
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: charts[0]),
            const SizedBox(width: 18),
            Expanded(child: charts[1]),
            const SizedBox(width: 18),
            Expanded(child: charts[2]),
          ],
        );
      },
    );
  }
}
