import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:imela/presentation/ui/business/business_section/business_section_page.dart';
import 'package:imela/presentation/ui/location_selector/location_selector_page.dart';
import 'package:imela/presentation/ui/loyalty/pages/loyalty_details_page.dart';
import 'package:imela/presentation/ui/loyalty/pages/loyalty_list_page.dart';
import 'package:imela/presentation/ui/membership/membership_detail/membership_confirmation_page.dart';
import 'package:imela/presentation/ui/membership/membership_detail/membership_detail_page.dart';
import 'package:imela/presentation/ui/membership/membership_detail/membership_payment_page.dart';
import 'package:imela/presentation/ui/membership/membership_list/membership_list_page.dart';
import 'package:imela/presentation/ui/membership/membership_list/membership_list_viewmodel.dart';
import 'package:imela/presentation/ui/membership/membership_plan_list/membership_plan_list_page.dart';
import 'package:imela/presentation/ui/profile/profile_page.dart';
import 'package:imela/presentation/ui/profile/update_profile/update_profile_page.dart';
import 'package:imela_core/business/model/business.section.dart';
import 'package:imela_core/loyalty/dto/loyalty.response.dart';
import 'package:imela_core/product/model/discount.model.dart';
import 'package:imela_core/product/model/product.model.dart';
import 'package:injectable/injectable.dart';

import 'package:imela/presentation/ui/authentication/auth_selection_page.dart';
import 'package:imela/presentation/ui/authentication/phone_login_page.dart';
import 'package:imela/presentation/ui/authentication/phone_verify_page.dart';
import 'package:imela/presentation/ui/bundle/bundle_detail/bundle_detail.page.dart';
import 'package:imela/presentation/ui/business/business_details.page.dart';
import 'package:imela/presentation/ui/cart/cart_detail_page.dart';
import 'package:imela/presentation/ui/cart/cart_list_page.dart';
import 'package:imela/presentation/ui/cart/order_configure/order_configure_page.dart';
import 'package:imela/presentation/ui/home/home.page.dart';
import 'package:imela/presentation/ui/order/order_confirmation/order_confirmation_page.dart';
import 'package:imela/presentation/ui/order/order_details/order_details_page.dart';
import 'package:imela/presentation/ui/order/order_list/order_list_page.dart';
import 'package:imela/presentation/ui/product/product_details/product_details.page.dart';
import 'package:imela/presentation/ui/product/product_list/product_list_page.dart';
import 'package:imela/presentation/ui/shared/list/list_display_style.constants.dart';
import 'package:page_transition/page_transition.dart';
import 'package:imela_core/order/model/cart.model.dart';
import 'package:imela_core/order/model/order.model.dart' as OrderModel;

abstract class IRoutingService {
  Future<T?> navigateTo<T>(BuildContext context, String routeName, {Map<String, dynamic> queryParam, Map<String, dynamic>? extra, bool replace = false});
  Future<void> goBack(BuildContext context, {Map<String, dynamic>? returnValue = const {}});
  Future<void> goBackToStack(BuildContext context, String routeName, {Map<String, dynamic>? returnValue = const {}});
  StreamSubscription<Uri> handleDeepLinks(Function(Uri) onLinkReceived);
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

  // Access the previous route
  static Widget? previousWidget;

