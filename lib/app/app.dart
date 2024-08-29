import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:imela/app/theme.dart';
import 'package:imela/services/routing_service.dart';

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
      themeMode: ThemeMode.light,
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
