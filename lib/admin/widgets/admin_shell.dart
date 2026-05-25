import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/admin_colors.dart';
import '../core/admin_theme.dart';
import '../services/admin_session_service.dart';
import 'admin_sidebar.dart';
import 'admin_top_bar.dart';

class AdminShell extends StatelessWidget {
  const AdminShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AdminTheme.light,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 1100;
          final tablet = constraints.maxWidth < 820;
          final contentPadding = tablet
              ? const EdgeInsets.all(18)
              : const EdgeInsets.fromLTRB(32, 28, 32, 36);

          return Scaffold(
            backgroundColor: AdminColors.background,
            drawer: tablet
                ? const Drawer(child: AdminSidebar(compact: false))
                : null,
            body: Row(
              children: [
                if (!tablet) AdminSidebar(compact: compact),
                Expanded(
                  child: Column(
                    children: [
                      if (tablet)
                        Builder(
                          builder: (context) => AppBar(
                            title: const Text('ServiMarket Admin'),
                            actions: [
                              const Padding(
                                padding: EdgeInsets.only(right: 12),
                                child: CircleAvatar(
                                  radius: 16,
                                  backgroundColor: AdminColors.primary,
                                  child: Text(
                                    'A',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                tooltip: 'Cerrar sesion',
                                onPressed: () async {
                                  await AdminSessionService().signOut();
                                  if (context.mounted) {
                                    context.go('/login');
                                  }
                                },
                                icon: const Icon(Icons.logout_rounded),
                              ),
                              const SizedBox(width: 8),
                            ],
                            leading: IconButton(
                              icon: const Icon(Icons.menu_rounded),
                              onPressed: () =>
                                  Scaffold.of(context).openDrawer(),
                            ),
                          ),
                        )
                      else
                        const AdminTopBar(),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: contentPadding,
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 1640),
                              child: child,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
