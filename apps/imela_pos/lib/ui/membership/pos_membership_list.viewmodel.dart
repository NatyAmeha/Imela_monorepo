import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:imela_core/business/model/payment_method.model.dart';
import 'package:imela_core/customer/model/customer.model.dart';
import 'package:imela_core/membership/dto/membership_response.dart';
import 'package:imela_core/membership/membership_usecase.dart';
import 'package:imela_core/membership/model/group.model.dart';
import 'package:imela_core/membership/model/membership.model.dart';
import 'package:imela_core/product/model/product.model.dart';
import 'package:imela_core/shared/currency_utils.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_core/shared/utils/exception_handler.dart';
import 'package:imela_data/network/graphql/graphql_datasource.dart';
import 'package:imela_pos/app/app_viewmodel.dart';
import 'package:imela_pos/injection.dart';
import 'package:imela_pos/ui/membership/components/pos_membership_details_component.dart';
import 'package:imela_pos/ui/membership/components/renew_membership_summary.dart';
import 'package:imela_pos/ui/membership/components/user_membership_detail_modal.dart';
import 'package:imela_pos/ui/membership/create_membership_page.dart';
import 'package:imela_ui_kit/components/modal/app_modal_sheet.dart';
import 'package:imela_ui_kit/helpers/file_upload.model.dart';
import 'package:imela_ui_kit/helpers/pop_up_menu_data.dart';
import 'package:imela_ui_kit/helpers/widget_extesions.dart';
import 'package:imela_utils/exception/app_exception.dart';
import 'package:imela_utils/helpers/base_viewmodel.dart';
import 'package:imela_utils/helpers/screen_size_utils.dart';
import 'package:injectable/injectable.dart';

@injectable
class POSMembershipListViewmodel extends GetxController with BaseViewmodel {
  final MembershipUseCase membershipUseCase;
  final IExceptiionHandler exceptiionHandler;
  POSMembershipListViewmodel({
    required this.membershipUseCase,
    @Named(AppExceptionHandler.injectName) required this.exceptiionHandler,
  });

  static POSMembershipListViewmodel getInstance() {
    return BaseViewmodel.isViewmodelRegistered(getIt<POSMembershipListViewmodel>());
  }

  // state variables
  var isLoading = false.obs;
  var isMembershipDetailsLoading = false.obs;
  var isProductsLoading = false.obs;
  var isRenewingMembership = false.obs;
  var exception = Rxn<AppException>();
  var selectedMembership = Rxn<Membership>();
  var filteredMembershipCustomers = <Customer>[].obs;

  // getters
  AppViewmodel get appViewmodel => AppViewmodel.getInstance();
  List<Membership> get membershipList => appViewmodel.allMemberships;
  String get selectedLanguage => appViewmodel.selectedLanguage;

  List<Benefit> get selectedMembershipBenefits => selectedMembership.value?.benefits ?? [];
  List<Product> get selectedMembershipProducts {
    var productIds = selectedMembership.value?.membersProductIds ?? [];
    if (productIds.isEmpty) return [];
    return appViewmodel.allProducts.where((product) => productIds.contains(product.id)).toList();
  }

  List<Customer> get selectedMembershipCustomers => appViewmodel.getMemberCustomers(selectedMembership.value?.id ?? '');

  @override
  void initViewmodel({Map<String, dynamic>? data}) {
    super.initViewmodel(data: data);
    Future.delayed(Duration.zero, () async {
      await getMemberships();
      filteredMembershipCustomers.value = selectedMembershipCustomers;
    });
  }

