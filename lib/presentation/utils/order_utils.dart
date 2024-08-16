import 'package:melegna_customer/domain/order/model/order_config.model.dart';

class ORderUtils{


}

extension OrderConfigUtils on List<OrderConfig>? {
  bool isContainAddonId(String addonId) {
    return this?.any((element) => element.addonId == addonId) ?? false;
  }
}