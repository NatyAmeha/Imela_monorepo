import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';
import 'package:melegna_customer/presentation/ui/business/business_details.page.dart';
import 'package:melegna_customer/presentation/ui/home/home.page.dart';
import 'package:melegna_customer/presentation/ui/product/product_details.page.dart';

abstract class IRoutingService {
  Future<T?> navigateTo<T>(BuildContext context, String routeName, {Map<String, dynamic> queryParam, Map<String,dynamic>? extra, bool replace = false});
  Future<void> goBack(BuildContext context, {Map<String, dynamic>? returnValue = const {}});
}

@Injectable(as: IRoutingService)
@Named(GoRouterService.injectName)
class GoRouterService implements IRoutingService {
  static const injectName = 'GoRouterService';
  static GoRouterService? instance;
  static final navigatorKey = GlobalKey<NavigatorState>();

  const GoRouterService._();

  factory GoRouterService() {
    instance ??= const GoRouterService._();
    return instance!;
  }

  static GoRouter routes = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: HomePage.routeName,
    redirect: (context, state) async {},
    routes: [
      GoRoute(
        path: HomePage.routeName,
        builder: (context, state) => HomePage(),
      ),
      GoRoute(
        path: BusinessDetailsPage.routeName,
        builder: (context, state) {
          final businessId = state.pathParameters[BusinessDetailsPage.idQueryParameter];
          final businessName = (state.extra as Map<String, dynamic>)['name'];
          return BusinessDetailsPage(businessId: businessId!, businessName: businessName);
        },
      ),
      GoRoute(path: ProductDetailPage.routeName, builder: (context, state){
        final productId = state.pathParameters["id"];
        final productName = (state.extra as Map<String, dynamic>)['name'];
        return ProductDetailPage(productId: productId!, productName: productName);
      
      }),
    ],
  );
  @override
  Future<T?> navigateTo<T>(BuildContext context, String path, {Map<String, dynamic> queryParam = const {}, Map<String,dynamic>? extra, bool replace = false}) async {
    if (replace) {
      context.go(Uri(path: path, queryParameters : queryParam).toString(), extra: extra);
      return await Future.value(null);
    }
    final result = await context.push<T>(path, extra: extra);
    return result;
  }

  @override
  Future<void> goBack(BuildContext context, {Map<String, dynamic>? returnValue = const {}}) async {
    context.pop<Map<String, dynamic>>(returnValue);
  }
}
