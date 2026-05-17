import 'package:flutter/material.dart';

class GroupHeader extends DataRow {
  GroupHeader({
    super.key,
    required String groupName,
    required Color backgroundColor,
    required Color textColor,
    required bool isCollapsed,
    VoidCallback? onToggle,
  }) : super(
          color: WidgetStateProperty.all(backgroundColor),
          onSelectChanged: onToggle == null ? null : (_) => onToggle(),
          cells: [
            DataCell(
              Icon(
                isCollapsed ? Icons.chevron_right : Icons.expand_more,
                color: textColor,
              ),
            ),
            DataCell(
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text(
                  groupName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
              placeholder: true,
            ),
            const DataCell(Text('')),
            const DataCell(Text('')),
            const DataCell(Text('')),
            const DataCell(Text('')),
          ],
        );
}
