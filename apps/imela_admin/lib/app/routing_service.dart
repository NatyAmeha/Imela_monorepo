import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:imela_admin/ui/dashboard/dashboard_page.dart';
import 'package:injectable/injectable.dart';

import 'package:page_transition/page_transition.dart';

abstract class IRoutingService {
  Future<T?> navigateTo<T>(BuildContext context, String routeName, {Map<String, dynamic> queryParam, Map<String, dynamic>? extra, bool replace = false});
  Future<void> goBack(BuildContext context, {Map<String, dynamic>? returnValue = const {}});
}

@Injectable(as: IRoutingService)
@Named(GoRouterService.injectName)
class GoRouterService implements IRoutingService {
  static const injectName = 'GoRouterService';
  static const injectNameBeta = 'GoRouterServiceBeta';
  static GoRouterService? instance;
  static final navigatorKey = GlobalKey<NavigatorState>();
  static String PREVIOUS_PAGE_KEY = 'PREVIOUS_PAGE_KEY';

  GoRouterService._();

  factory GoRouterService() {
    instance ??= GoRouterService._();
    return instance!;
  }
  static final customNavigatorObserver = CustomNavigatorObserver();

  // Access the previous route
  static Widget? previousWidget;

  static final GoRouter routes = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: DashboardPage.routeName,
    redirect: (context, state) async {},
    observers: [customNavigatorObserver],
    routes: [
      GoRoute(
        path: DashboardPage.routeName,
        builder: (context, state) => const DashboardPage(),
      ),
      
    ],
  );
  @override
  Future<T?> navigateTo<T>(BuildContext context, String path, {Map<String, dynamic> queryParam = const {}, Map<String, dynamic>? extra, bool replace = false}) async {
    if (replace) {
      context.go(Uri(path: path, queryParameters: queryParam).toString(), extra: extra);
      return await Future.value(null);
    }
    previousWidget = extra?[PREVIOUS_PAGE_KEY] as Widget?;
    final result = await context.push<T>(path, extra: extra);
    return result;
  }

  @override
  Future<void> goBack(BuildContext context, {Map<String, dynamic>? returnValue = const {}}) async {
    context.pop<Map<String, dynamic>>(returnValue);
  }

  static Page buildPageWithCustomTransition(GoRouterState state, Widget child, {PageTransitionType? transitionType, Widget? previousScreen}) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      name: state.name,
      child: child,
      arguments: state.extra,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return PageTransition(
          child: child,
          type: transitionType ?? (previousScreen != null ? PageTransitionType.rightToLeftJoined : PageTransitionType.rightToLeft),
          maintainStateData: true,
          childCurrent: previousScreen,
          duration: const Duration(milliseconds: 300),
          reverseDuration: const Duration(milliseconds: 300),
          alignment: Alignment.center,
          ctx: context,
        ).buildTransitions(context, animation, secondaryAnimation, child);
      },
    );
  }
}

class CustomNavigatorObserver extends NavigatorObserver {
  final List<Route<dynamic>> _routeStack = [];

  CustomNavigatorObserver();

  Route<dynamic>? get previousRoute => _routeStack.length > 1 ? _routeStack[_routeStack.length - 2] : null;

  @override
  // void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) => print('didPush: ${route.str}, previousRoute= ${previousRoute?.settings.arguments?["prev"] as Widget?}');

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) => print('didPop: ${route.str}, previousRoute= ${previousRoute?.str}');

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) => print('didRemove: ${route.str}, previousRoute= ${previousRoute?.str}');

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) => print('didReplace: new= ${newRoute?.str}, old= ${oldRoute?.str}');

  @override
  void didStartUserGesture(
    Route<dynamic> route,
    Route<dynamic>? previousRoute,
  ) =>
      print('didStartUserGesture: ${route.str}, '
          'previousRoute= ${previousRoute?.str}');

  @override
  void didStopUserGesture() => print('didStopUserGesture');
}

extension on Route<dynamic> {
  String get str => 'route(${settings.name}: ${settings.arguments})';
}
