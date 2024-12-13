import 'package:dartx/dartx.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';


import 'package:imela_core/product/model/discount.model.dart';
import 'package:imela_core/product/model/product.model.dart';
import 'package:imela_utils/helpers/base_viewmodel.dart';
import 'package:imela_utils/helpers/number_utils.dart';
import 'package:injectable/injectable.dart';

@injectable
class DynamicPriceViewmodel extends GetxController with BaseViewmodel {
  static DynamicPriceViewmodel getInstance() {
    return Get.put(DynamicPriceViewmodel());
  }

  late Product? product;
  final discountsWithPrice = Rx<Map<double, Discount?>>({});
  // Selected quantity (observable)
  var selectedQty = 1.0.obs;

  // Selected discount (observable)
  var selectedPrice = Rxn<double>();
  var basePRice = 0.0.obs;
  var selectedDiscount = Rxn<Discount?>();

  List<Discount> get selectedDiscounts => selectedDiscount.value != null ? [selectedDiscount.value!] : [];

  final ScrollController scrollController = ScrollController();

  @override
  void initViewmodel({Map<String, dynamic>? data}) {
    super.initViewmodel(data: data);
    Future.delayed(Duration.zero, () {
      final initialQty = data?['initialQty'];
      final minQty = data?['minQty'];
      selectedQty.value = initialQty ?? minQty.toDouble() ?? 1;
      basePRice.value = 0.0;
      final discounts = data?['discounts'] ?? [];
      basePRice.value = data?['basePrice'] ?? 0;
      product = data?['product'] as Product?;
      getPriceLists(discounts);
    });
  }

  void getPriceLists(List<Discount> discounts) {
    discountsWithPrice.value = {};
    discountsWithPrice.value[basePRice.value] = null;
    for (var discount in discounts) {
      final price = basePRice.value.getPercentage(discount.value);
      discountsWithPrice.value[price] = discount;
    }

    // selectedPrice.value = discountsWithPrice.value.keys.first;
    updateSelectedQty(selectedQty.value);
  }

  // Function to update the selected quantity
  void updateSelectedQty(double qty) {
    selectedQty.value = qty;
    print('initialQty ${selectedQty.value}');
    final sortedDiscounts = discountsWithPrice.value.entries.sortedBy((element) => double.tryParse(element.value?.conditionValue ?? '0') ?? 0).toList();
    final selectedDiscountValue = sortedDiscounts.lastOrNullWhere((element) {
      final conditionValue = double.tryParse(element.value?.conditionValue ?? '0');
      return (conditionValue ?? 0) <= selectedQty.value;
    });
    if (selectedDiscountValue != null) {
      selectedPrice.value = selectedDiscountValue.key;
      selectedDiscount.value = selectedDiscountValue.value;
    } else {
      selectedPrice.value = discountsWithPrice.value.keys.firstOrNull;
    }
  }

  void handleScrollonPriceChange() {
    ever(selectedPrice, (selectedPrice) {
      final index = discountsWithPrice.value.keys.toList().indexOf(selectedPrice ?? 0);
      if (index != -1) {
        scrollController.animateTo(
          index * 120.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }
}
