import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:melegna_customer/app/theme.dart';
import 'package:melegna_customer/data/network/graphql_config.dart';
import 'package:melegna_customer/data/network/graphql_datasource.dart';
import 'package:melegna_customer/domain/business/business.usecase.dart';
import 'package:melegna_customer/domain/business/repo/business_repository.dart';
import 'package:melegna_customer/presentation/ui/shared/icon_btn.dart';
import 'package:melegna_customer/presentation/utils/button_style.dart';
import 'package:melegna_customer/services/routing_service.dart';

class MelegnaCustomerApp extends StatelessWidget {
  const MelegnaCustomerApp._();

  static const MelegnaCustomerApp instance = MelegnaCustomerApp._();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Melegna',
      theme: AppThemeManager.getInstance(context).getLightTheme(),
      darkTheme: AppThemeManager.getInstance(context).getDarkTheme(),
      themeMode: ThemeMode.dark,
      localizationsDelegates: const [
        // AppLocalizations.delegate, // Add this line
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const <Locale>[
        Locale('en', ''), // English, no country code
        Locale('am', ''), // Amharic, no country code
      ],
      routerConfig: GoRouterService.routes,
    );
  }
}
