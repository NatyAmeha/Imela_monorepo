import 'package:isar/isar.dart';

@embedded
class PriceEntity {
  String? currency;
  double? amount;

  PriceEntity({this.currency, this.amount});
}