  Future<void> getMemberships({ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheFirst}) async {
    try {
      isLoading.value = true;
      exception.value = null;
      if (appViewmodel.allMemberships.isEmpty || fetchPolicy == ApiDataFetchPolicy.networkOnly) {
        final result = await appViewmodel.getBusinessMemberships(fetchPolicy: fetchPolicy);
        if (result == null || !(result.success ?? false)) {
          exception.value = exceptiionHandler.getException(AppException(message: 'Failed to fetch memberships'));
          return;
        }
        if ((result.memberships?.isEmpty ?? true)) {
          exception.value = exceptiionHandler.getException(AppException(message: 'No memberships found'));
          return;
        }
        appViewmodel.setBusinessMembershipInfo(result);
        appViewmodel.setAllMemberships(result.memberships ?? []);
      }
      selectedMembership.value ??= membershipList.first;
    } catch (e) {
      print('error fetching user memberships: $e');
      exception.value = exceptiionHandler.getException(e as AppException);
    } finally {
      isLoading.value = false;
    }
  }

  void selectMembership(BuildContext context, Membership membership) {
    selectedMembership.value = membership;
    if (Responsive.isSmallScreen(context)) {
      PosMembershipDetailsComponent.navigate(context);
    }
  }

  void filterCustomersByName(String query) {
    if (query.isEmpty) {
      filteredMembershipCustomers.value = selectedMembershipCustomers;
    } else {
      filteredMembershipCustomers.value = selectedMembershipCustomers.where((customer) => customer.name.toLowerCase().contains(query.toLowerCase())).toList();
    }
  }

  List<PopupMenuItemData<String>> getMembersAction(Customer customer) {
    var actions = [
      PopupMenuItemData(
        label: 'See Membeship details',
        value: 'details',
        icon: Icons.info_outline,
        onPressed: (context) {
          showMemberSubscriptionDetails(context, customer);
        },
      ),
    ];
    final customerMemberships = customer.getCustomerMembershipInfo(selectedMembership.value!.id!, membershipList);
    if (customerMemberships?.getCustomerGroupMemberInfo(customer.userId ?? '')?.memberStatus == GroupMemberStatus.PENDING.name) {
      actions.add(PopupMenuItemData(
        label: 'Approve Membership',
        value: 'approve',
        icon: Icons.check_circle_outline,
        onPressed: (context) {
          showRenewMembershipsummaryDialog(context, customer);
        },
      ));
    } else {
      actions.add(PopupMenuItemData(
        label: 'Renew Membership',
        value: 'renew',
        icon: Icons.refresh,
        onPressed: (context) {
          showRenewMembershipsummaryDialog(context, customer);
        },
      ));
    }
    return actions;
  }

  void showMemberSubscriptionDetails(BuildContext context, Customer customer) {
    final membershipInfo = customer.getCustomerMembershipInfo(selectedMembership.value!.id!, membershipList);
    if (membershipInfo == null) {
      return;
    }
    AppModalSheet.showModal(context, type: AppModalSheetType.DIALOG, pages: [
      ModalContent(
        title: const Text('Membership Details'),
        content: UserMembershipDetailModal(
          customer: customer,
          membershipInfo: membershipInfo,
          memberships: appViewmodel.allMemberships,
          widgetFactory: AppViewmodel.getWidgetFactory(context),
          onRenewSubscriptionPressed: () {
            AppModalSheet.closeModal();
            showRenewMembershipsummaryDialog(context, customer);
          },
          onCancelSubscriptionPressed: () {},
        ),
      )
    ]);
  }

  void showRenewMembershipsummaryDialog(BuildContext context, Customer customer) {
    if (selectedPaymentMethods.value == null) {
      var selectedPayment = SelectedPaymentMethod.cashPaymentAtStore(amoun: selectedMembership.value!.price?.toSelectedPrice("ETB")?.amount ?? 0);
      selectedPaymentMethods.value = selectedPayment;
    }
    AppModalSheet.showModal(
      context,
      type: AppModalSheetType.DIALOG,
      pages: [
        ModalContent(
          title: const Text('Renew Membership'),
          content: Obx(
            () => RenewMembershipSummary(
              customer: customer,
              enableCustomerSelection: false,
              membership: selectedMembership.value!,
              widgetFactory: AppViewmodel.getWidgetFactory(context),
              selectedLanguage: selectedLanguage,
              currency: appViewmodel.selectedCurrency,
              isRenewingMembership: isRenewingMembership.value,
              onImageUpload: (image) {
                addPaymenReceiptImage(image);
              },
              onImageRemoved: (index) {
                removeSelectedPaymentMethod(selectedPaymentMethods.value!);
              },
              onConfirm: () {
                renewMembership(context, customer);
              },
            ),
          ),
        )
      ],
    );
  }