  static final GoRouter routes = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: HomePage.routeName,
    redirect: (context, state) async {
      return null;
    },
    observers: [],
    routes: [
      GoRoute(
        path: HomePage.routeName,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final reload = extra?['RELOAD_PAGE'] as bool? ?? false;
          return HomePage(reload: reload);
        },
      ),
      GoRoute(
        path: BusinessSectionPage.routeName,
        pageBuilder: (context, state) {
          final businessId = state.pathParameters[BusinessSectionPage.BUSINESS_ID_KEY];
          final sectionId = state.pathParameters[BusinessSectionPage.SECTION_ID_KEY];
          final arguments = state.extra as Map<String, dynamic>;
          final sectionInfo = arguments[BusinessSectionPage.SECTION_INFO_KEY] as BusinessSection;
          return buildPageWithCustomTransition(state, BusinessSectionPage(businessId: businessId!, sectionId: sectionId!, sectionInfo: sectionInfo));
        },
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
          final discounts = arguments['discounts'] as List<Discount>?;
          return buildPageWithCustomTransition(state, ProductDetailPage(productId: productId!, productName: productName, discounts: discounts));
        },
      ),
      GoRoute(
        path: ProductListPage.routeName,
        pageBuilder: (context, state) {
          final title = (state.extra as Map<String, dynamic>)['title'];
          final arguments = state.extra as Map<String, dynamic>;
          final prevScreen = arguments[GoRouterService.PREVIOUS_PAGE_KEY] as Widget?;
          final List<Product>? products = arguments['products'];
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
          final order = arguments[OrderConfirmationPage.ORDER_INFO_KEY] as OrderModel.Order;
          return buildPageWithCustomTransition(state, OrderConfirmationPage(order: order));
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
          final redirectExtra = arguments?[AuthSelectionPage.REDIRECT_EXTRA_KEY] as Map<String, dynamic>?;
          print('redirect url info $redirectExtra $redirectUrl');
          return buildPageWithCustomTransition(state, AuthSelectionPage(redirectionRoute: redirectUrl, redirectExtra: redirectExtra));
        },
      ),
      GoRoute(
        path: PhoneLoginPage.routeName,
        pageBuilder: (context, state) {
          return buildPageWithCustomTransition(state, PhoneLoginPage());
        },
      ),
      GoRoute(
        path: UpdateProfilePage.routeName,
        pageBuilder: (context, state) {
          final arguments = state.extra as Map<String, dynamic>;
          final redirectUrl = arguments[UpdateProfilePage.REDIRECT_URL_KEY] as String;
          final redirectExtra = arguments[UpdateProfilePage.REDIRECT_EXTRA_KEY] as Map<String, dynamic>?;
          return buildPageWithCustomTransition(state, UpdateProfilePage(redirectUrl: redirectUrl, redirectExtra: redirectExtra));
        },
      ),
      GoRoute(
        path: ProfilePage.routeName,
        pageBuilder: (context, state) {
          return buildPageWithCustomTransition(state, ProfilePage());
        },
      ),
      GoRoute(
        path: PhoneVerifyPage.routeName,
        pageBuilder: (context, state) {
          return buildPageWithCustomTransition(state, PhoneVerifyPage());
        },
      ),
      GoRoute(
        path: LoyaltyListPage.routeName,
        pageBuilder: (context, state) {
          return buildPageWithCustomTransition(state, const LoyaltyListPage());
        },
      ),
      GoRoute(
        path: LoyaltyDetailsPage.routeName,
        pageBuilder: (context, state) {
          final arguments = state.extra as Map<String, dynamic>;
          final loyaltyInfo = arguments[LoyaltyDetailsPage.LOYALTY_INFO_KEY] as LoyaltyResponse?;
          final programName = arguments[LoyaltyDetailsPage.PROGRAM_NAME_KEY] as String;
          final businessId = arguments[LoyaltyDetailsPage.BUSINESS_ID_KEY] as String?;
          return buildPageWithCustomTransition(state, LoyaltyDetailsPage(loyaltyInfo: loyaltyInfo, programName: programName, businessId: businessId));
        },
      ),
      GoRoute(
        path: MembershipPlanListPage.routeName,
        pageBuilder: (context, state) {
          final arguments = state.extra as Map<String, dynamic>;
          final businessId = arguments[MembershipPlanListPage.BUSINESS_ID_KEY] as String;
          return buildPageWithCustomTransition(state, MembershipPlanListPage(businessId: businessId));
        },
      ),
      GoRoute(
        path: MembershipDetailsPage.routeName,
        name: MembershipDetailsPage.routeName,
        pageBuilder: (context, state) {
          final arguments = state.extra as Map<String, dynamic>;
          final membershipId = arguments[MembershipDetailsPage.MEMBERSHIP_ID_KEY] as String;
          return buildPageWithCustomTransition(state, MembershipDetailsPage(membershipId: membershipId));
        },
      ),
      GoRoute(
        path: MembershipConfirmationPage.routeName,
        pageBuilder: (context, state) {
          final arguments = state.extra as Map<String, dynamic>;
          final membershipId = arguments[MembershipConfirmationPage.MEMBERSHIP_ID_KEY] as String;
          return buildPageWithCustomTransition(state, MembershipConfirmationPage(membershipId: membershipId));
        },
      ),
      GoRoute(
        path: MembershipPaymentPage.routeName,
        pageBuilder: (context, state) {
          return buildPageWithCustomTransition(state, const MembershipPaymentPage());
        },
      ),
      GoRoute(
        path: UserMembershipListPage.routeName,
        pageBuilder: (context, state) {
          final arguments = state.extra as Map<String, dynamic>;
          String membershipListType = arguments[UserMembershipListPage.MEMBERSHIP_LIST_TYPE_KEY] ?? MembershipListType.USER_MEMBERSHIP.name;
          return buildPageWithCustomTransition(state, UserMembershipListPage(membershipListType: membershipListType));
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

  @override
  Future<void> goBackToStack(BuildContext context, String routeName, {Map<String, dynamic>? returnValue = const {}}) async {
    // Continue popping routes until the target route is reached

    while (true) {
      final currentPath = GoRouterState.of(context).uri?.toString();
      print('popping  $currentPath');
      if (!context.canPop() || (currentPath?.startsWith(routeName) ?? false)) {
        // If no more routes can be popped, break the loop
        break;
      }
      context.pop<Map<String, dynamic>>(returnValue);
    }
  }

  @override
  StreamSubscription<Uri> handleDeepLinks(Function(Uri) onLinkReceived) {
    final _appLinks = AppLinks();
    final subscription = _appLinks.uriLinkStream.listen((Uri? link) {
      if (link != null) {
        print('Received link: $link');
        onLinkReceived(link);
      } else {
        print('No link received');
      }
    }, onError: (err) {
      print('Failed to receive link: $err');
    });
    return subscription;
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
