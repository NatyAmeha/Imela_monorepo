import 'package:collection/collection.dart';
import 'package:imela_core/order/model/order_config.model.dart';

class ORderUtils{


}

extension OrderConfigUtils on List<OrderConfig>? {
  bool isContainAddonId(String addonId) {
    return this?.any((element) => element.addonId == addonId) ?? false;
  }

  double getQtyConfigValue() {
    final selectedQtyConfig = this?.lastWhereOrNull((element) => element.addonId == OrderConfig.QTY_CONFIG_ID);
    return double.tryParse(selectedQtyConfig?.singleValue ?? '1') ?? 1;
  }
}