import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:imela/presentation/ui/app_controller.dart';
import 'theme.dart';
import '../services/routing_service.dart';

class MelegnaCustomerApp extends StatefulWidget {
  const MelegnaCustomerApp._();

  static const MelegnaCustomerApp instance = MelegnaCustomerApp._();

  static _MelegnaCustomerAppState? of(BuildContext context) => context.findAncestorStateOfType<_MelegnaCustomerAppState>();

  @override
  State<MelegnaCustomerApp> createState() => _MelegnaCustomerAppState();
}

class _MelegnaCustomerAppState extends State<MelegnaCustomerApp> {
  Locale? _appLocale;
  var appController = AppController.getInstance;

  // Method to update locale dynamically
  void setLocale(Locale locale) {
    setState(() {
      _appLocale = locale;
    });
  }

  @override
  void initState() {
    super.initState();
    appController.router.handleDeepLinks((Uri uri) {
      print('uri $uri');
      appController.router.navigateTo(context, uri.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Imela',
      theme: AppThemeManager.getInstance(context).getLightTheme(),
      darkTheme: AppThemeManager.getInstance(context).getDarkTheme(),
      themeMode: ThemeMode.light,
      locale: _appLocale,
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
