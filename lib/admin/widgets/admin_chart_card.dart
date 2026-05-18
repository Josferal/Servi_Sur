import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../core/admin_colors.dart';
import '../models/admin_chart_segment.dart';
import '../models/admin_report_point.dart';

enum AdminChartType { line, bar, pie }

class AdminChartCard extends StatelessWidget {
  const AdminChartCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.points = const [],
    this.segments = const [],
    this.type = AdminChartType.line,
  });

  final String title;
  final String subtitle;
  final List<AdminReportPoint> points;
  final List<AdminChartSegment> segments;
  final AdminChartType type;

  @override
  Widget build(BuildContext context) {
    return Container(
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
          const SizedBox(height: 4),
          Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              return SizedBox(
                height: constraints.maxWidth < 460 ? 300 : 260,
                child: _chart(constraints.maxWidth),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _chart(double width) {
    return switch (type) {
      AdminChartType.line => _lineChart(),
      AdminChartType.bar => _barChart(),
      AdminChartType.pie => _pieChart(width),
    };
  }

  Widget _lineChart() {
    return LineChart(
      LineChartData(
        minY: 0,
        gridData: _grid(),
        borderData: FlBorderData(show: false),
        titlesData: _lineTitles(),
        lineBarsData: [
          _line(
            points.map((point) => point.current).toList(),
            AdminColors.primary,
          ),
          _line(
            points.map((point) => point.previous).toList(),
            AdminColors.blue,
          ),
        ],
      ),
    );
  }

  Widget _barChart() {
    return BarChart(
      BarChartData(
        minY: 0,
        gridData: _grid(),
        borderData: FlBorderData(show: false),
        titlesData: _lineTitles(),
        barGroups: List.generate(points.length, (index) {
          final point = points[index];
          return BarChartGroupData(
            x: index,
            barsSpace: 4,
            barRods: [
              BarChartRodData(
                toY: point.current,
                color: AdminColors.primary,
                width: 13,
                borderRadius: BorderRadius.circular(4),
              ),
              BarChartRodData(
                toY: point.previous,
                color: AdminColors.blue.withValues(alpha: 0.7),
                width: 13,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _pieChart(double width) {
    final total = segments.fold<double>(
      0,
      (sum, segment) => sum + segment.value,
    );
    final compact = width < 520;
    final chart = PieChart(
      PieChartData(
        sectionsSpace: 3,
        centerSpaceRadius: compact ? 36 : 48,
        sections: segments.map((segment) {
          final percent = total == 0 ? 0 : (segment.value / total) * 100;
          return PieChartSectionData(
            value: segment.value,
            color: segment.color,
            title: '${percent.round()}%',
            radius: compact ? 58 : 76,
            titleStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          );
        }).toList(),
      ),
    );
    final legend = _PieLegend(segments: segments);

    if (compact) {
      return Column(
        children: [
          Expanded(child: chart),
          const SizedBox(height: 12),
          legend,
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: chart),
        const SizedBox(width: 16),
        SizedBox(width: 150, child: legend),
      ],
    );
  }

  LineChartBarData _line(List<double> values, Color color) {
    return LineChartBarData(
      spots: List.generate(
        values.length,
        (index) => FlSpot(index.toDouble(), values[index]),
      ),
      isCurved: true,
      color: color,
      barWidth: 3,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        color: color.withValues(alpha: 0.08),
      ),
    );
  }

  FlGridData _grid() {
    return FlGridData(
      drawVerticalLine: false,
      getDrawingHorizontalLine: (_) => FlLine(
        color: AdminColors.outline.withValues(alpha: 0.35),
        strokeWidth: 1,
      ),
    );
  }

  FlTitlesData _lineTitles() {
    return FlTitlesData(
      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, _) {
            final index = value.toInt();
            if (index < 0 || index >= points.length) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                points[index].label,
                style: const TextStyle(
                  color: AdminColors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PieLegend extends StatelessWidget {
  const _PieLegend({required this.segments});

  final List<AdminChartSegment> segments;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: segments
          .map(
            (segment) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: segment.color,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${segment.label} (${segment.value.round()})',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AdminColors.textMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
