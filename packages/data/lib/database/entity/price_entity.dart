import 'package:isar/isar.dart';

part 'price_entity.g.dart';

@embedded
class PriceEntity {
  String? currency;
  double? amount;

  PriceEntity({this.currency, this.amount});
}
