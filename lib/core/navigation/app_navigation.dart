import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

class AppNavigation {
  const AppNavigation._();

  static void popOrFallback(
    BuildContext context, {
    String fallbackRoute = '/home',
  }) {
    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go(fallbackRoute);
  }
}
