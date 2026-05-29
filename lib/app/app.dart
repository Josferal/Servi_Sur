import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:servi_sur/app/providers/app_provider.dart';
import 'package:servi_sur/app/router/app_router.dart';
import 'package:servi_sur/app/theme/app_theme.dart';
import 'package:servi_sur/features/admin/data/repositories/firebase_admin_repository.dart';
import 'package:servi_sur/features/admin/domain/repositories/admin_repository.dart';
import 'package:servi_sur/features/admin/presentation/providers/admin_dashboard_provider.dart';
import 'package:servi_sur/features/order/presentation/providers/cart_provider.dart';
import 'package:servi_sur/shared/data/repositories/firebase_marketplace_repository.dart';
import 'package:servi_sur/shared/domain/repositories/marketplace_repository.dart';

class ServiSurApp extends StatelessWidget {
  const ServiSurApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<FirebaseMarketplaceRepository>(
          create: (_) => FirebaseMarketplaceRepository(),
        ),
        ProxyProvider<FirebaseMarketplaceRepository, MarketplaceRepository>(
          update: (context, repository, previous) => repository,
        ),
        ProxyProvider<MarketplaceRepository, AdminRepository>(
          update: (context, repository, previous) =>
              FirebaseAdminRepository(repository),
        ),
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProxyProvider<MarketplaceRepository, CartProvider>(
          create: (context) =>
              CartProvider(context.read<MarketplaceRepository>()),
          update: (context, repository, provider) =>
              provider!..updateRepository(repository),
        ),
        ChangeNotifierProxyProvider<AdminRepository, AdminDashboardProvider>(
          create: (context) =>
              AdminDashboardProvider(context.read<AdminRepository>()),
          update: (context, repository, provider) =>
              provider!..updateRepository(repository),
        ),
      ],
      child: MaterialApp.router(
        title: 'Servi Sur',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
