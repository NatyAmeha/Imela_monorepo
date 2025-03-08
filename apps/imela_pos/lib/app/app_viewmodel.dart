import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_core/branch/model/branch.model.dart';
import 'package:imela_core/business/model/business.model.dart';
import 'package:imela_core/business/model/business.section.dart';
import 'package:imela_core/business/model/business_order_status.dart';
import 'package:imela_core/business/model/payment_method.model.dart';
import 'package:imela_core/business/model/payment_option.model.dart';
import 'package:imela_core/calendar/model/calendar.model.dart';
import 'package:imela_core/chat/service/chat_socket_service.dart';
import 'package:imela_core/customer/customer_usecase.dart';
import 'package:imela_core/customer/model/customer.model.dart';
import 'package:imela_core/loyalty/dto/loyalty.response.dart';
import 'package:imela_core/loyalty/model/customer_loyalty.model.dart';
import 'package:imela_core/loyalty/model/reward.model.dart';
import 'package:imela_core/membership/dto/membership_response.dart';
import 'package:imela_core/membership/membership_usecase.dart';
import 'package:imela_core/membership/model/membership.model.dart';
import 'package:imela_core/order/model/cart.model.dart';
import 'package:imela_core/product/model/product.model.dart';
import 'package:imela_core/product/product.usecase.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_core/staff/model/staff_response.dart';
import 'package:imela_core/user/auth.usecase.dart';
import 'package:imela_core/user/model/access/access.model.dart';
import 'package:imela_data/injection.dart';
import 'package:imela_data/network/graphql/graphql_datasource.dart';
import 'package:imela_pos/app/routing_service.dart';
import 'package:imela_pos/ui/authentication/staff_signin.page.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';
import 'package:imela_utils/helpers/base_viewmodel.dart';
import 'package:imela_utils/helpers/localization_utils.dart';
import 'package:injectable/injectable.dart';

@injectable
class AppViewmodel extends GetxController with BaseViewmodel {
  static final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  static WidgetFactory? _widgetFactoryInstance;

  final AuthUsecase authUsecase;
  final ProductUsecase productUsecase;
  final CustomerUsecase customerUsecase;
  final MembershipUseCase membershipUsecase;

  AppViewmodel({
    required this.authUsecase,
    required this.customerUsecase,
    required this.membershipUsecase,
    required this.productUsecase,
  });

  late GoRouterService appRouter;

  // global state variables
  var loggedInStaffInfo = Rxn<StaffResponse>();

  var posCustomers = <Customer>[];

  var businessMembershipInfo = Rxn<MembershipResponse>();
  var allMemberships = <Membership>[];

  final selectedBusiness = Rxn<Business>();
  var selectedSection = Rxn<BusinessSection>();
  var branches = <Branch>[].obs;
  var selectedBranch = Rxn<Branch>();
  var selectedCustomer = Rxn<Customer>();

  var productsCalendars = <Calendar>[].obs;

  var selectedBusinessLoyaltyInfo = Rxn<LoyaltyResponse>();

  var cartInfo = Cart(name: [
    LocalizedField(key: AppLanguage.ENGLISH.name, value: "Cart"),
    LocalizedField(key: AppLanguage.AMHARIC.name, value: "ስምምነት"),
  ], items: []).obs;

  ChatSocketService chatSocketService = getIt<ChatSocketService>();

  BuildContext getAppContext() {
    return AppViewmodel.scaffoldMessengerKey.currentContext!;
  }
  List<Access> get loggedInStaffAccesses => loggedInStaffInfo.value?.authResponse?.accesses ?? [];

  // getter
  List<Product> get allProducts {
    return selectedBranch.value?.products ?? [];
  }

  bool get isUserAuthenticated {
    return loggedInStaffInfo.value != null;
  }

  String get selectedBusinessId => selectedBusiness.value!.id!;
  String get selectedBranchId => selectedBranch.value!.id!;
  List<Branch> get businessBranches => selectedBusiness.value?.branches ?? [];
  List<String> get businessBranchesIds => businessBranches.map((branch) => branch.id!).toList();

  List<Branch> get staffBranchList {
    final staffBranch = loggedInStaffInfo.value?.staff?.branch;
    if (loggedInStaffInfo.value == null) return [];

    return staffBranch != null ? [staffBranch] : businessBranches;
  }

  List<PaymentOption> get paymentOptions {
    return selectedBusiness.value?.paymentOptions ?? [PaymentOption.defaultPaymentOption()];
  }

  List<PaymentMethod> get paymentMethods {
    return PaymentMethod.getFakePaymentMethods();
  }

  List<Reward> get branchRewards => selectedBusinessLoyaltyInfo.value?.rewards ?? [];

  List<BusinessOrderStatus> get businessOrderStatuses => selectedBusiness.value?.orderStatuses ?? [];

  var reloadMembership = true;

  @override
  Future<void> initViewmodel({Map<String, dynamic>? data}) async {
    Get.put(this);
    appRouter = getIt<GoRouterService>(instanceName: GoRouterService.injectName);
  }

  static AppViewmodel getInstance() {
    return BaseViewmodel.isViewmodelRegistered(getIt<AppViewmodel>());
  }

  // Getters
  String? get loggedInStaffName => loggedInStaffInfo.value?.staff?.name;
  bool get isUserLoggedIn => loggedInStaffInfo.value != null;

  static WidgetFactory getWidgetFactory(BuildContext context) {
    return _widgetFactoryInstance ??= WidgetFactory(Theme.of(context).platform);
  }

  var selectedLanguage = AppLanguage.ENGLISH.name;
  var selectedCurrency = 'ETB';

