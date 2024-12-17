import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_core/business/model/payment_method.model.dart';
import 'package:imela_core/business/model/payment_option.model.dart';
import 'package:imela_core/customer/model/customer.model.dart';
import 'package:imela_core/order/model/order.response.dart';
import 'package:imela_core/order/order.usecase.dart';
import 'package:imela_core/shared/price.model.dart';
import 'package:imela_core/shared/utils/exception_handler.dart';
import 'package:imela_pos/app/app_viewmodel.dart';
import 'package:imela_pos/injection.dart';
import 'package:imela_pos/ui/cart/cart.viewmodel.dart';
import 'package:imela_pos/ui/customer/component/search_customer_list_modal.dart';
import 'package:imela_pos/ui/customer/customer.viewmodel.dart';
import 'package:imela_pos/ui/order/order_confirmation_page.dart';
import 'package:imela_ui_kit/components/modal/app_modal_sheet.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';
import 'package:imela_utils/exception/app_exception.dart';
import 'package:imela_utils/helpers/base_viewmodel.dart';
import 'package:imela_utils/helpers/number_utils.dart';
import 'package:injectable/injectable.dart';
import 'package:imela_core/order/model/order.model.dart' as OrderModel;

@injectable
class PaymentPageViewmodel extends GetxController with BaseViewmodel {
  // final Paymentusec businessUsecase;
  OrderUsecase orderUsecase;

  final IExceptiionHandler exceptiionHandler;

  PaymentPageViewmodel({
    required this.orderUsecase,
    @Named(AppExceptionHandler.injectName) required this.exceptiionHandler,
  });

  static PaymentPageViewmodel getInstance() {
    return BaseViewmodel.isViewmodelRegistered(getIt<PaymentPageViewmodel>());
  }

  // state variables
  var isLoading = false.obs;
  var exception = Rxn<AppException>();

  var selectedPaymentOption = Rxn<PaymentOption>();
  var selectedPaymentMethod = Rxn<PaymentMethod>();
  var amountEntered = 0.obs;

  var initialPaymentController = TextEditingController();
  var paymentMethodAmountController = TextEditingController();
  var resetPaymentMethodAmountController = false.obs;

  var paymentMethodControllers = <String, TextEditingController>{}.obs;

  var selectedDueDate = Rxn<DateTime>();

  // getters
  AppViewmodel get appViewmodel => AppViewmodel.getInstance();
  CartViewmodel get cartViewmodel => CartViewmodel.getInstance();
  CustomerViewmodel get customerViewmodel => CustomerViewmodel.getInstance();

  List<PaymentOption> get paymentOptions => appViewmodel.paymentOptions;
  List<PaymentMethod> get paymentMethods => appViewmodel.paymentMethods;

  bool get isPayLaterOption => selectedPaymentOption.value?.isPartialPaymentOption() ?? false;
  double get initialAmount => double.tryParse(initialPaymentController.text) ?? 0.0;
  double get totalPaidAmount {
    return paymentMethodControllers.value.values.sumBy((entry) => double.tryParse(entry.text) ?? 0.0).getPresision(2);
  }

  double get totalCartAmount {
    return appViewmodel.cartInfo.value.getTotatAmountPOS();
  }

  double get paylaterAmount {
    final initialPaymentPercentage = selectedPaymentOption.value?.upfrontPayment ?? 0;
    if (initialPaymentPercentage > 0) {
      return (totalCartAmount.getPercentageOff([initialPaymentPercentage])).getPresision(2);
    }
    return 0;
  }

  double get finalTotalAmount => (totalCartAmount - paylaterAmount).getPresision(2);
  String get finalTotalAmountString => '${appViewmodel.selectedCurrency} ${finalTotalAmount.toStringAsFixed(2)}';

  double get remainingAmountFromInitialPayment {
    return (finalTotalAmount - totalPaidAmount).getPresision(2);
  }

  String get totalProductString {
    return '${appViewmodel.cartInfo.value.items?.length ?? 0} products';
  }

  String get totalCartAmountString {
    return '\$ ${totalCartAmount.toStringAsFixed(2)}';
  }

  bool get canEnablePlaceOrder {
    if (selectedPaymentOption.value?.type == PaymentOptionType.FULL_PAYMENT.name) {
      return totalPaidAmount == totalCartAmount;
    } else if (selectedPaymentOption.value?.isPartialPaymentOption() ?? false) {
      return totalPaidAmount >= finalTotalAmount;
    }
    return false;
  }

  @override
  void initViewmodel({Map<String, dynamic>? data}) {
    super.initViewmodel(data: data);
    Future.delayed(Duration.zero, () {
      isLoading.value = false;
      exception.value = null;
      if (paymentOptions.isNotEmpty) {
        updateSelectedPaymentOption(paymentOptions.first);
        initialPaymentController.text = totalCartAmount.toStringAsFixed(2);
        paymentMethodControllers.value = getPaymentMethodControllers();
      }
    });
  }

