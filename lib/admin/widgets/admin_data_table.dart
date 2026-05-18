import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';

import '../core/admin_colors.dart';

class AdminTableRow {
  const AdminTableRow(this.cells);

  final List<Widget> cells;
}

class AdminDataTable extends StatelessWidget {
  const AdminDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.minWidth = 760,
  });

  final List<String> columns;
  final List<AdminTableRow> rows;
  final double minWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 420,
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: rows.isEmpty
            ? const Center(
                child: Text(
                  'No hay resultados para los filtros seleccionados.',
                  style: TextStyle(
                    color: AdminColors.textMuted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              )
            : DataTable2(
                minWidth: minWidth,
                dividerThickness: 0.8,
                headingRowColor: WidgetStateProperty.all(
                  AdminColors.surfaceLow,
                ),
                headingTextStyle: const TextStyle(
                  color: AdminColors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
                dataTextStyle: const TextStyle(
                  color: AdminColors.text,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                dataRowHeight: 68,
                columnSpacing: 18,
                horizontalMargin: 22,
                columns: columns
                    .map(
                      (column) => DataColumn2(
                        label: Text(column.toUpperCase()),
                        size: column == 'Acciones'
                            ? ColumnSize.L
                            : ColumnSize.M,
                      ),
                    )
                    .toList(),
                rows: rows
                    .map(
                      (row) => DataRow(
                        cells: row.cells
                            .map(
                              (cell) => DataCell(
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: cell,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    )
                    .toList(),
              ),
      ),
    );
  }
}
