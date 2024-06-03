import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:melegna_customer/app/app.dart';

class AppRoutes {
  static final navigatorKey = GlobalKey<NavigatorState>();
  static GoRouter routes = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const MyHomePage(title: 'Melegna Customer App'),
      ),
    ],
  );
}
