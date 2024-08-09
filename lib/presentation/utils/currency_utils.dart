import 'package:get/get.dart';
import 'package:melegna_customer/domain/shared/price.model.dart';
import 'package:melegna_customer/presentation/ui/app_controller.dart';

extension CurrencyUtils on List<Price>? {
  String toSelectedPriceString() {
    final selectedPrice = toSelectedPrice();
    if (selectedPrice == null) {
      return '';
    }
    return '${selectedPrice.currency} ${selectedPrice.amount.toPrecision(2)}';
  }

  Price? toSelectedPrice() {
    if (this == null || this?.isEmpty == true) {
      null;
    }
    final selectedCurrencyType = AppController.getInstance.selectedCurrency;
    return this!.firstWhereOrNull((element) => element.currency == selectedCurrencyType.name) ?? this!.first;
  }
}
