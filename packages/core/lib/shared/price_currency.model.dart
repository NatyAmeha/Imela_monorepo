import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:imela_utils/helpers/localization_utils.dart';

part 'price_currency.model.freezed.dart';
part 'price_currency.model.g.dart';

@freezed
class PriceCurrency with _$PriceCurrency {
  factory PriceCurrency({
    required double price,
    required Currency currency,
  }) = _PriceCurrency;

  factory PriceCurrency.fromJson(Map<String, dynamic> json) => _$PriceCurrencyFromJson(json);
}

