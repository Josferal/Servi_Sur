import 'package:flutter/material.dart';

class AdminTableActions extends StatelessWidget {
  const AdminTableActions({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Wrap(spacing: 2, runSpacing: 2, children: children);
  }
}

class AdminTableActionButton extends StatelessWidget {
  const AdminTableActionButton({
    super.key,
    required this.tooltip,
    required this.icon,
    this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon, size: 19),
      constraints: const BoxConstraints.tightFor(width: 36, height: 36),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }
}
