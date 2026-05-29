import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:servi_sur/features/admin/domain/entities/admin_metric.dart';
import 'package:servi_sur/features/admin/presentation/providers/admin_dashboard_provider.dart';
import 'package:servi_sur/features/admin/presentation/widgets/admin_chart_card.dart';
import 'package:servi_sur/features/admin/presentation/widgets/admin_data_table.dart';
import 'package:servi_sur/features/admin/presentation/widgets/admin_page_header.dart';
import 'package:servi_sur/features/admin/presentation/widgets/admin_stat_card.dart';
import 'package:servi_sur/features/admin/presentation/widgets/admin_status_chip.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminDashboardProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AdminPageHeader(
          title: 'Panel de Control',
          subtitle: 'Bienvenido de nuevo, aqui tienes el resumen de hoy.',
          actions: [
            AdminHeaderButton(
              label: 'Exportar',
              icon: Icons.download_rounded,
              primary: true,
            ),
          ],
        ),
        const SizedBox(height: 24),
        const _QuickActions(),
        const SizedBox(height: 24),
        _MetricGrid(metrics: provider.dashboardMetrics),
        const SizedBox(height: 24),
        _ChartGrid(provider: provider),
        const SizedBox(height: 24),
        AdminDataTable(
          columns: const ['Fecha', 'Usuario', 'Accion', 'Estado', 'Detalles'],
          rows: provider.recentActivity
              .map(
                (activity) => AdminTableRow([
                  Text(activity.time),
                  Text(activity.user),
                  Text(activity.action),
                  AdminStatusChip(
                    label: activity.status,
                    color: provider.statusColor(activity.status),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.visibility_rounded),
                  ),
                ]),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    final actions = [
      _QuickAction('Usuarios', Icons.group_rounded, '/admin/users'),
      _QuickAction(
        'Servicios',
        Icons.design_services_rounded,
        '/admin/services',
      ),
      _QuickAction('Ordenes', Icons.receipt_long_rounded, '/admin/orders'),
      _QuickAction('Reportes', Icons.bar_chart_rounded, '/admin/reports'),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1100
            ? 4
            : constraints.maxWidth >= 680
            ? 2
            : 1;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: actions.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisExtent: 76,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
          ),
          itemBuilder: (context, index) {
            final action = actions[index];
            return FilledButton.icon(
              onPressed: () => context.go(action.route),
              icon: Icon(action.icon),
              label: Text(action.label),
            );
          },
        );
      },
    );
  }
}

class _QuickAction {
  const _QuickAction(this.label, this.icon, this.route);

  final String label;
  final IconData icon;
  final String route;
}

class _ChartGrid extends StatelessWidget {
  const _ChartGrid({required this.provider});

  final AdminDashboardProvider provider;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final twoColumns = constraints.maxWidth >= 980;
        final charts = [
          AdminChartCard(
            title: 'Ingresos semanales',
            subtitle: 'Semana actual vs anterior.',
            points: provider.reportPoints,
            type: AdminChartType.line,
          ),
          AdminChartCard(
            title: 'Ordenes por dia',
            subtitle: 'Volumen operativo reciente.',
            points: provider.reportPoints,
            type: AdminChartType.bar,
          ),
          AdminChartCard(
            title: 'Estado de ordenes',
            subtitle: 'Distribucion actual de operaciones.',
            segments: provider.orderStatusSegments,
            type: AdminChartType.pie,
          ),
        ];

        if (!twoColumns) {
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

        return Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: charts[0]),
                const SizedBox(width: 18),
                Expanded(child: charts[1]),
              ],
            ),
            const SizedBox(height: 18),
            charts[2],
          ],
        );
      },
    );
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.metrics});

  final List<AdminMetric> metrics;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 1200
            ? 4
            : width >= 760
            ? 2
            : 1;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: metrics.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 18,
            mainAxisSpacing: 18,
            mainAxisExtent: 176,
          ),
          itemBuilder: (context, index) =>
              AdminStatCard(metric: metrics[index]),
        );
      },
    );
  }
}