  Map<String, TextEditingController> getPaymentMethodControllers() {
    return paymentMethods.asMap().map((index, paymentMethod) {
      return MapEntry(paymentMethod.id!, TextEditingController());
    });
  }

  void updateSelectedPaymentOption(PaymentOption option) {
    selectedPaymentOption.value = option;
    paymentMethodControllers.value = getPaymentMethodControllers();
    selectPaymentMethod(paymentMethods.first);
  }

  void updateAmountEntered() {
    paymentMethodControllers.refresh();
  }

  bool isPaymentSelected(PaymentMethod paymentInfo) {
    return paymentInfo.id == selectedPaymentMethod.value?.id;
  }

  void selectPaymentMethod(PaymentMethod paymentInfo) {
    selectedPaymentMethod.value = paymentInfo;
    selectedPaymentMethod.refresh();
    paymentMethodControllers.refresh();
  }

  void removeEntredAmount(PaymentMethod paymentMethod) {
    paymentMethodControllers.value[paymentMethod.id!]?.clear();
    paymentMethodControllers.refresh();
  }

  bool checkSelectedPaymentOptiontype(String paymentOptionType) {
    return selectedPaymentOption.value?.type == paymentOptionType;
  }

  Future<void> showDuedateSelector(BuildContext context, WidgetFactory widgetFactory) async {
    var dateTime = await widgetFactory.showDateTimePicker(context, initialDate: selectedDueDate.value, confirmText: 'Confirm', cancelText: 'Cancel');
    selectedDueDate.value = dateTime;
  }

  Future<void> placeOrder(BuildContext context) async {
    try {
      isLoading.value = true;
      final selectedPaymentMethodInfo = getSelecrtedPaymentMethodsForOrder()
          .entries
          .map((entry) {
            if (entry.key > 0) {
              return SelectedPaymentMethod(id: entry.value.id, name: entry.value.name!, amount: Price(amount: entry.key, currency: 'ETB'), paymentMethodOption: null);
            }
            return null;
          })
          .whereNotNull()
          .toList();

      final cartInfo = appViewmodel.cartInfo.value;
      var orderInfo = OrderModel.Order.createOrderInfo(cartInfo, paymentOption: selectedPaymentOption.value!, paidAmount: totalPaidAmount, totalAmount: totalCartAmount, paymentMethods: selectedPaymentMethodInfo, branchId: appViewmodel.selectedBranch.value?.id, orderNote: cartViewmodel.ordernote.value);
      final orderResponse = await orderUsecase.placePOSBusiness(appViewmodel.selectedBusiness.value!.id!, orderInfo, customerId: cartViewmodel.customerId);
      if (orderResponse.success ?? false) {
        cleanupResources(context);
        handleOrderConfirmation(context, orderResponse.order);
      }
    } catch (ex) {
      print('error $ex');
    } finally {
      isLoading.value = false;
    }
  }

  void cleanupResources(BuildContext context) {
    appViewmodel.resetCartInfo();
    cartViewmodel.initCartActions();
    cartViewmodel.removeAppliedDiscounts();
    appViewmodel.setSelectedCustomer(null);
    cartViewmodel.resetOrderNote(null);
  }

  Map<double, PaymentMethod> getSelecrtedPaymentMethodsForOrder() {
    return paymentMethodControllers.value.map((key, value) {
      final selectedPrice = double.tryParse(value.text) ?? 0.0;
      return MapEntry(selectedPrice, paymentMethods.firstWhere((element) => element.id == key));
    });
  }

  void handleOrderConfirmation(BuildContext context, OrderModel.Order? order) {
    cartViewmodel.clearCart(context);
    appViewmodel.setSelectedCustomer(null);
    if (order != null) {
      OrderConfirmationPage.navigate(context, order: order);
    }
  }

  // Future<void> showCustomerListModal(BuildContext context, {String title = 'Select customer', String? description}) async {
  //   final customers = appViewmodel.posCustomers;
  //   const pageId = 'customer_list_page';
  //   await AppModalSheet.showModal(
  //     context,
  //     type: AppModalSheetType.DIALOG,
  //     pages: [
  //       ModalContent(
  //         id: pageId,
  //         title: const Text('Select customer'),
  //         content: SearchCustomerListModal(
  //           customers: customers,
  //           selectedCustomer: appViewmodel.selectedCustomer.value,
  //           title: title,
  //           description: description,
  //           onCustomerSelected: (contextt, customerSelected) {
  //             AppModalSheet.closeModal();
  //             appViewmodel.setSelectedCustomer(customerSelected);
  //           },
  //         ),
  //       ),
  //     ],
  //   );
  // }
}
