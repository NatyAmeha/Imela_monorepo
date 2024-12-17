import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_core/customer/customer_usecase.dart';
import 'package:imela_core/customer/dto/customer_input.dart';
import 'package:imela_core/customer/model/customer.model.dart';
import 'package:imela_core/loyalty/model/reward.model.dart';
import 'package:imela_core/order/order.usecase.dart';
import 'package:imela_core/shared/utils/exception_handler.dart';
import 'package:imela_data/network/graphql/graphql_datasource.dart';
import 'package:imela_pos/app/app_viewmodel.dart';
import 'package:imela_pos/injection.dart';
import 'package:imela_pos/ui/customer/component/create_customer_modal.dart';
import 'package:imela_pos/ui/customer/component/customer_details_modal.dart';
import 'package:imela_pos/ui/customer/component/search_customer_list_modal.dart';
import 'package:imela_ui_kit/components/modal/app_modal_sheet.dart';
import 'package:imela_utils/exception/app_exception.dart';
import 'package:imela_utils/helpers/base_viewmodel.dart';
import 'package:injectable/injectable.dart';

@injectable
class CustomerViewmodel extends GetxController with BaseViewmodel {
  final OrderUsecase orderUsecase;
  final CustomerUsecase customerUsecase;
  final IExceptiionHandler exceptiionHandler;

  CustomerViewmodel({
    required this.orderUsecase,
    required this.customerUsecase,
    @Named(AppExceptionHandler.injectName) required this.exceptiionHandler,
  });

  static CustomerViewmodel getInstance() {
    return BaseViewmodel.isViewmodelRegistered(getIt<CustomerViewmodel>());
  }

  // state variables
  var isLoading = false.obs;
  var exception = Rxn<AppException>();
  var customers = <Customer>[].obs;
  final RxList<Customer> filteredCustomers = <Customer>[].obs;
  final RxBool isLoadingSearch = false.obs;
  final RxString searchType = 'name'.obs;

  var selectedLoyaltyReward = Rxn<Reward>();

  final TextEditingController searchController = TextEditingController();

  var isCustomerCreateLoading = false.obs;

  // getters
  AppViewmodel get appViewmodel => AppViewmodel.getInstance();

  @override
  void initViewmodel({Map<String, dynamic>? data}) {
    super.initViewmodel(data: data);
    Future.delayed(Duration.zero, () {
      var context = data?['context'] as BuildContext;
      var customerList = data?['customers'] as List<Customer>? ?? [];
      if (customerList.isNotEmpty) {
        customers.value = customerList;
        filteredCustomers.value = customers;
      } else {
        loadCustomers(context);
      }
    });
  }

  void loadCustomers(BuildContext context, {ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheFirst}) async {
    try {
      isLoadingSearch.value = true;
      isLoading.value = true;
      final result = await customerUsecase.getBusinessCustomer(appViewmodel.selectedBusinessId, 1, 1000, fetchPolicy: fetchPolicy);

      if (result?.customers?.isNotEmpty ?? false) {
        customers.value = [...result?.customers ?? []];
        filteredCustomers.value = customers;
        appViewmodel.setPosCustomers(customers);
      }
    } catch (e) {
      print('error $e');
      await AppViewmodel.getWidgetFactory(context).showFlashMessage(
        context,
        message: 'Unable to fetch customers, please try again',
        actionText: 'try again',
        onActinClicked: () {
          loadCustomers(context);
        },
      );
    } finally {
      isLoading.value = false;
      isLoadingSearch.value = false;
    }
  }

  void onSearchTextChanged(String value) {
    if (value.isEmpty) {
      filteredCustomers.value = customers;
    } else {
      filteredCustomers.value = customers.where((customer) {
        if (searchType.value == 'phone') {
          return customer.phoneNumber?.contains(value) ?? false;
        } else {
          final fullName = customer.name.toLowerCase();
          return fullName.contains(value.toLowerCase());
        }
      }).toList();
    }
  }

  void setSearchType(String? type) {
    if (type != null) {
      searchType.value = type;
      onSearchTextChanged(searchController.text);
    }
  }

  void selectCustomer(BuildContext context, Customer customer) async {
    final customerLoyalty = appViewmodel.getCustomerLoyaltyInfo(customer);
    final eligableRewards = appViewmodel.branchRewards.getEligibleRewards(customerLoyalty?.currentPoints ?? 0);

    await AppModalSheet.showModal(context, type: AppModalSheetType.DIALOG, pages: [
      ModalContent(
          title: const Text('Customer Details'),
          content: CustomerDetailsModal(
            customer: customer,
            customerMemberships: customer.getCustomerMemberships(appViewmodel.allMemberships),
            customerLoyalty: customerLoyalty,
            eligableRewards: eligableRewards,
            businessRewards: appViewmodel.branchRewards,
            selectedLanguage: 'ENGLISH',
            onCustomerSelected: (context, selectedReward) {
              selectedLoyaltyReward.value = selectedReward;
              appViewmodel.setSelectedCustomer(customer);
              AppModalSheet.closeModal();
            },
          )),
    ]);
  }

  void showCustomerCreateDialog(BuildContext context, {bool closeDialog = false}) async {
    if (closeDialog) {
      AppModalSheet.closeModal();
    }
    final widgetFactory = AppViewmodel.getWidgetFactory(context);

    await AppModalSheet.showModal(
      context,
      type: AppModalSheetType.DIALOG,
      dimissable: false,
      pages: [
        ModalContent(
          title: const Text('Create Customer'),
          content: Obx(
            () => CreateCustomerForm(
              widgetFactory: widgetFactory,
              isLoading: isCustomerCreateLoading.value,
              onCreateCustomer: (context, firstName, phoneNumber, email) async {
                createCustomer(context, firstName, phoneNumber, email);
              },
            ),
          ),
        ),
      ],
    );
  }

  Future<List<Customer>> createCustomer(BuildContext context, String firstName, String phoneNumber, String email) async {
    final widgetFactory = AppViewmodel.getWidgetFactory(context);
    try {
      isCustomerCreateLoading.value = true;
      final customerInfo = CreateCustomerData(firstName: firstName, phoneNumber: phoneNumber, email: email);
      final customerResult = await customerUsecase.createCustomer(appViewmodel.selectedBusinessId, [customerInfo]);
      if (customerResult?.isCustomerCreateSuccess() ?? false) {
        AppModalSheet.closeModal();
        updateCustomerListOnCreate(customerResult?.customers ?? []);
        widgetFactory.showFlashMessage(context, message: 'Customer created successfully', actionText: 'ok');
        return customerResult?.customers ?? [];
      }
      return [];
    } catch (e) {
      print('error $e');
      widgetFactory.showFlashMessage(context, message: 'Unable to create customer, please try again', actionText: 'try again', onActinClicked: () {
        createCustomer(context, firstName, phoneNumber, email);
      });
      return [];
    } finally {
      isCustomerCreateLoading.value = false;
    }
  }

  void updateCustomerListOnCreate(List<Customer> newCustomers) {
    appViewmodel.addToPosCustomers(newCustomers);
    customers.value = [...customers, ...newCustomers];
    filteredCustomers.value = customers;
    refresh();
  }
}
