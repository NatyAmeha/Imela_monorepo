import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_core/customer/customer_usecase.dart';
import 'package:imela_core/customer/dto/customer_input.dart';
import 'package:imela_core/customer/model/customer.model.dart';
import 'package:imela_core/membership/dto/membership_response.dart';
import 'package:imela_core/membership/membership_usecase.dart';
import 'package:imela_core/membership/model/membership.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_pos/app/app_viewmodel.dart';
import 'package:imela_pos/injection.dart';
import 'package:imela_pos/ui/customer/component/create_customer_modal.dart';
import 'package:imela_pos/ui/customer/component/search_customer_list_modal.dart';
import 'package:imela_pos/ui/membership/pos_membership_list.viewmodel.dart';
import 'package:imela_ui_kit/components/modal/app_modal_sheet.dart';
import 'package:imela_ui_kit/helpers/file_upload.model.dart';
import 'package:imela_utils/exception/app_exception.dart';
import 'package:imela_utils/helpers/base_viewmodel.dart';
import 'package:injectable/injectable.dart';

@injectable
class CreateMembershipViewmodel extends GetxController with BaseViewmodel {
  final MembershipUseCase membershipUseCase;
  final CustomerUsecase customerUseCase;
  CreateMembershipViewmodel({required this.membershipUseCase, required this.customerUseCase});

  var isLoading = false.obs;
  var isCustomerCreateLoading = false.obs;
  var exception = Rxn<AppException>();

  var selectedCustomer = Rxn<Customer>();

  late String membershipId;
  var selectedMembership = Rxn<Membership>();

  // getter
  AppViewmodel get appViewmodel => AppViewmodel.getInstance();
  POSMembershipListViewmodel get posMembershipListViewmodel => POSMembershipListViewmodel.getInstance();
  String get selectedLanguage => appViewmodel.selectedLanguage;
  String get selectedCurrency => appViewmodel.selectedCurrency;

  static CreateMembershipViewmodel getInstance() {
    return BaseViewmodel.isViewmodelRegistered(getIt<CreateMembershipViewmodel>());
  }

  @override
  void initViewmodel({Map<String, dynamic>? data}) {
    super.initViewmodel(data: data);
    Future.delayed(Duration.zero, () async {
      membershipId = data?['membershipId'] ?? '';
      getMembership();
    });
  }

  void getMembership() async {
    isLoading.value = true;
    exception.value = null;
    selectedMembership.value = null;
    selectedMembership.value = appViewmodel.allMemberships.firstWhereOrNull((element) => element.id == membershipId);
  }

  Future<void> showCustomerListDialog(BuildContext context) async {
    try {
      final allCustomers = await appViewmodel.loadCustomers(context);
      var nonMemberCustomers = allCustomers.where((customer) => !customer.isCustomerAMember(membershipId, appViewmodel.allMemberships)).toList();
      await AppModalSheet.showModal(
        context,
        type: AppModalSheetType.DIALOG,
        pages: [
          ModalContent(
            title: const Text('Select customer'),
            content: SearchCustomerListModal(
              customers: nonMemberCustomers,
              selectedCustomer: appViewmodel.selectedCustomer.value,
              title: 'Select customers',
              description: 'Select from of the registered customers to create membership',
              showCustomerCreate: false,
              onCustomerSelected: (contextt, customerSelected) {
                selectedCustomer.value = customerSelected;
                AppModalSheet.closeModal();
              },
            ),
          ),
        ],
      );
    } catch (e) {
      print('error $e');
    }
  }

  void showCustomerCreateDialog(BuildContext context) {
    AppModalSheet.showModal(
      context,
      type: AppModalSheetType.DIALOG,
      pages: [
        ModalContent(
          title: const Text('Create customer'),
          content: Obx(
            () => CreateCustomerForm(
              onCreateCustomer: (context, firstName, lastName, email) {
                createCustomer(context, firstName, lastName, email);
              },
              isLoading: isCustomerCreateLoading.value,
              widgetFactory: AppViewmodel.getWidgetFactory(context),
            ),
          ),
        ),
      ],
    );
  }

  Future<List<Customer>> createCustomer(BuildContext context, String firstName, String phoneNumber, String email) async {
    try {
      isCustomerCreateLoading.value = true;
      final customerInfo = CreateCustomerData(firstName: firstName, phoneNumber: phoneNumber, email: email);
      final customerResult = await customerUseCase.createCustomer(appViewmodel.selectedBusinessId, [customerInfo]);
      if (customerResult?.isCustomerCreateSuccess() ?? false) {
        AppModalSheet.closeModal();
        appViewmodel.addToPosCustomers(customerResult?.customers ?? []);
        AppViewmodel.getWidgetFactory(context).showFlashMessage(context, message: 'Customer created successfully', actionText: 'ok');
        return customerResult?.customers ?? [];
      }
      return [];
    } catch (e) {
      print('error $e');
      return [];
    } finally {
      isCustomerCreateLoading.value = false;
    }
  }

  var membershipJoinRequest = Rxn<MembershipResponse>();

  Future<void> createMembership(BuildContext context) async {
    try {
      isLoading.value = true;
      if (posMembershipListViewmodel.selectedPaymentMethods.value != null) {
        final result = await membershipUseCase.requestToJoinMembership(appViewmodel.selectedBusinessId, selectedMembership.value!.id!, membershipName: selectedMembership.value!.name.localize(selectedLanguage), memberId: selectedCustomer.value!.userId!, selectedPaymentMethod: posMembershipListViewmodel.selectedPaymentMethods.value!);
        if (result?.success ?? false) {
          membershipJoinRequest.value = result;
          final approveMembershipResult = await membershipUseCase.renewMembership(
            businessId: appViewmodel.selectedBusinessId,
            branchId: appViewmodel.selectedBranchId,
            membershipId: selectedMembership.value!.id!,
            membershipName: selectedMembership.value!.name.localize('ENGLISH'),
            memberId: selectedCustomer.value!.userId!,
            selectedPaymentMethod: posMembershipListViewmodel.selectedPaymentMethods.value!,
          );
          if (approveMembershipResult?.success ?? false) {
            AppViewmodel.getWidgetFactory(context).showFlashMessage(context, message: 'Membership created successfully', actionText: 'ok');
            appViewmodel.appRouter.goBack(context);
          }
        }
      }
    } catch (e) {
      print('error $e');
    }
  }

  void removeSelectedPaymentMethod(int index) {}

  void addSelectedPaymentMethod(FileUpload? image) {}
}
