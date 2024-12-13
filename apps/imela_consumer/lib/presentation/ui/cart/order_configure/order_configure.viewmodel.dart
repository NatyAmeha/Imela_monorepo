import 'package:dartx/dartx.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:imela/presentation/ui/app_controller.dart';
import 'package:imela/presentation/ui/cart/cart_list.viewmodel.dart';
import 'package:imela/presentation/ui/cart/order_configure/order_configure_page.dart';
import 'package:imela/presentation/ui/home/home.page.dart';
import 'package:imela/presentation/ui/order/order_confirmation/order_confirmation_page.dart';
import 'package:imela/presentation/ui/payment/components/payment_method_list_modal.dart';
import 'package:imela/presentation/ui/shared/base_viewmodel.dart';
import 'package:imela/services/routing_service.dart';
import 'package:imela_core/business/model/payment_method.model.dart';
import 'package:imela_core/business/model/payment_option.model.dart';
import 'package:imela_core/order/model/cart.model.dart';
import 'package:imela_core/order/order.usecase.dart';
import 'package:imela_core/shared/price.model.dart';
import 'package:imela_core/shared/utils/exception_handler.dart';
import 'package:imela_ui_kit/components/modal/app_modal_sheet.dart';
import 'package:imela_ui_kit/helpers/file_upload.model.dart';
import 'package:imela_utils/exception/app_exception.dart';
import 'package:injectable/injectable.dart';
import 'package:imela_core/order/model/order.model.dart' as OrderModel;

@injectable
class OrderConfigureViewmodel extends GetxController with BaseViewmodel {
  final IExceptiionHandler exceptiionHandler;
  final IRoutingService router;
  OrderUsecase orderUsecase;

  OrderConfigureViewmodel({
    required this.orderUsecase,
    @Named(AppExceptionHandler.injectName) required this.exceptiionHandler,
    @Named(GoRouterService.injectName) required this.router,
  });

  // page state variables
  var isLoading = false.obs;
  var exception = Rxn<AppException>();
  var errorMessage = ''.obs;

  var cartInfo = Rxn<Cart>();
  var selectedPaymentOption = Rxn<PaymentOption>();

  var selectedPaymentMethods = <SelectedPaymentMethod>[].obs;

  // getters
  AppController get appController => AppController.getInstance;
  CartListViewmodel get cartListViewmodel => CartListViewmodel.getInstance();

  String? get selectedPaymentOptionId => selectedPaymentOption.value?.id;

  bool get canEnablePlaceORderBtn {
    return selectedPaymentMethods.isNotEmpty &&
        selectedPaymentMethods.any((pm) {
          if (pm.requireReceiptImage == true) {
            return pm.receiptImages?.isNotEmpty == true;
          }
          return true;
        }) &&
        selectedPaymentOptionId?.isNotEmpty == true;
  }

  double get totalAmount => cartInfo.value?.getTotatAmountPOS() ?? 0.0;
  double get currentPayment {
    return selectedPaymentOption.value?.currentPayment(totalAmount) ?? 0.0;
  }

  @override
  void initViewmodel({Map<String, dynamic>? data}) {
    cartInfo.value = data?['cart'] as Cart?;
    selectedPaymentOption.value = cartInfo.value?.paymentOptions?.firstOrNull ?? PaymentOption.defaultPaymentOption();
    super.initViewmodel(data: data);
  }

  void selectPaymentOption(PaymentOption paymentOption) {
    selectedPaymentOption.value = paymentOption;
  }

  void addSelectedPaymentMethod(PaymentMethod paymentMethod, {required Price amount, PaymentMethodOption? option}) {
    final paymentInfo = SelectedPaymentMethod(id: paymentMethod.id, name: paymentMethod.name!, amount: amount, paymentMethodOption: option, requireReceiptImage: paymentMethod.requireReceiptImage);
    selectedPaymentMethods.add(paymentInfo);
  }

  void addPaymenReceiptImage(String selectedPaymentId, FileUpload? uploadedFile) {
    final selectedPaymentIndex = selectedPaymentMethods.indexWhere((pM) => pM.id == selectedPaymentId);
    if (selectedPaymentIndex != -1 && uploadedFile?.file?.path != null) {
      selectedPaymentMethods[selectedPaymentIndex] = selectedPaymentMethods[selectedPaymentIndex].copyWith(receiptImages: [uploadedFile!.file!.path]);
      selectedPaymentMethods.refresh();
    }
  }

  void removeSelectedPaymentMethod(SelectedPaymentMethod paymentMethod) {
    selectedPaymentMethods.value = selectedPaymentMethods.where((pM) => pM.id != paymentMethod.id).toList();
  }

  Future<void> showPaymentMethodListModal(BuildContext context) async {
    final defaultPaymentMethods = appController.defaultPaymentMethods;
    await AppModalSheet.showModal(
      context,
      type: AppModalSheetType.BOTTOMSHEET,
      pages: [
        ModalContent(
          title: const Text('Choose payment method'),
          content: PaymentMethodListModal(
            paymentMethods: defaultPaymentMethods,
            // initialPaymentMethod: selectedPaymentMethods.firstOrNull?.paymentMethod,
            onContinuePressed: (paymentMethod) {
              final amount = Price(amount: currentPayment, currency: appController.selectedCurrency.name);
              addSelectedPaymentMethod(paymentMethod, amount: amount);
              AppModalSheet.closeModal();
            },
          ),
        ),
      ],
    );
  }

  Future<void> placeOrder(BuildContext context) async {
    try {
      if (cartInfo.value == null || selectedPaymentOption.value == null) {
        return;
      }
      isLoading(true);
      final orderInfo = OrderModel.Order.createOrderInfo(cartInfo.value!, paymentOption: selectedPaymentOption.value!, paymentMethods: selectedPaymentMethods, totalAmount: totalAmount, paidAmount: currentPayment);
      if (cartInfo.value?.businessIds?.isEmpty == true) {
        appController.getWidgetFactory(context).showFlashMessage(context, message: 'Please select at least one business');
        return;
      }
      var placeOrderResult = await orderUsecase.placeOrderForBusiness(cartInfo.value!.businessIds!, cartInfo.value!.id!, orderInfo);
      if (placeOrderResult.success == true) {
        cartListViewmodel.removeCart(cartInfo.value!.id!);
        OrderConfirmationPage.navigate(context, placeOrderResult.order!);
        appController.setRefetchOrderList(true);
      } else {
        errorMessage(placeOrderResult.message);
      }
    } catch (e) {
      var ex = exceptiionHandler.getException(e as Exception);
      if (ex.isUnAuthorizedException == true) {
        await appController.refreshTokenOrLogout(context, moveToLogin: true, showLoginMessage: true, redirectUrl: OrderConfigurePage.routeName, redirectExtra: {'cart': cartInfo.value});
      }
    } finally {
      isLoading(false);
    }
  }

  void navigateToHome(BuildContext context) {
    appController.reloadHomePageDestination(true);
    HomePage.navigate(context, replace: true);
  }

  void removePaymentReceiptImage(String selectedPaymentId, int index) {
    final selectedPaymentIndex = selectedPaymentMethods.indexWhere((pM) => pM.id == selectedPaymentId);
    if (selectedPaymentIndex != -1) {
      selectedPaymentMethods[selectedPaymentIndex] = selectedPaymentMethods[selectedPaymentIndex].copyWith(receiptImages: []);
      selectedPaymentMethods.refresh();
    }
  }
}
