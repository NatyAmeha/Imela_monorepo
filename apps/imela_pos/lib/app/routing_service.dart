import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:imela_core/calendar/model/calendar_booking.model.dart';
import 'package:imela_core/order/model/order_item.model.dart';
import 'package:imela_pos/ui/authentication/staff_signin.page.dart';
import 'package:imela_pos/ui/authentication/workspace_auth/workspace_auth.dart';
import 'package:imela_pos/ui/cart/component/cart_list_component.dart';
import 'package:imela_pos/ui/customer/customer_list_page.dart';
import 'package:imela_pos/ui/home/branch_selection_page.dart';
import 'package:imela_pos/ui/home/home_page.dart';
import 'package:imela_pos/ui/home/splash/splash_page.dart';
import 'package:imela_pos/ui/membership/components/pos_membership_details_component.dart';
import 'package:imela_pos/ui/membership/create_membership_page.dart';
import 'package:imela_pos/ui/membership/pos_membership_list_page.dart';
import 'package:imela_pos/ui/order/order_confirmation_page.dart';
import 'package:imela_pos/ui/order/order_details_page.dart';
import 'package:imela_pos/ui/order/order_list_page.dart';
import 'package:imela_pos/ui/order/schedule/create_schedule/create_schedule_page.dart';
import 'package:imela_pos/ui/order/schedule/order_schedule_page.dart';
import 'package:imela_pos/ui/payment/payment_page.dart';
import 'package:imela_pos/ui/search/search_list_page.dart';
import 'package:imela_pos/ui/section/section_page.dart';
import 'package:imela_pos/ui/staff/create_staff/create_staff_page.dart';
import 'package:imela_pos/ui/staff/staff_list/staff_list_page.dart';
import 'package:injectable/injectable.dart';
import 'package:imela_core/order/model/order.model.dart' as OrderModel;

import 'package:page_transition/page_transition.dart';
import 'package:imela_pos/ui/product/product_list_page.dart';
import 'package:imela_pos/ui/inventory/inventory_list_page.dart';
import 'package:imela_pos/ui/calendar/calendar_list_page.dart';
import 'package:imela_pos/ui/product_price/product_price_list_page.dart';
import 'package:imela_pos/ui/chat/chat_room_list_page.dart';

abstract class IRoutingService {
  Future<T?> navigateTo<T>(BuildContext context, String routeName, {Map<String, dynamic> queryParam, Map<String, dynamic>? extra, bool replace = false});
  Future<void> goBack(BuildContext context, {Map<String, dynamic>? returnValue = const {}});
  Future<void> goNamed(BuildContext context, String routeName, {Map<String, dynamic> queryParam, Map<String, dynamic>? extra, bool replace = false});
}

@Injectable(as: IRoutingService)
@Named(GoRouterService.injectName)
class GoRouterService implements IRoutingService {
  static const injectName = 'GoRouterService';
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
    initialLocation: SplashPage.routeName,
    redirect: (context, state) async {},
    observers: [customNavigatorObserver],
    routes: [
      GoRoute(path: SplashPage.routeName, builder: (context, state) => const SplashPage()),
      GoRoute(path: WorkspaceAuth.routeName, builder: (context, state) => const WorkspaceAuth()),
      GoRoute(path: POSStaffSignInPage.routeName, builder: (context, state) => const POSStaffSignInPage()),
      GoRoute(path: BranchSelectionPage.routeName, builder: (context, state) => const BranchSelectionPage()),
      GoRoute(path: HomePage.routeName, builder: (context, state) => const HomePage()),
      GoRoute(path: SearchListPage.routename, builder: (context, state) => const SearchListPage()),
      GoRoute(path: CartListPage.routeName, builder: (context, state) => const CartListPage()),
      GoRoute(path: PaymentPage.routeName, builder: (context, state) => const PaymentPage()),
      GoRoute(
        path: OrderConfirmationPage.routeName,
        builder: (context, state) {
          var arguments = state.extra as Map<String, dynamic>;
          var order = arguments[OrderConfirmationPage.orderKey] as OrderModel.Order?;
          return OrderConfirmationPage(order: order);
        },
      ),
      GoRoute(path: OrderListPage.routeName, builder: (context, state) => const OrderListPage()),
      GoRoute(path: OrderDetailsPage.routeName, builder: (context, state) => const OrderDetailsPage()),
      GoRoute(path: CustomerListPage.routeName, builder: (context, state) => const CustomerListPage()),
      GoRoute(path: OrderListPage.routeName, builder: (context, state) => const OrderListPage()),
      GoRoute(path: StaffListPage.routeName, builder: (context, state) => const StaffListPage()),
      GoRoute(path: CreateStaffPage.routeName, builder: (context, state) => const CreateStaffPage()),
      GoRoute(path: POSMembershipListPage.routeName, builder: (context, state) => const POSMembershipListPage()),
      GoRoute(path: PosMembershipDetailsComponent.routeName, builder: (context, state) => PosMembershipDetailsComponent()),
      GoRoute(path: OrderSchedulePage.routeName, builder: (context, state) => const OrderSchedulePage()),
      GoRoute(
          path: CreateMembershipPage.routeName,
          builder: (context, state) {
            var arguments = state.extra as Map<String, dynamic>;
            final membershipId = arguments['membershipId'] as String;
            return CreateMembershipPage(membershipId: membershipId);
          }),
      GoRoute(
          path: CreateSchedulePage.routeName,
          builder: (context, state) {
            var arguments = (state.extra) as Map<String, dynamic>;
            var selectedBooking = arguments['selectedBooking'] as Schedule?;
            var calendarId = arguments['calendarId'] as String;
            var orderId = arguments['orderId'] as String;

            return CreateSchedulePage(
              selectedSchedule: selectedBooking,
              calendarId: calendarId,
              orderId: orderId,
            );
          }),
      GoRoute(
        path: SectionPage.routeName,
        builder: (context, state) {
          var arguments = state.extra as Map<String, dynamic>;
          var businessId = arguments['businessId'] as String;
          var sectionId = arguments['sectionId'] as String;
          var sectionName = arguments['sectionName'] as String;
          return SectionPage(businessId: businessId, sectionId: sectionId, sectionName: sectionName);
        },
      ),
      GoRoute(path: ProductListPage.routeName, builder: (context, state) => const ProductListPage()),
      GoRoute(path: InventoryListPage.routeName, builder: (context, state) => const InventoryListPage()),
      GoRoute(path: CalendarListPage.routeName, builder: (context, state) => const CalendarListPage()),
      GoRoute(path: ProductPriceListPage.routeName, builder: (context, state) => const ProductPriceListPage()),
      GoRoute(path: ChatRoomListPage.routeName, builder: (context, state) => const ChatRoomListPage()),
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
  Future<void> goNamed(BuildContext context, String routeName, {Map<String, dynamic> queryParam = const {}, Map<String, dynamic>? extra, bool replace = false}) async {
    context.goNamed(routeName, extra: extra);
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
