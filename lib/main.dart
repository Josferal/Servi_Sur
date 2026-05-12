import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'providers/app_provider.dart';
import 'providers/cart_provider.dart';
import 'repositories/marketplace_repository.dart';
import 'repositories/mock_marketplace_repository.dart';
import 'routes/app_router.dart';

void main() {
  runApp(const ServiSurApp());
}

class ServiSurApp extends StatelessWidget {
  const ServiSurApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<MarketplaceRepository>(
          create: (_) => MockMarketplaceRepository(),
        ),
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProxyProvider<MarketplaceRepository, CartProvider>(
          create: (context) =>
              CartProvider(context.read<MarketplaceRepository>()),
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