  var selectedPaymentMethods = Rxn<SelectedPaymentMethod>();

  void addPaymenReceiptImage(FileUpload? uploadedFile) {
    selectedPaymentMethods.value = selectedPaymentMethods.value?.addReceiptImages([uploadedFile!.file!.path]);
  }

  void removeSelectedPaymentMethod(SelectedPaymentMethod paymentMethod) {
    selectedPaymentMethods.value = selectedPaymentMethods.value?.removeReceiptImages([paymentMethod.id!]);
  }

  Future<void> renewMembership(BuildContext context, Customer customer) async {
    try {
      isRenewingMembership.value = true;
      final membershipId = selectedMembership.value!.id!;
      if (customer.userId == null) {
        exception.value = exceptiionHandler.getException(AppException(message: 'Customer has no user id'));
        return;
      }
      print('payment proof images ${selectedPaymentMethods.value?.toJson()}');
      final result = await membershipUseCase.renewMembership(businessId: appViewmodel.selectedBusinessId, branchId: appViewmodel.selectedBranchId, membershipId: membershipId, membershipName: selectedMembership.value!.name.localize('ENGLISH'), memberId: customer.userId!, selectedPaymentMethod: selectedPaymentMethods.value);
      if (!(result?.success ?? false)) {
        exception.value = exceptiionHandler.getException(AppException(message: result?.message ?? 'Failed to renew membership'));
        return;
      }
      AppViewmodel.getWidgetFactory(context).showFlashMessage(context, message: 'Membership renewed successfully', actionText: 'ok');
      getMembershipDetails(membershipId);
      AppModalSheet.closeModal();
    } catch (ex) {
      print("exception renewing membership: $ex");
    } finally {
      isRenewingMembership.value = false;
    }
  }

  Future<void> getMembershipDetails(String membershipId) async {
    try {
      isMembershipDetailsLoading.value = true;
      final result = await membershipUseCase.getMembershipDetails(membershipId, fetchPolicy: ApiDataFetchPolicy.networkOnly);
      if (!(result?.success ?? false)) {
        exception.value = exceptiionHandler.getException(AppException(message: result?.message ?? 'Failed to fetch membership details'));
        return;
      }
      if (result?.membership != null) {
        print('membership info data ${result?.membership?.toJson()}');
        selectedMembership.value = result!.membership;
        filteredMembershipCustomers.value = selectedMembershipCustomers;
        appViewmodel.updateMembershipInfo(selectedMembership.value);
      }
    } catch (ex) {
      print("exception renewing membership: $ex");
    } finally {
      isMembershipDetailsLoading.value = false;
    }
  }

  void navigateToCreateMember(BuildContext context) {
    var widgetFactory = AppViewmodel.getWidgetFactory(context);
    AppModalSheet.showModal(
      context,
      type: AppModalSheetType.DIALOG,
      pages: [
        ModalContent(
          title: const Text('Create New membership'),
          content: Column(
            children: [
              widgetFactory.createText(context, 'Membership creation is not supported in POS', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),
              widgetFactory.createText(context, 'Customer should navigate to your  website to create a membership. You can send them the link to create a membership. Once they create a membership, you can approve it in the POS.'),
              const SizedBox(height: 24),
              widgetFactory.createButton(
                context: context,
                content: const Text('Send Link to Customer'),
                onPressed: () {
                  AppModalSheet.closeModal();
                },
              ),
              const SizedBox(height: 16),
            ],
          ).withPaddingSymetric(horizontal: 16, vertical: 16)
        )
      ],
    );
  }
}
