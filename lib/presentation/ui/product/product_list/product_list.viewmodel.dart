import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';
import 'package:melegna_customer/domain/product/model/product.model.dart';
import 'package:melegna_customer/presentation/ui/shared/base_viewmodel.dart';
import 'package:melegna_customer/presentation/ui/shared/list/list_componenet.viewmodel.dart';
import 'package:melegna_customer/presentation/utils/exception/app_exception.dart';

@injectable
class ProductListViewmodel extends GetxController with BaseViewmodel {
  final productListController = Get.put(CustomListController<Product>(), tag: 'productListPageList');

  var isLoading = false.obs;
  var exception = Rxn<AppException>();

  @override
  void initViewmodel({Map<String, dynamic>? data}) {
    super.initViewmodel(data: data);
    var products = data?['products'] as List<Product>;
    if (products.isNotEmpty) {
      productListController.addItems(products);
    }
  }

  @override
  void onInit() {
    super.onInit();
  }

  List<Widget> getActions() {
    return [];
  }

  @override
  void onClose() {
    super.onClose();
  }
}
