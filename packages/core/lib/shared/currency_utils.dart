
import 'package:collection/collection.dart';
import 'package:imela_core/shared/price.model.dart';
import 'package:imela_utils/helpers/number_utils.dart';

extension CurrencyUtils on List<Price>? {
  String toSelectedPriceString(String currency) {

    final selectedPrice = this?.toSelectedPrice(currency);
    if (selectedPrice == null) {
      return '';
    }
    return '${selectedPrice.currency} ${selectedPrice.amount.getPresision(2)}';
  }

  Price? toSelectedPrice(String currency) {
    if (this == null || this?.isEmpty == true) {
      null;
    }
    return this?.firstWhereOrNull((element) => element.currency == currency) ?? this!.firstOrNull;
  }
}

extension StringCurrencyUtil on String{
   String withCurrencySymbol(String currency){
    return '${currency} $this';
   }
}