  void setSelectedBusiness(Business business) {
    selectedBusiness.value = business;
    cartInfo.value = cartInfo.value.addBusiness([business.id!]);
    selectedSection.value = business.sections?.first;
  }

  void setSelectedSection(BusinessSection section) {
    selectedSection.value = section;
  }

  void setLoggedInStaff(StaffResponse staffResponse) {
    loggedInStaffInfo.value = staffResponse;
    selectedBranch.value = staffResponse.staff?.branch ?? businessBranches.first;
  }

  void setSelectedCustomer(Customer? customer) {
    selectedCustomer.value = customer;
  }

  Future<List<Customer>> loadCustomers(BuildContext context) async {
    try {
      if (posCustomers.isNotEmpty) return posCustomers;
      final result = await customerUsecase.getBusinessCustomer(selectedBusinessId, 1, 1000);
      if (result?.customers?.isNotEmpty ?? false) {
        setPosCustomers(result?.customers ?? []);
        return result?.customers ?? [];
      }
      return [];
    } catch (e) {
      print('error $e');
      return [];
    }
  }

  void setPosCustomers(List<Customer> customers, {bool clear = true}) {
    if (clear) {
      posCustomers.clear();
    }
    posCustomers.assignAll(customers);
  }

  void addToPosCustomers(List<Customer> customers) {
    posCustomers.addAll(customers);
  }

  void setSelectedBusinessLoyaltyInfo(LoyaltyResponse? loyaltyResponse) {
    selectedBusinessLoyaltyInfo.value = loyaltyResponse;
  }

  CustomerLoyalty? getCustomerLoyaltyInfo(Customer? customer) {
    if (customer == null) return null;
    final selectedCustomer = posCustomers.firstWhereOrNull((c) => c.id == customer.id);
    return selectedCustomer?.customerLoyalties?.firstWhereOrNull((loyalty) => loyalty.businessId == selectedBusinessId);
  }

  List<Reward> getEligibleRewards(Customer customer) {
    final customerLoyalty = getCustomerLoyaltyInfo(customer);
    return branchRewards.getEligibleRewards(customerLoyalty?.currentPoints ?? 0);
  }

  void selectBranch(Branch? branch) {
    if (branch != null) {
      selectedBranch.value = branch;
    }
  }

  Future<MembershipResponse?> getBusinessMemberships({ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheFirst, bool forceReload = true}) async {
    try {
      MembershipResponse? result;
      if (forceReload || reloadMembership) {
        result = await membershipUsecase.getMembershipPlansForPos(selectedBusinessId, fetchPolicy: fetchPolicy);
      } else {
        result = businessMembershipInfo.value;
      }
      if (result == null || !(result.success ?? false)) {
        return null;
      }
      if ((result.memberships?.isEmpty ?? true)) {
        return null;
      }
      setBusinessMembershipInfo(result);
      setAllMemberships(result.memberships ?? []);
      reloadMembership = false;
      return result;
    } catch (e) {
      print('error fetching user memberships: $e');
      return null;
    }
  }

  void setBusinessMembershipInfo(MembershipResponse? membershipResponse) {
    businessMembershipInfo.value = membershipResponse;
  }

  void setAllMemberships(List<Membership> memberships) {
    allMemberships.assignAll(memberships);
  }

  List<Customer> getMemberCustomers(String membershipId) {
    final membership = allMemberships.firstWhereOrNull((membership) => membership.id == membershipId);
    if (membership == null) return [];

    final result = membership.allMembers?.map((member) => posCustomers.firstWhereOrNull((customer) => customer.userId == member.userId)).whereType<Customer>().toList() ?? [];
    return result;
  }

  Future<void> logout(BuildContext context, {bool showLogoutPopup = false}) async {
    if (showLogoutPopup) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel')),
            TextButton(
                onPressed: () async {
                  final result = await authUsecase.logout();
                  loggedInStaffInfo.value = null;
                  if (result) {
                    resetCustomerRelatedData();
                    resetCartInfo();
                    POSStaffSignInPage.navigate(context, replaceRoute: true);
                  }
                },
                child: const Text('Logout')),
          ],
        ),
      );
    } else {
      final result = await authUsecase.logout();
      loggedInStaffInfo.value = null;
      if (result) {
        POSStaffSignInPage.navigate(context, replaceRoute: true);
      }
    }
    
    // Disconnect socket on logout
    chatSocketService.disconnect();
  }

  void resetCustomerRelatedData() {
    setSelectedCustomer(null);
    setPosCustomers([]);
  }

  void resetCartInfo() {
    cartInfo.value = cartInfo.value.copyWith(items: []);
  }

  void updateMembershipInfo(Membership? membership) {
    if (membership == null) return;
    final index = allMemberships.indexWhere((membership) => membership.id == membership.id);
    if (index != -1) {
      allMemberships[index] = membership;
    }
  }

  void setProductCalendars(List<Calendar>? calendars) {
    if (calendars?.isEmpty ?? true) return;
    productsCalendars.assignAll(calendars!);
  }

  void initSocketConnection() {
    if (loggedInStaffInfo.value != null && loggedInStaffInfo.value!.staff != null) {
      final staffId = loggedInStaffInfo.value!.staff!.id;
      final token = loggedInStaffInfo.value!.authResponse!.accessToken;
      
      // Connect the socket
      if (staffId != null && token != null) {
        chatSocketService.connect(staffId, token);
        print('Socket connection initialized for staff: $staffId');
      }
    }
  }

  void updateLoggedInStaffInfo(StaffResponse staffInfo) {
    loggedInStaffInfo.value = staffInfo;
    
    // Initialize socket connection after login
    initSocketConnection();
  }
}
