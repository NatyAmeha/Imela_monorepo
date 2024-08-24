import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';
import 'package:melegna_customer/domain/order/model/cart.model.dart';
import 'package:melegna_customer/domain/product/model/product.model.dart' as AppProduct;
import 'package:melegna_customer/presentation/ui/authentication/auth_selection_page.dart';
import 'package:melegna_customer/presentation/ui/authentication/phone_login_page.dart';
import 'package:melegna_customer/presentation/ui/authentication/phone_verify_page.dart';
import 'package:melegna_customer/presentation/ui/bundle/bundle_detail/bundle_detail.page.dart';
import 'package:melegna_customer/presentation/ui/business/business_details.page.dart';
import 'package:melegna_customer/presentation/ui/cart/cart_detail_page.dart';
import 'package:melegna_customer/presentation/ui/cart/cart_list_page.dart';
import 'package:melegna_customer/presentation/ui/cart/order_configure/order_configure_page.dart';
import 'package:melegna_customer/presentation/ui/home/home.page.dart';
import 'package:melegna_customer/presentation/ui/order/order_confirmation/order_confirmation_page.dart';
import 'package:melegna_customer/presentation/ui/order/order_details/order_details_page.dart';
import 'package:melegna_customer/presentation/ui/order/order_list/order_list_page.dart';
import 'package:melegna_customer/presentation/ui/product/product_details/product_details.page.dart';
import 'package:melegna_customer/presentation/ui/product/product_list/product_list_page.dart';
import 'package:melegna_customer/presentation/ui/shared/list/list_display_style.constants.dart';
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
    initialLocation: HomePage.routeName,
    redirect: (context, state) async {},
    observers: [customNavigatorObserver],
    routes: [
      GoRoute(
        path: HomePage.routeName,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: BusinessDetailsPage.routeName,
        pageBuilder: (context, state) {
          final businessId = state.pathParameters[BusinessDetailsPage.idQueryParameter];
          final arguments = state.extra as Map<String, dynamic>;
          final businessName = arguments['name'] as String?;
          final prevScreen = arguments[GoRouterService.PREVIOUS_PAGE_KEY] as Widget?;

          return buildPageWithCustomTransition(state, BusinessDetailsPage(businessId: businessId!, businessName: businessName), previousScreen: prevScreen);
        },
      ),
      GoRoute(
        path: ProductDetailPage.routeName,
        pageBuilder: (context, state) {
          // ignore: prefer_single_quotes

          final productId = state.pathParameters["id"];
          final arguments = state.extra as Map<String, dynamic>;
          final productName = arguments['name'];
          final prevScreen = arguments[GoRouterService.PREVIOUS_PAGE_KEY] as Widget?;
          return buildPageWithCustomTransition(state, ProductDetailPage(productId: productId!, productName: productName), previousScreen: prevScreen);
        },
      ),
      GoRoute(
        path: ProductListPage.routeName,
        pageBuilder: (context, state) {
          final title = (state.extra as Map<String, dynamic>)['title'];
          final arguments = state.extra as Map<String, dynamic>;
          final prevScreen = arguments[GoRouterService.PREVIOUS_PAGE_KEY] as Widget?;
          final List<AppProduct.Product>? products = arguments['products'];
          final ListDisplayStyle displayStyle = arguments['displayStyle'];
          return buildPageWithCustomTransition(state, ProductListPage(products: products, title: title, displayStyle: displayStyle), previousScreen: prevScreen);
        },
      ),
      GoRoute(
        path: BundleDetailPage.routeName,
        pageBuilder: (context, state) {
          final bundleId = state.pathParameters[BundleDetailPage.idQueryKey];
          final arguments = state.extra as Map<String, dynamic>;
          final prevScreen = arguments[GoRouterService.PREVIOUS_PAGE_KEY] as Widget?;
          final bundleName = arguments[BundleDetailPage.nameQueryKey];
          return buildPageWithCustomTransition(state, BundleDetailPage(id: bundleId!, bundleName: bundleName), previousScreen: prevScreen);
        },
      ),
      GoRoute(
        path: CartListPage.routeName,
        pageBuilder: (context, state) {
          return buildPageWithCustomTransition(state, CartListPage());
        },
      ),
      GoRoute(
        path: CartDetailPage.routeName,
        pageBuilder: (context, state) {
          final arguments = state.extra as Map<String, dynamic>;
          final Cart cartInfo = arguments[CartDetailPage.CART_DATA];
          return buildPageWithCustomTransition(state, CartDetailPage(selectedCart: cartInfo));
        },
      ),
      GoRoute(
        path: OrderConfigurePage.routeName,
        pageBuilder: (context, state) {
          final arguments = state.extra as Map<String, dynamic>;
          final Cart cartInfo = arguments['cart'];
          return buildPageWithCustomTransition(state, OrderConfigurePage(cartInfo: cartInfo));
        },
      ),
      GoRoute(
        path: OrderConfirmationPage.routeName,
        pageBuilder: (context, state) {
          final arguments = state.extra as Map<String, dynamic>;
          return buildPageWithCustomTransition(state, OrderConfirmationPage());
        },
      ),
      GoRoute(
        path: OrderListPage.routeName,
        pageBuilder: (context, state) {
          return buildPageWithCustomTransition(state, OrderListPage());
        },
      ),
      GoRoute(
        path: OrderDetailPage.routeName,
        pageBuilder: (context, state) {
          final arguments = state.extra as Map<String, dynamic>;
          final orderId = state.pathParameters['id'] as String;
          return buildPageWithCustomTransition(state, OrderDetailPage(ORderId: orderId));
        },
      ),
      GoRoute(
        path: AuthSelectionPage.routeName,
        pageBuilder: (context, state) {
          final arguments = state.extra as Map<String, dynamic>?;
          final redirectUrl = arguments?[AuthSelectionPage.REDIRECT_URL_KEY] as String?;
          return buildPageWithCustomTransition(
              state,
              AuthSelectionPage(
                redirectionRoute: redirectUrl,
              ));
        },
      ),
      GoRoute(
        path: PhoneLoginPage.routeName,
        pageBuilder: (context, state) {
          return buildPageWithCustomTransition(state, PhoneLoginPage());
        },
      ),
      GoRoute(
        path: PhoneVerifyPage.routeName,
        pageBuilder: (context, state) {
          return buildPageWithCustomTransition(state, PhoneVerifyPage());
        },
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
