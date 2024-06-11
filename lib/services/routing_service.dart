import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:melegna_customer/presentation/ui/business/business_details.page.dart';

abstract class IRoutingService {
  Future<T?> navigateTo<T>(BuildContext context, String routeName, {Map<String, dynamic> arguments, bool replace = false});
  Future<void> goBack(BuildContext context, {Map<String, dynamic>? returnValue = const {}});
}

class GoRouterService implements IRoutingService {
  static final navigatorKey = GlobalKey<NavigatorState>();
  static GoRouter routes = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/',
    redirect: (context, state) async {
      
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) =>  BusinessDetailsPage(),
      ),
    ],
  );
  @override
  Future<T?> navigateTo<T>(BuildContext context, String routeName, {Map<String, dynamic> arguments = const {}, bool replace = false}) async {
    if (replace) {
      context.go(Uri(path: routeName, queryParameters: arguments).toString());
      return await Future.value(null);
    }
    final result = await context.pushNamed<T>(routeName, queryParameters: arguments);
    return result;
  }

  @override
  Future<void> goBack(BuildContext context, {Map<String, dynamic>? returnValue = const {}}) async {
    context.pop<Map<String, dynamic>>(returnValue);
  }
}
