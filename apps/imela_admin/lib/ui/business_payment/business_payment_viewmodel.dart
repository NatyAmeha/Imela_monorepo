import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_admin/app/app_viewmodel.dart';
import 'package:imela_admin/injection.dart';
import 'package:imela_admin/ui/business/business_list_page.dart';
import 'package:imela_admin/ui/business_payment/business_payment_page.dart';
import 'package:imela_admin/ui/business_payment/components/payment_method_list.dart';
import 'package:imela_core/business/model/payment_method.model.dart';
import 'package:imela_core/subscription/model/platform_service.model.dart';
import 'package:imela_ui_kit/components/modal/app_modal_sheet.dart';
import 'package:imela_ui_kit/helpers/widget_extesions.dart';
import 'package:imela_utils/exception/app_exception.dart';
import 'package:imela_utils/helpers/base_viewmodel.dart';
import 'package:injectable/injectable.dart';

@injectable
class BusinessPaymentViewmodel extends GetxController with BaseViewmodel {
  AppViewmodel get appViewmodel => AppViewmodel.getInstance();
  var selectedService = <PlatformService>[];
  final paymentmethods = PaymentMethod.platformPaymentMethods();
  var isFreeTierAvailable = true;

  @override
  void initViewmodel({Map<String, dynamic>? data}) {
    super.initViewmodel(data: data);
    selectedService = data![BusinessPaymentPage.selectedServiceArgKey];
  }

  var isLoading = false.obs;
  var exception = Rxn<AppException>();

  var selectedPaymentMethod = Rxn<PaymentMethod>();

  static BusinessPaymentViewmodel getInstance() {
    return BaseViewmodel.isViewmodelRegistered(getIt<BusinessPaymentViewmodel>());
  }

  bool isPaymentMethodSelected(PaymentMethod method) {
    return selectedPaymentMethod.value?.id == method.id;
  }

  void updatePaymentMethod(String? id) {
    selectedPaymentMethod.value = paymentmethods.firstWhere((element) => element.id == id);
    selectedPaymentMethod.refresh();
  }

  String getTotalPrice() {
    return '${selectedService.fold<double>(0, (previousValue, element) => previousValue + element.totalCustomizationPrice())}';
  }

  Future<void> showPaymentMethodsModalForSmallScreen(BuildContext context) async {
    await AppModalSheet.showModal(context, type: AppModalSheetType.BOTTOMSHEET, pages: [
      ModalContent(
          title: const Text('Selected platform services'),
          content: PaymentMethodList(
            paymentMethods: paymentmethods,
            isSelected: isPaymentMethodSelected,
            selectedPaymentMethodId: selectedPaymentMethod.value?.id,
            onSelected: (paymetnMethodId) {
              updatePaymentMethod(paymetnMethodId);
            },
            onContinue: () {
              // close modal first for small screen
              AppModalSheet.closeModal();
              processPayment(context);
            },
          ).withPaddingAll(16)),
    ]);
  }

  Future<void> processPayment(BuildContext context) async{
    BusinessListPage.navigate(context);
  }
}
