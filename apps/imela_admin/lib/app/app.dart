import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:imela_admin/app/routing_service.dart';
import 'package:imela_admin/app/theme.dart';
import 'package:imela_admin/l10n/l10n.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Imela_Admin',
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch, PointerDeviceKind.stylus, PointerDeviceKind.unknown},
      ),
      theme: AppThemeManager.getInstance(context).getLightTheme(),
      darkTheme: AppThemeManager.getInstance(context).getDarkTheme(),
      themeMode: ThemeMode.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: GoRouterService.routes,
    );
  }
}
