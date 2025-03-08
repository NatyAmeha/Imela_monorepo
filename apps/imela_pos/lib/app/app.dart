import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:imela_pos/app/app_constants.dart';
import 'package:imela_pos/app/routing_service.dart';
import 'package:imela_pos/app/theme.dart';
import 'package:imela_pos/app/app_viewmodel.dart';
import 'package:imela_pos/l10n/l10n.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      scaffoldMessengerKey: AppViewmodel.scaffoldMessengerKey,
      title: 'Imela_Admin',
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch, PointerDeviceKind.stylus, PointerDeviceKind.unknown},
      ),
      theme: AppThemeManager.getInstance(context).getLightTheme(),
      darkTheme: AppThemeManager.getInstance(context).getDarkTheme(),
      themeMode: ThemeMode.light,
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppConstants.supportedLocales,
      routerConfig: GoRouterService.routes,
      builder: (context, child) {
        // This ensures the scaffold messenger key has a valid context
        // that's connected to a Navigator
        return Scaffold(
          body: child,
        );
      },
    );
  }
}
