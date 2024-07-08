import 'package:freezed_annotation/freezed_annotation.dart';
part 'price.model.freezed.dart';
part 'price.model.g.dart';

enum CurrencyType {
  USD,
  ETB,
}

@freezed
class Price with _$Price {
  factory Price({
    String? id,
    required double amount,
    @Default("ETB") String currency,
  }) = _Price;

  factory Price.fromJson(Map<String, dynamic> json) => _$PriceFromJson(json);
}


