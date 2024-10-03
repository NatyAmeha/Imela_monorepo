import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_core/business/model/payment_method.model.dart';
import 'package:imela_core/business/model/payment_option.model.dart';
import 'package:imela_core/shared/utils/exception_handler.dart';
import 'package:imela_pos/app/app_viewmodel.dart';
import 'package:imela_pos/injection.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';
import 'package:imela_utils/exception/app_exception.dart';
import 'package:imela_utils/helpers/base_viewmodel.dart';
import 'package:imela_utils/helpers/number_utils.dart';
import 'package:injectable/injectable.dart';

@injectable
class PaymentPageViewmodel extends GetxController with BaseViewmodel {
  // final Paymentusec businessUsecase;
  final IExceptiionHandler exceptiionHandler;

  PaymentPageViewmodel({
    @Named(AppExceptionHandler.injectName) required this.exceptiionHandler,
  });

  static PaymentPageViewmodel getInstance() {
    return BaseViewmodel.isViewmodelRegistered(getIt<PaymentPageViewmodel>());
  }

  // state variables
  var isLoading = false.obs;
  var exception = Rxn<AppException>();

  var selectedPaymentOption = Rxn<PaymentOption>();
  var selectedPaymentMethodId = Rxn<String>();
  var amountEntered = 0.obs;
  var enteredPayments = <String, double>{}.obs; // payment method id and amount entered

  var initialPaymentController = TextEditingController();
  var paymentMethodAmountController = TextEditingController();
  var resetPaymentMethodAmountController = false.obs;

  var selectedDueDate = Rxn<DateTime>();

  // getters
  AppViewmodel get appViewmodel => AppViewmodel.getInstance();
  List<PaymentOption> get paymentOptions => appViewmodel.paymentOptions;
  List<PaymentMethod> get paymentMethods => appViewmodel.paymentMethods;

  bool get isPayLaterOption => selectedPaymentOption.value?.type == PaymentOptionType.PAY_LATER.toString();
  double get initialAmount => double.tryParse(initialPaymentController.text) ?? 0.0;
  double get totalPaidAmount {
    return enteredPayments.values.sumBy((entry) => entry).getPresision(2);
  }

  double get totalCartAmount {
    return appViewmodel.cartInfo.value.getTotalPrice;
  }

  double get remainingAmountForDueDate {
    return (totalCartAmount - initialAmount).getPresision(2);
  }

  double get remainingAmountFromInitialPayment {
    return (initialAmount - totalPaidAmount).getPresision(2);
  }

  String get totalProductString {
    return '${appViewmodel.cartInfo.value.items?.length ?? 0} products';
  }

  String get totalCartAmountString {
    return '\$ ${totalCartAmount.toStringAsFixed(2)}';
  }

  @override
  void initViewmodel({Map<String, dynamic>? data}) {
    super.initViewmodel(data: data);
    Future.delayed(Duration.zero, () {
      if (paymentOptions.isNotEmpty) {
        updateSelectedPaymentOption(paymentOptions.first);
        initialPaymentController.text = totalCartAmount.toStringAsFixed(2);
        initialPaymentController.addListener(() {});
        paymentMethodAmountController.addListener(() {
          if (resetPaymentMethodAmountController.value) {
            resetPaymentMethodAmountController.value = false;
          }
          var amount = double.tryParse(paymentMethodAmountController.value.text) ?? 0.0;
          enteredPayments[selectedPaymentMethodId.value!] = amount;
          enteredPayments.refresh();
        });
        listtenSelectedPaymentMethodChange();
      }
    });
  }

  void listtenSelectedPaymentMethodChange() {
    ever(selectedPaymentMethodId, (value) {
      resetPaymentMethodAmountController.value = true;
      // paymentMethodAmountController.clear();
      paymentMethodAmountController.text = enteredPayments[value]?.toStringAsFixed(2) ?? '';
    });
  }

  void updateSelectedPaymentOption(PaymentOption option) {
    selectedPaymentOption.value = option;
  }

  void updateAmountEntered(int value) {
    amountEntered.value = value;
  }

  bool isPaymentSelected(PaymentMethod paymentInfo) {
    return paymentInfo.id == selectedPaymentMethodId.value;
  }

  void selectPaymentMethod(PaymentMethod paymentInfo) {
    selectedPaymentMethodId.value = paymentInfo.id;
    selectedPaymentMethodId.refresh();
  }

  void removeEntredAmount(PaymentMethod paymentMethod) {
    enteredPayments.remove(paymentMethod.id);
    // enteredPayments.refresh();
  }

  bool checkSelectedPaymentOptiontype(String paymentOptionType) {
    return selectedPaymentOption.value?.type == paymentOptionType;
  }

  Future<void> showDuedateSelector(BuildContext context, WidgetFactory widgetFactory) async {
    var dateTime = await widgetFactory.showDateTimePicker(context, selectedDueDate.value, null, null, "Confirm", "Cancel", true);
    selectedDueDate.value = dateTime;
  }
}
